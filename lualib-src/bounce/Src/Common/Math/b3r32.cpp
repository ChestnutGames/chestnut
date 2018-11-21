/*
* Copyright (c) 2015-2015 Irlan Robson http://www.irlans.wordpress.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/



#include "b3r32.h"
#include <fixmath.h>

b3R32::b3R32() {}

b3R32::b3R32(int32_t v) {
	i = v;
}

// Add this vector with another vector.
b3R32& b3R32::operator+=(const b3R32& b) {
	i = fx_addx(i, b.i);
	return (*this);
}

b3R32& b3R32::operator+=(b3R32& b) {
	i = fx_addx(i, b.i);
	return (*this);
}

// Subtract this vector from another vector.
b3R32& b3R32::operator-=(const b3R32& b) {
	i = fx_subx(i, b.i);
	return (*this);
}

b3R32& b3R32::operator-=(b3R32& b) {
	i = fx_subx(i, b.i);
	return (*this);
}

// Multiply this vector by a scalar.
b3R32& b3R32::operator*=(const b3R32& b) {
	i = fx_mulx(i, b.i, 10);
	return (*this);
}

b3R32& b3R32::operator*=(b3R32& b) {
	i = fx_mulx(i, b.i, 10);
	return (*this);
}

// Multiply this vector by a scalar.
b3R32& b3R32::operator/=(const b3R32& b) {
	i = fx_divx(i, b.i, 10);
	return (*this);
}

//	r32 operator[]( u32 i ) const {
//		return reinterpret_cast<const r32 *>(this)[i];
//	}
//
//	r32& operator[]( u32 i ) {
//		return reinterpret_cast<r32 *>(this)[i];
//	}
//
// Set to the zero vector.
void b3R32::SetZero() {
	i = 0;
}

// Set from a triple.
void b3R32::Set(int32_t v) {
	i = v;
}

// Negate a vector.
b3R32 operator-(const b3R32& v) {
	fixed_t i = fx_subx(0, v.i);
	return b3R32(i);
}

b3R32 & b3R32::operator++() {
	i = fx_addx(i, 1);
	return (*this);
}

b3R32 & b3R32::operator++(int) {
	i = fx_addx(i, 1);
	return (*this);
}

b3R32::operator bool() {
	return (i > 0);
}

b3R32 b3R32::Sqrt(const b3R32& b) {
	fixed_t i = fx_sqrtx(b.i, 10);
	return b3R32(i);
}

b3R32 b3R32::Sin(const b3R32& b) {
	fixed_t v = fx_sinx(b.i, 10);
	return b3R32(v);
}

b3R32 b3R32::Cos(const b3R32& b) {
	fixed_t v = fx_cosx(b.i, 10);
	return b3R32(v);
}

b3R32 b3R32::Atan2(const b3R32& a, const b3R32& b) {
	// TODO
	return b3R32(0);
}

// friend
// Compute sum of two vectors.
b3R32 operator+(const b3R32 a, const b3R32 b) {
	fixed_t v = fx_addx(a.i, b.i);
	return b3R32(v);
}

// Compute subtraction of two vectors.
b3R32 operator-(const b3R32 a, const b3R32 b) {
	fixed_t v = fx_subx(a.i, b.i);
	return b3R32(v);
}

b3R32 operator*(const b3R32 a, const b3R32 b) {
	fixed_t v = fx_mulx(a.i, b.i, 10);
	return b3R32(v);
}

b3R32 operator*(const float a, const b3R32 b) {
	//TODO::
	//fixed_t v = fx_mulx(a.i, b.i, 10);
	return b3R32(0);
}

b3R32 operator*(const double a, const b3R32 b) {
	// TODO
	return b3R32(0);
}

b3R32 operator/(const b3R32 a, const b3R32 b) {
	fixed_t v = fx_divx(a.i, b.i, 10);
	return b3R32(v);
}

bool  operator==(const b3R32 a, const b3R32 b) {
	return (a.i == b.i);
}

bool  operator!=(const b3R32 a, const b3R32 b) {
	return (a.i != b.i);
}

bool  operator<(const b3R32 a, const b3R32 b) {
	return (a.i < b.i);
}

bool  operator<=(const b3R32 a, const b3R32 b) {
	return (a.i <= b.i);
}

bool  operator>(const b3R32 a, const b3R32 b) {
	return (a.i > b.i);
}

bool  operator>=(const b3R32 a, const b3R32 b) {
	return (a.i >= b.i);
}

//
//// Compute scalar-vector product.
//inline b3R32 operator*(r32 s, const b3R32& v) {
//	return b3R32(s * v.x, s * v.y, s * v.z);
//}
//
//// Compute the length of a vector.
//inline r32 b3Len(const b3R32& v) {
//	return b3Sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
//}
//
//// Compute the squared length of a vector.
//inline r32 b3LenSq(const b3R32& v) {
//	return v.x * v.x + v.y * v.y + v.z * v.z;
//}
//
//// Compute the dot-product of two vectors.
//inline r32 b3Dot(const b3R32& a, const b3R32& b) {
//	return a.x * b.x + a.y * b.y + a.z * b.z;
//}
//
//// Compute the cross-product of two vectors.
//inline b3R32 b3Cross(const b3R32& a, const b3R32& b) {
//	return b3R32(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
//}
//
//// Computed the normalized vector of a (non-zero!) vector.
//inline b3R32 b3Normalize(const b3R32& v) {
//	//@warning the vector must be normalized.
//	r32 invLen = B3_ONE / b3Len(v);
//	return invLen * v;
//}
//
//// Create a basis matrix given a vector.
//inline void b3ComputeBasis(const b3R32& a, b3R32* b, b3R32* c) {
//	// From Box2D.
//	// Suppose vector a has all equal components and is a unit vector: a = (s, s, s)
//	// Then 3*s*s = 1, s = sqrt(1/3) = 0.57735. This means that at least one component of a
//	// unit vector must be greater or equal to 0.57735.
//	if ( b3Abs(a.x) >= r32(0.57735027) ) {
//		b->Set(a.y, -a.x, B3_ZERO);
//	}
//	else {
//		b->Set(B3_ZERO, a.z, -a.y);
//	}
//
//	*b = b3Normalize(*b);
//	*c = b3Cross(a, *b);
//}


