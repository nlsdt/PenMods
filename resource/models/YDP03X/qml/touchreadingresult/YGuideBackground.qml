import QtQuick 2.12
import BaseQml 1.0

YTouchFollowReadingAudioPlayBase {
    id: id_guide_page
    objectName: "YGuideBackground.qml"
    anchors.fill: parent
    visible: false

    property alias maskSource: id_mask.source

    signal closed()

    YTouchReadingResultBlurMask {
        id: id_mask
        anchors.fill: parent
    }
}
