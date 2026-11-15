import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

Item {
    id: id_touch_reading_book_download_button
    implicitWidth: 40
    implicitHeight: YEnum.DS_SUCCEED === downloadState ? 68 : 40

    property int downloadState: YEnum.DS_NOT
    property int progress: 0

    signal download()

    YLoader {
        active: true
        anchors.fill: parent
        sourceComponent: {
            switch (downloadState) {
            case YEnum.DS_NOT:
            case YEnum.DS_CANCEL:
                return id_normal_component
            case YEnum.DS_SUCCEED:
                return id_succeed_component
            case YEnum.DS_ING:
            default:
                console.log("hihi: ",id_touch_reading_book_download_button.progress)
                if (id_touch_reading_book_download_button.progress <= 5) {
                    return id_waitting_component
                } else if (id_touch_reading_book_download_button.progress >= 99) {
                    return id_downloaded_component
                }
                return id_downloading_component
            }
        }
    }

    YMouseArea {
        anchors.fill: parent
        anchors.margins: -6
        enabled: YEnum.DS_SUCCEED !== downloadState
        onClicked: {
            download()
        }
    }

    Component {
        id: id_normal_component
        YIconButton {
            color: "#27282C"
            radius: 16
            sourceSize: Qt.size(24, 24)
            mouseAreaMargins: -6
            imageName: "touchreading/download"
            onClicked: {
                download()
            }
        }
    }

    Component {
        id: id_succeed_component
        Rectangle {
            color: "#27282C"
            radius: 16
            opacity: 0.3
            YTextMedium {
                font.family: fontManager.fontFamilyZhCn
                font.pixelSize: 16
                text: "已入\n书架"
                anchors.centerIn: parent
            }
        }
    }

    Component {
        id: id_waitting_component
        Item {
            YCircularProgressBar {
                id: id_waitting
                anchors.fill: parent
                size: 46
                lineWidth: 6
                lineCap: "round"
                primaryColor: "#ACD94E"
                secondaryColor: "#27282C"
                progressValue: 0
                Component.onCompleted: {
                    progressValue = 25
                }
                RotationAnimation {
                    target: id_waitting
                    duration: 2000
                    from: 0
                    to: 360
                    running: true
                    loops: RotationAnimation.Infinite
                }
            }

            YImage {
                width: 20
                height: 20
                anchors.centerIn: parent
                sourceSize: Qt.size(20, 20)
                imageName: "touchreading/downloading"
            }
        }
    }

    Component {
        id: id_downloading_component
        YCircularProgressBar {
            size: 46
            lineWidth: 6
            lineCap: "round"
            primaryColor: "#ACD94E"
            secondaryColor: "#27282C"
            progressValue: id_touch_reading_book_download_button.progress

            YImage {
                width: 20
                height: 20
                anchors.centerIn: parent
                sourceSize: Qt.size(20, 20)
                imageName: "touchreading/downloading"
            }
        }
    }

    Component {
        id: id_downloaded_component
        YCircularProgressBar {
            size: 46
            lineWidth: 6
            primaryColor: "#ACD94E"
            secondaryColor: "#27282C"
            progressValue: 100
            YImage {
                width: 20
                height: 20
                anchors.centerIn: parent
                sourceSize: Qt.size(20, 20)
                imageName: "touchreading/download_finished"
            }
        }
    }

}
