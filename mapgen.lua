--schematichs generation

function nssb_register_buildings(
	build,			-- name of the schematic
	rand,			-- 1/rand is the probability of the spawning of the schematic if the place found is acceptable
	posschem,		-- the block on which the schematic need to be to spawn
	down,			-- useful in finding flat surfaces, down indetify the x and z coordinates of a block 1 under posschem
	downblock,		-- the block that is necessary to find in down to place the schematic
	above,			-- when you need to place the schem under something (water, air, jungleleaves...) above is the number of blocks above posschem
	aboveblock,		-- the name of this block above above-times posschem
	radius,			-- the radius in which the function search for the "near" block
	near,			-- the block that is necessary to spawn the schem in the radius
	side,			-- the mesure of the side of the schematic, it is necessary to put the dirt under it
	underground,	-- if true the schematic need to spawn underground
	height,			-- under this heigh the schematic can spawn. If nil the schematic can spawn everywhere underground
	ice,			-- if true fill the space under the schem with ice and not with dirt as standard
	exact_height, 	-- exact_height=exact_eight under the surface in the correct place
	portal)			-- is this schematic a portal for the morlendor?

	minetest.register_on_generated(function(minp, maxp, seed)
		if underground==false then
			local i, j, k
			local flag=0
			local posd
			i = math.random(minp.x, maxp.x)
			k = math.random(minp.z, maxp.z)
			for j=minp.y,maxp.y do
				local pos1 = {x=i, y=j, z=k}
				local pos2 = {x=i+down, y=j-1, z=k+down}
				local pos3 = {x=i, y=j+above, z=k}
				local n = minetest.env:get_node(pos1).name
				local u = minetest.env:get_node(pos2).name
				local d = minetest.env:get_node(pos3).name
				if (downblock==nil) then
					u = downblock
				end
				if (aboveblock==nil) then
					d = aboveblock
				end
				if n== posschem and u== downblock and d==aboveblock and flag==0 and math.random(1,rand)==1 then
					if minetest.find_node_near(pos3, radius, near) then
							minetest.place_schematic(pos1, minetest.get_modpath("nssb").."/schems/".. build ..".mts", "0", {}, true)
							--minetest.chat_send_all("Added schematic in "..(minetest.pos_to_string(pos1)))
							posd=pos1
							flag=1
					end
				end
			end
			--Puts dirt/ice under the schematic to fill the space under it
			if flag==1 and side>0 then
				for dx = 0,side do
					for dz = 0,side do
						local dy=posd.y-1
						local f = {x = posd.x+dx, y=dy, z=posd.z+dz}
						local fg = minetest.env:get_node(f).name
						if ice == false then
							while fg=="air" do
								minetest.env:set_node(f, {name="default:dirt"})
								f.y=f.y-1
								fg = minetest.env:get_node(f).name
							end
						else
							while fg=="air" do
									minetest.env:set_node(f, {name="default:ice"})
									f.y=f.y-1
									fg = minetest.env:get_node(f).name
							end
						end
					end
				end
			end
			if portal==true then
				--this is a portal for the morlendor



			end
		else	--underground==true
			if minp.y<0 then
				minetest.chat_send_all("Posmin: "..(minetest.pos_to_string(minp)).." Posmax: "..(minetest.pos_to_string(maxp)))
				local i, jj, k, j
				local flag=0

				i = math.random(minp.x, maxp.x)
				k = math.random(minp.z, maxp.z)
				jj = math.random(minp.y, maxp.y)
				if height~=nil then
					if height>maxp.y then
						j = jj
					elseif height>minp.y and height<maxp.y then
						j = math.random(minp.y, height)
					else
						return
					end
				else
					if jj>0 then
						j = math.random(minp.y, 0)
					end
				end
				local pos1={x=i, y=j, z=k}
				local n = minetest.env:get_node(pos1).name
				if minetest.find_node_near(pos1, radius, "default:lava_source")or flag==1 then
					return
				else
					if n==posschem and math.random(1,rand)==1 then
						minetest.place_schematic(pos1, minetest.get_modpath("nssb").."/schems/".. build ..".mts", "0", {}, true)
						flag=1
						--minetest.chat_send_all("Added schematic in "..(minetest.pos_to_string(pos1)))
					end
				end
			end
		end
	end)
end

nssb_register_buildings ('spiaggiagranchius', 2, "default:sand", 3, "default:sand", 2, "air",  3, "air", 0, false, nil, false, false, false)
nssb_register_buildings ('acquagranchius', 3, "default:sand", 3, "default:sand", 12,"default:water_source", 3, "default:water_source", 0, false, nil, false, false, false)
nssb_register_buildings ('ooteca', 6, "default:dirt_with_grass", 3, "default:dirt", 2, "air", 24, "default:tree", 8, false, nil, false, false, false)
nssb_register_buildings ('minuscolaooteca', 6, "default:dirt_with_grass",3 , "default:dirt", 2, "air", 24, "default:tree", 2, false, nil, false, false, false)
nssb_register_buildings ('piccolaooteca', 6, "default:dirt_with_grass", 2, "default:dirt", 2, "air", 24, "default:tree", 4, false, nil, false, false, false)
nssb_register_buildings ('arcate', 8, "default:sand", 3, "default:sand", 13, "default:water_source", 3, "default:water_source",0, false, nil, false, false, false)
nssb_register_buildings ('grandepiramide', 8, "default:dirt", 3, "default:dirt", 20, "default:water_source", 3, "default:water_source", 0, false, nil, false, false, false)
nssb_register_buildings ('collina', 5, "default:dirt_with_grass", 3, "default:dirt", 2, "air", 3, "air", 12, false, nil, false, false, false)
nssb_register_buildings ('megaformicaio', 7, "default:dirt_with_grass", 4, "default:dirt", 2, "air", 3, "air", 25, false, nil, false, false, false)
nssb_register_buildings ('antqueenhill', 8, "default:dirt_with_grass", 4, "default:dirt", 2, "air", 3, "air", 21, false, nil, false, false, false)
nssb_register_buildings ('rovine1', 4, "default:dirt_with_grass", 3, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)
--nssb_register_buildings ('rovine2', 1, "default:stone", 0, "air",  0, "air", 24, "default:jungletree", 5, true, -8, false, false)
nssb_register_buildings ('rovine3', 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)
nssb_register_buildings ('rovine4', 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)
nssb_register_buildings ('rovine5', 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)
nssb_register_buildings ('rovine6', 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)
nssb_register_buildings ('rovine7', 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)
nssb_register_buildings ('rovine8', 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)
nssb_register_buildings ('rovine9', 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)
nssb_register_buildings ('rovine10', 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)
nssb_register_buildings ('bozzoli', 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)
nssb_register_buildings ('blocohouse', 4, "default:stone", 0, "air",  0, "air", 3, "default:stone", 5, true, -10, false, false, false)
nssb_register_buildings ('bigblocohouse', 4, "default:stone", 0, "air",  0, "air", 3, "default:stone", 5, true, -20, false, false, false)
nssb_register_buildings ('blocobiggesthouse', 4, "default:stone", 0, "air",  0, "air", 3, "default:stone", 5, true, -30, false, false, false)
nssb_register_buildings ('picco', 12, "default:desert_sand", 1, "default:desert_stone",  1, "air", 3, "default:desert_sand", 10, false, nil, false, false, false)
nssb_register_buildings ('piccoghiaccio', 12, "default:dirt_with_snow", 1, "default:dirt",  1, "air", 3, "default:dirt_with_snow", 10, false, nil, true, false, false)
nssb_register_buildings ('icehall', 8, "default:dirt_with_snow", 1, "default:dirt",  1, "air", 3, "default:dirt_with_snow", 30, false, nil, true, false, false)
nssb_register_buildings ('piccomoonheron', 8, "default:dirt_with_snow", 1, "default:dirt",  1, "air", 3, "default:dirt_with_snow", 3, false, nil, true, false, false)
nssb_register_buildings ('doppiopiccoghiaccio', 11, "default:dirt_with_snow", 1, "default:dirt",  1, "air", 3, "default:dirt_with_snow", 7, false, nil, true, false, false)
nssb_register_buildings ('doppiopiccosabbia', 11, "default:desert_sand", 1, "default:desert_stone",  1, "air", 3, "default:desert_sand", 7, false, nil, false, false, false)
nssb_register_buildings ('piccoscrausics', 8, "default:desert_sand", 1, "default:desert_stone",  1, "air", 3, "default:desert_sand", 3, false, nil, false, false, false)
nssb_register_buildings ('fossasand', 1, "default:desert_sand", 1, "default:desert_stone",  1, "air", 3, "default:desert_sand", 16, false, nil, false, false, false)
nssb_register_buildings ('portal', 1, "default:dirt_with_grass", 2, "default:dirt", 2, "air", 24, "air", 7, false, nil, false, false, true)

--minetest.place_schematic({x=0, y=-1000, z=0}, minetest.get_modpath("nssb").."/schems/portalhome.mts", "0", {}, true)
--abm

minetest.register_abm({
	nodenames = {"default:torch"},
	neighbors = {"nssb:morentir","nssb:morkemen"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node)
			minetest.set_node({x = pos.x, y = pos.y , z = pos.z}, {name = "nssb:mornar"})
		end
})

minetest.register_abm({
	nodenames = {"nssb:morlote"},
	neighbors = {"air"},
	interval = 30,
	chance = 40,
	action =
	function(pos, node)
		local pos1 = {x=pos.x, y=pos.y+1, z=pos.z}
		local n = minetest.env:get_node(pos1).name
		if n ~= "air" then
			return
		end
		minetest.add_entity(pos1, "nssm:morgre")
		minetest.remove_node(pos)
	end
})
--[[ danno degli errori strani
minetest.register_abm({
	nodenames = {"nssb:fall_morentir"},
	neighbors = {"nssb:fall_morentir"},
	interval = 10,
	chance = 3,
	action =
	function(pos, node)
		nodeupdate(pos)
	end
})

minetest.register_abm({
	nodenames = {"nssb:boum_morentir"},
	neighbors = {"nssb:morentir"},
	interval = 1,
	chance = 3,
	action =
	function(self, pos, node)
        explosion(pos, 3, 1)
	end
})
]]

minetest.register_abm({
	nodenames = {"nssb:mornen", "nssb:mornen_flowing"},
	neighbors = {"air"},
	interval = 1.0,
	chance = 3,
	action =
		function (pos, node)
			minetest.add_particlespawner({
				amount = 3,
				time = 3,
				minpos = {x=pos.x-0.5, y=pos.y+0.5, z=pos.z-0.5},
				maxpos = {x=pos.x+0.5, y=pos.y+0.5, z=pos.z+0.5},
				minvel = {x=0, y=0.1, z=0},
				maxvel = {x=0, y=0.3, z=0},
				minacc = {x=0,y=0,z=0},
				maxacc = {x=0,y=0,z=0},
				minexptime = 1,
				maxexptime = 1.2,
				minsize = 0.5,
				maxsize = 0.7,
				collisiondetection = false,
				vertical = true,
				texture = "morparticle.png",
			})
		end

})


minetest.register_abm({
	nodenames = {"nssb:portal"},
	neighbors = {"air"},
	interval = 5.0,
	chance = 1,
	action =
		function (pos, node)
			minetest.add_particlespawner({
				amount = 15,
				time = 1,
				minpos = {x=pos.x-0.5, y=pos.y+0.5, z=pos.z-0.5},
				maxpos = {x=pos.x+0.5, y=pos.y+0.5, z=pos.z+0.5},
				minvel = {x=0, y=0.1, z=0},
				maxvel = {x=0, y=0.8, z=0},
				minacc = {x=0,y=0,z=0},
				maxacc = {x=0,y=0.4,z=0},
				minexptime = 1,
				maxexptime = 3,
				minsize = 0.5,
				maxsize = 1.4,
				collisiondetection = false,
				vertical = true,
				texture = "morparticle.png",
			})
			for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
				if obj:is_player() then
					local posp = obj:getpos()
					minetest.chat_send_all("Posizione: "..minetest.pos_to_string(posp))
					for i=-5,5 do
						for k = -5,5 do
							local pos1 = {x=pos.x+i,y=pos.y,z=pos.z+k}
							local name = minetest.env:get_node(pos1).name
							if name == "nssb:memoryone" then
								obj:setpos({x=pos1.x, y=pos1.y+2, z =pos1.z})
								local meta = minetest.get_meta(pos1)
								meta:set_string("player"..obj:get_player_name(), minetest.pos_to_string(posp))
							end
						end
					end

					--[[
					local pos1 = {x=pos.x,y=-30093,z=pos.z}
					local pos2 = {x=pos.x,y=-30092,z=pos.z}
					local name = minetest.env:get_node(pos1).name
					local name2
					if name == "ignore" then
						minetest.get_voxel_manip():read_from_map(pos1, pos1)
						if not minetest.get_node_or_nil(pos1) then
							minetest.emerge_area(vector.subtract(pos1, 80), vector.add(pos1, 80))
							minetest.forceload_block(pos1)
						end

						--minetest.get_voxel_manip():read_from_map(pos1, pos1)
						--minetest.chat_send_all("Dentro")
						--minetest.get_voxel_manip():read_from_map(pos2, pos2)
						name = minetest.get_node(pos1).name
						name2 = minetest.get_node(pos2).name
					end
					if (name=="air") and (name2=="air") then
						obj:setpos(pos1)
					else
						minetest.chat_send_all("Name: "..name.." Name2: "..name2)
					end
					]]
				end
			end
		end
})

minetest.register_abm({
	nodenames = {"nssb:portalhome"},
	neighbors = {"air"},
	interval = 5.0,
	chance = 1,
	action =
		function (pos, node)
			minetest.add_particlespawner({
				amount = 15,
				time = 1,
				minpos = {x=pos.x-0.5, y=pos.y+0.5, z=pos.z-0.5},
				maxpos = {x=pos.x+0.5, y=pos.y+0.5, z=pos.z+0.5},
				minvel = {x=0, y=0.1, z=0},
				maxvel = {x=0, y=0.8, z=0},
				minacc = {x=0,y=0,z=0},
				maxacc = {x=0,y=0.4,z=0},
				minexptime = 1,
				maxexptime = 3,
				minsize = 0.5,
				maxsize = 1.4,
				collisiondetection = false,
				vertical = true,
				texture = "earth_particle.png",
			})
			for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
				if obj:is_player() then
					for i=-5,5 do
						for k = -5,5 do
							local pos1 = {x=pos.x+i,y=pos.y,z=pos.z+k}
							local name = minetest.env:get_node(pos1).name
							if name == "nssb:memoryone" then
								--obj:setpos({x=pos1.x, y=pos1.y+2, z =pos1.z})
								local meta = minetest.get_meta(pos1)
								local target = minetest.string_to_pos(meta:get_string("player"..obj:get_player_name()))
								--meta:set_string("player", minetest.pos_to_string(pos))

								minetest.chat_send_all("Posizione target: "..minetest.pos_to_string(target))
								obj:setpos({x = target.x, y=target.y+2, z=target.z})
							end
						end
					end
					--[[
					local pos1
					local pos2
					local name2
					for i=0,140 do
						pos1 = {x = pos.x, y = i, z = pos.z}
						pos2 = {x = pos.x, y = i+1, z = pos.z}
						local name = minetest.env:get_node(pos1).name
						if name == "ignore" then
							minetest.get_voxel_manip():read_from_map(pos1, pos1)
							minetest.get_voxel_manip():read_from_map(pos2, pos2)
							name = minetest.get_node(pos1).name
							name2 = minetest.get_node(pos2).name
						end
						--minetest.chat_send_all("Name: "..name)
						if (name == "air") and (name2 == "air") then
							obj:setpos(pos1)
							return
						end
					end
					]]
				end
			end
		end
})

--nodes gen

--This dimension is "divided" in in 7 layer.
--1st layer from 30000 to 30007 is indistructible, made of indistructible morentir



for i=1,9 do
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "nssb:indistructible_morentir",
		wherein        = {"default:water_source","default:water_flowing","default:gravel", "default:dirt", "default:sand", "default:lava_source", "default:lava_flowing", "default:mese_block", "default:stone","air","default:stone_with_coal","default:stone_with_iron","default:stone_with_mese","default:stone_with_diamond","default:stone_with_gold","default:stone_with_copper","nssb:ant_dirt","default:stone","default:cobble","default:stonebrick","default:mossycobble","default:desert_stone","default:desert_cobble","default:desert_stonebrick","default:sandstone","default:sandstonebrick"},
		clust_scarcity = 1,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min          = -30044,
		y_max          = -30037,
	})
end

--2� layer from 30008 to 30028, is "stalagmitic", have bats and morelentir

local function replace(old, new)
	for i=1,9 do
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = new,
			wherein        = old,
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = -30065,
			y_max          = -30045,
		})
	end
end

replace("default:stone", "nssb:morentir")
replace("default:stone_with_coal", "nssb:morelentir")
replace("default:stone_with_iron", "nssb:morelentir")
replace("default:stone_with_mese", "nssb:morelentir")
replace("default:stone_with_diamond", "nssb:morelentir")
replace("default:stone_with_gold", "nssb:morelentir")
replace("default:stone_with_copper", "nssb:morelentir")
replace("default:gravel", "nssb:morelentir")
replace("default:dirt", "nssb:morelentir")
replace("default:sand", "nssb:morelentir")
replace("default:water_source", "nssb:morelentir")
replace("default:water_flowing", "nssb:morelentir")
replace("default:lava_source", "nssb:morelentir")
replace("default:lava_flowing", "nssb:morelentir")
replace("default:mese_block", "nssb:morelentir")
replace({"nssb:ant_dirt","default:stone","default:cobble","default:stonebrick","default:mossycobble","default:desert_stone","default:desert_cobble","default:desert_stonebrick","default:sandstone","default:sandstonebrick"}, "nssb:morelentir")

minetest.register_ore({
		ore_type        = "blob",
		ore             = "nssb:morvilya",
		wherein         = "nssb:morentir",
		clust_scarcity  = 15 * 15 * 15,
		clust_size      = 6,
		y_min           = -30065,
		y_max           = -30045,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
	})
for i=1,3 do
minetest.register_ore({
			ore_type       = "scatter",
			ore            = "air",
			wherein        = "nssb:morentir",
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = -30066,
			y_max          = -30058,
		})
end


--3� layer from 30029 to 30077 is made by air

for i=1,16 do
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = "air",
			wherein        = {"nssb:ant_dirt","default:stone","default:cobble","default:stonebrick","default:mossycobble","default:desert_stone","default:desert_cobble","default:desert_stonebrick","default:sandstone","default:sandstonebrick","default:water_source","default:water_flowing","default:gravel", "default:dirt", "default:sand", "default:lava_source", "default:lava_flowing", "default:mese_block", "default:stone","air","default:stone_with_coal","default:stone_with_iron","default:stone_with_mese","default:stone_with_diamond","default:stone_with_gold","default:stone_with_copper"},
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = -30093,
			y_max          = -30066,
		})
	end

minetest.register_ore({
		ore_type        = "blob",
		ore             = "nssb:morelentir",
		wherein         = "air",
		clust_scarcity  = 10 * 10 * 10,
		clust_size      = 3,
		y_min           = -30068,
		y_max           = -30065,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
	})

minetest.register_ore({
		ore_type        = "blob",
		ore             = "nssb:fall_morentir", --morelentir
		wherein         = "air",
		clust_scarcity  = 16 * 16 * 16,
		clust_size      = 6,
		y_min           = -30071,
		y_max           = -30065,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
	})

minetest.register_ore({
		ore_type        = "blob",
		ore             = "nssb:morvilya",
		wherein         = "nssb:morentir",
		clust_scarcity  = 15 * 15 * 15,
		clust_size      = 6,
		y_min           = -30092,
		y_max           = -30066,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
	})

minetest.register_ore({
		ore_type        = "blob",
		ore             = "nssb:morentir",
		wherein         = "air",
		clust_scarcity  = 13 * 13 * 13,
		clust_size      = 6,
		y_min           = -30095,
		y_max           = -30089,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
	})

minetest.register_ore({
		ore_type        = "blob",
		ore             = "nssb:morentir",
		wherein         = "air",
		clust_scarcity  = 11 * 11 * 11,
		clust_size      = 5,
		y_min           = -30095,
		y_max           = -30090,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
	})

minetest.register_ore({
		ore_type        = "blob",
		ore             = "nssb:morentir",
		wherein         = "air",
		clust_scarcity  = 10 * 10 * 10,
		clust_size      = 4,
		y_min           = -30095,
		y_max           = -30091,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 5, z = 5},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
	})

minetest.register_ore({
		ore_type        = "blob",
		ore             = "nssb:morentir",
		wherein         = "air",
		clust_scarcity  = 10 * 10 * 10,
		clust_size      = 10,
		y_min           = -30095,
		y_max           = -30089,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 1,
			scale = 1,
			spread = {x = 1, y = 1000, z = 1},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
	})

--4�layer from  30078 to 30091 is a plain with mobs, fire, water...

local function replace(old, new)
	for i=1,9 do
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = new,
			wherein        = old,
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = -30107,
			y_max          = -30094,
		})
	end
end

replace("default:stone", "nssb:morentir")
replace("default:stone_with_coal", "nssb:mornen")
replace("default:stone_with_iron", "air")
replace("default:stone_with_mese", "air")
replace("default:stone_with_diamond", "air")
replace("default:stone_with_gold", "air")
replace("default:stone_with_copper", "air")
replace("default:gravel", "nssb:morkemen")
replace("default:dirt", "nssb:morkemen")
replace("default:sand", "nssb:morkemen")
replace("default:lava_source", "nssb:mornen")
replace("default:lava_flowing", "nssb:mornen_flowing")
replace("default:water_source", "nssb:mornen")
replace("default:water_flowing", "nssb:mornen_flowing")
replace("default:mese_block", "nssb:life_energy_ore")
replace({"nssb:ant_dirt","default:stone","default:cobble","default:stonebrick","default:mossycobble","default:desert_stone","default:desert_cobble","default:desert_stonebrick","default:sandstone","default:sandstonebrick"}, "nssb:morkemen")

minetest.register_ore({
			ore_type       = "scatter",
			ore            = "nssb:morlote",
			wherein        = "air",
			clust_scarcity = 6*6*6,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = -30094,
			y_max          = -30093,
		})

minetest.register_ore({
			ore_type       = "scatter",
			ore            = "nssb:mornar",
			wherein        = "air",
			clust_scarcity = 4*4*4,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = -30094,
			y_max          = -30093,
		})

minetest.register_ore({
			ore_type       = "scatter",
			ore            = "nssm:morwa_statue",
			wherein        = "air",
			clust_scarcity = 20*20*20,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = -30094,
			y_max          = -30093,
		})

--5� layer from 30092 to 30140 is underground with caves

local function replace(old, new)
	for i=1,9 do
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = new,
			wherein        = old,
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = -30156,
			y_max          = -30108,
		})
	end
end

replace("default:stone", "nssb:morentir")
replace("default:stone_with_coal", "nssb:life_energy_ore")
replace("default:stone_with_iron", "nssb:morentir")
replace("default:stone_with_mese", "nssb:morentir")
replace("default:stone_with_diamond", "nssb:life_energy_ore")
replace("default:stone_with_gold", "nssb:life_energy_ore")
replace("default:stone_with_copper", "nssb:morentir")
replace("default:gravel", "nssb:morkemen")
replace("default:dirt", "nssb:morkemen")
replace("default:sand", "nssb:morkemen")
replace("default:lava_source", "nssb:morentir")
replace("default:lava_flowing", "nssb:morentir")
replace("default:water_source", "nssb:mornen")
replace("default:water_flowing", "nssb:mornen_flowing")
replace("default:mese_block", "nssb:life_energy_ore")
replace({"nssb:ant_dirt","default:stone","default:cobble","default:stonebrick","default:mossycobble","default:desert_stone","default:desert_cobble","default:desert_stonebrick","default:sandstone","default:sandstonebrick"}, "nssb:morkemen")

--6� layer from 30141 to 30189 is underground with other caves and the special metal

local function replace(old, new)
	for i=1,9 do
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = new,
			wherein        = old,
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = -30205,
			y_max          = -30157,
		})
	end
end

replace("default:stone", "nssb:morentir")
replace("default:stone_with_coal", "nssb:life_energy_ore")
replace("default:stone_with_iron", "nssb:moranga")
replace("default:stone_with_mese", "nssb:moranga")
replace("default:stone_with_diamond", "nssb:life_energy_ore")
replace("default:stone_with_gold", "nssb:life_energy_ore")
replace("default:stone_with_copper", "nssb:moranga")
replace("default:gravel", "nssb:morkemen")
replace("default:dirt", "nssb:morkemen")
replace("default:sand", "nssb:morkemen")
replace("default:lava_source", "nssb:morentir")
replace("default:lava_flowing", "nssb:morentir")
replace("default:water_source", "nssb:mornen")
replace("default:water_flowing", "nssb:mornen_flowing")
replace("default:mese_block", "nssb:life_energy_ore")
replace({"nssb:ant_dirt","default:stone","default:cobble","default:stonebrick","default:mossycobble","default:desert_stone","default:desert_cobble","default:desert_stonebrick","default:sandstone","default:sandstonebrick"}, "nssb:morkemen")


--7� layer from 30190 to 30197 is indistructible

for i=1,9 do
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "nssb:indistructible_morentir",
		wherein        = {"nssb:ant_dirt","default:stone","default:cobble","default:stonebrick","default:mossycobble","default:desert_stone","default:desert_cobble","default:desert_stonebrick","default:sandstone","default:sandstonebrick","default:water_source","default:water_flowing","default:gravel", "default:dirt", "default:sand", "default:lava_source", "default:lava_flowing", "default:mese_block", "default:stone","air","default:stone_with_coal","default:stone_with_iron","default:stone_with_mese","default:stone_with_diamond","default:stone_with_gold","default:stone_with_copper"},
		clust_scarcity = 1,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min          = -30213,
		y_max          = -30206,
	})
end
