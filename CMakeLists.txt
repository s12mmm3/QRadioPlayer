cmake_minimum_required(VERSION 3.16)

project(QRadioPlayer VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zi /EHa")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /DEBUG")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /DEBUG")
    set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})
endif()
if(APPLE)
    if(IOS)
        # Building for iOS
    elseif(UNIX)
        # Building for macOS
        set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")
    else()
    endif()
endif()
if(EMSCRIPTEN)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pthread -s USE_PTHREADS=1 -s SHARED_MEMORY=1")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -s USE_PTHREADS=1 -s SHARED_MEMORY=1")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pthread -s USE_PTHREADS=1 -s SHARED_MEMORY=1")
endif()

set(BUILD_SHARED_LIBS OFF)
set(MUSICAPI_TEST OFF)

add_subdirectory(3rdparty/QCloudMusicApi)
include_directories(3rdparty/QCloudMusicApi)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick QuickControls2 LinguistTools Network Concurrent Widgets Multimedia)

qt_standard_project_setup(REQUIRES 6.8)

set(TS_FILES
    i18n/zh_CN.ts
)

FILE(GLOB TASKS task/*.*)
FILE(GLOB MANAGERS manager/*.*)
FILE(GLOB HEADERS ./*.h)
FILE(GLOB SOURCES ./*.cpp)
FILE(GLOB QRCS ./*.qrc)
set(PROJECT_SOURCES
    ${TASKS}
    ${MANAGERS}
    ${HEADERS}
    ${SOURCES}
    ${QRCS}
    ${TS_FILES}
)

qt_add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE
    ${PROJECT_SOURCES}
)
if(EMSCRIPTEN)
    target_link_options(${PROJECT_NAME} PUBLIC -sASYNCIFY -Os)
endif()
set(QML_SINGLETONS
    "qmls/singletons/ToolSingleton.qml"
)
set_source_files_properties(${QML_SINGLETONS}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

set(QML_FILES
    "Main.qml"

    "qmls/common/ScrollablePage.qml"

    "qmls/setting/AccountMenu.qml"
    "qmls/setting/AboutDialog.qml"
    "qmls/setting/SettingsDialog.qml"

    "qmls/radio/MainPage.qml"
    "qmls/radio/AudioControl.qml"
    "qmls/radio/PlaybackControl.qml"
    "qmls/radio/PlaybackRateControl.qml"
    "qmls/radio/PlaybackSeekControl.qml"
)
if(EMSCRIPTEN)
    set(FONTS
        "fonts/Alibaba-PuHuiTi-Medium.ttf"
    )
else()
    set(FONTS)
endif()
set(RESOURCES
    "icons/gallery/20x20/back.png"
    "icons/gallery/20x20/drawer.png"
    "icons/gallery/20x20/menu.png"
    "icons/gallery/20x20@2/back.png"
    "icons/gallery/20x20@2/drawer.png"
    "icons/gallery/20x20@2/menu.png"
    "icons/gallery/20x20@3/back.png"
    "icons/gallery/20x20@3/drawer.png"
    "icons/gallery/20x20@3/menu.png"
    "icons/gallery/20x20@4/back.png"
    "icons/gallery/20x20@4/drawer.png"
    "icons/gallery/20x20@4/menu.png"
    "icons/gallery/index.theme"
    "qtquickcontrols2.conf"
)
qt_add_qml_module(${PROJECT_NAME}
    URI main
    NO_RESOURCE_TARGET_PATH
    QML_FILES ${QML_FILES} ${QML_SINGLETONS}
    RESOURCES ${RESOURCES} ${FONTS}
)

if (ANDROID)
    include(FetchContent)
    FetchContent_Declare(
        android_openssl
        DOWNLOAD_EXTRACT_TIMESTAMP true
        URL https://github.com/KDAB/android_openssl/archive/refs/heads/master.zip
        )
    FetchContent_MakeAvailable(android_openssl)
    include(${android_openssl_SOURCE_DIR}/android_openssl.cmake)

    add_android_openssl_libraries(${PROJECT_NAME})
else()

endif()
target_compile_definitions(${PROJECT_NAME} PRIVATE
    PROJECT_NAME="${PROJECT_NAME}"
    QT_MESSAGELOGCONTEXT
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
    Qt6::Concurrent
    Qt6::Widgets
    Qt6::Multimedia
    QCloudMusicApi
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(${PROJECT_NAME} PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appCMakeTest
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
