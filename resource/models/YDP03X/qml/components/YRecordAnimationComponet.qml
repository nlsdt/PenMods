import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import BaseQml 1.0
import "../i18n"
Item {
    property int r_width: 180
    property int r_height: 80
    property bool isStart: false
    property int animationduration: 300
    property bool isRead: false
    width: r_width
    height: r_height

    signal recordStart()
    signal recordStop()

    YLoader {
        id: id_start_record_button_loader
        anchors.fill: parent
        asynchronous: false
        active: !isStart
        sourceComponent: id_start_button_componet
    }

    YLoader {
        id: id_recording_button_loader
        asynchronous: false
        active: isStart
        sourceComponent: id_recording_componet
    }

    //录音按钮
    Component {
        id: id_start_button_componet
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            opacity: isRead ? 0.7 : 1
            YImage {
                anchors.horizontalCenter: parent.horizontalCenter
                width: r_width - 50
                height: r_height
                sourceSize: Qt.size(r_width, r_height)
                imageName: "dict/follow_microphone_icon"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    isStart = true
                    isRead = true
                    recordStart()
                }
            }
        }
    }

    // 录音动画
    Component {
        id: id_recording_componet
        Rectangle {
            width: r_width
            height: r_height
            color: "transparent"
            property alias sequentAnimation: id_top_screen_animation

            YAnimatedImagesView {
                id: id_top_screen_animation
                anchors.bottom:parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                frameSize: Qt.size(r_width , r_height)
//                objectName: "id_touch_talk_page.qml"
                imageName:"asr_recording"
                imageNameLoop:"asr_recording"
                frameCount:79
                frameCountLoop:79
                YButtonBaseMouseArea {
                    id: id_button
                    anchors.fill: parent
                    onValidClicked: {
                        isStart = false
                        recordStop()
                    }
                    objectName: "YListennigButton.qml_id_button"
                }
                Component.onCompleted: {
                    console.log("seven:animation:2")
                    id_top_screen_animation.play()
                }
            }

            Component.onCompleted: {
                console.log("seven:animation:2")
                id_top_screen_animation.play()
            }
        }
    }
}
