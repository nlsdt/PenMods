import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

YIconLabelButton {
    implicitHeight: visible ? 54 : 0
    radius: height/2
    leftMargin: 20
    rightMargin: 20
    spacing: 8
    color: "#27282C"
    textColor: YColors.grayText
    sourceSize: Qt.size(32, 32)
    icon: "dict/follow-pron"
    pixelSize: 24
    textFormat: Text.RichText
    text: ('<span style="font-family: %1; font-weight: 500">%2</span>').arg(
              fontManager.fontFamily).arg(YTranslateText.follow)
}
