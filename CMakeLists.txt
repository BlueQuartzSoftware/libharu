# CMakeLists.txt
#
# Copyright (C) 2008  Werner Smekal
#
# Process this file with cmake to produce Makefiles or project files
# for your specific compiler tool set
#
# TODO:
# - shared and static library
# - packaging
# - devpackage
# =======================================================================
# libharu project
# =======================================================================

if(${CMAKE_MAJOR_VERSION} STREQUAL "3")
  # CMake 3.0 introduces some OS X RPath policies
  cmake_policy(SET CMP0042 NEW)
endif()

project(libharu LANGUAGES C)
set(libharu_VERSION 2.2.0.0)

# determine compiler name
set(COMPILER_LABEL "unknown")
if(CMAKE_COMPILER_IS_GNUCC)
  set(COMPILER_LABEL "gcc")
endif(CMAKE_COMPILER_IS_GNUCC)
if(MSVC)
  set(COMPILER_LABEL "vc")
endif(MSVC)

# information about libharu
set(LIBHPDF_MAJOR 2)
set(LIBHPDF_MINOR 2)
set(LIBHPDF_PATCH 0)
set(LIBHPDF_VERSION ${LIBHPDF_MAJOR}.${LIBHPDF_MINOR}.${LIBHPDF_PATCH})
set(LIBHPDF_DESCRIPTION "libHaru is a free, cross platform, open source library for generating PDF files.")
set(LIBHPDF_PACKAGE_NAME "libHaru-${LIBHPDF_VERSION}-${COMPILER_LABEL}")

# we want cmake version 3.11.0 at least
cmake_minimum_required(VERSION 3.11.0 FATAL_ERROR)

# Location where the haru cmake build system first looks for cmake modules
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/modules)

# ---------- Setup output Directories -------------------------
if(NOT DEFINED CMAKE_LIBRARY_OUTPUT_DIRECTORY)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY
    ${libharu_BINARY_DIR}/Bin
    CACHE PATH
    "Single Directory for all Libraries"
    )
endif()

# --------- Setup the Executable output Directory -------------
if(NOT DEFINED CMAKE_RUNTIME_OUTPUT_DIRECTORY)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY
    ${libharu_BINARY_DIR}/Bin
    CACHE PATH
    "Single Directory for all Executables."
    )
endif()

# --------- Setup the Executable output Directory -------------
if(NOT DEFINED CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY
    ${libharu_BINARY_DIR}/Bin
    CACHE PATH
    "Single Directory for all static libraries."
    )
endif()

#Enable use of Solution Folders
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Build shared libraries
OPTION(LIBHPDF_BUILD_SHARED_LIBS "libHaru: Build Shared Libraries" OFF)
if(WIN32)
  set(LIBHPDF_BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
endif()
set(LIB_TYPE STATIC)
if(LIBHPDF_BUILD_SHARED_LIBS)
    set(LIB_TYPE SHARED)
endif(LIBHPDF_BUILD_SHARED_LIBS)

# =======================================================================
# command line options
# =======================================================================
option(LIBHPDF_EXAMPLES "Build libharu examples" NO)
option(LIBHPDF_DEVPAK "Create DevPackage" NO)

# Enable exceptions on linux if required
# (eg if you are using libharu in a C++ environment,
# and you want your error-callback to throw an exception,
# you will need to enable this for the exception to be
# able to throw through the libharu callstack).
if (CMAKE_COMPILER_IS_GNUCC OR ("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang"))
   option (LIBHPDF_ENABLE_EXCEPTIONS "Enable exceptions" NO)
   if (LIBHPDF_ENABLE_EXCEPTIONS)
      set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fexceptions")
   endif (LIBHPDF_ENABLE_EXCEPTIONS)
endif ()

if(LIBHPDF_DEVPAK AND NOT WIN32)
  message( STATUS "DevPackage only available for Win32. Set LIBHPDF_DEVPAK to OFF." )
  set(LIBHPDF_DEVPAK OFF)
endif(LIBHPDF_DEVPAK AND NOT WIN32)
if(LIBHPDF_DEVPAK AND LIBHPDF_EXAMPLES)
  message( STATUS "Examples are not build for DevPackage. Set LIBHPDF_EXAMPLES to OFF." )
  set(LIBHPDF_EXAMPLES OFF)
endif(LIBHPDF_DEVPAK AND LIBHPDF_EXAMPLES)

# =======================================================================
# look for headers and libraries
# =======================================================================
include(haru)
include(summary)

# check zlib availibility
find_package(ZLIB)
if(ZLIB_FOUND)
  include_directories(${ZLIB_INCLUDE_DIR})
  set(ADDITIONAL_LIBRARIES ${ZLIB_LIBRARIES})
endif(ZLIB_FOUND)
  
# check png availibility
find_package(PNG)
if(PNG_FOUND)
  include_directories(${PNG_INCLUDE_DIR})
  add_definitions(${PNG_DEFINITIONS})
  set(ADDITIONAL_LIBRARIES ${ADDITIONAL_LIBRARIES} ${PNG_LIBRARIES})
endif(PNG_FOUND)


# =======================================================================
# configure header files, add compiler flags
# =======================================================================
# add definitions and directories to include
#if(CMAKE_COMPILER_IS_GNUCC)
#  add_definitions("-Wall")
#endif(CMAKE_COMPILER_IS_GNUCC)
if(MSVC_VERSION GREATER 1399)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_CRT_SECURE_NO_DEPRECATE)
endif(MSVC_VERSION GREATER 1399)
#include_directories(${CMAKE_SOURCE_DIR}/include)


# these are options
option (LIBHPDF_DEBUG "Enable HPDF Debug")
option (LIBHPDF_DEBUG_TRACE "Enable HPDF Debug trace")

# I'll guess what these were supposed to be
set (LIBHPDF_PACKAGE_STRING "${LIBHPDF_PACKAGE_NAME}")
set (LIBHPDF_PACKAGE_VERSION ${LIBHPDF_VERSION})

# I have no idea
set (LIBHPDF_PACKAGE_BUGREPORT "TODO")
set (LIBHPDF_PACKAGE_TARNAME "TODO")

# Just set to 1, we'll assume they are always available.
# If not, then someone will have to add some tests in here to correctly determine
# the headers existance.
set (LIBHPDF_STDC_HEADERS 1)

# Don't do anything with this, it doesn't seem to be used anywhere anyhow
# set (LIBHPDF_size_t ???)

# support all of the different variations of LIBPNG defines in HARU
set (LIBHPDF_HAVE_LIBPNG ${PNG_FOUND})
if (NOT PNG_FOUND)
   set (LIBHPDF_HAVE_NOPNGLIB 1)
   set (HPDF_NOPNGLIB 1)
endif (NOT PNG_FOUND)

# support different zlib defines
set (LIBHPDF_HAVE_LIBZ ${ZLIB_FOUND})
if (NOT ZLIB_FOUND)
   set (LIBHPDF_HAVE_NOZLIB 1)
endif (NOT ZLIB_FOUND)


# create hpdf_config.h
configure_file(
  ${libharu_SOURCE_DIR}/include/hpdf_config.h.cmake
  ${libharu_BINARY_DIR}/include/hpdf_config.h
)
#include_directories(${CMAKE_BINARY_DIR}/include)

# create DevPackage file
if(LIBHPDF_DEVPAK)
  configure_file(
    ${libharu_SOURCE_DIR}/libharu.DevPackage.cmake
    ${libharu_BINARY_DIR}/libharu.DevPackage
  )
endif(LIBHPDF_DEVPAK)
# =======================================================================
# create library and demos
# =======================================================================
add_subdirectory(src)
add_subdirectory(demo)

# =======================================================================
# installation configuration
# =======================================================================
set(
  haru_HDRS
    ${libharu_SOURCE_DIR}/include/hpdf.h
    ${libharu_SOURCE_DIR}/include/hpdf_types.h
    ${libharu_SOURCE_DIR}/include/hpdf_consts.h 
    ${libharu_SOURCE_DIR}/include/hpdf_version.h
    ${libharu_SOURCE_DIR}/include/hpdf_annotation.h
    ${libharu_SOURCE_DIR}/include/hpdf_catalog.h
    ${libharu_SOURCE_DIR}/include/hpdf_conf.h
    ${libharu_SOURCE_DIR}/include/hpdf_destination.h
    ${libharu_SOURCE_DIR}/include/hpdf_doc.h
    ${libharu_SOURCE_DIR}/include/hpdf_encoder.h
    ${libharu_SOURCE_DIR}/include/hpdf_encrypt.h
    ${libharu_SOURCE_DIR}/include/hpdf_encryptdict.h
    ${libharu_SOURCE_DIR}/include/hpdf_error.h
    ${libharu_SOURCE_DIR}/include/hpdf_ext_gstate.h
    ${libharu_SOURCE_DIR}/include/hpdf_font.h
    ${libharu_SOURCE_DIR}/include/hpdf_fontdef.h
    ${libharu_SOURCE_DIR}/include/hpdf_gstate.h
    ${libharu_SOURCE_DIR}/include/hpdf_image.h
    ${libharu_SOURCE_DIR}/include/hpdf_info.h
    ${libharu_SOURCE_DIR}/include/hpdf_list.h
    ${libharu_SOURCE_DIR}/include/hpdf_mmgr.h
    ${libharu_SOURCE_DIR}/include/hpdf_objects.h
    ${libharu_SOURCE_DIR}/include/hpdf_outline.h
    ${libharu_SOURCE_DIR}/include/hpdf_pages.h
    ${libharu_SOURCE_DIR}/include/hpdf_page_label.h
    ${libharu_SOURCE_DIR}/include/hpdf_streams.h
    ${libharu_SOURCE_DIR}/include/hpdf_u3d.h
    ${libharu_SOURCE_DIR}/include/hpdf_utils.h
    ${libharu_SOURCE_DIR}/include/hpdf_pdfa.h
    ${libharu_SOURCE_DIR}/include/hpdf_3dmeasure.h
    ${libharu_SOURCE_DIR}/include/hpdf_exdata.h
    ${CMAKE_BINARY_DIR}/include/hpdf_config.h
)

# install header files
install(FILES ${haru_HDRS} DESTINATION include)

# install various files
install(FILES README CHANGES INSTALL DESTINATION .)
if(NOT LIBHPDF_DEVPAK)
  install(DIRECTORY if DESTINATION .)
endif(NOT LIBHPDF_DEVPAK)
if(LIBHPDF_DEVPAK)
  install(FILES ${CMAKE_BINARY_DIR}/libharu.DevPackage DESTINATION .)
endif(LIBHPDF_DEVPAK)

# =======================================================================
# print out some information
# =======================================================================
#summary()

# =======================================================================
# packing stuff
# =======================================================================
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${LIBHPDF_DESCRIPTION})
set(CPACK_PACKAGE_VENDOR "Werner Smekal")
set(CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/README)
set(CPACK_PACKAGE_VERSION_MAJOR "${LIBHPDF_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${LIBHPDF_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${LIBHPDF_PATCH}")
set(CPACK_PACKAGE_FILE_NAME "libHaru-${LIBHPDF_VERSION}-${COMPILER_LABEL}")

set(CPACK_STRIP_FILES ON)

if(WIN32)
  set(CPACK_GENERATOR ZIP)
else(WIN32)
  set(CPACK_GENERATOR TGZ)
endif(WIN32)

INCLUDE( CPack )
