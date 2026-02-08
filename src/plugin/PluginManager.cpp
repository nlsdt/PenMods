#include "PluginManager.h"
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
        context->setContextProperty("PluginManager", this);
    });

    scanAndLoadAll();
}

void PluginManager::scanAndLoadAll() {
    QDir dir(m_defaultDir);
    if (!dir.exists()) {
        spdlog::error("Plugins directory does not exist: {}", m_defaultDir.toStdString());
        dir.mkpath("."); // 尝试创建
        return;
    }

    // 只扫描目录
    QStringList subDirs = dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);

    for (const QString& subDirName : subDirs) {
        QString    fullPath = dir.absoluteFilePath(subDirName);
        PluginInfo info;
        if (parseMetadata(fullPath, info)) {
            spdlog::info("Found plugin: {} ({})", info.name.toStdString(), info.id.toStdString());

            // 如果插件有 C++ 部分，尝试加载它
            if (!info.mainSo.isEmpty()) {
                loadSo(info);
            }

            m_plugins.append(info);
        }
    }
    emit pluginsChanged();
}

bool PluginManager::parseMetadata(const QString& path, PluginInfo& info) {
    QFile file(path + "/metadata.json");
    if (!file.open(QIODevice::ReadOnly)) {
        spdlog::warn("Missing metadata.json in {}", path.toStdString());
        return false;
    }

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    if (doc.isNull()) return false;

    QJsonObject obj = doc.object();
    info.id         = obj["id"].toString();
    info.name       = obj["name"].toString();
    info.version    = obj["version"].toString();
    info.mainQml    = path + "/" + obj["main_qml"].toString();
    info.mainSo     = obj["main_so"].toString(); // 相对路径
    info.path       = path;

    return !info.id.isEmpty();
}

bool PluginManager::loadSo(PluginInfo& info) {
    QString   soPath = info.path + "/" + info.mainSo;
    QLibrary* lib    = new QLibrary(soPath);

    if (lib->load()) {
        // 约定：每个插件库必须导出一个初始化函数
        // 例如：extern "C" void init_plugin();
        typedef void (*InitFunc)();
        InitFunc init = (InitFunc)lib->resolve("init_plugin");
        if (init) {
            init(); // 执行插件内部的初始化逻辑
            info.isLoaded = true;
            spdlog::info("Successfully loaded SO for plugin: {}", info.id.toStdString());
            return true;
        } else {
            spdlog::error("Could not resolve init_plugin in {}", soPath.toStdString());
        }
    } else {
        spdlog::error("Failed to load SO: {}, error: {}", soPath.toStdString(), lib->errorString().toStdString());
    }
    return false;
}

bool PluginManager::togglePlugin(QString pluginId, bool enable) {
    for (auto& plugin : m_plugins) {
        if (plugin.id == pluginId) {
            if (enable && !plugin.isLoaded && !plugin.mainSo.isEmpty()) {
                // 启用插件
                return loadSo(plugin);
            } else if (!enable) {
                // 禁用插件 - 这里可能需要额外的卸载逻辑
                // 注意：Qt 的 QLibrary 不提供直接卸载库的功能
                plugin.isLoaded = false;
                spdlog::info("Disabled plugin: {}", pluginId.toStdString());
                return true;
            }
            return plugin.isLoaded == enable;
        }
    }

    spdlog::error("Plugin not found: {}", pluginId.toStdString());
    return false;
}

} // namespace mod