import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

import "."
import UIEnum
import HelperError

Page {
    property var model: []
    property var regionList: []
    property var categoryList: []
    id: root
    focus: true
    header: Row {
        ComboBox {
            id: comboBox_region
            model: root.regionList
            textRole: "name"
            valueRole: "id"
            onActivated: root.update()
        }
        ComboBox {
            id: comboBox_category
            model: root.categoryList
            textRole: "name"
            valueRole: "id"
            onActivated: root.update()
        }
    }

    function init() {
        let ret = $apimgr.invoke("broadcast_category_region_get", {})
        root.regionList = [{ "name": "全部", "id": 0 }].concat(ret?.data?.regionList)
        root.categoryList = [{ "name": "全部", "id": 0 }].concat(ret?.data?.categoryList)
        update()
    }

    function update() {
        let ret = $apimgr.invoke("broadcast_channel_list", { "limit": 1000, "regionId": comboBox_region.currentValue, "categoryId": comboBox_category.currentValue })
        root.model = ret?.data?.list
    }

    Component.onCompleted: root.init()
    onVisibleChanged: if (visible) root.update()

    ColumnLayout {
        anchors.fill: parent
        ScrollablePage {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            Flow {
                // 子项移动动画
                move: ToolSingleton.transition
                // 子项添加动画
                add: ToolSingleton.transition
                populate: ToolSingleton.transition

                Repeater {
                    model: root.model
                    ItemDelegate {
                        id: delegate
                        required property var modelData
                        required property int index
                        contentItem: Column {
                            width: 80
                            spacing: 5
                            Label {
                                width: parent.width
                                text: delegate.modelData.regionName
                                elide: Text.ElideRight
                            }
                            Label {
                                width: parent.width
                                text: delegate.modelData.name
                                elide: Text.ElideRight
                            }
                        }
                        onClicked: {
                            let ret = $apimgr.invoke("broadcast_channel_currentinfo", { "id": delegate.modelData.id })
                            let playUrl = ret?.data?.playUrl || ""
                            mediaPlayer.source = playUrl
                            mediaPlayer.play()
                        }
                    }
                }
            }
        }
    }


    MediaPlayer {
        id: mediaPlayer
        audioOutput: AudioOutput {
            id: audio
            muted: playbackControl.muted
            volume: playbackControl.volume
        }
    }

    footer: PlaybackControl {
        id: playbackControl

        mediaPlayer: mediaPlayer
    }
}
