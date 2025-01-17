local moreores = minetest.get_modpath("moreores")
local nethermod = minetest.get_modpath("nether")
local is_50 = nssb.is_50

nssb.mymapgenis = tonumber(minetest.settings:get("mymapgenis")) or 7
if nssb.mymapgenis ~= 6 and nssb.mymapgenis ~= 7 then
	nssb.mymapgenis = 7
end

-- mapgen limits check from minetest
local mapgen_limit = tonumber(minetest.settings:get("mapgen_limit")) or 31000

-- get generation level from settings
local level = tonumber(minetest.settings:get("nssb.morlendor_level")) or -30000

-- schematics generation
local posplace = {x = 0, y = level - 93, z = 0}
local posmemory = {x = 0, y = level - 92, z = 0}
local postest = {x = 5, y = level - 91, z = 6}

-- ore type generation depending on minetest version
local oretype_morlan_layer
if is_50 then oretype_morlan_layer       = "stratum"  else  oretype_morlan_layer       = "scatter" end

-- mapgen limit must be at least enought before any check
if mapgen_limit < 400 then error("[nssb] the map limit is too low, there's no space for morlendor") end

-- morlendor must be inside the limits, but not almost the limit of the world, and must be almost 320 levels
level_amount_and_limit = math.abs(mapgen_limit) - math.abs(level)

while level_amount_and_limit <= 320 do

	level = (math.abs(level) - math.abs(level_amount_and_limit) - 1) * -1
	level_amount_and_limit = math.abs(mapgen_limit) - math.abs(level)

	minetest.log("error", "[nssb] incompatible morlendor level, autosetting: ".. level)
end

-- detection of nether deep floor, mordenlor must be below more than player things, cos has industructible layer
if nethermod then

	local nether_df = math.abs(tonumber(minetest.settings:get("nether_depth_ymax")) or -11000)

	if ( math.abs(nether_df) >= math.abs(level) + 1000 ) then
		error("[nssb] morlendor level conflicts with nether, unable to fix, check your settings")
	end
end

function nssb_register_buildings(
	build, -- name of the schematic
	rand, -- 1/rand is the probability of the spawning of the schematic if the place found is acceptable
	posschem, -- the block on which the schematic need to be to spawn
	down, -- useful in finding flat surfaces, down indetify the x and z coordinates of a block 1 under posschem
	downblock, -- the block that is necessary to find in down to place the schematic
	above, -- when you need to place the schem under something (water, air, jungleleaves...) above is the number of blocks above posschem
	aboveblock, -- the name of this block above above-times posschem
	radius, -- the radius in which the function search for the "near" block
	near, -- the block that is necessary to spawn the schem in the radius
	side, -- the mesure of the side of the schematic, it is necessary to put the dirt under it
	underground, -- if true the schematic need to spawn underground
	height, -- under this heigh the schematic can spawn. If nil the schematic can spawn everywhere underground
	ice, -- if true fill the space under the schem with ice and not with dirt as standard
	exact_height, -- exact_height=exact_eight under the surface in the correct place
	portal) -- is this schematic a portal for the morlendor?

	minetest.register_on_generated(function(minp, maxp, seed)

		if underground == false then

			local i, j, k
			local flag = 0
			local posd

			i = math.random(minp.x, maxp.x)
			k = math.random(minp.z, maxp.z)

			for j = minp.y, maxp.y do

				local pos1 = {x = i, y = j, z = k}
				local pos2 = {x = i + down, y = j - 1, z = k + down}
				local pos3 = {x = i, y = j + above, z = k}
				local n = minetest.get_node(pos1).name
				local u = minetest.get_node(pos2).name
				local d = minetest.get_node(pos3).name

				if downblock == nil then
					u = downblock
				end

				if aboveblock == nil then
					d = aboveblock
				end

				if n == posschem and u == downblock and d == aboveblock and flag == 0
				and math.random(1, rand) == 1 then

					if minetest.find_node_near(pos3, radius, near) then

							minetest.place_schematic(pos1, minetest.get_modpath("nssb")
									.. "/schems/" .. build .. ".mts", "0", {}, true)

-- minetest.chat_send_all("Added schematic in "..(minetest.pos_to_string(pos1)))

							posd = pos1
							flag = 1
					end
				end
			end

			-- Puts dirt/ice under the schematic to fill the space under it
			if flag == 1 and side > 0 then

				for dx = 0, side do

					for dz = 0, side do

						local dy = posd.y - 1
						local f = {x = posd.x + dx, y = dy, z = posd.z + dz}
						local fg = minetest.get_node(f).name

						if ice == false then

							while fg == "air" do

								--minetest.set_node(f, {name = "default:dirt"})
								minetest.swap_node(f, {name = "default:dirt"})

								f.y = f.y - 1

								fg = minetest.get_node(f).name
							end
						else
							while fg == "air" do

								--minetest.set_node(f, {name = "default:ice"})
								minetest.swap_node(f, {name = "default:ice"})

								f.y = f.y - 1

								fg = minetest.get_node(f).name
							end
						end
					end
				end
			end

			if portal == true then

--[[
				-- this is a portal for the morlendor
				if already_spawned == 0 then

					--already_spawned = 1

					local name = minetest.get_node(posplace).name

					minetest.chat_send_all("Non ancora creato. Nome: "..name)

					if name == "ignore" then

						local pmin, pmax = minetest.get_voxel_manip():read_from_map(
								vector.subtract(posplace, 80), vector.add(posplace, 80))

						name = minetest.get_node(posplace).name

						minetest.chat_send_all("name dopo read_from_map:.."..name)

						if name == "ignore" then

							minetest.emerge_area(vector.subtract(posplace, 80),
									vector.add(posplace, 80))

							name = minetest.get_node(posplace).name

							minetest.chat_send_all("name dopo emerge_area:.."..name)
						end

						minetest.after(25, function(posplace)

							name = minetest.get_node(posplace).name

							minetest.chat_send_all("name prima di place_schematic:.."..name)

							minetest.place_schematic(posplace,
									minetest.get_modpath("nssb")
									.. "/schems/memoportal.mts", "0", {}, true)

							-- minetest.place_schematic(posplace,
									minetest.get_modpath("nssb")
									.. "/schems/memoportal.mts", "0", {}, true)

							--minetest.chat_send_all("3")

							name = minetest.get_node(posplace).name

							minetest.chat_send_all("name dopo place_schematic:.."..name)

						end, posplace)
					end

					minetest.place_schematic(posplace, minetest.get_modpath("nssb")
							.. "/schems/memoportal.mts", "0", {}, true)
				end

]]--
			end

		else	--underground == true

			if minp.y < 0 then

-- minetest.chat_send_all("Posmin: " .. (minetest.pos_to_string(minp)).." Posmax: " .. (minetest.pos_to_string(maxp)))

				local i, jj, k, j
				local flag = 0

				i = math.random(minp.x, maxp.x)
				k = math.random(minp.z, maxp.z)
				jj = math.random(minp.y, maxp.y)

				if height ~= nil then

					if height > maxp.y then
						j = jj
					elseif height > minp.y and height < maxp.y then
						j = math.random(minp.y, height)
					else
						return
					end
				else
					if jj > 0 then
						j = math.random(minp.y, 0)
					end
				end

				local pos1 = {x = i, y = j, z = k}
				local n = minetest.get_node(pos1).name

				if minetest.find_node_near(pos1, radius, "default:lava_source")
				or flag == 1 then
					return
				else
					if n == posschem and math.random(1, rand) == 1 then

						minetest.place_schematic(pos1, minetest.get_modpath("nssb")
								.. "/schems/" .. build .. ".mts", "0", {}, true)

						flag = 1

-- minetest.chat_send_all("Added schematic in "..(minetest.pos_to_string(pos1)))

					end
				end
			end
		end
	end)
end


if nssb.mymapgenis == 6 then

	nssb_register_buildings ("spiaggiagranchius", 2, "default:sand", 3, "default:sand", 2, "air",  3, "air", 0, false, nil, false, false, false)

	nssb_register_buildings ("acquagranchius", 3, "default:sand", 3, "default:sand", 12,"default:water_source", 3, "default:water_source", 0, false, nil, false, false, false)

	nssb_register_buildings ("ooteca", 6, "default:dirt_with_grass", 3, "default:dirt", 2, "air", 24, "default:tree", 8, false, nil, false, false, false)

	nssb_register_buildings ("minuscolaooteca", 6, "default:dirt_with_grass",3 , "default:dirt", 2, "air", 24, "default:tree", 2, false, nil, false, false, false)

	nssb_register_buildings ("piccolaooteca", 6, "default:dirt_with_grass", 2, "default:dirt", 2, "air", 24, "default:tree", 4, false, nil, false, false, false)

	nssb_register_buildings ("arcate", 8, "default:sand", 3, "default:sand", 13, "default:water_source", 3, "default:water_source",0, false, nil, false, false, false)

	nssb_register_buildings ("grandepiramide", 8, "default:dirt", 3, "default:dirt", 20, "default:water_source", 3, "default:water_source", 0, false, nil, false, false, false)

	nssb_register_buildings ("collina", 5, "default:dirt_with_grass", 3, "default:dirt", 2, "air", 3, "air", 12, false, nil, false, false, false)

	nssb_register_buildings ("megaformicaio", 7, "default:dirt_with_grass", 4, "default:dirt", 2, "air", 3, "air", 25, false, nil, false, false, false)

	nssb_register_buildings ("antqueenhill", 8, "default:dirt_with_grass", 4, "default:dirt", 2, "air", 3, "air", 21, false, nil, false, false, false)

	nssb_register_buildings ("rovine1", 4, "default:dirt_with_grass", 3, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	-- nssb_register_buildings ("rovine2", 1, "default:stone", 0, "air",  0, "air", 24, "default:jungletree", 5, true, -8, false, false)

	nssb_register_buildings ("rovine3", 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine4", 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine5", 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine6", 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine7", 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine8", 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine9", 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine10", 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("bozzoli", 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("picco", 12, "default:desert_sand", 1, "default:desert_stone",  1, "air", 3, "default:desert_sand", 10, false, nil, false, false, false)

	nssb_register_buildings ("piccoghiaccio", 12, "default:dirt_with_snow", 1, "default:dirt",  1, "air", 3, "default:dirt_with_snow", 10, false, nil, true, false, false)

	nssb_register_buildings ("icehall", 8, "default:dirt_with_snow", 1, "default:dirt",  1, "air", 3, "default:dirt_with_snow", 30, false, nil, true, false, false)

	nssb_register_buildings ("piccomoonheron", 8, "default:dirt_with_snow", 1, "default:dirt",  1, "air", 3, "default:dirt_with_snow", 3, false, nil, true, false, false)

	nssb_register_buildings ("doppiopiccoghiaccio", 11, "default:dirt_with_snow", 1, "default:dirt",  1, "air", 3, "default:dirt_with_snow", 7, false, nil, true, false, false)

	nssb_register_buildings ("doppiopiccosabbia", 11, "default:desert_sand", 1, "default:desert_stone",  1, "air", 3, "default:desert_sand", 7, false, nil, false, false, false)

	nssb_register_buildings ("piccoscrausics", 8, "default:desert_sand", 1, "default:desert_stone",  1, "air", 3, "default:desert_sand", 3, false, nil, false, false, false)

	nssb_register_buildings ("fossasand", 20, "default:desert_sand", 1, "default:desert_stone",  1, "air", 3, "default:desert_sand", 16, false, nil, false, false, false)

	nssb_register_buildings ("portal", 100, "default:dirt_with_grass", 2, "default:dirt", 2, "air", 24, "air", 11, false, nil, false, false, true)

else -- mymapgenis 7

	nssb_register_buildings ("spiaggiagranchius", 5, "default:sand", 3, "default:sand", 2, "air",  3, "air", 0, false, nil, false, false, false)

	nssb_register_buildings ("acquagranchius", 6, "default:sand", 3, "default:sand", 12,"default:water_source", 3, "default:water_source", 0, false, nil, false, false, false)

	nssb_register_buildings ("ooteca", 12, "default:dirt_with_grass", 3, "default:dirt", 2, "air", 24, "default:tree", 8, false, nil, false, false, false)

	nssb_register_buildings ("minuscolaooteca", 11, "default:dirt_with_grass",3 , "default:dirt", 2, "air", 24, "default:tree", 2, false, nil, false, false, false)

	nssb_register_buildings ("piccolaooteca", 11, "default:dirt_with_grass", 2, "default:dirt", 2, "air", 24, "default:tree", 4, false, nil, false, false, false)

	nssb_register_buildings ("arcate", 24, "default:sand", 3, "default:sand", 13, "default:water_source", 3, "default:water_source",0, false, nil, false, false, false)

	nssb_register_buildings ("grandepiramide", 24, "default:dirt", 3, "default:dirt", 20, "default:water_source", 3, "default:water_source", 0, false, nil, false, false, false)

	nssb_register_buildings ("collina", 14, "default:dirt_with_grass", 3, "default:dirt", 2, "air", 3, "air", 12, false, nil, false, false, false)

	nssb_register_buildings ("megaformicaio", 20, "default:dirt_with_grass", 4, "default:dirt", 2, "air", 3, "air", 25, false, nil, false, false, false)

	nssb_register_buildings ("antqueenhill", 22, "default:dirt_with_grass", 4, "default:dirt", 2, "air", 3, "air", 21, false, nil, false, false, false)

	nssb_register_buildings ("rovine1", 6, "default:dirt_with_grass", 3, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	-- nssb_register_buildings ("rovine2", 1, "default:stone", 0, "air",  0, "air", 24, "default:jungletree", 5, true, -8, false, false)

	nssb_register_buildings ("rovine3", 6, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine4", 6, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine5", 6, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine6", 6, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine7", 6, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine8", 6, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine9", 6, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("rovine10", 6, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("bozzoli", 4, "default:dirt_with_grass", 1, "default:dirt",  2, "air", 8, "default:jungletree", 10, false, nil, false, false, false)

	nssb_register_buildings ("picco", 32, "default:desert_sand", 1, "default:desert_stone",  1, "air", 3, "default:desert_sand", 10, false, nil, false, false, false)

	nssb_register_buildings ("piccoghiaccio", 32, "default:dirt_with_snow", 1, "default:dirt",  1, "air", 3, "default:dirt_with_snow", 10, false, nil, true, false, false)

	nssb_register_buildings ("icehall", 40, "default:dirt_with_snow", 1, "default:dirt",  1, "air", 3, "default:dirt_with_snow", 30, false, nil, true, false, false)

	nssb_register_buildings ("piccomoonheron", 32, "default:dirt_with_snow", 1, "default:dirt",  1, "air", 3, "default:dirt_with_snow", 3, false, nil, true, false, false)

	nssb_register_buildings ("doppiopiccoghiaccio", 32, "default:dirt_with_snow", 1, "default:dirt",  1, "air", 3, "default:dirt_with_snow", 7, false, nil, true, false, false)

	nssb_register_buildings ("doppiopiccosabbia", 32, "default:desert_sand", 1, "default:desert_stone",  1, "air", 3, "default:desert_sand", 7, false, nil, false, false, false)

	nssb_register_buildings ("piccoscrausics", 32, "default:desert_sand", 1, "default:desert_stone",  1, "air", 3, "default:desert_sand", 3, false, nil, false, false, false)

	nssb_register_buildings ("fossasand", 50, "default:desert_sand", 1, "default:desert_stone",  1, "air", 3, "default:desert_sand", 16, false, nil, false, false, false)

	nssb_register_buildings ("portal", 200, "default:dirt_with_grass", 2, "default:dirt", 2, "air", 24, "air", 11, false, nil, false, false, true)
end

nssb_register_buildings ("blocohouse", 4, "default:stone", 0, "air",  0, "air", 3, "default:stone", 5, true, -10, false, false, false)

nssb_register_buildings ("bigblocohouse", 4, "default:stone", 0, "air",  0, "air", 3, "default:stone", 5, true, -20, false, false, false)

nssb_register_buildings ("blocobiggesthouse", 4, "default:stone", 0, "air",  0, "air", 3, "default:stone", 5, true, -30, false, false, false)

-- nodes gen

-- This dimension is "divided" in in 7 layer.
-- 1st layer is indistructible, made of indistructible morentir

local ite = is_50 and 1 or 9

for i = 1, ite do

	minetest.register_ore({
		ore_type       = oretype_morlan_layer,
		ore            = "nssb:indistructible_morentir",
		wherein        = {
			"default:water_source","default:water_flowing","default:gravel",
			"default:dirt", "default:sand", "default:lava_source", "default:lava_flowing",
			"default:mese_block", "default:stone", "air", "default:stone_with_coal",
			"default:stone_with_iron", "default:stone_with_mese",
			"default:stone_with_diamond", "default:stone_with_gold",
			"default:stone_with_copper", "nssb:ant_dirt",  "default:stone",
			"default:cobble", "default:stonebrick", "default:mossycobble",
			"default:desert_stone", "default:desert_cobble", "default:desert_stonebrick",
			"default:sandstone", "default:sandstonebrick", "default:stone_with_tin",
			-- moreores (can be added to list, only removes if mod active)
			"moreores:mineral_tin", "moreores:mineral_silver", "moreores:mineral_mithril",
			"default:silver_sand"
		},
		clust_scarcity = 1,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min          = level - 44,
		y_max          = level - 37
	})
end

--[[
if moreores then
	local ite = is_50 and 1 or 9
	for i = 1, ite do
		minetest.register_ore({
			ore_type       = oretype_morlan_layer,
			ore            = "nssb:indistructible_morentir",
			wherein        = {
				"moreores:mineral_tin", "moreores:mineral_silver",
				"moreores:mineral_mithril"
			},
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = level - 44,
			y_max          = level - 37
		})
	end
end
]]

-- 2nd layer is "stalagmitic", have bats and morelentir

local function replace2(old, new)

	local ite = is_50 and 1 or 9

	for i = 1, ite do

		minetest.register_ore({
			ore_type       = oretype_morlan_layer,
			ore            = new,
			wherein        = old,
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = level - 65,
			y_max          = level - 45
		})
	end
end

-- optimized list
replace2({"default:stone", "default:stone_with_coal", "default:stone_with_iron",
		"default:stone_with_mese", "default:stone_with_diamond", "default:silver_sand",
		"default:stone_with_gold", "default:stone_with_copper", "default:gravel",
		"default:dirt", "default:sand", "default:water_source", "default:water_flowing",
		"default:lava_source", "default:lava_flowing", "default:mese_block",
		"nssb:ant_dirt", "default:stone", "default:cobble", "default:stonebrick",
		"default:mossycobble", "default:desert_stone", "default:desert_cobble",
		"default:desert_stonebrick", "default:sandstone", "default:sandstonebrick"},
		"nssb:morelentir")
replace2({"default:stone_with_tin", "moreores:mineral_tin", "moreores:mineral_silver",
		"moreores:mineral_mithril"}, "air")


minetest.register_ore({
	ore_type        = "blob",
	ore             = "nssb:morvilya",
	wherein         = "nssb:morentir",
	clust_scarcity  = 15 * 15 * 15,
	clust_size      = 6,
	y_min           = level - 65,
	y_max           = level - 45,
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

for i = 1, 3 do
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "air",
		wherein        = "nssb:morentir",
		clust_scarcity = 1,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min          = level - 66,
		y_max          = level - 58
	})
--	if is_50 then break end
end

-- 3rd layer is made by air

local ite = is_50 and 1 or 32

for i = 1, ite do

	minetest.register_ore({
		ore_type       = oretype_morlan_layer,
		ore            = "air",
		wherein        = {
			"nssb:ant_dirt", "default:stone", "default:cobble", "default:stonebrick",
			"default:mossycobble", "default:desert_stone", "default:desert_cobble",
			"default:desert_stonebrick", "default:sandstone", "default:sandstonebrick",
			"default:water_source", "default:water_flowing", "default:gravel",
			"default:dirt", "default:sand", "default:lava_source", "default:lava_flowing",
			"default:mese_block",  "default:stone", "air", "default:stone_with_coal",
			"default:stone_with_iron", "default:stone_with_mese", "default:silver_sand",
			"default:stone_with_diamond", "default:stone_with_gold",
			"default:stone_with_copper", "default:stone_with_tin",
			-- moreores (can be added to list, only removes if mod active)
			"moreores:mineral_tin", "moreores:mineral_silver", "moreores:mineral_mithril"
		},
		clust_scarcity = 1,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min          = level - 93,
		y_max          = level - 66
	})
end

--[[
if moreores then

	for i = 1, 9 do
		minetest.register_ore({
			ore_type       = oretype_morlan_layer,
			ore            = "air",
			wherein        = {
				"moreores:mineral_tin", "moreores:mineral_silver",
				"moreores:mineral_mithril"
			},
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = level - 93,
			y_max          = level - 66
		})
		if is_50 then break end
	end
end
]]


minetest.register_ore({
	ore_type        = "blob",
	ore             = "nssb:morelentir",
	wherein         = "air",
	clust_scarcity  = 10 * 10 * 10,
	clust_size      = 3,
	y_min           = level - 68,
	y_max           = level - 65,
	noise_threshold = 0.0,
	noise_params    = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 17676,
		octaves = 1,
		persist = 0.0
	}
})

minetest.register_ore({
	ore_type        = "blob",
	ore             = "nssb:morelentir",
	wherein         = "air",
	clust_scarcity  = 16 * 16 * 16,
	clust_size      = 6,
	y_min           = level - 71,
	y_max           = level - 65,
	noise_threshold = 0.0,
	noise_params    = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 17676,
		octaves = 1,
		persist = 0.0
	}
})

minetest.register_ore({
	ore_type        = "blob",
	ore             = "nssb:morvilya",
	wherein         = "nssb:morentir",
	clust_scarcity  = 15 * 15 * 15,
	clust_size      = 6,
	y_min           = level - 92,
	y_max           = level - 66,
	noise_threshold = 0.0,
	noise_params    = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 17676,
		octaves = 1,
		persist = 0.0
	}
})

minetest.register_ore({
	ore_type        = "blob",
	ore             = "nssb:morentir",
	wherein         = "air",
	clust_scarcity  = 13 * 13 * 13,
	clust_size      = 6,
	y_min           = level - 95,
	y_max           = level - 89,
	noise_threshold = 0.0,
	noise_params    = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 17676,
		octaves = 1,
		persist = 0.0
	}
})

minetest.register_ore({
	ore_type        = "blob",
	ore             = "nssb:morentir",
	wherein         = "air",
	clust_scarcity  = 11 * 11 * 11,
	clust_size      = 5,
	y_min           = level - 95,
	y_max           = level - 90,
	noise_threshold = 0.0,
	noise_params    = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 17676,
		octaves = 1,
		persist = 0.0
	}
})

minetest.register_ore({
	ore_type        = "blob",
	ore             = "nssb:morentir",
	wherein         = "air",
	clust_scarcity  = 10 * 10 * 10,
	clust_size      = 4,
	y_min           = level - 95,
	y_max           = level - 91,
	noise_threshold = 0.0,
	noise_params    = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 17676,
		octaves = 1,
		persist = 0.0
	}
})

minetest.register_ore({
	ore_type        = "blob",
	ore             = "nssb:morentir",
	wherein         = "air",
	clust_scarcity  = 10 * 10 * 10,
	clust_size      = 10,
	y_min           = level - 95,
	y_max           = level - 89,
	noise_threshold = 0.0,
	noise_params    = {
		offset = 1,
		scale = 1,
		spread = {x = 1, y = 1000, z = 1},
		seed = 17676,
		octaves = 1,
		persist = 0.0
	}
})

-- 4th layer is a plain with mobs, fire, water...

local function replace4(old, new)

	local ite = is_50 and 1 or 9

	for i = 1, ite do

		minetest.register_ore({
			ore_type       = oretype_morlan_layer,
			ore            = new,
			wherein        = old,
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = level - 107,
			y_max          = level - 94
		})
	end
end

-- optimized list
replace4({"default:stone_with_iron", "default:stone_with_mese", "default:stone_with_gold",
		"default:stone_with_diamond", "default:stone_with_copper"}, "air")
replace4({"default:stone_with_coal", "default:lava_source", "default:water_source"},
		"nssb:mornen")
replace4({"default:lava_flowing", "default:water_flowing"}, "nssb:moenen_flowing")
replace4({"default:gravel", "default:dirt", "default:sand", "nssb:ant_dirt",
		"default:stone", "default:cobble", "default:stonebrick", "default:mossycobble",
		"default:desert_stone", "default:desert_cobble", "default:desert_stonebrick",
		"default:sandstone", "default:sandstonebrick", "default:silver_sand"},
		"nssb:morkemen")
replace4({"default:stone", "default:stone_with_tin", "moreores:mineral_tin",
		"moreores:mineral_silver", "moreores:mineral_mithril"}, "nssb:morentir")
replace4("default:mese_block", "nssb:life_energy_ore")


minetest.register_ore({
	ore_type       = "scatter",
	ore            = "nssb:morlote",
	wherein        = "air",
	clust_scarcity = 7 * 7 * 7,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = level - 94,
	y_max          = level - 93
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "nssb:mornar",
	wherein        = "air",
	clust_scarcity = 4 * 4 * 4,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = level - 94,
	y_max          = level - 93
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "nssm:morwa_statue",
	wherein        = "air",
	clust_scarcity = 18 * 18 * 18,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = level - 94,
	y_max          = level - 93
})

-- 5th layer is underground with caves

local function replace5(old, new)

	local ite = is_50 and 1 or 9

	for i = 1, ite do

		minetest.register_ore({
			ore_type       = oretype_morlan_layer,
			ore            = new,
			wherein        = old,
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = level - 156,
			y_max          = level - 108
		})
	end
end

minetest.register_ore({
	ore_type        = "blob",
	ore             = "nssb:fall_morentir",
	wherein         = "air",
	clust_scarcity  = 16 * 16 * 16,
	clust_size      = 6,
	y_min           = level - 204,
	y_max           = level - 109,
	noise_threshold = 0.0,
	noise_params    = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 17676,
		octaves = 1,
		persist = 0.0
	}
})

-- optimized list
replace5({"default:stone", "default:stone_with_iron", "default:stone_with_mese",
		"default:stone_with_copper"}, "nssb:morentir")
replace5({"default:stone_with_coal", "default:stone_with_diamond",
		"default:stone_with_gold", "default:mese_block", "default:stone_with_tin",
		"moreores:mineral_tin"}, "nssb:life_energy_ore")
replace5({"default:lava_source", "default:lava_flowing", "moreores:mineral_silver"},
		"nssb:morentir")
replace5("default:water_source", "nssb:mornen")
replace5("default:water_flowing", "nssb:mornen_flowing")
replace5("moreores:mineral_mithril", "nssb:moranga")
replace5({"default:gravel", "default:dirt", "default:sand", "nssb:ant_dirt",
		"default:stone", "default:cobble", "default:stonebrick", "default:mossycobble",
		"default:desert_stone", "default:desert_cobble", "default:desert_stonebrick",
		"default:sandstone", "default:sandstonebrick", "default:silver_sand"},
		"nssb:morkemen")

-- 6th layer is underground with other caves and the special metal

local function replace6(old, new)

	local ite = is_50 and 1 or 9

	for i = 1, ite do

		minetest.register_ore({
			ore_type       = oretype_morlan_layer,
			ore            = new,
			wherein        = old,
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = level - 205,
			y_max          = level - 157
		})
	end
end

-- optimized list
replace6({"default:stone", "default:lava_source", "default:lava_flowing"},
		"nssb:morentir")
replace6({"default:stone_with_coal", "default:stone_with_diamond",
		"default:stone_with_gold", "default:mese_block", "default:stone_with_tin",
		"moreores:mineral_tin"}, "nssb:life_energy_ore")
replace6({"default:stone_with_iron", "default:stone_with_mese",
		"default:stone_with_copper", "moreores:mineral_silver",
		"moreores:mineral_mithril"}, "nssb:moranga")
replace6({"default:gravel", "default:dirt", "default:sand", "nssb:ant_dirt",
		"default:stone", "default:cobble", "default:stonebrick", "default:mossycobble",
		"default:desert_stone", "default:desert_cobble", "default:desert_stonebrick",
		"default:sandstone", "default:sandstonebrick", "default:silver_sand"},
		"nssb:morkemen")
replace6("default:water_source", "nssb:mornen")
replace6("default:water_flowing", "nssb:mornen_flowing")

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "nssb:boum_morentir",
	wherein        = "nssb:morentir",
	clust_scarcity = 13 * 13 * 13,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = level - 205,
	y_max          = level - 157
})

-- 7th layer is indistructible

local ite = is_50 and 1 or 9

for i = 1, ite do

	minetest.register_ore({
		ore_type       = oretype_morlan_layer,
		ore            = "nssb:indistructible_morentir",
		wherein        = {
			"nssb:ant_dirt", "default:stone", "default:cobble", "default:stonebrick",
			"default:mossycobble", "default:desert_stone", "default:desert_cobble",
			"default:desert_stonebrick", "default:sandstone", "default:sandstonebrick",
			"default:water_source", "default:water_flowing", "default:gravel",
			"default:dirt", "default:sand", "default:lava_source", "default:lava_flowing",
			"default:mese_block", "default:stone", "air", "default:stone_with_coal",
			"default:stone_with_iron", "default:stone_with_mese", "default:silver_sand",
			"default:stone_with_diamond", "default:stone_with_gold",
			"default:stone_with_copper", "default:stone_with_tin",
			"moreores:mineral_tin", "moreores:mineral_silver", "moreores:mineral_mithril"
		},
		clust_scarcity = 1,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min          = level - 213,
		y_max          = level - 206
	})
end

--[[
if moreores then
	local ite = is_50 and 1 or 9
	for i = 1, ite do
		minetest.register_ore({
			ore_type       = oretype_morlan_layer,
			ore            = "nssb:indistructible_morentir",
			wherein        = {
				"moreores:mineral_tin", "moreores:mineral_silver",
				"moreores:mineral_mithril"
			},
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = level - 213,
			y_max          = level - 206
		})
	end
end
]]

local ite = is_50 and 1 or 12

for i = 1, ite do

	minetest.register_ore({
		ore_type       = oretype_morlan_layer,
		ore            = "air",
		wherein        = {
			"default:water_source", "default:water_flowing", "default:lava_source",
			"default:lava_flowing"
		},
		clust_scarcity = 1,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min          = level - 207,
		y_max          = level - 45
	})
end

-- Place the buildings in the morlendor

posmorvalarblock = {x = 827, y = level - 94, z = -817}
posplace = {x = 0, y = level - 93, z = 0}
posmemory = {x = 0, y = level - 92, z = 0}

if posplace then

	--[[if name11 == "ignore" then
		local pmin, pmax = minetest.get_voxel_manip():read_from_map(posplace, posplace)
	end
	]]

	-- minetest.get_voxel_manip():read_from_map(posplace, posplace)

	if not minetest.get_node_or_nil(posplace) then
		minetest.emerge_area(vector.subtract(posplace, 80), vector.add(posplace, 80))
	end

	minetest.after(5, function(posplace)

		minetest.place_schematic(posplace, minetest.get_modpath("nssb")
				.. "/schems/memoportal.mts", 0, {}, true)
	end, posplace)
end

posarena = {x = 777, y = level - 96, z = -777}

if posarena then

	-- minetest.get_voxel_manip():read_from_map(posplace, posplace)
	if not minetest.get_node_or_nil(posarena) then
		minetest.emerge_area(vector.subtract(posarena, 120), vector.add(posarena, 120))
	end

	-- teleport the player
	minetest.after(5, function(posarena)

		local mp = minetest.get_modpath("nssb")

		minetest.place_schematic(posarena, mp .. "/schems/arena51.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-9},
				mp .. "/schems/arena52.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-18},
				mp .. "/schems/arena53.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-27},
				mp .. "/schems/arena54.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-36},
				mp .. "/schems/arena55.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-45},
				mp .. "/schems/arena56.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-54},
				mp .. "/schems/arena57.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-63},
				mp .. "/schems/arena58.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-72},
				mp .. "/schems/arena59.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-81},
				mp .. "/schems/arena510.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-90},
				mp .. "/schems/arena511.mts", "0", {}, true)

		local objects = minetest.get_objects_inside_radius(posmorvalarblock, 90)
		local found = 0

		for _,obj in ipairs(objects) do

			if (obj:get_luaentity() and (obj:get_luaentity().name=="nssm:morvalar0"
			or obj:get_luaentity().name=="nssm:morvalar1"
			or obj:get_luaentity().name=="nssm:morvalar2"
			or obj:get_luaentity().name=="nssm:morvalar3"
			or obj:get_luaentity().name=="nssm:morvalar4"
			or obj:get_luaentity().name=="nssm:morvalar5"
			or obj:get_luaentity().name=="nssm:morvalar6"
			or obj:get_luaentity().name=="nssm:morvalar")) then
				found = 1
			end
		end

		if found == 0 then
			minetest.set_node(posmorvalarblock, {name="nssb:morvalar_block"})
		end
	end, posarena)
end

minetest.register_abm({
	nodenames = {"nssb:indistructible_morentir"},
	neighbors = {"nssb:mornar"},
	interval = 1,
	chance = 1,
	action = function(pos, node)

-- minetest.chat_send_all("Ciao ciao pirloni")

		local mp = minetest.get_modpath("nssb")

		minetest.place_schematic(posarena, mp .. "/schems/arena51.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-9},
				mp .. "/schems/arena52.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-18},
				mp .. "/schems/arena53.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-27},
				mp .. "/schems/arena54.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-36},
				mp .. "/schems/arena55.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-45},
				mp .. "/schems/arena56.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-54},
				mp .. "/schems/arena57.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-63},
				mp .. "/schems/arena58.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-72},
				mp .. "/schems/arena59.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-81},
				mp .. "/schems/arena510.mts", "0", {}, true)

		minetest.place_schematic({x = posarena.x, y = level - 96, z = posarena.z-90},
				mp .. "/schems/arena511.mts", "0", {}, true)
	end
})

--[[
minetest.register_abm({
	nodenames = {"default:lava_source"},
	neighbors = {
		"nssb:morentir","nssb:morkemen", "nssb:morelentir", "nssb:mornen",
		"nssb:mornar","nssb:indistructible_morentir"
	},
	interval = 1,
	chance = 1,
	action = function(pos, node)
			minetest.set_node({x = pos.x, y = pos.y , z = pos.z}, {name = "air"})
	end
})
]]

minetest.register_abm({
	nodenames = {
		"default:lava_source", "default:lava_flowing", "default:water_source",
		"default:water_flowing"
	},
	neighbors = {"air"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		if pos.y < level then
			minetest.remove_node(pos)
		end
	end
})

-- If the generated chunks of map are in Morlendor remove the lava_source nodes
--[[
minetest.register_on_generated(function(minp, maxp, seed)

    if maxp.y > level then

        if minp.y < level then
            maxp.y = level
        else
            return
        end
    end

	minetest.chat_send_all("Ciao sono qui")

    local poslist = minetest.find_nodes_in_area(minp,maxp,"default:lava_source")

    for _,v in pairs(poslist) do
		minetest.chat_send_all("Posizione: "..pos_to_string)
        minetest.remove_node(v)
    end
end)

minetest.register_abm({
	nodenames = {"default:water_source"},
	neighbors = {
		"nssb:morentir","nssb:morkemen", "nssb:morelentir", "nssb:mornen",
		"nssb:mornar","nssb:indistructible_morentir"
	},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		minetest.set_node({x = pos.x, y = pos.y , z = pos.z}, {name = "air"})
	end
})
]]

-- Abms

minetest.register_abm({
	nodenames = {"default:torch"},
	neighbors = {"nssb:morentir","nssb:morkemen"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		minetest.set_node({x = pos.x, y = pos.y , z = pos.z}, {name = "nssb:mornar"})
	end
})

minetest.register_abm({
	nodenames = {"nssb:morlote"},
	neighbors = {"air"},
	interval = 60,
	chance = 100,
	action = function(pos, node)

		local pos1 = {x = pos.x, y = pos.y + 1, z = pos.z}
		local n = minetest.get_node(pos1).name

		if n ~= "air" then
			return
		end

		minetest.add_entity(pos1, "nssm:morgre")

		minetest.remove_node(pos)
	end
})

minetest.register_abm({
	nodenames = {"nssb:fall_morentir"},
	neighbors = {"nssb:fall_morentir"},
	interval = 1,
	chance = 1,
	action = function(pos, node)

		for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 7)) do

			if obj:is_player() then
				minetest.check_for_falling(pos)
			end
		end
	end
})

minetest.register_abm({
	nodenames = {"nssb:boum_morentir"},
	neighbors = {"nssb:morentir"},
	interval = 1,
	chance = 1,
	action = function(pos, node)

		for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 5)) do

			if obj:is_player() then
				tnt.boom(pos, {radius = 3, damage_radius = 0})
			end
		end
	end
})

minetest.register_abm({
	nodenames = {"nssb:mornen", "nssb:mornen_flowing"},
	neighbors = {"air"},
	interval = 1.0,
	chance = 5,
	action = function (pos, node)

		minetest.add_particlespawner({
			amount = 1,
			time = 2,
			minpos = {x = pos.x - 0.5, y = pos.y + 0.5, z = pos.z - 0.5},
			maxpos = {x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5},
			minvel = {x = 0, y = 0.1, z = 0},
			maxvel = {x = 0, y = 0.3, z = 0},
			minacc = {x = 0, y = 0, z = 0},
			maxacc = {x = 0, y = 0, z = 0},
			minexptime = 1,
			maxexptime = 1.2,
			minsize = 0.5,
			maxsize = 0.7,
			collisiondetection = false,
			vertical = true,
			texture = "morparticle.png"
		})
	end
})

minetest.register_abm({
	nodenames = {"nssb:portal"},
	neighbors = {"air"},
	interval = 1,
	chance = 1,
	action = function (pos, node)

		minetest.add_particlespawner({
			amount = 3,
			time = 1,
			minpos = {x = pos.x - 0.5, y = pos.y + 0.5, z = pos.z - 0.5},
			maxpos = {x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5},
			minvel = {x = 0, y = 0.1, z = 0},
			maxvel = {x = 0, y = 0.8, z = 0},
			minacc = {x = 0, y = 0, z = 0},
			maxacc = {x = 0, y = 0.4, z = 0},
			minexptime = 1,
			maxexptime = 3,
			minsize = 0.5,
			maxsize = 1.4,
			collisiondetection = false,
			vertical = true,
			texture = "morparticle.png"
		})
	end
})

minetest.register_abm({
	nodenames = {"nssb:portal"},
	neighbors = {"air"},
	interval = 7,
	chance = 1,
	action = function (pos, node)

		for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do

			if obj:is_player() then

				local pos1 = posmemory
				local meta = minetest.get_meta(pos1)

				-- the timer is saved inside a position because for me the tonumber
				-- function doesn"t work
				local timer_pos = minetest.string_to_pos(meta:get_string("player_timer"
						.. obj:get_player_name()))

				if not timer_pos or ((timer_pos) and ((os.time() - timer_pos.x) >= 30)) then

					local posp = obj:get_pos()

-- minetest.chat_send_all("Posizione: "..minetest.pos_to_string(posp))

					obj:set_pos({x = 5, y = pos1.y + 2, z = 5})

					meta:set_string("player"..obj:get_player_name(), minetest.pos_to_string(posp))

					timer_pos = {x = os.time(), y = 0, z = 0}

					meta:set_string("player_timer" .. obj:get_player_name(),
							minetest.pos_to_string(timer_pos))
				end
			end
		end
	end
})

minetest.register_abm({
	nodenames = {"nssb:portalhome"},
	neighbors = {"air"},
	interval = 1,
	chance = 1,
	action = function (pos, node)
		minetest.add_particlespawner({
			amount = 3,
			time = 1,
			minpos = {x = pos.x - 0.5, y = pos.y + 0.5, z = pos.z - 0.5},
			maxpos = {x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5},
			minvel = {x = 0, y = 0.1, z = 0},
			maxvel = {x = 0, y = 0.8, z = 0},
			minacc = {x = 0, y = 0, z = 0},
			maxacc = {x = 0, y = 0.4, z = 0},
			minexptime = 1,
			maxexptime = 3,
			minsize = 0.5,
			maxsize = 1.4,
			collisiondetection = false,
			vertical = true,
			texture = "earth_particle.png"
		})
	end
})

minetest.register_abm({
	nodenames = {"nssb:portalhome"},
	neighbors = {"air"},
	interval = 7,
	chance = 2,
	action = function (pos, node)

		for _,obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do

			if obj:is_player() then

				local pos1 = posmemory
				local meta = minetest.get_meta(pos1)
				-- the timer is saved inside a position because for me the tonumber
				-- function doesn"t work
				local timer_pos = minetest.string_to_pos(meta:get_string("player_timer"
						.. obj:get_player_name()))

				if not timer_pos or ((timer_pos) and ((os.time() - timer_pos.x) >= 30)) then

					local name = minetest.get_node(pos1).name

					local target = minetest.string_to_pos(meta:get_string("player"
							.. obj:get_player_name()))

					if target then

						obj:set_pos({x = target.x, y = target.y + 1, z = target.z})

						timer_pos = {x = os.time(), y = 0, z = 0}

						meta:set_string("player_timer"
								.. obj:get_player_name(),
								minetest.pos_to_string(timer_pos))
					end
				end
			end
		end
	end
})
