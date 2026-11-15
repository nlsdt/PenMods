import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YBackgroundIgnoreMouseEvent {
    implicitWidth: YEnum.Screen.Width
    implicitHeight: YEnum.Screen.Height
    visible: false

    signal backButtonClicked()

    function show() {
        visible = true
    }

    property int currentIndex: settingManager.articleLevel

    enum STLevel {
        DEFAULT,    // (0, "通用")
        PRIMARY,    // (1, "小学")
        JUNIOR,     // (2, "初中")
        HIGH,       // (3, "高中")
        CET4,       // (4, "四级")
        CET6,       // (5, "六级")
        GRADUATE,   // (6, "考研")
        TOEFL,      // (7, "托福")
        IELTS = 9   // (9, "雅思")
    }

    Flickable {
        id: id_container
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_layout_column.height

        Column {
            id: id_layout_column
            anchors.left: parent.left
            anchors.right: parent.right

            YSpacingForColumn {
                implicitHeight: 24
            }

            YTextBase {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 34
                font.pixelSize: 26
                color: YColors.grayText
                text: YTranslateText.articleLevelSelectedTip
            }

            YSpacingForColumn {
                implicitHeight: 14
            }

            Grid {
                anchors.left: parent.left
                anchors.right: parent.right
                columnSpacing: 12
                rowSpacing: 10
                columns: 3

                Repeater {
                    id: id_level_repeater
                    model: {
                        switch (settingManager.uiLanguage) {
                        case YEnum.ZH_CN:
                            return ["通用","小学", "初中", "高中", "四级", "六级", "考研", "托福", "雅思"]
                        //case YEnum.ZH_TW:
                        //    return ["通用","小学", "初中", "高中", "四级", "六级", "考研", "托福", "雅思"] // todo may be
                        //case YEnum.JA_JP:
                        //    return ["通用","小学", "初中", "高中", "四级", "六级", "考研", "托福", "雅思"] // todo may be
                        //case YEnum.KO_KR:
                        //    return ["通用","小学", "初中", "高中", "四级", "六级", "考研", "托福", "雅思"] // todo may be
                        case YEnum.EN_US:
                        default:
                            return ["General","G1-G6", "G7-G9", "G10-G12", "CET 4", "CET 6", "NEEP", "TOEFL", "IELTS"]
                        }
                    }

                    YPressedButton {
                        implicitWidth: 224
                        clickable: model.index !== (9 === currentIndex ? 8 : currentIndex)
                        checkedIndicatorScale: model.index === (9 === currentIndex ? 8 : currentIndex)

                        function logType(selectedIndex) {
                            switch(selectedIndex) {
                            case 1:
                                return "G1-G6"
                            case 2:
                                return "G7-G9"
                            case 3:
                                return "G10-G12"
                            case 4:
                                return "CET4"
                            case 5:
                                return "CET6"
                            case 6:
                                return "NEEP"
                            case 7:
                                return "TOEFL"
                            case 8:
                                return "IELTS"
                            case 0:
                            default:
                                return "General"
                            }
                        }

                        onClicked: {
                            if (model.index !== (9 === currentIndex ? 8 : currentIndex)) {
                                currentIndex = (8 === model.index) ? 9 : model.index
                                logManager.sendHttpLog("action=essay_level&type=%1".arg(logType(currentIndex)))
                            }
                        }
                        textItem.font.family: qmlGlobal.fontFamilyZhCn
                        text: model.modelData
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 32
            }
        }
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            backButtonClicked()
        }
    }

    YIconButton {
        id: id_filter_button
        opacity: mouseAreaItem.pressed || !enabled ? 0.2 : 1
        implicitWidth: 44
        implicitHeight: 44
        radius: height/2
        mouseAreaMargins: -25
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        enabled: -1 !== currentIndex
        sourceSize: Qt.size(36, 36)
        imageName: "commons/confirm"
        onValidClicked: {
            settingManager.articleLevel = currentIndex
            backButtonClicked()
        }

        property int incubatorCreateCount: 0
    }
}
