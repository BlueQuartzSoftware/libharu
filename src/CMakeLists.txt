# src/CMakeLists.txt
#
# Copyright (C) 2008  Werner Smekal
#
# create library
# =======================================================================
# libharu source files
# =======================================================================
set(
  LIBHPDF_SRCS
  	hpdf_annotation.c
  	hpdf_array.c
  	hpdf_binary.c
  	hpdf_boolean.c
  	hpdf_catalog.c
  	hpdf_destination.c
  	hpdf_dict.c
  	hpdf_doc_png.c
  	hpdf_doc.c
  	hpdf_encoder_cns.c
  	hpdf_encoder_cnt.c
  	hpdf_encoder_jp.c
  	hpdf_encoder_kr.c
  	hpdf_encoder.c
  	hpdf_encrypt.c
  	hpdf_encryptdict.c
  	hpdf_error.c
  	hpdf_ext_gstate.c
  	hpdf_font_cid.c
  	hpdf_font_tt.c
  	hpdf_font_type1.c
  	hpdf_font.c
  	hpdf_fontdef_base14.c
  	hpdf_fontdef_cid.c
  	hpdf_fontdef_cns.c
  	hpdf_fontdef_cnt.c
  	hpdf_fontdef_jp.c
  	hpdf_fontdef_kr.c
  	hpdf_fontdef_tt.c
  	hpdf_fontdef_type1.c
  	hpdf_fontdef.c
  	hpdf_gstate.c
	hpdf_image_ccitt.c
  	hpdf_image_png.c
  	hpdf_image.c
  	hpdf_info.c
  	hpdf_list.c
  	hpdf_mmgr.c
  	hpdf_name.c
  	hpdf_namedict.c
  	hpdf_null.c
  	hpdf_number.c
  	hpdf_objects.c
  	hpdf_outline.c
  	hpdf_page_label.c
  	hpdf_page_operator.c
  	hpdf_pages.c
  	hpdf_real.c
  	hpdf_streams.c
  	hpdf_string.c
  	hpdf_u3d.c
  	hpdf_utils.c
  	hpdf_xref.c
  	hpdf_pdfa.c
	hpdf_3dmeasure.c
	hpdf_exdata.c
	hpdf_encoder_utf.c
)

# =======================================================================
# create static and shared haru library
# =======================================================================
set(install_dir "bin")
set(lib_install_dir "lib")
set(extra_install_dir "lib")
set(include_install_dir "include")
set(top_install_dir "")
if(WIN32)
	set(install_dir "bin")
	set(lib_install_dir "lib")
	set(extra_install_dir "bin")
	set(include_install_dir "include")
	set(top_install_dir "")
endif()

set(targetName hpdf)
add_library(${targetName} ${LIB_TYPE} ${LIBHPDF_SRCS})
target_include_directories(${targetName}
				PRIVATE
				${libharu_SOURCE_DIR}/include
)

if( NOT LIBHPDF_BUILD_SHARED_LIBS AND MSVC)
set_target_properties( ${targetName}
	PROPERTIES
	DEBUG_OUTPUT_NAME lib${targetName}
	RELEASE_OUTPUT_NAME lib${targetName}  )
endif()
    #-- Set the Debug and Release names for the libraries
set_target_properties( ${targetName}
		PROPERTIES
		DEBUG_POSTFIX _debug 
		)
if(LIBHPDF_BUILD_SHARED_LIBS)
	if(APPLE)
		# use, i.e. don't skip the full RPATH for the build tree
		SET(CMAKE_SKIP_BUILD_RPATH  FALSE)

		# when building, don't use the install RPATH already
		# (but later on when installing)
		SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

		SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

		# add the automatically determined parts of the RPATH
		# which point to directories outside the build tree to the install RPATH
		SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

	endif(APPLE)
	if(CMAKE_SYSTEM_NAME MATCHES "Linux")
		set(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib")
		set_target_properties( ${targetName}
							PROPERTIES
							INSTALL_RPATH \$ORIGIN/../lib)
	endif()

endif( LIBHPDF_BUILD_SHARED_LIBS)

target_link_libraries(hpdf ${ADDITIONAL_LIBRARIES})




install(
	TARGETS ${targetName}
	COMPONENT Applications
	EXPORT libharuTargets
	ARCHIVE DESTINATION lib
	LIBRARY DESTINATION lib
	RUNTIME DESTINATION bin
	BUNDLE DESTINATION "."
)
if(WIN32 AND NOT CYGWIN)
	foreach(addlib ${ADDITIONAL_LIBRARIES})
		install(FILES ${addlib} DESTINATION lib)
	endforeach(addlib)
endif(WIN32 AND NOT CYGWIN)


include(CMakePackageConfigHelpers)

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/libharu/libharuTargetsConfigVersion.cmake"
  VERSION ${libharu_VERSION}
  COMPATIBILITY AnyNewerVersion
)
if(LIBHPDF_SHARED)
  export(EXPORT libharuTargets
    FILE "${CMAKE_CURRENT_BINARY_DIR}/libharu/libharuTargets.cmake"
    NAMESPACE libharu::
  )
endif()

configure_file(cmake/libharuConfig.cmake
  "${CMAKE_CURRENT_BINARY_DIR}/libharu/libharuConfig.cmake"
  @ONLY
)

set(ConfigPackageLocation cmake/libharu)

if(LIBHPDF_SHARED)
  install(EXPORT libharuTargets
    FILE
			libharuTargets.cmake
    NAMESPACE
			libharu::
    DESTINATION
      ${ConfigPackageLocation}
  )

endif()

install(
  FILES
    "${CMAKE_CURRENT_BINARY_DIR}/libharu/libharuConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/libharu/libharuTargetsConfigVersion.cmake"
  DESTINATION
    ${ConfigPackageLocation}
  COMPONENT
    Devel
)


