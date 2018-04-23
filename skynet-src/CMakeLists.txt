project(strawberry)

SET(POSIX_CXX ../3rd/posix/cpoll/cpoll.cpp)
file(GLOB POSIX_H ../3rd/posix/*.h)
file(GLOB POSIX_C ../3rd/posix/*.c)

file(GLOB LIBLUA_H ../3rd/lua/*.h)
aux_source_directory(../3rd/lua LIBLUA_C)
list(REMOVE_ITEM LIBLUA_C ../3rd/lua/luac.c ../3rd/lua/lua.c)

file(GLOB STRAWBERRY_H *.h)
file(GLOB STRAWBERRY_C *.c)

include_directories(.)
include_directories(../3rd/lua)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

IF(MSVC)
source_group("posix" FILES ${POSIX_H} ${POSIX_C})
source_group("posix\\cpoll" FILES ${POSIX_CXX})
source_group("lua" FILES ${LIBLUA_H} ${LIBLUA_C})
source_group("skynet" FILES ${STRAWBERRY_H} ${STRAWBERRY_C})

include_directories(../3rd/posix)
include_directories(../3rd/pthread-win32)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
ADD_DEFINITIONS(-D_CRT_SECURE_NO_WARNINGS)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)

# target
add_executable(strawberry ${POSIX_H} ${POSIX_C} ${POSIX_CXX} ${LIBLUA_H} ${LIBLUA_C} ${STRAWBERRY_H} ${STRAWBERRY_C})

IF(CMAKE_CL_64)
set_target_properties(strawberry PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../..)
set_target_properties(strawberry PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../..)
set_target_properties(strawberry PROPERTIES LINK_FLAGS "/DEF:\"../../skynet-src/skynet.def\"")
target_link_libraries(strawberry ws2_32 ../../3rd/pthread-win32/bin/x64_MSVC2015.Debug/pthread_dll)
ENDIF(CMAKE_CL_64)

ELSE(MSVC)
# linux
include_directories(../3rd/jemalloc/include/jemalloc)
ADD_DEFINITIONS(-DLUA_USE_LINUX)
#ADD_DEFINITIONS(-Wno-unused-variable -Werror)
ADD_DEFINITIONS(-Wno-unused-function)
SET(CMAKE_C_FLAGS "-std=gnu99 -Wall -Wextra -Wl,-E")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wextra -Wl,-E")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")

# target
FIND_LIBRARY(JEMALLOC_LIB jemalloc_pic ../3rd/jemalloc/lib NO_DEFAULT_PATH)
link_libraries(${JEMALLOC_LIB})

add_executable(strawberry ${LIBLUA_H} ${LIBLUA_C} ${STRAWBERRY_H} ${STRAWBERRY_C})

SET(EXECUTABLE_OUTPUT_PATH ../..)
SET(LIBRARY_OUTPUT_PATH ../..)

target_link_libraries(strawberry pthread m dl rt)

ENDIF(MSVC)
