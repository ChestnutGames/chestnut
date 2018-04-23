#pragma once
#ifndef xlogger_buffer_h
#define xlogger_buffer_h

#include <base/list.h>
#include <string.h>

#define ONE_MB	        (1024*1024)
//#define LOG_BUFFER_SIZE (2*ONE_MB)			// һ��LOG������4M
#define LOG_BUFFER_SIZE (1*1024)			// һ��LOG������4M

struct xlogger_buffer {
	struct list_head node;
	char data[LOG_BUFFER_SIZE];
	int size;					           // ��������ʹ���ֽ���
};

static inline void
xlogger_buffer_init(struct xlogger_buffer *self) {
	self->node.prev = NULL;
	self->node.next = NULL;

	memset(self->data, 0, LOG_BUFFER_SIZE);
	self->size = 0;
}

#endif // !xlogger_buffer_h
