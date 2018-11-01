# cmake_minimum_required(VERSION 3.12)

project(libfixedptmath)

if (CMAKE_COMPILER_IS_GNUCXX)
    set (CMAKE_C_FLAGS "-std=gnu99 -Wall")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall")
	# message (${CMAKE_C_FLAGS})
	# message (${CMAKE_CXX_FLAGS})
endif ()

aux_source_directory(. LIBFIXEDPTMATH_C)
aux_source_directory(./libfixmath LIBFIXEDPTMATH_C)

add_library(libfixedptmath STATIC ${LIBFIXEDPTMATH_C})
set_target_properties(libfixedptmath
    PROPERTIES
    PREFIX ""
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../..
    RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../..
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../..
)
