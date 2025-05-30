import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Dialog {
    property var builtInStyles: []
    property alias orientationCheckBox: orientationCheckBox
    id: root
    modal: true
    focus: true
    title: qsTr("Settings")

    Settings {
        id: settings
        property string style
    }

    onVisibleChanged: {
        if (visible) {
            textField_proxy.text = $apimgr.proxy
        }
    }

    standardButtons: Dialog.Ok | Dialog.Cancel
    onAccepted: {
        settings.style = styleBox.displayText
        $apimgr.proxy = textField_proxy.text
        root.close()
    }
    onRejected: {
        styleBox.currentIndex = styleBox.styleIndex
        root.close()
    }

    contentItem: ColumnLayout {
        id: settingsColumn
        spacing: 20

        RowLayout {
            spacing: 10

            Label {
                text: qsTr("Style:")
            }

            ComboBox {
                id: styleBox
                property int styleIndex: -1
                model: root.builtInStyles
                Component.onCompleted: {
                    styleIndex = find(settings.style, Qt.MatchFixedString)
                    if (styleIndex !== -1)
                        currentIndex = styleIndex
                }
                Layout.fillWidth: true
            }
        }

        RowLayout {
            id: colorSchemes
            // Some Qt Quick styles prioritize the respective design system guidelines
            // over the system palette.
            enabled: ["FluentWinUI3", "Fusion", "iOS"].includes(styleBox.currentText)
            CheckBox {
                id: autoColorScheme
                checked: true
                text: qsTr("Auto")
            }
            CheckBox {
                id: darkColorScheme
                text: qsTr("Dark Mode")
            }
            CheckBox {
                id: lightColorScheme
                text: qsTr("Light Mode")
            }
            ButtonGroup {
                exclusive: true
                buttons: colorSchemes.children
                onCheckedButtonChanged: {
                    let scheme;
                    switch (checkedButton) {
                    case autoColorScheme:
                        scheme = Qt.Unknown
                        break;
                    case darkColorScheme:
                        scheme = Qt.Dark
                        break;
                    case lightColorScheme:
                        scheme = Qt.Light
                        break;
                    }
                    Qt.styleHints.colorScheme = scheme
                }
            }
        }

        CheckBox {
            id: orientationCheckBox
            text: qsTr("Enable Landscape")
            checked: false
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("Restart required")
            color: "#e41e25"
            opacity: styleBox.currentIndex !== styleBox.styleIndex ? 1.0 : 0.0
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            Layout.fillWidth: true
            // Layout.fillHeight: true
        }

        TextField {
            Layout.fillWidth: true
            placeholderText: qsTr("代理地址")
            id: textField_proxy
        }
    }
}
