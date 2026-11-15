import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

import "../components"
import "../i18n"

YSettingItemPage {
    id: id_setting_page
    objectName: "YPage===YSettingHomePage.qml"
    property int currentShowIndex: -1
    function showSettingPage(settingPage) {
        id_pop_container.show(settingPage)
    }

    Flickable {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: {
            var height = 80 + id_setting_gridview.height + 36
            return height
        }

        YSettingItemTitle {
            id: id_title_containerr
            title: YTranslateText.selectfeatureSetting
        }
        Flow {
            id: id_setting_gridview
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: id_title_containerr.bottom
            spacing: 12

            Repeater {
                model: id_setting_model
                Rectangle {
                    id: id_item_delegate
                    objectName: "YSettingPage.qml_delegate_index" + index
                    width: 341
                    height: 76
                    color: YColors.grayNormal
                    radius: 12
                    YSettingSwitchItem {
                        id: id_switch_state_button_rect
                        implicitHeight: 76
                        anchors.fill: parent
                        title: hometext
                        interval: 0
                        switchOn: settingManager.readhomepagesettings(pageindex)
                        onTimerTriggered: {
                            settingManager.sethomepagesettings(pageindex,id_switch_state_button_rect.switchOn);
                            qmlGlobal.sethidehomeItem(pageindex,id_switch_state_button_rect.switchOn);
                            console.log("7777777777777777777777",pageindex,id_switch_state_button_rect.switchOn)
                        }
                    }

                }

            }
        }

    }


    ListModel {
        id: id_setting_model

        Component.onCompleted: {
            append({hometext: YTranslateText.textbookSynchronous, pageindex: YEnum.ParentsControlList.TextBook}) //教材同步
            append({hometext: YTranslateText.article,             pageindex: YEnum.ParentsControlList.Article}) //写作指导
            append({hometext: YTranslateText.mathExercise,        pageindex: YEnum.ParentsControlList.MathTutor}) //AI好题本
            append({hometext: YTranslateText.mathCalculate,       pageindex: YEnum.ParentsControlList.Math}) //口算批改
            if (qmlGlobal.checkFeature(YEnum.FEATURE_OID))
            append({hometext: YTranslateText.touchreading,        pageindex: YEnum.ParentsControlList.Reading}) //图书点读
            append({hometext: YTranslateText.ximalaya,            pageindex: YEnum.ParentsControlList.CooXmly}) //喜马拉雅
            append({hometext: YTranslateText.textbookGuidListen,  pageindex: YEnum.ParentsControlList.Audioplayer}) //听力练习

        }
    }
    Component.onDestruction: {
        console.log("YSettingPage.qml===Component.onDestruction===called")
    }

}
