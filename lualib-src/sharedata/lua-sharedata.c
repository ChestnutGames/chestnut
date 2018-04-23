#define LUA_LIB

#include "shash.h"

#include <lua.h>
#include <lauxlib.h>

#include <stdlib.h>


static void 
lua_pushtable(lua_State *L) {
}

static int
_topointer(lua_State *L, lua_State *LL, const char *key) {
	return 0;
}

static int
linit(lua_State *L) {
	return 0;
}

static int 
lget(lua_State *L) {
	return 0;
}

static int
lset(lua_State *L) {
	return 0;
}

static int
lrelease(lua_State *L) {
	return 0;
}

LUAMOD_API int 
luaopen_sharedata_c(lua_State *L) {
	luaL_checkversion(L);

	luaL_Reg l[] = {
        {"init", linit},
        {"get", lget},
        {"set", lset},
        {"release", lrelease},
        {NULL, NULL}
    };

    luaL_newlib(L, l);
    return 1;
}