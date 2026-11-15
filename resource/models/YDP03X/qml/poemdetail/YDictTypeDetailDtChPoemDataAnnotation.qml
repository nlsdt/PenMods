import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../commons"
import "../dicts"
import "../i18n"

YBackButtonPage {
    id: id_dict_detail_page
    objectName: "YPage===YDictTypeDetailDtChPoemDataAnnotation.qml"

    property int dictType: YEnum.NoDict
    property string content: ""
    readonly property var dictJson: {
        try {
            let jsonObj = JSON.parse(content)
            if (typeof jsonObj == "object") {
                return jsonObj
            }
        } catch(e) {
            console.log("YDictDetailPage.qml === dictJson parse error: ", e)
        }
        return new Object
    }
    property alias title: id_title_text.text
    property bool showPoemTitle: false
    property var backLastPos:null

    Flickable {
        id: id_container_flickable
        anchors.fill: parent
        anchors.leftMargin: 60
        anchors.rightMargin: 16
        z: id_dict_detail_page.z + 1
        contentHeight: id_dict_content_column.height
        interactive: !id_dict_content_loader.moving

        Column {
            id: id_dict_content_column
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            YSpacingForColumn {
                implicitHeight: 12
            }

            YText {
                id: id_title_text
                visible: !showPoemTitle
                width: parent.width
                color: YColors.wordBlue
                height: 24
                //horizontalAlignment: YText.AlignHCenter
                verticalAlignment: YText.AlignVCenter
                font.pixelSize: 22
            }

            Rectangle {
                id: id_word_bg
                width: id_poem_title_origin.paintedWidth + 16
                height: id_poem_title_origin.paintedHeight + 6
                color: "#171717"
                radius: 4
                clip: true
                visible: showPoemTitle

                YTextBase {
                    id: id_poem_title_origin
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.top: parent.top
                    anchors.topMargin: 3
                    height: parent.height
                    width: Math.min(228, paintedWidth + 16)
                    font.family: qmlGlobal.fontFamilyZhCn
                    font.letterSpacing: 2
                    font.pixelSize: text.length > 5 ? 22 : 32
                    color: YColors.white
                    text: id_title_text.text
                    wrapMode: text.length > 5 ? YTextBase.Wrap : Text.NoWrap
                } // Text id_poem_title_origin
            }

            YSpacingForColumn {
                implicitHeight: 10
            }
            YLoader {
                id: id_dict_content_loader
                asynchronous: false

                active: YEnum.DtChLarge === dictType
                        || YEnum.DtChAncientWord === dictType
                        || YEnum.DtChPoemDict === dictType
                //英文词典
                        || YEnum.DtOxford === dictType
                        || YEnum.DtSenior === dictType
                        || YEnum.DtWebster === dictType
                        || YEnum.DtEnChKid === dictType
                //韩文词典
                        || YEnum.DtChKo === dictType
                        || YEnum.DtKoCh === dictType
                        || YEnum.DtMangoKidEnglish === dictType
                sourceComponent: {
                    switch(title){
                    case YTranslateText.annotation:
                        return id_poem_annotation
                    }
                }
                //查看注释
                Component{
                    id:id_poem_annotation
                    YDictTypeDtChPoemDataAnnotation{
                        width: id_dict_content_column.width
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 20
            }

            YIconButton {
                id: id_to_top_button
                implicitWidth: 113
                implicitHeight: 66
                color: "transparent"
                mouseAreaMargins: -25
                anchors.horizontalCenter: parent.horizontalCenter
                imageName: "dict/mango_top"
                sourceSize: Qt.size(113, 46)
                visible: id_container_flickable.contentY > id_container_flickable.height
                onValidClicked: {
                    id_container_flickable.contentY = 0
                }
            }
        }
    }
    ignoreDefaultBackButtonClicked: true
    onBackButtonClickedCallback: {
        backButtonClicked()
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.DictDetail
            id_container_flickable.contentY = 0
            if(backLastPos!=null){
                id_container_flickable.contentY = backLastPos
                backLastPos=null
            }
        } else {
            soundCenter.stop()
        }
    }
}
