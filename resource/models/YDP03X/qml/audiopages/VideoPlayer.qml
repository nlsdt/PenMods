import QtQuick 2.12

// Keep the second-generation page name usable by plugins on YDP03X.
ExternalPlayer {
    id: page
    objectName: "YPage===VideoPlayer.qml"
    property alias fileName: page.path
}
