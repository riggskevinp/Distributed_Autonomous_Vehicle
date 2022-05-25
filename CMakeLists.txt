cmake_minimum_required(VERSION 3.16)
project(Distributed_Autonomous_Vehicle LANGUAGES CXX)

# Download automatically, you can also just copy the conan.cmake file
if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
   message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
   file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/0.18.1/conan.cmake"
                  "${CMAKE_BINARY_DIR}/conan.cmake")
endif()

include(${CMAKE_BINARY_DIR}/conan.cmake)

conan_cmake_autodetect(settings)
message(STATUS ${settings})

conan_cmake_install(PATH_OR_REFERENCE ${CMAKE_SOURCE_DIR}
                    BUILD missing
                    SETTINGS ${settings}
                    INSTALL_FOLDER ${CMAKE_BINARY_DIR})

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
#include(conanbuildinfo.cmake)
conan_basic_setup(TARGETS)

find_package(Protobuf REQUIRED)
add_subdirectory(ProtosExample)

message(STATUS "Protobuf locations")
message(STATUS ${Protobuf_INCLUDE_DIRS})
message(STATUS ${ProtobufMessagesIncludePath})
message(STATUS ${PROTO_SRCS})
message(STATUS ${PROTO_HDRS})

include_directories(${CMAKE_BINARY_DIR} ${ProtobufMessagesIncludePath} ${Protobuf_INCLUDE_DIRS})


set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)


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
    ${PROTO_SRCS}
    ${PROTO_HDRS}
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
        CONAN_PKG::protobuf
)




