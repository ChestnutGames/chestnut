#ifndef XLOG_H
#define XLOG_H

#include <base/list.h>
#include <string.h>


typedef enum logger_level {
	LOG_DEBUG = 0,
	LOG_INFO,
	LOG_WARNING,
	LOG_ERROR,
	LOG_FATAL,
	LOG_MAX
} logger_level;

#define XLOGER_APPEND_BUFFER_CAP (512)

struct xlogger_append_buffer {
	struct list_head node;
	logger_level level;
	int size;					           // 缓冲区已使用字节数
	char data[XLOGER_APPEND_BUFFER_CAP];
};

static inline void
xlogger_append_buffer_init(struct xlogger_append_buffer *self) {
	INIT_LIST_HEAD(&self->node);
	self->level = LOG_DEBUG;
	self->size = 0;
	memset(self->data, 0, XLOGER_APPEND_BUFFER_CAP);
}

#endif // !XLOG_H
