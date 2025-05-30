import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import UIEnum


Menu {
    title: qsTr("帮助")
    id: root
    Repeater {
        model: [
            { "text": qsTr("设置"), "onClicked": () => { settingsDialog.open() }, "enabled": true, },
            { "text": qsTr("打开日志目录"), "onClicked": () => { $logmgr.openLogFolder() }, "enabled": true, },
            { "text": qsTr("关于"), "onClicked": () => { aboutDialog.open() }, "enabled": true, },
        ]
        MenuItem {
            text: modelData.text
            onTriggered: modelData.onClicked()
            enabled: modelData.enabled
        }
    }
}
