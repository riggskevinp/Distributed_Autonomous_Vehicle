cmake_minimum_required(VERSION 3.16)
project(Distributed_Autonomous_Vehicle LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
SET(CMAKE_AUTORCC ON)


if(NOT DEFINED INSTALL_MAPSDIR)
    set(INSTALL_MAPSDIR "examples")
endif()

set(INSTALL_MAPDIR "${INSTALL_MAPSDIR}/mqtt/Vehicle_Mapping")

find_package(Qt5 REQUIRED COMPONENTS Core Gui Mqtt Qml Quick Positioning Location)

set(SOURCE
    ${SOURCE}
    cpp/main.cpp
    cpp/planecontroller.h
    cpp/QmlMqttClient.h
    cpp/QmlMqttClient.cpp
)

add_executable(${PROJECT_NAME}
    ${SOURCE}
    qml.qrc
)


target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt::PositioningPrivate

    )
target_link_libraries(${PROJECT_NAME}
    PUBLIC
        Qt::Core
        Qt::Gui
        Qt::Mqtt
        Qt::Qml
        Qt::Quick
        Qt::Location

)
