project(skynet)

include_directories(../3rd/lua)
include_directories(../skynet-src)

if (MSVC)
	include_directories(../3rd/pthread-win32/include)
	include_directories(../3rd/posix)
	add_definitions(-DLUA_BUILD_AS_DLL)
	add_definitions(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
else (MSVC)
	set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Wextra -fPIC --shared")
	set (CMAKE_C_FLAGS_DEBUG "-g -O0")
	set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -Wextra -fPIC --shared")
	set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
endif (MSVC)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
	add_definitions(-D_DEBUG)
ENDIF()

file(GLOB SKYNET_H *.h)
aux_source_directory(. SKYNET_C)
list(REMOVE_ITEM SKYNET_C ./lua-clientsocket.c ./lua-bson.c)

add_library(skynet SHARED ${SKYNET_H} ${SKYNET_C})
IF (MSVC)
	target_link_libraries(skynet ws2_32 strawberry)
	target_link_libraries(skynet ../../3rd/pthread-win32/lib/pthread_dll)
ENDIF (MSVC)
add_dependencies(skynet strawberry)


set(BSON_C ./lua-bson.c)
add_library(bson SHARED ${BSON_C})
if (MSVC)
	target_link_libraries(bson ws2_32 strawberry)
endif ()
add_dependencies(bson strawberry)

set_target_properties(skynet bson
	PROPERTIES
	PREFIX ""
	SUFFIX ".so"
	FOLDER "lualib"
	RUNTIME_OUTPUT_DIRECTORY ../../luaclib
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY ../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib
	LIBRARY_OUTPUT_DIRECTORY ../../luaclib
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../luaclib
)
