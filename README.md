## ![skynet logo](https://github.com/cloudwu/skynet/wiki/image/skynet_metro.jpg)

Skynet is a lightweight online game framework, and it can be used in many other fields.

## Build

CMake 3.12
Visual Studio 2017
Gnumake

For Win, install Visual Studio 2017

```
git clone https://github.com/mephostopilis/chestnut.git
cd chestnut
make_win64.bat
```

For Linux, install autoconf first for jemalloc:

```
git clone https://github.com/cloudwu/skynet.git
cd skynet
make 'PLATFORM'  # PLATFORM can be linux, macosx, freebsd now
```

Or you can:

```
export PLAT=linux
make
```

For FreeBSD , use gmake instead of make.

## Test

Run these in different consoles:

```
./skynet examples/config	# Launch first skynet node  (Gate server) and a skynet-master (see config for standalone option)
./3rd/lua/lua examples/client.lua 	# Launch a client, and try to input hello.
```

## About Lua version

Skynet now uses a modified version of lua 5.3.4 ( https://github.com/ejoy/lua/tree/skynet ) for multiple lua states.

You can also use official Lua versions, just edit the Makefile by yourself.

## How To Use (Sorry, currently only available in Chinese)

* Read Wiki for documents https://github.com/cloudwu/skynet/wiki
* The FAQ in wiki https://github.com/cloudwu/skynet/wiki/FAQ
