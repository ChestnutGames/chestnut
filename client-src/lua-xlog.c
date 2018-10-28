#define LUA_LIB

#include <lua.h>
#include <lauxlib.h>
#include <skynet.h>
#include <skynet_server.h>
#include <skynet_handle.h>
#include <message/message.h>
#include <message/xlogger_message.h>
#include <xlog/xlog.h>
#include <base/list.h>

#include <string.h>
#include <stdint.h>

static void
send_append_msg(logger_level level, const char *src, size_t sz) {
	size_t msglen = sizeof(struct message) + sizeof(struct xlogger_append_request) + sz + 1;
	struct message *msg = skynet_malloc(msglen);
	memset(msg, 0, msglen);
	const char *cmd = "APPEND";
	strncpy(msg->cmd, cmd, strlen(cmd));

	struct xlogger_append_request *append_request = CAST_USERTYPE_POINTER(msg, struct xlogger_append_request);
	memcpy(append_request->buffer, src, sz);
	append_request->buffer[sz] = '\n';
	append_request->size = sz + 1;
	append_request->level = level;

	uint32_t source = skynet_current_handle();
	struct skynet_context *context = skynet_handle_grab(source);
	if (context == NULL) {
		return;
	}
	skynet_context_grab(context);
	skynet_sendname(context, source, ".xloggerd", PTYPE_TEXT | PTYPE_TAG_DONTCOPY, 0, msg, msglen);
	skynet_context_release(context);
}

static int
ldebug(lua_State *L) {
	size_t l = 0;
	const char * s = luaL_checklstring(L, 1, &l);
	if (l <= 0) {
		luaL_error(L, "xlog fatal msg len must be more than 0");
	}
	send_append_msg(LOG_DEBUG, s, l);
	return 0;
}

static int
linfo(lua_State *L) {
	size_t l = 0;
	const char * s = luaL_checklstring(L, 1, &l);
	if (l <= 0) {
		luaL_error(L, "xlog fatal msg len must be more than 0");
	}
	send_append_msg(LOG_INFO, s, l);
	return 0;
}

static int
lwarning(lua_State *L) {
	size_t l = 0;
	const char * s = luaL_checklstring(L, 1, &l);
	if (l <= 0) {
		luaL_error(L, "xlog fatal msg len must be more than 0");
	}
	send_append_msg(LOG_WARNING, s, l);
	return 0;
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
	send_append_msg(LOG_ERROR, s, l);
	return 0;
}

static int
lfatal(lua_State *L) {

	size_t l = 0;
	const char * s = luaL_checklstring(L, 1, &l);
	if (l <= 0) {
		luaL_error(L, "xlog fatal msg len must be more than 0");
	}
	send_append_msg(LOG_FATAL, s, l);
	return 0;
}

LUAMOD_API int
luaopen_client_xlog_core(lua_State *L) {
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
