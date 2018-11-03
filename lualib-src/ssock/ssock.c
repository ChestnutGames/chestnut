#include "ssock.h"
#if defined(WIN32) || defined(WIN64)
#include <Winsock2.h>
#include <Wininet.h>
#include <ws2tcpip.h>
#include <Windows.h>
#pragma comment (lib, "Ws2_32.lib")
#else
#include <sys/stat.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/timeb.h>
#include <netdb.h>
#include <sys/select.h>
#endif
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <time.h>
#include <assert.h>

static int
sssl_callback(void *ud, const char * cmd, int how) {
	if (strcmp(cmd, 'S') == 0) {
		struct ssock *so = (struct ssock *)ud;
		shutdown(so->fd, how);
	} else if (strcmp(cmd, 'K') == 0) {
		struct ssock *so = (struct ssock *)ud;
		closesocket(so->fd);
	}
}

struct ssock *
ssock_alloc() {
#if defined(_WIN32)
	WSADATA wsaData;
	int iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
	if (iResult != 0) {
		printf("WSAStartup failture.");
	}
#endif
	struct ssock *inst = (struct ssock *)malloc(sizeof(*inst));
	int fd = 0;
	if ((fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) == INVALID_SOCKET) {
		printf("创建socket 失败.");
		exit(0);
	}
	printf("创建套接字成功\r\n");
	inst->fd = fd;
	inst->ss = ss_normal;
	inst->sssl = sssl_alloc(inst, sssl_callback);
	return inst;
}

void
ssock_free(struct ssock *self) {
	sssl_free(self->sssl);
	free(self);
#if defined(_WIN32)
	WSACleanup();
#endif // defined(_WIN32)
}

int            
ssock_connect(struct ssock *self, const char *addr, int port) {
	struct sockaddr_in add;
	add.sin_family = AF_INET;
	if (inet_pton(AF_INET, addr, &add.sin_addr) < 0) {
		return -1;
	}
	add.sin_port = htons(port);
	int res = connect(self->fd, (struct sockaddr *)&add, sizeof(add));
	if (res < 0) {
#ifdef _WIN32
		int err = WSAGetLastError();
		if (err == EWOULDBLOCK) {

		}
#endif // _WIN32
		return -1;
	}
	printf("socket 链接成功\r\n");
	return sssl_connect(self->sssl);
}

int
ssock_update(struct ssock *self) {
	char buf[4096] = { 0 };
	int nread = recv(self->fd, buf, 4096, 0);
	if (nread > 0) {
		struct write_buffer *wb = sssl_poll(self->sssl, buf, nread);
		send(self->fd, wb->ptr, wb->len, 0);
	} else if (nread == 0) {
		// 断联
	} else if (nread < 0) {
		// 出错
		if (nread == WSAEWOULDBLOCK) {
			struct write_buffer *wb = sssl_poll(self->sssl, buf, 0);
			send(self->fd, wb->ptr, wb->len, 0);
		}
	}
	// recv
	sssl_recv(self->sssl, buf, 4096);
	printf(buf);
	return 1;
}

int
ssock_send(struct ssock *self, const char *buf, int size) {
	return sssl_send(self->sssl, buf, size);
}

int
ssock_shutdown(struct ssock *self, int how) {
	return sssl_shutdown(self->sssl, how);
}

int
ssock_close(struct ssock *self) {
	return sssl_close(self->sssl);
}

int            
ssock_clear(struct ssock *self) {
	return sssl_clear(self->sssl);
}

