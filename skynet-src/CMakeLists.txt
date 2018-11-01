project(strawberry)

include_directories(.)
include_directories(../3rd/lua)

IF(MSVC)
	include_directories(../3rd/posix)
	include_directories(../3rd/pthread-win32)
	add_definitions(-DLUA_BUILD_AS_DLL)
	add_definitions(-D_CRT_SECURE_NO_WARNINGS)
	add_definitions(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ELSE(MSVC)
	include_directories(../3rd/jemalloc/include/jemalloc)
	add_definitions(-DLUA_USE_LINUX)
	set(CMAKE_C_FLAGS "-std=gnu99 -Wall -Wextra -Wl,-E")
	set(CMAKE_C_FLAGS_DEBUG "-g -O0")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Wl,-E")
	set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF(MSVC)

if(CMAKE_BUILD_TYPE MATCHES "Debug")
	add_definitions(-D_DEBUG)
endif()

# target
set ( POSIX_CXX ../3rd/posix/cpoll/cpoll.cpp)
file ( GLOB POSIX_H ../3rd/posix/*.h)
file ( GLOB POSIX_C ../3rd/posix/*.c)

file(GLOB LIBLUA_H ../3rd/lua/*.h)
aux_source_directory(../3rd/lua LIBLUA_C)
list(REMOVE_ITEM LIBLUA_C ../3rd/lua/luac.c ../3rd/lua/lua.c)

file(GLOB STRAWBERRY_H *.h)
file(GLOB STRAWBERRY_C *.c)

source_group("posix" FILES ${POSIX_H} ${POSIX_C})
source_group("posix\\cpoll" FILES ${POSIX_CXX})
source_group("lua" FILES ${LIBLUA_H} ${LIBLUA_C})
source_group("skynet" FILES ${STRAWBERRY_H} ${STRAWBERRY_C})
IF(MSVC)
	add_executable(strawberry ${POSIX_H} ${POSIX_C} ${POSIX_CXX} ${LIBLUA_H} ${LIBLUA_C} ${STRAWBERRY_H} ${STRAWBERRY_C})
	set_target_properties(strawberry PROPERTIES LINK_FLAGS "/DEF:\"../../skynet-src/skynet.def\"")
	target_link_libraries(strawberry ws2_32 ../../3rd/pthread-win32/bin/x64_MSVC2015.Debug/pthread_dll)
ELSE(MSVC)
	add_executable(strawberry ${LIBLUA_H} ${LIBLUA_C} ${STRAWBERRY_H} ${STRAWBERRY_C})
	find_library(JEMALLOC_LIB jemalloc_pic ../3rd/jemalloc/lib NO_DEFAULT_PATH)
	target_link_libraries(${JEMALLOC_LIB})
	target_link_libraries(strawberry pthread m dl rt)
ENDIF()

set_target_properties(strawberry 
	PROPERTIES
	ENABLE_EXPORTS ON
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../..
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../..
)
