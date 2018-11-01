project(client)

aux_source_directory(. CLIENT_C)

include_directories(../foundation)
include_directories(../3rd/lua)
include_directories(../skynet-src)

IF(MSVC)
	include_directories(../3rd/pthread-win32)
	include_directories(../3rd/posix)
	add_definitions(-DLUA_BUILD_AS_DLL)
	add_definitions(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK -D_CRT_SECURE_NO_WARNINGS)

ELSE(MSVC)
	set (CMAKE_C_FLAGS "-std=gnu99 -Wall -fPIC --shared")
	set (CMAKE_C_FLAGS_DEBUG "-g -O0")
	set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -fPIC --shared")
	set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF(MSVC)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
	add_definitions(-D_DEBUG)
ENDIF()

add_library(client SHARED ${CLIENT_C})
set_target_properties(client PROPERTIES PREFIX "")
set_target_properties(client PROPERTIES SUFFIX ".so")
set_target_properties(client PROPERTIES FOLDER "lualib")
set_target_properties(client PROPERTIES 
	RUNTIME_OUTPUT_DIRECTORY ../../luaclib
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY ../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)

IF(MSVC)
	target_link_libraries(client ws2_32 ../../strawberry)
ENDIF()

add_dependencies(client strawberry)
