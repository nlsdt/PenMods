import QtQuick 2.12
import "../utils/utils.js" as Script

Item {
    function qmlCreateComponent(qmlName) {
        return Qt.createComponent(("qrc:/qml/%1.qml").arg(qmlName))
    }
}
