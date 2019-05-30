project(lpeg)

file(GLOB LPEG_H *.h)
file(GLOB LPEG_C *.c)

include_directories(.)
include_directories(../../3rd/lua)
include_directories(../../skynet-src)
if (MSVC)
	include_directories(../../3rd/posix)
endif (MSVC)

if (MSVC)
	add_definitions(-DLUA_BUILD_AS_DLL)
	add_definitions(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC)
else (MSVC)
	set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Wno-unused-function -Wno-unused-varibale")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall")
    set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
endif (MSVC)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
	add_definitions(-D_DEBUG)
ENDIF()

add_library(lpeg SHARED ${LPEG_H} ${LPEG_C})
set_target_properties(lpeg PROPERTIES PREFIX "")
set_target_properties(lpeg PROPERTIES SUFFIX ".so")
set_target_properties(lpeg PROPERTIES FOLDER "3rd")
set_target_properties(lpeg PROPERTIES
	RUNTIME_OUTPUT_DIRECTORY ../../../luaclib
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY ../../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../../luaclib
    LIBRARY_OUTPUT_DIRECTORY ../../../luaclib
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../../luaclib
)

if (MSVC)
	target_link_libraries(lpeg ws2_32 ../../../strawberry)
endif (MSVC)

add_dependencies(lpeg strawberry)
