import QtQuick 2.12
import QtQuick.XmlListModel 2.14
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"
import "../../qml/timers"
import "../components"

Rectangle {
    id: id_number_rectangle
    anchors.top: parent.top
    anchors.topMargin: 5
    height: 26
    width: visible ? 26 : 0
    radius: height/2
    color: spliteMean ? YColors.transparent: YColors.white
    property var spliteMean: false
    visible: JSON.stringify(model.modelData).length && id_meaning_column.haveMeanText
    YText {
        id: id_mean_index_text
        width: visible ? paintedWidth : 0
        font.family: fontManager.fontFamilyXinHuaXiHei
        anchors.centerIn: parent
        font.pixelSize: spliteMean ? 30 : 20
        color: !spliteMean ? YColors.black : YColors.grayText
        text: index+1
        visible:  {
            return JSON.stringify(model.modelData).length && id_meaning_column.haveMeanText
        }
    }
}



