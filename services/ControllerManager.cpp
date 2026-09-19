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
    const bool nameDidChange = m_name != name;

    m_connected = connected;
    m_name = name;

    if (connectionChanged)
        emit connectedChanged();

    if (nameDidChange)
        emit nameChanged();

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

SDL_Joystick *joystick = SDL_GetGamepadJoystick(m_gamepad);
const char *name = joystick ? SDL_GetJoystickName(joystick) : nullptr;

const SDL_JoystickID joystickId = SDL_GetGamepadID(m_gamepad);

const SDL_GamepadType mappedType =
    SDL_GetGamepadTypeForID(joystickId);

const SDL_GamepadType realType =
    SDL_GetRealGamepadTypeForID(joystickId);

const Uint16 vendor =
    SDL_GetGamepadVendorForID(joystickId);

const Uint16 product =
    SDL_GetGamepadProductForID(joystickId);

const char *mappedTypeName =
    SDL_GetGamepadStringForType(mappedType);

const char *realTypeName =
    SDL_GetGamepadStringForType(realType);

setConnected(true, QString::fromUtf8(name ? name : "Xbox Controller"));

SDL_Log("Stratara ControllerManager: connected: %s",
        name ? name : "Xbox Controller");

SDL_Log("Stratara ControllerManager: mapped type: %s",
        mappedTypeName ? mappedTypeName : "Unknown");

SDL_Log("Stratara ControllerManager: real type: %s",
        realTypeName ? realTypeName : "Unknown");

SDL_Log("Stratara ControllerManager: vendor: 0x%04X, product: 0x%04X",
        vendor, product);
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
                if (m_gamepad &&
                    event.gdevice.which == SDL_GetGamepadID(m_gamepad)) {
                    closeGamepad();
                    }
                    break;

            case SDL_EVENT_GAMEPAD_BUTTON_DOWN:
                if (m_gamepad &&
                    event.gbutton.which == SDL_GetGamepadID(m_gamepad)) {

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
                        if (m_gamepad &&
                            event.gbutton.which == SDL_GetGamepadID(m_gamepad)) {
                            emit buttonReleased(static_cast<int>(event.gbutton.button));
                            }
                            break;

                    case SDL_EVENT_GAMEPAD_AXIS_MOTION:
                        // Stratara uses D-pad-only navigation.
                        // Stick movement is deliberately ignored.
                        if (m_gamepad &&
                            event.gaxis.which == SDL_GetGamepadID(m_gamepad)) {
                            emit axisMoved(
                                static_cast<int>(event.gaxis.axis),
                                           static_cast<double>(event.gaxis.value) / 32767.0
                            );
                            }
                            break;

                    default:
                        break;
        }
    }
}
