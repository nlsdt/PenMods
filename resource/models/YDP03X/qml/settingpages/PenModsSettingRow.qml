import QtQuick 2.12
import BaseQml 1.0
import "../common"
import "../components"

YSettingItemBackground {
    id: row
    property string title: ""
    property string value: ""
    property string description: ""
    property bool checked: false
    property bool showSwitch: false
    property bool interactive: true
    readonly property bool pressed: hitArea.pressed
    signal clicked()

    implicitHeight: Math.max(76, labels.height + 32)
    opacity: !enabled ? 0.6 : pressed ? 0.85 : 1
    scale: pressed ? 0.99 : 1
    Behavior on opacity { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

    Column {
        id: labels
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: row.showSwitch ? 120
                           : valueLabel.visible ? valueLabel.width + valueLabel.anchors.rightMargin + 20
                           : indicator.visible ? 76 : 20
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        YTextMedium {
            width: parent.width
            text: row.title
            color: YColors.white
            font.pixelSize: 28
            elide: Text.ElideRight
        }
        YText {
            width: parent.width
            visible: text.length > 0
            text: row.description
            color: YColors.grayText
            font.pixelSize: 24
            wrapMode: Text.Wrap
        }
    }
    YTextMedium {
        id: valueLabel
        anchors.right: parent.right
        anchors.rightMargin: indicator.visible ? 64 : 20
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, row.width * 0.4)
        visible: !row.showSwitch && text !== ""
        text: row.value
        color: YColors.grayText
        font.pixelSize: 26
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideLeft
    }
    YImage {
        id: indicator
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        sourceSize: Qt.size(36, 36)
        imageName: row.checked ? "textbook/select-check" : "settings/info_more_arrow"
        visible: !row.showSwitch && (row.checked || row.interactive)
    }
    YSwitch {
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        visible: row.showSwitch
        switchOn: row.checked
    }
    YMouseArea { id: hitArea; anchors.fill: parent; enabled: row.interactive; onClicked: row.clicked() }
}
