mkdir build_win64 & pushd build_win64
cmake -G "Visual Studio 15 2017 Win64" ..
popd
cmake --build build_win64 --config Debug

REM pause