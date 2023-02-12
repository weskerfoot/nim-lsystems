#! /usr/bin/env bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/wes/code/lsystem/raylib/raylib:/home/wes/code/lsystem
export LIBRARY_PATH=$LD_LIBRARY_PATH:/home/wes/code/lsystem/raylib/raylib:/home/wes/code/lsystem
cd raylib
git fetch
cmake -DBUILD_SHARED_LIBS=ON .
make clean || true
export PLATFORM=PLATFORM_DESKTOP
export RAYLIB_LIBTYPE=SHARED
make
sudo ldconfig
cd ../

rm -f raygui/raygui.so
rm -f raygui.so
cd raygui && git fetch
gcc -L./raylib/raylib -o raygui.so src/raygui.c -shared -fpic -DRAYGUI_IMPLEMENTATION -lGL -lm -lpthread -ldl -lrt -lX11 -lraylib
cp ./src/raygui.h ./src/raygui.c
cp raygui.so ../
sudo cp raygui.so /usr/lib/raygui.so
