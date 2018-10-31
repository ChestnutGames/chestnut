project(aoi)

set (AOI_H ./aoi.h)
set (AOI_C ./aoi.c ./lua-aoi.c) 

include_directories(../../3rd/lua)
include_directories(../../skynet-src)
if (MSVC)
include_directories(../../3rd/pthread-win32)
include_directories(../../3rd/posix)
endif (MSVC)

if (MSVC)
add_definitions(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK -D_CRT_SECURE_NO_WARNINGS)
else (MSVC)
set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Wno-unused-function -Wno-unused-variable -Werror")
set (CMAKE_C_FLAGS_DEBUG "-g -O0")
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Wno-unused-function -Wno-unused-variable -Werror")
set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
endif (MSVC)

if (CMAKE_BUILD_TYPE MATCHES "Debug")
add_definitions(-D_DEBUG)
endif()

add_library(aoi SHARED ${AOI_H} ${AOI_C})
set_target_properties(aoi PROPERTIES PREFIX "")
set_target_properties(aoi PROPERTIES SUFFIX ".so")
set_target_properties(aoi PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)
set_target_properties(aoi PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)
set_target_properties(aoi PROPERTIES FOLDER "lualib")

if (MSVC)
target_link_libraries(aoi ws2_32)
endif (MSVC)
#target_link_libraries(aoi ../../../libbase)
target_link_libraries(aoi ../../../strawberry)

add_dependencies(aoi strawberry)
