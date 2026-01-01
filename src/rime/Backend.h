#ifndef RIME_BACKEND_H
#define RIME_BACKEND_H

#include <QObject>
#include <QQmlEngine>
#include <QQmlContext>

#include "common/service/Singleton.h"
#include "common/service/Logger.h"

#include "RimeWrapper.h"

namespace mod::rime {

class Backend : public QObject, public Singleton<Backend>, private Logger
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit Backend();

    void initialize(QQmlEngine *engine, QJSEngine *scriptEngine);

private:
    RimeWrapper *m_rimeWrapper;
};

} // namespace mod::rime

#endif // RIME_BACKEND_H