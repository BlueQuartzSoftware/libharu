include("${CMAKE_CURRENT_LIST_DIR}/libharuLibTargets.cmake")


if(@libharu_ENABLE_HDF5_SUPPORT@)
  include("${CMAKE_CURRENT_LIST_DIR}/libharuHDFLibTargets.cmake")
endif()

set(libharu_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}/../../../include")
set(libharu_LIB_DIRS "${CMAKE_CURRENT_LIST_DIR}/../../../lib;${CMAKE_CURRENT_LIST_DIR}/../../../bin")

set(libharu_BUILD_SHARED_LIBS "@LIBHPDF_SHARED@")

