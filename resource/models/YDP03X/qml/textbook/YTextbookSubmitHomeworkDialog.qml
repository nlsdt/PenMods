import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YDialog {
    id: id_textbook_submit_homework_dialog
    property string submitTipString: ""
    property bool submitDone: false
    property bool submitDoing: false

    signal redoHomework()
    signal submitHomework()
    signal submitFinished()

    Item {
        anchors.fill: parent
        visible: !submitDoing

        Item {
            id: id_tip_item
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.right: parent.right
            anchors.rightMargin: 100
            anchors.top: parent.top
            anchors.topMargin: 30
            height: 110

            YLoader {
                active: true
                asynchronous: false
                anchors.fill: parent
                anchors.centerIn: parent
                sourceComponent: submitDone ? id_submit_suf_tip_component : id_tip_component
            }

            Component {
                id: id_tip_component

                YText {
                    id: id_tip_text
                    font.pixelSize: 28
                    anchors.centerIn: parent
                    horizontalAlignment: YText.AlignHCenter
                    verticalAlignment: YText.AlignVCenter
                    wrapMode: YText.Wrap
                    textFormat: Text.RichText
                    font.family: fontManager.fontFamilyZhCn
                    text: submitTipString
                }
            }

            Component {
                id: id_submit_suf_tip_component

                Item {
                    id: id_submit_suf_tip
                    anchors.fill: parent

                    Row {
                        spacing: 16
                        height: 40
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        YImage {
                            imageName: "textbook/submitsuf"
                            sourceSize: Qt.size(40, 40)
                        }

                        YText {
                            width: contentWidth
                            height: 40
                            font.pixelSize: 28
                            verticalAlignment: YText.AlignVCenter
                            font.family: fontManager.fontFamilyZhCn
                            text: YTranslateText.textbookSubmitSuccessful
                        }
                    }
                }
            }
        }

        Item {
            id: id_button_item
            height: 80
            width: id_button_row.width
            anchors.top: id_tip_item.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            Row {
                id: id_button_row
                height: id_button_item.height
                spacing: 16

                YButton {
                    id: id_redo_button
                    implicitWidth: 320
                    color: YColors.grayNormal
                    textFamily: fontManager.fontFamilyZhCn
                    text: YTranslateText.textbookRelearn
                    visible: !submitDone
                    enabled: !submitDoing
                    onClicked: {
                        id_textbook_submit_homework_dialog.redoHomework()
                    }
                }

                YButton {
                    id: id_submit_button
                    implicitWidth: 320
                    color: YColors.red
                    textFamily: fontManager.fontFamilyZhCn
                    text: YTranslateText.textbookSubmitJob
                    visible: !submitDone
                    enabled: !submitDoing
                    onClicked: {
                        if (!wifiManager.internetConnect) {
                            baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                            return
                        }
                        if (!loginManager.isLogin) {
                            baseSignals.showToast(YTranslateText.accountHasUnbundling, YColors.grayNormal)
                            return
                        }
                        id_textbook_submit_homework_dialog.submitHomework()
                        submitDoing = true
                    }
                }

                YButton {
                    id: id_done_button
                    implicitWidth: 320
                    color: YColors.red
                    textFamily: fontManager.fontFamilyZhCn
                    text: YTranslateText.textbookCompletePractice
                    visible: submitDone
                    onClicked: {
                        close()
                        id_textbook_submit_homework_dialog.submitFinished()
                    }
                }
            }
        }

        YIconButton {
            id: id_close_button
            implicitWidth: 44
            implicitHeight: 44
            radius: height/2
            color: YColors.grayNormal
            mouseAreaMargins: -22
            imageName: "commons/close"
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.left: parent.left
            anchors.leftMargin: 16
            enabled: !submitDoing
            onClicked: {
                close()
                if (submitDone) {
                    id_textbook_submit_homework_dialog.submitFinished()
                } else {
                    closed()
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: submitDoing

        Row {
            spacing: 10
            height: 40
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            YCircularProgressBar {
                id: id_progress_bar
                anchors.verticalCenter: parent.verticalCenter
                lineCap: "round"
                lineWidth: 6
                size: 40

                NumberAnimation on rotation {
                    from: 0
                    to: 360
                    duration: 1920
                    running: submitDoing
                    loops: NumberAnimation.Infinite
                    alwaysRunToEnd: true
                }
            }

            YText {
                width: contentWidth
                height: 40
                font.pixelSize: 28
                verticalAlignment: YText.AlignVCenter
                font.family: fontManager.fontFamilyZhCn
                text: YTranslateText.textbookSubmiting
            }
        }
    }

    Component.onCompleted: {
        id_progress_bar.progressValue = 25
        console.log("YTextbookSubmitHomeworkDialog.qml===Component.onCompleted===called")
    }

    Component.onDestruction: {
        console.log("YTextbookSubmitHomeworkDialog.qml===Component.onDestruction===called")
    }
}

