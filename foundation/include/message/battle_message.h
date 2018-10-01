#ifndef BATTLE_MESSAGE_H
#define BATTLE_MESSAGE_H

#include <stdint.h>

//--------------------c2s--------------------
struct battle_start_request {
	int dummy;
};

struct battle_start_response {
	int errorcode;
};

struct battle_join_request {
	int64_t uid;
	int64_t subid;
};

struct battle_join_response {
	int64_t errorcode;
};


#endif // !BATTLE_MESSAGE_H
