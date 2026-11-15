import QtQuick 2.12

import BaseQml 1.0
import "../components"
import "../i18n"

YTouchReadingPageOpeningItem {
    id: id_content_shelf_series_detail
    anchors.fill: parent
    color: "#1F2261"
    backButtonEnabled: true
    backButtonIcon: "touchreading/medal_set_back"

    property string onlyId: ""
    property alias progress: id_progress_bg.progress
    property alias progressText: id_progress_bg.text
    property int interval: 180

    function initData(paramsObj) {
        onlyId          = paramsObj.id
        progress        = parseInt(paramsObj.lightedMedalCount*100/paramsObj.totalMedalCount)
        progressText    = ('<font color="#FFEE55">%1</font>/%2').arg(paramsObj.lightedMedalCount).arg(paramsObj.totalMedalCount)
        readingBookManager.entrySeries(onlyId, true)
    }

    YImage {
        anchors.verticalCenter: id_progress_bg.verticalCenter
        anchors.right: id_title_left.left
        anchors.rightMargin: 10
        sourceSize: Qt.size(48, 17)
        imageName: "touchreading/tip_left"
    }

    YTextMedium {
        id: id_title_left
        width: paintedWidth
        height: paintedHeight
        anchors.right: id_progress_bg.left
        anchors.rightMargin: 4
        anchors.verticalCenter: id_progress_bg.verticalCenter
        text: YTranslateText.youHaveUnlock
        font.family: fontManager.fontFamilyZhCn
    }

    YProgressBar {
        id: id_progress_bg
        implicitWidth: 200
        implicitHeight: 24
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 40
        textItem.textFormat: Text.RichText
        color: "#5C5CE2"
        progressGradient: Gradient {
            GradientStop { position: 0.0; color: "#DF84FF" }
            GradientStop { position: 1.0; color: "#B072FF" }
        }
    }

    YTextMedium {
        id: id_title_right
        width: paintedWidth
        height: paintedHeight
        anchors.left: id_progress_bg.right
        anchors.leftMargin: 4
        anchors.verticalCenter: id_progress_bg.verticalCenter
        text: YTranslateText.medalPieces
        font.family: fontManager.fontFamilyZhCn
    }

    YImage {
        anchors.verticalCenter: id_progress_bg.verticalCenter
        anchors.left: id_title_right.right
        anchors.leftMargin: 10
        sourceSize: Qt.size(48, 17)
        imageName: "touchreading/tip_right"
    }

    YHorizontalListView {
        id: id_main_touch_reading_list_view
        anchors.fill: parent
        anchors.topMargin: 96
        anchors.bottomMargin: 38
        anchors.leftMargin: 34
        anchors.rightMargin: 34
        header: Item {
            height: id_main_touch_reading_list_view.height
            implicitWidth: 42
        }
        footer: Item {
            height: id_main_touch_reading_list_view.height
            implicitWidth: 42
        }
        delegate: id_delegate_component
        model: readingBookManager

        onMovingChanged: {
            if (!moving && atXEnd && readingBookManager.hasMore) {
                readingBookManager.loadMore()
            }
        }
    }

    Component {
        id: id_delegate_component
        YTouchReadingOpeningContentMedalSetDetailItem {
            id: id_delegate_item
            function showDetailList(incubatorObject, paramsObj, posX) {
                incubatorObject.initData(paramsObj)
                incubatorObject.backButtonClicked.connect(function(){
                    id_content_shelf_series_detail.backButtonEnabled = true
                })
                id_content_shelf_series_detail.backButtonEnabled = false
                incubatorObject.show(posX)
            }

            property int incubatorCreateCount: 0

            onClicked: {
                const curItem = id_delegate_item.mapToItem(id_content_shelf_series_detail, 0, 0)
                const component = qmlCreateComponent(
                                    "touchreading/YTouchReadingOpeningContentMedalSetDetailItemDetail");
                const incubator = component.incubateObject(id_content_shelf_series_detail);
                if (incubator.status !== Component.Ready) {
                    incubator.onStatusChanged = function(status) {
                        if (status === Component.Ready) {
                            if (0 === --incubatorCreateCount) {
                                showDetailList(incubator.object, model.modelData, curItem.x)
                            } else {
                                incubator.object.destroy()
                            }
                        }
                    }
                    ++incubatorCreateCount
                } else {
                    showDetailList(incubator.object, model.modelData, curItem.x)
                }
            }
        }
    }

    onBackButtonClicked: {
        id_content_shelf_series_detail.hide()
        readingBookManager.wipeData()
        id_content_shelf_series_detail.destroy()
    }

    Component {
        id: id_bg_component
        YImage {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 9
            sourceSize: Qt.size(745, 227)
            imageName: "touchreading/medal_set_detail_bg"
        }
    }

    property int incubatorCreateCount: 0
    Component.onCompleted: {
        const incubator = id_bg_component.incubateObject(backgroundItem);
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 !== --incubatorCreateCount) {
                        incubator.object.destroy()
                    }
                }
            }
            ++incubatorCreateCount
        }
    }
}
