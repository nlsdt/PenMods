import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
CheckBox {
    id: control;
    property var title: ""
    property var checkBoxSize : 36
    style: CheckBoxStyle {
        spacing: 5;
        // 复选框形状 用颜色和边框宽度区分选中状态 也可采用jpg png svg等格式图片来代替
        indicator: Rectangle {
            implicitWidth: checkBoxSize
            implicitHeight: checkBoxSize
            color: "#2D2E33"
            radius: checkBoxSize / 2;
            Rectangle {
                implicitWidth: checkBoxSize
                implicitHeight: checkBoxSize
                visible: control.checked;
                color: "white"
                border.color: "#FA423C"
                border.width: 10
                radius: checkBoxSize / 2;
                anchors.fill: parent
            }
        }
        // 复选框 名称
        label: Label {
            id: id_label_title
            text: title
            font.family: fontManager.fontFamily
            font.pixelSize: 28
            color: "white"
            leftPadding: 3;
        }
    }
}
