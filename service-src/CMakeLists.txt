project(gate)

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


project(harbor)

set(HARBOR_C ./service_harbor.c)

include_directories(.)
include_directories(../3rd/lua)
include_directories(../skynet-src)

IF(MSVC)
include_directories(../3rd/pthread-win32)
include_directories(../3rd/posix)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ELSE(MSVC)
ADD_DEFINITIONS(-Wno-unused-function)
SET(CMAKE_C_FLAGS "-Wall -std=gnu99")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF(MSVC)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

add_library(harbor SHARED ${HARBOR_C})

set_target_properties(harbor PROPERTIES PREFIX "")
set_target_properties(harbor PROPERTIES SUFFIX ".so")

IF(MSVC)
set_target_properties(harbor PROPERTIES FOLDER "service")
set_target_properties(harbor PROPERTIES LINK_FLAGS "/DEF:\"../../service-src/service_harbor.def\"")
set_target_properties(harbor PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../cservice)
set_target_properties(harbor PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../cservice)
set_target_properties(harbor PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../cservice)
set_target_properties(harbor PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../cservice)

IF(CMAKE_CL_64)
target_link_libraries(harbor ws2_32 ../../strawberry)
ENDIF(CMAKE_CL_64)
ELSE(MSVC)

SET(EXECUTABLE_OUTPUT_PATH ../../cservice)
SET(LIBRARY_OUTPUT_PATH ../../cservice)

ENDIF(MSVC)

ADD_DEPENDENCIES(harbor gate)

project(logger)

set(LOGGER_C ./service_logger.c)

include_directories(.)
include_directories(../3rd/lua)
include_directories(../skynet-src)

IF(MSVC)
include_directories(../3rd/pthread-win32)
include_directories(../3rd/posix)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ELSE(MSVC)
ADD_DEFINITIONS(-Wno-unused-function)
SET(CMAKE_C_FLAGS "-std=gnu99 -Wall")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF(MSVC)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

add_library(logger SHARED ${LOGGER_C})

set_target_properties(logger PROPERTIES PREFIX "")
set_target_properties(logger PROPERTIES SUFFIX ".so")


IF(MSVC)
set_target_properties(logger PROPERTIES FOLDER "service")
set_target_properties(logger PROPERTIES LINK_FLAGS "/DEF:\"../../service-src/service_logger.def\"")
set_target_properties(logger PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../cservice)
set_target_properties(logger PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../cservice)

IF(CMAKE_CL_64)
target_link_libraries(logger ws2_32 ../../strawberry)
ENDIF(CMAKE_CL_64)
ELSE(MSVC)

SET(EXECUTABLE_OUTPUT_PATH ../../cservice)
SET(LIBRARY_OUTPUT_PATH ../../cservice)

ENDIF(MSVC)

ADD_DEPENDENCIES(logger harbor)

project(snlua)

set(SNLUA_C ./service_snlua.c)

include_directories(.)
include_directories(../3rd/lua)
include_directories(../skynet-src)

IF(MSVC)
include_directories(../3rd/pthread-win32)
include_directories(../3rd/posix)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ELSE(MSVC)
ADD_DEFINITIONS(-Wno-unused-function)
SET(CMAKE_C_FLAGS "-Wall -std=gnu99")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF()

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

add_library(snlua SHARED ${SNLUA_C})

set_target_properties(snlua PROPERTIES PREFIX "")
set_target_properties(snlua PROPERTIES SUFFIX ".so")


IF(MSVC)
set_target_properties(snlua PROPERTIES FOLDER "service")
set_target_properties(snlua PROPERTIES LINK_FLAGS "/DEF:\"../../service-src/service_snlua.def\"")
set_target_properties(snlua PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../cservice)
set_target_properties(snlua PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../cservice)

IF(CMAKE_CL_64)
target_link_libraries(snlua ws2_32 ../../strawberry)
ENDIF(CMAKE_CL_64)
ELSE(MSVC)

SET(EXECUTABLE_OUTPUT_PATH ../../cservice)
SET(LIBRARY_OUTPUT_PATH ../../cservice)

ENDIF()

ADD_DEPENDENCIES(snlua logger)

#project(xlogger)

#set(XLOGGER_H ./shash.h)
#set(XLOGGER_C ./service_xlogger.c)

#include_directories(.)
#include_directories(../3rd/lua)
#include_directories(../skynet-src)
#include_directories(../foundation)

#IF(MSVC)
#include_directories(../3rd/pthread-win32)
#include_directories(../3rd/posix)
#ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
#ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
#ELSE(MSVC)
#ADD_DEFINITIONS(-Wno-unused-function -Wno-unused-variable -Werror)
#SET(CMAKE_C_FLAGS "-Wall -std=gnu99")
#SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
#SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
#SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
#ENDIF()

#IF(CMAKE_BUILD_TYPE MATCHES "Debug")
#ADD_DEFINITIONS(-D_DEBUG)
#ENDIF()

#add_library(xlogger SHARED ${XLOGGER_H} ${XLOGGER_C})

#set_target_properties(xlogger PROPERTIES PREFIX "")
#set_target_properties(xlogger PROPERTIES SUFFIX ".so")

#IF(MSVC)
#set_target_properties(xlogger PROPERTIES FOLDER "service")
#set_target_properties(xlogger PROPERTIES LINK_FLAGS "/DEF:\"../../service-src/service_xlogger.def\"")
#set_target_properties(xlogger PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../cservice)
#set_target_properties(xlogger PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../cservice)
#IF(CMAKE_CL_64)
#target_link_libraries(xlogger ws2_32 ../../strawberry)
#ENDIF()
#ELSE(MSVC)
#SET(EXECUTABLE_OUTPUT_PATH ../../cservice)
#SET(LIBRARY_OUTPUT_PATH ../../cservice)

#ENDIF()

#ADD_DEPENDENCIES(xlogger snlua)

project(xloggerd)

set(XLOGGERD_H ./xloggerdd.h ./shash.h)
set(XLOGGERD_C ./service_xloggerd.c ./xloggerdd.c)

include_directories(.)
include_directories(../3rd/lua)
include_directories(../skynet-src)
include_directories(../foundation)

IF(MSVC)
include_directories(../3rd/pthread-win32)
include_directories(../3rd/posix)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ELSE(MSVC)
ADD_DEFINITIONS(-Wno-unused-function -Wno-unused-variable -Werror)
SET(CMAKE_C_FLAGS "-Wall -std=gnu99 -Wformat=0")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11 -Wformat=0")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF()

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

add_library(xloggerd SHARED ${XLOGGERD_H} ${XLOGGERD_C})

set_target_properties(xloggerd PROPERTIES PREFIX "")
set_target_properties(xloggerd PROPERTIES SUFFIX ".so")

IF(MSVC)
set_target_properties(xloggerd PROPERTIES FOLDER "service")
set_target_properties(xloggerd PROPERTIES LINK_FLAGS "/DEF:\"../../service-src/service_xloggerd.def\"")
set_target_properties(xloggerd PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../cservice)
set_target_properties(xloggerd PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../cservice)
IF(CMAKE_CL_64)
target_link_libraries(xloggerd ws2_32 ../../strawberry)
ENDIF(CMAKE_CL_64)
ELSE(MSVC)
SET(EXECUTABLE_OUTPUT_PATH ../../cservice)
SET(LIBRARY_OUTPUT_PATH ../../cservice)
ENDIF(MSVC)

ADD_DEPENDENCIES(xloggerd strawberry)
