#ifndef APIMGR_H
#define APIMGR_H

#include "QCloudMusicApi/apihelper.h"

namespace UINamespace {
/**
 * @class ApiMgr
 * @brief ApiMgr管理类，管理API的生命周期。
 */
class ApiMgr: public ApiHelper
{
    Q_OBJECT
public:
    ApiMgr();
    static ApiMgr* instance();

    // 登录/其他需要账号信息的接口使用
    Q_INVOKABLE QVariantMap invoke(QString member, QVariantMap arg);
    // 匿名使用
    Q_INVOKABLE QVariantMap anonimous(QString member, QVariantMap arg);

private:
    Q_DISABLE_COPY_MOVE(ApiMgr)
};
}

#endif // APIMGR_H
