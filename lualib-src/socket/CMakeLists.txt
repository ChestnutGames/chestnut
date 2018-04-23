project(skynet)

file(GLOB SKYNET_H *.h)
aux_source_directory(. SKYNET_C)
list(REMOVE_ITEM SKYNET_C ./lua-clientsocket.c ./lua-bson.c)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
set(BUILD_USE_64BITS on)

include_directories(.)
include_directories(../../3rd/lua)
include_directories(../../3rd/posix)
include_directories(../../skynet-src/)

IF(MSVC)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

IF(CMAKE_CL_64)
SET(LIBRARY_OUTPUT_PATH ../../luaclib)	
add_library(skynet SHARED ${SKYNET_H} ${SKYNET_C})
#link_directories(${CMAKE_CURRENT_SOURCE_DIR}../../bin/win64/Debug)
target_link_libraries(skynet ../../../bin/win64/Debug/posix ../../../bin/win64/Debug/liblua ../../../bin/win64/Debug/strawberry ../../../bin/win64/Debug/pthreadVC2 ws2_32)
set_target_properties(skynet PROPERTIES FOLDER "lualib") 
ADD_DEPENDENCIES(skynet lualib strawberry posix)
ENDIF()


project(bson)

set(BSON_C ./lua-bson.c)
set(BUILD_USE_64BITS on)

include_directories(.)
include_directories(../../3rd/lua)
include_directories(../../3rd/posix)
include_directories(../../skynet-src/)

ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
IF(MSVC)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
ENDIF()

IF(CMAKE_CL_64)
SET(LIBRARY_OUTPUT_PATH ../../luaclib)	
add_library(bson SHARED ${BSON_C})
#link_directories(${CMAKE_CURRENT_SOURCE_DIR}../../bin/win64/Debug)
target_link_libraries(bson ../../../bin/win64/Debug/posix ../../../bin/win64/Debug/liblua ../../../bin/win64/Debug/strawberry ../../../bin/win64/Debug/pthreadVC2)
set_target_properties(bson PROPERTIES FOLDER "lualib") 
ADD_DEPENDENCIES(bson lualib strawberry posix)
ENDIF()