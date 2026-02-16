#include "QmlPluginWrapper.h"
#include <QJsonArray>
#include <QUrl>

namespace mod {

QmlPluginWrapper::QmlPluginWrapper(QObject* parent) : QObject(parent), m_pluginManager(&PluginManager::getInstance()) {
    // 连接底层插件管理器的信号
    connect(m_pluginManager, &PluginManager::pluginsChanged, this, &QmlPluginWrapper::onPluginsChanged);
}

int QmlPluginWrapper::getPluginCount() {
    auto& plugins = m_pluginManager->getPlugins();
    return plugins.size();
}

QJsonObject QmlPluginWrapper::getPluginInfo(int index) {
    auto& plugins = m_pluginManager->getPlugins();
    if (index < 0 || index >= plugins.size()) return QJsonObject();

    const auto& plugin = plugins[index];
    QJsonObject obj;
    obj["id"]          = plugin.id; // 必须传递 ID
    obj["name"]        = plugin.name;
    obj["description"] = plugin.description;
    obj["version"]     = plugin.version;
    obj["author"]      = plugin.author;
    // UI 开关状态绑定到 isEnabled (偏好)，但如果 isLoaded 为 false 且 isEnabled 为 true，UI 应该知道出错了
    obj["enabled"] = plugin.isEnabled;
    obj["loaded"]  = plugin.isLoaded;
    obj["icon"]    = plugin.icon.isEmpty() ? "settings/plugin" : plugin.icon;

    // 转换路径为 URL 格式供 QML 使用
    obj["mainQmlUrl"] = QUrl::fromLocalFile(plugin.mainQml).toString();

    return obj;
}

bool QmlPluginWrapper::setPluginEnabled(const QString& pluginId, bool enabled) {
    // 这里假设 QML 传过来的是 ID 或者我们在 Wrapper 里根据 Name 找 ID
    // 建议 QML 直接传 ID，这里做个兼容查找
    auto&   plugins  = m_pluginManager->getPlugins();
    QString targetId = pluginId;

    // 如果传的是 Name (兼容旧逻辑)，尝试找 ID
    bool foundById = false;
    for (const auto& p : plugins)
        if (p.id == pluginId) foundById = true;

    if (!foundById) {
        for (const auto& p : plugins) {
            if (p.name == pluginId) {
                targetId = p.id;
                break;
            }
        }
    }

    bool result = m_pluginManager->togglePlugin(targetId, enabled);
    if (result) {
        // 强制刷新列表，确保 UI 状态（尤其是加载失败回滚的情况）正确
        emit pluginListUpdated();
    }
    return result;
}

void QmlPluginWrapper::uninstallPlugin(const QString& pluginName) {
    // 首先尝试按 ID 查找插件
    auto&   plugins  = m_pluginManager->getPlugins();
    QString targetId = pluginName;

    // 检查是否直接提供了 ID
    bool foundById = false;
    for (const auto& p : plugins) {
        if (p.id == pluginName) {
            foundById = true;
            break;
        }
    }

    // 如果不是 ID，尝试按名称查找 ID
    if (!foundById) {
        for (const auto& p : plugins) {
            if (p.name == pluginName) {
                targetId = p.id;
                break;
            }
        }
    }

    // 调用 PluginManager 的卸载方法
    bool result = m_pluginManager->uninstallPlugin(targetId);
    if (result) {
        spdlog::info("Successfully uninstalled plugin: {}", pluginName.toStdString());
        // 发送信号通知 UI 更新
        emit pluginListUpdated();
    } else {
        spdlog::error("Failed to uninstall plugin: {}", pluginName.toStdString());
    }
}

void QmlPluginWrapper::openPluginSettings(const QString& pluginName) {
    // TODO: 实现打开插件设置的逻辑
    spdlog::info("Opening settings for plugin: {}", pluginName.toStdString());
}

void QmlPluginWrapper::requestPluginList() {
    // 触发重新扫描插件
    m_pluginManager->scanAndLoadAll();
}

void QmlPluginWrapper::onPluginsChanged() {
    // 将底层变化通知到 QML 层
    emit pluginListUpdated();
}

} // namespace mod