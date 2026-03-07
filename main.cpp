#include "utility.h"
#include "logger.h"
#include "manager/apimgr.h"
#include "manager/logmgr.h"
#include "globalconst.h"
#include "dumpcatcher.h"
#include "uienum.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QOperatingSystemVersion>
#include <QQuickStyle>
#include <QIcon>
#include <QLoggingCategory>
#include <QLocale>
#include <QTranslator>
#include <QFontDatabase>
#include <QQuickWindow>

using namespace UINamespace;

using namespace Qt::StringLiterals;

static constexpr auto styleKey = "style"_L1;

void registerTypes()
{
    qmlRegisterUncreatableType<UIEnum>("UIEnum", 1, 0, "UIEnum", "Access to enums & flags only");
    qmlRegisterUncreatableMetaObject(UINamespace::staticMetaObject, "HelperError", 1, 0, "HelperError", "Access to enums & flags only");
}

Utility utility;
bool contextPropertys(QQmlEngine& engine)
{
    engine.rootContext()->setContextProperty("$utility", &utility);
    engine.rootContext()->setContextProperty("$apimgr", ApiMgr::instance());
    engine.rootContext()->setContextProperty("$logmgr", LogMgr::instance());

    engine.rootContext()->setContextProperty("$appname", APPLICATION_NAME);
    return true;
}

int main(int argc, char *argv[])
{
    DumpCatcher::initDumpCatcher(APPLICATION_NAME);

    QQuickWindow::setGraphicsApi(QSGRendererInterface::Unknown);
    QCoreApplication::setApplicationName(APPLICATION_NAME);
    QCoreApplication::setOrganizationName(ORGANIZATION_NAME);
    QGuiApplication app(argc, argv);
#if defined(Q_OS_WASM) || defined(Q_OS_LINUX) || defined(Q_OS_ANDROID)
    // 加载字体
    int fontId = QFontDatabase::addApplicationFont(":/fonts/HarmonyOS_Sans_SC_Medium.ttf");
    QString family = QFontDatabase::applicationFontFamilies(fontId).value(0);
    if (!family.isEmpty())
    {
        // 设置全局字体
        QFont font(family);
        app.setFont(font);
    }
#else
#endif

    registerTypes();

    QIcon::setThemeName("gallery"_L1);

    QSettings settings;
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE"))
        QQuickStyle::setStyle(settings.value(styleKey).toString());

    // If this is the first time we're running the application,
    // we need to set a style in the settings so that the QML
    // can find it in the list of built-in styles.
    const QString styleInSettings = settings.value(styleKey).toString();
    if (styleInSettings.isEmpty())
        settings.setValue(styleKey, QQuickStyle::name());

    QQmlApplicationEngine engine;

    contextPropertys(engine);
    QStringList builtInStyles = { "Basic"_L1, "Fusion"_L1, "Imagine"_L1,
                                 "Material"_L1, "Universal"_L1, "FluentWinUI3"_L1 };
    if constexpr (QOperatingSystemVersion::currentType() == QOperatingSystemVersion::MacOS)
        builtInStyles << "macOS"_L1 << "iOS"_L1;
    else if constexpr (QOperatingSystemVersion::currentType() == QOperatingSystemVersion::IOS)
        builtInStyles << "iOS"_L1;
    else if constexpr (QOperatingSystemVersion::currentType() == QOperatingSystemVersion::Windows)
        builtInStyles << "Windows"_L1;

    engine.setInitialProperties({{ "builtInStyles"_L1, builtInStyles }});
    engine.load(QUrl("qrc:/Main.qml"));
    if (engine.rootObjects().isEmpty())
        return -1;

    return QCoreApplication::exec();
}
