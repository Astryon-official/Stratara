#pragma once

#include <QObject>
#include <QString>

struct SDL_Gamepad;

class ControllerManager final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)

public:
    explicit ControllerManager(QObject *parent = nullptr);
    ~ControllerManager() override;

    bool connected() const { return m_connected; }
    QString name() const { return m_name; }

signals:
    void connectedChanged();
    void nameChanged();
    void controllerConnected(const QString &name);
    void controllerDisconnected();
    void buttonPressed(int button);
    void buttonReleased(int button);
    void axisMoved(int axis, double value);
    void actionPressed(const QString &action);

private slots:
    void pollEvents();

private:
    void setConnected(bool connected, const QString &name = {});
    void openGamepad(unsigned int instanceId);
    void closeGamepad();

    SDL_Gamepad *m_gamepad = nullptr;
    bool m_connected = false;
    QString m_name;
};
