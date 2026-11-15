import QtQuick 2.12
import "../components"

Item {
    id: id_animated_images_view

    implicitWidth: frameSize.width
    implicitHeight: frameSize.height
    state: "enter"
    clip: true

    property alias frameDuration: id_play_timer.interval

    property int loops: Animation.Infinite

    property int currentFrame: 0

    property int stopShowFrameIndex: YStrokesOrderView.StopShowFrameAt.SSFA_Last

    property size frameSize: Qt.size(86, 86)

    enum StopShowFrameAt {
        SSFA_First,     // 动画停止时显示第一帧
        SSFA_Last       // 动画停止时显示最后
    }

    property int frameCount: 0
    property int frameCountLoop: 0
    property int frameCountExit: 0

    property var imageNameList: []
    property var imageNameLoopList: []
    property var imageNameExitList: []

    property int preloadCount: 3

    readonly property alias running: id_image_enter_repeater.running
    readonly property alias playing: id_play_timer.running

    property string baseImagesUrl: "image://svgs/%1.png"

    function play() {
        if (id_play_timer.running) id_play_timer.stop()
        currentFrame = 0
        id_image_enter_repeater.running = true
        if (imageNameList.length > 0) {
            state = "enter"
        } else if (imageNameLoopList.length > 0) {
            state = "loop"
        }
        id_play_timer.restart()
    }

    function runExit() {
        id_play_timer.stop()
        currentFrame = 0
        state = "exit"
        id_play_timer.restart()
    }

    function stopPlay() {
        if (YStrokesOrderView.StopShowFrameAt.SSFA_Last === stopShowFrameIndex) {
            switch (state) {
            case "enter":
                currentFrame = frameCount - 1
                break
            case "loop":
                currentFrame = frameCountLoop - 1
                break
            default:
                currentFrame = 0
                break
            }
        } else {
            currentFrame = 0
        }
        id_play_timer.stop()
        id_image_enter_repeater.running = false
    }

    signal enterAnimatedImagePlayEnd()
    signal loopAnimatedImagePlayEnd() // may be...
    signal exitAnimatedImagePlayEnd()

    Repeater {
        id: id_image_exit_repeater
        model: ("exit" === id_animated_images_view.state || (frameCountExit > 0)) ? imageNameExitList : null
        YImage {
            width: (model !== null) && (index >= currentFrame && (index <= Math.min(currentFrame + preloadCount, frameCountExit - 1))) ? frameSize.width : 0
            height: (model !== null) && (index >= currentFrame && (index <= Math.min(currentFrame + preloadCount, frameCountExit - 1))) ? frameSize.height : 0
            source: (model !== null) && (index >= currentFrame && (index <= Math.min(currentFrame + preloadCount, frameCountExit - 1))) ? model.modelData.toLoadFileUrl() : ""
            visible: id_image_enter_repeater.running && isLoaded && ("exit" === id_animated_images_view.state) && (index === currentFrame)
        }
    }

    Repeater {
        id: id_image_loop_repeater
        model: ("loop" === id_animated_images_view.state || (frameCountLoop > 0)) ? imageNameLoopList : null
        YImage {
            width: (model !== null) && (index >= Math.min(currentFrame - preloadCount, 0) && (index <= Math.min(currentFrame + preloadCount, frameCountLoop - 1))) ? frameSize.width : 0
            height: (model !== null) && (index >= Math.min(currentFrame - preloadCount, 0) && (index <= Math.min(currentFrame + preloadCount, frameCountLoop - 1))) ? frameSize.height : 0
            source: (model !== null) && (index >= Math.min(currentFrame - preloadCount, 0) && (index <= Math.min(currentFrame + preloadCount, frameCountLoop - 1))) ? model.modelData.toLoadFileUrl()  : ""
            visible: isLoaded && ("loop" === id_animated_images_view.state) && (index === currentFrame)
        }
    }

    Repeater {
        id: id_image_enter_repeater
        model: ("enter" === id_animated_images_view.state) ? imageNameList : null
        YImage {
            width: (model !== null) && (index >= currentFrame && (index <= Math.min(currentFrame + preloadCount, frameCount - 1))) ? frameSize.width : 0
            height: (model !== null) && (index >= currentFrame && (index <= Math.min(currentFrame + preloadCount, frameCount - 1))) ? frameSize.height : 0
            source:  (model !== null) && ((index >= currentFrame || index == 0) && (index <= Math.min(currentFrame + preloadCount, frameCount - 1)))
                       ? model.modelData.toLoadFileUrl() : ""
            visible: isLoaded && ("enter" === id_animated_images_view.state) && (index === currentFrame)
        }

        property bool running: false
    }

    YTimer {
        id: id_play_timer
        interval: 40
        repeat: {
            switch (id_animated_images_view.state) {
            case "enter":
                return (currentFrame < frameCount - 1) || (imageNameLoopList.length > 0)
            case "loop":
                return true
            case "exit":
                return (currentFrame < frameCountExit - 1)
            default:
                return false
            }
        }
        onTriggered: {
            if (("enter" === id_animated_images_view.state) && id_image_enter_repeater.itemAt(currentFrame).isLoaded) {
                ++currentFrame
                if (currentFrame === (frameCount - 1)) {
                    enterAnimatedImagePlayEnd()
                    if (imageNameLoopList.length > 0) {
                        id_animated_images_view.state = "loop"
                        currentFrame = 0
                    } else {
                        id_play_timer.stop()
                        currentFrame = (YStrokesOrderView.StopShowFrameAt.SSFA_Last === stopShowFrameIndex) ? (frameCount - 1) : 0
                    }
                }
            } else if (("loop" === id_animated_images_view.state) && id_image_loop_repeater.itemAt(currentFrame).isLoaded) {
                ++currentFrame
                if (currentFrame === (frameCountLoop - 1)) {
                    loopAnimatedImagePlayEnd()
                    currentFrame = 0
                }
            } else if (("exit" === id_animated_images_view.state) && id_image_exit_repeater.itemAt(currentFrame).isLoaded) {
                ++currentFrame
                if (currentFrame === (frameCountExit - 1)) {
                    exitAnimatedImagePlayEnd()
                    id_image_enter_repeater.running = false
                }
            }
        }
    }

}
