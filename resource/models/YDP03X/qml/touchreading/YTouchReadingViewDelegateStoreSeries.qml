import QtQuick 2.12

import BaseQml 1.0
import "../components"

YTouchReadingViewDelegateBase {
    id: id_delegate_item_root
    implicitWidth: 226
    delegateItem: id_delegate_item

    readonly property int downloadProgress: model.modelData.downloadProgress
    readonly property int downloadState: model.modelData.downloadState

    signal clicked()

    YMouseArea {
        id: id_delegate_item_button
        anchors.fill: parent
        onClicked: {
            id_delegate_item_root.clicked()
        }
        objectName: "YTouchReadingPageIndex.qml_id_store_series_delegate"
    }

    Rectangle {
        id: id_delegate_item
        implicitWidth: 196
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        opacity: id_delegate_item_button.pressed ? 0.6 : 1
        radius: 24
        color: "#3E494A70"

        YOpacityMaskImage {
            width: 136
            height: 136
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 18
            source: model.modelData.coverLocal.toLoadFileUrl()
        }

        YTextMedium {
            width: 180
            height: 44
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14
            font.pixelSize: 20
            lineHeight: 22
            lineHeightMode: YTextMedium.FixedHeight
            wrapMode: YTextMedium.Wrap
            horizontalAlignment: YTextMedium.AlignHCenter
            verticalAlignment: YTextMedium.AlignVCenter
            font.family: fontManager.fontFamilyZhCn
            text: model.modelData.title
            elide: YTextMedium.ElideRight
        }

        YLoader {
            active: model.modelData.isNew
            sourceComponent: YImage {
                sourceSize: Qt.size(64, 64)
                imageName: "touchreading/new"
            }
        }

    }
}
