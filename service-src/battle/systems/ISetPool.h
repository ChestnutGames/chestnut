#ifndef ISETPOOL_H
#define ISETPOOL_H

#include <EntitasPP/Pool.h>

namespace Chestnut {
	namespace Ball {

		class ISetPool {
		public:
			ISetPool() = default;
			virtual ~ISetPool() = default;
			virtual auto SetPool(std::shared_ptr<EntitasPP::Pool> pool) -> void = 0;
		private:

		};
	}
}

#endif // !ISETPOOL_H
