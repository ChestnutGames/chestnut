#include "Context.h"

#include <skynet_server.h>
#include <message/message.h>

namespace Chestnut {
	namespace Ball {

		Context::Context() {}

		Context::~Context() {}

		auto Context::GetSystems()->Systems * const {
			return &_systesm;
		}

		auto Context::GetPool()->Chestnut::EntitasPP::Pool *const {
			return &_pool;
		}

		auto Context::DispatchResponse(int session, void *msg)->void {
			if (_response.find(session) != _response.end()) {
				_response[session](msg);
			}
		}

		auto Context::Send(const char *dst, const char *cmd, void *msg, size_t sz, std::function<void(void*)> callback) -> void {
			const char *name = strcat("S2C", cmd);
			size_t msglen = sizeof(struct message) + sz;
			struct message *request = (struct message *)skynet_malloc(msglen);
			memset(request, 0, msglen);
			strcpy(request->cmd, name);
			memcpy(request + sizeof(struct message), msg, sz);
			int session = skynet_context_newsession(_context);
			_response[session] = callback;
			skynet_sendname(_context, 0, dst, PTYPE_TEXT | PTYPE_TAG_DONTCOPY, session, request, msglen);
		}

	}
}