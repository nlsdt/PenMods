import QtQuick 2.12

import BaseQml 1.0

YAnimatedImagesView {
    objectName: "YFollowMicTipBase.qml"
    frameSize: Qt.size(140, 150)

    frameDuration: 40
    frameCount: 70
    frameCountLoop: 60
    frameCountExit: 30

    imageName: "matti_mic"
    imageNameLoop: "matti_mic_loop"
    imageNameExit: "matti_mic_end"
}
