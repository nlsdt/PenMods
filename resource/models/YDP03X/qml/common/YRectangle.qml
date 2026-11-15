import QtQuick 2.12

Rectangle {
    function qmlCreateComponent(qmlName) {
        return Qt.createComponent(("qrc:/qml/%1.qml").arg(qmlName))
    }

}
