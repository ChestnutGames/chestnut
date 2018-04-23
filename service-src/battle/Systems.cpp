#include "Systems.h"

namespace Chestnut {
	namespace Ball {

		Systems::Systems() {}

		Systems::~Systems() {}

		auto Systems::GetJoinSystem()->Chestnut::Ball::JoinSystem * const {
			return &_joinSystem;
		}

		auto Systems::GetIndexSystem()->Chestnut::Ball::IndexSystem * const {
			return &_indexSystem;
		}

	}
}