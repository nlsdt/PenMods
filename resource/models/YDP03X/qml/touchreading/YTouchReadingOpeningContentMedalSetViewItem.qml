import QtQuick 2.12

import BaseQml 1.0
import "../components"

YTouchReadingViewDelegateBase {
    id: id_delegate_item_root
    implicitWidth: 177
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

    Item {
        id: id_delegate_item_bg
        implicitWidth: 148
        implicitHeight: 141
        anchors.horizontalCenter: parent.horizontalCenter

        YOpacityMaskImage {
            id: id_delegate_item
            width: 136
            height: 136
            anchors.horizontalCenter: parent.horizontalCenter
            source: model.modelData.coverLocal.toLoadFileUrl()
        }
    }

    YLoader {
        anchors.left: id_delegate_item_bg.left
        anchors.right: id_delegate_item_bg.right
        anchors.bottom: id_delegate_item_bg.bottom
        active: true
        sourceComponent: YBlurMaskProgressBar {
            implicitHeight: 28
            progressGradient: Gradient {
                GradientStop { position: 0.0; color: "#FFB320" }
                GradientStop { position: 1.0; color: "#FF9C28" }
            }
            sourceRect: Qt.rect(0, id_delegate_item_bg.height - height, width, height)
            progress: parseInt(model.modelData.lightedMedalCount*100/model.modelData.totalMedalCount)
            text: ("%1/%2").arg(model.modelData.lightedMedalCount).arg(model.modelData.totalMedalCount)
        }
        onLoaded: {
            item.sourceItem = id_delegate_item_bg
        }
    }

    YTextMedium {
        font.pixelSize: 22
        maximumLineCount: 2
        width: 177
        lineHeight: 22
        lineHeightMode: Text.FixedHeight
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: model.modelData.title
        elide: Text.ElideRight
        anchors.top: id_delegate_item_bg.bottom
        anchors.topMargin: 10
        font.family: fontManager.fontFamilyZhCn
    }
}
