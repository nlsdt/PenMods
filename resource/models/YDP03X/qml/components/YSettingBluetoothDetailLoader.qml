import QtQuick 2.12
import QtQuick.Layouts 1.15
import BaseQml 1.0
import com.youdao.pen 1.0
import "../components"
import "../i18n"
YLoader {
    id: id_connect_wifi_loader
    anchors.fill: parent

    property string devName: ""
    property string addrName: ""
    property var linkStatus: YEnum.LINKED
    property bool isDisconnectting: false
    signal callPositionViewAtBeginning()
    signal callback();
    sourceComponent:YBackgroundIgnoreMouseEvent {

        YVerticalTitleBar {
            anchors.left: parent.left
            anchors.leftMargin: -90
            onCallBack: {
                callback();
            }
        }
        Item {
            id: id_title_bar
            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: 80

            YText {
                font.pixelSize: 26
                color: YColors.grayText
                anchors.verticalCenter: parent.verticalCenter
                text: YTranslateText.configBluetooth
            }
        }

        YSettingItemBackground {
            id: id_connect_wifi_item
            implicitHeight: 80
            anchors.top: id_title_bar.bottom

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 34
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                YTextMedium {
                    text: devName
                    anchors.left: parent.left
                    anchors.right: parent.right
                    elide: YText.ElideRight
                }
                YText {
                    font.pixelSize: 24
                    color: YColors.grayText
                    text: linkStatus === YEnum.LINKED ? YTranslateText.connectSuccess : YTranslateText.notconnet
                }
            }
//            YImage {
//                id: id_connect_wifi_icon
//                anchors.right: parent.right
//                anchors.rightMargin: 20
//                anchors.verticalCenter: parent.verticalCenter
//                sourceSize: Qt.size(44, 44)
//                imageName: "settings/st-check"
//            }
        }
        onClicked: {
            id_connect_wifi_loader.active = false
        }

        RowLayout
        {
         anchors.top: id_connect_wifi_item.bottom
         anchors.topMargin: 10
         width: parent.width -10
         height: 80
         //忽略
        YButton {
            visible:linkStatus === YEnum.LINKED ||  linkStatus === YEnum.UNLINK
            Layout.fillWidth: true
            Layout.minimumWidth:parent.width /2
            Layout.preferredWidth:parent.width /2
            Layout.maximumWidth: parent.width
            text: YTranslateText.ignoreThisDevice
            onClicked: {
                blueToothManager.ignore(addrName,devName)
                callback();
            }
        }
        //断开
        YButton {
           color:"lightgrey"
           visible:linkStatus === YEnum.LINKED
           Layout.minimumWidth:0
           Layout.preferredWidth:parent.width /2
           Layout.maximumWidth: parent.width/2
            text: "断开设备"  //YTranslateText.ignoreThisDevice
            onClicked: {
                   blueToothManager.disblueconnet(addrName,devName)
                  callback();
            }
        }
        }
    }

//    Connections {
//        target: blueToothManager
//        ignoreUnknownSignals: true
//        enabled: id_connect_wifi_loader.active
//        function onDisconnectFinished(addr, bSuc) {
//            if (addrName === addr) {
//                if (bSuc) {
//                    active = false
//                    callPositionViewAtBeginning()
//                }
//                isDisconnectting = false
//            }
//        }
//    }
}
