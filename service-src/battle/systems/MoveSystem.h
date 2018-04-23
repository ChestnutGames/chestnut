#pragma once
#include <EntitasPP/ISystem.h>
#include <EntitasPP/Group.h>
#include <EntitasPP/Pool.h>

namespace Chestnut {
namespace Ball {

class MoveSystem :
	public EntitasPP::ISystem, public EntitasPP::ISetRefPoolSystem, public EntitasPP::IFixedExecuteSystem
{
public:
	
	void SetPool(std::shared_ptr<EntitasPP::Pool> pool);

	void FixedExecute();

protected:
	std::shared_ptr<Chestnut::EntitasPP::Pool> pool;

};

}
}