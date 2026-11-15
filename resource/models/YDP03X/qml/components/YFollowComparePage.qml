import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import BaseQml 1.0
import "../i18n"
YPage {
    anchors.fill: parent
    property bool autoClose: false
    property int status_value: 0 // 0无变化 1 有提高 2 下滑
    property string c_word: ""
    property string c_pronunciation: ""
    property int c_oldScore: 0
    property int c_newScore: 0
    YIconButton {
        id: id_close_button
        implicitWidth: 44
        implicitHeight: 44
        radius: height/2
        color: YColors.grayNormal
        mouseAreaMargins: -22
        imageName: "commons/close"
        anchors.top: parent.top
        anchors.topMargin: 18
        anchors.left: parent.left
        anchors.leftMargin: 16
        visible: !autoClose
        z: 100
        onClicked: {
            backButtonClicked()
        }
    }
    function setResultsData(word, pronunciation, oldScore, newScore, isAutoClose){
        c_word = word
        c_pronunciation = pronunciation
        c_oldScore = oldScore
        c_newScore = newScore
        autoClose = isAutoClose
        if(oldScore === newScore) status_value = 0
        else if(oldScore < newScore) status_value = 1
        else if(oldScore > newScore) status_value = 2
        if(autoClose){
            id_countDown.start()
        }
    }

    onStatus_valueChanged: {
        switch (status_value){
        case 0: // 无变化
            id_old_score.y = id_new_score.y = 40
            break
        case 1: // 有提高
            id_old_score.y = 40
            id_new_score.y = 0
            break
        default: //下滑
            id_old_score.y = 0
            id_new_score.y = 40
        }
    }

    Row {
        anchors.fill: parent
        Rectangle {
            width: parent.width / 2
            height: parent.height
            color: "transparent"
            Item {
                width: parent.width
                height: 85
                anchors.verticalCenter: parent.verticalCenter

                YText {
                    id: id_symbol_word
                    font.family: "Nunito Sans"
                    width: parent.width
                    height: 50
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment  : Text.AlignHCenter
                    font.pixelSize: {
                        if(c_word.length > followManager.getWordLength()) return 30
                        return 50
                    }
                    font.bold: true
                    color: "#FFFFFF"
                    text: c_word
                }
                YText {
                    id: id_symbol_phonetic
                    font.family: "Nunito Sans"
                    anchors.top:id_symbol_word.bottom
                    anchors.topMargin: {
                        if(c_pronunciation.length > followManager.getWordLength()) return 50
                        return 5
                    }
                    width: parent.width
                    height: 30
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment  : Text.AlignHCenter
                    font.pixelSize: 30
                    color: "#878A99"
                    text: c_pronunciation
                }
            }
        }

        Rectangle {
            width: parent.width / 2
            height: parent.height
            color: "transparent"

            Rectangle {
                width: 185
                height: 150
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: id_status_tips.top
                color: "transparent"
                YText {
                    id: id_old_score
                    font.family: "Poppins"
                    height: 50
                    width: 64
                    x: -12
                    y: -50
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment  : Text.AlignHCenter
                    font.pixelSize: 50
                    font.bold: true
                    font.italic: true
                    color: "#215D7E"
                    text: c_oldScore
                    opacity: 0.3
                }

                YText {
                    id: id_new_score
                    font.family: "Poppins"
                    height: 50
                    width: 64
                    x: parent.width - width + 10
                    y: -50
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment  : Text.AlignHCenter
                    font.pixelSize: 50
                    font.bold: true
                    font.italic: true
                    color: "#215D7E"
                    text: c_newScore
                }

                YImage {
                    id: id_medal_image
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: 185
                    height: 150
                    sourceSize: Qt.size(width, height)
                    imageName: {
                        switch (status_value){
                        case 0:
                            return "dict/follow_score_nochanged_icon"
                        case 1:
                            return "dict/follow_score_up_icon"
                        default:
                            return "dict/follow_score_down_icon"
                        }
                    }
                    fillMode: Image.PreserveAspectFit
                }
            }

            YText {
                id: id_status_tips
                font.family: "HarmonyOS Sans SC"
                anchors.bottom:parent.bottom
                anchors.bottomMargin: 24
                width: parent.width
                height: 30
                style: Text.Outline
                styleColor: "#1B79AB"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment  : Text.AlignHCenter
                font.pixelSize: 30
                font.bold: true
                color: "#FFFFFF"
                text: {
                    switch (status_value){
                    case 0:
                        return "表现不错，继续努力！"
                    case 1:
                        return "口语达标，你太厉害了！"
                    default:
                        return "还有提升空间，加油！"
                    }
                }
            }
        }
    }

    Timer {
        id:id_countDown;
        interval: 3000
        repeat: false
        onTriggered: {
            backButtonClicked()
        }
    }
    Connections {
        target: systemBase
        ignoreUnknownSignals: true
        //enabled: id_dict_page.visible
        function onOcrStart() {
//            back()
        }
        function onOcrStop(scanType) {
            backButtonClicked()
        }

        function onHomeKeyPress() {
            backButtonClicked()
        }
    }
}
