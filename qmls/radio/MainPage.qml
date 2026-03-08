import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

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

        comboBox_region.currentIndex = 1
        comboBox_category.currentIndex = 0

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
        ItemFlowPage {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.model.map(i => Object.assign({}, i, {
                                                         "imgUrl": i.coverUrl || "",
                                                         "names": [ i.regionName, i.name, ],
                                                     }))
            onClicked: function(modelData) {
                let ret = $apimgr.invoke("broadcast_channel_currentinfo", { "id": modelData.id })
                let playUrl = ret?.data?.playUrl || ""
                mediaPlayer.source = playUrl
                mediaPlayer.play()
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
