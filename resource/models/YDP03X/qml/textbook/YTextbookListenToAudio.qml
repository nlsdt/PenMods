import QtQuick 2.0
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    id: id_textbook_listentoaudio_page
    objectName: "YPage===YTextbookListenToAudio.qml"

    property alias model: id_textbook_listentoaudio_page_column_view.model
    property string bookId: settingManager.studyingBookId

    Item {
        anchors.fill: parent
        YTextbookListenToAudioColumnView {
            id: id_textbook_listentoaudio_page_column_view
            anchors.fill: parent
            anchors.leftMargin: 90
            anchors.rightMargin: 16

            readonly property bool editing: false
        }
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            textBookBlockManager.wipeData()
            showSubPage(YEnum.Textbook_Home, true)
        }

        YIconButton {
            id: id_more_button_bg
            enabled: id_textbook_page.isSelectEnabled
            implicitWidth: 44
            implicitHeight: 44
            mouseAreaMargins: -18
            radius: height/2
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            sourceSize: Qt.size(36, 36)
            imageName: "textbook/switch"
            onClicked: {
                showSubPage(YEnum.Textbook_MyTextbook, true)
            }
        }
    } // YVerticalTitleBar

    YTextbookListenToAudioFilterDrawerLayer {
        id: id_textbook_home_filter_drawer_layer
        onFilterChanged: {
            console.warn("YTextbookListenToAudioColumnView.qml===YTextbookListenToAudioFilterDrawerLayer===onFilterChanged:", filterString)
            textBookBlockManager.entryBook(bookId, filterString)
        }
    }

    Component.onCompleted: {
        textBookBlockManager.entryBook(bookId)
    }

//    onBackButtonClicked: {
//        textBookBlockManager.wipeData()
//    }
}
