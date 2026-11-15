import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

import QtQuick 2.12
import com.youdao.pen 1.0

import "./commons"
import "./i18n"

YBackgroundIgnoreMouseEvent {
    anchors.fill: parent
    function play() {
//        id_scan_guide_animation.play()
    }
    function stop() {
//        id_scan_guide_animation.stopPlay()
    }

    signal callBack()

//    YTextBase {
//        id: id_result_empty_tip
//        width: 410
//        height: parent.height
//        anchors.left: parent
//        anchors.leftMargin: 70
//        anchors.fill: parent
//        color: "#FFFFFF"
//        font.pixelSize: 32
//        lineHeightMode: Text.FixedHeight
//        lineHeight: 46
//        textFormat: YTextMedium.RichText
//        text: YTranslateText.scanMethodTip.arg(YColors.red)
//        verticalAlignment: Text.AlignVCenter
//    }

    YImage {
        id: id_result_empty_tip_image
       // anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: 80
        fillMode: Image.PreserveAspectFit
        imageName: settingManager.uiLanguage === YEnum.ZH_CN ?
                       "scan-tip" : "scan-tip-en"
        //sourceSize: Qt.size(300, 254)
    }

//    YAnimatedImagesView {
//        id: id_scan_guide_animation
//        objectName: "YScanGuidePage.qml"
//        anchors.fill: parent
//        anchors.leftMargin: running ? 0 : YEnum.Screen.Width
//        Behavior on anchors.leftMargin {
//            NumberAnimation {
//                duration: 300
//            }
//        }
//        frameSize: Qt.size(YEnum.Screen.Width, YEnum.Screen.Height)
//        frameCountLoop: 289
//        imageNameLoop: "scan_guide"
//        clip: false
//    }

    YVerticalTitleBar {
        anchors.left: parent.left
//        anchors.leftMargin: id_scan_guide_animation.running ? 0 : YEnum.Screen.Width
//        Behavior on anchors.leftMargin {
//            NumberAnimation {
//                duration: 300
//            }
//        }
        onCallBack: {
            parent.callBack()
            qmlGlobal.requestHideScanGuide()
        }
    }
}


//YBackgroundIgnoreMouseEvent {
//    anchors.fill: parent
//    function play() {
//        id_scan_guide_animation.play()
//    }
//    function stop() {
//        id_scan_guide_animation.stopPlay()
//    }

//    signal callBack()

//    YAnimatedImagesView {
//        id: id_scan_guide_animation
//        objectName: "YScanGuidePage.qml"
//        anchors.fill: parent
//        anchors.leftMargin: running ? 0 : YBaseEnum.Screen.Width
//        Behavior on anchors.leftMargin {
//            NumberAnimation {
//                duration: 300
//            }
//        }
//        frameSize: Qt.size(YBaseEnum.Screen.Width, YBaseEnum.Screen.Height)
//        frameCountLoop: 289
//        imageNameLoop: "scan_guide"
//        clip: false
//    }

//    YVerticalTitleBar {
//        anchors.left: parent.left
//        anchors.leftMargin: id_scan_guide_animation.running ? 0 : YBaseEnum.Screen.Width
//        Behavior on anchors.leftMargin {
//            NumberAnimation {
//                duration: 300
//            }
//        }
//        onCallBack: {
//            parent.callBack()
//            qmlGlobal.requestHideScanGuide()
//        }
//    }
//}
