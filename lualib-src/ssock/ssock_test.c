//#include "ssock.h"
#include "https-client-c.h"

int
main(int argv, char **argc) {
	//struct ssock * so = ssock_alloc();
	struct http_response* resp = http_get("https://180.97.33.108:443", NULL);
	return 0;
}