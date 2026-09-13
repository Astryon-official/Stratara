#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "services/BluetoothManager.h"
#include "services/ControllerManager.h"
#include "services/SettingsLauncher.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    ControllerManager controllerManager;
    SettingsLauncher settingsLauncher;
    BluetoothManager bluetoothManager;

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(
        "controllerManager",
        &controllerManager
    );

    engine.rootContext()->setContextProperty(
        "settingsLauncher",
        &settingsLauncher
    );

    engine.rootContext()->setContextProperty(
        "bluetoothManager",
        &bluetoothManager
    );

    engine.loadFromModule(
        "Stratara",
        "StrataraShell"
    );

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
