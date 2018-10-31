project(libfixedptmath)

if (CMAKE_COMPILER_IS_GNUCXX)
    set (CMAKE_C_FLAGS "-std=gnu99 -Wall")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall")
endif ()
message (${CMAKE_C_FLAGS})
message (${CMAKE_CXX_FLAGS})

aux_source_directory(. SRC_LIST)
aux_source_directory(./libfixmath SRC_LIST)

add_library(libfixedptmath ${SRC_LIST})
set_target_properties(libfixedptmath
    PROPERTIES
    PREFIX ""
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../..
    RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../..
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../..
)


#project(fixedptmath)
#aux_source_directory(. SRC_LIST)
#aux_source_directory(./libfixmath SRC_LIST)
# include
#include_directories(../src)


#add_library(fixedptmath SHARED ${SRC_LIST})
#set_target_properties(fixedptmath PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../bin)
#set_target_properties(fixedptmath PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../bin)
#target_link_libraries(fixedptmath ../../bin/liblua)
#ADD_DEPENDENCIES(fixedptmath lua)
