#include "MoveSystem.h"

namespace Chestnut {
namespace Ball {

void MoveSystem::SetPool(std::shared_ptr<EntitasPP::Pool> pool) {
	this->pool = pool;
}

void MoveSystem::FixedExecute() {

}

}
}