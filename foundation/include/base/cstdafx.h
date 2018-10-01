#pragma once

#ifndef CSTDAFX_H
#define CSTDAFX_H

#ifdef __cplusplus
extern "C" {
#endif

#include <base/config.h>
#include <base/utarray.h>
#include <base/uthash.h>
#include <base/utlist.h>
#include <base/utringbuffer.h>
#include <base/utstring.h>

#ifdef FIXEDPT
#include <base/fixedptmath.h>
#include <base/fixedptmath3d.h>
#else
#include <math3d.h>
#endif // FIXEDPT

#ifdef __cplusplus
}
#endif
#endif // !STDAFX_H

