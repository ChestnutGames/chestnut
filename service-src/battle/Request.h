#ifndef REQUEST_H
#define REQUEST_H

#include <Context.h>
#include <message/battle_message.h>

namespace Chestnut {
	namespace Ball {

		class Request {
		public:
			Request();
			~Request();

			auto Start(battle_start_request *request) ->int;

			auto Join(battle_join_request *request) ->struct battle_join_response;

		private:
			Context * _context;

		};

	}
}

#endif // !REQUEST_H
