cmake_minimum_required(VERSION 3.16)

project(AstryonHome)

set(CMAKE_CXX_STANDARD 17)

find_package(Qt6 REQUIRED COMPONENTS Widgets)

add_executable(AstryonHome
    main.cpp
)

target_link_libraries(AstryonHome
    Qt6::Widgets
)
