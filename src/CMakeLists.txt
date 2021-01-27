find_package( Boost 1.46.0 REQUIRED )
find_package(Qt5 COMPONENTS Core Gui Widgets PrintSupport REQUIRED)
find_package( Qwt6)


if(WIN32)
  set( QT_USE_QTMAIN 1 )
endif(WIN32)

#include( ${QT_USE_FILE} )
#add_definitions( ${QT_DEFINITIONS} )

# include_directories(
#   ${QT_INCLUDES}
#   ${QWT6_INCLUDE_DIRS}
#   ${Boost_INCLUDE_DIRS}
#   ${CMAKE_CURRENT_BINARY_DIR}
#   ${CMAKE_CURRENT_SOURCE_DIR}
# )


### PLATFORM SPECIFIC DATA ###
set(OUTPUT_BIN_FOLDER bin)
set(OUTPUT_BIN_FOLDER "${OUTPUT_BIN_FOLDER}" PARENT_SCOPE)
set(OUTPUT_BUNDLE_FOLDER "./")
set(OUTPUT_FRAMEWORKS_FOLDER Frameworks)
set(OUTPUT_RESOURCES_FOLDER_NAME Resources)
set(BUNDLE_ICON)

if(UNIX AND NOT WIN32 AND NOT APPLE)
  set(OUTPUT_BIN_NAME "qsapecng")
  set(OUTPUT_BIN_NAME "${OUTPUT_BIN_NAME}" PARENT_SCOPE)
  #set(OUTPUT_DOC_FOLDER "share/doc/${OUTPUT_BIN_NAME}")
elseif(APPLE)
  set(OUTPUT_BIN_NAME "QSapecNG")
  set(OUTPUT_BIN_NAME "${OUTPUT_BIN_NAME}" PARENT_SCOPE)
  set(OUTPUT_DOC_FOLDER "${OUTPUT_BIN_NAME}.app/Contents/${OUTPUT_RESOURCES_FOLDER_NAME}/doc")
  set(OUTPUT_RES_FOLDER "${OUTPUT_BIN_NAME}.app/Contents/${OUTPUT_RESOURCES_FOLDER_NAME}")
  set(OUTPUT_BUNDLE_NAME "${OUTPUT_BIN_NAME}")

  option(INCLUDE_REQUIRED_LIBRARIES_INTO_BUNDLE "Enable this option to include required external libraries into application Bundle (default ON)" ON)

  set(MACOSX_BUNDLE_ICON_FILE "qsapecng.icns")
  set(BUNDLE_ICON "gui/images/${MACOSX_BUNDLE_ICON_FILE}")
  set_source_files_properties("${CMAKE_CURRENT_SOURCE_DIR}/gui/images/${MACOSX_BUNDLE_ICON_FILE}" PROPERTIES MACOSX_PACKAGE_LOCATION "${OUTPUT_RESOURCES_FOLDER_NAME}")

  # This section is for Info.plist and ${lang}.lproj subfolders
  set(MACOSX_BUNDLE_DISPLAY_NAME "${OUTPUT_BUNDLE_NAME}")
  set(MACOSX_BUNDLE_NAME "${OUTPUT_BUNDLE_NAME}")
  set(MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION_MAJOR}-${PROJECT_VERSION_MINOR}-${PROJECT_VERSION_PATCH}")
  set(MACOSX_BUNDLE_COPYRIGHT "Copyright (C) ${PROJECT_YEAR_COPYRIGHT} ${PROJECT_AUTHOR}")
  set(MACOSX_BUNDLE_VERSION "${PROJECT_VERSION}")
  set(MACOSX_BUNDLE_DEVELOPMENT_REGION "it_IT")
  set(MACOSX_BUNDLE_EXECUTABLE "${OUTPUT_BIN_NAME}")
  set(MACOSX_BUNDLE_IDENTIFIER "net.sourceforge.qsapecng")
  set(MACOSX_BUNDLE_PACKAGE_TYPE "APPL")
  set(MACOSX_BUNDLE_ADDITIONAL "<key>LSHasLocalizedDisplayName</key>\n<string>1</string>") # TODO da ritestare
  configure_file("${PROJECT_SOURCE_DIR}/cmake/MacOSXBundle_Info.plist.in" "${CMAKE_CURRENT_BINARY_DIR}/Info.plist" @ONLY)

  # this section is to fixup the bundle after it has been created
  set(FIXUP_BUNDLE_PATH "${PROJECT_BINARY_DIR}/${OUTPUT_BIN_FOLDER}/${OUTPUT_BIN_NAME}.app")
  set(FIXUP_BUNDLE_LIBS "")
  set(FIXUP_BUNDLE_DIRS "${QWT_ROOT_DIR}/lib")
  configure_file("${PROJECT_SOURCE_DIR}/cmake/MacOSXBundle_fixup_bundle.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/fixup_bundle.cmake" @ONLY)

  if(INCLUDE_REQUIRED_LIBRARIES_INTO_BUNDLE)
    add_custom_target(fixup_bundle ALL COMMAND "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/fixup_bundle.cmake")
  else(INCLUDE_REQUIRED_LIBRARIES_INTO_BUNDLE)
    add_custom_target(fixup_bundle COMMAND "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/fixup_bundle.cmake")
    message(STATUS "You can execute 'make fixup_bundle' to manually fixup the created bundle before distributing it")
  endif(INCLUDE_REQUIRED_LIBRARIES_INTO_BUNDLE)
elseif(WIN32)
  set(OUTPUT_BIN_NAME "QSapecNG")
  set(OUTPUT_BIN_NAME "${OUTPUT_BIN_NAME}" PARENT_SCOPE)
  #set(OUTPUT_DOC_FOLDER "doc")

  unset(QT_DLL_DIR CACHE)
  find_path(QT_DLL_DIR
    NAMES
      "QtCore${QT_VERSION_MAJOR}.dll"
      "QtGui${QT_VERSION_MAJOR}.dll"
    PATHS
      "${QT_BINARY_DIR}"
      "${QT_LIBRARY_DIR}"
      "${QT_LIBRARY_DIR}/../bin"
    DOC "path of the Qt DLL files to be included in the binary packages"
    NO_DEFAULT_PATH
  )

  unset(QWT_DLL_DIR CACHE)
  find_path(QWT_DLL_DIR
    NAMES "qwt.dll"
    PATHS
      "${QWT_INCLUDE_DIR}/../lib"
      "${QWT_INCLUDE_DIR}/../bin"
    PATH_SUFFIXES lib bin
    ENV PATH
    DOC "path of the Qwt DLL files to be included in the binary packages"
  )

  if(NOT QT_DLL_DIR STREQUAL "QT_DLL_DIR-NOTFOUND" AND NOT QT_CONFIG MATCHES "static")
    option(INCLUDE_QT_DLL_IN_BIN_PACKAGE "Enable this option to include Qt DLL files in binary packages (default ON)" ON)
  else(NOT QT_DLL_DIR STREQUAL "QT_DLL_DIR-NOTFOUND" AND NOT QT_CONFIG MATCHES "static")
    unset(INCLUDE_QT_DLL_IN_BIN_PACKAGE CACHE)
    set(INCLUDE_QT_DLL_IN_BIN_PACKAGE OFF)
    mark_as_advanced(INCLUDE_QT_DLL_IN_BIN_PACKAGE)
    mark_as_advanced(QT_DLL_DIR)
  endif(NOT QT_DLL_DIR STREQUAL "QT_DLL_DIR-NOTFOUND" AND NOT QT_CONFIG MATCHES "static")

  if(NOT QWT_DLL_DIR STREQUAL "QWT_DLL_DIR-NOTFOUND")
    option(INCLUDE_QWT_DLL_IN_BIN_PACKAGE "Enable this option to include Qwt DLL files in binary packages (default ON)" ON)
  else(NOT QWT_DLL_DIR STREQUAL "QWT_DLL_DIR-NOTFOUND")
    unset(INCLUDE_QWT_DLL_IN_BIN_PACKAGE CACHE)
    set(INCLUDE_QWT_DLL_IN_BIN_PACKAGE OFF)
    mark_as_advanced(INCLUDE_QWT_DLL_IN_BIN_PACKAGE)
    mark_as_advanced(QWT_DLL_DIR)
  endif(NOT QWT_DLL_DIR STREQUAL "QWT_DLL_DIR-NOTFOUND")
endif()

# set(
#   LIBS
#   ${LIBS} 
#   ${QT_LIBRARIES}
#   ${QWT_LIBRARIES}
# )

IF(WIN32)
  set(
    LIBS
    ${LIBS}
    Imm32.lib
    Winmm.lib
    ws2_32.lib
  )
ENDIF(WIN32)

#QT5 port of QtPropertyBrowser
#note currently requires a git submodule checkout (possibly not ideal)
add_subdirectory(gui/QtPropertyBrowser)

set(qsapecng_SRCS
  logger/logger.cpp
  model/circuit.cpp
  model/metacircuit.cpp
  parser/ir_circuit.cpp
  parser/crc_circuit.cpp
  functor/rpoly-adapter.cpp
  functor/rpoly.cpp
  gui/qsapecng.cpp
  gui/settings.cpp
  gui/qsapecngwindow.cpp
  gui/configdialog/configdialog.cpp
  gui/configdialog/configpage.cpp
  gui/sidebarmodel.cpp
  gui/sidebarview.cpp
  gui/delegate.cpp
  gui/editor/schematiceditor.cpp
  gui/editor/undoredocommand.cpp
  gui/editor/schematicsceneparser.cpp
  gui/editor/schematicscene.cpp
  gui/editor/graphicsnode.cpp
  gui/editor/component.cpp
  gui/editor/label.cpp
  gui/editor/wire.cpp
  gui/editor/item.cpp
  gui/workplane/workplane.cpp
  gui/qsapecng.qrc
  gui/qsapecng.rc
)



set( CMAKE_RUNTIME_OUTPUT_DIRECTORY "../${OUTPUT_BIN_FOLDER}" )

add_executable(
  qsapecng WIN32 MACOSX_BUNDLE
  ${qsapecng_SRCS}
  "${BUNDLE_ICON}"
# qtcreator lacks a proper file management for software based on cmake,
# this is a workaround to include file within the project tree
# see also files statements.
  ${DOXY}
)

target_link_libraries( qsapecng Qt5::Core Qt5::Gui Qt5::Widgets Qt5::PrintSupport Qwt6::Qwt6 QtPropertyBrowser)
target_include_directories( qsapecng PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})
set_target_properties(qsapecng PROPERTIES AUTOMOC ON AUTORCC ON)

set_target_properties(qsapecng
  PROPERTIES
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_BINARY_DIR}/Info.plist"
    OUTPUT_NAME "${OUTPUT_BIN_NAME}"
)

install(
  TARGETS qsapecng
  RUNTIME DESTINATION "${OUTPUT_BIN_FOLDER}"
  BUNDLE DESTINATION "${OUTPUT_BUNDLE_FOLDER}"
)

if(UNIX AND NOT APPLE AND NOT WIN32)
  install(
    FILES gui/images/qsapecng.desktop
    DESTINATION share/applications
  )
  install(
    FILES gui/images/qsapecng-16x16.png
    DESTINATION share/icons/hicolor/16x16/apps
    RENAME qsapecng.png
  )
  install(
    FILES gui/images/qsapecng-22x22.png
    DESTINATION share/icons/hicolor/22x22/apps
    RENAME qsapecng.png
  )
  install(
    FILES gui/images/qsapecng-32x32.png
    DESTINATION share/icons/hicolor/32x32/apps
    RENAME qsapecng.png
  )
  install(
    FILES gui/images/qsapecng-48x48.png
    DESTINATION share/icons/hicolor/48x48/apps
    RENAME qsapecng.png
  )
  install(
    FILES gui/images/qsapecng-64x64.png
    DESTINATION share/icons/hicolor/64x64/apps
    RENAME qsapecng.png
  )
  install(
    FILES gui/images/qsapecng-128x128.png
    DESTINATION share/icons/hicolor/128x128/apps
    RENAME qsapecng.png
  )
  install(
    FILES gui/images/qsapecng-256x256.png
    DESTINATION share/icons/hicolor/256x256/apps
    RENAME qsapecng.png
  )
  install(
    FILES gui/images/qsapecng.svg
    DESTINATION share/icons/hicolor/scalable/apps
  )
endif(UNIX AND NOT APPLE AND NOT WIN32)

if(WIN32)
  if(INCLUDE_QT_DLL_IN_BIN_PACKAGE)
    install(
      FILES
        "${QT_DLL_DIR}/QtCore${QT_VERSION_MAJOR}.dll"
        "${QT_DLL_DIR}/QtGui${QT_VERSION_MAJOR}.dll"
      DESTINATION "${OUTPUT_BIN_FOLDER}"
    )
  endif(INCLUDE_QT_DLL_IN_BIN_PACKAGE)

  if(INCLUDE_QWT_DLL_IN_BIN_PACKAGE)
    install(
      FILES "${QWT_DLL_DIR}/qwt.dll"
      DESTINATION "${OUTPUT_BIN_FOLDER}"
    )
  endif(INCLUDE_QWT_DLL_IN_BIN_PACKAGE)
endif(WIN32)

if(APPLE)
  add_dependencies(fixup_bundle qsapecng)

  install(
    FILES
      "${PROJECT_SOURCE_DIR}/LICENSE"
      "${PROJECT_SOURCE_DIR}/README"
    DESTINATION "${OUTPUT_DOC_FOLDER}"
  )

  #install(FILES gui/images/qsapecng.svg DESTINATION "${OUTPUT_RES_FOLDER}")
  install(FILES "${PROJECT_SOURCE_DIR}/cmake/DS_Store" DESTINATION "${OUTPUT_BUNDLE_FOLDER}" RENAME .DS_Store)

  # Questa parte serve quando ci saranno i file con le stringhe tradotte in altre lingue
  # dato che ho fatto copia-incolla da altro progetto lo lascio.
  #
  # file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/InfoPlist.strings" "CFBundleDisplayName = \"${MACOSX_BUNDLE_DISPLAY_NAME}\";\nCFBundleName = \"${MACOSX_BUNDLE_NAME}\";\nNSHumanReadableCopyright = \"${MACOSX_BUNDLE_COPYRIGHT}\";\nCFBundleShortVersionString = \"${MACOSX_BUNDLE_SHORT_VERSION_STRING}\";")
  # foreach(lang_loop IN LISTS TRANSLATIONS)
  #   if(${lang_loop} MATCHES "qsapecng_([a-z][a-z](_[A-Z][A-Z])?)\\.")
  #     string(REGEX REPLACE ".*lang/qsapecng_([a-z][a-z](_[A-Z][A-Z])?)\\..*" "\\1" lang "${lang_loop}")
  #     configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/MacOSXBundle_locversion.plist.in" "${CMAKE_CURRENT_BINARY_DIR}/${lang}.lproj/locversion.plist" @ONLY)
  #     install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${lang}.lproj/locversion.plist" DESTINATION "${OUTPUT_RES_FOLDER}/${lang}.lproj")
  #     install(FILES "${CMAKE_CURRENT_BINARY_DIR}/InfoPlist.strings" DESTINATION "${OUTPUT_RES_FOLDER}/${lang}.lproj")
  #   endif(${lang_loop} MATCHES "qsapecng_([a-z][a-z](_[A-Z][A-Z])?)\\.")
  # endforeach(lang_loop)
endif(APPLE)
