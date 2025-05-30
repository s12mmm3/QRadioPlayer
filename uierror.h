#ifndef UIERROR_H
#define UIERROR_H

#include <QObject>

namespace UINamespace {
Q_NAMESPACE

/**
 * @brief 错误码枚举
 */
enum ErrorCode {
    EC_NO_ERROR = 0, // 没问题
};
Q_ENUM_NS(ErrorCode)
}

#endif // UIERROR_H
