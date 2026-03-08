import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "."
import "../common"
import UIEnum
import HelperError

Page {
    property var model: []
    property var regionList: []
    property var categoryList: []
    id: root
    focus: true

    header: TabBar {
        id: bar
        width: parent.width
        Repeater {
            model: [ qsTr("广播电台"), qsTr("最嗨电音"), qsTr("古典电台"), qsTr("爵士电台") ]
            TabButton { text: modelData }
        }
    }

    contentItem: StackLayout {
        id: stackLayout
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: bar.currentIndex

        BroadCast { id: broadCast }
        FIFM { id: electronic; source: 0 }
        FIFM { id: classical; source: 1 }
        FIFM { id: jazz; source: 2 }
    }
}
