import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YTouchReadingPageOpeningItemBase {
    id: id_opening_item

    property int highlightStartX: 0 // need set
    property int currentTabIndex: YEnum.RI_COUNT
    property bool backButtonEnabled: (YEnum.ShelfSeries !== currentTabIndex) || (YEnum.MyShelf === currentTabIndex)
    property alias backButtonIcon: id_back_button_icon.imageName

    highlightStartWidth: {
        switch (currentTabIndex) {
        case YEnum.ShelfSeries:
            return 268
        case YEnum.StoreSeries:
            return 196
        default:
            return 170
        }
    }
    highlightStartY: {
        switch (currentTabIndex) {
        case YEnum.StoreSeries:
        case YEnum.ShelfSeries:
            return 14
        default:
            return 18
        }
    }
    highlightStartHeight: {
        switch (currentTabIndex) {
        case YEnum.StoreSeries:
        case YEnum.ShelfSeries:
            return 226
        default:
            return 218
        }
    }

    backButtonObject: id_back_button
    backButtonHideValue: id_back_button.backButtonHideValue
    backButtonShowValue: id_back_button.backButtonShowValue

    YFastBlurRectangle {
        id: id_back_button
        anchors.top: parent.top
        anchors.topMargin: showMargin
        anchors.left: parent.left
        anchors.leftMargin: showMargin
        implicitWidth: 115
        implicitHeight: 115
        z: parent.z + 1

        opacity: id_back_button_ma.pressed ? 0.6 : 1
        enabled: id_opening_item.opacity > 0.9
        visible: backButtonEnabled
        property int showMargin: -115

        function backButtonHideValue() {
            return -115
        }

        function backButtonShowValue() {
            return backButtonEnabled ? -52 : -115
        }

        YImage {
            id: id_back_button_icon
            anchors.top: parent.top
            anchors.topMargin: 60
            anchors.left: parent.left
            anchors.leftMargin: 60
            sourceSize: Qt.size(38, 38)
            imageName: "touchreading/back"
        }

        YBackButtonBase {
            id: id_back_button_ma
            anchors.fill: parent
            anchors.bottomMargin: -30
            anchors.rightMargin: -10
            objectName: "YTouchReadingPageIndex.qml_id_back_button"
            enabled: (id_opening_item.opacity > 0.9)
            onTriggered: {
                backButtonClicked()
            }
        }
    }

}
