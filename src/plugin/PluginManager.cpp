#include "PluginManager.h"
#include "QmlPluginWrapper.h"
#include "common/Event.h"
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLibrary>
#include <QQmlContext>
#include <QQuickView>

namespace mod {

PluginManager::PluginManager() : Logger("PluginManager") {
    connect(&Event::getInstance(), &Event::beforeUiInitialization, [this](QQuickView& view, QQmlContext* context) {
        auto* wrapper = &QmlPluginWrapper::getInstance();
        context->setContextProperty("pluginManager", wrapper);
    });
    scanAndLoadAll();
}

void PluginManager::scanAndLoadAll() {
    m_plugins.clear(); // 清除旧数据，保证列表重载时不重复
    QDir dir(m_defaultDir);
    if (!dir.exists()) {
        dir.mkpath(".");
        return;
    }

    QStringList subDirs = dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);

    for (const QString& subDirName : subDirs) {
        QString    fullPath = dir.absoluteFilePath(subDirName);
        PluginInfo info;
        if (parseMetadata(fullPath, info)) {
            // 检查持久化标记和崩溃标记
            QFile disabledFlag(fullPath + "/.disabled");
            QFile loadingFlag(fullPath + "/.loading");

            // --- 崩溃自愈逻辑 ---
            if (loadingFlag.exists()) {
                // 发现上一次加载时崩溃了！
                spdlog::critical("Plugin {} crashed during last startup. Auto-disabling.", info.id.toStdString());

                // 1. 标记为禁用
                setPluginPersistence(info, false);
                // 2. 清除加载中标记，防止下次还报崩溃提示
                loadingFlag.remove();

                info.isEnabled = false;
            } else {
                info.isEnabled = !disabledFlag.exists();
            }
            // --- 崩溃自愈结束 ---

            spdlog::info(
                "Found plugin: {} (ID: {}, Enabled: {})",
                info.name.toStdString(),
                info.id.toStdString(),
                info.isEnabled
            );

            // 如果启用且有 C++ 库，尝试加载
            if (info.isEnabled && !info.mainSo.isEmpty()) {
                if (!loadSo(info)) {
                    // 如果加载失败，强制禁用并写入标记，防止下次启动死循环或崩溃
                    spdlog::warn("Auto-disabling plugin {} due to load failure.", info.id.toStdString());
                    info.isEnabled = false;
                    info.isLoaded  = false;
                    setPluginPersistence(info, false);
                }
            } else if (info.isEnabled && info.mainSo.isEmpty()) {
                // 纯 QML 插件，默认视为已加载
                info.isLoaded = true;
            }

            m_plugins.append(info);
        }
    }
    emit pluginsChanged();
}

bool PluginManager::parseMetadata(const QString& path, PluginInfo& info) {
    QFile file(path + "/metadata.json");
    if (!file.open(QIODevice::ReadOnly)) return false;

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    if (doc.isNull()) return false;

    QJsonObject obj  = doc.object();
    info.id          = obj["id"].toString();
    info.name        = obj["name"].toString();
    info.version     = obj["version"].toString();
    info.author      = obj["author"].toString();
    info.description = obj["description"].toString();
    info.icon        = obj["icon"].toString();
    // 存储绝对路径，方便 QML 加载
    info.mainQml = path + "/" + obj["main_qml"].toString();
    info.mainSo  = obj["main_so"].toString();
    info.path    = path;

    return !info.id.isEmpty();
}

bool PluginManager::loadSo(PluginInfo& info) {
    QString soPath          = info.path + "/" + info.mainSo;
    QString loadingFlagPath = info.path + "/.loading"; // 临时加载标记

    // 1. 准备加载前，先创建标记文件
    QFile loadingFlag(loadingFlagPath);
    if (!loadingFlag.open(QIODevice::WriteOnly)) {
        spdlog::error("Cannot create loading flag for {}", info.id.toStdString());
        return false;
    }
    loadingFlag.close(); // 文件已创建于磁盘

    QLibrary* lib = new QLibrary(soPath);
    // 这里可以把 lib 指针存入 info 或 map 中管理，防止内存泄漏（此处简化）

    if (lib->load()) {
        typedef void (*InitFunc)();
        InitFunc init = (InitFunc)lib->resolve("init_plugin");
        if (init) {
            init();

            // 2. 初始化成功，删除加载标记
            QFile::remove(loadingFlagPath);

            info.isLoaded = true;
            spdlog::info("Successfully loaded SO: {}", info.id.toStdString());
            return true;
        }
        spdlog::error("No init_plugin symbol in {}", soPath.toStdString());
    } else {
        spdlog::error("Failed to load SO: {}, Error: {}", soPath.toStdString(), lib->errorString().toStdString());
    }

    // 如果运行到这里，说明加载失败（但没崩溃）
    QFile::remove(loadingFlagPath); // 清理标记
    return false;
}

void PluginManager::setPluginPersistence(const PluginInfo& info, bool enable) {
    QString flagPath = info.path + "/.disabled";
    if (enable) {
        // 启用：删除 .disabled 文件
        QFile::remove(flagPath);
    } else {
        // 禁用：创建 .disabled 文件
        QFile file(flagPath);
        if (file.open(QIODevice::WriteOnly)) {
            file.close();
        }
    }
}

bool PluginManager::togglePlugin(QString pluginId, bool enable) {
    for (auto& plugin : m_plugins) {
        if (plugin.id == pluginId) {

            // 更新持久化状态
            setPluginPersistence(plugin, enable);
            plugin.isEnabled = enable;

            // 处理运行时加载/卸载
            if (enable) {
                if (!plugin.isLoaded && !plugin.mainSo.isEmpty()) {
                    if (!loadSo(plugin)) {
                        // 加载失败，回滚状态
                        plugin.isEnabled = false;
                        setPluginPersistence(plugin, false);
                        return false;
                    }
                } else if (plugin.mainSo.isEmpty()) {
                    plugin.isLoaded = true; // 纯 QML 插件
                }
            } else {
                // 禁用逻辑：目前 C++ 无法安全卸载 DLL/SO，
                // 但我们将 isLoaded 设为 false，并发送信号让 QML 知道
                plugin.isLoaded = false;
                spdlog::info(
                    "Plugin marked as disabled (restart required to fully unload memory): {}",
                    pluginId.toStdString()
                );
            }

            emit pluginsChanged(); // 广播变更，让 UI 刷新
            return true;
        }
    }
    return false;
}

QString PluginManager::getPluginMainQml(const QString& pluginId) {
    for (const auto& plugin : m_plugins) {
        if (plugin.id == pluginId) return plugin.mainQml;
    }
    return "";
}

bool PluginManager::uninstallPlugin(QString pluginId) {
    for (auto it = m_plugins.begin(); it != m_plugins.end(); ++it) {
        if (it->id == pluginId) {
            // 先禁用插件，确保没有正在运行的实例
            if (it->isEnabled) {
                togglePlugin(pluginId, false);
            }

            // 删除插件目录及其所有内容
            QDir pluginDir(it->path);
            if (pluginDir.exists()) {
                bool success = pluginDir.removeRecursively();
                if (success) {
                    spdlog::info("Successfully uninstalled plugin: {}", pluginId.toStdString());
                    // 从插件列表中移除
                    m_plugins.erase(it);
                    emit pluginsChanged();
                    return true;
                } else {
                    spdlog::error("Failed to remove plugin directory: {}", it->path.toStdString());
                    return false;
                }
            } else {
                spdlog::warn("Plugin directory does not exist: {}", it->path.toStdString());
                // 即使目录不存在，我们也从内存中移除这个插件信息
                m_plugins.erase(it);
                emit pluginsChanged();
                return true;
            }
        }
    }

    spdlog::error("Plugin not found for uninstallation: {}", pluginId.toStdString());
    return false;
}

} // namespace mod