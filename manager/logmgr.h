#ifndef LOGMGR_H
#define LOGMGR_H

#include <QFile>
#include <QMutex>
#include <QObject>

namespace UINamespace {
/**
 * @class LogMgr
 * @brief LogMgr日志管理类
 */
class LogMgr: public QObject
{
    Q_OBJECT
public:
    static LogMgr* instance();
    // 日志输出函数
    static void handler(QtMsgType type, const QMessageLogContext &context, const QString &msg);
    // 打开日志文件夹
    Q_INVOKABLE void openLogFolder();

    LogMgr();

private:
    void initInternal();
    void handlerInternal(QtMsgType type, const QMessageLogContext &context, const QString &msg);
    // 日志文件后缀
    QString logFileSuffix();

private:
    QMutex m_mtxLog;                // 日志锁
    QFile *m_logFile = Q_NULLPTR;   // 日志文件句柄

    QString m_logDirPath; // 日志文件夹绝对路径
    QString m_logFilePath; // 日志文件绝对路径
};
}

#endif // LOGMGR_H
