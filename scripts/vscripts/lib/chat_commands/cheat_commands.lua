--[[
Cheat lobby commands
 -spawnCreeps, -sc      	-- spawn creeps on map. 
 -enableCreepSpawn			-- enable creep spawning 
 -disableCreepSpawn			-- disable creep spawning 
 -is_cheats 				-- is cheats enabled 
 -addmod modifier_name 10 	-- adding modifier with name 'modifier_name' and duration '10'sec
 -remmod modifier_name		-- removing modifier with name 'modifier_name'
 -str 100					-- set base hero strength to 100
 -agi 100					-- set base hero agility to 100
 -int 100					-- set base hero intellect to 100 
]]

Commands = Commands or class({})

--require("lib/spawners/creep_spawner")

function Commands:is_cheats( player, arg )
	if GameRules:IsCheatMode() then print_d("Cheats is enabled!") else print_d("Cheats is disabled!") end
end 

------------------------------------------------------------------------------------------------------------

if not GameRules:IsCheatMode() then 
	return 
end 

function Commands:spawnCreeps( player, arg )
	CreepSpawner:SpawnCreeps() 
end 
function Commands:sc( player, arg ) self:spawnCreeps( player, arg ); end 


function Commands:disableCreepSpawn(player, arg)
	CreepSpawner:SetEnable(false) 
end 

function Commands:enableCreepSpawn(player, arg)
	CreepSpawner:SetEnable(true) 
end 

function Commands:addmod(player, arg)
	local hero 			= player:GetAssignedHero() 
	local modifierName 	= arg[1]
	local duration 		= arg[2]

	hero:AddNewModifier(hero, nil, modifierName, { duration = duration }) 
end 

function Commands:remmod(player, arg)
	local hero 			= player:GetAssignedHero() 
	local modifierName 	= arg[1]
	hero:RemoveModifierByName(modifierName)
end 

function Commands:str(player, arg)
	local hero 			= player:GetAssignedHero() 
	hero:SetBaseStrength( tonumber(arg[1]) )
	hero:CalculateStatBonus()
end 

function Commands:agi(player, arg)
	local hero 			= player:GetAssignedHero() 
	hero:SetBaseAgility( tonumber(arg[1]) )
	hero:CalculateStatBonus()
end 

function Commands:int(player, arg)
	local hero 			= player:GetAssignedHero() 
	hero:SetBaseIntellect( tonumber(arg[1]) )
	hero:CalculateStatBonus()
end

function Commands:q(player, arg)
	local hero 			= player:GetAssignedHero()
	hero:AddItemByName("item_slice_amulet")
	hero:AddItemByName("item_static_amulet")
end