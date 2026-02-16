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
public:
    explicit PluginManager();

    void                     scanAndLoadAll();
    Q_INVOKABLE bool         togglePlugin(QString pluginId, bool enable);
    Q_INVOKABLE bool         uninstallPlugin(QString pluginId);
    const QList<PluginInfo>& getPlugins() const { return m_plugins; }

    // 获取特定插件的 QML 入口路径
    QString getPluginMainQml(const QString& pluginId);

signals:
    void pluginsChanged();

private:
    const QString     m_defaultDir = "/userdisk/PenMods/plugins";
    QList<PluginInfo> m_plugins;

    bool parseMetadata(const QString& path, PluginInfo& info);
    bool loadSo(PluginInfo& info);
    void setPluginPersistence(const PluginInfo& info, bool enable);

    friend class Singleton<PluginManager>;
};

} // namespace mod