﻿project(sproto)

file(GLOB SPROTO_H *.h)
file(GLOB SPROTO_C *.c)

#include_directories(.)
include_directories(../../3rd/lua)
IF(MSVC)
	ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
	ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC)
ELSE(MSVC)
	set (CMAKE_C_FLAGS "-std=gnu99 -Wall -fPIC --shared -Werror")
	set (CMAKE_C_FLAGS_DEBUG "-g -O0")
	set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -fPIC --shared -Werror")
	set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF()

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
	ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

add_library(sproto SHARED ${SPROOT_H} ${SPROTO_C})

set_target_properties(sproto
	PROPERTIES
	PREFIX ""
	SUFFIX ".so"
	FOLDER "lualib"
	RUNTIME_OUTPUT_DIRECTORY ../../../luaclib
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY ../../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../../luaclib
	LIBRARY_OUTPUT_DIRECTORY ../../../luaclib
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../../luaclib
)

if (MSVC)
	target_link_libraries(sproto ws2_32 ../../../strawberry)
endif (MSVC)

add_dependencies(sproto strawberry)
