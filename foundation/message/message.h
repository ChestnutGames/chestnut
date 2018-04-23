#ifndef MESSAGE_H
#define MESSAGE_H

#include <skynet.h>
#include <string.h>

struct message {
	char cmd[32];
};

#define CAST_MESSAGE_POINTER(p) ((struct message *)((char *)p - sizeof(struct message)))
#define CAST_USERTYPE_POINTER(p, t) ((t*)((char *)p + sizeof(struct message)))

#endif // !MESSAGE_H
