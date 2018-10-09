#ifndef skynet_xlogger_h
#define skynet_xlogger_h

#include <message/message.h>
#include <message/xlogger_message.h>

//#define LOG_MAX (4*1024)						// ����LOG�4K

struct xloggerdd;
struct xloggerdd *
xloggerdd_create(logger_level loglevel, size_t rollsize, const char *path);

int xloggerdd_init(struct xloggerdd *self);
void xloggerdd_release(struct xloggerdd *self);

int xloggerdd_push(struct xloggerdd *self, struct xlogger_append_request *request);
int xloggerdd_flush(struct xloggerdd *self);

#endif