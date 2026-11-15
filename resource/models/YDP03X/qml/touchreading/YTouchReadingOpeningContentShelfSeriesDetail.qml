import QtQuick 2.12

import BaseQml 1.0
import "../components"
import "../i18n"

YTouchReadingPageOpeningItem {
    id: id_content_shelf_series_detail
    anchors.fill: parent
    backButtonEnabled: false

    property string onlyId: ""
    property alias coverLocal: id_icon.source
    property alias title: id_title.text
    property alias progress: id_progress_bg.progress
    property int interval: 180
    property string followStar: ""
    property int questionStar: 0

    function initData(paramsObj) {
        onlyId          = paramsObj.id
        coverLocal      = paramsObj.coverLocal.toLoadFileUrl()
        title           = paramsObj.title
        progress        = paramsObj.progress
        followStar      = paramsObj.followStar
        questionStar    = paramsObj.questionStar
    }

    YOpacityMaskImage {
        id: id_icon
        implicitWidth: 160
        implicitHeight: 194
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 90

        YBlurMaskProgressBar {
            id: id_progress_bg
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            implicitHeight: 35
            radius: 12
            sourceItem: id_icon.imageItem
            sourceRect: Qt.rect(0, id_icon.height - height, width, height)
            text: {
                switch (progress) {
                case 100:
                    return ""
                default:
                    return ("%1%").arg(progress)
                }
            }
        }

        YImage {
            anchors.centerIn: id_progress_bg
            visible: (100 === id_progress_bg.progress)
            sourceSize: Qt.size(28, 30)
            imageName: visible ? "touchreading/download_finished" : ""
        }
    }

    YTextMedium {
        id: id_title
        width: 472
        height: paintedHeight
        anchors.left: parent.left
        anchors.leftMargin: 288
        anchors.top: parent.top
        anchors.topMargin: 28
        elide: YTextMedium.ElideRight
        font.family: fontManager.fontFamilyZhCn
    }

    YFastBlurRectangle {
        anchors.left: parent.left
        anchors.leftMargin: 288
        anchors.top: parent.top
        anchors.topMargin: 88
        anchors.right: parent.right
        anchors.rightMargin: 40
        implicitHeight: 60

        Rectangle {
            color: "#644FEC"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: id_follow_tip.paintedWidth + 48
            radius: height/2
            YTextMedium {
                id: id_follow_tip
                anchors.centerIn: parent
                font.pixelSize: 24
                font.family: fontManager.fontFamilyZhCn
                text: YTranslateText.followReadingResult
            }
        }

        YTextBase {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: id_star_icon.left
            anchors.rightMargin: 10
            color: "#99FFFFFF"
            font.pixelSize: 24
            font.family: fontManager.fontFamilyZhCn
            text: YTranslateText.totalGet
        }

        YImage {
            id: id_star_icon
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: id_follow_star.left
            anchors.rightMargin: 3
            sourceSize: Qt.size(30, 29)
            imageName: "touchreading/star_on"
        }

        YTextMedium {
            id: id_follow_star
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 24
            color: "#FFAB2E"
            font.family: fontManager.fontFamilyZhCn
            font.pixelSize: 24
            text: "x" + followStar
        }
    }

    YFastBlurRectangle {
        anchors.left: parent.left
        anchors.leftMargin: 288
        anchors.top: parent.top
        anchors.topMargin: 164
        anchors.right: parent.right
        anchors.rightMargin: 40
        implicitHeight: 60
        Rectangle {
            color: "#644FEC"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: id_answer_tip.paintedWidth + 48
            radius: height/2
            YTextMedium {
                id: id_answer_tip
                anchors.centerIn: parent
                font.pixelSize: 24
                font.family: fontManager.fontFamilyZhCn
                text: YTranslateText.interactiveQuizzes
            }
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 20
            spacing: 6

            YImage {
                sourceSize: Qt.size(30, 29)
                imageName: questionStar >= 3 ?
                               "touchreading/star_on" : "touchreading/star_off"
            }

            YImage {
                sourceSize: Qt.size(30, 29)
                imageName: questionStar >= 2 ?
                               "touchreading/star_on" : "touchreading/star_off"
            }

            YImage {
                sourceSize: Qt.size(30, 29)
                imageName: questionStar >= 1 ?
                               "touchreading/star_on" : "touchreading/star_off"
            }
        }
    }
}
