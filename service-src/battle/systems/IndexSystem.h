#pragma once

#ifndef INDEXSYSTEM_H
#define INDEXSYSTEM_H

#include "ISetPool.h"
#include <EntitasPP/ISystem.h>
#include <EntitasPP/Pool.h>
#include <EntitasPP/Entity.h>
#include <unordered_map>

namespace Chestnut {
	namespace Ball {

		class IndexSystem :
			public EntitasPP::ISystem, public EntitasPP::IInitializeSystem, public EntitasPP::IFixedExecuteSystem {
		public:
			IndexSystem() = default;
			virtual ~IndexSystem() {}

			auto SystemType() ->int;

			auto SetPool(std::shared_ptr<EntitasPP::Pool> pool) -> void;

			auto Initialize() -> void;

			auto FixedExecute() -> void;

			auto OnEntityCreated(EntitasPP::Pool* pool, EntitasPP::EntityPtr entity) -> void;

			auto FindEntity(int index)->EntitasPP::EntityPtr;

			auto NextIndex() ->int;

		protected:

		private:
			RefCountedPtr< Chestnut::EntitasPP::Pool>  pool;
			std::unordered_map<int, EntitasPP::EntityPtr> entitas;
			int _index;
		};

	}
}

#endif // !INDEXSYSTEM_H


