mkdir -p build.linux64 && cd build.linux64
cmake ../
cd ..
#cmake --build build_linux64 --config Release
cmake --build build.linux64 --config Debug

# pause
