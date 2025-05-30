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
    property alias transition: transition
    Transition {
        id: transition
        ParallelAnimation { // 并行动画
            NumberAnimation {
                properties: "x"
                duration: 200
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                properties: "y"
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
}
