#pragma once

#include "PluginManager.h"
#include "common/service/Singleton.h"
#include <QJSEngine>
#include <QObject>
#include <QQmlEngine>

namespace mod {

/**
 * @brief 为 QML 提供插件管理功能的包装类
 */
class QmlPluginWrapper : public QObject, public Singleton<QmlPluginWrapper> {
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(PluginManager)

public:
    explicit QmlPluginWrapper(QObject* parent = nullptr);

    // QML 可调用的方法
    Q_INVOKABLE int         getPluginCount();
    Q_INVOKABLE QJsonObject getPluginInfo(int index);
    Q_INVOKABLE bool        setPluginEnabled(const QString& pluginName, bool enabled);
    Q_INVOKABLE void        uninstallPlugin(const QString& pluginName);
    Q_INVOKABLE void        openPluginSettings(const QString& pluginName);
    Q_INVOKABLE void        requestPluginList();

signals:
    // 通知 QML 层插件列表已更新
    void pluginListUpdated();

    // 通知 QML 层插件状态已改变
    void pluginStateChanged(const QString& pluginName, bool newState);

private slots:
    // 响应底层插件管理器的变化
    void onPluginsChanged();

private:
    PluginManager* m_pluginManager;
    friend class Singleton<QmlPluginWrapper>;
};

} // namespace mod
