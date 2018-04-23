#ifndef CONTEXT_H
#define CONTEXT_H


#include "Systems.h"
#include <unordered_map>
#include <skynet.h>

namespace Chestnut {
	namespace Ball {
		class Context {

		public:
			Context();
			~Context();

			auto GetSystems()->Systems * const;
			auto GetPool()->Chestnut::EntitasPP::Pool *const;

			auto DispatchResponse(int session, void *msg)->void;

			auto Send(const char *dst, const char *cmd, void *msg, size_t sz, std::function<void(void*)>) -> void;


		private:
			struct skynet_context * _context;
			Systems _systesm;
			Chestnut::EntitasPP::Pool _pool;
			std::unordered_map<int, std::function<void(void*)>> _response;
		};

	}
}
#endif // !CONTEXT_H
