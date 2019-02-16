--[[
------------------------------------------------------------
table structure:

[boss_name]
{
	spawner = "BOSS_SPAWN_1"
	respawn = 5 -- in minutes
	until_respawn = 5 -- in minutres
}
------------------------------------------------------------
]]
local boss_table = {}

function InitBossTable(bosses_table)
	local names = 
	{
		["Demon_possessed"]				= "POSSESSED_SPAWN",
		["npc_dota_custom_guardian"]	= "BOSS_CHANGE_HERO_SPAWN",
		["npc_monk_of_love"] 			= "MONK_OF_LOVE",
		["npc_monk_of_hate"] 			= "MONK_OF_HATE",
		["npc_monk_of_life"] 			= "MONK_OF_LIFE",
		["npc_monk_of_death"]			= "MONK_OF_DEATH",
		["npc_angel_of_love"] 			= "ANGEL_OF_LOVE",
		["npc_angel_of_hate"] 			= "ANGEL_OF_HATE",
		["npc_angel_of_life"] 			= "ANGEL_OF_LIFE",
		["npc_angel_of_death"] 			= "ANGEL_OF_DEATH",
		["npc_boss_travaler"]			= "BOSS_TRAVALER_SPAWN",
	}
	local respawn_time = 300 
	local until_respawn_time = 0

	for i, x in pairs(names) do
		AddBossToTable(bosses_table, i, x, respawn_time, until_respawn_time)
	end
	
	SetCustomBossUntilRespawnTime(bosses_table, "Demon_possessed", 300)
	SetCustomBossRespawnTime(bosses_table, "npc_boss_travaler", 300 + math.floor(150 * RandomFloat(1.0, 2.0)))
	--SetCustomBossRespawnTime(bosses_table, "npc_dota_custom_guardian", 10) -- DELETE IT!
end

function SetCustomBossUntilRespawnTime(boss_table, boss_name, respawn_time)
	boss_table[boss_name].until_respawn = respawn_time
end

function SetCustomBossRespawnTime(boss_table, boss_name, respawn_time)
	boss_table[boss_name].respawn = respawn_time
end

function AddBossToTable(bosses_table, boss_name, spawner_name, respawn_time, until_respawn_time)
	bosses_table[boss_name] = {
		spawner = spawner_name,
		respawn = respawn_time,
		until_respawn = until_respawn_time,
	}
end

InitBossTable(boss_table)

return boss_table

---------------------------------------------------------------------------
