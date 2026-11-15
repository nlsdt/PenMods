import QtQuick 2.12
import QtQml 2.14
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YPage {
    id: id_speechguide_page_switch_loader
    signal callback();
    anchors.fill: parent
        PathView {
            id: id_speech_pathview
            anchors.fill: parent
            anchors.leftMargin: 80
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            highlightRangeMode: PathView.StrictlyEnforceRange
            snapMode: PathView.NoSnap
          //  movementDirection:  PathView.Shortest
            pathItemCount: 2
            clip: true
            //切换的时间
             highlightMoveDuration: 1000
             //向前移动，即顺序0 1 2 3
             movementDirection: PathView.Positive
//            path: Path{
//                startX: 0
//                startY: id_speech_pathview.height / 2;
//                PathLine {
//                    x: id_speech_pathview.width
//                    y: id_speech_pathview.height / 2
//                }
//            }

             path: Path {
              startX: -id_speech_pathview.width/2
              startY: id_speech_pathview.height / 2

              PathLine {
              x: id_speech_pathview.pathItemCount * id_speech_pathview.width-id_speech_pathview.width / 2
              y: id_speech_pathview.height / 2
              }
             }



            model: guidemiagemodel

            onCurrentIndexChanged: {
                console.log("speech guide index change")

            }

            delegate: id_speech_view_delegate
            interactive: true
        }

        YVerticalTitleBar {
            onCallBack: {
                id_speech_pathview.currentIndex = 0
              backButtonClicked();
            }
        }
        Component.onCompleted: {
            id_speech_pathview.currentIndex = 0
        }

        YTimer {
            id: id_check_speechguide_timer
            interval: 3000
            repeat: true
            running: false
            onTriggered: {
              if(id_speech_pathview.count >1 )
              id_speech_pathview.currentIndex = (id_speech_pathview.currentIndex + 1)%id_speech_pathview.count

            }
        }

    Component {
        id: id_speech_view_delegate
        Rectangle {
            width: PathView.view.width
            height: PathView.view.height
            color: YColors.black
            YText {
                id: id_word
                height: 34
                width: paintedWidth
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 22
                verticalAlignment: YText.AlignVCenter
                font.weight: Font.Bold
                font.pixelSize: 26
                font.family: fontManager.fontFamilyEnUs
                text: tips
            }

            YText {
                id: id_index_tip
                anchors.left: id_word.right
                anchors.leftMargin: 10
                anchors.verticalCenter: id_word.verticalCenter
                verticalAlignment: YText.AlignVCenter
                font.pixelSize: 22
                textFormat: YTextBase.RichText
                width: paintedWidth
                text: ("%1<font color=\"%3\">/%2</font>").arg(index + 1).arg(guidemiagemodel.count).arg(YColors.grayText)
            }

            YImage {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                fillMode: Image.PreserveAspectFit
                imageName: imagepath
            }
        }
    }

    ListModel {
        id: guidemiagemodel

        Component.onCompleted: {
            guidemiagemodel.clear()
            if (settingManager.uiLanguage === YEnum.ZH_CN) {
                guidemiagemodel.append({tips: YTranslateText.useofSpeechaction,
                                           imagepath: "large_animation/speech_guide/speechgui01"})
            } else {
                guidemiagemodel.append({tips: YTranslateText.useofSpeechaction,
                                           imagepath: "large_animation/speech_guide/speechgui01-en"})
            }
            guidemiagemodel.append({tips: YTranslateText.useofSpeechaction,
                                       imagepath: "large_animation/speech_guide/speechgui02"})
        }
    }
}
