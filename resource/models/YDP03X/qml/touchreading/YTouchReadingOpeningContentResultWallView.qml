import QtQuick 2.12

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    id: id_opening_content_shelf_series_view

    anchors.fill: parent

    property string onlyId: ""
    property int interval: 180

    readonly property bool layerShowing: false

    signal callBack()

    function shrink() {
        // only a empty interface
    }

    function initData(paramsObj) {
//        onlyId      = paramsObj.id
    }

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 160
        anchors.rightMargin: 87
        anchors.topMargin: 40
        anchors.bottomMargin: 28
        flickableDirection: Flickable.HorizontalFlick
        contentWidth: id_row.width

        Row {
            id: id_row
            height: 138
            spacing: 70
            YFastBlurRectangle {
                implicitWidth: 138
                implicitHeight: 138
                blurRadius: 128

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -6
                    radius: height/2
                    color: "transparent"
                    border.width: 14
                    border.color: "#FFEE55"
                }

                YTextMedium {
                    anchors.centerIn: parent
                    font.pixelSize: 24
                    text: readingSeriesManager.totalFollowStars
                }

                YTextMedium {
                    anchors.top: parent.bottom
                    anchors.topMargin: 16
                    font.pixelSize: 26
                    font.family: fontManager.fontFamilyZhCn
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: YTranslateText.starCount
                }
            }

            YFastBlurRectangle {
                implicitWidth: 138
                implicitHeight: 138
                blurRadius: 128

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -6
                    radius: height/2
                    color: "transparent"
                    border.width: 14
                    border.color: "#E477FF"
                }

                YTextMedium {
                    anchors.centerIn: parent
                    font.pixelSize: 24
                    text: readingSeriesManager.totalStudyDays
                }

                YTextMedium {
                    anchors.top: parent.bottom
                    anchors.topMargin: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 26
                    font.family: fontManager.fontFamilyZhCn
                    text: YTranslateText.studyDays
                }
            }

            YFastBlurRectangle {
                implicitWidth: 138
                implicitHeight: 138
                blurRadius: 128

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -6
                    radius: height/2
                    color: "transparent"
                    border.width: 14
                    border.color: "#3FDCFF"
                }

                YTextMedium {
                    anchors.centerIn: parent
                    font.pixelSize: 24
                    text: readingSeriesManager.totalMedalBookCount
                }

                YTextMedium {
                    anchors.top: parent.bottom
                    anchors.topMargin: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 26
                    font.family: fontManager.fontFamilyZhCn
                    text: YTranslateText.readBooksTotal
                }
            }
        }
    }

    Rectangle {
        implicitWidth: 42
        implicitHeight: 42
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.leftMargin: 750
        radius: height/2
        color: "#222248"
        opacity: id_tip_button.pressed || !enabled ? 0.6 : 1

        YImage {
            anchors.centerIn: parent
            sourceSize: Qt.size(28, 27)
            imageName: "touchreading/result_wall_tip"
        }

        YMouseArea {
            id: id_tip_button
            anchors.fill: parent
            anchors.margins: -20
            objectName: "YTouchReadingOpeningContentResultWallView.qml_tip_button"

            function showTips(incubatorObject) {
                incubatorObject.show(750)
            }

            property int incubatorCreateCount: 0

            onClicked: {
                const component = qmlCreateComponent(
                                    "touchreading/YTouchReadingOpeningContentResultWallViewTips");
                const incubator = component.incubateObject(id_opening_content_shelf_series_view);
                if (incubator.status !== Component.Ready) {
                    incubator.onStatusChanged = function(status) {
                        if (status === Component.Ready) {
                            if (0 === --incubatorCreateCount) {
                                showTips(incubator.object)
                            } else {
                                incubator.object.destroy()
                            }
                        }
                    }
                    ++incubatorCreateCount
                } else {
                    showTips(incubator.object)
                }
            }
        }
    }

    YImage {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        sourceSize: Qt.size(94, 254)
        imageName: "touchreading/result_wall_back_bg"
        opacity: id_medal_set_back_button.pressed || !enabled ? 0.6 : 1

        YTextMedium {
            width: 28
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 104
            font.pixelSize: 26
            font.family: fontManager.fontFamilyZhCn
            textFormat: YTextMedium.RichText
            text: YTranslateText.resultWallVertical
        }

        YBackButtonBase {
            id: id_medal_set_back_button
            anchors.fill: parent
            onTriggered: {
                callBack()
            }
            objectName: "OpeningContentMedalSetView.qml_id_medal_set_back_button"
        }
    }
}
