import QtQuick 2.12

import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YTouchReadingViewDelegateBase {
    id: id_delegate_item_root
    implicitWidth: {
        switch (index) {
        case 0:
            if (0 === readingSeriesManager.itemCount) {
                return 140
            }
            switch (readingSeriesManager.shelfCovers.length) {
            case 0:
                return 140
            case 1:
                return 158
            case 2:
                return 178
            case 3:
            default:
                return 198
            }
        case 1:
            return 150
        case 2:
            return 137
        }
    }

    delegateItem: id_delegate_item

    signal clicked(int readingIndex)

    YMouseArea {
        id: id_achievement_delegate_button
        anchors.fill: parent
        onClicked: {
            id_delegate_item_root.clicked(index)
        }
        objectName: "YTouchReadingPageIndex.qml_id_achievement_delegate"
    }

    Item {
        id: id_delegate_item
        anchors.fill: parent

        Item {
            id: id_loading
            implicitWidth: 140
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            visible: !id_covers_loader.isLoaded

            YCircularProgressBar {
                id: id_waitting
                implicitWidth: 80
                implicitHeight: 80
                anchors.centerIn: parent
                size: 80
                lineWidth: 12
                lineCap: "round"
                primaryColor: "#644FEC"
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
                    running: id_loading.visible
                    loops: RotationAnimation.Infinite
                }
            }
        }

        YLoader {
            id: id_covers_loader
            anchors.fill: parent
            active: 0 === index
            sourceComponent: Repeater {
                model: ((0 !== readingSeriesManager.itemCount) && (readingSeriesManager.shelfCovers.length > 0))
                       ? readingSeriesManager.shelfCovers
                       : [qmlGlobal.applicationDirPath + "/images/touchreading/default_icon.png"]
                Item {
                    implicitWidth: ((0 !== readingSeriesManager.itemCount) && (readingSeriesManager.shelfCovers.length > 0)) ? 154 : 136
                    implicitHeight: 168
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 4
                    anchors.rightMargin: 20 * index
                    opacity: id_achievement_delegate_button.pressed ? 0.6 : 1

                    Rectangle {
                        width: parent.width
                        height: parent.height
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: 6
                        radius: 20
                        color: {
                            if (0 === readingSeriesManager.itemCount) {
                                return YColors.transparent
                            }
                            switch (readingSeriesManager.shelfCovers.length - index) {
                            case 0:
                                return YColors.transparent
                            case 1:
                                return "#33000000"
                            case 2:
                            default:
                                return "#4D000000"
                            }
                        }
                    }

                    YOpacityMaskImage {
                        id: id_book_cover
                        anchors.fill: parent
                        source: model.modelData.toLoadFileUrl()
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: {
                            if (0 === readingSeriesManager.itemCount) {
                                return YColors.transparent
                            }
                            switch (readingSeriesManager.shelfCovers.length - 1 - index) {
                            case 0:
                                return YColors.transparent
                            case 1:
                                return "#33000000"
                            case 2:
                            default:
                                return "#4D000000"
                            }
                        }
                    }

                }
            }
        }

        YLoader {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 32
            active: 1 === index
            sourceComponent: YImage {
                sourceSize: Qt.size(136, 52)
                imageName: "touchreading/achievement_result_bg"
                Row {
                    height: 24
                    spacing: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2
                    YImage {
                        sourceSize: Qt.size(24, 24)
                        imageName: "touchreading/achievement_result_icon"
                    }
                    YTextMedium {
                        width: paintedWidth
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 22
                        color: "#FFE531"
                        text: (0 === readingSeriesManager.itemCount) ? "0" : readingSeriesManager.totalMedalBookCount
                    }
                }
            }
        }

        YLoader {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 32
            active: 2 === index
            sourceComponent: YImage {
                sourceSize: Qt.size(136, 52)
                imageName: "touchreading/achievement_result_bg"
                YImage {
                    sourceSize: Qt.size(89, 16)
                    imageName: "touchreading/achievement_result_empty"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 6
                }
            }
        }

        YImage {
            id: id_delegate_item_icon
            anchors.top: parent.top
            sourceSize: {
                switch (index) {
                case 0:
                    return Qt.size(84, 172)
                case 1:
                    return Qt.size(150, 157)
                case 2:
                    return Qt.size(137, 156)
                }
            }
            imageName: {
                switch (index) {
                case 0:
                    return "touchreading/folder"
                case 1:
                    return "touchreading/medal_set"
                default:
                    return "touchreading/results_wall"
                }
            }
            opacity: id_achievement_delegate_button.pressed && (index > 0) ? 0.6 : 1
        }

        YTextMedium {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            font.pixelSize: 22
            horizontalAlignment: YTextMedium.AlignHCenter
            font.family: fontManager.fontFamilyZhCn
            opacity: id_achievement_delegate_button.pressed ? 0.6 : 1
            text: {
                switch (index) {
                case 0:
                    return "我的书架"
                case 1:
                    return "勋章集"
                default:
                    return "成果墙"
                }
            }
        }
    }
}
