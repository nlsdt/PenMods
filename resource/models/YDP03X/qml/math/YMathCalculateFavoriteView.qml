import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"
import "./YMathUtilities.js" as MathUtil

YBackButtonView {
    id: id_calc_favorite_view
    property bool isInEditing: false

    YIconButton {
        id: id_math_favorite_btn
        implicitWidth: 44
        implicitHeight: 44
        radius: 22
        anchors.horizontalCenter: id_calc_favorite_view.backBar.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        mouseAreaMargins: -20
        visible: id_list_view.count > 0
        icon: {
            if (id_calc_favorite_view.isInEditing) {
                return "math/fav-confirm"
            } else {
                return "math/fav-delete"
            }
        }
        iconSourceSize: Qt.size(36, 36)
        onClicked: {
            switchEditingMode()
        }
    }

    YBaseListView {
        id: id_list_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        spacing: 10

        model: mathManager.mathCalculateDB.favoriteListModel

        onMovingChanged: {
            if (!moving && atYEnd && mathManager.mathCalculateDB.hasMore) {
                mathManager.mathCalculateDB.loadMore()
            }
        }

        delegate: YMathFavoriteCell {
            width: id_list_view.width
            isInEditing: id_calc_favorite_view.isInEditing
            text: model.modelData.listOCRContent
            onCellDidClicked: {
                showQuestion(model.modelData)
            }
            onCellDeleteDidClicked: {
                deleteQuestion(model.modelData)
                loadMoreAfterDelete()
                logManager.sendHttpLog("action=math_errorbook_delete_click")
            }
        }

        header: Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: {
                let topMargin = 25
                let textHeight = 34
                let bottomMargin = 23
                return topMargin + textHeight + bottomMargin
            }
            color: YColors.black
            YText {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 26
                horizontalAlignment: YText.AlignLeft
                color: YColors.grayText
                text: YTranslateText.mathProblemBook
            }
        }

        footer: YSpacing {
            width: id_list_view.width
            implicitHeight: 18
        }

        YText {
            id: id_empty_tip
            width: 386
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -20
            anchors.verticalCenterOffset: 20
            font.pixelSize: 28
            font.weight: Font.Medium
            color: YColors.white
            textFormat: YText.RichText
            wrapMode: YTextBase.Wrap
            horizontalAlignment: YText.AlignHCenter
            verticalAlignment: YText.AlignVCenter
            text: YTranslateText.mathCalculateFavEmpty
            visible: false
            YTimer {
                id: id_delay_check_empty_timer
                interval: 300
                repeat: false
                onTriggered: {
                    id_empty_tip.visible = Qt.binding(function(){
                        return id_list_view.count === 0
                    })
                }
            }
        }
    }

    YLoader {
        id: id_result_view
        anchors.fill: parent
        asynchronous: false
        sourceComponent: YMathCalculateResultView {
            yModel: mathManager.mathCalculateDB.showModel
            onBackButtonClicked: {
                closeQuestionView()
            }
        }
    }


    Component.onCompleted: {
        mathManager.mathCalculateDB.loadMore()
        id_delay_check_empty_timer.start()
    }

    Component.onDestruction: {
        mathManager.mathCalculateDB.wipeData()
    }

    function switchEditingMode() {
        id_calc_favorite_view.isInEditing = !id_calc_favorite_view.isInEditing
    }

    function deleteQuestion(quesModel) {
        if (quesModel === null) { return }
        mathManager.mathCalculateDB.markRemoveItem(quesModel.ocrContent)
    }

    function loadMoreAfterDelete() {
        let loadThreshold = 5
        if (id_list_view.count >= loadThreshold)  { return }
        if (!mathManager.mathCalculateDB.hasMore) { return }
        mathManager.mathCalculateDB.loadMore()
    }

    function showQuestion(quesModel) {
        if (quesModel === null) { return }
        let result = mathManager.mathCalculateDB.prepareShow(quesModel)
        if (!result) { return }
        MathUtil.showView(id_result_view)
    }

    function closeQuestionView() {
        MathUtil.closeView(id_result_view)
    }
}
