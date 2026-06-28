#ifndef LUA_API_H
#define LUA_API_H

const char *lua_api_string =

    "\n"
    "function mapdraw(...)\n"
    "  map(...)\n"
    "end\n"
    "\n"
    "function cocreate(f)\n"
    "  return coroutine.create(f)\n"
    "end\n"
    "\n"
    "function yield()\n"
    "  coroutine.yield()\n"
    "end\n"
    "\n"
    "function coresume(f, ...)\n"
    "  return coroutine.resume(f, ...)\n"
    "end\n"
    "\n"
    "function costatus(f)\n"
    "  return coroutine.status(f)\n"
    "end\n"
    "\n"
    "function pack(...)\n"
    "  return {n=select('#',...), ...}\n"
    "end";

#endif
