import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
    id: id_header_item
    width: 608
    height: Math.max(content_col.height, id_strokes_area.height)
    objectName: "YDictPageHeaderChChinese.qml"
    property string chCharacter: ""
    property bool strokesResultGot: false
    property bool isImagesExit: false
    property int strokeCount: 0
    property string structure: ""
    property string radical: ""
    signal headerSelectedPinYinChanged(var currentPinYin)
    function initValue() {
        chCharacter = ""
        strokesResultGot = false
        isImagesExit = false
        strokeCount = 0
        structure = ""
        radical = ""
    }

    Connections {
        target: strokeManager
        ignoreUnknownSignals: true
        function onImageListChanged() {
            strokesResultGot = true
            if (strokeManager.imageList.length > 0) {
                id_strokes_animation.frameCount = strokeManager.imageList.length
                id_strokes_animation.imageNameList = strokeManager.imageList
                isImagesExit = true
                id_strokes_animation.play()
            }
        }
    }

    YMouseArea {
        id: id_strokes_area
        anchors.left: parent.left
        width: 132
        height: 132

        YStrokesOrderView {
            id: id_strokes_animation
            objectName: "YStrokesOrderView.qml"
            frameSize: Qt.size(parent.width, parent.height)
            frameCount: 0
            frameDuration: 260
            visible: chinesAnimationBackGround.visible
            z: chinesAnimationBackGround.z + 1
        }

        YImage {
            id: chinesAnimationBackGround
            visible: isImagesExit
            anchors.centerIn: parent
            imageName: "dict/ch_mask"
            sourceSize: Qt.size(parent.width, parent.height)
        }

        YText {
            anchors.centerIn: parent
            font.family: fontManager.fontFamilyXinHuaXiHei
            visible: chinesGridBackGround.visible
            z: chinesGridBackGround.z + 1
            text: chCharacter
            font.pixelSize: 93
        }

        YImage {
            id: chinesGridBackGround
            anchors.centerIn: parent
            imageName: "dict/ch_grid"
            sourceSize: Qt.size(parent.width, parent.height)
            visible: strokesResultGot && !isImagesExit
        }

        onClicked: {
            if (isImagesExit) {
                id_strokes_animation.play()
            }
        }
    }

    YIconButton {
        id: id_strokes_play_button
        implicitWidth: 30
        implicitHeight: 30
        color: YColors.red
        mouseAreaMargins: -10
        radius: height/2
        anchors.right: id_strokes_area.right
        anchors.bottom: id_strokes_area.bottom
        sourceSize: Qt.size(30, 30)
        imageName: "dict/strokes-play"
        visible: isImagesExit && !id_strokes_animation.playing
        onClicked: {
            logManager.sendHttpLog("action=detail_strokes_click")
            id_strokes_animation.play()
        }
    }

    Flow {
        id: content_col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        property var isWrap: height > 37
        anchors.topMargin: isWrap ? 6 : 21
        anchors.leftMargin: 156
        //anchors.rightMargin: 0
        spacing: 1
        property var widthSpace:  25
        property var heightSpace:  isWrap ? 1 : 26

        Row {
            width: id_stoke_key .width + id_stroke_space.width + id_stroke_value.width + content_col.widthSpace
            visible: strokeCount !== 0
            YText {
                id: id_stoke_key
                width: settingManager.uiLanguage === YEnum.ZH_CN ? 64 : paintedWidth
                lineHeightMode: Text.FixedHeight
                lineHeight: 37
                font.pixelSize: 28
                color: YColors.grayText
                text: YTranslateText.stroke
            }

            Item {
                id: id_stroke_space
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 10
            }

            YText {
                id: id_stroke_value
                width: paintedWidth
                lineHeightMode: Text.FixedHeight
                lineHeight: 37
                font.pixelSize: 28
                color: YColors.white
                //wrapMode: YText.Wrap
                text: strokeCount
            }
        }

        Row {
            visible: structure !== ""
            width: id_structure_key .width + id_structure_space.width + id_structure_value.width + content_col.widthSpace
            YText {
                id: id_structure_key
                width: settingManager.uiLanguage === YEnum.ZH_CN ? 64 : paintedWidth
                lineHeightMode: Text.FixedHeight
                lineHeight: 37
                font.pixelSize: 28
                color: YColors.grayText
                text: YTranslateText.structure
            }

            Item {
                id: id_structure_space
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 10
            }

            YText {
                id: id_structure_value
                width: paintedWidth
                lineHeightMode: Text.FixedHeight
                lineHeight: 37
                font.pixelSize: 28
                color: YColors.white
                //wrapMode: YText.Wrap
                text: structure
            }
        }

        Row {
            visible: radical !== ""
             width: id_radical_key .width + id_radical_space.width + id_radical_value.width + content_col.widthSpace
            YText {
                id: id_radical_key
                width: settingManager.uiLanguage === YEnum.ZH_CN ? 64 : paintedWidth
                lineHeightMode: Text.FixedHeight
                lineHeight: 37
                font.pixelSize: 28
                color: YColors.grayText
                text: YTranslateText.radical
            }

            Item {
                id: id_radical_space
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 10
            }

            YText {
                id: id_radical_value
                width: paintedWidth
                lineHeightMode: Text.FixedHeight
                lineHeight: 37
                font.pixelSize: 28
                //font.family: "Noto Sans SC"
                font.family: fontManager.fontFamilyXinHuaXiHei
                color: YColors.white
                textFormat: Text.RichText
                font.bold: true
                //wrapMode: YText.Wrap
                anchors.verticalCenter: parent.verticalCenter
                //anchors.verticalCenterOffset: -5
                text: radical
            }
        }
    }

    Flickable {
        id: id_ch_pinyins_flick
        anchors.left: content_col.left
        anchors.right: content_col.right
        anchors.top: content_col.bottom
        anchors.topMargin: content_col.isWrap ? 9 : 26
        height: 52
        contentWidth: id_dict_ch_pinyin_list.width
        flickableDirection: Flickable.HorizontalFlick
        visible: id_dict_ch_pinyin_list_repeater.count >= 1
        clip: true

        Connections {
            target: resultManager
            ignoreUnknownSignals: true
            function onCurrentQueryChanged() {
                chPinYinList =[]
                console.log("seven:dtChEnglish:2");
                firstDictJson = ({})
                chPinyinSelected = Qt.binding(function(){ return chPinYinList.length ? chPinYinList[0] : ""})
            }
        }

        function getChSound(clickIndex = null) {
            let soundType = settingManager.autoPronounceType
            //如果是新华字典，使用新华字典发音
            if(firstDictType === YEnum.DtXinHua) {
                for(let i = 0; i < id_dict_ch_pinyin_list_repeater.count; i++) {
                    if(id_dict_ch_pinyin_list_repeater.itemAt(i).isCurrentSelectedPinyin || clickIndex === i) {
                        soundType =  YEnum.XinHua + 1
                        chPinYinsSound = typeof xinHuaPinYinNums[i] !== "undefined" ? xinHuaPinYinNums[i]: null
                        break
                    }
                }
            }else if(firstDictType === YEnum.DtBusinessAnCh){
                soundType =  YEnum.DtBusinessAnCh + 1
                chPinYinsSound = typeof buPinYinNums[clickIndex] !== "undefined" ? buPinYinNums[clickIndex]: null
                console.log("seven:buPinYinNume:",chPinYinsSound)
            }else {
                try {

                    if (typeof firstDictJson.dataList != "undefined") {

                        if (typeof firstDictJson.dataList[clickIndex === null ? 0 : clickIndex].pinyinWithNum != "undefined") {

                            if (typeof firstDictJson.details[clickIndex === null ? 0 : clickIndex].pinyinWithNum != "string" ) {

                                chPinYinsSound = firstDictJson.dataList[clickIndex === null ? 0 : clickIndex].pinyinWithNum.join(" ")

                            } else {
                                chPinYinsSound = firstDictJson.dataList[clickIndex === null ? 0 : clickIndex].pinyinWithNum
                            }

                        } else {

                            if (typeof firstDictJson.dataList[clickIndex === null ? 0 : clickIndex].speech != "undefined") {
                                chPinYinsSound = firstDictJson.dataList[clickIndex === null ? 0 : clickIndex].speech
                            } else {
                                chPinYinsSound = null
                            }
                        }

                    } else {

                        if (typeof firstDictJson.phones != "undefined" ) {

                            if (typeof firstDictJson.phones[clickIndex === null ? 0 : clickIndex].pinyinWithNum != "undefined") {

                                if (typeof firstDictJson.phones[clickIndex === null ? 0 : clickIndex].pinyinWithNum != "string") {
                                    chPinYinsSound = firstDictJson.phones[clickIndex === null ? 0 : clickIndex].pinyinWithNum.join(" ")
                                } else {
                                    chPinYinsSound = firstDictJson.phones[clickIndex === null ? 0 : clickIndex].pinyinWithNum
                                }

                            } else {

                                if (typeof firstDictJson.phones[clickIndex === null ? 0 : clickIndex].speech != "undefined") {
                                    chPinYinsSound = firstDictJson.phones[clickIndex === null ? 0 : clickIndex].speech
                                } else {
                                    chPinYinsSound = null
                                }
                            }

                        } else {

                            if (typeof firstDictJson.details[clickIndex === null ? 0 : clickIndex].pinyinWithNum != "undefined") {
                                if (typeof firstDictJson.details[clickIndex === null ? 0 : clickIndex].pinyinWithNum != "string") {

                                    chPinYinsSound = firstDictJson.details[clickIndex === null ? 0 : clickIndex].pinyinWithNum.join(" ")

                                } else {

                                    chPinYinsSound = firstDictJson.details[clickIndex === null ? 0 : clickIndex].pinyinWithNum
                                }
                            } else {
                                    chPinYinsSound =  (chPinYinsSound.length ? chPinYinsSound : null)
                            }
                        }
                    }

//                    chPinYinsSound = typeof firstDictJson.dataList != "undefined" ?
//                                (typeof firstDictJson.dataList[clickIndex === null ? 0 : clickIndex].pinyinWithNum != "undefined" ?
//                                     (typeof firstDictJson.details[clickIndex === null ? 0 : clickIndex].pinyinWithNum != "string" ?
//                                          firstDictJson.dataList[clickIndex === null ? 0 : clickIndex].pinyinWithNum.join(" ") :
//                                          firstDictJson.dataList[clickIndex === null ? 0 : clickIndex].pinyinWithNum) :
//                                     (typeof firstDictJson.dataList[clickIndex === null ? 0 : clickIndex].speech != "undefined" ?
//                                          firstDictJson.dataList[clickIndex === null ? 0 : clickIndex].speech : null)) :
//                                (typeof firstDictJson.phones != "undefined" ?
//                                     (typeof firstDictJson.phones[clickIndex === null ? 0 : clickIndex].pinyinWithNum != "undefined" ?
//                                          (typeof firstDictJson.phones[clickIndex === null ? 0 : clickIndex].pinyinWithNum != "string" ?
//                                               firstDictJson.phones[clickIndex === null ? 0 : clickIndex].pinyinWithNum.join(" ") :
//                                               firstDictJson.phones[clickIndex === null ? 0 : clickIndex].pinyinWithNum) :
//                                          (typeof firstDictJson.phones[clickIndex === null ? 0 : clickIndex].speech != "undefined" ?
//                                               firstDictJson.phones[clickIndex === null ? 0 : clickIndex].speech : null)) :
//                                     (typeof firstDictJson.details[clickIndex === null ? 0 : clickIndex].pinyinWithNum != "undefined" ?
//                                          (typeof firstDictJson.details[clickIndex === null ? 0 : clickIndex].pinyinWithNum != "string" ?
//                                               firstDictJson.details[clickIndex === null ? 0 : clickIndex].pinyinWithNum.join(" ") :
//                                               firstDictJson.details[clickIndex === null ? 0 : clickIndex].pinyinWithNum) :
//                                          (chPinYinsSound.length ? chPinYinsSound : null)))
                } catch (e) {
                }
            }
            return soundType
        }

        function soundPlay() {
            if (settingManager.isAutoPronounce && !resultManager.isReturnSearch && visible) {
                 var nAutoPronType = settingManager.autoPronounceType
                if(chPinYinList.length && Object.keys(firstDictJson).length) {

                    nAutoPronType = id_ch_pinyins_flick.getChSound()
                    id_dict_ch_pinyin_list_repeater.itemAt(0).play()
                }
                qmlGlobal.audioPlayId = soundCenter.play(resultManager.currentQuery,
                                                         resultManager.getSoundLanguage(),
                                                         chPinYinsSound === null ? resultManager.phoneticSymbolJson : chPinYinsSound,
                                                         nAutoPronType)
                resultManager.isReturnSearch = true
                logManager.sendHttpLog("action=sound_click")
            }
        }

//        YTimer {
//            id: id_set_ch_header_total_show
//            interval: 500
//            onTriggered: {
//                id_ch_pinyins_flick.soundPlay()
//            }
//        }

        YTimer {
            id: id_set_ch_header_show
            interval: 10
            property var countNum: 0
            onTriggered: {
                if(firstDictType === settingManager.topShowChDict || firstDictType === settingManager.topShowChDict || settingManager.topShowChDict === YEnum.DtXinHua) {
                    id_ch_pinyins_flick.soundPlay()
                    countNum = 0
                } else {
                    //                    id_set_ch_header_total_show.restart()
                    if(resultManager.itemCount >= 2 && countNum < 40) {
                        countNum = 40
                    }

                    if(countNum < 60) {
                        countNum++
                        id_set_ch_header_show.restart()
                    } else {
                        id_ch_pinyins_flick.soundPlay()
                        countNum = 0
                    }
                }
            }
        }

        Row {
            id: id_dict_ch_pinyin_list
            height: 52
            spacing: 10
            anchors.bottom: parent.bottom
            visible: (chPinYinList.length && Object.keys(firstDictJson).length) || id_dict_content_view_repeater_empty_tip.visible
            onVisibleChanged: {
                if(firstDictType === settingManager.topShowChDict || firstDictType === settingManager.topShowChDict || settingManager.topShowChDict === YEnum.DtXinHua) {
                    id_ch_pinyins_flick.soundPlay()
                } else {
                    id_set_ch_header_show.restart()
                }
            }

            Repeater {
                id: id_dict_ch_pinyin_list_repeater
                model:{
                    return chPinYinList
                }

                YAudioPlayIconLabelHCenterButton {
                    height: 52
                    color: YColors.grayNormal
                    textItem.font.pixelSize: 26
                    textItem.font.family: fontManager.fontFamilyXinHuaXiHei
                    text: model.modelData
                    textItem.color: isCurrentSelectedPinyin ? YColors.red : YColors.white
                    iconItem.visible: isCurrentSelectedPinyin
                    width: (iconItem.visible ? iconItem.width : 0) + textItem.width + 20 * 2

                    readonly property bool isCurrentSelectedPinyin : chPinyinSelected === model.modelData

                    onValidClicked: {
                        console.log("seven:selectPinYinChanged111111:")
//                        resultManager.selectPinYinChanged(text)
                        headerSelectedPinYinChanged(text)
                        console.log("seven:selectPinYinChanged222222:")
                        console.log("YDictPage.qml === id_dict_ch_pinyin_list.btn.onClicked text: ", text)
                        logManager.sendHttpLog("action=detail_chinese_audio")
                        chPinyinSelected = ""
                        chPinyinSelected = text
                        /*if (isFirstDict) */{
                            resultManager.phoneticSymbolJson = text
                            let soundType = id_ch_pinyins_flick.getChSound(index)
                            console.log("seven:soundType",soundType)
                            qmlGlobal.audioPlayId = soundCenter.play(resultManager.currentQuery,
                                                                     resultManager.getSoundLanguage(),
                                                                     chPinYinsSound === null ? resultManager.phoneticSymbolJson : chPinYinsSound,
                                                                     soundType)
                        }
                    }
                }
            }
        }
    }


}
