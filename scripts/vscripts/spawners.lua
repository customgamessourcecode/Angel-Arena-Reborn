local creep_table = require('creeps/creeps_table')
local bosses_table = require('creeps/boss_table')
local items_table = require('items/drop_table')

local creeps_count = 0
local map_multipler = 1
local init = false
_G.Units = {}
_G.Bosses = {}
_G.CREEPS_LIMIT = 700 

UnitList = {}
ItemList = {}

local hero_max_level = 0

function GetMaxLevelInTeam()
	local lvl = 0
	local lc = 0
	local heroes = HeroList:GetAllHeroes()

	for i,x in pairs(heroes) do
		if x and IsConnected(x) then
			lvl = lvl + x:GetLevel()
			lc = lc + 1
		end
	end

	hero_max_level = lvl/lc
end

function SpawnNeutrals()
	if init == false then
		init = true
		if GetMapName() == "map_10x10" then
			map_multipler = 2
			_G.CREEPS_LIMIT = 1200
		end
		print("map multipler = " .. map_multipler)
		SpawnAllBosses(bosses_table, Bosses)
	end
	--SpawnEasyStack()
	--SpawnCreepsOnPoints(creep_table)
end

function SpawnCreepsOnPoints(creep_table)
	local count_min = 2
	local count_max = 3
	local max_level = 1 -- max 10!
	local current_level = 1
	local point;

	GetMaxLevelInTeam() -- sets max level

	if hero_max_level > 4 then -- old 5
		count_min = 2
		count_max = 4
		max_level = 2 -- level 5
	end

	if hero_max_level > 12 then -- old 10
		count_min = 2
		count_max = 5
		max_level = 3 -- level 10
	end

	if hero_max_level > 14 then -- old 15
		count_min = 3
		count_max = 6
		max_level = 4 -- level 15
	end

	if hero_max_level > 16 then -- old 20
		count_min = 4
		count_max = 7
		max_level = 5 -- level 20
	end

	if hero_max_level > 20 then -- old 25
		count_min = 5
		count_max = 8
		max_level = 6 -- level 25
	end

	if hero_max_level > 36 then -- old 45
		count_min = 5
		count_max = 8
		max_level = 7 -- level 40
	end

	if hero_max_level > 50 then -- old 70
		count_min = 5
		count_max = 8
		max_level = 8 -- level 60
	end

	if hero_max_level > 66 then -- old 80
		count_min = 5
		count_max = 8
		max_level = 9 -- level 80
	end

	if hero_max_level > 80 then --old 100
		count_min = 5
		count_max = 8
		max_level = 10 -- level 100
	end

	count_max = count_max*map_multipler

	local count = RandomInt(count_min, count_max)

	for i = 1, count do
		for j, x in pairs(creep_table) do
			if creeps_count > _G.CREEPS_LIMIT then
				print("ERROR, TOO MANY CREEPS")
				print("CREEPS COUNT = " .. creeps_count)
				return
			end
			if Entities:FindByName(nil, j) then
				point = Entities:FindByName(nil, j):GetAbsOrigin() 
				current_level = RandomInt(1, max_level)
				CreateUnitByName(x[current_level], point, true, nil, nil, DOTA_TEAM_NEUTRALS)
				creeps_count = creeps_count + 1
			end
		end
	end
end

function IsUnitCreep(unit_name)
	for i, x in pairs(creep_table) do
		for _, y in pairs(x) do
			if unit_name == y then
				return true
			end
		end
	end
end

function OnCreepDeathGlobal(creep_unit)
	creeps_count = creeps_count - 1
	Timers:CreateTimer({
             	endTime = 10,
                callback = function()
                	UTIL_Remove(creep_unit) 
                    return nil
                end})
end

function SpawnEasyStack()
	local point_radiant = Entities:FindByName( nil, "RADIANT_SPAWNER_KEY"):GetAbsOrigin() 
	local point_dire = Entities:FindByName( nil, "DIRE_SPAWNER_KEY"):GetAbsOrigin()
	local MX = 4
	local MN = 2
	if GameRules:GetGameTime() > 600 then 
		MX = 6
		MN = 3
	end

	if GameRules:GetGameTime() > 1200 then 
		MN = 5
		MX = 8
	end

	MX = MX*map_multipler
	local ds = RandomInt(MN, MX)
	local cu
	for i = 1, ds do
		cu = RandomInt(1, 6)
		if cu == 1 then unitname = "npc_dota_neutral_kobold" end;
		if cu == 2 then unitname = "npc_dota_neutral_harpy_scout" end;
		if cu == 3 then unitname = "npc_dota_neutral_ghost" end;
		if cu == 4 then unitname = "npc_dota_neutral_gnoll_assassin" end;
		if cu == 5 then unitname = "npc_dota_neutral_harpy_storm" end;
		if cu == 6 then unitname = "npc_dota_neutral_alpha_wolf" end;
		CreateUnitByName(unitname, point_radiant, true, nil, nil, DOTA_TEAM_NEUTRALS) 
		CreateUnitByName(unitname, point_dire, true, nil, nil, DOTA_TEAM_NEUTRALS) 
	end
end

function SpawnAllBosses(bosses_table, unit_table)
	for i, _ in pairs(bosses_table) do
		SpawnBoss(unit_table, bosses_table, i)
	end
end

function SpawnBoss(unit_table, boss_table, boss_name)
	if not IsBossAlive(unit_table, boss_name) then
		if IsBossReadyToRespawn(boss_table, boss_name) then
			PrecacheUnitByNameAsync(boss_name, function(...)
				local spawn_point 
				if boss_name ~= "npc_boss_travaler" then
					spawn_point = Entities:FindByName( nil, boss_table[boss_name].spawner ):GetAbsOrigin() 
				else
					local spawn_number = RandomInt(1, 5)
					spawn_point = Entities:FindByName( nil, "TRAVALER_SPAWN_" .. spawn_number ):GetAbsOrigin() 
				end
				
				local boss_unit = CreateUnitByName(boss_name, spawn_point, true, nil, nil, DOTA_TEAM_NEUTRALS)
				Timers:CreateTimer("poss_power" .. boss_name, {
					endTime = 3,
					callback = function()
						boss_unit:AddNewModifier(boss_unit, nil, "modifier_boss_power", null) 
						print("[LUA]Boss spawner: " .. boss_unit:GetUnitName())
						InsertUnitInBossTable(unit_table, boss_unit, spawn_point)		
					end
				})
			end)
		else
			Timers:CreateTimer("SpawnBoss_" .. boss_name ,{
             	endTime = boss_table[boss_name].until_respawn,
                callback = function()
                	boss_table[boss_name].until_respawn = 0
                	SpawnBoss(unit_table, boss_table, boss_name)
                    return nil
                end})
		end
	end
end

function InsertUnitInBossTable(unit_table, inserting_unit, inserting_point)
	local inserting_data = 
	{
		unit = inserting_unit,
		point = inserting_point,
	}
	table.insert(unit_table, inserting_data)
end

function OnBossDeathGlobal(unit)
	OnBossDeath(Bosses, bosses_table, unit)
end

function PrintBossDeathMessage(boss_name)
	GameRules:SendCustomMessage("#die_"..boss_name, 0, 0) 
end

function OnBossDeath(unit_table, boss_table, killed_unit)
	if killed_unit then
		local boss_name = killed_unit:GetUnitName()
		print("Boss ".. boss_name .. " dead now. respawn at " .. boss_table[boss_name].respawn .. " seconds, current time" .. GameRules:GetGameTime())

		_G.Bosses.deaths = _G.Bosses.deaths or {}

		if not _G.Bosses.deaths[boss_name] then _G.Bosses.deaths[boss_name] = 0 end -- kill counter

		_G.Bosses.deaths[boss_name] = _G.Bosses.deaths[boss_name] + 1

		print("Boss:", boss_name, "die counter:", _G.Bosses.deaths[boss_name])
		Timers:CreateTimer("SpawnBoss_" .. boss_name ,{ --таймер следующей дуэльки
             	endTime = boss_table[boss_name].respawn,
                callback = function()
                	SpawnBoss(unit_table, boss_table, boss_name)
                    return nil
                end})
		PrintBossDeathMessage(boss_name)
	end

	for i, x in pairs(unit_table) do
		if x.unit == killed_unit then
			table.remove(unit_table, i)
		end
	end
end

function IsUnitBossGlobal(unit)
	if not unit or not IsValidEntity(unit) then 
		return false
	end
	return IsUnitBoss(bosses_table, unit:GetUnitName())
end

function IsUnitBoss(bosses_table, unit_name)
	for i, _ in pairs(bosses_table) do
		if i == unit_name then 
			--print_d("unit " .. unit_name .. " is boss")
			return true
		end
	end
	--print_d("unit " .. unit_name .. " not is boss")
	return false
end

function IsBossReadyToRespawn(boss_table, boss_name)
	if boss_table[boss_name].until_respawn == 0 then
		--print("Boss " .. boss_name .. " ready to spawn")
		return true
	else
		--print("Boss " .. boss_name .. " not ready to spawn")
		return false
	end
end

function IsBossAlive(unit_table, unit_name)
	for i, x in pairs(unit_table) do
		if x.unit then

			if not x.unit:IsNull() and x.unit:GetUnitName() == unit_name then
				return true
			end

			if x.unit:IsNull() then
				table.remove(unit_table, i)
			end
		end
	end
	return false
end

function IsBossAliveGlobal(unit_name)
	--if GameRules:GetGameTime() < 300 then return true end
	return IsBossAlive(Bosses, unit_name)

end

function IsMonkAlive(monk_type)
	return IsBossAlive(Bosses, "npc_monk_of_".. monk_type )
end

function SpawnAllBosses(bosses_table, unit_table)
	for i, _ in pairs(bosses_table) do
		SpawnBoss(unit_table, bosses_table, i)
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------DROP ITEM SYSTEM-----------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
function GetTableSize(table_one)
	local i = 0
	for _,_ in pairs(table_one) do
		i = i+1
	end

	return i
end

function GetRandomItemFromTable(drop_table_items)
	local rand_n = RandomInt(1, GetTableSize(drop_table_items))
	local count = 0
	--print("random size = " .. GetTableSize(drop_table_items))
--	DeepPrintTable(drop_table_items)
	for i, x in pairs(drop_table_items) do
		--print("item", i)
		count = count + 1
		if rand_n == count then 
			return i 
		end
	end
end

function GetCreepQuality(drop_table, unit)
	if not unit then 
		return -1
	end
	local unitname = unit:GetUnitName()
	if drop_table[unitname] then
		return drop_table[unitname]
	else
		return -1
	end
end

function DropItem(unit)
	local drop_table = items_table
	local quality = GetCreepQuality(drop_table.creeps, unit)
	if quality == -1 then 
		return 
	end
	local max_item_count = drop_table[quality].max_count
	local item
	local point = unit:GetAbsOrigin()
	for i = 0, max_item_count do 
		item = GetRandomItemFromTable(drop_table[quality].items)
		if RollPercentage(drop_table[quality].items[item]) then
			CreateDrop(item, point)
		end
	end
end
]]


function GetItemsCount(unit)
	if not unit then return end

	local level = unit:GetLevel()

	if level == 100 then return 6 end

	return 1
end

function GetTableSize(table_one)
	if not table_one then return 0 end
	local i = 0
	for _,_ in pairs(table_one) do
		i = i+1
	end

	return i
end

function GetRandomItemFromBossTable(table)
	if not table then return end
	local rand, j, tries
	tries = 0
	while(tries < 20) do
		rand = RandomInt(1, GetTableSize(table))
		j = 1
		for i, x in pairs(table) do
			if j == rand and x and RollPercentage(x[1]) then
				return i
			end
			j = j + 1
		end
		tries = tries + 1
	end
end

function BalanceDrop(difference, noob_team)
	local point, random_max

	if noob_team == DOTA_TEAM_GOODGUYS then
		point =  Entities:FindByName( nil, "RADIANT_BASE" ):GetAbsOrigin()
	elseif noob_team == DOTA_TEAM_BADGUYS then
		point = Entities:FindByName( nil, "DIRE_BASE"):GetAbsOrigin()
	end

	if difference >= 20 then
		random_max = RandomInt(1, 2)
		for i = 1, random_max do
			CreateDrop("item_tome_un_6", point)
		end

		CreateDrop("item_tome_med", point)

		for i = 1, random_max do
			CreateDrop("item_tome_lvlup", point)
		end
	end
	
	if difference >= 10 then
		random_max = RandomInt(1, 1)
		for i = 1, random_max do
			CreateDrop("item_tome_un_6", point)
		end
		random_max = RandomInt(1, 2)
		for i = 1, random_max do
			CreateDrop("item_tome_lvlup", point)
		end
	end

	if difference >= 5 then
		random_max = RandomInt(1, 1)
		for i = 1, random_max do
			CreateDrop("item_tome_lvlup", point)
		end
	end

end

function CreateDrop(itemName, pos)
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

function IsConnected(unit)
    return not IsDisconnected(unit)
end

function IsDisconnected(unit)
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


function DropItem(unit)
	local drop_table = items_table
	if not drop_table then
		return
	end

	if not unit then 
		return
	end

	if not items_table[unit:GetUnitName()] then
		return 
	end

	if not IsUnitBossGlobal(unit) then
		return 
	end
	
	local max_item_count = GetItemsCount(unit)
	local item
	local point = unit:GetAbsOrigin()

	if not point or not max_item_count then return end

	for i = 1, max_item_count do 
		item = GetRandomItemFromBossTable(drop_table[unit:GetUnitName()])

		if item then CreateDrop(item, point) end
	end
end