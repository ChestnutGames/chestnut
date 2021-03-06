project(udpgate)

set(GATE_H ./hashid.h ./databuffer.h)
set(GATE_C ./service_gate.c)

include_directories(.)
include_directories(../3rd/lua)
include_directories(../skynet-src)

IF(MSVC)
include_directories(../3rd/pthread-win32)
include_directories(../3rd/posix)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
ADD_DEFINITIONS(-D_CRT_SECURE_NO_WARNINGS)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ELSE(MSVC)
#ADD_DEFINITIONS( -Wno-unused-variable -Werror)
ADD_DEFINITIONS(-Wno-unused-function)
SET(CMAKE_C_FLAGS "-Wall -std=gnu99")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF(MSVC)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

# target
add_library(gate SHARED ${GATE_H} ${GATE_C})

set_target_properties(gate PROPERTIES PREFIX "")
set_target_properties(gate PROPERTIES SUFFIX ".so")

IF(MSVC)
set_target_properties(gate PROPERTIES FOLDER "service")
set_target_properties(gate PROPERTIES LINK_FLAGS "/DEF:\"../../service-src/service_gate.def\"")
set_target_properties(gate PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../cservice)
set_target_properties(gate PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../cservice)
set_target_properties(gate PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../cservice)
set_target_properties(gate PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../cservice)

IF(CMAKE_CL_64)
target_link_libraries(gate ws2_32 ../../strawberry)
ENDIF(CMAKE_CL_64)
ELSE(MSVC)
SET(EXECUTABLE_OUTPUT_PATH ../../cservice)
SET(LIBRARY_OUTPUT_PATH ../../cservice)
ENDIF(MSVC)
ADD_DEPENDENCIES(gate strawberry)
