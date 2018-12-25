set_property(GLOBAL PROPERTY USE_FOLDERS On)
cmake_minimum_required(VERSION 3.0.0)
project(skynet)
add_subdirectory(skynet-src)

#add_subdirectory(3rd/lua)
add_subdirectory(3rd/lpeg)
add_subdirectory(3rd/lua-md5)
add_subdirectory(3rd/kcp)

add_subdirectory(lualib-src)
add_subdirectory(lualib-src/sproto)
add_subdirectory(lualib-src/rapidjson)
add_subdirectory(lualib-src/chestnut)
add_subdirectory(lualib-src/rudp)
add_subdirectory(lualib-src/sssl)
add_subdirectory(lualib-src/skiplist)
add_subdirectory(lualib-src/crab)
add_subdirectory(lualib-src/aoi)
#add_subdirectory(lualib-src/bounce)

add_subdirectory(service-src)
add_subdirectory(service-src/xlogger)

#add_subdirectory(client-src)


