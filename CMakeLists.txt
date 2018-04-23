set_property(GLOBAL PROPERTY USE_FOLDERS On)
cmake_minimum_required(VERSION 2.8.0)
project(skynet)
add_subdirectory(skynet-src)

#add_subdirectory(foundation)
#add_subdirectory(3rd/posix)
#add_subdirectory(3rd/lua)
add_subdirectory(3rd/lpeg)
add_subdirectory(3rd/lua-md5)
add_subdirectory(lualib-src)
add_subdirectory(lualib-src/sproto)
add_subdirectory(lualib-src/rapidjson)
add_subdirectory(lualib-src/chestnut)
add_subdirectory(service-src)


