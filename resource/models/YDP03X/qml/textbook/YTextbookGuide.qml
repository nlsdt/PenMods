import QtQuick 2.12
import QtGraphicalEffects 1.0
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    id: id_textbook_guide_item
    objectName: "YTextBookGuide.qml"
    anchors.fill: parent

    YVerticalTitleBar {
        onCallBack: {
            id_textbook_page.subPageCallBack()
        }
    }

    YMouseArea {
        id: id_select_textbook_mousearea
        anchors.left: parent.left
        anchors.leftMargin: 90
        anchors.top: parent.top
        anchors.topMargin: 32
        width: 200
        height: 190

        YImage {
            id: id_select_textbook_image
            anchors.fill: parent
            imageName: ("textbook/guide-%1").arg(imageIndex)
            property int imageIndex: 1
            YTimer {
                id: id_select_textbook_image_timer
                repeat: true
                interval: 5000
                onTriggered: {
                    id_select_textbook_image.imageIndex %= 3
                    id_select_textbook_image.imageIndex += 1
                }
            }
        }

        Item {
            id: id_effect_item
            implicitWidth: parent.width
            implicitHeight: 60
            anchors.bottom: parent.bottom
            clip: true

            ShaderEffectSource {
                id: id_effect_source
                anchors.fill: parent
                sourceItem: id_select_textbook_image
                sourceRect: Qt.rect(0, 130, width, height)
            }

            FastBlur {
                anchors.fill: parent
                source: id_effect_source
                radius: 32
            }

            Rectangle {
                anchors.fill: parent
                color: "#661A1B1F"
            }
        }

        Text {
            height: contentHeight
            width: contentWidth
            anchors.centerIn: id_effect_item
            font.pixelSize: 24
            font.family: fontManager.fontFamilyZhCn
            font.weight: Font.Bold
            color: YColors.white
            text: YTranslateText.textbookGuidSelect
            z: id_effect_item.z + 1
        }

        onClicked: {
            id_textbook_page.showSubPage(YEnum.Textbook_Select, true)
        }
    }

    Grid {
        id: id_textbook_guide_grid
        anchors.top: parent.top
        anchors.topMargin: id_textbook_guide.visible ? 45 : 78
        anchors.left: parent.left
        anchors.leftMargin: 360
        columns: 2
        columnSpacing: 64
        rowSpacing: id_textbook_guide.visible ? 25 : 34

        Repeater {
            model: iconTextModel

            Item {
                implicitWidth: 146
                implicitHeight: 32

                YImage {
                    sourceSize: Qt.size(30, 30)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    imageName: iconName
                }

                Text {
                    height: parent.height
                    width: contentWidth
                    anchors.left: parent.left
                    anchors.leftMargin: 42
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 26
                    font.family: fontManager.fontFamilyZhCn
                    color: YColors.grayText
                    text: textContent
                }
            }
        }

        ListModel {
            id: iconTextModel
            Component.onCompleted: {
                append({iconName: "textbook/guid-audio", textContent:YTranslateText.textbookGuidAudio})
                append({iconName: "textbook/guid-scan", textContent:YTranslateText.textbookGuidScan})
                append({iconName: "textbook/guid-listen", textContent:YTranslateText.textbookGuidListen})
                append({iconName: "textbook/guid-spoken", textContent:YTranslateText.textbookGuidSpoken})
            }
        }
    }

    Rectangle {
        id: id_textbook_guide
        width: 376
        height: 60
        anchors.horizontalCenter: id_textbook_guide_grid.horizontalCenter
        anchors.top: id_textbook_guide_grid.bottom
        anchors.topMargin: 28
        radius: height / 2
        color: YColors.grayNormal
        visible: false //!qmlGlobal.checkFeature(YEnum.FEATURE_SKU_PEP)

        Text {
            id: id_textbook_guide_text
            height: parent.height
            width: contentWidth
            anchors.left: parent.left
            anchors.leftMargin: 55
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 26
            font.family: fontManager.fontFamilyZhCn
            color: YColors.grayText
            text: YTranslateText.textbookGuidText
        }

        YImage {
            sourceSize: Qt.size(24, 24)
            anchors.left: id_textbook_guide_text.right
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            imageName: "textbook/enter-icon"
        }

        YMouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("YTextbookGuide.qml===show guide page")
                id_free_guide_page.visible = true
            }
        }
    }

    YTextbookFreeGuide {
        id: id_free_guide_page
        anchors.fill:parent
        visible: false
    }

    Component.onCompleted: {
        id_select_textbook_image_timer.start()
    }
}

