project(strawberry)

include_directories(.)
include_directories(../3rd)
include_directories(../3rd/lua)

IF(MSVC)
	include_directories(../3rd/pthread-win32/include)
	include_directories(posix)
	add_definitions(-DLUA_BUILD_AS_DLL)
	add_definitions(-D_CRT_SECURE_NO_WARNINGS)
	add_definitions(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC)
	add_definitions(-DUSE_PTHREAD)
	#add_definitions(-DUSE_PTHREAD_LOCK)
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
set (POSIX_H 
	posix/win/cpoll/cpoll.h
	posix/dlfcn.h
	posix/unistd.h
)
set (POSIX_C
	posix/win/cpoll/cpoll.cpp
	posix/win/timeutils.c
	posix/dlfcn.c
	posix/unistd.c
)

file(GLOB LIBLUA_H ../3rd/lua/*.h)
aux_source_directory(../3rd/lua LIBLUA_C)
list(REMOVE_ITEM LIBLUA_C ../3rd/lua/luac.c ../3rd/lua/lua.c)

file(GLOB STRAWBERRY_H *.h)
file(GLOB STRAWBERRY_C *.c)


macro(source_group_by_dir proj_dir source_files)
    if(MSVC OR APPLE)
        get_filename_component(sgbd_cur_dir ${proj_dir} ABSOLUTE)
        foreach(sgbd_file ${${source_files}})
			get_filename_component(sgbd_abs_file ${sgbd_file} ABSOLUTE)
            file(RELATIVE_PATH sgbd_fpath ${sgbd_cur_dir} ${sgbd_abs_file})
            string(REGEX REPLACE "\(.*\)/.*" \\1 sgbd_group_name ${sgbd_fpath})
            string(COMPARE EQUAL ${sgbd_fpath} ${sgbd_group_name} sgbd_nogroup)
            string(REPLACE "/" "\\" sgbd_group_name ${sgbd_group_name})
            if(sgbd_nogroup)
                set(sgbd_group_name "\\")
            endif(sgbd_nogroup)
            source_group(${sgbd_group_name} FILES ${sgbd_file})
        endforeach(sgbd_file)
    endif(MSVC OR APPLE)
endmacro(source_group_by_dir)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} POSIX_H)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} POSIX_C)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LIBLUA_H)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LIBLUA_C)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} STRAWBERRY_H)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} STRAWBERRY_C)

IF(MSVC)
	add_executable(strawberry ${POSIX_H} ${POSIX_C} ${LIBLUA_H} ${LIBLUA_C} ${STRAWBERRY_H} ${STRAWBERRY_C})
	set_target_properties(strawberry PROPERTIES LINK_FLAGS "/DEF:\"../../skynet-src/skynet.def\"")
	target_link_libraries(strawberry ws2_32 ../../3rd/pthread-win32/lib/pthread_dll)
ELSE(MSVC)
	add_executable(strawberry ${LIBLUA_H} ${LIBLUA_C} ${STRAWBERRY_H} ${STRAWBERRY_C})
	find_library(JEMALLOC_LIB jemalloc_pic ../3rd/jemalloc/lib NO_DEFAULT_PATH)
	target_link_libraries(strawberry ${JEMALLOC_LIB})
	target_link_libraries(strawberry pthread m dl rt)
ENDIF()

set_target_properties(strawberry
	PROPERTIES
	ENABLE_EXPORTS ON
    RUNTIME_OUTPUT_DIRECTORY ../..
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../..
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../..
)
