#pragma once
#include <QJsonObject>
#include <QString>

namespace mod {
struct PluginInfo {
    QString id;
    QString name;
    QString version;
    QString author;
    QString description;
    QString mainQml; // QML 入口文件绝对路径
    QString mainSo;  // SO 库相对路径
    QString icon;
    QString path; // 插件根目录

    bool isEnabled = true;  // 插件开关（基于是否存在 .disabled 文件）
    bool isLoaded  = false; // 运行时的实际加载状态
};
} // namespace mod