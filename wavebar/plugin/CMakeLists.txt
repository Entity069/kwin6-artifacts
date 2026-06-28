cmake_minimum_required(VERSION 3.21)
project(wavebar_cava LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Qml)
set(QML_MODULE_DIR "${QT6_QML_DIR}/entity069/wavebar/cava")

set(CMAKE_INSTALL_RPATH "$ORIGIN")
set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)
set(BUILD_QML_DIR "${CMAKE_BINARY_DIR}/entity069/wavebar/cava")


qt_add_qml_module(wavebar_cava
    URI entity069.wavebar.cava
    VERSION 1.0
    PLUGIN_TARGET wavebar_cava
    OUTPUT_DIRECTORY "${BUILD_QML_DIR}"
    SOURCES
        src/cavamodel.h
        src/cavamodel.cpp
)


target_link_libraries(wavebar_cava PRIVATE Qt6::Core Qt6::Qml)

target_include_directories(wavebar_cava PRIVATE src)

set_target_properties(wavebar_cava PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${BUILD_QML_DIR}"
)



install(FILES
    "${BUILD_QML_DIR}/libwavebar_cava.so"
    "${BUILD_QML_DIR}/qmldir"
    DESTINATION "${QML_MODULE_DIR}"
)
