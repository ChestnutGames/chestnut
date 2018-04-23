#include "Context.h"
#include "Request.h"

#include <skynet.h>
#include <skynet_env.h>
#include <message/message.h>
#include <message/battle_message.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <assert.h>

struct battled {
	Chestnut::Ball::Context context;
	Chestnut::Ball::Request request;
};

struct battled *
	battle_create(void) {
	struct battled *inst = (struct battled *)skynet_malloc(sizeof(struct battled));
}

void
battle_release(struct battled * inst) {
	skynet_free(inst);
}

static int
_logger(struct skynet_context * context, void *ud, int type, int session, uint32_t source, const void * msg, size_t sz) {
	struct battled * inst = (struct battled *)ud;
	if (type == PTYPE_TEXT) {
		struct message *message = (struct message *)(msg);
		if (strcmp(message->cmd, "C2S_JOIN") == 0) {
			battlec2s_join_response res = inst->request.Join(CAST_USERTYPE_POINTER(message, struct battlec2s_join_request));
			size_t msglen = sizeof(struct message) + sizeof(struct battlec2s_join_response);
			struct message *response = (struct message *)skynet_malloc(msglen);
			memset(response, 0, msglen);
			strcpy(response->cmd, "C2S_JOIN");
			response->type = message_type::response;
			memcpy(response + sizeof(struct message), &res, sizeof(res));
			skynet_send(context, 0, source, PTYPE_TEXT | PTYPE_TAG_DONTCOPY, session, response, msglen);
			return 1;
		} else if (strcmp(message->cmd, "CLOSE") == 0) {
			return 1;
		} else {
			assert(0);
		}
	}
	return 0;
}

int
battle_init(struct loggerdd * inst, struct skynet_context *ctx, const char * parm) {
	skynet_callback(ctx, inst, _logger);
	skynet_command(ctx, "REG", ".battle");
	return 0;
}
