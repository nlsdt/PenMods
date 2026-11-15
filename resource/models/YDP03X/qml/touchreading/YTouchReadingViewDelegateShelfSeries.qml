import QtQuick 2.12

import BaseQml 1.0
import "../components"

YTouchReadingViewDelegateBase {
    id: id_delegate_item_root
    implicitWidth: 298
    delegateItem: id_delegate_item

    signal clicked(bool isEidt)

    Rectangle {
        id: id_delegate_item
        implicitWidth: 268
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        radius: 24
        color: "#3E494A70"

        Item {
            implicitWidth: 196
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            YOpacityMaskImage {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 18
                width: 136
                height: 136
                source: model.modelData.coverLocal.toLoadFileUrl()

                YTextMedium {
                    width: 178
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.bottom
                    font.pixelSize: 22
                    lineHeight: 26
                    lineHeightMode: YTextMedium.FixedHeight
                    maximumLineCount: 2
                    wrapMode: YTextMedium.Wrap
                    horizontalAlignment: YTextMedium.AlignHCenter
                    text: model.modelData.title
                    font.family: fontManager.fontFamilyZhCn
                    elide: YTextMedium.ElideRight
                }
            }
        }

        YMouseArea {
            id: id_shelf_view_button
            anchors.fill: parent
            onClicked: {
                id_delegate_item_root.clicked(false)
            }
            objectName: "id_shelf_series_delegate_shelf_view_bg"
        }

        YImage {
            anchors.top: parent.top
            anchors.right: parent.right
            sourceSize: Qt.size(72, 80)
            imageName: "touchreading/shelf_edit_bg"
            opacity: id_shelf_edit_button.pressed ? 0.6 : 1

            YMouseArea {
                id: id_shelf_edit_button
                anchors.fill: parent
                onClicked: {
                    id_delegate_item_root.clicked(true)
                }
                objectName: "id_shelf_series_delegate_shelf_edit_bg"
            }

            YImage {
                anchors.centerIn: parent
                sourceSize: Qt.size(36, 36)
                imageName: "touchreading/shelf_edit"
            }
        }

        YImage {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            sourceSize: Qt.size(72, 146)
            imageName: "touchreading/shelf_view_bg"
            opacity: id_shelf_view_button.pressed ? 0.6 : 1

            YImage {
                anchors.centerIn: parent
                sourceSize: Qt.size(36, 36)
                imageName: "touchreading/shelf_view"
            }
        }

    }
}
