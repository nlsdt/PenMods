import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YMouseArea {
    id: id_header_item
    width: id_id_header_content_bg.width + ( displayWords ? 6 : 12)
    implicitHeight: 70
    enabled: -1 !== resultManager.autoSelectIndex
    objectName: "YDictPageHeaderNormal.qml"
    Rectangle {
        id: id_id_header_content_bg
        width: id_header_content.contentWidth + (!displayWords ? 24 : 20)
        implicitHeight: parent.implicitHeight
        radius: 16
        color: YColors.grayNormal
        Rectangle {
            radius: parent.radius
            anchors.fill: parent
            visible: -1 === tagsIndex
            color: YColors.red
        }
        YTextBase {
            id: id_header_content
            anchors.centerIn: parent
            font.family: fontManager.fontFamilyZhCn
            font.pixelSize: 26
            font.weight: Font.Bold
            color: (-1 === tagsIndex) ? YColors.white : YColors.grayText
            text: {
                switch (resultManager.mainQueryType) {
                case YEnum.WGT_Sentence:
                    return YTranslateText.wgtSentence
                case YEnum.WGT_Ch_Group:
                case YEnum.WGT_En_Group:
                case YEnum.WGT_Ko_Group:
                    return YTranslateText.wgtGroup
                default:
                    return ""
                }
            }
        }
    }

    onClicked: {
        resultManager.autoSelectIndex = -1
        id_dict_listview.positionViewAtBeginning()
        id_fav_word_button.queryResult(resultManager.mainQuery)
    }
}
