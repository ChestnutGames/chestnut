project(skynet)

file(GLOB SKYNET_H *.h)
aux_source_directory(. SKYNET_C)
list(REMOVE_ITEM SKYNET_C ./lua-clientsocket.c ./lua-bson.c)

include_directories(.)
include_directories(../3rd/lua)
include_directories(../skynet-src)

IF(MSVC)
include_directories(../3rd/pthread-win32)
include_directories(../3rd/posix)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ELSE(MSVC)
ADD_DEFINITIONS(-Wno-unused-function -Wno-unused-variable -Werror)
SET(CMAKE_C_FLAGS "-Wall -std=gnu99")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF(MSVC)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

add_library(skynet SHARED ${SKYNET_H} ${SKYNET_C})

set_target_properties(skynet PROPERTIES PREFIX "")
set_target_properties(skynet PROPERTIES SUFFIX ".so")

IF(MSVC)
set_target_properties(skynet PROPERTIES FOLDER "lualib")
set_target_properties(skynet PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(skynet PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)

IF(CMAKE_CL_64)
target_link_libraries(skynet ws2_32 ../../3rd/pthread-win32/bin/x64_MSVC2015.Debug/pthread_dll)
target_link_libraries(skynet ../../strawberry)
ENDIF(CMAKE_CL_64)

SET(EXECUTABLE_OUTPUT_PATH ../../luaclib)
SET(LIBRARY_OUTPUT_PATH ../../luaclib)

ELSE(MSVC)
#target_link_libraries(skynet ../../../bin/linux/strawberry)
ENDIF(MSVC)

ADD_DEPENDENCIES(skynet chestnut)


# bson
project(bson)

set(BSON_C ./lua-bson.c)

include_directories(.)
include_directories(../3rd/lua)
include_directories(../skynet-src)

IF(MSVC)
include_directories(../3rd/pthread-win32)
include_directories(../3rd/posix)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ELSE(MSVC)
ADD_DEFINITIONS(-Wno-unused-function -Wno-unused-variable -Werror)
SET(CMAKE_C_FLAGS "-Wall -std=gnu99 -Wl,-E")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11 -Wl,-E")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF(MSVC)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

add_library(bson SHARED ${BSON_C})

set_target_properties(bson PROPERTIES PREFIX "")
set_target_properties(bson PROPERTIES SUFFIX ".so")

IF(MSVC)
set_target_properties(bson PROPERTIES FOLDER "lualib")
set_target_properties(bson PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(bson PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib)
set_target_properties(bson PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib)

IF(CMAKE_CL_64)
target_link_libraries(bson ws2_32 ../../strawberry)
ENDIF(CMAKE_CL_64)
ELSE(MSVC)

SET(EXECUTABLE_OUTPUT_PATH ../../luaclib)
SET(LIBRARY_OUTPUT_PATH ../../luaclib)

ENDIF(MSVC)

ADD_DEPENDENCIES(bson skynet)