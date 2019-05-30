#define LUA_LIB

#include "xlogger_message.h"
#include "xlog/xlog.h"

#include <lua.h>
#include <lauxlib.h>
#include <skynet.h>
#include <ejoy/list.h>
#include <string.h>
#include <stdint.h>

#define MALLOC skynet_malloc
#define FREE skynet_free

static int
send_append_msg(lua_State *L, logger_level level, const char *src, size_t sz) {
	size_t msglen = sizeof(struct xlogger_append_request) + sz + 1;
	struct xlogger_append_request *append_request = MALLOC(msglen);
	memset(append_request, 0, msglen);

	memcpy(append_request->buffer, src, sz);
	append_request->buffer[sz] = '\n';
	append_request->size = sz + 1;
	append_request->level = level;

	lua_pushlightuserdata(L, append_request);
	lua_pushinteger(L, msglen);
	return 2;
}

static int
ldebug(lua_State *L) {
	size_t l = 0;
	const char * s = luaL_checklstring(L, 1, &l);
	if (l <= 0) {
		luaL_error(L, "xlog fatal msg len must be more than 0");
	}
	return send_append_msg(L, LOG_DEBUG, s, l);
}

static int
linfo(lua_State *L) {
	size_t l = 0;
	const char * s = luaL_checklstring(L, 1, &l);
	if (l <= 0) {
		luaL_error(L, "xlog fatal msg len must be more than 0");
	}
	return send_append_msg(L, LOG_INFO, s, l);
}

static int
lwarning(lua_State *L) {
	size_t l = 0;
	const char * s = luaL_checklstring(L, 1, &l);
	if (l <= 0) {
		luaL_error(L, "xlog fatal msg len must be more than 0");
	}
	return send_append_msg(L, LOG_WARNING, s, l);
}

static int
lerror(lua_State *L) {
	/*lua_State* L1 = luaL_newstate();
	luaL_traceback(L1, L, NULL, 1);
	size_t len;
	const char *ss = luaL_tolstring(L1, 1, &len);*/

	size_t l = 0;
	const char * s = luaL_checklstring(L, 1, &l);
	if (l <= 0) {
		luaL_error(L, "xlog fatal msg len must be more than 0");
	}
	return send_append_msg(L, LOG_ERROR, s, l);
}

static int
lfatal(lua_State *L) {
	size_t l = 0;
	const char * s = luaL_checklstring(L, 1, &l);
	if (l <= 0) {
		luaL_error(L, "xlog fatal msg len must be more than 0");
	}
	return send_append_msg(L, LOG_FATAL, s, l);
}

LUAMOD_API int
luaopen_xlog_core(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] =
	{
		{ "debug", ldebug },
		{ "info", linfo },
		{ "warning", lwarning },
		{ "error", lerror },
		{ "fatal", lfatal },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);

	return 1;
}
