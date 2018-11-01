project(ssock)

include_directories(../../3rd/lua)
include_directories(../../skynet-src)

IF(MSVC)
	include_directories(../../3rd/openssl/include)
	include_directories(../../3rd/pthread-win32)
	include_directories(../../3rd/posix)
	add_definitions(-DLUA_BUILD_AS_DLL)
	add_definitions(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK -D_CRT_SECURE_NO_WARNINGS)
ELSE(MSVC)
	set (CMAKE_C_FLAGS "-std=gnu99 -Wall -fPIC --shared -Werror")
	set (CMAKE_C_FLAGS_DEBUG "-g -O0")
	set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -fPIC --shared -Werror")
	set (CMAKE_CXX_FLAGS_DEBUG "-g -O0")
ENDIF(MSVC)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
	add_definitions(-D_DEBUG)
ENDIF()

SET(SSL_H ./ssock.h ./sssl.h)
SET(SSL_C ./ssock.c ./sssl.c ./lua-ssock.c) 
add_library(ssock SHARED ${SSL_H} ${SSL_C})
set_target_properties(ssock
	PROPERTIES 
	PREFIX ""
	SUFFIX ".so"
	FOLDER "lualib"
	RUNTIME_OUTPUT_DIRECTORY ../../luaclib
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY ../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../luaclib
	LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../luaclib
)

IF(MSVC)
	#target_link_libraries(chestnut ../../../libbase)
	target_link_libraries(ssock ws2_32 ../../../strawberry)
	target_link_libraries(ssock ../../../3rd/openssl/libcrypto ../../../3rd/openssl/libssl)
	target_link_libraries(ssock ../../../3rd/pthread-win32/bin/x64_MSVC2015.Debug/pthread_dll)
ELSE(MSVC)
	target_link_libraries(ssock crypto ssl)
ENDIF()

add_dependencies(ssock strawberry)
