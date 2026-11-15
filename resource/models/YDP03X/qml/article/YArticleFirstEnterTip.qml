import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YBackground {
    id: id_article_first_enter_tip
    objectName: "YArticleFirstEnterTip.qml"
    anchors.fill: parent
    visible: false

    function show() {
        visible = true
    }

    signal backButtonClicked()
    signal closed()

    YButtonBaseMouseArea {
        onValidClicked: {
            if (1 === id_guide_image.index) {
                id_guide_image.index += 1
            } else {
                settingManager.setNotIsFirstEnterArticlePage()
                closed()
            }
        }
    }

    YImage {
        id: id_guide_image
        property int index: 1
        sourceSize: Qt.size(800, 254)
        imageName: "article/guide_01"
        visible: 1 === id_guide_image.index
    }

    YImage {
        sourceSize: Qt.size(800, 254)
        imageName: "article/guide_02"
        visible: 2 === id_guide_image.index
    }

    YButtonBaseMouseArea {
        anchors.fill: undefined
        implicitWidth: 80
        implicitHeight: 80
        onValidClicked: {
            if (2 === id_guide_image.index) {
                id_guide_image.index -= 1
            } else if (1 === id_guide_image.index) {
                backButtonClicked()
            }
        }
    }
}
