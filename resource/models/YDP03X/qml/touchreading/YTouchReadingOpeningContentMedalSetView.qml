import QtQuick 2.12
import com.youdao.pen 1.0

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
        // only a interface, no need code
    }

    function initData(paramsObj) {
        readingSeriesManager.loadMore(true)
    }

    YHorizontalListView {
        id: id_main_touch_reading_list_view
        anchors.fill: parent
        anchors.topMargin: 32
        anchors.bottomMargin: 24
        anchors.leftMargin: 132
        spacing: 30
        clip: false
        delegate: id_delegate_component
        model: readingSeriesManager

        onMovingChanged: {
            if (!moving && atXEnd && readingSeriesManager.hasMore) {
                readingSeriesManager.loadMore(true)
            }
        }

        YTextMedium {
            id: id_empty_tips
            visible: !id_main_touch_reading_list_view.busying
                     && id_main_touch_reading_list_view.empty
            anchors.centerIn: parent
            text: YTranslateText.noTouchReadingBooks
            font.family: fontManager.fontFamilyZhCn
            textFormat: YTextMedium.RichText
            horizontalAlignment: YTextMedium.AlignHCenter
        }
    }

    YImage {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        sourceSize: Qt.size(94, 254)
        imageName: "touchreading/medal_set_back_bg"
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
            text: YTranslateText.metalSetVertical
        }

        YBackButtonBase {
            id: id_medal_set_back_button
            anchors.fill: parent
            onTriggered: {
                callBack()
                readingSeriesManager.wipeData()
            }
            objectName: "OpeningContentMedalSetView.qml_id_medal_set_back_button"
        }
    }

    Component {
        id: id_delegate_component
        YTouchReadingOpeningContentMedalSetViewItem {
            id: delegateItem
            function showDetailList(incubatorObject, paramsObj, posX) {
                incubatorObject.initData(paramsObj)
                incubatorObject.show(posX)
            }

            property int incubatorCreateCount: 0

            onClicked: {
                logManager.sendHttpLog("action=touchreading_achieve_medalset_medals_click")
                const curItem = delegateItem.mapToItem(id_opening_content_shelf_series_view, 0, 0)
                const component = qmlCreateComponent(
                                    "touchreading/YTouchReadingOpeningContentMedalSetDetailList");
                const incubator = component.incubateObject(id_opening_content_shelf_series_view);
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

}
