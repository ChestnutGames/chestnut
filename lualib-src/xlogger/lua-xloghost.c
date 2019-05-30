#define LUA_LIB

#include "xlogger_message.h"
#include "xlog/xlog.h"

#include <lua.h>
#include <lauxlib.h>

#include <ejoy/list.h>
#include <string.h>
#include <stdint.h>

struct xloggerd {
	struct xloggerdd *d;
};


static int
lalloc(lua_State *L) {
	const char *logdir = luaL_checkstring(L, 1);
	int rollsize = luaL_checkinteger(L, 2);
	struct xloggerd *d = lua_newuserdata(L, sizeof(*d));
	d->d = xloggerdd_create(LOG_INFO, rollsize, logdir);
	return 1;
}

static int
lfree(lua_State *L) {
	struct xloggerd *inst = lua_touserdata(L, 1);
	xloggerdd_release(inst->d);
	return 0;
}

static int
lclose(lua_State *L) {
	struct xloggerd *inst = lua_touserdata(L, 1);
	return 0;
}

static int
lappend(lua_State *L) {
	struct xloggerd *inst = lua_touserdata(L, 1);
	struct xlogger_append_request *append_request = lua_touserdata(L, 2);
	xloggerdd_push(inst->d, append_request);

	return 0;
}

static int
lflush(lua_State *L) {
	struct xloggerd *inst = lua_touserdata(L, 1);
	xloggerdd_flush(inst->d);
	return 0;
}

LUAMOD_API int
luaopen_xlog_host(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] =
	{
		{ "alloc", lalloc },
		{ "free",  lfree },
		{ "close",  lclose },
		{ "append", lappend },
		{ "flush", lflush },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);

	return 1;
}
