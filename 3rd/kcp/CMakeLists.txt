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
	add_definitions(-DLUA_BUILD_AS_DLL)
	add_definitions(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK -D_CRT_SECURE_NO_WARNINGS)
else (MSVC)
    set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Wno-unused-function -Wno-unused-varibale")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall")
    set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
endif (MSVC)

if (CMAKE_BUILD_TYPE MATCHES "Debug")
	add_definitions(-D_DEBUG)
endif ()

set (KCP_H ./ikcp.h)
set (KCP_C ./ikcp.c ./lkcp.c)

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

add_dependencies(kcp strawberry)

set (KCPTEST_H ./test.h)
set (KCPTEST_C ./test.cpp)

add_executable(kcptest ${KCPTEST_H} ${KCPTEST_C})
set_target_properties(kcptest PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../..)
set_target_properties(kcptest PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../..)
set_target_properties(kcptest PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../..)
set_target_properties(kcptest PROPERTIES FOLDER "test")

if (MSVC)
	target_link_libraries(kcptest ws2_32)
endif ()
