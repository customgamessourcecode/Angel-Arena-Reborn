--[[
--------------------------------------------
Author: CryDeS (but its doesnt matter, lol)
--------------------------------------------
creeps table struct:

	[SPAWNER_NAME]
	{
		[LEVEL*]
		{
			"creep_one"
			"creep_two"
		}
	}

--------------------------------------------
	* 1 = <level_1>, 2 = <level_5>, 3 = <level_10>, 4 = <level_15>, 5 = <level_20>, 6 = <level_25>, 7 = <level_40>, 8 = <level_60>, 9 = <level_80>, 10 = <level_100>)
]]

local creeps = {}

local level_table =
{
	"level_1",	
	"level_5",
	"level_10",
	"level_15",
	"level_20",
	"level_25",
	"level_40",
	"level_60",
	"level_80",
	"level_100",
}

local creeps_dire = 
{
	"Troll",
	"Troll",
	"Wildwing",
	"Wildwing",
	"Centaur",
	"Dragon",
	"Wildwing",
	"Troll",
}

local creeps_radiant = 
{
	"Ursa",
	"Ursa",
	"Golem",
	"Golem",
	"Croco",
	"Salamander",
	"Golem",
	"Ursa",
}
function AddCreep(t_table, spawner_name, creep_name)
	local unit_name
	local temp_table = {}

	for i,x in pairs(level_table) do
		unit_name = creep_name .. "_" .. x
		table.insert(temp_table, unit_name)
	end
	t_table[spawner_name] = temp_table
end

function AddAllCreeps(table_t)
	
	-- only one creep type for spawn!

	for i,x in pairs(creeps_dire) do
		AddCreep(table_t, "DIRE_SPAWNER_" .. i, x)
	end

	for i,x in pairs(creeps_radiant) do
		AddCreep(table_t, "RADIANT_SPAWNER_" .. i, x)
	end

end

------------------------------------------------------------BODY--------------------------------------------------
AddAllCreeps(creeps)
return creeps