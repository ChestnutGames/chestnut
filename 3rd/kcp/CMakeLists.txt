project(kcp)

SET(KCP_H ./ikcp.h)
SET(KCP_C ./ikcp.c ./lkcp.c)

# include 
include_directories(../../3rd/lua)
include_directories(../../skynet-src)
IF(MSVC)
include_directories(../../3rd/pthread-win32)
include_directories(../../3rd/posix)
ENDIF(MSVC)

# definitions
IF(MSVC)
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

# target
add_library(kcp SHARED ${KCP_H} ${KCP_C})
set_target_properties(kcp PROPERTIES PREFIX "")
set_target_properties(kcp PROPERTIES SUFFIX ".so")
set_target_properties(kcp PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)
set_target_properties(kcp PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)

IF(MSVC)
set_target_properties(kcp PROPERTIES FOLDER "3rd")
target_link_libraries(kcp ws2_32 ../../../strawberry)
ENDIF()

ADD_DEPENDENCIES(kcp strawberry)

project(kcptest)

SET(KCPTEST_H ./test.h)
SET(KCPTEST_C ./test.cpp)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

add_executable(kcptest ${KCPTEST_H} ${KCPTEST_C})
set_target_properties(kcptest PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../..)
set_target_properties(kcptest PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../..)
set_target_properties(kcptest PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../..)

IF(MSVC)
set_target_properties(kcptest PROPERTIES FOLDER "test")
target_link_libraries(kcptest ws2_32)
ENDIF()
