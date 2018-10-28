project(libfixedptmath)
aux_source_directory(. SRC_LIST)
aux_source_directory(./libfixmath SRC_LIST)

add_library(libfixedptmath ${SRC_LIST})
set_target_properties(libfixedptmath PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../..)
set_target_properties(libfixedptmath PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../..)

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