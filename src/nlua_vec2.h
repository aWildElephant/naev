/*
 * See Licensing and Copyright notice in naev.h
 */


#ifndef NLUA_VEC2_H
#  define NLUA_VEC2_H


#include "nlua.h"
#include "physics.h"


#define VECTOR_METATABLE   "vec2"   /**< Vector metatable identifier. */

/* Helper. */
#define luaL_optvector(L,ind,def)   nluaL_optarg(L,ind,def,luaL_checkvector)

/*
 * Vector library.
 */
int nlua_loadVector( nlua_env env );

/*
 * Vector operations.
 */
Vector2d* lua_tovector( lua_State *L, int ind );
Vector2d* luaL_checkvector( lua_State *L, int ind );
Vector2d* lua_pushvector( lua_State *L, Vector2d vec );
int lua_isvector( lua_State *L, int ind );


#endif /* NLUA_VEC2_H */


