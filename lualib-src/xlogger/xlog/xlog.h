#ifndef XLOG_H
#define XLOG_H

typedef enum logger_level {
	LOG_DEBUG = 0,
	LOG_INFO,
	LOG_WARNING,
	LOG_ERROR,
	LOG_FATAL,
	LOG_MAX
} logger_level;

#endif // !XLOG_H
