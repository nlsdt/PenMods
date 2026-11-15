import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    id: id_opening_content_store_series

    anchors.fill: parent

    property string onlyId: ""
    property alias coverLocal: id_icon.source
    property alias title: id_title.text
    property alias classify: id_classify.text
    property alias age: id_age.text
    property alias introduce: id_introduce.text
    property alias qrcodeLocal: id_buy_book_component.source
    property int progress: 0
    property int interval: 180
    property int downloadState: YEnum.DS_NOT

    readonly property bool isExtending: "extend" === state

    readonly property bool isBuying: "buying" === state

    readonly property bool layerShowing: isExtending || isBuying

    function shrink() {
        state = "shrink"
    }

    function extend() {
        state = "extend"
    }

    function buying() {
        state = "buying"
    }

    function initData(paramsObj) {
        onlyId      = paramsObj.id
        coverLocal  = paramsObj.coverLocal.toLoadFileUrl()
        title       = paramsObj.title
        classify    = paramsObj.classify
        age         = paramsObj.age
        introduce   = paramsObj.introduce
        qrcodeLocal = paramsObj.qrcodeLocal.toLoadFileUrl()
    }

    YOpacityMaskImage {
        id: id_icon
        width: 168
        height: 168
        anchors.left: parent.left
        anchors.leftMargin: 66
        anchors.top: parent.top
        anchors.topMargin: 32
        visible: (id_introduce_container.opacity > 0.5)
    }

    YTextMedium {
        id: id_title
        width: 472
        height: 28
        anchors.left: id_introduce_container.left
        anchors.bottom: id_introduce_container.top
        anchors.bottomMargin: 52
        elide: YTextMedium.ElideRight
        font.family: fontManager.fontFamilyZhCn
    }

    Item {
        height: 24
        width: id_classify.width + 22 + id_age.width
        anchors.left: id_introduce_container.left
        anchors.bottom: id_introduce_container.top
        anchors.bottomMargin: 14
        opacity: id_title.opacity

        YTextBase {
            id: id_classify
            color: "#3FDCFF"
            font.pixelSize: 24
            width: paintedWidth
            height: 24
            font.family: fontManager.fontFamilyZhCn
        }

        Rectangle {
            implicitWidth: 2
            implicitHeight: 16
            anchors.left: id_classify.right
            anchors.leftMargin: 10
            radius: width/2
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: (id_classify.paintedHeight - 24) / 2 + 1
            color: "#333FDCFF"
        }

        YTextBase {
            id: id_age
            color: "#3FDCFF"
            font.pixelSize: 24
            width: paintedWidth
            height: 24
            anchors.right: parent.right
            font.family: fontManager.fontFamilyZhCn
        }
    }

    Flickable {
        id: id_introduce_container
        anchors.left: parent.left
        anchors.leftMargin: 288
        anchors.top: parent.top
        anchors.topMargin: 108
        height: 26
        width: 452
        boundsBehavior: isExtending ? Flickable.DragAndOvershootBounds
                                    : Flickable.StopAtBounds
        contentHeight: id_introduce.paintedHeight
        clip: isExtending
        enabled: id_introduce_container.opacity > 0.9

        YTextBase {
            id: id_introduce
            color: isExtending ? "#FFFFFF" : "#66FFFFFF"
            font.pixelSize: 26
            width: parent.width
            elide: isExtending ? YTextMedium.ElideNone : YTextMedium.ElideRight
            wrapMode: isExtending ? YTextMedium.Wrap : YTextMedium.NoWrap
            font.family: fontManager.fontFamilyZhCn

            YMouseArea {
                anchors.fill: parent
                visible: id_title.opacity < 0.1
                onClicked: {
                    shrink()
                }
                objectName: "YTouchReadingOpeningContentStoreSeries.qml_id_introduce"
            }
        }
    }


    YImage {
        id: id_introduce_more_icon
        anchors.left: id_introduce_container.right
        anchors.leftMargin: -10
        anchors.verticalCenter: id_introduce_container.verticalCenter
        anchors.verticalCenterOffset: (id_introduce.paintedHeight - 26) / 2 + 1
        sourceSize: Qt.size(24, 24)
        imageName: visible ? "touchreading/introduce_more" : ""
        visible: !isExtending && (id_introduce_container.opacity > 0.5)
    }

    YMouseArea {
        id: id_introduce_extend_button
        anchors.top: id_title.top
        anchors.bottom: id_introduce_container.bottom
        anchors.left: id_introduce_container.left
        anchors.right: id_title.right
        visible: id_title.opacity > 0.9
        onClicked: {
            logManager.sendHttpLog("action=touchreading_bookdetail_click")
            extend()
        }
        objectName: "YTouchReadingOpeningContentStoreSeries.qml_id_introduce_extend_button"
    }

    Row {
        anchors.left: id_introduce_container.left
        anchors.top: id_introduce_container.bottom
        anchors.topMargin: 24
        height: 72
        spacing: 20
        opacity: id_title.opacity

        YDownloadProgressButton {
            id: id_download_progress_button
            buttonColor: "#252144"
            progressColor: "#FF8B20"
            clickable: YEnum.DS_SUCCEED !== downloadState
            textFamily: fontManager.fontFamilyZhCn
            progress: {
                switch (downloadState) {
                case YEnum.DS_SUCCEED:
                    return 100
                case YEnum.DS_ING:
                    return id_opening_content_store_series.progress
                default:
                    return 0
                }
            }
            text: {
                switch (downloadState) {
                case YEnum.DS_SUCCEED:
                    return YTranslateText.bookAddToShelf
                case YEnum.DS_FAILURE:
                    return YTranslateText.downloadFaild
                case YEnum.DS_ING:
                    return (0 === progress) ? YTranslateText.downloadWaiting
                                            : YTranslateText.downloadProgress.arg(progress)
                default:
                    return YTranslateText.downloadTouchReadingBook
                }
            }
            onDownload: {
                if (!wifiManager.internetConnect) {
                    baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                    return
                }
                console.log("YTouchReadingOpeningContentStoreSeries.qml==="
                            +"call===readingSeriesManager.downloadSeries(onlyId): ",
                            onlyId)
                switch (downloadState) {
                case YEnum.DS_FAILURE:
                case YEnum.DS_ING:
                    readingSeriesManager.cancelDownloadSeries(onlyId)
                    break
                default:
                    logManager.sendHttpLog("action=touchreading_add_bookshelf_click&name=%1".arg(id_title.text))
                    readingSeriesManager.downloadSeries(onlyId)
                    break
                }
            }
        }

        YButton {
            id: id_buy_book_button
            implicitWidth: 226
            implicitHeight: 72
            color: "#644FEC"
            pixelSize: 26
            textFamily: fontManager.fontFamilyZhCn
            text: YTranslateText.buyBook
            onClicked: {
                logManager.sendHttpLog("action=touchreading_store_purchase_click")
                buying()
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
                target: id_introduce_container
                width: 452
                height: 26
                anchors.topMargin: 108
                opacity: 1
            }
            PropertyChanges {
                target: id_title
                opacity: 1
            }
        },State {
            name: "extend"
            PropertyChanges {
                target: id_introduce_container
                width: 470
                height: 190
                anchors.topMargin: 32
                opacity: 1
            }
            PropertyChanges {
                target: id_title
                opacity: 0
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
                target: id_introduce_container
                opacity: 0
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
                properties: "x,y,width,height,anchors.topMargin"
                duration: interval
            }
            NumberAnimation {
                properties: "opacity"
                duration: interval
            }
        }
    }
}
