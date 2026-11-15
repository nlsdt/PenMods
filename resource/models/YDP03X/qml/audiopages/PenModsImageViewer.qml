import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../common"
import "../i18n"

// 图片查看器（png/jpg/gif/bmp/webp；webp 走 image://webp provider）
//
// 显示策略：先把图片等比缩放到完整适配视口（fitScale），再叠加捏合缩放（imgScale 1~4 倍）。
// 注意不能把 Image 高度设成 sourceSize 原始像素高再 PreserveAspectFit——
// 那样绘制内容会被垂直居中到视口外，表现为整页黑屏。
YBackButtonPage {
    id: id_image_viewer
    objectName: "YPage===PenModsImageViewer.qml"

    property real imgScale: 1.0

    // 让整张图完整落入视口的缩放系数（按宽高分别计算取小）
    readonly property real fitScale: {
        var sw = id_img.sourceSize.width
        var sh = id_img.sourceSize.height
        if (sw <= 0 || sh <= 0) return 1.0
        var vw = id_img_flick.width
        var vh = id_img_flick.height
        if (vw <= 0 || vh <= 0) return 1.0
        return Math.min(vw / sw, vh / sh)
    }

    Flickable {
        id: id_img_flick
        anchors.fill: parent
        anchors.leftMargin: 54
        anchors.rightMargin: 12
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        contentWidth: id_img.width
        contentHeight: id_img.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Image {
            id: id_img
            anchors.top: parent.top
            anchors.left: parent.left
            source: (imageViewer && imageViewer.source) ? imageViewer.source : ""
            fillMode: Image.PreserveAspectFit
            // 缩放后尺寸 = 原始像素 × 适配系数 × 捏合缩放
            width: id_img.sourceSize.width > 0
                   ? id_img.sourceSize.width * id_image_viewer.fitScale * imgScale : 0
            height: id_img.sourceSize.height > 0
                    ? id_img.sourceSize.height * id_image_viewer.fitScale * imgScale : 0
            transformOrigin: Item.TopLeft
            cache: false

            onStatusChanged: {
                if (status === Image.Error) {
                    id_load_fail_tip.visible = true
                }
            }
        }

        // 加载失败提示（覆盖在图片区中央）
        YText {
            id: id_load_fail_tip
            anchors.centerIn: parent
            visible: false
            font.pixelSize: 20
            color: YColors.grayText
            font.family: fontManager.fontFamilyZhCn
            text: "图片加载失败"
        }

        PinchArea {
            anchors.fill: parent
            onPinchUpdated: {
                imgScale = Math.max(1.0, Math.min(4.0, imgScale * pinch.scale))
            }
            onPinchFinished: {
                imgScale = Math.max(1.0, Math.min(4.0, imgScale * pinch.scale))
            }
        }
    }
}
