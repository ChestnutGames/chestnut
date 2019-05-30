#include "xloggerdd.h"

#include <skynet.h>
#include <skynet_timer.h>
#include <ejoy/list.h>

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <assert.h>
#include <stdbool.h>
#include <stdint.h>
#include <inttypes.h>

#ifdef _MSC_VER
#include <Windows.h>
#else
#include <dirent.h>
#endif // DEBUG

#define ONE_MB	          (1024*1024)
#define DEFAULT_ROLL_SIZE (128*ONE_MB)		// ��־�ļ��ﵽ512M������һ�����ļ�
#define DEFAULT_PATH      ("logs")
#define DEFAULT_INTERVAL  (5)			    // ��־ͬ�������̼��ʱ��

struct xloggerdd {
	logger_level loglevel;
	size_t rollsize;        // �ļ����ʱ�����
	FILE* handle[LOG_MAX];
	size_t written_bytes[LOG_MAX];	// ��д���ļ����ֽ���

	char path[32];

	struct list_head head;
};

static size_t
get_file_size(const char *filename) {
	struct stat statbuff;
	if (stat(filename, &statbuff) < 0) {
		return -1;
	}
	return statbuff.st_size;
}

static size_t
get_log_filename(char *basepath, logger_level level, char *filename, size_t count) {
	assert(level >= LOG_DEBUG && level < LOG_MAX);
	assert(filename != NULL);
	memset(filename, 0, count);

	uint32_t st = skynet_starttime();
	uint64_t ct = skynet_now();
	uint64_t cs = st + ct / 100;

	struct tm *tm = localtime((const time_t *)&cs);
	assert(tm != NULL);

	char timebuf[32] = { 0 };
	strftime(timebuf, sizeof(timebuf), "%Y%m%d", tm);
	if (level == LOG_DEBUG) {
		snprintf(filename, count, "%s/%s-%s-%llu.log", basepath, timebuf, "debug", cs);
	} else if (level == LOG_INFO) {
		snprintf(filename, count, "%s/%s-%s-%llu.log", basepath, timebuf, "info", cs);
	} else if (level == LOG_WARNING) {
		snprintf(filename, count, "%s/%s-%s-%llu.log", basepath, timebuf, "warning", cs);
	} else if (level == LOG_ERROR) {
		snprintf(filename, count, "%s/%s-%s-%llu.log", basepath, timebuf, "error", cs);
	} else if (level == LOG_FATAL) {
		snprintf(filename, count, "%s/%s-%s-%llu.log", basepath, timebuf, "fatal", cs);
	}
	return strlen(filename);
}

static void 
check_dir(struct xloggerdd *inst) {
	char path[32][32];  // max 32
	memset(path, 0, 32 * 32);
	int offset = 0;
	int s = 0;
	int p = 0;
	int len = strlen(inst->path);
	assert(len > 0);
	while (p < len) {
		if (inst->path[p] == '\\' || inst->path[p] == '/') {
			int c = memcmp(".", &inst->path[s], p - s);
			if (c != 0) {
				memcpy(path[offset], &inst->path[s], p - s);
				offset++;
				s = ++p;
			} else {
				s = ++p;
			}
		} else {
			p++;
		}
	}
	assert(len == p);
	if (p > s) {
		memcpy(path[offset], &inst->path[s], p - s);
		offset++;
	}

	int i = 0;
	for (; i < offset; i++) {
		if (strncmp(path[i], "..", 2) == 0) {
			continue;
		}
		char tmp[64] = { 0 };
		int tmpoffset = 0;
		int j = 0;
		for (; j <= i; j++) {
			int l = strlen(path[j]);
			memcpy(tmp + tmpoffset, path[j], l);
			tmpoffset += l;
#ifdef _MSC_VER
			tmp[tmpoffset] = '\\';
			tmpoffset++;
#else
			tmp[tmpoffset] = '/';
			tmpoffset++;
#endif // _MSC_VER
		}
		tmpoffset--;
		tmp[tmpoffset] = '\0';
#ifdef _MSC_VER
		BOOL bValue = FALSE;
		WIN32_FIND_DATA  FindFileData;
		HANDLE hFind = FindFirstFileA(tmp, &FindFileData);
		if ((hFind != INVALID_HANDLE_VALUE) && (FindFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
			bValue = TRUE;
		}
		FindClose(hFind);
		if (bValue) {
			continue;
		} else {
			CreateDirectoryA(tmp, NULL);
		}
#else
		// ��������ڣ������ļ���
		DIR* dir = opendir(tmp);
		if (dir == NULL) {
			switch (errno) {
			case ENOENT:
				if (mkdir(tmp, 0755) == -1) {
					fprintf(stderr, "mkdir error: %s\n", strerror(errno));
					exit(EXIT_FAILURE);
				}
				break;
			default:
				fprintf(stderr, "opendir error: %s\n", strerror(errno));
				exit(EXIT_FAILURE);
				break;
			}
		} else
			closedir(dir);
#endif // _MSC_VER
	}
}

struct xloggerdd *
xloggerdd_create(logger_level loglevel, size_t rollsize, const char *path) {
	struct xloggerdd *inst = (struct xloggerdd *)skynet_malloc(sizeof(*inst));
	memset(inst, 0, sizeof(*inst));

	inst->loglevel = loglevel;
	if (rollsize > 0) {
		inst->rollsize = rollsize * ONE_MB;
	} else {
		inst->rollsize = DEFAULT_ROLL_SIZE;
	}

	if (path == NULL)
		strncpy(inst->path, DEFAULT_PATH, strlen(DEFAULT_PATH));
	else {
		size_t pathlen = strlen(path);
		pathlen = pathlen > 32 ? 32 : pathlen;
		strncpy(inst->path, path, pathlen);
	}

	INIT_LIST_HEAD(&inst->head);

	return inst;
}

int
xloggerdd_init(struct xloggerdd *self) {
	check_dir(self);

	char fullpath[64] = { 0 };
	for (size_t i = self->loglevel; i < LOG_MAX; i++) {

		// create
		memset(fullpath, 0, 64);
		size_t len = get_log_filename(self->path, i, fullpath, 64);
		assert(len > 0);

		FILE *f = fopen(fullpath, "w+");
		if (f == NULL) {
#ifdef _MSC_VER
			DWORD dw = GetLastError();
			char buffer[128] = { 0 };
			if (FormatMessage(FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_FROM_SYSTEM,
				NULL,
				dw,
				0,
				buffer,
				sizeof(buffer) / sizeof(char),
				NULL)) {
				fprintf(stderr, "open file error: %s\n", buffer);
			}
#else
			fprintf(stderr, "open file error: %s\n", strerror(errno));
#endif // _MSC_VER
			f = stdout;
		}
		self->handle[i] = f;
	}
	return 0;
}

void 
xloggerdd_release(struct xloggerdd *self) {
	for (size_t i = self->loglevel; i < LOG_MAX; i++) {
		FILE *f = self->handle[i];
		if (f == NULL) {
			continue;
		}
		fclose(f);
	}
	skynet_free(self);
}

int
xloggerdd_push(struct xloggerdd *self, struct xlogger_append_request *request) {
	list_add_tail(&request->head, &self->head);
	return 0;
}

int
xloggerdd_flush(struct xloggerdd *self) {
	struct list_head *pos = NULL, *n = NULL;
	list_for_each_safe(pos, n, &self->head) {
		struct xlogger_append_request *request = (struct xlogger_append_request *)pos;
		if (request->level < self->loglevel) {
			skynet_free(request);
			continue;
		}
		assert(request->level >= LOG_DEBUG && request->level < LOG_MAX);
		FILE *f = self->handle[request->level];
		if (f == NULL) {
			skynet_free(request);
			continue;
		}
		size_t nbytes = 0;
		while (nbytes < request->size) {
#ifdef _MSC_VER
			size_t nn = _fwrite_nolock(request->buffer + nbytes, 1, request->size - nbytes, f);
#else
			size_t nn = fwrite_unlocked(request->buffer + nbytes, 1, request->size - nbytes, f);
#endif // _MSC_VER
			nbytes += nn;
		}
		self->written_bytes[request->level] += nbytes;
		skynet_free(request);
	}
	INIT_LIST_HEAD(&self->head);

	for (size_t i = self->loglevel; i < LOG_MAX; i++) {
		FILE *f = self->handle[i];
		if (f == NULL) {
			continue;
		}
		fflush(f);
	}

	// check roll
	for (size_t i = self->loglevel; i < LOG_MAX; i++) {
		FILE *f = self->handle[i];
		if (f == NULL) {
			continue;
		}
		size_t nbytes = self->written_bytes[i];
		if (nbytes > self->rollsize) {
			fclose(f);
			char fullpath[64] = { 0 };
			// create
			memset(fullpath, 0, 64);
			size_t len = get_log_filename(self->path, i, fullpath, 64);
			assert(len > 0);

			f = fopen(fullpath, "w+");
			if (f == NULL) {
#ifdef _MSC_VER
				DWORD dw = GetLastError();
				char buffer[128] = { 0 };
				if (FormatMessage(FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_FROM_SYSTEM,
					NULL,
					dw,
					0,
					buffer,
					sizeof(buffer) / sizeof(char),
					NULL)) {
					fprintf(stderr, "open file error: %s\n", buffer);
				}
#else
				fprintf(stderr, "open file error: %s\n", strerror(errno));
#endif // _MSC_VER
				f = stdout;
			}
			self->handle[i] = f;
		}
	}
	return 0;
}
