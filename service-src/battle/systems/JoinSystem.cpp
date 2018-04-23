#include "JoinSystem.h"
#include <components/IndexComponent.h>
#include <components/PositionComponent.h>

namespace Chestnut {
	namespace Ball {

		auto JoinSystem::SetPool(std::shared_ptr<EntitasPP::Pool> pool) -> void {
			this->_pool = pool;
		}

		auto SetSystems(std::shared_ptr<Systems> systems)-> void {

		}

		void JoinSystem::Join(int64_t uid, int64_t subid) {

			auto entity = _pool->CreateEntity();
			entity->Add<Chestnut::Ball::IndexComponent>(index);
			entity->Add<Chestnut::Ball::PositionComponent>(fix16_zero, fix16_zero, fix16_zero);
		}

		auto JoinSystem::Leave(int64_t uid) ->void {

		}



	}
}