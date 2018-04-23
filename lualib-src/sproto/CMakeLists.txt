project(sproto)

file(GLOB SPROTO_H *.h)
file(GLOB SPROTO_C *.c)

include_directories(.)
include_directories(../../3rd/lua)

IF(MSVC)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ELSE(MSVC)
ADD_DEFINITIONS(-Wno-unused-function -Wno-unused-variable -Werror)
SET(CMAKE_C_FLAGS "-Wall -std=gnu99")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF()

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

add_library(sproto SHARED ${SPROOT_H} ${SPROTO_C})

set_target_properties(sproto PROPERTIES PREFIX "")
set_target_properties(sproto PROPERTIES SUFFIX ".so")

IF(MSVC)
set_target_properties(sproto PROPERTIES FOLDER "lualib") 
set_target_properties(sproto PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)
set_target_properties(sproto PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)

IF(CMAKE_CL_64)
target_link_libraries(sproto ws2_32 ../../../strawberry)
ENDIF()
ELSE(MSVC)

SET(EXECUTABLE_OUTPUT_PATH ../../../luaclib)
SET(LIBRARY_OUTPUT_PATH ../../../luaclib)

ENDIF()

ADD_DEPENDENCIES(sproto rapidjson)
