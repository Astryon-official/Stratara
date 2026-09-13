#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "services/ControllerManager.h"
#include "services/SettingsLauncher.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    ControllerManager controllerManager;
    SettingsLauncher settingsLauncher;

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(
        "controllerManager",
        &controllerManager
    );

    engine.rootContext()->setContextProperty(
        "settingsLauncher",
        &settingsLauncher
    );

    engine.loadFromModule("Stratara", "StrataraShell");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
