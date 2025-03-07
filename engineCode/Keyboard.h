#ifndef KEYBOARD_H
#define KEYBOARD_H

#include "GPU-Includes.h"

struct lua_State;

void updateKeyboardState();
void keyboardUpdateLua(lua_State* L);

void updateMouseState();
void mouseUpdateLua(lua_State* L);

#endif //KEYBOARD_H
