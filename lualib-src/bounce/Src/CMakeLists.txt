# cmake_minimum_required(VERSION 3.12)

project(bounce)

include_directories(..)
include_directories(../fixmath/include)
include_directories(../lua/src)

if (MSVC)
	add_definitions(-DLUA_BUILD_AS_DLL)
endif (MSVC)

if (CMAKE_COMPILER_IS_GNUCXX)
    set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Wextra -fPIC")
    set (CMAKE_C_FLAGS_DEBUG "-g -O0")
    set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -Wextra -fPIC")
	set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
	# message (${CMAKE_C_FLAGS})
	# message (${CMAKE_CXX_FLAGS})
endif ()

set (BOUNCE_CORE
	./Collision/b3BroadPhase.h ./Collision/b3DynamicAABBTree.h ./Collision/b3SAT.h
	./Collision/b3BroadPhase.cpp ./Collision/b3DynamicAABBTree.cpp ./Collision/b3SAT.cpp
	./Collision/Shapes/b3Hull.h ./Collision/Shapes/b3Polyhedron.h ./Collision/Shapes/b3Shape.h
	./Collision/Shapes/b3Hull.cpp ./Collision/Shapes/b3Polyhedron.cpp ./Collision/Shapes/b3Shape.cpp
	./Common/b3Time.h ./Common/b3Settings.h
	./Common/b3Time.cpp ./Common/b3Settings.cpp
	./Common/Math/b3r32.h ./Common/Math/b3r32.cpp ./Common/Math/b3Vec3.h
	./Common/Memory/b3BlockAllocator.h ./Common/Memory/b3StackAllocator.h
	./Common/Memory/b3BlockAllocator.cpp ./Common/Memory/b3StackAllocator.cpp
	./Dynamics/b3World.h ./Dynamics/b3Island.h ./Dynamics/b3Body.h
	./Dynamics/b3World.cpp ./Dynamics/b3Island.cpp ./Dynamics/b3Body.cpp
	./Dynamics/Joints/b3JointGraph.cpp ./Dynamics/Joints/b3JointSolver.cpp ./Dynamics/Joints/b3MouseJoint.cpp
	./Dynamics/Joints/b3RevoluteJoint.cpp ./Dynamics/Joints/b3SphericalJoint.cpp
	./Dynamics/Contacts/b3ContactGraph.cpp ./Dynamics/Contacts/b3ContactSolver.cpp
	./lua-bounce.cpp
)

macro(source_group_by_dir proj_dir source_files)
    if(MSVC OR APPLE)
        get_filename_component(sgbd_cur_dir ${proj_dir} ABSOLUTE)
        foreach(sgbd_file ${${source_files}})
			get_filename_component(sgbd_abs_file ${sgbd_file} ABSOLUTE)
            file(RELATIVE_PATH sgbd_fpath ${sgbd_cur_dir} ${sgbd_abs_file})
            string(REGEX REPLACE "\(.*\)/.*" \\1 sgbd_group_name ${sgbd_fpath})
            string(COMPARE EQUAL ${sgbd_fpath} ${sgbd_group_name} sgbd_nogroup)
            string(REPLACE "/" "\\" sgbd_group_name ${sgbd_group_name})
            if(sgbd_nogroup)
                set(sgbd_group_name "\\")
            endif(sgbd_nogroup)
            source_group(${sgbd_group_name} FILES ${sgbd_file})
        endforeach(sgbd_file)
    endif(MSVC OR APPLE)
endmacro(source_group_by_dir)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} BOUNCE_CORE)

add_library(bounce SHARED ${BOUNCE_CORE})
#target_compile_definitions(libbounce PRIVATE FIXEDPT)
set_target_properties(bounce
    PROPERTIES
    PREFIX ""
	RUNTIME_OUTPUT_DIRECTORY ../..
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../..
	RUNTIME_OUTPUT_DIRECTORY_RELEASE ../..
	ARCHIVE_OUTPUT_DIRECTORY ../..
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../..
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE ../..
	LIBRARY_OUTPUT_DIRECTORY ../..
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../..
)
target_link_libraries(bounce ws2_32 libfixedptmath ../../liblua)
