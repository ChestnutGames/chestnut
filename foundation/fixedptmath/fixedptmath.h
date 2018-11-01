#ifndef fixmath_h
#define fixmath_h

#include "libfixmath/fixmath.h"

#define fix16_zero (0)
#define fix16_neg(a) fix16_sub(0, a)
#define fix16_min(a, b) (a > b ? b : a)
#define fix16_max(a, b) (a > b ? a : b)

#endif // !fixmath_h