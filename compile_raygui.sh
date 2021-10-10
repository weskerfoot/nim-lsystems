#! /usr/bin/env bash

# Run from raygui/src
mv raygui.h raygui.c # Needed to compile as a shared library or else GCC won't expose symbols
gcc -shared -fPIC -DRAYGUIDEF -DRAYGUI_IMPLEMENTATION -lraylib -lGL -lm -lpthread -ldl -lrt -lX11 raygui.c -o raygui.so
mv raygui.c raygui.h
