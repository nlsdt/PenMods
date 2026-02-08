#pragma once
#include "PluginInfo.h"
#include "common/service/Logger.h"
#include "common/service/Singleton.h"
#include <QLibrary>
#include <QList>
#include <QObject>

namespace mod {

class PluginManager : public QObject, public Singleton<PluginManager>, private Logger {
    Q_OBJECT
    // 将插件列表暴露给 QML，方便在界面上显示
    Q_PROPERTY(QList<QObject*> pluginObjects READ pluginObjects NOTIFY pluginsChanged)

public:
    explicit PluginManager();

    // 扫描并尝试加载所有插件
    void scanAndLoadAll();

    // 从 QML 调用的方法：手动启用某个插件
    Q_INVOKABLE bool togglePlugin(QString pluginId, bool enable);

signals:
    void pluginsChanged();

private:
    const QString     m_defaultDir = "/userdisk/PenMods/plugins";
    QList<PluginInfo> m_plugins;

    bool parseMetadata(const QString& path, PluginInfo& info);
    bool loadSo(PluginInfo& info);

    // 用于 QML 显示的包装对象（可选，如果需要更复杂的交互）
    QList<QObject*> m_pluginObjects;
    QList<QObject*> pluginObjects() { return m_pluginObjects; }

    friend class Singleton<PluginManager>;
};

} // namespace mod