import QtQuick 2.12

Item {
    id: id_animated_images_view

    implicitWidth: frameSize.width
    implicitHeight: frameSize.height
    state: "enter"
    clip: true

    property alias frameDuration: id_play_timer.interval

    property int loops: Animation.Infinite

    property int currentFrame: 0

    property int stopShowFrameIndex: YSVGImagesView.StopShowFrameAt.SSFA_Last

    property size frameSize: Qt.size(800, 254)

    enum StopShowFrameAt {
        SSFA_First,     // 动画停止时显示第一帧
        SSFA_Last       // 动画停止时显示最后
    }

    property string imageName: ""
    property string imageNameLoop: ""
    property string imageNameExit: ""

    property int frameCount: 0
    property int frameCountLoop: 0
    property int frameCountExit: 0

    property int preloadCount: 1

    readonly property alias running: id_image_enter_repeater.running

    readonly property string baseImagesUrl: (pluginLoader.appWorkPath() + "/svgs/%1.svg").toLoadFileUrl()

    function play() {
        currentFrame = 0
        id_image_enter_repeater.running = true
        if (imageName.length > 0) {
            state = "enter"
        } else if (imageNameLoop.length > 0) {
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
        if (YSVGImagesView.StopShowFrameAt.SSFA_Last === stopShowFrameIndex) {
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
        model: ("exit" === id_animated_images_view.state || (frameCountExit > 0)) ? frameCountExit : 0
        YImage {
            width: (imageNameExit.length > 0) && (index >= currentFrame && (index <= Math.min(currentFrame + preloadCount, frameCountExit - 1))) ? frameSize.width : 0
            height: (imageNameExit.length > 0) && (index >= currentFrame && (index <= Math.min(currentFrame + preloadCount, frameCountExit - 1))) ? frameSize.height : 0
            sourceSize: Qt.size(width, height)
            source: (imageNameExit.length > 0) && (index >= currentFrame && (index <= Math.min(currentFrame + preloadCount, frameCountExit - 1))) ? baseImagesUrl.arg(imageNameExit + "/" + index.padZero(3)) : ""
            visible: id_image_enter_repeater.running && isLoaded && ("exit" === id_animated_images_view.state) && (index === currentFrame)
        }
    }

    Repeater {
        id: id_image_loop_repeater
        model: ("loop" === id_animated_images_view.state || (frameCountLoop > 0)) ? frameCountLoop : 0
        YImage {
            width: (imageNameLoop.length > 0) && (index >= Math.min(currentFrame - preloadCount, 0) && (index <= Math.min(currentFrame + preloadCount, frameCountLoop - 1))) ? frameSize.width : 0
            height: (imageNameLoop.length > 0) && (index >= Math.min(currentFrame - preloadCount, 0) && (index <= Math.min(currentFrame + preloadCount, frameCountLoop - 1))) ? frameSize.height : 0
            sourceSize: Qt.size(width, height)
            source: (imageNameLoop.length > 0) && (index >= Math.min(currentFrame - preloadCount, 0) && (index <= Math.min(currentFrame + preloadCount, frameCountLoop - 1))) ? baseImagesUrl.arg(imageNameLoop + "/" + index.padZero(3)) : ""
            visible: isLoaded && ("loop" === id_animated_images_view.state) && (index === currentFrame)
        }
    }

    Repeater {
        id: id_image_enter_repeater
        model: ("enter" === id_animated_images_view.state) ? frameCount : 0
        YImage {
            width: (id_animated_images_view.imageName.length > 0) && (index >= currentFrame && (index <= Math.min(currentFrame + preloadCount, frameCount - 1))) ? frameSize.width : 0
            height: (id_animated_images_view.imageName.length > 0) && (index >= currentFrame && (index <= Math.min(currentFrame + preloadCount, frameCount - 1))) ? frameSize.height : 0
            sourceSize: Qt.size(width, height)
            source: (id_animated_images_view.imageName.length > 0) && (index >= currentFrame && (index <= Math.min(currentFrame + preloadCount, frameCount - 1)))
                       ? baseImagesUrl.arg(id_animated_images_view.imageName + "/" + index.padZero(3)) : ""
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
                return (currentFrame < frameCount - 1) || (imageNameLoop.length > 0)
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
                    if (imageNameLoop.length > 0) {
                        id_animated_images_view.state = "loop"
                        currentFrame = 0
                    } else {
                        id_play_timer.stop()
                        currentFrame = (YSVGImagesView.StopShowFrameAt.SSFA_Last === stopShowFrameIndex) ? (frameCount - 1) : 0
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
