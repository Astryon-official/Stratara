cmake_minimum_required(VERSION 3.21)

project(Stratara VERSION 0.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Positioning)
find_package(SDL3 REQUIRED)

qt_standard_project_setup()

qt_add_executable(stratara-app
    main.cpp
    services/ControllerManager.cpp
    services/ControllerManager.h
    services/SettingsLauncher.cpp
    services/SettingsLauncher.h
)

qt_add_qml_module(stratara-app
    URI Stratara
    VERSION 1.0
    QML_FILES
        shell/StrataraShell.qml
)

target_link_libraries(stratara-app PRIVATE
    Qt6::Quick
    Qt6::Positioning
    SDL3::SDL3
)
