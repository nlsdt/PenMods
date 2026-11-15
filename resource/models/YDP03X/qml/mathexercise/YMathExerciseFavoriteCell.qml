import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

Item {
    id: id_favorite_cell
    anchors.left: parent.left
//    anchors.right: parent.right
//    anchors.fill: parent
    width: 694
    height: 120
    state: isInEditing ? "edit" : "normal"

    property var contentModel: null
    property bool isInEditing: false
    property bool isNewContent: contentModel.isNewContent   //todo

    signal cellDidClicked()
    signal cellDeleteDidClicked()

    onContentModelChanged: {
        console.warn("****** id_favorite_cell onContentModelChanged" + JSON.stringify(contentModel))
    }

    Rectangle {
        id: id_bg_rect
        anchors.fill: parent
        radius: 16
        color: YColors.grayNormal

        Rectangle {
            id: id_new_tip_icon
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            height: 12
            width: 12
            radius: 30
            visible: isNewContent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#FF6D1A" }
                GradientStop { position: 1.0; color: "#FF961A" }
            }
        }

        YText {
            id: id_fav_title_text
            anchors.left: parent.left
            anchors.leftMargin: isNewContent ? 54 : 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 20
            elide: Text.ElideRight
            height: 37
            horizontalAlignment : YText.AlignLeft
            verticalAlignment: YText.AlignVCenter
//            opacity: 1
            text: contentModel.quesText.replace(/\n/g, "")
        }

        Row {
            id: id_label_row
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.left: id_fav_title_text.left
            anchors.right: id_date_text.left
            anchors.rightMargin: 42
            spacing: 12
            height: 34

            Item {
                id: id_source_label
                visible: (typeof contentModel.quesSource === "string")
                         && contentModel.quesSource === "HWAladdin"
                width: 222
                height: 34
                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "#0ABCB0"
                    opacity: 0.1
                }

                YTextBase {
                    anchors.centerIn: parent
                    font.pixelSize: 22
                    height: 29
                    color: "#0ABCB0"
                    text: "来自有道智能学习灯"
                }
            }

            YTextBase {
                anchors.verticalCenter: id_label_row.verticalCenter
                font.pixelSize: 22
                width: id_source_label.visible ? id_label_row.width - id_source_label.width : id_label_row.width
                height: 29
                color: "#A8AAB3"
                horizontalAlignment : YText.AlignLeft
                verticalAlignment: YText.AlignVCenter
                elide: Text.ElideRight
                visible: text !== ""
                text: {
                    var ret = ""
                    for (var i = 0; i < contentModel.quesLabels.length; i++) {
                        if (i !== 0) ret += " / "
                        ret = ret + contentModel.quesLabels[i]
                    }
                    return ret
                }
            }

        }

        YTextBase {
            id: id_date_text
            anchors.top: id_fav_title_text.bottom
            anchors.topMargin: 12
            anchors.right: id_fav_title_text.right
            font.pixelSize: 22
            height: 33
            color: "#A8AAB3"
            text: contentModel.createTime//"2022-2-10"
        }

        YMouseArea {
            anchors.fill: parent
            onClicked:  {
                if (id_favorite_cell.isInEditing) { return }
                cellDidClicked()
            }
        }
    }

    YIconButton {
        id: id_delete_btn
        implicitWidth: 36
        implicitHeight: 36
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        mouseAreaMargins: -20
        iconSourceSize: Qt.size(36, 36)
        icon: "math/fav-item-delete"
        visible: id_favorite_cell.isInEditing
        onClicked: {
            cellDeleteDidClicked()
        }
    }

    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: id_fav_title_text
                opacity: 1
                anchors.rightMargin: 20
            }

            PropertyChanges {
                target: id_bg_rect
                opacity: 1
            }
        },
        State {
            name: "edit"
            PropertyChanges {
                target: id_fav_title_text
                opacity: 0.6
                anchors.rightMargin: 94
            }
            PropertyChanges {
                target: id_bg_rect
                opacity: 0.6
            }
        }
    ]
}
