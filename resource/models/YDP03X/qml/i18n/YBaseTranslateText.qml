pragma Singleton
import QtQuick 2.12

QtObject {
    // no need translate

    // translate text
	readonly property string inputTip: qsTr("请输入内容")
    readonly property string cancel: qsTr("取消")
    readonly property string confirm: qsTr("确认")
}
