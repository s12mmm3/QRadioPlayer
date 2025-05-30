#include "apimgr.h"
#include "logger.h"

#include <QJsonDocument>

using namespace UINamespace;

Q_GLOBAL_STATIC(ApiMgr, apiMgr)
Q_GLOBAL_STATIC(ApiHelper, anonimousHelper)

ApiMgr::ApiMgr()
{
    // 绑定匿名API的属性
    connect(this, &ApiHelper::realIPChanged, [=]() {
        anonimousHelper->set_realIP(this->ApiHelper::realIP());
    });
    connect(this, &ApiHelper::proxyChanged, [=]() {
        anonimousHelper->set_proxy(this->ApiHelper::proxy());
    });
}

ApiMgr *ApiMgr::instance()
{
    return apiMgr();
}

QVariantMap invoke_p(ApiHelper* helper, QString member, QVariantMap arg)
{
    // arg["realIP"] = "58.100.87.193";
    auto result = helper->ApiHelper::invoke(member, arg)["body"].toMap();
    auto code = result.value("code").toLongLong();
    DEBUG.noquote() << member << code;
    if (code != 200)
    {
        // 502 网络连接断开
        WARNING.noquote() << code << member << Qt::endl << QJsonDocument::fromVariant(arg).toJson() << Qt::endl << QJsonDocument::fromVariant(result).toJson();
    }
    return result;
}

QVariantMap ApiMgr::invoke(QString member, QVariantMap arg) { return invoke_p(this, member, arg); }
QVariantMap ApiMgr::anonimous(QString member, QVariantMap arg) { return invoke_p(anonimousHelper(), member, arg); }
