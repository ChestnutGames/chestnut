project(rudp)

SET(RUDP_H ./rudp.h)
SET(RUDP_C ./rudp.c ./lua-rudp.c)

include_directories(../../3rd/lua)
include_directories(../../skynet-src)

IF(MSVC)
include_directories(../../3rd/openssl/include)
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

add_library(rudp SHARED ${RUDP_H} ${RUDP_C})
set_target_properties(rudp PROPERTIES PREFIX "")
set_target_properties(rudp PROPERTIES SUFFIX ".so")
set_target_properties(rudp PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)
set_target_properties(rudp PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)

IF(MSVC)
set_target_properties(rudp PROPERTIES FOLDER "lualib")
target_link_libraries(rudp ws2_32 ../../../strawberry)
ENDIF()

ADD_DEPENDENCIES(rudp strawberry)

project(rudptest)

SET(RUDP_H ./rudp.h)
SET(RUDP_C ./rudp.c ./main.c)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

add_executable(rudptest ${RUDP_H} ${RUDP_C})
set_target_properties(rudptest PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../..)
set_target_properties(rudptest PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../..)
set_target_properties(rudptest PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../..)

IF(MSVC)
set_target_properties(rudptest PROPERTIES FOLDER "test")
target_link_libraries(rudptest ws2_32)
ENDIF()
