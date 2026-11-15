import QtQuick 2.12

import BaseQml 1.0
import "../components"

YTouchReadingViewDelegateBase {
    id: id_delegate_item_root
    implicitWidth: 204
    delegateItem: id_delegate_item

    signal clicked()

    YMouseArea {
        id: id_delegate_item_button
        anchors.fill: parent
        onClicked: {
            id_delegate_item_root.clicked()
        }
        objectName: "ContentShelfSeriesViewItem.qml_id_store_series_delegate"
    }

    YOpacityMaskImage {
        id: id_delegate_item
        implicitWidth: 164
        implicitHeight: 164
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        source: model.modelData.coverLocal.toLoadFileUrl()

        YBlurMaskProgressBar {
            id: id_progress_bg
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            implicitHeight: 28
            sourceItem: id_delegate_item.imageItem
            sourceRect: Qt.rect(0, id_delegate_item.height - height, width, height)
            progress: model.modelData.progress
            text: {
                switch (model.modelData.progress) {
                case 100:
                    return ""
                default:
                    return ("%1%").arg(model.modelData.progress)
                }
            }
        }

        YImage {
            anchors.centerIn: id_progress_bg
            visible: (100 === model.modelData.progress)
            sourceSize: Qt.size(28, 30)
            imageName: visible ? "touchreading/download_finished" : ""
        }
    }

    YTextMedium {
        font.pixelSize: 22
        maximumLineCount: 2
        width: 170
        lineHeight: 22
        lineHeightMode: YText.FixedHeight
        wrapMode: YText.Wrap
        horizontalAlignment: YText.AlignHCenter
        text: model.modelData.title
        elide: YText.ElideRight
        anchors.top: id_delegate_item.bottom
        anchors.topMargin: 8
        font.family: fontManager.fontFamilyZhCn
    }
}
