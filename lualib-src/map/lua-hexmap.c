#define LUA_LIB

#include <lua.h>
#include <lauxlib.h>

#include "hexmap.h"

static int
ldebug(lua_State *L) {
	size_t l = 0;
	return 0;
}



LUAMOD_API int
luaopen_chestnut_hexmap_core(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] =
	{
		{ "debug", ldebug },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
