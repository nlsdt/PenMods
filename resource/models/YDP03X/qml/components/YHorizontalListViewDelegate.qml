import QtQuick 2.12
import QtQml 2.14

import BaseQml 1.0

YItem {
    id: id_item_delegate

    property int rotationAngle: 0

    transform: Rotation {
        origin.x: id_item_delegate.ListView.view.isMoveToLeft ? 30 : (width - 30)
        axis { x: 0; y: 1; z: 0 }
        angle: rotationAngle
    }

    Binding {
        target: id_item_delegate
        property: "rotationAngle"
        restoreMode: Binding.RestoreBinding
        value: (id_item_delegate.ListView.view.isMoveToLeft ? 1 : -1) * (Math.abs(id_item_delegate.ListView.view.horizontalVelocity)/1000 + 2) * 2
        when: id_item_delegate.ListView.view.moving || id_item_delegate.ListView.view.flicking || id_item_delegate.ListView.view.dragging
    }

    Binding {
        target: id_item_delegate
        property: "rotationAngle"
        restoreMode: Binding.RestoreBinding
        value: 0
        when: !(id_item_delegate.ListView.view.moving || id_item_delegate.ListView.view.dragging)
    }

    Behavior on rotationAngle {
        NumberAnimation { duration: 60; to: 0}
        enabled: !(id_item_delegate.ListView.view.flicking || id_item_delegate.ListView.view.dragging)
    }
}
