#include "logmgr.h"
#include "logger.h"
#include "globalconst.h"

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QUrl>
#include <QDesktopServices>
#include <iostream>

using namespace UINamespace;
Q_GLOBAL_STATIC(LogMgr, logMgr)
LogMgr *LogMgr::instance()
{
    return logMgr();
}

void LogMgr::handler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    instance()->handlerInternal(type, context, msg);
}

void LogMgr::openLogFolder()
{
    QDesktopServices::openUrl(QUrl::fromLocalFile(m_logDirPath));
}

LogMgr::LogMgr()
{
    this->initInternal();
}

const static QString g_format = "yyyy_MM_dd_HHmmss_zzz"; // 日志文件夹的日期格式
const static int g_logExpiredDateNum = 30; // 日志超时自动清除日期

void LogMgr::initInternal()
{
    qSetMessagePattern("%{time yyyy-MM-dd hh:mm:ss.zzz} : %{threadid} : %{category} : %{type} : %{line} : %{function} : %{message}");
    qInstallMessageHandler(LogMgr::handler);
    QLoggingCategory::setFilterRules("QCloudMusicApi.debug=false");

    QLocale locale(QLocale::English, QLocale::UnitedKingdom);
    auto curDt = QDateTime::currentDateTime();
    auto curDtStr = locale.toString(curDt, g_format);

#ifdef Q_OS_MAC
    auto tempPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
#else
    auto tempPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
#endif

    auto allDirPath = tempPath + "/" + ORGANIZATION_NAME + "/"+ APPLICATION_NAME;
    m_logDirPath = allDirPath + "/" + curDtStr;
    m_logFilePath = m_logDirPath + QString("/log_%1_").arg(APPLICATION_NAME) + curDtStr + logFileSuffix();
    QDir dir(m_logDirPath);
    if (!dir.exists() && !dir.mkpath(m_logDirPath))
    {
        // 创建日志文件夹失败
    }
    else
    {
        m_logFile = new QFile(m_logFilePath);
        if (!m_logFile->open(QIODevice::ReadWrite | QIODevice::Append))
        {
            if (m_logFile)
            {
                delete m_logFile;
                m_logFile = Q_NULLPTR;
            }
        }

        dir = QDir(allDirPath);
        for (const auto &dirPath : dir.entryList(QDir::AllDirs|QDir::NoDotAndDotDot))
        {
            dir = QDir(allDirPath + "/" + dirPath);

            auto dirName = dir.dirName();
            auto dirBirthDt = QDateTime::fromString(dirName, g_format);
            if (dirBirthDt.isValid()
                && dirBirthDt != curDt
                && dirBirthDt.daysTo(curDt) > g_logExpiredDateNum) // 大于某个日期的日志自动删除
            {
                //if (dir.removeRecursively())
                //    INFO << "Delete log directory. Path:" << dir.path();
            }
        }
    } 
}

void LogMgr::handlerInternal(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QMutexLocker lock(&m_mtxLog);
    QString message = qFormatLogMessage(type, context, msg);
    qDebug().noquote() << message;

    if (m_logFile)
    {
        auto strFormatMsg = message.append("\r\n");
        m_logFile->write(qUtf8Printable(strFormatMsg));
        m_logFile->flush();
    }
}

QString LogMgr::logFileSuffix()
{
    QString suffix = ".txt";

#ifdef Q_OS_WIN
    suffix = ".txt";
#elif defined(Q_OS_MAC)
    suffix = ".log";
#endif

    return suffix;
}
