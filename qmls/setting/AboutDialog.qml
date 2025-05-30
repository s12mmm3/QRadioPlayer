
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Dialog {
    id: aboutDialog
    modal: true
    focus: true
    title: qsTr("关于")
    contentHeight: aboutColumn.height

    Column {
        id: aboutColumn
        spacing: 20

        Label {
            width: aboutDialog.availableWidth
            text: $appname
            wrapMode: Label.Wrap
            font.pixelSize: 12
        }
    }
}
