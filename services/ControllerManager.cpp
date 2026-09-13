#include "ControllerManager.h"

#include <QTimer>

#include <SDL3/SDL.h>
#include <SDL3/SDL_gamepad.h>

namespace {
constexpr int kPollIntervalMs = 8;
}

ControllerManager::ControllerManager(QObject *parent)
    : QObject(parent)
{
    SDL_SetHint(SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS, "1");

    if (!SDL_Init(SDL_INIT_GAMEPAD)) {
        SDL_Log("Stratara ControllerManager: SDL_Init failed: %s", SDL_GetError());
        return;
    }

    int count = 0;
    SDL_JoystickID *gamepads = SDL_GetGamepads(&count);

    if (gamepads) {
        for (int i = 0; i < count; ++i) {
            if (SDL_IsGamepad(gamepads[i])) {
                openGamepad(gamepads[i]);
                break;
            }
        }
        SDL_free(gamepads);
    }

    auto *timer = new QTimer(this);
    timer->setInterval(kPollIntervalMs);
    connect(timer, &QTimer::timeout, this, &ControllerManager::pollEvents);
    timer->start();
}

ControllerManager::~ControllerManager()
{
    closeGamepad();
    SDL_QuitSubSystem(SDL_INIT_GAMEPAD);
}

void ControllerManager::setConnected(bool connected, const QString &name)
{
    const bool connectionChanged = m_connected != connected;
    const bool nameChanged = m_name != name;

    m_connected = connected;
    m_name = name;

    if (connectionChanged)
        emit connectedChanged();

    if (nameChanged)
	emit ControllerManager::nameChanged();	

    if (connected)
        emit controllerConnected(m_name);
    else
        emit controllerDisconnected();
}

void ControllerManager::openGamepad(unsigned int instanceId)
{
    if (m_gamepad)
        return;

    m_gamepad = SDL_OpenGamepad(static_cast<SDL_JoystickID>(instanceId));
    if (!m_gamepad) {
        SDL_Log("Stratara ControllerManager: SDL_OpenGamepad failed: %s", SDL_GetError());
        return;
    }

    const char *name = SDL_GetGamepadName(m_gamepad);
    setConnected(true, QString::fromUtf8(name ? name : "Xbox Controller"));

    SDL_Log("Stratara ControllerManager: connected: %s", name ? name : "Xbox Controller");
}

void ControllerManager::closeGamepad()
{
    if (m_gamepad) {
        SDL_CloseGamepad(m_gamepad);
        m_gamepad = nullptr;
    }

    if (m_connected || !m_name.isEmpty())
        setConnected(false);
}

void ControllerManager::pollEvents()
{
    SDL_Event event;

    while (SDL_PollEvent(&event)) {
        switch (event.type) {
        case SDL_EVENT_GAMEPAD_ADDED:
            if (!m_gamepad && SDL_IsGamepad(event.gdevice.which))
                openGamepad(event.gdevice.which);
            break;

        case SDL_EVENT_GAMEPAD_REMOVED:
            if (m_gamepad && event.gdevice.which == SDL_GetGamepadID(m_gamepad))
                closeGamepad();
            break;

        case SDL_EVENT_GAMEPAD_BUTTON_DOWN:
            if (m_gamepad && event.gbutton.which == SDL_GetGamepadID(m_gamepad)) {
                emit buttonPressed(static_cast<int>(event.gbutton.button));

                switch (event.gbutton.button) {
                case SDL_GAMEPAD_BUTTON_SOUTH:
                    emit actionPressed("accept");
                    break;
                case SDL_GAMEPAD_BUTTON_EAST:
                    emit actionPressed("cancel");
                    break;
                case SDL_GAMEPAD_BUTTON_DPAD_UP:
                    emit actionPressed("up");
                    break;
                case SDL_GAMEPAD_BUTTON_DPAD_DOWN:
                    emit actionPressed("down");
                    break;
                case SDL_GAMEPAD_BUTTON_DPAD_LEFT:
                    emit actionPressed("left");
                    break;
                case SDL_GAMEPAD_BUTTON_DPAD_RIGHT:
                    emit actionPressed("right");
                    break;
                case SDL_GAMEPAD_BUTTON_GUIDE:
                    emit actionPressed("guide");
                    break;
                default:
                    break;
                }
            }
            break;

        case SDL_EVENT_GAMEPAD_BUTTON_UP:
            if (m_gamepad && event.gbutton.which == SDL_GetGamepadID(m_gamepad))
                emit buttonReleased(static_cast<int>(event.gbutton.button));
            break;

        case SDL_EVENT_GAMEPAD_AXIS_MOTION:
            if (m_gamepad && event.gaxis.which == SDL_GetGamepadID(m_gamepad)) {
                const double value = static_cast<double>(event.gaxis.value) / 32767.0;
                emit axisMoved(static_cast<int>(event.gaxis.axis), value);

                if (event.gaxis.axis == SDL_GAMEPAD_AXIS_LEFTX ||
                    event.gaxis.axis == SDL_GAMEPAD_AXIS_LEFTY) {
                    constexpr double deadzone = 0.65;
                    constexpr double releaseZone = 0.35;

                    if (event.gaxis.axis == SDL_GAMEPAD_AXIS_LEFTX) {
                        if (value < -deadzone)
                            emit actionPressed("left");
                        else if (value > deadzone)
                            emit actionPressed("right");
                    } else {
                        if (value < -deadzone)
                            emit actionPressed("up");
                        else if (value > deadzone)
                            emit actionPressed("down");
                    }

                    Q_UNUSED(releaseZone);
                }
            }
            break;

        default:
            break;
        }
    }
}
