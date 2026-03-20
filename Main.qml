pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtMultimedia

import "."
import UIEnum

ApplicationWindow {
    id: window
    width: 1280
    height: 720
    visible: true
    title: $appname

    property alias source: mediaPlayer.source
    property alias playbackRate: mediaPlayer.playbackRate
    property bool fullScreen: false

    //! [orientation]
    readonly property bool portraitMode: !settingsDialog.orientationCheckBox.checked || window.width < window.height
    //! [orientation]

    required property var builtInStyles

    menuBar: MenuBar {
        AccountMenu { }
    }

    StackView {
        id: stackView

        anchors.fill: parent

        initialItem: mainPage
    }

    Component {
        id: mainPage
        MainPage {}
    }

    SettingsDialog {
        id: settingsDialog
        anchors.centerIn: Overlay.overlay
        builtInStyles: window.builtInStyles
    }

    AboutDialog {
        id: aboutDialog
        anchors.centerIn: Overlay.overlay
        width: Math.min(window.width, window.height) / 3 * 2
    }

    function message(text) {
        dialogMessage.title = text
        dialogMessage.open()
    }

    Dialog {
        id: dialogMessage
        modal: true
        focus: true
        anchors.centerIn: parent
    }

    MetadataInfo {
        id: metadataInfo
    }

    TracksInfo {
        id: audioTracksInfo
        onSelectedTrackChanged: {
            mediaPlayer.activeAudioTrack = selectedTrack
            mediaPlayer.updateMetadata()
        }
    }

    TracksInfo {
        id: videoTracksInfo
        onSelectedTrackChanged: {
            mediaPlayer.activeVideoTrack = selectedTrack
            mediaPlayer.updateMetadata()
        }
    }

    TracksInfo {
        id: subtitleTracksInfo
        onSelectedTrackChanged: {
            mediaPlayer.activeSubtitleTrack = selectedTrack
            mediaPlayer.updateMetadata()
        }
    }

    MediaDevices {
        id: mediaDevices
        onAudioOutputsChanged: {
            audio.device = mediaDevices.defaultAudioOutput
        }
    }

    //! [1]
    MediaPlayer {
        id: mediaPlayer
        //! [1]
        function updateMetadata() {
            metadataInfo.clear()
            metadataInfo.read(mediaPlayer.metaData)
            metadataInfo.read(mediaPlayer.audioTracks[mediaPlayer.activeAudioTrack])
            metadataInfo.read(mediaPlayer.videoTracks[mediaPlayer.activeVideoTrack])
            metadataInfo.read(mediaPlayer.subtitleTracks[mediaPlayer.activeSubtitleTrack])
        }
        //! [2]
        videoOutput: videoOutput
        audioOutput: AudioOutput {
            id: audio
            muted: playbackController.muted
            volume: playbackController.volume
        }
        //! [2]
        //! [4]
        onErrorOccurred: {
            mediaError.text = mediaPlayer.errorString
            mediaError.open()
        }
        //! [4]
        onMetaDataChanged: { updateMetadata() }
        //! [6]
        onTracksChanged: {
            audioTracksInfo.read(mediaPlayer.audioTracks)
            videoTracksInfo.read(mediaPlayer.videoTracks)
            subtitleTracksInfo.read(mediaPlayer.subtitleTracks, 6) /* QMediaMetaData::Language = 6 */
            updateMetadata()
            mediaPlayer.play()
        }
        //! [6]

        property var callback
        onPlaybackStateChanged: {
            if (callback) callback()
        }

    }

    //! [3]
    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        visible: mediaPlayer.mediaStatus > 0

        // TapHandler {
        //     onDoubleTapped: {
        //         root.fullScreen ?  root.showNormal() : root.showFullScreen()
        //         root.fullScreen = !root.fullScreen
        //     }
        // }
    }
    //! [3]

    //! [5]
    footer: PlaybackControl {
        id: playbackController
        //! [5]

        //! [6]
        mediaPlayer: mediaPlayer
        audioTracksInfo: audioTracksInfo
        videoTracksInfo: videoTracksInfo
        subtitleTracksInfo: subtitleTracksInfo
        metadataInfo: metadataInfo
    }
    //! [6]
}
