import QtQuick 2.12
import com.youdao.pen 1.0
import QtGraphicalEffects 1.14

import BaseQml 1.0
import "../i18n"

Item {
    id: id_math_exercise_page_fav_loader
    anchors.fill: parent

    property string filter: ""
    property bool isInEditing: false
    property int currentTab: 0

    function switchEditingMode() {
        id_math_exercise_page_fav_loader.isInEditing = !id_math_exercise_page_fav_loader.isInEditing
    }

    YVerticalTitleBar {

        onCallBack: {
            showSubPage(YEnum.Mathexercise_Home, false)
        }

        YIconButton {
            id: id_math_exercise_filter_btn
            implicitWidth: 44
            implicitHeight: 44
            radius: 16
            anchors.left: id_math_exercise_delete_btn.left
            anchors.bottom: id_math_exercise_delete_btn.top
            anchors.bottomMargin: 43
            mouseAreaMargins: -20
            visible: mathManager.mathExerciseDB.tabType === YEnum.MTT_Favorite
            icon: "commons/more"
            iconSourceSize: Qt.size(36, 36)
            onClicked: {
                id_label_select_drawer_layer.show()
                logManager.sendHttpLog("action=math_goodbook_filt_click")
            }
        }

        YIconButton {
            id: id_math_exercise_delete_btn
            implicitWidth: 44
            implicitHeight: 44
            radius: 16
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            mouseAreaMargins: -20
            visible: mathManager.mathExerciseDB.tabType === YEnum.MTT_Favorite
                     && (id_fav_list_view.count !== 0)
            icon: id_math_exercise_page_fav_loader.isInEditing ? "math/fav-confirm" : "math/fav-delete"
            iconSourceSize: Qt.size(36, 36)
            onClicked: {
                if (id_math_exercise_page_fav_loader.isInEditing) {
                    logManager.sendHttpLog("action=math_goodbook_delete_click")
                }
                switchEditingMode()
            }
        }
    }

    YBaseListView {
        id: id_fav_list_view
        anchors.fill: parent
        anchors.leftMargin: 90
        clip: true
        spacing: 10

        cacheBuffer: 1000
        boundsBehavior: (0 === count) ? ListView.StopAtBounds : ListView.DragAndOvershootBounds

        property alias busyingInterval: id_delay_empty_tip_timer.interval
        readonly property alias busying: id_delay_empty_tip_timer.running
        readonly property alias empty: id_delay_empty_tip_timer.empty

        onMovingChanged: {
            if (!moving && atYEnd && mathManager.mathExerciseDB.hasMore) {
                mathManager.mathExerciseDB.loadMore(filter)
            }
        }

        onCountChanged: {
            if (0 === count) {
                id_delay_empty_tip_timer.restart()
                id_math_exercise_page_fav_loader.isInEditing = false
            } else {
                id_delay_empty_tip_timer.stop()
                id_delay_empty_tip_timer.empty = false
            }
        }

        model: mathManager.mathExerciseDB.tabType === 0
               ?  mathManager.mathExerciseDB.favoriteListModel
               :  mathManager.mathExerciseDB.knowledgeListModel

        delegate: {
            if (mathManager.mathExerciseDB.tabType === 0) {
                return id_question_list_view_component
            } else {
                return id_knowledge_list_view_component
            }
        }

        YTimer {
            id: id_delay_empty_tip_timer
            property bool empty: (0 === count)
            interval: 360
            repeat: false
            objectName: "YBaseListView.qml_id_delay_empty_tip_timer"
            onTriggered: {
                empty = true
            }
        }

        header: id_list_view_header_component

        footer: YSpacing {
            width: id_fav_list_view.width
            implicitHeight: 18
        }

        YText {
            id: id_empty_tip
            width: paintedWidth
            height: 40
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 0
            anchors.verticalCenterOffset: 13
            font.pixelSize: 30
            font.weight: Font.Medium
            color: YColors.white
            horizontalAlignment: YText.AlignHCenter
            verticalAlignment: YText.AlignVCenter
            text: (mathManager.mathExerciseDB.tabType === 0) ?
                      YTranslateText.mathExerciseFavEmpty : YTranslateText.mathExerciseKnowEmpty
            visible: false

            YTimer {
                id: id_delay_check_empty_timer
                interval: 300
                repeat: false
                onTriggered: {
                    id_empty_tip.visible = Qt.binding(function(){
                        return id_fav_list_view.count === 0
                    })
                }
            }
        }
    }

    YLoader {
        id: id_know_view_loader
        anchors.fill: parent
        asynchronous: false
        sourceComponent: YMathExerciseKnowledge {
            resultModel: mathManager.mathExerciseDB.knowShowModel
            onBackButtonClicked: {
                id_know_view_loader.active = false
            }
        }
    }

    Component.onCompleted: {
        mathManager.mathExerciseDB.loadMore()
        id_delay_check_empty_timer.start()
    }

    Component.onDestruction: {
        mathManager.mathExerciseDB.wipeData(true)
    }

    Component {
        id: id_list_view_header_component

        Item {
            id: id_title_bar
            width: ListView.view.width
            implicitHeight: 80

            YTabsTitleBar {
                id: id_tab_title_bar
                anchors.top: id_title_bar.top
                anchors.topMargin: 24
                anchors.left: id_title_bar.left
                namesArray: [YTranslateText.mathGoodProblemBook, YTranslateText.mathPointsList]

                onCurrentIndexChanged: {
                    id_math_exercise_page_fav_loader.isInEditing = false
                    updateUI()
                    id_delay_check_empty_timer.restart()
                }

                function updateUI() {
                    mathManager.mathExerciseDB.tabType = currentIndex
                }

                Component.onCompleted: {
                    updateUI()
                }
            }
        }
    }

    Component {
        id: id_question_list_view_component

        YMathExerciseFavoriteCell {
            contentModel: model.modelData
            isInEditing: id_math_exercise_page_fav_loader.isInEditing

            onCellDidClicked: {
                let result = mathManager.mathExerciseDB.prepareShow(model.modelData)
                if (!result) { return }
                entryFavResult()
                isNewContent = false
                logManager.sendHttpLog("action=math_goodbook_quest_click")
            }

            onCellDeleteDidClicked: {
                mathExerciseManager.deleteFromFavorites(model.modelData.questionCode)
            }
        }
    }

    Component {
        id: id_knowledge_list_view_component

        Item {
            anchors.left: parent.left
            width: 690
            height: 76

            Rectangle {
                anchors.fill: parent
                radius: 16
                color: YColors.grayNormal

                YText {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    height: 32
                    horizontalAlignment : YText.AlignLeft
                    verticalAlignment: YText.AlignVCenter
                    text: model.modelData.title
                }

                YMouseArea {
                    anchors.fill: parent
                    onClicked:  {
                        let result = mathManager.mathExerciseDB.prepareShowKnowledge(model.modelData)
                        if (!result) { return }
                        entryKnowledge()
                        logManager.sendHttpLog("action=math_list_know_click")
                    }
                }
            }
        }
    }

    YMathExerciseFilterDrawerLayer {
        id: id_label_select_drawer_layer
        visible: true

        onFilterChanged: {
            filter = filterString
            mathManager.mathExerciseDB.reload(filter)
        }
    }
}
