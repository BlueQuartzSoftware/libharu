include("${CMAKE_CURRENT_LIST_DIR}/libharuTargets.cmake")

set(libharu_INCLUDE_DIRS "${CMAKE_CURRENT_LIST_DIR}/../../../include")
set(libharu_LIB_DIRS "${CMAKE_CURRENT_LIST_DIR}/../../../lib;${CMAKE_CURRENT_LIST_DIR}/../../../bin")

set(libharu_BUILD_SHARED_LIBS "@LIBHPDF_SHARED@")

