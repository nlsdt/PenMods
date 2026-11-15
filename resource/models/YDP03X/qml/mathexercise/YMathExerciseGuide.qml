import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
     id: id_mathexercise_guide_item
     anchors.fill: parent
     visible: false

     YBackgroundIgnoreMouseEvent {
         anchors.fill: parent
     }

    YLoader {
        id: id_verify_content_loader
        width: id_mathexercise_guide_item.width
        height: id_mathexercise_guide_item.height
        sourceComponent: id_introduction_component
        onSourceComponentChanged: {
            console.log("YMathExerciseGuide.qml === id_verify_content_loader.onSourceComponentChanged: ")
        }
    }

    Component {
        id: id_introduction_component

        Item {
            id: id_introduction_item
            width: id_mathexercise_guide_item.width
            height: id_mathexercise_guide_item.height

            Flickable {
                width: parent.width
                height: parent.height
                topMargin: 24
                rightMargin: 20
                anchors {top: parent.top; left: parent.left;leftMargin: 90}
                contentHeight: id_tilte.height + id_image_bg.paintedHeight + id_image_bg.anchors.topMargin + 10
                clip: true

                YText {
                    id: id_tilte
                    height: 34
                    width: parent.width
                    font.pixelSize: 26
                    font.family: fontManager.fontFamilyZhCn
                    font.weight: Font.Normal
                    color: YColors.grayText
                    anchors {top: parent.top; left: parent.left}
                    horizontalAlignment: Text.AlignLeft
                    text: YTranslateText.mathExerciseIntro
                }

                YImage {
                    id: id_image_bg
                    anchors {top: id_tilte.bottom; topMargin: 26; left: parent.left}
                    sourceSize: Qt.size(690, 840)
                    imageName: "math/exercise-introduction"
                    Component.onCompleted: {
                        console.log("YMathExerciseGuide.qml===id_image_bg ", id_image_bg.width, id_image_bg.height)
                    }
                }
            }

            YVerticalTitleBar {
                id: id_title_bar
                onCallBack: {
                    id_mathexercise_guide_item.visible = false
                }
            }

        }
    }

    onVisibleChanged: {
        id_verify_content_loader.active = id_mathexercise_guide_item.visible
    }
}
