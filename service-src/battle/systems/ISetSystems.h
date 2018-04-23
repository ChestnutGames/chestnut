#ifndef ISETSYSTEM_H
#define ISETSYSTEM_H

#include "Systems.h"
#include <memory>

namespace Chestnut {
	namespace Ball {
		class ISetSystems {
		public:
			virtual auto SetSystems(std::shared_ptr<Systems> systems)-> void = 0;
		};
	}
}
#endif