# cmake_minimum_required(VERSION 3.12)

project(libfixedptmath)

include_directories(../../foundation)

if (CMAKE_COMPILER_IS_GNUCXX)
    set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Wextra -fPIC")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -Wextra -fPIC")
	set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
	# message (${CMAKE_C_FLAGS})
	# message (${CMAKE_CXX_FLAGS})
endif ()

#aux_source_directory(. LIBFIXEDPTMATH_C)
#aux_source_directory(./libfixmath LIBFIXEDPTMATH_C)

set (LIBFIXEDPTMATH_CORE ./libfixmath/fix16.c ./libfixmath/fix16_exp.c ./libfixmath/fix16_sqrt.c ./libfixmath/fix16_str.c 
	./libfixmath/fix16_trig.c ./libfixmath/fract32.c ./libfixmath/uint32.c
)

add_library(libfixedptmath STATIC ${LIBFIXEDPTMATH_CORE})
target_compile_definitions(libfixedptmath PRIVATE FIXEDPT)
set_target_properties(libfixedptmath
    PROPERTIES
    PREFIX ""
	RUNTIME_OUTPUT_DIRECTORY ../../..
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../..
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ../../..
	ARCHIVE_OUTPUT_DIRECTORY ../../..
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../..
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../../..
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../..
)
