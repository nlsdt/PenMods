import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

Flickable {
    id: id_flickable_item
    contentHeight: id_content_container.height

    property int readingBookType: YEnum.RBT_Touch

    readonly property int activeSentenceIndex: readingBookReadingManager.activeSentenceIndex
    readonly property bool isTranslateShowing: YEnum.RBTT_ZH_CN === settingManager.readingBookTranslateType
    readonly property bool audioPlayStateNoPlaying: YEnum.PAUSED === readingBookReadingManager.audioPlayState ||
                                                    YEnum.STOPPED === readingBookReadingManager.audioPlayState
    property bool isFollowing: true

    signal playStarIncrease()
    signal totalTextReadingFinished()
    signal followMoveItem(int index)

    function updateContentYBySentenceIndex(sentenceIndex) {
        let item = null
        for (let i = 0; i < id_jumping_animation_text_repeater.count; ++i) {
            item = id_jumping_animation_text_repeater.itemAt(i)
            if (item.itemSentenceIndex === sentenceIndex) {
                const posY = item.mapToItem(id_content_container, 0, 0).y
                id_flickable_item.contentY = posY - (id_flickable_item.height - 120) / 2
                break
            }
        }
    }

    function posYAtItem(index) {
        const item = id_jumping_animation_text_repeater.itemAt(index)
        const posY = item.mapToItem(id_content_container, 0, 0).y
        id_flickable_item.contentY = posY - (id_flickable_item.height - item.height - 36) / 2
    }

    Flow {
        id: id_content_container
        width: parent.width

        YSpacing {
            implicitWidth: id_flickable_item.width
            implicitHeight: 80
        }

        Repeater {
            id: id_jumping_animation_text_repeater
            model: visible ? readingBookReadingManager : null

            Item {
                id: id_jumping_animation_text_item
                width: id_jumping_animation_text.visible ? id_jumping_animation_text.width : 0
                height: {
                    if (id_jumping_animation_text.visible) {
                        if (YEnum.AniTextTypeTrans === model.modelData.textType) {
                            return isTranslateShowing ? (50 + id_jumping_animation_text.height) : 1
                        }
                        return 84
                    }
                    return 0
                }

                readonly property int itemSentenceIndex: model.modelData.sentenceIndex

                YJumpingAnimationText {
                    id: id_jumping_animation_text
                    interval: model.modelData.duration
                    content: model.modelData.text
                    playState: model.modelData.animationState
                    isActive: activeSentenceIndex === model.modelData.sentenceIndex
                    textType: model.modelData.textType
                    followHitState: model.modelData.followHitState
                    anchors.bottom: parent.bottom
                    readingBookType: id_flickable_item.readingBookType
                    audioPlayStateIsFinished: audioPlayStateNoPlaying

                    visible: {
                        if (!isReadingBookTypeIsTouch && isFollowing) {
                            return isActive
                        }
                        return true
                    }
                    onPlayStateChanged: {
                        if (!isTranslateType) {
                            posYAtItem(index)
                        }
                        id_monkey_jump_singleton.stopPlay()
                    }
                    onCallMonkeyRejump: {
                        if (!isTranslateType) {
                            followMoveItem(index)
                        }
                        id_monkey_jump_singleton.stopPlay()
                        if (!isReadingBookTypeIsTouch) {
                            id_star_item.stop()
                        }
                        const item = id_jumping_animation_text_repeater.itemAt(index)
                        const pos = item.mapToItem(id_content_container, 0, 0)
                        const posX = pos.x + (item.width - id_monkey_jump_singleton.width) / 2
                        const posY = pos.y + (item.height - id_monkey_jump_singleton.height) / 2 + 22
                        id_monkey_jump_singleton.x = posX
                        id_monkey_jump_singleton.y = posY
                        id_monkey_jump_singleton.play()
                        if (!isReadingBookTypeIsTouch) {
                            id_star_item.moving()
                        }
                        if (!isReadingBookTypeIsTouch) {
                            playStarIncrease()
                        }
                    }
                    onTextAnimationFinished: {
                        if (isReadingBookTypeIsTouch &&
                                ((id_jumping_animation_text_repeater.count - 2) === index) &&
                                ((readingBookReadingManager.sentenceCount - 1) === model.modelData.sentenceIndex)) {
                            id_jumping_animation_text.stopAnimation()
                            totalTextReadingFinished()
                        }
                    }
                }
            }
        }

        YSpacing {
            implicitWidth: id_flickable_item.width
            implicitHeight: isTranslateShowing ? 40 : 100
        }
    }

    YImage {
        id: id_star_item
        sourceSize: Qt.size(30, 30)
        imageName: "touchreading/star"
        visible: id_star_moving_animation.running
        x: (id_monkey_jump_singleton.x + id_monkey_jump_singleton.width / 2)
        y: (id_monkey_jump_singleton.y + id_monkey_jump_singleton.height / 2)

        function moving() {
            id_star_moving_animation.restart()
        }

        function stop() {
            id_star_moving_animation.stop()
        }

        ParallelAnimation {
            id: id_star_moving_animation
            alwaysRunToEnd: true
            NumberAnimation {
                target: id_star_item
                property: "x"
                from: id_monkey_jump_singleton.x + id_monkey_jump_singleton.width / 2
                to: 602
                duration: 120
            }
            NumberAnimation {
                target: id_star_item
                property: "y"
                from: id_monkey_jump_singleton.y + id_monkey_jump_singleton.height / 2
                to: id_flickable_item.contentY + 14
                duration: 120
            }
        }
    }

    YReadingMonkey {
        id: id_monkey_jump_singleton
    }

    onVisibleChanged: {
        if (!visible) {
            id_star_item.stop()
        }
    }
}
