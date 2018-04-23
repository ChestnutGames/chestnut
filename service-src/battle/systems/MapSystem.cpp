#include "MapSystem.h"
#include <components/IndexComponent.h>
#include <EntitasPP/Group.h>
#include <EntitasPP/Matcher.h>
#include <PxPhysicsAPI.h>
#include <stdio.h>


namespace Chestnut {
	namespace Ball {



		MapSystem::~MapSystem() {

		}

		void MapSystem::SetPool(std::shared_ptr< EntitasPP::Pool> pool) {
			this->pool = pool;
		}

		void MapSystem::Initialize() {
			/*const char *path = "./../../assets/map/map1.map";
			FILE *f = NULL;
			struct stat filestat;
			f = fopen(path, "rb");
			if (f != NULL) {
				stat(path, &filestat);
				char *buffer = (char *)malloc(sizeof(char) *(filestat.st_size + 1));
				size_t nread = 0;
				size_t bytes = fread(buffer + nread, sizeof(char), filestat.st_size - nread, f);
				nread += bytes;
				fclose(f);
				this->map = hexmap_create_from_plist(buffer, nread);
			}*/
		}

		void MapSystem::FixedExecute() {

		}

		void MapSystem::FindPath(int index, physx::PxVec3 start, physx::PxVec3 dst) {
			pool->GetEntities(Matcher_AllOf(IndexComponent));

		}


	}
}



