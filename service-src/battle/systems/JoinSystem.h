#pragma once

#include "ISetPool.h"
#include "ISetSystems.h"
#include "Systems.h"
#include <EntitasPP\Pool.h>
#include <EntitasPP\ISystem.h>

namespace Chestnut {
	namespace Ball {
		class JoinSystem : public EntitasPP::ISystem, public ISetPool, public ISetSystems {
		protected:

		public:

			JoinSystem() = default;
			virtual ~JoinSystem() = default;

			

			auto SetPool(std::shared_ptr<EntitasPP::Pool> pool) -> void;

			auto SetSystems(std::shared_ptr<Systems> systems)-> void;

			auto Join(int64_t uid, int64_t subid) -> void;

			auto Leave(int64_t uid) ->void;

		protected:
			std::shared_ptr<EntitasPP::Pool> _pool;
			std::shared_ptr<Systems> _systems;

		};
	}
}
