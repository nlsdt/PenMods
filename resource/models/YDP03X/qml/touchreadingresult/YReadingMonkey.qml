import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YAnimatedImagesView {
    objectName: "YReadingMonkey.qml"
    frameDuration: 10
    frameSize: Qt.size(140, 140)
    frameCount: 26
    imageName: "touch_reading_monkey"
    opacity: running
    loops: 1
}
