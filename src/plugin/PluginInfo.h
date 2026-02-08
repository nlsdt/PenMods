#pragma once
#include <QJsonObject>
#include <QString>

namespace mod {
struct PluginInfo {
    QString id;
    QString name;
    QString version;
    QString author;
    QString mainQml;
    QString mainSo;
    QString icon;
    QString path;
    bool    isLoaded = false;
};
} // namespace mod