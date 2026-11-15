import QtQuick 2.12
import QtQuick.XmlListModel 2.14
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"
import "../../qml/timers"
import "../components"
import "../commons"

//YDictOnlineSearchWords
YDictTypeBase {
    id: id_dict_type_online
    title: YTranslateText.dtOnlineTitle 
    Column{
        anchors.left: parent.left
        anchors.top : parent.top
        anchors.right: parent.right
        spacing: 10
        Repeater {
            id: id_paraphrase_repeater
            model: {
                var arr = []
                console.log("chenfei 在线查词:",dictJson)
                dictJson.webOnline.trans.forEach(function(transObj){
                    arr.push(transObj)
                })
                return arr
            }
            Rectangle {
                height: id_paraphrase_content.contentHeight
                width: parent.width
                color: "black"
                YText {
                    id: id_paraphrase_num
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width:id_paraphrase_repeater.model.length < 2 ? 0 : 30
                    height: width
                    // font.family: fontManager.fontFamilyXinHuaXiHei
                    font.pixelSize: 30
                    wrapMode: YText.WordWrap
                    textFormat: Text.RichText
                    color: YColors.white
                    visible: width != 0
                    text: index + 1 + "."
                }

                YText {
                    id: id_paraphrase_content
                    anchors.left: id_paraphrase_num.right
                    anchors.top: id_paraphrase_num.top
                    anchors.right: parent.right
                    // font.family: fontManager.fontFamilyXinHuaXiHei
                    font.pixelSize: 30
                    wrapMode: YText.WordWrap
                    textFormat: Text.RichText
                    color: YColors.white
                    text: id_paraphrase_repeater.model[index]//"0000000000000 0000000000 00000000000000000 0000000000000"
                }
            }
        }

        YTextBase {
            id: id_word_source_key
            width: parent.width
            height: 30
            visible: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment :Text.AlignVCenter
            font.pixelSize: 26
            color: YColors.grayText
            text: YTranslateText.dtOnlineSubTitle
        }
    }
    
}