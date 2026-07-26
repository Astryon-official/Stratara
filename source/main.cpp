#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "core/AstryonCore.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    AstryonCore core;
    core.initialize();

    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/qml/screens/Home.qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() {
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection
    );

    engine.load(url);

    int result = app.exec();

    core.shutdown();

    return result;
}
