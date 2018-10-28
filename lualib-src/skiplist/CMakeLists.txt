project(skiplist)

SET(SKIPLIST_H ./skiplist.h)
SET(SKIPLIST_C ./skiplist.c ./lua-skiplist.c)

include_directories(.)
include_directories(../../3rd/lua)
include_directories(../../skynet-src)

IF(MSVC)
include_directories(../../3rd/pthread-win32)
include_directories(../../3rd/posix)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK -D_CRT_SECURE_NO_WARNINGS)

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

add_library(skiplist SHARED ${SKIPLIST_H} ${SKIPLIST_C})
set_target_properties(skiplist PROPERTIES PREFIX "")
set_target_properties(skiplist PROPERTIES SUFFIX ".so")
set_target_properties(skiplist PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)
set_target_properties(skiplist PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)

IF(MSVC)
set_target_properties(skiplist PROPERTIES FOLDER "lualib")
IF(CMAKE_CL_64)
#target_link_libraries(skiplist ../../../libbase)
target_link_libraries(skiplist ws2_32 ../../../strawberry)
ENDIF(CMAKE_CL_64)
ELSE(MSVC)
ENDIF()

ADD_DEPENDENCIES(skiplist strawberry)
