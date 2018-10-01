#ifndef xlogger_message_h
#define xlogger_message_h

#include <xlog/xlog.h>
#include <xlog/xlogger_buffer.h>

// ------------------------xlogger--------------------------------------
struct xlogger_append_request {
	struct list_head head;
	logger_level level;
	size_t size;
	char buffer[0];
};

// ------------------------xloggerd--------------------------------------
struct xloggerd_flush_request {
	struct xlogger_buffer *buffer;
};

struct xloggerd_flush_response {
	struct xlogger_buffer *buffer;
};

struct xloggerd_close_request {
	struct xlogger_buffer *buffer;
};

struct xloggerd_close_response {
	struct xlogger_buffer *buffer;
};

#endif // !xlogger_message_h
