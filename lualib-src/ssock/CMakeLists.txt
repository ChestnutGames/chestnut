project(ssock)

SET(SSL_H ./ssock.h ./sssl.h)
SET(SSL_C ./ssock.c ./sssl.c ./lua-ssock.c) 

include_directories(../../3rd/lua)
include_directories(../../skynet-src)

IF(MSVC)
include_directories(../../3rd/openssl/include)
include_directories(../../3rd/pthread-win32)
include_directories(../../3rd/posix)
ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)
ADD_DEFINITIONS(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK -D_CRT_SECURE_NO_WARNINGS)

ELSE(MSVC)
ADD_DEFINITIONS(-Wno-unused-function -Wno-unused-variable -Werror)
SET(CMAKE_C_FLAGS "-Wall -std=gnu99")
SET(CMAKE_C_FLAGS_DEBUG "-g -O0")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11")
SET(CMAKE_CXX_FLAGS_DEBUG "-g -O0")

link_libraries(crypto)
link_libraries(ssl)

ENDIF(MSVC)

IF(CMAKE_BUILD_TYPE MATCHES "Debug")
ADD_DEFINITIONS(-D_DEBUG)
ENDIF()

add_library(ssock SHARED ${SSL_H} ${SSL_C})
set_target_properties(ssock PROPERTIES PREFIX "")
set_target_properties(ssock PROPERTIES SUFFIX ".so")
set_target_properties(ssock PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)
set_target_properties(ssock PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../../luaclib)

IF(MSVC)
set_target_properties(ssock PROPERTIES FOLDER "lualib")
#target_link_libraries(chestnut ../../../libbase)
target_link_libraries(ssock ws2_32 ../../../strawberry)
target_link_libraries(ssock ../../../3rd/openssl/libcrypto ../../../3rd/openssl/libssl)
target_link_libraries(ssock ../../../3rd/pthread-win32/bin/x64_MSVC2015.Debug/pthread_dll)
ENDIF()

ADD_DEPENDENCIES(ssock strawberry)
