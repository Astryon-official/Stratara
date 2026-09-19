cmake_minimum_required(VERSION 3.21)

project(Stratara VERSION 0.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS
    Quick
    Positioning
)

find_package(PkgConfig REQUIRED)

pkg_check_modules(BLUEZQT REQUIRED KF6BluezQt)

find_package(SDL3 REQUIRED)

qt_standard_project_setup()

qt_add_executable(stratara-app
    main.cpp

    services/ControllerManager.cpp
    services/ControllerManager.h

    services/SettingsLauncher.cpp
    services/SettingsLauncher.h

    services/BluetoothManager.cpp
    services/BluetoothManager.h

    ${CMAKE_CURRENT_SOURCE_DIR}/services/SystemManager.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/services/SystemManager.h
)

target_include_directories(stratara-app PRIVATE
    ${BLUEZQT_INCLUDE_DIRS}
)

target_link_directories(stratara-app PRIVATE
    ${BLUEZQT_LIBRARY_DIRS}
)

qt_add_qml_module(stratara-app
    URI Stratara
    VERSION 1.0

QML_FILES
    shell/StrataraShell.qml
    shell/components/GlassCard.qml
    shell/components/SystemButton.qml
    shell/components/PanelOption.qml
    shell/components/PanelAction.qml
    shell/panels/LiveTV/LiveTVPanel.qml

    RESOURCES
        icons/settings.svg
)

target_link_libraries(stratara-app PRIVATE
    Qt6::Quick
    Qt6::Positioning
    ${BLUEZQT_LIBRARIES}
    SDL3::SDL3
)
