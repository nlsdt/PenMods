import QtQuick 2.12

import "../components"

YHorizontalListViewDelegate {
    id: id_touch_reading_view_delegate_base
    height: ListView.view.height
    property QtObject delegateItem: id_touch_reading_view_delegate_base
}
