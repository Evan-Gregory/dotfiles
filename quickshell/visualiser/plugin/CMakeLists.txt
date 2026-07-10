cmake_minimum_required(VERSION 3.19)
project(qs-visualiser VERSION 1.0.0 LANGUAGES CXX)

# std::jthread / std::stop_token in audiocollector require C++20
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(VERSION 1.0)

find_package(Qt6 REQUIRED COMPONENTS Core Qml)
find_package(PkgConfig REQUIRED)

# libcava is typically built from source and installed under /usr/local, which
# isn't always on the default pkg-config search path — make sure it's searched.
set(ENV{PKG_CONFIG_PATH} "/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:$ENV{PKG_CONFIG_PATH}")

pkg_check_modules(Pipewire IMPORTED_TARGET libpipewire-0.3 REQUIRED)
pkg_check_modules(Cava IMPORTED_TARGET libcava QUIET)
if(NOT Cava_FOUND)
    pkg_check_modules(Cava IMPORTED_TARGET cava REQUIRED)
endif()

# libcava (and its soname libcava.so.7) lives under /usr/local/lib, which is not
# on the default runtime linker path. Bake its dir into the installed RPATH so
# the module resolves it without any global ld.so / LD_LIBRARY_PATH config.
set(EXTRA_RPATH "${Cava_LIBRARY_DIRS};${Pipewire_LIBRARY_DIRS}")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)

# Resolve the Qt6 QML import dir so Quickshell discovers the module automatically
# (install onto Qt's default QML path — no env var or --import-path needed).
find_program(QTPATHS NAMES qtpaths6 qtpaths)
if(QTPATHS)
    execute_process(COMMAND ${QTPATHS} --query QT_INSTALL_QML
        OUTPUT_VARIABLE _QT_QML_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
if(NOT _QT_QML_DIR)
    set(_QT_QML_DIR "/usr/lib64/qt6/qml")
endif()
set(INSTALL_QMLDIR "${_QT_QML_DIR}" CACHE PATH "Qt6 QML import dir")

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")
qt_standard_project_setup(REQUIRES 6.8)

# Build a QML module and install its lib + plugin + qmldir + typeinfo onto the
# Qt QML import path.
function(qml_module arg_TARGET)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "URI" "SOURCES;LIBRARIES")

    qt_add_qml_module(${arg_TARGET}
        URI ${arg_URI}
        VERSION ${VERSION}
        SOURCES ${arg_SOURCES}
    )

    qt_query_qml_module(${arg_TARGET}
        URI module_uri
        VERSION module_version
        PLUGIN_TARGET module_plugin_target
        TARGET_PATH module_target_path
        QMLDIR module_qmldir
        TYPEINFO module_typeinfo
    )

    message(STATUS "Created QML module ${module_uri}, version ${module_version}")

    # Keep $ORIGIN (sibling module libs) and add the external lib dirs so the
    # installed .so can find libcava.so.7 at runtime.
    set_target_properties(${arg_TARGET} ${module_plugin_target} PROPERTIES
        INSTALL_RPATH "\$ORIGIN;\$ORIGIN/../lib64;${EXTRA_RPATH}")

    set(module_dir "${INSTALL_QMLDIR}/${module_target_path}")
    install(TARGETS ${arg_TARGET} LIBRARY DESTINATION "${module_dir}" RUNTIME DESTINATION "${module_dir}")
    install(TARGETS "${module_plugin_target}" LIBRARY DESTINATION "${module_dir}" RUNTIME DESTINATION "${module_dir}")
    install(FILES "${module_qmldir}" DESTINATION "${module_dir}")
    install(FILES "${module_typeinfo}" DESTINATION "${module_dir}")

    target_link_libraries(${arg_TARGET} PRIVATE Qt::Core Qt::Qml ${arg_LIBRARIES})
endfunction()

# Target name is deliberately NOT "cava" so our backing lib (libvisualiser.so)
# doesn't collide with the external libcava.so. The QML module URI stays "Cava".
qml_module(visualiser
    URI Cava
    SOURCES
        service.hpp service.cpp
        serviceref.hpp serviceref.cpp
        audiocollector.hpp audiocollector.cpp
        audioprovider.hpp audioprovider.cpp
        cavaprovider.hpp cavaprovider.cpp
    LIBRARIES
        PkgConfig::Pipewire
        PkgConfig::Cava
)
