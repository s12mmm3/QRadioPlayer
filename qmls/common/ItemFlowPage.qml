import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

ScrollablePage {
    id: root
    property var model: []
    signal clicked(var modelData)
    clip: true
    Flow {
        // 子项移动动画
        move: transition
        // 子项添加动画
        add: transition
        populate: transition

        Transition {
            id: transition
            ParallelAnimation { // 并行动画
                NumberAnimation {
                    properties: "x"
                    duration: 350
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    properties: "y"
                    duration: 350
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Repeater {
            model: root.model
            ItemDelegate {
                id: delegate
                required property var modelData
                required property int index
                contentItem: Row {
                    spacing: 5
                    CommonAnimatedImage {
                        fixedSize: 60
                        imgUrl: delegate.modelData.imgUrl
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        spacing: 5
                        Repeater {
                            model: delegate.modelData.names
                            Label {
                                width: parent.width
                                text: modelData
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
                onClicked: {
                    root.clicked(delegate.modelData)
                }
            }
        }
    }
}
