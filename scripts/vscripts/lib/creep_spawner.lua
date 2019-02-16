creep_spawners = class({})

LinkLuaModifier( "modifier_creep_leveling_1",  'lib/modifiers/creep_leveling/modifier_creep_leveling_1',   LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_5",  'lib/modifiers/creep_leveling/modifier_creep_leveling_5',   LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_10", 'lib/modifiers/creep_leveling/modifier_creep_leveling_10',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_15", 'lib/modifiers/creep_leveling/modifier_creep_leveling_15',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_20", 'lib/modifiers/creep_leveling/modifier_creep_leveling_20',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_25", 'lib/modifiers/creep_leveling/modifier_creep_leveling_25',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_40", 'lib/modifiers/creep_leveling/modifier_creep_leveling_40',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_60", 'lib/modifiers/creep_leveling/modifier_creep_leveling_60',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_80", 'lib/modifiers/creep_leveling/modifier_creep_leveling_80',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_100",'lib/modifiers/creep_leveling/modifier_creep_leveling_100', LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_creep_leveling_ancient_1",  'lib/modifiers/creep_leveling/modifier_creep_leveling_ancient_1',   LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_ancient_5",  'lib/modifiers/creep_leveling/modifier_creep_leveling_ancient_5',   LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_ancient_10", 'lib/modifiers/creep_leveling/modifier_creep_leveling_ancient_10',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_ancient_15", 'lib/modifiers/creep_leveling/modifier_creep_leveling_ancient_15',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_ancient_20", 'lib/modifiers/creep_leveling/modifier_creep_leveling_ancient_20',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_ancient_25", 'lib/modifiers/creep_leveling/modifier_creep_leveling_ancient_25',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_ancient_40", 'lib/modifiers/creep_leveling/modifier_creep_leveling_ancient_40',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_ancient_60", 'lib/modifiers/creep_leveling/modifier_creep_leveling_ancient_60',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_ancient_80", 'lib/modifiers/creep_leveling/modifier_creep_leveling_ancient_80',  LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_creep_leveling_ancient_100",'lib/modifiers/creep_leveling/modifier_creep_leveling_ancient_100', LUA_MODIFIER_MOTION_NONE )


local items_table 			= require('lib/creep_spawner/new_drop')

local creep_stats 			= LoadKeyValues('scripts/npc/creep_stats.txt')
local creep_levels 			= { 1, 5, 10, 15, 20, 25, 40, 60, 80, 100 }
local stat_creep_name 		= "standart_"
local stat_ancient_name 	= "ancient_"
local radiant_spawner_name 	= "RADIANT_SPAWNER_"
local dire_spawner_name 	= "DIRE_SPAWNER_"
local creep_spawners 		= LoadKeyValues('scripts/npc/creep_spawners.txt')
local modifier_name 		= "modifier_creep_leveling_"
local modifier_name_ancient	= "modifier_creep_leveling_ancient_"

local ancients_creep_names 	= { 
	["npc_aa_creep_dragon_a"] = 1, 
	["npc_aa_creep_centaur_a"] = 1, 
	["npc_aa_creep_croco_a"] = 1, 
	["npc_aa_creep_salamander_a"] = 1
}

local map_multipler 		= 1
local CREEP_LIMIT 			= 700
local current_creep_count 	= 0 

if GetMapName() == "map_10x10" then
	map_multipler = 2
	_G.CREEPS_LIMIT = 1200
end

function creep_spawners:GetSpawnInformation()
	local count_min = 2
	local count_max = 3
	local max_level = 1
	local k_level 	= creep_spawners:GetCreepLeveling()

	if k_level > 4 then
		count_min = 2
		count_max = 4
		max_level = 5 -- level 5
	end

	if k_level > 12 then
		count_min = 2
		count_max = 5
		max_level = 10 -- level 10
	end

	if k_level > 14 then
		count_min = 3
		count_max = 5
		max_level = 15 -- level 15
	end

	if k_level > 16 then
		count_min = 3
		count_max = 5
		max_level = 20 -- level 20
	end

	if k_level > 20 then
		count_min = 3
		count_max = 5
		max_level = 25 -- level 25
	end

	if k_level > 36 then
		count_min = 3
		count_max = 5
		max_level = 40 -- level 40
	end

	if k_level > 50 then
		count_min = 3
		count_max = 5
		max_level = 60 -- level 60
	end

	if k_level > 66 then
		count_min = 3
		count_max = 5
		max_level = 80 -- level 80
	end

	if k_level > 80 then
		count_min = 3
		count_max = 5
		max_level = 100 -- level 100
	end

	return count_min, count_max, max_level
end

function creep_spawners:Shuffle( tbl )
	for idx, x in pairs(tbl) do
		local i = RandomInt(1, #tbl)
		if i ~= idx then
			local temp = x;
			tbl[idx] = tbl[i];
			tbl[i] = temp;
		end
	end
	return tbl 
end

function creep_spawners:GetCreepLeveling()
	local lvl = 0
	local lc = 0
	local heroes = HeroList:GetAllHeroes()

	for i,x in pairs(heroes) do
		if x and creep_spawners:IsConnected(x) then
			lvl = lvl + x:GetLevel()
			lc = lc + 1
		end
	end

	return lvl/lc
end

function SpawnersDeathListener( unit )
	if not unit or not unit.is_neutral_spawned then 
		return 
	end 

	creep_spawners:DropItemA(unit)

	current_creep_count = current_creep_count - 1
	Timers:CreateTimer({
     	endTime = 10,
        callback = function()
        	UTIL_Remove(unit) 
            return nil
        end})
end

function creep_spawners:SpawnCreepsAtPoint(point_name, creep_list, min_count, max_count, stat_table)
	local point_ent = Entities:FindByName( nil, point_name ) 
	if not point_ent then 
		print("[Creep Spawner] failed to find point name <" .. point_name .. ">")
		return 
	end

	local point_coord = point_ent:GetAbsOrigin() 
	local c = RandomInt(min_count, max_count)
	local spawned_count = 0	
	local is_easy_spawner = creep_spawners:IsEasySpawner ( point_name )
	local is_ancient_spawner = creep_spawners:IsAncientSpawner( point_name )

	creep_list = creep_spawners:Shuffle(creep_list)

	for i = 0, c do
		for _, creep_name in pairs(creep_list) do
			spawned_count = spawned_count + 1
			--print("current_creep_count = ", current_creep_count)
			if spawned_count > c then 
				return 
			end		
			if current_creep_count > CREEP_LIMIT then 
				return 
			end

			local creep = CreateUnitByName(creep_name, point_coord, true, nil, nil, DOTA_TEAM_NEUTRALS) 	
			
			if creep then
				creep.is_neutral_spawned = true 
				creep.level = stat_table["lvl"] 
				current_creep_count = current_creep_count + 1

				local local_modifier_name = modifier_name
				
				if not is_easy_spawner then
					if not is_ancient_spawner then
						creep:AddNewModifier(creep, nil, modifier_name .. stat_table["lvl"], {})
					else
						creep:AddNewModifier(creep, nil, modifier_name_ancient .. stat_table["lvl"], {})
					end
					creep:SetDeathXP( stat_table["exp"] )

					local gold_min = stat_table["gold_min"] or 0 
					local gold_max = stat_table["gold_max"] or 0

					if creep_spawners:IsDragon(creep_name) then
						gold_min = gold_min * 1.3
						gold_max = gold_max * 1.3
					end

					creep:SetMinimumGoldBounty( gold_min )
					creep:SetMaximumGoldBounty( gold_max )
				end

				--CustomNetTables:SetTableValue("creeps", modifier_name .. stat_table["lvl"], stat_table)

				
			end

		end
	end
end

function creep_spawners:GetRandomFromLevelTable(min, max)
	local new_levels = Shuffle(creep_levels)
	local current_level = RandomInt(min, max)
	for _, number in pairs(new_levels) do
		if number <= current_level and number >= min then
			return number
		end
	end
end

function creep_spawners:GetStatsForLevel( level, bAncient )
	local name = stat_creep_name

	if bAncient then
		name = stat_ancient_name
	end

	local new_table = creep_stats[name .. level]

	if not new_table then
		return {}
	end

	new_table["lvl"] = level 

	return new_table
end

function creep_spawners:IsEasySpawner( spawner_name )
	if string.find(spawner_name, "_KEY") or string.find(spawner_name, "_KEY") then
		return true 
	else 
		return false
	end
end

function creep_spawners:Is10x10Spawner( spawner_name )
	if string.find(spawner_name, "SPAWNER_7") or string.find(spawner_name, "SPAWNER_8") then
		return true 
	else 
		return false
	end
end

function creep_spawners:IsAncientSpawner( spawner_name )
	if string.find(spawner_name, "SPAWNER_5") or string.find(spawner_name, "SPAWNER_6") then
		return true 
	else 
		return false
	end
end

function creep_spawners:IsDragon( creep_name )
	if string.find(creep_name, "dragon") or string.find(creep_name, "salamander") then
		return true 
	else 
		return false
	end
end

function SpawnCreeps()
	local min_count, max_count, max_level = creep_spawners:GetSpawnInformation()
	local stats 

	for spawner_name, creep_list in pairs(creep_spawners["radiant"]) do
		if not ( creep_spawners:Is10x10Spawner(spawner_name) and GetMapName() ~= "map_10x10" )then
			stats = creep_spawners:GetStatsForLevel( max_level, creep_spawners:IsAncientSpawner( spawner_name ) )
			creep_spawners:SpawnCreepsAtPoint( spawner_name, creep_list, min_count, max_count, stats)
		end
	end

	for spawner_name, creep_list in pairs(creep_spawners["dire"]) do
		if not ( creep_spawners:Is10x10Spawner(spawner_name) and GetMapName() ~= "map_10x10" )then

			stats = creep_spawners:GetStatsForLevel( max_level, creep_spawners:IsAncientSpawner( spawner_name ) )
			creep_spawners:SpawnCreepsAtPoint( spawner_name, creep_list, min_count, max_count, stats)
		end
	end
end

function creep_spawners:LoadDataToNetTable()
	local name = stat_creep_name

	for _, level in pairs(creep_levels) do
		local new_table = creep_stats[name .. level]
		CustomNetTables:SetTableValue("creeps", modifier_name .. level, new_table)
	end

	name = stat_ancient_name
	
	for _, level in pairs(creep_levels) do
		local new_table = creep_stats[name .. level]
		CustomNetTables:SetTableValue("creeps", modifier_name_ancient .. level, new_table)
	end

	
end


function creep_spawners:GetNumberForLevel(level)
	local number = 1

	if level >= 10 then
		number = 2
	end

	if level >= 15 then
		number = 3
	end

	if level >= 25 then
		number = 4
	end

	return number 
end

function creep_spawners:GetRandomItemFromTableA(table, level)
	if not table then return nil end

	if GameRules:GetGameTime() > 3000 then return nil end
	local number = creep_spawners:GetNumberForLevel(level)
	local rand, j, tries

	rand = RandomInt(1, GetTableSize(table))
	j = 1
	for i, x in pairs(table) do
		if j == rand and x and RollPercentage(x[1]) and number >= x[4] then
			return i
		end
		j = j + 1
	end
	return nil
end

function creep_spawners:DropItemA(unit)
	local drop_table = items_table
	if not drop_table then
		return
	end

	if not unit then 
		return
	end

	local max_item_count = GetItemsCount(unit)
	local item
	local point = unit:GetAbsOrigin()

	if not point or not max_item_count then return end

	for i = 1, max_item_count do 
		item = creep_spawners:GetRandomItemFromTableA(drop_table, unit.level )

		if item then creep_spawners:CreateDrop(item, point) end
	end
end

function creep_spawners:IsConnected(unit)
    return not creep_spawners:IsDisconnected(unit)
end

function creep_spawners:IsDisconnected(unit)
    if not unit or not IsValidEntity(unit) then
        return false
    end

    local playerid = unit:GetPlayerOwnerID()
    if not playerid then 
        return false
    end

    local connection_state = PlayerResource:GetConnectionState(playerid) 
    if connection_state == DOTA_CONNECTION_STATE_ABANDONED or connection_state == DOTA_CONNECTION_STATE_DISCONNECTED then
        return true
    else
        return false
    end
end

function creep_spawners:CreateDrop(itemName, pos)
   	local newItem = CreateItem(itemName, nil, nil)
   	newItem:SetPurchaseTime(0)
   	local drop = CreateItemOnPositionSync( pos, newItem )
   	newItem:LaunchLoot(false, 300, 0.75, pos + RandomVector(RandomFloat(50, 80)))

   	Timers:CreateTimer({
             	endTime = 60,
                callback = function()
                	if newItem and IsValidEntity(newItem) then

                		if not newItem:GetOwnerEntity() then 

	                		if drop and IsValidEntity(drop) then UTIL_Remove(drop) end
                			UTIL_Remove(newItem)

                		end

                   	end
                    return nil
                end})
end


creep_spawners:LoadDataToNetTable()

