project(lua)

include_directories(../../skynet-src)
if (MSVC)
	include_directories(../../3rd/posix)
endif (MSVC)

if (MSVC)
	add_definitions(-DLUA_BUILD_AS_DLL)
	#add_definitions(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK)
else (MSVC)
	set (CMAKE_C_FLAGS "-std=gnu99 -Wall")
	set (CMAKE_C_FLAGS_DEBUG "-g -O0")
	set (CMAKE_CXX_FLAGS "-std=c++11 -Wall")
	set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
endif ()

if (CMAKE_BUILD_TYPE MATCHES "Debug")
	add_definitions(-D_DEBUG)
endif()

set (LUA lapi.c lauxlib.c lbaselib.c lbitlib.c lcode.c lcorolib.c lctype.c ldebug.c ldo.c ldump.c lfunc.c lgc.c linit.c llex.c lmathlib.c lmem.c loadlib.c
	lobject.c lopcodes.c loslib.c lparser.c lstate.c lstring.c lstrlib.c ltable.c ltablib.c ltm.c lua.c lundump.c lutf8lib.c lvm.c lzio.c
)

# target
add_executable(lua ${LUA})
set_target_properties(lua
	PROPERTIES
	FOLDER "3rd"
	ENABLE_EXPORTS ON
	RUNTIME_OUTPUT_DIRECTORY ../../..
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../..
	ARCHIVE_OUTPUT_DIRECTORY ../../..
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../..
)

