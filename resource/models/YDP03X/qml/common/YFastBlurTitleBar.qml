import QtQuick 2.12
import QtGraphicalEffects 1.14

YBackground {
    id: id_title_bar_holder
    anchors.top: parent.top
    implicitWidth: 90

    property int sourceItemLeftMargin: 90
    property alias sourceItem: id_effect_source.sourceItem

    ShaderEffectSource {
        id: id_effect_source
        anchors.fill: parent
        sourceRect: Qt.rect(x - 90, y , width, height)
        visible: false
    }

    FastBlur {
        anchors.fill: parent
        source: id_effect_source
        radius: 32
    }

    Rectangle {
        anchors.fill: parent
        color: "#4D000000"
    }
}
