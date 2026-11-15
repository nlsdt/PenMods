import QtQuick 2.12

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    id: id_opening_content_shelf_series_edit

    anchors.fill: parent

    property string onlyId: ""
    property alias coverLocal: id_icon.source
    property alias title: id_title.text
    property alias qrcodeLocal: id_buy_book_component.source
    property int interval: 180

    readonly property bool isBuying: "buying" === state
    readonly property bool layerShowing: isBuying

    signal callBack()

    function shrink() {
        state = "shrink" // todo
    }

    function buying() {
        state = "buying"
    }

    function initData(paramsObj) {
        id_del_button.text = YTranslateText.deleteTouchReadingBooksPackage
        onlyId      = paramsObj.id
        coverLocal  = paramsObj.coverLocal.toLoadFileUrl()
        title       = paramsObj.title
        qrcodeLocal = paramsObj.qrcodeLocal.toLoadFileUrl()
        id_del_button.clickable = true
    }

    YOpacityMaskImage {
        id: id_icon
        width: 168
        height: 168
        anchors.left: parent.left
        anchors.leftMargin: 66
        anchors.top: parent.top
        anchors.topMargin: 32
        visible: (id_title.opacity > 0.5)
    }

    YTextMedium {
        id: id_title
        width: 472
        height: paintedHeight
        maximumLineCount: 2
        anchors.left: parent.left
        anchors.leftMargin: 288
        anchors.top: parent.top
        anchors.topMargin: 40
        wrapMode: YTextMedium.Wrap
        font.family: fontManager.fontFamilyZhCn
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 288
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        height: 72
        spacing: 20
        opacity: id_title.opacity

        YButton {
            id: id_del_button
            implicitWidth: 226
            implicitHeight: 72
            color: "#252144"
            clickable: false
            textFamily: fontManager.fontFamilyZhCn
            onClicked: {
                readingSeriesManager.remove(onlyId)
                logManager.sendHttpLog("action=touchreading_shelf_remove_click&name=%1".arg(id_title.text))
                id_del_animation.restart()
            }

            SequentialAnimation {
                id: id_del_animation
                running: false
                loops: SequentialAnimation.Infinite
                ScriptAction { script: {
                        id_del_button.clickable = false
                        id_del_button.text = YTranslateText.deleting + ".  "
                    }
                }
                PauseAnimation { duration: 480 }
                ScriptAction { script: {
                        id_del_button.text = YTranslateText.deleting + ".. "
                    }
                }
                PauseAnimation { duration: 480 }
                ScriptAction { script: {
                        id_del_button.text = YTranslateText.deleting + "..."
                    }
                }
                PauseAnimation { duration: 480 }
            }
        }

        YButton {
            id: id_buy_book_button
            implicitWidth: 226
            implicitHeight: 72
            color: "#644FEC"
            pixelSize: 26
            text: YTranslateText.buyBook
            textFamily: fontManager.fontFamilyZhCn
            onClicked: {
                logManager.sendHttpLog("action=touchreading_shelf_purchase_click&name=%1".arg(id_title.text))
                buying()
            }
        }
    }

    Connections {
        target: readingSeriesManager
        ignoreUnknownSignals: true
        function onRemoveSeriesFinished(seriesId) {
            if (seriesId === onlyId) {
                id_del_animation.stop()
                callBack()
            }
        }
    }

    YTouchReadingPageBuyBookComponent {
        id: id_buy_book_component
        opacity: 0
        x: 534
        y: 158
        width: 226
        height: 72
        enabled: opacity > 0.9
        title: id_title.text
    }

    state: "shrink"

    states: [
        State {
            name: "shrink"
            PropertyChanges {
                target: id_buy_book_component
                x: 534
                y: 158
                width: 226
                height: 72
                opacity: 0
            }
            PropertyChanges {
                target: id_title
                opacity: 1
            }
        },State {
            name: "buying"
            PropertyChanges {
                target: id_buy_book_component
                x: 0
                y: 0
                width: 800
                height: 254
                opacity: 1
            }
            PropertyChanges {
                target: id_title
                opacity: 0
            }
        }
    ]

    transitions: Transition {
        from: "shrink"
        to: "*"
        reversible: true
        SequentialAnimation {
            NumberAnimation {
                properties: "x,y,width,height"
                duration: interval
            }
            NumberAnimation {
                properties: "opacity"
                duration: interval
            }
        }
    }
}
