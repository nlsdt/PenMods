import QtQuick 2.12
import BaseQml 1.0
import "../i18n"

YButtonBase {
    id: id_icon_label_button_bg
    width: visible ? (id_content_flow.width + id_content_flow.anchors.leftMargin) : 0
    height: id_content_flow.height + id_content_flow.anchors.topMargin
    //implicitHeight: 48
    radius: height/2
    //mouseAreaMargins: id_multiphone_item.enPolyPhoneLength ? 0: -10
    property var enPolyPhoneString: resultManager.enPolyPhone
    property var enPolyPhoneLength: Qt.binding(function(item) {return resultManager.enPolyPhone.length})
    onEnPolyPhoneStringChanged: {
        enPolyPhoneLength = Qt.binding(function(item) {return resultManager.enPolyPhone.length})
    }
    mouseAreaMargins: -5
    color: "transparent"
    opacity: 1

    state: isWrap ? "wrap" : "nowrap"
    property int isUk: 0
    property string chUkOrUs: '<span style="font-family: %1; font-weight: 500">%2</span>&nbsp;'

    states: [
        State {
            name: "wrap"
            PropertyChanges {
                target: mouseAreaItem
                anchors.rightMargin: -id_content_flow.anchors.leftMargin
            }
        },State {
            name: "nowrap"
            PropertyChanges {
                target: mouseAreaItem
                anchors.rightMargin: -id_content_flow.anchors.leftMargin
            }
        }
    ]

    readonly property var phoneticSymbolJson: {
        let jsonObjTmp = null
        try {
            jsonObjTmp = JSON.parse(resultManager.phoneticSymbolJson)
        } catch(e) { }
        return jsonObjTmp
    }

    property alias icon: id_button_icon.imageName
    property alias source: id_button_icon.imageName
    property alias imageName: id_button_icon.imageName
    property alias imageHeight: id_button_icon.height
    property bool isWrap: qmlGlobal.scanOldType === 0

    property alias iconSourceSize: id_button_icon.sourceSize
    property alias sourceSize: id_button_icon.sourceSize
    signal phoneticClick()
    signal multiPhoneButtonClick()
    property bool isComponent: false
    onIsComponentChanged: {
        if(!isComponent) {
            id_set_visible.restart()
        }
    }

    property alias textModel: id_text_repeater.model
    property var textContent: YTranslateText.pronunciation/*"səˈpraɪzd"*//*"\/ ˌnjuːmənəʊˌʌltrəˌmaɪkrə(ʊ)ˈskɒpɪkˌsɪlɪkəʊvɒlˌkeɪnəʊˌkəʊnɪˈəʊsɪʃ; njʊˌməʊnəʊ- \/"*/
    property var textStyle: ""
    onTextStyleChanged: {
        if(textStyle.length) {
            isComponent = false
            let modelArray = []
            for(let i = 0; i < textContent.length; i++) {
                modelArray.push(textStyle.arg( textContent === YTranslateText.pronunciation ? fontManager.fontFamilyZhCn : fontManager.fontFamilyEnSymbol).arg(textContent[i]))
            }
            id_text_repeater.model = modelArray
        }
    }

    visible: isComponent && textContent.length

    onTextContentChanged: {
        if(!textContent.trim().length) {
            textContent = YTranslateText.pronunciation
            textStyle = '<span style="font-family: %1; font-weight: 500">%2</span>'
        }
         isComponent = false
         //Qt.callLater(resultManager.queryEnPolyPhone,resultManager.currentQuery)
    }

    onValidClicked: {
        phoneticClick()
    }

    YTimer {
        id: id_set_visible
        repeat: false
        interval: 80
        onTriggered: {
            if(0 === qmlGlobal.scanOldType)
                isWrap = true
            isComponent = true
        }
    }

    Flow{
        id: id_content_flow
        anchors.left: parent.left
        anchors.leftMargin: isWrap ? 0 : 56
        anchors.top: parent.top
        anchors.topMargin: (isWrap && 1 === qmlGlobal.scanOldType) ? 20 : 0
        property var repeatWidth: 0
        visible: isComponent
        //property var conetentWidth: id_button_icon.width + id_button_right_icon.width + id_content_flow.repeatWidth + id_multiphone_item.width

        width: isWrap ? 582 : undefined

        property var lastWidth: 0

        onWidthChanged: {
             id_set_visible.restart()
        }

        Component.onCompleted: {
            id_set_visible.restart()
        }

        YImage {
            id: id_button_icon
            visible: isComponent
            verticalAlignment: Image.AlignVCenter
            width: 20
            height: isWrap ? 26 : 40
            imageName: "dict/sound-left"
            fillMode: Image.PreserveAspectFit
            sourceSize: (Qt.size(20,20))
            //baselineOffset: 10
            cache: true
            opacity: id_icon_label_button_bg.pressed || !id_icon_label_button_bg.enabled ? 0.6 : 1
        }

        Repeater{
            id: id_text_repeater
            model: {
                let modelArray = []
                for(let i = 0; i < textContent.length; i++) {
                    modelArray.push(textContent[i])
                }
                return modelArray
            }

            onModelChanged: {
                id_content_flow.repeatWidth = 0
            }
            delegate:id_text
            onCountChanged: {
                 id_set_visible.restart()
            }
            onItemAdded: {
                id_set_visible.restart()
            }
            onItemRemoved: {
                id_set_visible.restart()
            }
            opacity: id_icon_label_button_bg.pressed || !id_icon_label_button_bg.enabled ? 0.6 : 1
        }

        Component{
            id:id_text
            YText {
                id: id_label
                textFormat: YText.RichText
                font.pixelSize: 24
                height: id_button_icon.height
                verticalAlignment: Text.AlignVCenter
                width: paintedWidth
                color: YColors.grayText
                lineHeightMode: Text.FixedHeight
                lineHeight: 30/*id_button_icon.height*/
                opacity: id_icon_label_button_bg.pressed || !id_icon_label_button_bg.enabled ? 0.6 : 1
                text: index === 0 ? ((textContent === YTranslateText.pronunciation ? "" :
                       ((isUk > 0 ? (isUk===1 ? chUkOrUs.arg(qmlGlobal.fontFamily).arg(YTranslateText.shorthandEN)
                                          :chUkOrUs.arg(qmlGlobal.fontFamily).arg(YTranslateText.shorthandUS)) : "")+ "\/ ")) + model.modelData) :
                                    (index ===id_text_repeater.model.length - 1 ? (model.modelData + (textContent === YTranslateText.pronunciation ? "" : " \/")): model.modelData)
            }
        }

        YImage {
            id: id_button_right_icon
            imageName: "dict/sound-right"
            fillMode: Image.PreserveAspectFit
            visible: isComponent
            verticalAlignment: Image.AlignVCenter
            width: 20
            height: id_button_icon.height
            sourceSize: (Qt.size(20,20))
            cache: true
            opacity: id_icon_label_button_bg.pressed || !id_icon_label_button_bg.enabled ? 0.6 : 1
        }

        Item{
            id: id_multiphone_item
            width: visible ? 46 : 0
            height: id_button_icon.height

            visible: (enPolyPhoneLength || (phoneticSymbolJson !== null && typeof phoneticSymbolJson.us != "undefined" &&
                     phoneticSymbolJson.us.length && typeof phoneticSymbolJson.uk != "undefined" &&
                     phoneticSymbolJson.uk.length)) && isComponent

            YButtonBaseMouseArea {
                id: id_multiphone_mouse
                anchors.margins: -5
                anchors.topMargin: -10
                anchors.bottomMargin: -10
                anchors.rightMargin: -20
                onValidClicked: {
                    console.warn("***********************multi click")
                    multiPhoneButtonClick()
                }
                opacity: id_multiphone_mouse.pressed || !id_multiphone_mouse.enabled ? 0.6 : 1
                enabled: id_multiphone_item.visible
            }

            Rectangle{
                width: 26
                height: 26
                radius: height/2
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color: YColors.grayNormal
                opacity: id_multiphone_mouse.pressed || !id_multiphone_mouse.enabled ? 0.6 : 1

                YImage {
                    id: id_button_multiPhone_icon
                    imageName: "dict/multi-phone"
                    fillMode: Image.PreserveAspectFit
                    verticalAlignment: Image.AlignVCenter
                    anchors.centerIn: parent
                    sourceSize: (Qt.size(18,18))
                    cache: true
                }
            }
        }


    }
}
