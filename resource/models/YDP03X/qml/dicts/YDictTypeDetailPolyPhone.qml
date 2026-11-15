import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../dicts"
import "../i18n"
import "../components"

YBackButtonPage {
    id: id_dict_detail_page
    objectName: "YPage===YDictTypeDetailPolyPhone.qml"

    // 拼读按钮的 visible 状态
    property alias spellButtonVisible: id_sound_spell.visible
    // 跟读按钮的 visible 状态
    property alias followButtonVisible: id_sound_follow.visible

    function getPhoneticJson() {
        let jsonObjTmp = null
        try {
            jsonObjTmp = JSON.parse(resultManager.phoneticSymbolJson)
        } catch(e) { }
        return jsonObjTmp
    }

    property var phoneticSymbolJson:getPhoneticJson()

    property var curWord: resultManager.currentQuery
    property var soundLanguageType: resultManager.getSoundLanguage()
    property var spellPhonics:spellManager.phonics

    function getData() {
        try {
            let jsonObj = JSON.parse(resultManager.enPolyPhone)
            if (typeof jsonObj == "object") {
                return jsonObj
            }
        } catch(e) {
            console.log("YDictTypeDetailPolyPhone.qml === resultManager.enPolyPhone parse error: ", e)
        }
        return new Object
    }

    property int dictType: YEnum.NoDict
    property string content: ""
    property var dictJson: null
    property string title: ""
    property var backLastPos: null
    property bool showPoemTitle: false
    property var resJson: getData()


    function soundPlay(word) {
        var nAutoPronType = YEnum.EnPolyPhone
        qmlGlobal.audioPlayId = soundCenter.play(word,
                                                 soundLanguageType,
                                                 word,
                                                 nAutoPronType + 1)
    }

    Flickable {
        id: id_container_flickable
        anchors.fill: parent
        anchors.leftMargin: 80
        anchors.rightMargin: 41
        z: id_dict_detail_page.z + 1
        contentHeight: id_contetnt_column.height

        Column{
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            id: id_contetnt_column

            YSpacingForColumn{
                height: 20
            }

            YDictPageHeaderView {
                id: id_dict_listview
                isDetailShow: true
                detailContent: curWord
                //visible: !id_stroke_info_item.visible && !id_word.visible /*&& !id_dict_listview_pointScan.visible*/
            }
            YSpacingForColumn{
                height: 20
            }

        Column {
            id: id_dict_content_column
            anchors.left: parent.left
            anchors.right: parent.right
            //anchors.top: parent.top
            //anchors.topMargin: 12
            spacing: 2

            Repeater {
                model: {
                    if (id_dict_detail_page.resJson !== null && typeof id_dict_detail_page.resJson.uk != "undefined"
                            && id_dict_detail_page.resJson.uk !== null) {
                        return id_dict_detail_page.resJson.uk
                    } else if( (id_dict_detail_page.resJson === null || typeof id_dict_detail_page.resJson.uk === "undefined") && phoneticSymbolJson !== null) {
                        if(typeof phoneticSymbolJson.uk !== "undefined" && phoneticSymbolJson.uk.length){
                            return [phoneticSymbolJson.uk]
                        }
                    } else return null
                }
                YAudioPlayIconLabelButton {
                    id: id_sound_uk
                    implicitHeight: textLength > 70 ? textItem.contentHeight : 40
                    property var textLength: 0
                    textItem.verticalAlignment: Text.AlignVCenter
                    textItem.anchors.verticalCenter: undefined
                    imageItem.anchors.verticalCenter: undefined
                    imageItem.anchors.top: id_sound_uk.top
                    imageItem.anchors.topMargin: 3
                    textItem.width: 467
                    leftMargin: 0
                    sourceSize: Qt.size(32, 32)
                    pixelSize: 26
                    color: "transparent"
                    visible: text !== ""
                    text: {
                        var value = ""
                        var pos = ""
                        var phone = ""
                        if (model.modelData !== "undefined") {
                            if (typeof(model.modelData.phone) === "string"
                                    && model.modelData.phone.length > 0) {
                                phone = model.modelData.phone
                            }

                            if (typeof (model.modelData.pos) !== "undefined" && model.modelData.pos.length > 0) {
                                for (let i = 0; i < model.modelData.pos.length; i++) {
                                    pos = pos + model.modelData.pos[i] + '.&nbsp;'
                                }
                                pos = ('<span style="font-family: %1; font-style: italic; font-size: 24px">').arg(fontManager.fontFamilyClass) + pos + '</span>'
                            }
                             if (typeof model.modelData.phone === "undefined")
                                phone = model.modelData
                        }

                        if (/*(phone.length > 10 && phone.length <= 20)
                                ||*/ phone.length > 70) {
                            pos = '<br>' + pos
                        }

                        if (phone.length > 0) {
//                            if (phone.length > 20) {
//                                phone = phone.slice(0, 13) + '<br>' + phone.slice(13);
//                            }
                            textLength = phone.length
                            phone = ('<span style="font-family: %1;">&frasl;&nbsp;%2&nbsp;&frasl;</span>').arg(fontManager.fontFamilyEnSymbol).arg(phone)
                        }
                        if (pos !== "" || phone !== "") value = YTranslateText.shorthandEN + '&nbsp;' +  phone + '&nbsp;&nbsp;' + pos
                        return value
                    }
                    onValidClicked: {
                        if (typeof model.modelData.speech != "undefined") {
                          soundPlay(model.modelData.speech)
                        } else {
                            const nAutoPronType = YEnum.UK
                            qmlGlobal.audioPlayId = soundCenter.play(curWord,
                                                                     soundLanguageType,
                                                                     curWord,
                                                                     nAutoPronType + 1)
                        }
                        logManager.sendHttpLog("action=detail_british_accent_click")
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 8
            }

            Repeater {
                model: {
                    if ( id_dict_detail_page.resJson !== null && typeof id_dict_detail_page.resJson.us != "undefined"
                            && id_dict_detail_page.resJson.us !== null) {
                        return id_dict_detail_page.resJson.us
                    } else if( (id_dict_detail_page.resJson === null || typeof id_dict_detail_page.resJson.us === "undefined")
                              && phoneticSymbolJson !== null) {
                        if(typeof phoneticSymbolJson.us !== "undefined"
                                && phoneticSymbolJson.us.length){
                            return [phoneticSymbolJson.us]
                        }
                    } else return null
                }
                YAudioPlayIconLabelButton {
                    id: id_sound_us
                    implicitHeight: textLength > 70 ? textItem.contentHeight : 40
                    property var textLength: 0
                    textItem.verticalAlignment: Text.AlignVCenter
                    textItem.anchors.verticalCenter: undefined
                    imageItem.anchors.verticalCenter: undefined
                    imageItem.anchors.top: id_sound_us.top
                    imageItem.anchors.topMargin: 3
                    textItem.width: 467
                    leftMargin: 0
                    sourceSize: Qt.size(32, 32)
                    pixelSize: 26
                    color: "transparent"
                    visible: text !== ""
                    text: {
                        var value = ""
                        var pos = ""
                        var phone = ""
                        if (model.modelData !== "undefined") {
                            if (typeof(model.modelData.phone) === "string"
                                    && model.modelData.phone.length > 0) {
                                phone = model.modelData.phone
                            }

                            if (typeof model.modelData.phone === "undefined")
                               phone = model.modelData

                            if (typeof model.modelData.pos !== "undefined" && model.modelData.pos.length > 0) {
                                 for (let i = 0; i < model.modelData.pos.length; i++) {
                                    pos = pos + model.modelData.pos[i] + '.&nbsp;'
                                }
                                pos = ('<span style="font-family: %1; font-style: italic; font-size: 24px">').arg(fontManager.fontFamilyClass) + pos + '</span>'
                            }
                        }

                        if (/*(phone.length > 10 && phone.length <= 20)
                                ||*/ phone.length > 70) {
                            pos = '<br>' + pos
                        }

                        if (phone.length > 0) {
//                            if (phone.length > 20) {
//                                phone = phone.slice(0, 13) + '<br>' + phone.slice(13);
//                            }
                            textLength = phone.length
                            phone = ('<span style="font-family: %1;">&frasl;&nbsp;%2&nbsp;&frasl;</span>').arg(fontManager.fontFamilyEnSymbol).arg(phone)
                        }
                        if (pos !== "" || phone !== "") value = YTranslateText.shorthandUS + '&nbsp;' +  phone + '&nbsp;' + pos

                        return value
                    }
                    onValidClicked: {
                        if (typeof model.modelData.speech != "undefined") {
                          soundPlay(model.modelData.speech)
                        } else {
                            const nAutoPronType = YEnum.US
                            qmlGlobal.audioPlayId = soundCenter.play(curWord,
                                                                     soundLanguageType,
                                                                     curWord,
                                                                     nAutoPronType + 1)
                        }
                        logManager.sendHttpLog("action=detail_american_accent_click")
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 4
            }
        }     
        }
        }

        //拼读，跟读按钮
        Column {
            id: id_spell_row
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 41
            height: id_sound_spell.height + id_sound_follow.height
            spacing: 22
            z: id_container_flickable.z+1


            YIconLabelButton {
                id: id_sound_spell
                radius: 34
                implicitHeight: visible ? 54 : 0
                leftMargin: 20
                rightMargin: 20
                spacing: 8
                textColor: YColors.grayText
                textFormat: YText.RichText
                sourceSize: Qt.size(34, 34)
                pixelSize: 24
                visible: spellPhonics.length > 0
                color: "#27282C"

                icon: spellPhonics.length > 0 ? "dict/spelling" : ""
                text: (spellPhonics.length <= 0)
                      ? ('<span style="font-family: %1; font-weight: 500">%2</span>').arg(
                            fontManager.fontFamily).arg(YTranslateText.pronunciation)
                      : ('<span style="font-family: %1; font-weight: 500">%2</span>').arg(
                            fontManager.fontFamily).arg(YTranslateText.spell)
                readonly property bool playing: "playing" === id_playing_animation.state

                property int iconChangedAnimationDuration: 300

                property double playId: id_playing_animation.audioPlayId

                function play() {
                    id_playing_animation.state = "playing"
                    id_playing_animation.running = true
                }

                function stop() {
                    id_playing_animation.state = "stop"
                    id_playing_animation.running = false
                }

                onValidClicked: {
                    spellManager.reset();
                    if (spellManager.phonics.length > 0) {
                        logManager.sendHttpLog("action=detail_add_spell_click")
                        soundCenter.stop();
                        spellManager.content = curWord;
                        spellManager.richContent = curWord;
                        qmlGlobal.showSpellPage();
                    } else {
                        if (playing) {
                            stop()
                            soundCenter.stop()
                        } else {
                            play()
                        }
                        qmlGlobal.audioPlayId = soundCenter.play(curWord,
                                                                 soundLanguageType,
                                                                 curWord,
                                                                settingManager.autoPronounceType + 1)
                    }
                }

                SequentialAnimation {
                    id: id_playing_animation
                    loops: Animation.Infinite
                    alwaysRunToEnd: true
                    property string state: "stop"
                    property double audioPlayId: 0
//                    PropertyAction {
//                        target: id_sound_spell
//                        property: "icon"
//                        value: "dict/mangoSound-1"
//                    }
//                    PauseAnimation { duration: id_sound_spell.iconChangedAnimationDuration }
//                    PropertyAction {
//                        target: id_sound_spell
//                        property: "icon"
//                        value: "dict/mangoSound-2"
//                    }
//                    PauseAnimation { duration: id_sound_spell.iconChangedAnimationDuration }
//                    PropertyAction {
//                        target: id_sound_spell
//                        property: "icon"
//                        value: "dict/mangoSound-3"
//                    }
//                    PauseAnimation { duration: id_sound_spell.iconChangedAnimationDuration }
//                    onRunningChanged: {
//                        if (!running && ("stop" === id_playing_animation.state)) {
//                            id_sound_spell.icon = "dict/mangoSound"
//                        }
//                    }
                }

                Connections {
                    target: qmlGlobal
                    ignoreUnknownSignals: true
                    enabled: spellPhonics.length <= 0
                    function onAudioPlayIdChanged() {
                        if (id_sound_spell.playing) {
                            id_playing_animation.audioPlayId = qmlGlobal.audioPlayId
                        }
                    }
                }
                Connections {
                    target: soundCenter
                    ignoreUnknownSignals: true
                    enabled: spellPhonics.length <= 0
                    function onEnd(seq) {
                        if ((id_sound_spell.playing)
                                && (seq == id_playing_animation.audioPlayId)) {
                            id_sound_spell.stop()
                        }
                    }
                }
            }

            YFollowReadingButton {
                id: id_sound_follow
                visible: qmlTranslator.textIsEnglishOnly(curWord)
                onValidClicked: {
                    soundCenter.stop();
                    spellManager.reset();
                    followManager.ukPhonetic = "";
                    followManager.usPhonetic = "";
                    logManager.sendHttpLog("action=detail_add_follow_click")

                    if (typeof phoneticSymbolJson != "undefined") {
                        followManager.ukPhonetic =
                                typeof phoneticSymbolJson.uk == "undefined"
                                ? "" : phoneticSymbolJson.uk;
                        followManager.usPhonetic =
                                typeof phoneticSymbolJson.us == "undefined"
                                ? "" : phoneticSymbolJson.us;
                    }
                    followManager.clearResult()
                    followManager.content = curWord;
                    followManager.isUk =
                            (settingManager.autoPronounceType === YEnum.UK)
                            && (followManager.ukPhonetic.length !== 0)
//                    qmlGlobal.showFollowPage();
                    jupToFollowWordPageEx()
                }
            }
        }

    ignoreDefaultBackButtonClicked: true
    onBackButtonClickedCallback: {
        backButtonClicked()
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.DictDetail
            id_container_flickable.contentY = 0
        }
    }

    YPopLayer {
        id: id_pop_layer
        function showPage(qrcqml, properties) {
            show(qrcqml, false, false, properties)
            currentShowPage = popItemObject
        }
    }
    property var currentShowPage: null
    function jupToFollowWordPageEx(){
        id_pop_layer.showPage("components/YFollowWordExPage");
        currentShowPage.queryWordInfo()
    }
}
//// object
//{
//    "uk":[
//        {
//            "phone":"ˈɒbdʒɪkt",
//            "pos":["n"],
//            "speech":"object&phonetic=ˈɒbdʒɪkt&type=1"
//        },
//        {
//            "phone":"ˈɒbdʒekt",
//            "pos":["n"],
//            "speech":"object&phonetic=ˈɒbdʒekt&type=1"
//        },
//        {
//            "phone":"əbˈdʒekt",
//            "pos":["v"],
//            "speech":"object&phonetic=əbˈdʒekt&type=1"
//        }
//    ],
//    "us":[
//        {
//            "phone":"ˈɑːbdʒɪkt",
//            "pos":["n"],
//            "speech":"object&phonetic=ˈɑːbdʒɪkt&type=2"
//        },
//        {
//            "phone":"ˈɑːbdʒekt",
//            "pos":["n"],
//            "speech":"object&phonetic=ˈɑːbdʒekt&type=2"
//        },
//        {
//            "phone":"əbˈdʒekt",
//            "pos":["v"],
//            "speech":"object&phonetic=əbˈdʒekt&type=2"
//        }
//    ]
//}
