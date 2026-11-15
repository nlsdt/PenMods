import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import BaseQml 1.0
import "../i18n"
Rectangle {
    id: id_status_bar
    radius: width / 2
    clip: true
    color: "#000000"
    property int spaceHeight: 3
    ListModel {
        id: id_status_model
    }
    function updateSetp(step){
        id_status_model.get(step).isCompledted = 1
    }
    function resetStatusbar(){
        for(var i = 0; i < 3; ++i){
            id_status_model.get(i).isCompledted = 0
        }
    }
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "#000000"
        clip: true
        Column {
            width: parent.width
            Repeater {
                width: parent.width
                model: id_status_model
                Column {
                    width: parent.width
                    Rectangle {
                        width: parent.width
                        height: {
                            var spaceH = (id_status_model.count - 1)  * id_status_bar.spaceHeight
                            return (id_status_bar.height - spaceH) / id_status_model.count
                        }
                        color: "#0069C9"
                        opacity: isCompledted ? 0.8 : 0.2
                    }

                    YSpacingForColumn{
                        height: id_status_bar.spaceHeight
                        visible: true
                    }
                }

            }

        }
    }
    Component.onCompleted: {
        for(var i = 0; i < 3; ++i){
            id_status_model.append({
                                       "isCompledted" : 0 // 0未完成 1 完成
                                   })
        }
    }
}
