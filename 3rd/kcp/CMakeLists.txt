project(kcp)

# include
include_directories(../../3rd/lua)
include_directories(../../skynet-src)
if (MSVC)
include_directories(../../3rd/pthread-win32)
include_directories(../../3rd/posix)
endif (MSVC)

# definitions
if (MSVC)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK -D_CRT_SECURE_NO_WARNINGS)
else (MSVC)
    set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Wno-unused-function -Wno-unused-varibale")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
    set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
endif (MSVC)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

SET(KCP_H ./ikcp.h)
SET(KCP_C ./ikcp.c ./lkcp.c)

# target
add_library(kcp SHARED ${KCP_H} ${KCP_C})
set_target_properties(kcp PROPERTIES PREFIX "")
set_target_properties(kcp PROPERTIES SUFFIX ".so")
set_target_properties(kcp PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)
set_target_properties(kcp PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)
set_target_properties(kcp PROPERTIES FOLDER "3rd")

IF(MSVC)
target_link_libraries(kcp ws2_32 ../../../strawberry)
ENDIF()

ADD_DEPENDENCIES(kcp strawberry)

SET(KCPTEST_H ./test.h)
SET(KCPTEST_C ./test.cpp)

add_executable(kcptest ${KCPTEST_H} ${KCPTEST_C})
set_target_properties(kcptest PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../..)
set_target_properties(kcptest PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../..)
set_target_properties(kcptest PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../..)
set_target_properties(kcptest PROPERTIES FOLDER "test")

IF(MSVC)
target_link_libraries(kcptest ws2_32)
ENDIF()
