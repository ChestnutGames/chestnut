#project(xlogger)

#set(XLOGGER_H ./shash.h)
#set(XLOGGER_C ./service_xlogger.c)

#include_directories(.)
#include_directories(../3rd/lua)
#include_directories(../skynet-src)
#include_directories(../foundation/include/message)

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
include_directories(../../3rd/lua)
include_directories(../../skynet-src)
include_directories(../../foundation)
IF(MSVC)
	include_directories(../../3rd/pthread-win32)
	include_directories(../../3rd/posix)
ENDIF(MSVC)

IF(MSVC)
	add_definitions(-DLUA_BUILD_AS_DLL)
	add_definitions(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ELSE(MSVC)
	set (CMAKE_C_FLAGS "-std=gnu99 -Wall -fPIC --shared")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -fPIC --shared")
    set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF()

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
	ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

add_library(xloggerd SHARED ${XLOGGERD_H} ${XLOGGERD_C})
set_target_properties(xloggerd
	PROPERTIES
	PREFIX ""
	SUFFIX ".so"
	FOLDER "service"
	RUNTIME_OUTPUT_DIRECTORY ../../../cservice
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../../cservice
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../../cservice
	ARCHIVE_OUTPUT_DIRECTORY ../../../cservice
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../../cservice
	ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../../cservice
    LIBRARY_OUTPUT_DIRECTORY ../../../cservice
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../../cservice
)

IF(MSVC)
	set_target_properties(xloggerd PROPERTIES FOLDER "service")
	set_target_properties(xloggerd PROPERTIES LINK_FLAGS "/DEF:\"../../../service-src/xlogger/service_xloggerd.def\"")
	target_link_libraries(xloggerd ws2_32 ../../../strawberry)
ENDIF(MSVC)

add_dependencies(xloggerd strawberry)
