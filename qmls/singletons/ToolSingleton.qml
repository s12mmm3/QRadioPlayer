pragma Singleton

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml
import QtQuick.Dialogs

import "."
import HelperError
import UIEnum

Item {
    id: root

    // 获取图片url的尺寸参数
    function getImgParam(fixedSize = 80) {
        let ratio = Screen.devicePixelRatio
        return `?param=${Math.round(fixedSize * ratio)}y${Math.round(fixedSize * ratio)}`
    }
}
