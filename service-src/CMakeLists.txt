project(service)

include_directories(.)
include_directories(../3rd/lua)
include_directories(../skynet-src)

IF(MSVC)
	include_directories(../3rd/pthread-win32)
	include_directories(../3rd/posix)
	add_definitions(-DLUA_BUILD_AS_DLL)
	add_definitions(-D_CRT_SECURE_NO_WARNINGS)
	add_definitions(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ELSE(MSVC)
	set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Wno-unused-function -Wno-unused-varibale")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall")
    set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF(MSVC)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
	ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

# target
set(GATE_H ./hashid.h ./databuffer.h)
set(GATE_C ./service_gate.c)
add_library(gate SHARED ${GATE_H} ${GATE_C})
IF(MSVC)
	set_target_properties(gate PROPERTIES LINK_FLAGS "/DEF:\"../../service-src/service_gate.def\"")
	target_link_libraries(gate ws2_32 ../../strawberry)
ENDIF()
add_dependencies(gate strawberry)

set(HARBOR_C ./service_harbor.c)
add_library(harbor SHARED ${HARBOR_C})
IF(MSVC)
	set_target_properties(harbor PROPERTIES LINK_FLAGS "/DEF:\"../../service-src/service_harbor.def\"")
	target_link_libraries(harbor ws2_32 ../../strawberry)
ENDIF()
add_dependencies(harbor strawberry)

set(LOGGER_C ./service_logger.c)
add_library(logger SHARED ${LOGGER_C})
IF(MSVC)
	set_target_properties(logger PROPERTIES LINK_FLAGS "/DEF:\"../../service-src/service_logger.def\"")
	target_link_libraries(logger ws2_32 ../../strawberry)
ENDIF()
add_dependencies(logger strawberry)

set(SNLUA_C ./service_snlua.c)
add_library(snlua SHARED ${SNLUA_C})
IF(MSVC)
	set_target_properties(snlua PROPERTIES LINK_FLAGS "/DEF:\"../../service-src/service_snlua.def\"")
	target_link_libraries(snlua ws2_32 ../../strawberry)
ENDIF()
add_dependencies(snlua strawberry)

set_target_properties(gate harbor logger snlua
	PROPERTIES
	PREFIX ""
	SUFFIX ".so"
	FOLDER "service"
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../cservice
	ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../cservice
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../cservice
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../cservice
)
