import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

Rectangle {
    id: id_opening_item
    color: "black"
    y: highlightStartY
    width: highlightStartWidth
    height: highlightStartHeight
    opacity: 0

    readonly property alias backgroundItem: id_bg
    property bool isBusyCreating: false


    Rectangle {
        id: id_bg
        implicitWidth: 800
        implicitHeight: 254
        anchors.centerIn: parent
        color: YColors.touchReadingBg
    }

    signal backButtonClicked()
    signal creatIncubateOpeningItemObjectFinished(var incubatorObject, var paramsObj)

    property int incubatorCreateCount: 0
    function creatIncubateOpeningItemObject(component, paramObj) {
        isBusyCreating = true
        let incubator = component.incubateObject(id_opening_item)
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 === --incubatorCreateCount) {
                        creatIncubateOpeningItemObjectFinished(incubator.object, paramObj)
                    } else {
                        incubator.object.destroy()
                    }
                }
            }
            ++incubatorCreateCount
        } else {
            creatIncubateOpeningItemObjectFinished(incubator.object, paramObj)
        }
    }

    YMouseArea {
        id: id_private
        anchors.fill: parent
        objectName: "YTouchReadingPageIndex.qml_id_opening_item_ignore_event"
        enabled: id_opening_item.opacity > 0.9
    }

    property int highlightStartX: 0 // need set
    property int highlightStartY: 0
    property int highlightStartWidth: 0
    property int highlightStartHeight: 0

    property int currentTabIndex: YEnum.RI_COUNT
    property bool backButtonEnabled: true

    readonly property int interval: 240
    readonly property bool isShowing: "show" === state

    function show(posX) {
        highlightStartX = posX
        state = "show"
    }
    function hide() {
        state = "hide"
    }

    property var backButtonObject: null
    property var backButtonHideValue: null
    property var backButtonShowValue: null

    state: "hide"
    states: [
        State {
            name: "hide"
            PropertyChanges {
                target: id_opening_item
                x: highlightStartX
                y: highlightStartY
                width: highlightStartWidth
                height: highlightStartHeight
                opacity: 0
            }
            PropertyChanges {
                target: backButtonObject
                showMargin: backButtonHideValue()
            }
        },State {
            name: "show"
            PropertyChanges {
                target: id_opening_item
                x: 0; y: 0; width: 800; height: 254; opacity: 1
            }
            PropertyChanges {
                target: backButtonObject
                showMargin: backButtonShowValue()
            }
        }
    ]

    transitions: Transition {
        SequentialAnimation {
            NumberAnimation {
                properties: "x,y,width,height,opacity"
                duration: id_opening_item.interval
            }
            NumberAnimation {
                properties: "showMargin"
                duration: id_opening_item.interval
            }
        }
    }

    function setIdle() {
        id_delay_idle_timer.restart()
    }

    YTimer {
        id: id_delay_idle_timer
        interval: 600
        onTriggered: {
            isBusyCreating = false
        }
        objectName: "YTouchReadingPageOpeningItemBase.qml_id_delay_idle_timer"
    }
}
