local mod_storage = minetest.get_mod_storage()
local sX = 0
local sY = -10000
local sZ = 0
local startPos = {x=sX, y=sY, z=sZ}
local playerInvContents = {
	"default:pick_wood",
}
local chestContents = {
	"default:dirt",
	"default:water_source 2",
	"default:acacia_bush_sapling",
	"default:acacia_sapling",
	"default:aspen_sapling",
	"default:blueberry_bush_sapling",
	"default:bush_sapling",
	"default:cactus",
	"default:emergent_jungle_sapling",
	"default:fern_1",
	"default:grass_1",
	"default:junglegrass",
	"default:junglesapling",
	"default:large_cactus_seedling",
	"default:marram_grass_1",
	"default:papyrus",
	"default:pine_bush_sapling",
	"default:pine_sapling",
	"default:sapling",
}
local chestContentsFarming = {
	"farming:seed_wheat",
	"farming:seed_cotton",
}
local chestContentsFlowers = {
	"flowers:chrysanthemum_green",
	"flowers:dandelion_white",
	"flowers:dandelion_yellow",
	"flowers:geranium",
	"flowers:mushroom_brown",
	"flowers:mushroom_red",
	"flowers:rose",
	"flowers:tulip",
	"flowers:tulip_black",
	"flowers:viola",
	"flowers:waterlily",
}

-- Start chest

function placeChest()
	if minetest.global_exists("farming") then
		for i,v in ipairs(chestContentsFarming) do
			table.insert(chestContents, v)
		end
	end
	if minetest.global_exists("flowers") then
		for i,v in ipairs(chestContentsFlowers) do
			table.insert(chestContents, v)
		end
	end

	local pos = {x=sX, y=sY, z=sZ+1}
	minetest.set_node(pos, {name="default:chest"})
	local inv = minetest.get_meta(pos):get_inventory()
	for i,v in ipairs(chestContents) do
		inv:set_stack("main", i, v)
	end
end

-- Player spawning

minetest.register_on_newplayer(function(player)
	if mod_storage:get_string("initialized") == "" then
		minetest.place_schematic({x=sX-1, y=sY-1, z=sZ-1}, minetest.get_modpath("underground_spawn").."/schematics/underground_spawn.mts", "0", {}, true)
		placeChest()
		mod_storage:set_string("initialized", "true")
	end

	if player then
		player:set_pos(startPos)
		local inv = player:get_inventory()
		for i,v in ipairs(playerInvContents) do
			inv:add_item("main", v)
		end
	end
end)

minetest.register_on_respawnplayer(function(player)
	if player then
		player:set_pos(startPos)
	end
	return true
end)

-- Make caves not dig through the stone directly surrounding the start pos

minetest.register_node("underground_spawn:fake_stone", {
	description = "Stone",
	tiles = {"default_stone.png"},
	groups = {cracky = 3, stone = 1},
	drop = 'default:cobble',
	is_ground_content = false,
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_abm{
	label = "Convert Fake Stone",
	nodenames = "underground_spawn:fake_stone",
	interval = 10,
	chance = 1,
	action = function(pos)
		minetest.set_node(pos, {name="default:stone"})
	end,
}

-- Leaves to dirt

minetest.register_craft({
	output = "default:dirt",
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'group:leaves', 'group:leaves'},
	},
})
