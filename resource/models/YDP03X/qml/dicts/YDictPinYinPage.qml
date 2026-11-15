import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YDictTypeBase {
    id: id_spell_page
    objectName: "YPage===YSpellPage.qml"
    title: YTranslateText.dtPinYinDict
    onDictJsonChanged: {
        chPinyinList = JSON.parse(content).data
    }
    //property var chPinyinList: JSON.parse(content).data

//    onIsFirstDictChanged:  {
//        if(isFirstDict) {

//        }
//    }

    Item {
        id: name
        height: id_word_column.height
        width:  590
        function oneButtonClick() {
            var nAutoPronType =  YEnum.PinYin
            let audioNumber = 0
            for(let i =0;i < id_pinyin_repeater.count;i++) {
                if (resultManager.currentQuery === id_pinyin_repeater.itemAt(i).word) {
                   audioNumber = i
                   //id_pinyin_repeater.itemAt(i).play()
                   break
                }
            }
            qmlGlobal.audioPlayId = soundCenter.play(id_pinyin_repeater.itemAt(audioNumber).pronunciationFileName,
                                                     "en",
                                                     id_pinyin_repeater.itemAt(audioNumber).pronunciationFileName,
                                                     nAutoPronType + 1)
        }
        property var words: null
        readonly property var phoneticSymbolJson: {
            let jsonObjTmp = null
            try {
                jsonObjTmp = JSON.parse(resultManager.phoneticSymbolJson)
            } catch(e) { }
            return jsonObjTmp
        }

        Column {
            id: id_word_column
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0
            visible: id_pinyin_repeater.count

            YSpacingForColumn {
                implicitHeight: 10
            }

            onVisibleChanged: {
                if (visible && settingManager.isAutoPronounce && id_dict_page.visible && !resultManager.isReturnSearch && isFirstDict) {
                    console.warn("******************* name.oneButtonClick")
                    name.oneButtonClick()
                }
            }

            Flow{
                id: id_pinyin_grid
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 30
                //rowSpacing: 50
                //columnSpacing:
                //columns: 2
                Repeater{
                    id:id_pinyin_repeater
                    model: JSON.parse(content).data

                    delegate:
                        YAudioPlayIconLabelButton {
                        implicitHeight: 47
                        leftMargin: 0
                        rightMargin: index != id_pinyin_repeater.model.length-1 ? 10 : 0
                        id: id_sound_pinyin
                        //textWrapMode:YText.Wrap
                        sourceSize:Qt.size(32,32)
                        color: "transparent"
                        text:  typeof model.modelData.text != "undefined"?model.modelData.text:model.modelData.phonetic
                        property var pronunciationFileName: {
                            let pos = model.modelData.phonetic.indexOf(".")
                            let fileName="";
                            if(pos!=-1)
                                fileName=model.modelData.phonetic.substring(0,pos)
                            else
                                fileName=model.modelData.phonetic
                            return fileName
                        }

                        property var word: typeof model.modelData.text != "undefined"?model.modelData.text:model.modelData.phonetic
                        onValidClicked: {
                            if (playing) {
                                for(let i =0;i<id_pinyin_repeater.count;i++)
                                {
                                    if (i!=index&&id_pinyin_repeater.itemAt(index).playing) {
                                        id_pinyin_repeater.itemAt(index).stop()
                                    }
                                }
                                play()
                                var nAutoPronType =  YEnum.PinYin
                                qmlGlobal.audioPlayId = soundCenter.play(pronunciationFileName,
                                                                         "en",
                                                                         pronunciationFileName,nAutoPronType + 1)
                            }
                        }
                    }
                }
            }
            //词典选择暂去
            YLoader{
                id:id_setDict_loader
                property var currentSelectDict: 0
                asynchronous: true
                active:false
                sourceComponent: id_setDict_component
            }
            Component{
                id:id_setDict_component
                Item{
                    width: 244
                    height: id_text.height+id_space_item.height+id_chinese_button.height+id_dict_space_item.height+
                            id_chinese_english_button.height
                    YText{
                        id:id_text
                        text:YTranslateText.preferSearchDict
                        font.pixelSize: 18
                        textFormat: Text.RichText
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment:Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        width: 244
                        height: 44
                    }
                    Item{
                        id:id_space_item
                        anchors.top:id_text.bottom
                        anchors.left: parent.left
                        height: 10
                        width: id_text.width
                    }
                    YPressedButton {
                        id: id_chinese_button
                        anchors.left: parent.left
                        anchors.top: id_space_item.bottom
                        implicitWidth: 244
                        implicitHeight: 50
                        clickable: !id_setDict_loader.currentSelectDict
                        checkedIndicatorScale:id_setDict_loader.currentSelectDict
                        textItem.font.pixelSize: 18
                        text: YTranslateText.dtChEnglish
                        onClicked: {
                            id_setDict_loader.currentSelectDict =1
                        }
                    }
                    Item{
                        id:id_dict_space_item
                        anchors.top:id_chinese_button.bottom
                        anchors.left: parent.left
                        height: 10
                        width: id_text.width
                    }
                    YPressedButton {
                        id: id_chinese_english_button
                        anchors.left: parent.left
                        anchors.top: id_dict_space_item.bottom
                        implicitWidth: 244
                        implicitHeight: 50
                        clickable:  id_setDict_loader.currentSelectDict
                        checkedIndicatorScale: !id_setDict_loader.currentSelectDict
                        textItem.font.pixelSize: 18
                        text: YTranslateText.dtChChinese
                        onClicked: {
                            id_setDict_loader.currentSelectDict =0
                        }
                    }
                }
            }
        }
    }
}
