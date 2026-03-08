import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

AnimatedImage {
    property double fixedSize: 50
    property string imgUrl: ""
    Layout.preferredWidth: fixedSize
    Layout.preferredHeight: fixedSize
    width: fixedSize
    height: fixedSize
    Layout.alignment: Qt.AlignVCenter
    source: imgUrl && fixedSize ? imgUrl + ToolSingleton.getImgParam(fixedSize) : imgUrl
    visible: Boolean(source)
    fillMode: Image.PreserveAspectFit
}
