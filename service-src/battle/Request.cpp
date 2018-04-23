#include "Request.h"

namespace Chestnut {
	namespace Ball {

		Request::Request() {}

		Request::~Request() {}

		auto Request::Start(battle_start_request *request) ->int {

		}

		auto Request::Join(battle_join_request *request) -> struct battle_join_response {
			_context->GetSystems()->GetJoinSystem()->Join(request->uid, request->subid);
			struct battle_join_response res;
			return res;
		}

	}
}