pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "."
import UIEnum

ApplicationWindow {
    id: window
    width: 1280
    height: 720
    visible: true
    title: $appname

    //! [orientation]
    readonly property bool portraitMode: !settingsDialog.orientationCheckBox.checked || window.width < window.height
    //! [orientation]

    required property var builtInStyles

    readonly property var typeList: [
        UIEnum.FT_DownloadLyric,
        UIEnum.FT_UploadWiki,
        UIEnum.FT_UploadUserCheck,
        UIEnum.FT_LyricTool,
        666,
    ]

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
}
