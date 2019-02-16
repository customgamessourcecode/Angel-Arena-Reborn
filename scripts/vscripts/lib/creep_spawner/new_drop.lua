--[[
--------------------------------------------
Author: CryDeS
--------------------------------------------
item_table struct

{
	["item"] = { [1] = 10, [2] = 1, [3] = 3, [4] = 1} -- 1 - chance, 2 - min_count, 3 - max_count, 4 - priority
}

creep_drop_table_struct = 
{
	["my_little_creep"] = item_table
}
]]

local items = {
	["item_ward_observer"]			 = { [1] = 30, [2] = 1, [3] = 2, [4] = 1 },
	["item_slippers"]				 = { [1] = 30, [2] = 1, [3] = 1, [4] = 1 },
	["item_mantle"]					 = { [1] = 30, [2] = 1, [3] = 1, [4] = 1 },
	["item_gauntlets"]				 = { [1] = 30, [2] = 1, [3] = 1, [4] = 1 },
	["item_circlet"]				 = { [1] = 30, [2] = 1, [3] = 1, [4] = 1 },
	--["item_enchanted_mango"]		 = { [1] = 30, [2] = 1, [3] = 1, [4] = 1 },
	["item_ring_of_protection"]		 = { [1] = 30, [2] = 1, [3] = 1, [4] = 1 },
	
	["item_boots"]					 = { [1] = 30, [2] = 1, [3] = 1, [4] = 2 },
	["item_belt_of_strength"]		 = { [1] = 30, [2] = 1, [3] = 1, [4] = 2 },
	["item_boots_of_elves"]			 = { [1] = 30, [2] = 1, [3] = 1, [4] = 2 },
	["item_robe"]					 = { [1] = 30, [2] = 1, [3] = 1, [4] = 2 },
	["item_gloves"]					 = { [1] = 30, [2] = 1, [3] = 1, [4] = 2 },
	["item_bottle"]					 = { [1] = 30, [2] = 1, [3] = 1, [4] = 2 },
	["item_blight_stone"]			 = { [1] = 30, [2] = 1, [3] = 1, [4] = 2 },		
	["item_sobi_mask"]				 = { [1] = 30, [2] = 1, [3] = 1, [4] = 2 },	
	["item_ring_of_regen"] 			 = { [1] = 30, [2] = 1, [3] = 1, [4] = 2 },	
	
	["item_medallion_of_courage"]	 = { [1] = 30, [2] = 1, [3] = 1, [4] = 3 },
	["item_phase_boots"]			 = { [1] = 30, [2] = 1, [3] = 1, [4] = 3 },
	["item_power_treads"]			 = { [1] = 30, [2] = 1, [3] = 1, [4] = 3 },
	["item_arcane_boots"]			 = { [1] = 30, [2] = 1, [3] = 1, [4] = 3 },
	
	["item_solar_crest"]			 = { [1] = 30, [2] = 1, [3] = 1, [4] = 4 },
	["item_sange"]					 = { [1] = 30, [2] = 1, [3] = 1, [4] = 4 },
	["item_yasha"]					 = { [1] = 30, [2] = 1, [3] = 1, [4] = 4 },
}

return items