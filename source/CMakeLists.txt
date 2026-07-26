cmake_minimum_required(VERSION 3.16)

project(AstryonHome)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Qml)

qt_add_executable(AstryonHomeApp
    main.cpp
    core/AstryonCore.cpp
    ui/AstryonUI.cpp
)

qt_add_qml_module(AstryonHomeApp
    URI AstryonHome
    VERSION 1.0
    QML_FILES
        qml/screens/Home.qml
)

target_link_libraries(AstryonHomeApp PRIVATE
    Qt6::Quick
    Qt6::Qml
)
