import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

import "."
import "../common"
import UIEnum
import HelperError

Page {
    property int source: 0
    property var channelId: currentChannel?.id || 0
    property var currentChannel
    property var model: styleList[comboBox_region.currentIndex]?.channels || []
    property var styleList: []
    id: root
    focus: true
    footer: Column {
        Row {
            ComboBox {
                id: comboBox_region
                model: root.styleList.map(i => i.chineseName || i.name || "")
            }
        }
        Row {
            spacing: 5
            CommonAnimatedImage {
                fixedSize: 60
                imgUrl: currentChannel?.cover || ""
                anchors.verticalCenter: parent.verticalCenter
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: 500
                spacing: 5
                Repeater {
                    model: [
                        currentChannel?.name || "",
                        playlist[currentIndex]?.name || "",
                    ]
                    Label {
                        width: parent.width
                        text: modelData
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    function init() {
        let ret = $apimgr.invoke("dj_difm_all_style_channel", { "sources": JSON.stringify([source]) })
        root.styleList = ret?.data[0]?.styles
    }

    function update() {
        let ret = $apimgr.invoke("dj_difm_playing_tracks_list", { "channelId": root.channelId, "source": root.source, })
        playlist = ret?.data?.list || []
        console.log("new list:", playlist.map(i => i.id))
    }

    Component.onCompleted: root.init()
    onVisibleChanged: if (visible) root.update()

    ColumnLayout {
        anchors.fill: parent
        ItemFlowPage {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.model.map(i => Object.assign({}, i, {
                                                         "imgUrl": i.cover || "",
                                                         "names": [ i.name, i.chineseName, ],
                                                     }))
            onClicked: function(modelData) {
                root.currentChannel = modelData
                root.update()

                root.start()
            }
        }
    }
    property var playlist: []
    property int currentIndex: 0

    function start() {
        mediaPlayer.callback = () => {
            if (mediaPlayer.playbackState === MediaPlayer.StoppedState) {
                root.next()
            }
        }
        currentIndex = -1
        root.next()
    }

    function next() {
        currentIndex++
        if (currentIndex === playlist.length) {
            root.update()
            currentIndex = 0
        }
        let audio = playlist[currentIndex]?.audio
        mediaPlayer.source = audio
        mediaPlayer.play()
    }
}
