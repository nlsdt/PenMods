import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./components"

YPage {
    id: id_spell_page
    objectName: "YPage===YSpellPage.qml"

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            soundCenter.suspend()
            spellManager.enableReply = true
            backButtonClicked()
        }
        YIconButton {
            id: id_replay_button_bg
            implicitWidth: 44
            implicitHeight: 44
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 16
            enabled: spellManager.enableReply
            iconSourceSize: Qt.size(36, 36)
            icon: "/spell/replay"
            radius: 22
            mouseAreaMargins: -5
            onClicked: {
                spellManager.reset();
                //spellManager.replay();
                id_delay_timer.start()
                logManager.sendHttpLog("action=detail_add_spell_again_click")
            }
        }
    }
    Item {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: id_title_bar.right
        anchors.right: parent.right
        YImage {
            id: id_spell_bg
            anchors.centerIn: parent
            sourceSize: Qt.size(600, 100)
            imageName: spellManager.content.length < 30 ? "spell/bg" : "spell/largebg"
        }
        YText {
            id: id_content_label
            anchors.topMargin: -10
            font.family: fontManager.fontFamilyPinyin
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -5
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: spellManager.content.length < 30 ? 56 : 42
            textFormat: YText.RichText
            font.weight: Font.DemiBold
            text: spellManager.richContent
        }
    }


    Component.onCompleted: {
        spellManager.reset();
        id_delay_timer.start()
    }
    YTimer {
        id: id_delay_timer
        interval: 500
        objectName: "YSpellPage.qml_delay_timer"
        onTriggered: {
            spellManager.enableReply = false
            spellManager.reset();
            spellManager.replay();
        }
    }

    Component.onDestruction: {
        spellManager.enableReply = true
        soundCenter.suspend()
        console.log("YSpellPage.qml===Component.onDestruction===called")
    }


    onVisibleChanged: {
        if (visible) {
            //resultManager.queryEnPolyPhone(resultManager.currentQuery)
            qmlGlobal.currentPageIndex = YEnum.PageIndex.Spell
        }
    }
}
