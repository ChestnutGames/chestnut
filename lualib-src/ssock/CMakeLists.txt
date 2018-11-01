project(ssock)

include_directories(../../3rd/lua)
include_directories(../../skynet-src)
include_directories(../../3rd/openssl/include)

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
IF(MSVC)
=======
IF(MSVC)	
>>>>>>> 575873cd484aea15ae9a087ed5c035ecbb42f187
=======
IF(MSVC)	
>>>>>>> 575873cd484aea15ae9a087ed5c035ecbb42f187
=======
IF(MSVC)	
>>>>>>> f6c4b0ac679435bd21a828c907e545d053798ed7
	include_directories(../../3rd/pthread-win32)
	include_directories(../../3rd/posix)
	add_definitions(-DLUA_BUILD_AS_DLL)
	add_definitions(-DNOUSE_JEMALLOC -DHAVE_STRUCT_TIMESPEC -DUSE_PTHREAD_LOCK -D_CRT_SECURE_NO_WARNINGS)
ELSE(MSVC)
	set (CMAKE_C_FLAGS "-std=gnu99 -Wall -Werror")
	set (CMAKE_C_FLAGS_DEBUG "-g -O0")
	set (CMAKE_CXX_FLAGS "-std=c++11 -Wall -Werror")
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
	RUNTIME_OUTPUT_DIRECTORY ../../../luaclib
	RUNTIME_OUTPUT_DIRECTORY_DEBUG ../../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY ../../../luaclib
	ARCHIVE_OUTPUT_DIRECTORY_DEBUG ../../../luaclib
	LIBRARY_OUTPUT_DIRECTORY ../../../luaclib
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ../../../luaclib
)

IF(MSVC)
	target_link_libraries(ssock ws2_32 ../../../strawberry)
	target_link_libraries(ssock ../../../3rd/openssl/lib/libcrypto ../../../3rd/openssl/lib/libssl)
	target_link_libraries(ssock ../../../3rd/pthread-win32/bin/x64_MSVC2015.Debug/pthread_dll)
ELSE(MSVC)
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
	find_library(CRYPTO_LIB libcrypto.a ../../3rd/openssl/lib NO_DEFAULT_PATH)
	find_library(SSL_LIB libssl.a ../../3rd/openssl/lib NO_DEFAULT_PATH)
	message(${CRYPTO_LIB})
    target_link_libraries(ssock ${CRYPTO_LIB} ${SSL_LIB})
    # target_link_libraries(ssock crypto ssl)
=======
=======
>>>>>>> 575873cd484aea15ae9a087ed5c035ecbb42f187
=======
>>>>>>> f6c4b0ac679435bd21a828c907e545d053798ed7
	find_library(CRYPTO_LIB crypto ../../../3rd/openssl/lib NO_DEFAULT_PATH)
	find_library(SSL_LIB ssl ../../../3rd/openssl/lib NO_DEFAULT_PATH)
	message(${CRYPTO_LIB})
	target_link_libraries(strawberry ${CRYPTO_LIB} ${SSL_LIB})
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 575873cd484aea15ae9a087ed5c035ecbb42f187
=======
>>>>>>> 575873cd484aea15ae9a087ed5c035ecbb42f187
=======
>>>>>>> f6c4b0ac679435bd21a828c907e545d053798ed7
ENDIF()

add_dependencies(ssock strawberry)
