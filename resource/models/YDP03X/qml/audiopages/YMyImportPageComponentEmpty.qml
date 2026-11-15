import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    id: id_container_index

    YBackground {
        anchors.fill: parent
        anchors.leftMargin: 90
    }

    YText {
        anchors.top: parent.top
        anchors.topMargin: 22
        anchors.left: parent.left
        anchors.leftMargin: 90
        anchors.right: parent.right
        anchors.rightMargin: 250
        font.family: fontManager.fontFamilyZhCn
        font.pixelSize: {
            switch (settingManager.uiLanguage) {
            case YEnum.EN_US:
                return 26
            }
            return 28
        }
        wrapMode: YText.Wrap
        text: YTranslateText.myImportAudiosTip
    }

    YTextBase {
        id: id_tip_1
        anchors.left: parent.left
        anchors.leftMargin: 90
        anchors.right: parent.right
        anchors.rightMargin: 250
        anchors.bottom: id_tip_2.top
        anchors.bottomMargin: {
            switch (settingManager.uiLanguage) {
            case YEnum.EN_US:
                return 6
            }
            return 10
        }
        font.family: fontManager.fontFamilyZhCn
        wrapMode: YTextBase.Wrap
        color: YColors.grayText
        font.pixelSize: 24
        text: YTranslateText.myImportAudiosFormat
    }

    YTextBase {
        id: id_tip_2
        anchors.left: parent.left
        anchors.leftMargin: 90
        anchors.right: parent.right
        anchors.rightMargin: 250
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 22
        font.family: fontManager.fontFamilyZhCn
        wrapMode: YTextBase.Wrap
        color: YColors.grayText
        font.pixelSize: 24
        text: YTranslateText.myImportAudiosQrCodeTip
    }

    Rectangle {
        id: id_qr_code_bg
        implicitWidth: 214
        implicitHeight: 214
        radius: 16
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter

        YImage {
            id: iid_qr_code_icon
            anchors.centerIn: parent
            sourceSize: Qt.size(200, 200)
            imageName: "audioplayer/audioplayer_import_qr"
        }
    }
}
