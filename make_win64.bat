mkdir build.win64 & pushd build.win64
cmake -G "Visual Studio 15 2017 Win64" ..
popd
cmake --build build.win64 --config Debug

REM pause