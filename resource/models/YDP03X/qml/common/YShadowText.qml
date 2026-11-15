import QtQuick 2.12
import QtGraphicalEffects 1.14

YTextMedium {
    id: id_text_content

    layer.enabled: true
    layer.effect: DropShadow {
        verticalOffset: 1
        color: "#4D000000"
        radius: 3
        samples: 7
    }
}
