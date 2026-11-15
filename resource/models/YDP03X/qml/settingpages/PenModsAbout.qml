import QtQuick 2.12

PenModsSettingsPage {
    title: "关于 PenMods"
    PenModsSettingRow { title: "版本"; value: mod.version; interactive: false }
    PenModsSettingRow { title: "构建信息"; description: mod.buildInfo; interactive: false }
    PenModsSettingRow { title: "已缓存符号"; value: String(mod.cachedSymCount); interactive: false }
    PenModsSettingRow { title: "项目主页"; description: "github.com/Haikure/PenMods"; interactive: false }
    PenModsSettingRow { title: "社区"; description: "t.me/PenUniverse"; interactive: false }
    PenModsSettingRow { title: "致谢"; description: "PenUniverse、Dobby、Qt Project 与所有贡献者"; interactive: false }
}
