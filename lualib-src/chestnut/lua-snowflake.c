#define LUA_LIB

#include "snapshot.h"

#include <skynet.h>
#include <skynet_timer.h>

#include <lua.h>
#include <lauxlib.h>

#include <stdint.h>
#include <string.h>
#include <assert.h>

#define MAX_INDEX_VAL       (0x0fff)           // £¨12£©
#define MAX_WORKID_VAL      (0x03ff)           //  (10)
#define MAX_TIMESTAMP_VAL   (0x01ffffffffff)   //  (41)

typedef struct ctx {
	int64_t last_timestamp;
	int16_t work_id;
	int16_t index;
	volatile int inited;
} ctx_t;

// ms
static int64_t
get_timestamp() {
	int64_t st = skynet_starttime() * 100;   // sec
	int64_t ct = skynet_now();
	return (st + ct);
}

static void
wait_next_msec(ctx_t *TI) {
	assert(TI != NULL);
	int64_t current_timestamp = 0;
	do {
		current_timestamp = get_timestamp();
	} while (TI->last_timestamp >= current_timestamp);
	TI->last_timestamp = current_timestamp;
	TI->index = 0;
}

static int64_t
next_id(ctx_t *TI) {
	if (TI->inited != 1) {
		return -1;
	}
	int64_t current_timestamp = get_timestamp();
	if (current_timestamp == TI->last_timestamp) {
		if (TI->index < MAX_INDEX_VAL) {
			++TI->index;
		} else {
			wait_next_msec(TI);
		}
	} else {
		TI->last_timestamp = current_timestamp;
		TI->index = 0;
	}
	int64_t nextid = (int64_t)(
		((TI->last_timestamp & MAX_TIMESTAMP_VAL) << 22) |
		((TI->work_id & MAX_WORKID_VAL) << 12) |
		(TI->index & MAX_INDEX_VAL)
		);
	return nextid;
}

static int
linit(lua_State* L) {
	/*lua_State* L1 = luaL_newstate();
	luaL_traceback(L1, L, NULL, 1);
	size_t len;
	const char *s = luaL_tolstring(L1, 1, &len);*/

	lua_Integer id = luaL_checkinteger(L, 1);
	if (id < 0 || id > MAX_WORKID_VAL) {
		return luaL_error(L, "Work id is in range of 0 - 1023.");
	}

	ctx_t * TI = (ctx_t *)lua_newuserdata(L, sizeof(ctx_t));
	memset(TI, 0, sizeof(*TI));
	TI->last_timestamp = get_timestamp();
	TI->work_id = (int16_t)id;
	TI->index = 0;
	TI->inited = 1;

	return 1;
}

static int
lnextid(lua_State* L) {
	luaL_checktype(L, 1, LUA_TUSERDATA);
	ctx_t * TI = (ctx_t *)lua_touserdata(L, 1);
	int64_t id = next_id(TI);
	lua_pushinteger(L, id);
	return 1;
}

static int
lexit(lua_State *L) {
	luaL_checktype(L, 1, LUA_TUSERDATA);
	ctx_t * TI = (ctx_t *)lua_touserdata(L, 1);
	return 0;
}

LUAMOD_API int
luaopen_chestnut_snowflake(lua_State* l) {
	luaL_checkversion(l);
	luaL_Reg lib[] = {
		{ "init", linit },
		{ "next_id", lnextid },
		{ NULL, NULL }
	};
	luaL_newlib(l, lib);
	return 1;
}