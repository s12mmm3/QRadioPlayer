#include "utility.h"
#include "logger.h"
#include "manager/apimgr.h"
#include "manager/logmgr.h"
#include "globalconst.h"

#include "dumpcatcher.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QQuickStyle>
#include <QIcon>
#include <QLoggingCategory>
#include <QLocale>
#include <QTranslator>
#include <QFontDatabase>

using namespace UINamespace;

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

    QGuiApplication::setApplicationName(APPLICATION_NAME);
    QGuiApplication::setOrganizationName(ORGANIZATION_NAME);
    QGuiApplication app(argc, argv);
#ifdef Q_OS_WASM
    // 加载字体
    int fontId = QFontDatabase::addApplicationFont(":/fonts/Alibaba-PuHuiTi-Medium.ttf");
    QString family = QFontDatabase::applicationFontFamilies(fontId).at(0);

    // 设置全局字体
    QFont font(family);
    app.setFont(font);
#endif

    registerTypes();

    QIcon::setThemeName("gallery");

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "QRadioPlayer_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }

    QSettings settings;
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE"))
        QQuickStyle::setStyle(settings.value("style").toString());

    // If this is the first time we're running the application,
    // we need to set a style in the settings so that the QML
    // can find it in the list of built-in styles.
    const QString styleInSettings = settings.value("style").toString();
    if (styleInSettings.isEmpty())
        settings.setValue(QLatin1String("style"), QQuickStyle::name());

    QQmlApplicationEngine engine;

    contextPropertys(engine);

    QStringList builtInStyles = { QLatin1String("Basic"), QLatin1String("Fusion"),
                                 QLatin1String("Imagine"), QLatin1String("Material"), QLatin1String("Universal"),
                                 QLatin1String("FluentWinUI3") };
#if defined(Q_OS_MACOS)
    builtInStyles << QLatin1String("macOS");
    builtInStyles << QLatin1String("iOS");
#elif defined(Q_OS_IOS)
    builtInStyles << QLatin1String("iOS");
#elif defined(Q_OS_WINDOWS)
    builtInStyles << QLatin1String("Windows");
#endif

    engine.setInitialProperties({{ "builtInStyles", builtInStyles }});
    engine.load(QUrl("qrc:/Main.qml"));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
