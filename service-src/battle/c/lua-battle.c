#define LUA_LIB

#include <lua.h>
#include <lauxlib.h>
#include <skynet.h>
#include <skynet_server.h>
#include <skynet_handle.h>
#include <message/message.h>
#include <message/battle_message.h>

#include <string.h>
#include <stdint.h>

static int 
ljoin(lua_State *L) {
	lua_Integer uid = luaL_checkinteger(L, 1);
	lua_Integer subid = luaL_checkinteger(L, 2);
	size_t msglen = sizeof(struct message) + sizeof(struct battle_join_request);
	struct message *msg = skynet_malloc(msglen);
	memset(msg, 0, msglen);
	struct battle_join_request *join_request = CAST_USERTYPE_POINTER(msg, struct battle_join_request);
	join_request->uid = uid;
	join_request->subid = subid;

	uint32_t source = skynet_current_handle();
	struct skynet_context *context = skynet_handle_grab(source);
	skynet_context_grab(context);
	skynet_sendname(context, source, ".xlogger", PTYPE_TEXT | PTYPE_TAG_DONTCOPY, 0, msg, msglen);
	skynet_context_release(context);

	return 0;
}

LUAMOD_API int 
luaopen_client_battle_core(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] =
	{
		{ "join", ljoin },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);

	return 1;
}
