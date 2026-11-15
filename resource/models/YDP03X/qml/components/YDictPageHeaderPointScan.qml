import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
    id: id_header_item
    width: id_animated_sprite_container.width + id_header_content.width + 12
    implicitHeight: 70
    objectName: "YDictPageHeaderNormal.qml"

    Item {
        id: id_animated_sprite_container
        implicitWidth: 32
        implicitHeight: 32
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        YAnimatedImagesView {
            id: id_animated_sprite
            objectName: "YDictPageHeaderPointScan.qml"
            anchors.centerIn: parent
            scale: 0.5
            frameSize: Qt.size(64, 64)
            frameCount: 22
            frameDuration: 40
            imageName: "point_scan"
            onCurrentFrameChanged: {
                if (currentFrame >= 21) {
                    stopPlay()
                }
            }
        }
    }

    YTextMedium {
        id: id_header_content
        anchors.left: id_animated_sprite_container.right
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 25
        verticalAlignment: YTextMedium.AlignBottom
        color: YColors.grayText
        text: {
            if (YEnum.ZH_CN === settingManager.uiLanguage) {
                efficiencyReport.addClock("point_scan_show_event")
                return YTranslateText.pointScan
            } else
                return ""
        }
        width: paintedWidth
        height: id_animated_sprite_container.height      
    }

    Connections {
        target: resultManager
        ignoreUnknownSignals: true
        function onCurrentQueryChanged() {
            if (0 === qmlGlobal.scanType) {
                id_animated_sprite.play()
            }
        }
    }
}

