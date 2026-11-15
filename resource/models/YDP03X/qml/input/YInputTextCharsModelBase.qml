import QtQuick 2.12

import "../common"

Flow {
    id: id_input_text_chars_model_base_view
    width: 552
    spacing: 8

    readonly property alias containerItem: id_input_text_chars_model_base_view

    function charTriggered(text) {
        id_input_text_title_area.enterChar(text)
    }

    function charPressed(text, posX, posY) {
        id_highlight_item.x = posX - 48
        id_highlight_item.y = posY - 48 + 80
        id_highlight_item_content.text = text
    }

    function charRelessed() {
        id_highlight_item_content.text = ""
    }

}
