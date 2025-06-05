cmake_minimum_required(VERSION 3.16)

project(app_ai VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appapp_ai
    main.cpp
    ApiClient.cpp
)
target_link_libraries(appapp_ai PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Network
    Qt6::Concurrent
)

qt_add_qml_module(appapp_ai
    URI app_ai
    VERSION 1.0
    QML_FILES
        Main.qml
        QML_FILES ConversationPage.qml
        QML_FILES SecondPage.qml
        SOURCES
        SOURCES
        SOURCES
        SOURCES
        SOURCES ApiClient.cpp
        SOURCES ApiClient.h
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appapp_ai PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appapp_ai
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appapp_ai
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appapp_ai
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
