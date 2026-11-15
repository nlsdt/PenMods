import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import BaseQml 1.0
import "../i18n"
Item {
    property alias medal_width : id_medal_image.width
    property alias mdeal_height: id_medal_image.height
    property alias mdeal_title_font: id_medal_title.font.pixelSize
    property alias mdeal_title_text: id_medal_title.text
    property alias mdeal_title_v_ofset: id_medal_title.anchors.verticalCenterOffset
    property alias mdeal_img_v_ofset: id_medal_image.anchors.verticalCenterOffset
    signal medalClick()
    Rectangle {
        id: id_medal_bg
        anchors.fill: parent
        color: "transparent"

        YImage {
            id: id_medal_image
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
//            width: parent.width//230
//            height: parent.height//230
            sourceSize: Qt.size(width, height)
            imageName: "dict/follow_medal"
            fillMode: Image.PreserveAspectFit
            Text {
                id: id_medal_title
                anchors.left: parent.left
                anchors.right: parent.right
                height: font.pixelSize
                anchors.verticalCenter: parent.verticalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment  : Text.AlignHCenter
                font.italic: true
                font.bold: true
                font.family: "Poppins"
                color: "#FFFFFF"
            }

        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                medalClick()
            }
        }
    }
}
