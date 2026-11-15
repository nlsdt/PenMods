import QtQuick 2.12
import BaseQml 1.0
import "../i18n"
import "./YMathUtilities.js" as MathUtil

YBackButtonView {
    id: id_calc_guide_view

    property var listItems : [
        {
            title: "四则运算",
            content: "guide_0",
            size: Qt.size(654, 194),
            openHeight: 297,
            isOpen: false
        },
        {
            title: "有余数的除法",
            content: "guide_1",
            size: Qt.size(654, 34),
            openHeight: 137,
            isOpen: false
        },
        {
            title: "比大小",
            content: "guide_3",
            size: Qt.size(654, 158),
            openHeight: 261,
            isOpen: false
        },
        {
            title: "单位换算",
            content: "guide_4",
            size: Qt.size(654, 166),
            openHeight: 269,
            isOpen: false
        },
        {
            title: "乘法口诀",
            content: "guide_5",
            size: Qt.size(654, 78),
            openHeight: 181,
            isOpen: false
        },
        {
            title: "数的读法和写法",
            content: "guide_6",
            size: Qt.size(654, 122),
            openHeight: 225,
            isOpen: false
        },
    ]

    YIconButton {
        id: id_favorite_btn
        implicitWidth: 44
        implicitHeight: 44
        radius: 22
        anchors.horizontalCenter: id_calc_guide_view.backBar.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        mouseAreaMargins: -20
        icon: "math/fav-entry"
        iconSourceSize: Qt.size(36, 36)
        onClicked: {
            logManager.sendHttpLog("action=math_errorbook_click")
            showFavoriteView()
        }
    }

    Flickable {
        id: id_example_listview
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_column.height

        Column {
            id: id_column
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            YSpacingForColumn {
                implicitHeight: 25
            }

            YTextMedium {
                wrapMode: YTextBase.WrapAnywhere
                width: 600
                font.pixelSize: 30
                font.weight: Font.Medium
                textFormat: YTextMedium.RichText
                horizontalAlignment: Text.AlignLeft
                text: YTranslateText.mathCalculateGuideTip_1
            }

            YSpacingForColumn {
                implicitHeight: 18
            }

            YTextMedium {
                wrapMode: YTextBase.WrapAnywhere
                width: 600
                font.pixelSize: 28
                font.weight: Font.Normal
                horizontalAlignment: Text.AlignLeft
                text: YTranslateText.mathCalculateQuesList
            }

            YSpacingForColumn {
                implicitHeight: 12
            }

            Repeater {
                model: id_calc_guide_view.listItems
                delegate: YMathCalculateGuideCell {
                    yModel: model.modelData
                }
            }

            YSpacingForColumn {
                implicitHeight: 16
            }
        }
    }

    YLoader {
        id: id_math_favorite_view
        anchors.fill: parent
        asynchronous: false
        sourceComponent: YMathCalculateFavoriteView{
            onBackButtonClicked: {
                closeFavoriteView()
            }
        }
    }

    function showFavoriteView() {
        MathUtil.showView(id_math_favorite_view)
    }

    function closeFavoriteView() {
        MathUtil.closeView(id_math_favorite_view)
    }
}
