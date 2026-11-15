// PenMods2 兼容别名：2 代的 YInputPage 位于 qrc:/qml/YInputPage.qml（qml 根），
// 3 代位于 qrc:/qml/input/YInputPage.qml。插件按 2 代路径
// Qt.createComponent("qrc:/qml/YInputPage.qml") 即可在两代宿主上通用，
// 这里转发到 3 代实现（对象即 YInputPage 实例，enterText/inputFinished/
// backButtonClicked/show/todoDestroy 接口原样透出）。
import QtQuick 2.12
import "input"

YInputPage { }
