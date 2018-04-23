#pragma once

#include "ISetPool.h"
#include <EntitasPP/ISystem.h>
#include <EntitasPP/Pool.h>
#include <foundation/PxVec3.h>
#include <memory>

namespace Chestnut {
	namespace Ball {

		class MapSystem :
			public  EntitasPP::ISystem, public ISetPool, public EntitasPP::IInitializeSystem, public EntitasPP::IFixedExecuteSystem {

		public:
			
			MapSystem() = default;
			virtual ~MapSystem();

			void SetPool(std::shared_ptr<EntitasPP::Pool> pool);

			void Initialize();

			void FixedExecute();

			void FindPath(int index, physx::PxVec3 start, physx::PxVec3 dst);

		protected:

		private:
			std::shared_ptr<Chestnut::EntitasPP::Pool> pool;


		};

	}
}