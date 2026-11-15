// PenMods2 兼容别名：2 代的图片查看器叫 FileManagerImageViewer（qrc:/qml/audiopages/），
// 3 代叫 PenModsImageViewer。插件按 2 代命名调用，这里转发到 3 代实现。
// 两者都从 `imageViewer` 上下文属性（source/fullPath/isWebP/isAnimatedWebP）取图，
// openSystemImageViewer() 先 imageViewer.open(localPath) 再 show 本页，接口一致。
import QtQuick 2.12
import "."

PenModsImageViewer { }
