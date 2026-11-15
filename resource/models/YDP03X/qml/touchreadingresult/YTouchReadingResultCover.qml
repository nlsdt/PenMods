import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"

YTouchFollowReadingAudioPlayBase {
    id: id_touch_reading_result_index
    anchors.fill: parent
    visible: false
    enabled: !id_delay_enabled_timer.running

    readonly property int coverImageLogoType: readingBookCoverManager.coverImgLogoType
    readonly property alias currentMenuType: id_touch_reading_result_cover_menu_bar.currentMenuType

    function play() {
        if (isBookMetalGet && (YTouchReadingResultCoverMenuBar.XiaoXiang === currentMenuType)) {
            showBookMetal(true)
        } else {
            readingBookCoverManager.playAudio()
        }
    }

    YImage {
        id: id_bg_image
        cache: false
        width: {
            switch (coverImageLogoType) {
            case YEnum.CILT_Center:
                return 108
            case YEnum.CILT_Right:
                return 132
            case YEnum.CILT_Crop:
            default:
                return parent.width
            }
        }
        height: {
            switch (coverImageLogoType) {
            case YEnum.CILT_Center:
                return 108
            case YEnum.CILT_Right:
                return 178
            case YEnum.CILT_Crop:
            default:
                return parent.height
            }
        }
        fillMode: {
            switch (coverImageLogoType) {
            case YEnum.CILT_Center:
            case YEnum.CILT_Right:
                return YImage.Stretch
            case YEnum.CILT_Crop:
            default:
                return YImage.PreserveAspectCrop
            }
        }
        anchors.left: {
            switch (coverImageLogoType) {
            case YEnum.CILT_Center:
            case YEnum.CILT_Right:
                return parent.left
            case YEnum.CILT_Crop:
            default:
                return undefined
            }
        }
        anchors.leftMargin: {
            switch (coverImageLogoType) {
            case YEnum.CILT_Center:
                return 346
            case YEnum.CILT_Right:
                return 636
            case YEnum.CILT_Crop:
            default:
                return undefined
            }
        }
        anchors.top: {
            switch (coverImageLogoType) {
            case YEnum.CILT_Center:
            case YEnum.CILT_Right:
                return parent.top
            case YEnum.CILT_Crop:
            default:
                return undefined
            }
        }
        anchors.topMargin: {
            switch (coverImageLogoType) {
            case YEnum.CILT_Center:
                return 20
            case YEnum.CILT_Right:
                return 38
            case YEnum.CILT_Crop:
            default:
                return undefined
            }
        }
        horizontalAlignment: YImage.AlignHCenter
        verticalAlignment: YImage.AlignVCenter
        source: readingBookCoverManager.isNewBook
                ? readingBookCoverManager.coverImgLogoPath.toLoadFileUrl()
                : readingBookCoverManager.coverImgPath.toLoadFileUrl()
        onLoaded: {
            id_delay_enabled_timer.restart()
        }
        property QtObject item: null
    }

    YLoader {
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.top: parent.top
        anchors.topMargin: 27
        anchors.right: parent.right
        anchors.rightMargin: 195
        active: YEnum.CILT_Right === coverImageLogoType
        sourceComponent: YTextEnUs {
            font.pixelSize: 36
            font.weight: Font.Bold
            font.family: fontManager.fontFamilyPinyin
            wrapMode: YTextEnUs.Wrap
            color: YColors.white
            text: readingBookCoverManager.coverText
        }
    }

    YTouchReadingResultCoverMenuBar {
        id: id_touch_reading_result_cover_menu_bar
        readonly property string coverPractice: readingBookCoverManager.coverPractice

        Component.onCompleted: {
            console.warn("YTouchReadingResultCover.qml===coverPractice: ", coverPractice)
            modelArray = Qt.binding(function(){
                if (readingBookCoverManager.isNewBook) {
                    if (YEnum.PageIndex.Reading === qmlGlobal.currentPageIndex) {
                        const coverPracticeData = JSON.parse(coverPractice)
                        if (coverPracticeData.cover_practice.length > 0) {
                            let practiceNames = new Array
                            let tmpString = ""
                            coverPracticeData.cover_practice.forEach(function(practiceItem) {
                                tmpString += practiceItem.practice_name
                                practiceNames.push({"text": practiceItem.practice_name,
                                                       "key": practiceItem.practice_key})
                            })

                            switch (tmpString) {
                            case "学单词读绘本做练习":
                                currentMenuType = YTouchReadingResultCoverMenuBar.RedRocket
                                break
                            case "学汉字玩游戏":
                                currentMenuType = YTouchReadingResultCoverMenuBar.XiaoXiang
                                break
                            }

                            return practiceNames
                        }
                    }
                }
                currentMenuType = YTouchReadingResultCoverMenuBar.MT_COUNT

                return [{"text": "点读模式", "key": ""},
                        {"text": "跟读模式", "key": ""},
                        {"text": "互动答题", "key": ""}]
            })
        }

        onMenuClicked: {
            id_touch_reading_result_index.stop()
            switch (buttonText) {
            case "单词预习":
                // todo
                break
            case "跟读模式":
                if (null !== followMattiReadingTips) {
                    settingManager.readingBookType = YEnum.RBT_Follow
                    id_bg_image.item = followMattiReadingTips
                    playMp3("follow-mode-enable")
                    followMattiReadingTips.play()
                    logManager.sendHttpLog("action=touchreading_mode_readfollow_click")
                }
                break
            case "互动答题":
                qmlGlobal.currentQuizLearningType = YEnum.QLT_Default
                qmlGlobal.requestInteractiveQuizzesTips()
                logManager.sendHttpLog(("action=touchreading_mode_test_click&name=%1").arg(readingBookCoverManager.coverText))
                break
            case "学汉字": // 小象识字
                interactiveLearningManager.xiaoxiangLearning(buttonKey)
                break
            case "玩游戏": // 小象识字
                readingBookQuizManager.xiaoxiangPlayGames(buttonKey)
                break
            case "学单词": // 红火箭
                readingBookContentArrayManager.requestRedRocketLearning(buttonKey)
                break
            case "做练习": // 红火箭
                readingBookQuizManager.redRocketStartPractice(buttonKey)
                break
            case "点读模式":
            case "读绘本": // 红火箭
            default:
                if (null !== touchBookReadingTips) {
                    settingManager.readingBookType = YEnum.RBT_Touch
                    id_bg_image.item = touchBookReadingTips
                    playMp3("reading-guide-tip")
                    touchBookReadingTips.play()
                }
                break
            }
        }
    }

    property var touchBookReadingTips: null

    Component {
        id: id_touch_book_reading_tips
        YTouchBookReadingTips {
        }
    }

    property var followMattiReadingTips: null

    Component {
        id: id_follow_matti_reading_tips
        YFollowMattiReadingTips {
        }
    }

    YTimer {
        id: id_delay_enabled_timer
        interval: 900
        onTriggered: {
            if (YEnum.PageIndex.Reading !== qmlGlobal.currentPageIndex) {
                id_touch_reading_result_index.visible = false
                id_touch_reading_result_index.destroy()
            } else {
                id_touch_reading_result_index.visible = true
            }
        }
    }

    onEndPlay: {
        id_bg_image.item.stop()
    }

    Component.onCompleted: {
        touchBookReadingTips = id_touch_book_reading_tips.createObject(id_touch_reading_result_index)
        followMattiReadingTips = id_follow_matti_reading_tips.createObject(id_touch_reading_result_index)
        logManager.sendHttpLog("action=touchreading_mode_view")
    }
}
