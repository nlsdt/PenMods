import QtQuick 2.12

import BaseQml 1.0
import "../components"
import "../i18n"
YDictTypeBase {
    title: YTranslateText.dtYoudaoTras


    Connections {
        target: resultManager
        ignoreUnknownSignals: true
        onOnlineResultsChanged: {
            console.log("seven:onOnlineResultsChanged:",hasResults)
            id_yd_buttons_grid.visible = hasResults
        }
    }
    Item {
        width: parent.width
        height: id_yd_nettans_colum.height
        Column{
            id: id_yd_nettans_colum
            width: parent.width
            Row {
                id: id_yd_buttons_grid
                width: parent.width
                spacing: 20
                visible: !isFirstDict //!settingManager.onlineSearchWordsSwitch()//false
                function autoPlay() {
                    play(true, true)
                }

                function play(isOrg, isAutoPlay) {
                    if (isOrg) {
                        if (id_yd_sound_tar.playing) {
                            id_yd_sound_tar.stop()
                        }
                        if (isAutoPlay)
                            id_yd_sound_org.autoplay()
                        else
                            id_yd_sound_org.play()
                    } else {
                        if (id_yd_sound_org.playing) {
                            id_yd_sound_org.stop()
                        }
                        if (isAutoPlay)
                            id_yd_sound_tar.autoplay()
                        else
                            id_yd_sound_tar.play()
                    }
                }

                YAudioPlayIconLabelButton {
                    id: id_yd_sound_org
                    textFontFamily: fontManager.fontFamily
                    textFormat: YText.PlainText
                    text: YTranslateText.original
                    onValidClicked: {
                        if (playing) {
                            id_yd_buttons_grid.play(true, false)
                            qmlGlobal.soundSentence()
                            logManager.sendHttpLog("action=detail_trans_origin_pronounce_click");
                        }
                    }

                    Component.onCompleted: {
                        autoPlay()
                    }
                }

                YAudioPlayIconLabelButton {
                    id: id_yd_sound_tar
                    textFontFamily: fontManager.fontFamily
                    textFormat: YText.PlainText
                    text: YTranslateText.translation
                    onValidClicked: {
                        if (playing) {
                            id_yd_buttons_grid.play(false, false)
                            qmlGlobal.soundSentence(content)
                            logManager.sendHttpLog("action=detail_trans_pronounce_click");
                        }
                    }
                }


            }

            YSpacingForColumn{
                height: 18
                visible: id_yd_buttons_grid.visible
            }

            YTextMedium {
                id: id_dict_content
                wrapMode: YText.Wrap
                width : parent.width
                height: id_dict_content.contentHeight
                lineHeightMode: Text.FixedHeight
                lineHeight: 40
                text: content
                onTextChanged: {
                    font.family = qmlGlobal.getFontFamilyNameByLangName(resultManager.dstLang)
                }
            }
        }
    }


}
