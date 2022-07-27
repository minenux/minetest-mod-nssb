nssb = {}

local path = minetest.get_modpath("nssb")

nssb.is_50 = minetest.has_feature("object_use_texture_alpha") or nil

dofile(path .. "/nodes.lua")
dofile(path .. "/mapgen.lua")
dofile(path .. "/spawn.lua")
