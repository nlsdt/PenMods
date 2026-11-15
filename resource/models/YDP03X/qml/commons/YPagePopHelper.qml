// PenMods2 兼容别名：2 代的 YPagePopHelper 位于 qrc:/qml/commons/，
// 3 代位于 qrc:/qml/common/。插件按 2 代命名 `import "qrc:/qml/commons"`
// 即可在两代宿主上通用，这里转发到 3 代实现。
import QtQuick 2.12
import "qrc:/qml/common"

YPagePopHelper { }
