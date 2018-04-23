#ifndef SYSTEMS_H
#define SYSTEMS_H

#include <systems/JoinSystem.h>
#include <systems/IndexSystem.h>

namespace Chestnut {
	namespace Ball {

		class Systems {
		public:
			Systems();
			~Systems();

			auto GetJoinSystem()->Chestnut::Ball::JoinSystem * const;
			auto GetIndexSystem()->Chestnut::Ball::IndexSystem * const;

		private:

			Chestnut::Ball::JoinSystem _joinSystem;
			Chestnut::Ball::IndexSystem _indexSystem;
		};

	}
}

#endif // !SYSTEMS_H
