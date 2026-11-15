import QtQuick 2.12

import BaseQml 1.0

Row {
    anchors.left: parent.left
    anchors.leftMargin: {
        switch (currentMenuType) {
        case YTouchReadingResultCoverMenuBar.RedRocket:
            return 32
        case YTouchReadingResultCoverMenuBar.XiaoXiang:
            return 60
        case YTouchReadingResultCoverMenuBar.MT_COUNT:
        default:
            return 66
        }
    }
    anchors.bottom: parent.bottom
    anchors.bottomMargin: {
        switch (currentMenuType) {
        case YTouchReadingResultCoverMenuBar.RedRocket:
            return 33
        case YTouchReadingResultCoverMenuBar.XiaoXiang:
            return 16
        case YTouchReadingResultCoverMenuBar.MT_COUNT:
        default:
            return 24
        }
    }
    spacing: {
        switch (currentMenuType) {
        case YTouchReadingResultCoverMenuBar.RedRocket:
            return 16
        case YTouchReadingResultCoverMenuBar.XiaoXiang:
            return 16
        case YTouchReadingResultCoverMenuBar.MT_COUNT:
        default:
            return 22
        }
    }

    visible: false

    property alias modelArray: id_repeater.model
    readonly property alias count: id_repeater.count

    signal menuClicked(int index, string buttonText, string buttonKey)

    property int currentMenuType: YTouchReadingResultCoverMenuBar.MT_COUNT

    enum MenuType {
        RedRocket,
        XiaoXiang,
        MT_COUNT
    }

    Repeater {
        id: id_repeater

        YTouchReadingResultCoverButton {
            width: {
                switch (currentMenuType) {
                case YTouchReadingResultCoverMenuBar.RedRocket:
                    return 180
                case YTouchReadingResultCoverMenuBar.XiaoXiang:
                    return 332
                case YTouchReadingResultCoverMenuBar.MT_COUNT:
                default:
                    return 208
                }
            }

            color: {
                switch (currentMenuType) {
                case YTouchReadingResultCoverMenuBar.XiaoXiang:
                    switch (index) {
                    case 0:
                        return "#644FEC"
                    default:
                        return "#FF7E08"
                    }
                default:
                    return "#CC32325E"
                }
            }

            imageVisible: {
                switch (currentMenuType) {
                case YTouchReadingResultCoverMenuBar.XiaoXiang:
                    return false
                default:
                    return true
                }
            }

            imageName : {
                switch (currentMenuType) {
                case YTouchReadingResultCoverMenuBar.RedRocket:
                    switch (index) {
                    case 0:
                        return "touchreading/learn"
                    case 1:
                        return "touchreading/scan"
                    default:
                        return "touchreading/quiz"
                    }
                case YTouchReadingResultCoverMenuBar.XiaoXiang:
                    return ""
                case YTouchReadingResultCoverMenuBar.MT_COUNT:
                default:
                    switch (index) {
                    case 0:
                        return "touchreading/scan"
                    case 1:
                        return "touchreading/mic"
                    default:
                        return "touchreading/quiz"
                    }
                }
            }

            spacing: {
                switch (currentMenuType) {
                case YTouchReadingResultCoverMenuBar.RedRocket:
                    return 4
                default:
                    return 0
                }
            }

            onClicked: {
                menuClicked(index, model.modelData.text, model.modelData.key)
            }

            text: model.modelData.text
        }
    }

    YTimer {
        id: id_delay_show
        interval: 300
        onTriggered: {
            parent.visible = true
        }
    }

    onWidthChanged: {
        id_delay_show.restart()
    }
}
