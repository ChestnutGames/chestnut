#include <skynet.h>
#include <skynet_handle.h>
#include <skynet_server.h>
#include <skynet_server.h>
#include <base/list.h>
#include <message/message.h>
#include <message/xlogger_message.h>
#include <xlog/xlogger_buffer.h>

#include <assert.h>
#include <string.h>

#include <base/uthash.h>

typedef void(*response_cb_t)(struct message *msg);

struct shash {
	int id;
	response_cb_t cb;
	UT_hash_handle hh;
};

struct xlogger {
	struct list_head freelist;
	struct xlogger_buffer* curr_buffer;		// 当前缓冲区
	struct shash *hh;
};

struct xlogger *
xlogger_create(void) {
	struct xlogger * inst = skynet_malloc(sizeof(*inst));
	memset(inst, 0, sizeof(*inst));
	INIT_LIST_HEAD(&inst->freelist);

	inst->curr_buffer = skynet_malloc(sizeof(*inst->curr_buffer));
	xlogger_buffer_init(inst->curr_buffer);

	return inst;
}

void
xlogger_release(struct xlogger * inst) {
	if (inst->curr_buffer != NULL) {
		list_add_tail(&inst->curr_buffer->node, &inst->freelist);
	}
	struct list_head *pos = NULL, *n = NULL;
	list_for_each_safe(pos, n, &inst->freelist) {
		skynet_free((struct buffer *)pos);
	}
	skynet_free(inst);
}

static void
_response(struct xlogger * inst, const char *cmd, struct message *msg) {
	if (strcmp(cmd, "FLUSH") == 0) {
		struct xloggerd_flush_response *response = CAST_USERTYPE_POINTER(msg, struct xloggerd_flush_response);
		list_add_tail(&response->buffer->node, &inst->freelist);
	} else if (strcmp(cmd, "CLOSE") == 0) {
	}
}

static void 
send_flush(struct skynet_context * context, struct xlogger * inst, struct xlogger_buffer *buffer) {
	assert(buffer != NULL);
	size_t flush_message_size = sizeof(struct message) + sizeof(struct xloggerd_flush_request);
	struct message *flush = skynet_malloc(flush_message_size);
	memset(flush, 0, flush_message_size);
	const char *cmd = "FLUSH";
	memcpy(flush->cmd, cmd, strlen(cmd));
	struct xloggerd_flush_request *flush_request = CAST_USERTYPE_POINTER(flush, struct xloggerd_flush_request);
	flush_request->buffer = buffer;

	struct shash *h = skynet_malloc(sizeof(struct shash));
	int session = skynet_context_newsession(context);
	h->id = session;
	h->cb = NULL;
	HASH_ADD_INT(inst->hh, id, h);

	skynet_sendname(context, 0, ".xloggerd", PTYPE_TEXT | PTYPE_TAG_DONTCOPY, session, flush, flush_message_size);
}

static int
_logger(struct skynet_context * context, void *ud, int type, int session, uint32_t source, const void * msg, size_t sz) {
	struct xlogger * inst = ud;
	if (type == PTYPE_TEXT) {
		struct message *message = (struct message *)(msg);
		// response
		struct shash *s;
		HASH_FIND_INT(inst->hh, &session, s);
		if (s != NULL) {
			HASH_DEL(inst->hh, s);
			skynet_free(s);

			_response(inst, message->cmd, message);
			return 0;  // 不保留
		}

		// request
		if (strcmp(message->cmd, "APPEND") == 0) {
			if (inst->curr_buffer == NULL) { // 结束，不再写日志
				return 0;
			}
			struct xlogger_append_request *append_request = CAST_USERTYPE_POINTER(message, struct xlogger_append_request);
			if (inst->curr_buffer->size + append_request->size < LOG_BUFFER_SIZE) {
				memcpy(inst->curr_buffer->data + inst->curr_buffer->size, append_request->buffer, append_request->size);
				inst->curr_buffer->size += append_request->size;

				struct xlogger_buffer *buffer = inst->curr_buffer;
				inst->curr_buffer = NULL;

				if (list_empty(&inst->freelist)) {
					inst->curr_buffer = skynet_malloc(sizeof(*inst->curr_buffer));
				} else {
					inst->curr_buffer = (struct xlogger_buffer *)inst->freelist.next;
					list_del(inst->freelist.next);
				}
				xlogger_buffer_init(inst->curr_buffer);

				send_flush(context, inst, buffer);
			} else {
				struct xlogger_buffer *buffer = inst->curr_buffer;
				inst->curr_buffer = NULL;

				if (list_empty(&inst->freelist)) {
					inst->curr_buffer = skynet_malloc(sizeof(*inst->curr_buffer));
				} else {
					inst->curr_buffer = (struct xlogger_buffer *)inst->freelist.next;
					list_del(inst->freelist.next);
				}
				xlogger_buffer_init(inst->curr_buffer);

				memcpy(inst->curr_buffer->data + inst->curr_buffer->size, append_request->buffer, append_request->size);
				inst->curr_buffer->size += append_request->size;
				
				send_flush(context, inst, buffer);
			}

		} else if (strcmp(message->cmd, "CLOSE") == 0) {
			struct xlogger_buffer* buffer = inst->curr_buffer;
			inst->curr_buffer = NULL;

			size_t close_message_size = sizeof(struct message) + sizeof(struct xloggerd_close_request);
			struct message *close = skynet_malloc(close_message_size);
			const char *cmd = "CLOSE";
			memcpy(close->cmd, cmd, strlen(cmd));
			struct xloggerd_close_request *close_requesst = CAST_USERTYPE_POINTER(message, struct xloggerd_close_request);
			close_requesst->buffer = buffer;
			
			struct shash *h = skynet_malloc(sizeof(struct shash));
			int session = skynet_context_newsession(context);
			h->id = session;
			h->cb = NULL;
			HASH_ADD_INT(inst->hh, id, h);

			skynet_sendname(context, 0, ".xloggerd", PTYPE_TEXT | PTYPE_TAG_DONTCOPY, session, close, close_message_size);
		} else if (strcmp(message->cmd, "FLUSH") == 0) {
			struct shash *s;
			HASH_FIND_INT(inst->hh, &session, s);
			if (s != NULL) {
				HASH_DEL(inst->hh, s);
				skynet_free(s);

				_response(inst, "FLUSH", message);
				return 0;
			}

		} else {
			assert(0);
		}
	}
	return 0;
}

int
xlogger_init(struct xlogger * inst, struct skynet_context *ctx, const char * parm) {
	skynet_callback(ctx, inst, _logger);
	skynet_command(ctx, "REG", ".xlogger");
	skynet_command(ctx, "LAUNCH", "xloggerd");
	return 0;
}
