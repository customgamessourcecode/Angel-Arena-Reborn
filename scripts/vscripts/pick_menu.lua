--[[
 * ---- Author: CryDeS     ---- *
 * ---- Build : 16.07.2016 ---- *

 * It's changes normal pick menu! Be careful with it
 * Also u need to add <GameRules:SetHeroSelectionTime(0)> into u InitGameMode()
 * Be careful, input pick table ITS NOT PICK TABLE FOR HERO, its only uses for interface. 
 * Real hero with real abilities takes from 'scripts/npc/npc_heroes.txt' or 'scripts/npc/npc_heroes_custom.txt'

 * Example of pick table (WITH4
  {
	"npc_my_game_lol"		-- game try to change hero for THIS hero
	{
		name 		= "npc_dota_hero_wisp",
		real_name 	= "npc_my_game_lol"
		abilities	= {		-- max skills = 6! more will cause bugs with panorama
			"chen_penitence",		
			"chen_test_of_faith",
			"chen_hand_of_god",
		},
		base_att 	= 1, 	-- STR[0], AGI[1], INT[2]
		str 		= 10, 	-- base strength
		agi 		= 20, 	-- base agility
		int 		= 12,	-- base intellect
		str_plus	= 1.2, 	-- additional strength per level, dont work because there no command in lua to change additional att per lvl.
		agi_plus	= 2.3, 	-- see top
		int_plus	= 4.2,	-- see top!
		bat 		= 1.7,	-- Base Attack Time. For alchemist ultimate its 1.0, for most standart hereos 1.7
		movespeed 	= 200,	-- some questions for base movespeed?)
		attack 		= 42, 	-- start damage(AVERAGE, max - min / 2)
		picked 		= 1, 	-- is hero already picked? 0 = false, 1 = true
	},

	"npc_dota_hero_wisp"
	{
		name 		= "npc_dota_hero_wisp",
		real_name 	= "npc_dota_hero_wisp"
		abilities	= { 	-- max skills = 6! more will cause bugs with panorama
			"wisp_skill_1",		
			"wisp_skill_2",
			"wisp_skill_3",
			"wisp_skill_4",
			"wisp_skill_5",
			"wisp_skill_6",
		},
		base_att 	= 1, 	-- STR[0], AGI[1], INT[2]
		str 		= 10, 	-- base strength
		agi 		= 20, 	-- base agility
		int 		= 12,	-- base intellect
		str_plus	= 1.2, 	-- additional strength per level, dont work because there no command in lua to change additional att per lvl.
		agi_plus	= 2.3, 	-- see top
		int_plus	= 4.2,	-- see top!
		bat 		= 1.7,	-- Base Attack Time. For alchemist ultimate its 1.0, for most standart hereos 1.7
		movespeed 	= 200,	-- some questions for base movespeed?)
		attack 		= 42, 	-- start damage(AVERAGE, max - min / 2)
		picked 		= 0, 	-- is hero already picked? 0 = false, 1 = true
	}
  }

  * Example of using:
  [
  		local hPlayer 		= event.player 					-- u need hPlayer here!
  		local tPick_table 	= SomeParsingFunction() 		-- gets heroes for UI(u need to create this function)
  		-- local tPick_table = PickMenu:_GetHeroesParams() 	-- or use mine function for parse standart doto+custom heroes
		PickMenu:OpenMenuToPlayer(hPlayer, tPick_table)
  ]

  *Functions and input args:
  	table _GetHeroesParams()
  	nil	OpenMenuToPlayer(hPlayer, tPick)
  	nil	PickHeroForPlayer(iPlayerID, sHeroName)
  	nil	OpenMenuToAllPlayers(tPick)

  * Also I using table that contains radiant and dire tables
   tHeroesRadiant	-- for radiant heroes
   tHeroesDire		-- for dire heroes
]]

PickMenu = PickMenu or class({})

_G.DEFAULT_HERO_PICK 		= "npc_dota_hero_target_dummy"	-- Default hero
local RADIANT_BASE_POINT 	= "RADIANT_BASE"				-- Game teleport to this point before change hero
local DIRE_BASE_POINT 		= "DIRE_BASE"					-- Game teleport to this point before change hero
local STUN_MODIFIER			= "modifier_dissapear"			-- IMPORTANT, its stun that gets hero before change to other hero!

local forbidden_modifiers = {
	"modifier_shredder_chakram_disarm",
	"modifier_shredder_chakram_disarm_2",
	"modifier_shredder_chakram_2_disarm",
	"modifier_naga_siren_song_of_the_siren_aura",
	"modifier_followthrough",
}

local exceptions_hero = {
	["npc_dota_hero_visage"] 			= 1, -- armor fail
	["npc_dota_hero_invoker"] 			= 1, -- ultimate fail
	["npc_dota_hero_earth_spirit"] 		= 1, -- stone charges fail
	["npc_dota_hero_mirana"] 			= 1, -- 1 skill cd with scepter fail
	["npc_dota_hero_legion_commander"] 	= 1, -- passive fail
	["npc_dota_hero_gyrocopter"] 		= 1, -- passive with scepter fail
	["npc_dota_hero_drow_ranger"] 		= 1, -- new skill fail
	["npc_dota_hero_slark"] 			= 1, -- passive fail, ult fail
	["npc_dota_hero_shadow_demon"] 		= 1, -- ult charges fail
	["npc_dota_hero_ember_spirit"] 		= 1, -- ult charges fail
	["npc_dota_hero_zuus"] 				= 1, -- 2 skill stun = 1 sec, fail
	["npc_dota_hero_lina"] 				= 1, -- 3 skill dont work, fail
	["npc_dota_hero_rubick"]			= 1, -- ultimate rechange attribute bonus, fail
	["npc_dota_hero_sand_king"]			= 1, -- 3 skill fail
	["npc_dota_hero_puck"]				= 1, -- 1 skill fail
	["npc_dota_hero_brewmaster"]		= 1, -- 1 skill fail
}

local fix_skills = {
	["npc_dota_hero_riki"] 					= { "modifier_riki_permanent_invisibility" },
	["npc_dota_hero_weaver"] 				= { "modifier_weaver_geminate_attack" },
	["npc_dota_hero_keeper_of_the_light"] 	= { "modifier_keeper_of_the_light_spirit_form" },
	["npc_dota_hero_brewmaster"] 			= { "modifier_brewmaster_drunken_brawler" },
	["npc_dota_hero_tidehunter"] 			= { "modifier_tidehunter_kraken_shell" },
	["npc_dota_hero_lycan"] 				= { "modifier_lycan_feral_impulse_aura", "modifier_lycan_feral_impulse"},
	["npc_dota_hero_huskar"] 				= { "modifier_huskar_burning_spear_self", "modifier_huskar_berserkers_blood"},
	["npc_dota_hero_shredder"] 				= { "modifier_shredder_reactive_armor"},
	["npc_dota_hero_skeleton_king"] 		= { "modifier_skeleton_king_vampiric_aura", "modifier_skeleton_king_vampiric_aura_buff", "modifier_skeleton_king_mortal_strike", "modifier_skeleton_king_reincarnation"},
	["npc_dota_hero_abaddon"] 				= { "modifier_abaddon_frostmourne", "modifier_abaddon_borrowed_time_passive" },
	["npc_dota_hero_spirit_breaker"] 		= { "modifier_spirit_breaker_empowering_haste_aura", "modifier_spirit_breaker_empowering_haste"},
	["npc_dota_hero_elder_titan"]			= { "modifier_elder_titan_natural_order_aura"},
	["npc_dota_hero_omniknight"] 			= { "modifier_beastmaster_inner_beast_aura", "modifier_beastmaster_inner_beast"},
	["npc_dota_hero_earthshaker"] 			= { "modifier_earthsheker_aftershock" },
	["npc_dota_hero_vengefulspirit"] 		= { "modifier_vengefulspirit_command_aura", "modifier_vengefulspirit_command_aura_effect"},
	["npc_dota_hero_antimage"] 				= { "modifier_antimage_spell_shield"},
	["npc_dota_hero_bloodseeker"] 			= { "modifier_bloodseeker_thirst" },
	["npc_dota_hero_troll_warlord"]			= { "modifier_troll_warlord_fervor" },
	["npc_dota_hero_phantom_lance"]			= { "modifier_phantom_lancer_phantom_edge", "modifier_phantom_lancer_juxtapose" },
	["npc_dota_hero_nevermore"]				= { "modifier_nevermore_necromastery" },
	["npc_dota_hero_phantom_assassin"]		= { "modifier_phantom_assassin_blur", "modifier_phantom_assassin_blur_active", "modifier_phantom_assassin_coupdegrace" },
	["npc_dota_hero_luna"]					= { "modifier_luna_moon_glaive" },
	["npc_dota_hero_spectre"]				= { "modifier_spectre_spectral_dagger_path", "modifier_spectre_desolate", "modifier_spectre_dispersion" },
	["npc_dota_hero_bounty_hunter"]			= { "modifier_bounty_hunter_jinada"},
	["npc_dota_hero_broodmother"]			= { "modifier_broodmother_incapacitating_bite" },
	["npc_dota_hero_ursa"]					= { "modifier_ursa_fury_swipes" },
	["npc_dota_hero_viper"]					= { "modifier_viper_poison_attack", "modifier_viper_nethertoxin", "modifier_viper_corrosive_skin" },
	["npc_dota_hero_obsidian_destroyer"]	= { "modifier_obsidian_destroyer_arcane_orb"},
	["npc_dota_hero_enchantress"]			= { "modifier_enchantress_untouchable", "modifier_enchantress_impetus" },
	["npc_dota_hero_storm_spirit"]			= { "modifier_storm_spirit_overload_passive" },
	["npc_dota_hero_necrolyte"]				= { "modifier_necrolyte_sadist" },
}

local playerid_that_pick = {}
local playerid_that_connect = {}

function PickMenu:_SetPickedHero(old_hero, new_hero_name, hero_table)
	for i,x in pairs(hero_table) do
		if x == old_hero then
			x.picked_hero = new_hero_name;
		end
	end
end

function PickMenu:_DeleteAllControlUnits(player, unit_name)
	local all = Entities:FindAllByName(unit_name) 

	for i,x in pairs(all) do
		if x:GetPlayerOwner() == player then
			UTIL_Remove(x)
		end
	end
end

function PickMenu:_GetRandomFromTable(hero_table)
	local hero_name_table = {}
	for i,_ in pairs(hero_table) do
		table.insert(hero_name_table, i)
	end

	return hero_name_table[RandomInt(1, #hero_name_table)]
end

function PickMenu:PickRandomHero( keys )
	local playerid = keys.playerID
	--local heroes_table = PickMenu:_GetHeroesForPick()
	local heroes_table = PickMenu:_ParseGodsMenu()
	local player = PlayerResource:GetPlayer(playerid)
	local hero_name = PickMenu:_GetRandomFromTable(heroes_table)

	if not _G.session[playerid] then return end

	local iteration = 0;

	while(PickMenu:IsHeroAlreadyPicked(hero_name)) do
		hero_name = PickMenu:_GetRandomFromTable(heroes_table)
		print("new iteration, hero name = ", hero_name)
		iteration = iteration + 1;
		if(iteration > 100) then
			return;
		end
	end

	playerid_that_pick[playerid] = true

	player.is_picking = true;

	PickMenu:PickHeroForPlayer(playerid, hero_name)

end

function PickMenu:OnMenuClosed( keys ) 
	local player 	= PlayerResource:GetPlayer(keys.playerID)
	local playerid = player:GetPlayerID();
	if not _G.session or not _G.session[playerid] then return end

	if not PickMenu:IsPlayerPickHero( keys.playerID ) then
		PickMenu:OnPlayerLoadPickMenu( {playerID = keys.PlayerID} )
	end
end

function PickMenu:PickHeroForPlayer(playerid, abstract_hero_name)
	
	if not _G.session[playerid] then return end

	if _G.nCOUNTDOWNTIMER < 12 then return end
	if _G.duel_come == true then return end 

	if DuelLibrary:IsDuelActive() then return end

	local heroes_table = PickMenu:_GetHeroesParams()
	if not heroes_table[abstract_hero_name] then return end

	local player 	= PlayerResource:GetPlayer(playerid)
	local hero_name = heroes_table[abstract_hero_name].name
	local abilities = heroes_table[abstract_hero_name].abilities
	local old_hero 	= player:GetAssignedHero() 

	old_hero:AddNewModifier(old_hero, nil, STUN_MODIFIER, {duration = 4})

	if not IsConnected(old_hero) then 
		return 
	end

	player.is_picking = true
	
	if PickMenu:IsHeroAlreadyPicked( abstract_hero_name ) then 
		PickMenu:OpenRepickMenu(player)
		player.is_picking = false 
		_G.session[playerid] = nil;
		return 
	end

	CustomGameEventManager:Send_ServerToAllClients( "pick_menu_disable_hero", { hero = abstract_hero_name } )

	PrecacheUnitByNameAsync(hero_name, function()

		if not IsConnected(old_hero) then 
			--playerid_that_pick[playerid] = false;
			--player.is_picking = false
			_G.session[playerid] = nil;
			return  
		end

		if player.crash_timer then
			print_d("CRASH REPORT!")
			PickMenu:OpenRepickMenu(player)
			player.is_picking = false 
			_G.session[playerid] = nil;
			return 
		end

		if PickMenu:IsHeroAlreadyPicked( abstract_hero_name ) then 
			PickMenu:OpenRepickMenu(player)
			player.is_picking = false 
			_G.session[playerid] = nil;
			return 
		end

		if PickMenu:HasForbiddenModifier(old_hero) then 
			--PickMenu:OpenRepickMenu(player)
			player.is_picking = false 
			_G.session[playerid] = nil;
			return 
		end

		if _G.nCOUNTDOWNTIMER < 12 then 
			player.is_picking = false
			_G.session[playerid] = nil; 
			return 
		end

		heroes_table[abstract_hero_name].picked = 1

		PickMenu:_SetPickedHero(old_hero, abstract_hero_name, _G.tHeroesRadiant)
		PickMenu:_SetPickedHero(old_hero, abstract_hero_name, _G.tHeroesDire)

		old_hero:AddNewModifier(old_hero, nil, STUN_MODIFIER, {duration = 4})
		PickMenu:_MoveToBase(old_hero)

		local gold 		= old_hero:GetGold() or 0
		
		PickMenu:_RemoveHeroFromHeroTable(_G.tHeroesRadiant, old_hero)
		PickMenu:_RemoveHeroFromHeroTable(_G.tHeroesDire, old_hero)

		----------------------------- FIXES ----------------------------
		if old_hero:GetUnitName() == "npc_dota_hero_meepo" then
			local old_owner = old_hero:GetPlayerOwner() 
			local all = Entities:FindAllByName("npc_dota_hero_meepo") 

			for _, meepo_unit in pairs(all) do
				if old_owner == meepo_unit:GetPlayerOwner() and meepo_unit ~= old_hero then
					UTIL_Remove(meepo_unit)
				end
			end
		end

		if old_hero:HasAbility("life_stealer_assimilate") then
			local heroes = HeroList:GetAllHeroes() 
			for _, hero in pairs(heroes) do
				hero:RemoveModifierByName("modifier_life_stealer_assimilate")
			end
		end

		if old_hero:HasAbility("lone_druid_spirit_bear") then 
			old_hero:RemoveAbility("lone_druid_spirit_bear")
		end

		if old_hero:GetUnitName() == "npc_dota_hero_arc_warden" then
			local all = Entities:FindAllByName("npc_dota_hero_arc_warden") 
			for i,x in pairs(all) do
				if x:HasModifier("modifier_arc_warden_tempest_double") and x:GetPlayerOwner() == player then
					UTIL_Remove(x)
				end
			end
		end

		if old_hero:GetUnitName() == "npc_dota_hero_visage" then
			PickMenu:_DeleteAllControlUnits(player, "npc_dota_visage_familiar")
		end

		if old_hero:GetUnitName() == "npc_dota_hero_batrider" then
			PickMenu:_DeleteAllControlUnits(player, "npc_custom_unit_hawk")
		end

		if old_hero:GetUnitName() == "npc_dota_hero_earth_spirit" then
			PickMenu:_DeleteAllControlUnits(player, "npc_dota_earth_spirit_stone")
		end

		if old_hero:GetUnitName() == "npc_dota_hero_broodmother" then
			PickMenu:_DeleteAllControlUnits(player, "npc_dota_broodmother_web")
		end

		if old_hero:GetUnitName() == "npc_dota_hero_lone_druid" then
			PickMenu:_DeleteAllControlUnits(player, "npc_dota_lone_druid_bear")
		end

		PickMenu:_DeleteAllControlUnits(player, "Wildwing_level_1")
		PickMenu:_DeleteAllControlUnits(player, "Wildwing_level_5")
		PickMenu:_DeleteAllControlUnits(player, "Wildwing_level_10")
		PickMenu:_DeleteAllControlUnits(player, "Wildwing_level_15")
		PickMenu:_DeleteAllControlUnits(player, "Wildwing_level_20")
		PickMenu:_DeleteAllControlUnits(player, "Wildwing_level_25")
		PickMenu:_DeleteAllControlUnits(player, "Wildwing_level_40")
		PickMenu:_DeleteAllControlUnits(player, "Wildwing_level_60")
		PickMenu:_DeleteAllControlUnits(player, "Wildwing_level_80")
		PickMenu:_DeleteAllControlUnits(player, "Wildwing_level_100")

		PickMenu:_DeleteAllControlUnits(player, "Golem_level_1")
		PickMenu:_DeleteAllControlUnits(player, "Golem_level_5")
		PickMenu:_DeleteAllControlUnits(player, "Golem_level_10")
		PickMenu:_DeleteAllControlUnits(player, "Golem_level_15")
		PickMenu:_DeleteAllControlUnits(player, "Golem_level_20")
		PickMenu:_DeleteAllControlUnits(player, "Golem_level_25")
		PickMenu:_DeleteAllControlUnits(player, "Golem_level_40")
		PickMenu:_DeleteAllControlUnits(player, "Golem_level_60")
		PickMenu:_DeleteAllControlUnits(player, "Golem_level_80")
		PickMenu:_DeleteAllControlUnits(player, "Golem_level_100")
		----------------------------- FIXES END----------------------------

		----------------------------- SAVE ITEMS --------------------------
		local item_table = {}
		for i = 0, 12 do
			local item = old_hero:GetItemInSlot(i)
			if item then 
				local tbl = {
					item_name = item:GetName(),
					charges = item:GetCurrentCharges(),
					owner = item:GetPurchaser() 
				}
				--print("item:", tbl.item_name, "owner item:", tbl.owner:GetUnitName())
				if tbl.owner == old_hero then tbl.owner = nil end
				table.insert(item_table, tbl)
				UTIL_Remove(item)
			else
				table.insert(item_table, "null_item")
			end
		end
		local old_hero_name = old_hero:GetUnitName()

		PlayerResource:ReplaceHeroWith( playerid, hero_name, gold, 0 )

		local hero = player:GetAssignedHero()

		-- Удалим тпшку дающуюся за репик
		for i = 0, 5 do
			item = hero:GetItemInSlot(i)
			if item then
				UTIL_Remove(item)
			end
		end 

		print("TRYING TO DELETE OLD HERO")
		UTIL_Remove(old_hero)
		print("REMOVED OLD HERO")
		------------------------ FIXES -------------------------------------------
		hero:SetAbilityPoints(1)
		

		if old_hero_name == "npc_dota_hero_meepo" then
			if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
				table.insert(_G.tHeroesRadiant, hero)
			end
			if hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
				table.insert(_G.tHeroesDire, hero)
			end

		end

		local point 
		if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			point =  Entities:FindByName( nil, RADIANT_BASE_POINT ):GetAbsOrigin()
			print("moving hero to radiant base")
		elseif hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			point =  Entities:FindByName( nil, DIRE_BASE_POINT ):GetAbsOrigin()
			print("moving hero to dire base")
		end
	
		if point then
			FindClearSpaceForUnit(hero, point, false)
		end
		-------------------------FIXES END---------------------------------------
		
		for i = 0, 12 do
        	if item_table[i] and item_table[i] ~= "null_item" then
   				local item
   				if item_table[i].owner then
   					item = CreateItem(item_table[i].item_name, item_table[i].owner, item_table[i].owner) 
        			item:SetPurchaser(item_table[i].owner)
        			item:SetOwner(item_table[i].owner)
        		else
        			item = CreateItem(item_table[i].item_name, hero, hero) 
        			item:SetPurchaser(hero)
       				item:SetOwner(hero)
       			end
        			
        		item:SetPurchaseTime(0) 

        		if item_table[i].charges then
        			item:SetCurrentCharges(item_table[i].charges)
        		end

       			hero:AddItem(item) 

        		if item:GetName() == "item_hand_of_midas" or item:GetName() == "item_advanced_midas" then
        			item:StartCooldown(100)
        		end
       		end
       	end


		if(not exceptions_hero[abstract_hero_name]) then
			print("[PickMenu] Adding abilities for hero")
			for i = 0, 15 do
				local ability = hero:GetAbilityByIndex(i)
				if (ability) then hero:RemoveAbility(ability:GetName() ) end
			end

			for index, ability_name in pairs(abilities) do
				print("AddAbility", ability_name)
				hero:AddAbility(ability_name)
			end

			if not hero:HasAbility("attribute_bonus") then
				hero:AddAbility("attribute_bonus") 
			end
		end

		-------------------------------- FIX FOR STANDART SKILLS ----------------------------
		print("[PickMenu] Fix for some standart skills")

		if abstract_hero_name == "npc_dota_hero_sniper" then
			local ability = hero:FindAbilityByName("sniper_shrapnel")
			hero:AddNewModifier(hero, ability, "modifier_sniper_shrapnel_charge_counter", {}) 
		end
		
		if hero:HasAbility("bloodseeker_rupture") then
			for i = 0, hero:GetAbilityCount() - 1 do
				local ability = hero:GetAbilityByIndex(i)
				if ability and ability:GetName() == "bloodseeker_rupture" then
					hero:AddNewModifier(hero, ability, "modifier_bloodseeker_rupture_charge_counter", {})
					hero:SetModifierStackCount("modifier_bloodseeker_rupture_charge_counter", ability, 1)
				end
			end
		end

		if fix_skills[abstract_hero_name] then
			for _, modifier_to_remove in pairs(fix_skills[abstract_hero_name]) do
				hero:RemoveModifierByName(modifier_to_remove)
			end
		end

		if hero:HasAbility("vengefulspirit_nether_swap") then
			local nether_swap = hero:FindAbilityByName("vengefulspirit_nether_swap")
			if nether_swap and nether_swap:GetLevel() < 1 then
				nether_swap:SetLevel(1)
			end
		end
		-------------------------------- Setting stats --------------------------------------
		print("[PickMenu] Setting stats for picked hero")
		PickMenu:_SetHeroStatsFromTable(hero, heroes_table[abstract_hero_name])
		PickMenu:_addHeroname(hero, abstract_hero_name)

		print("[PickMenu] Moving hero to base")
		player.is_picking = false

		print("[PickMenu] End of pick hero for player precache block")
	end)
	print("[PickMenu] End of pick hero for player all")
end

function PickMenu:OpenMenuToPlayer(player, pick_table)
	if not player or not pick_table then return end

	CustomGameEventManager:Send_ServerToPlayer(player ,"pick_menu_start_menu", pick_table)
end

function PickMenu:OpenMenuToAllPlayers(pick_table)
	CustomGameEventManager:Send_ServerToAllClients("pick_menu_start_menu", pick_table)
end

------------------------------------------------------------------------------------------------
------------------------------- Some shit for angel arena! -------------------------------------

function PickMenu:OpenGodsMenu(player)

	local plyid = player:GetPlayerID()
	_G.session = _G.session or {}
	_G.session[plyid] = true;
	PickMenu:OpenMenuToPlayer(player, PickMenu:_ParseGodsMenu() )
end

function PickMenu:OpenRepickMenu(player)

	--PickMenu:OpenMenuToPlayer(player, PickMenu:_GetHeroesForPick() )

	print("[PickMenu] Trying to open repick menu")
end

function PickMenu:CloseRepickMenu(player)
	print("[PickMenu] Trying to close pick menu")
	if not player or not IsValidEntity(player) then return end
	CustomGameEventManager:Send_ServerToPlayer(player ,"pick_menu_close", pick_table)
	print("[PickMenu] Close pick menu success from lua side...")
end

------------------------------------------------------------------------------------------------
------------------------------- Base Functions!	------------------------------------------------

function PickMenu:_ParseGodsMenu()
	local kv_table = LoadKeyValues('scripts/npc/npc_heroes_custom.txt') 
	local return_table = {}
	--[[
	"npc_dota_hero_wisp"
	{
		name 		= "npc_dota_hero_wisp",
		real_name 	= "npc_dota_hero_wisp"
		abilities	= { 	-- max skills = 6! more will cause bugs with panorama
			"wisp_skill_1",		
			"wisp_skill_2",
			"wisp_skill_3",
			"wisp_skill_4",
			"wisp_skill_5",
			"wisp_skill_6",
		},
		base_att 	= 1, 	-- STR[0], AGI[1], INT[2]
		str 		= 10, 	-- base strength
		agi 		= 20, 	-- base agility
		int 		= 12,	-- base intellect
		str_plus	= 1.2, 	-- additional strength per level, dont work because there no command in lua to change additional att per lvl.
		agi_plus	= 2.3, 	-- see top
		int_plus	= 4.2,	-- see top!
		bat 		= 1.7,	-- Base Attack Time. For alchemist ultimate its 1.0, for most standart hereos 1.7
		movespeed 	= 200,	-- some questions for base movespeed?)
		attack 		= 42, 	-- start damage(AVERAGE, max + min / 2)
		picked 		= 0, 	-- is hero already picked? 0 = false, 1 = true
	}
	]]
	for hero_name, value in pairs(kv_table) do 
		if hero_name and value and type(value) == "table" and hero_name ~= "npc_dota_hero_base" and value["IsGod"] then
			return_table[hero_name] = {
				name 		= value["override_hero"],
				real_name 	= hero_name,
				base_att	= PickMenu:GetAttributeNumber(value["AttributePrimary"]),
				abilities 	= {},
				str 		= value["AttributeBaseStrength"],
				agi 		= value["AttributeBaseAgility"],
				int 		= value["AttributeBaseIntelligence"],
				str_plus	= value["AttributeStrengthGain"],
				agi_plus 	= value["AttributeAgilityGain"],
				int_plus	= value["AttributeIntelligenceGain"],
				bat 		= value["AttackRate"],
				movespeed 	= value["MovementSpeed"],
				attack 		= (value["AttackDamageMin"] + value["AttackDamageMax"]) / 2,
				picked 		= 0,
			}

			for i = 1, 6 do 
				local ability_name = value["Ability" .. i]
				if ability_name and ability_name ~= "attribute_bonus" then
					table.insert(return_table[hero_name].abilities, ability_name)
				end
			end

		end
	end

	local hero_list = HeroList:GetAllHeroes() 

	for i, x in pairs(hero_list) do
		if x then
			for j, k in pairs(return_table) do

				if k and k.name == x:GetUnitName() then
					print("hero picked, hero name = ", x:GetUnitName())
					return_table[j].picked = 1
				end
			end
		end
	end
--[[
	for i, x in pairs(_G.tHeroesRadiant) do
		print("Hero:", x:GetUnitName(), " RealName:", x.picked_hero)
		if x.picked_hero and return_table[x.picked_hero] and not IsAbadoned(x) then

			return_table[x.picked_hero].picked = 1;
		end
	end

	for i, x in pairs(_G.tHeroesDire) do
		if x.picked_hero and return_table[x.picked_hero] and not IsAbadoned(x) then
			return_table[x.picked_hero].picked = 1;
			print("Hero:", x:GetUnitName(), " RealName:", x.picked_hero)
		end
	end
	]]
	return return_table;

end


function PickMenu:_MoveToBase(unit)
	local point

	if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		point =  Entities:FindByName( nil, RADIANT_BASE_POINT ):GetAbsOrigin()
		print("moving hero to radiant base")
	elseif unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		point =  Entities:FindByName( nil, DIRE_BASE_POINT ):GetAbsOrigin()
		print("moving hero to dire base")
	end
	
	if not point then return end

	FindClearSpaceForUnit(unit, point, false)
	unit:Stop()
	unit:AddNewModifier(unit, nil, STUN_MODIFIER, {})
end

function PickMenu:_addHeroname(hero, hero_name)
	for i, x in pairs(tHeroesRadiant) do
		if x == hero then
			x.picked_hero = hero_name
			x.GetHeroName = function() 
								return x.hero_name
							end
		end
	end

	for i, x in pairs(tHeroesDire) do
		if x == hero then
			x.picked_hero = hero_name
			x.GetHeroName = function() 
								return x.hero_name
							end
		end
	end
end

function PickMenu:_SetHeroStatsFromTable(hero, stats_table)
	hero:SetBaseStrength (stats_table.str)
	hero:SetBaseAgility  (stats_table.agi)
	hero:SetBaseIntellect(stats_table.int)

	hero:SetBaseMoveSpeed (stats_table.movespeed)	-- wrong on tooltip!
	hero:SetBaseAttackTime(stats_table.bat)			-- wrong on tooltip!
	hero:SetPrimaryAttribute(stats_table.base_att)
	hero:SetBaseDamageMin(stats_table.attack_min)
	hero:SetBaseDamageMax(stats_table.attack_max)
	hero:SetPrimaryAttribute(stats_table.base_att)
end

function PickMenu:_RemoveHeroFromHeroTable(tHeroes, hHero)
	for index, hTempHero in pairs(tHeroes) do
		if hTempHero == hHero then
			table.remove(tHeroes, index)
			print("Removing hero from its table")
		end
	end
end

function PickMenu:_GetHeroesParams()
	local kv_table = LoadKeyValues('scripts/npc/npc_heroes.txt')
	local done_table = {}

	
	for hero_name, value in pairs(kv_table) do 
		if hero_name and value and type(value) == "table" and hero_name ~= "npc_dota_hero_base" and hero_name ~= "npc_dota_hero_target_dummy" then

			done_table[hero_name] = {
				name 		= hero_name,
				real_name 	= hero_name,
				abilities 	= {},
				str 		= 0,
				agi 		= 0,
				int 		= 0,
				str_plus 	= 0,
				agi_plus 	= 0,
				int_plus 	= 0,
				bat 		= 0,
				movespeed 	= 0,
				range		= 0,
				attack_min	= 0,
				attack_max	= 0,
				base_att	= 0,
				picked 		= 0,
			}
			for i = 1, 16 do 
				local ability_name = value["Ability" .. i]
				if ability_name and ability_name~= "attribute_bonus" then
					done_table[hero_name].abilities[i] = ability_name;	
				end
			end

			done_table[hero_name].str 		= value["AttributeBaseStrength"] 		or 0
			done_table[hero_name].agi 		= value["AttributeBaseAgility"] 		or 0
			done_table[hero_name].int 		= value["AttributeBaseIntelligence"] 	or 0
			done_table[hero_name].str_plus 	= value["AttributeStrengthGain"] 		or 0
			done_table[hero_name].agi_plus 	= value["AttributeAgilityGain"] 		or 0
			done_table[hero_name].int_plus 	= value["AttributeIntelligenceGain"] 	or 0
			done_table[hero_name].bat 		= value["AttackRate"] 					or 0
			done_table[hero_name].movespeed = value["MovementSpeed"] 				or 0
			done_table[hero_name].range 	= value["AttackRange"] 					or 0
			done_table[hero_name].attack_min= value["AttackDamageMin"] 				or 0 
			done_table[hero_name].attack_max= value["AttackDamageMax"] 				or 0

			if value["AttributePrimary"] == "DOTA_ATTRIBUTE_STRENGTH" then
				done_table[hero_name].base_att = 0;
			end
			if value["AttributePrimary"] == "DOTA_ATTRIBUTE_AGILITY" then
				done_table[hero_name].base_att = 1;
			end
			if value["AttributePrimary"] == "DOTA_ATTRIBUTE_INTELLECT" then
				done_table[hero_name].base_att = 2;
			end
		end
	end

	kv_table = {} -- delete old info

	--Parse custom heroes and changed default heroes
	kv_table = LoadKeyValues('scripts/npc/npc_heroes_custom.txt') 

	for hero_name, value in pairs(kv_table) do
		if hero_name and value and type(value) == "table" then

			if value["override_hero"] then

				done_table[hero_name] = done_table[hero_name] or {
					name = value["override_hero"],
					real_name 	= hero_name,
					abilities = {},
					str 		= 0,
					agi 		= 0,
					int 		= 0,
					agi_plus 	= 0,
					str_plus 	= 0,
					int_plus 	= 0,
					bat 		= 0,
					movespeed 	= 0,
					attack_min	= 0,
					attack_max 	= 0,
					base_att	= 0,
					picked 		= 0,
				}

				for i = 1, 16 do 
					local ability_name = value["Ability" .. i]
					if ability_name then
						done_table[hero_name].abilities[i] = ability_name;
					end
				end

				done_table[hero_name].str 		= value["AttributeBaseStrength"] 		or done_table[hero_name].str 		or 0
				done_table[hero_name].agi 		= value["AttributeBaseAgility"] 		or done_table[hero_name].agi 		or 0
				done_table[hero_name].int 		= value["AttributeBaseIntelligence"] 	or done_table[hero_name].int 		or 0
				done_table[hero_name].str_plus 	= value["AttributeStrengthGain"] 		or done_table[hero_name].str_plus 	or 0
				done_table[hero_name].agi_plus 	= value["AttributeAgilityGain"] 		or done_table[hero_name].agi_plus 	or 0
				done_table[hero_name].int_plus 	= value["AttributeIntelligenceGain"] 	or done_table[hero_name].int_plus 	or 0
				done_table[hero_name].bat 		= value["AttackRate"] 					or done_table[hero_name].bat 		or 0
				done_table[hero_name].movespeed = value["MovementSpeed"] 				or done_table[hero_name].movespeed 	or 0
				done_table[hero_name].attack_min= value["AttackDamageMin"] 				or done_table[hero_name].attack_min or 0 
				done_table[hero_name].attack_max= value["AttackDamageMax"] 				or done_table[hero_name].attack_max or 0


				if value["AttributePrimary"] == "DOTA_ATTRIBUTE_STRENGTH" then
					done_table[hero_name].base_att = 0;
				end
				if value["AttributePrimary"] == "DOTA_ATTRIBUTE_AGILITY" then
					done_table[hero_name].base_att = 1;
				end
				if value["AttributePrimary"] == "DOTA_ATTRIBUTE_INTELLECT" then
					done_table[hero_name].base_att = 2;
				end
			else
				if done_table[hero_name] then
					done_table[hero_name].str 		= value["AttributeBaseStrength"] 		or done_table[hero_name].str
					done_table[hero_name].agi 		= value["AttributeBaseAgility"] 		or done_table[hero_name].agi
					done_table[hero_name].int 		= value["AttributeBaseIntelligence"] 	or done_table[hero_name].int
					done_table[hero_name].str_plus 	= value["AttributeStrengthGain"] 		or done_table[hero_name].str_plus
					done_table[hero_name].agi_plus 	= value["AttributeAgilityGain"] 		or done_table[hero_name].agi_plus
					done_table[hero_name].int_plus 	= value["AttributeIntelligenceGain"] 	or done_table[hero_name].int_plus
					done_table[hero_name].bat 		= value["AttackRate"] 					or done_table[hero_name].bat
					done_table[hero_name].movespeed = value["MovementSpeed"] 				or done_table[hero_name].movespeed
					done_table[hero_name].attack_min= value["AttackDamageMin"] 				or done_table[hero_name].attack_min or 0 
					done_table[hero_name].attack_max= value["AttackDamageMax"] 				or done_table[hero_name].attack_max or 0

					
					if value["AttributePrimary"] == "DOTA_ATTRIBUTE_STRENGTH" then
						done_table[hero_name].base_att = 0;
					end
					if value["AttributePrimary"] == "DOTA_ATTRIBUTE_AGILITY" then
						done_table[hero_name].base_att = 1;
					end
					if value["AttributePrimary"] == "DOTA_ATTRIBUTE_INTELLECT" then
						done_table[hero_name].base_att = 2;
					end

					for i = 1, 16 do 
						local ability_name = value["Ability" .. i]
						if ability_name then
							done_table[hero_name].abilities[i] = ability_name;
						end
					end
				else
					print("ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!")
				end

			end


		end
	end

	return done_table
end

function PickMenu:GetAttributeNumber( sPrimaryAttribute )
	if sPrimaryAttribute == "DOTA_ATTRIBUTE_STRENGTH" then
		return 0;
	end

	if sPrimaryAttribute == "DOTA_ATTRIBUTE_AGILITY" then
		return 1
	end
	
	if sPrimaryAttribute == "DOTA_ATTRIBUTE_INTELLECT" then
		return 2;
	end
end

function PickMenu:_GetHeroesForPick()
	local kv_table = LoadKeyValues('scripts/npc/npc_heroes.txt')
	local done_table = {}

	
	for hero_name, value in pairs(kv_table) do 
		if hero_name and value and type(value) == "table" and hero_name ~= "npc_dota_hero_base" and hero_name ~= "npc_dota_hero_target_dummy" then

			done_table[hero_name] = {
				name 		= hero_name,
				real_name 	= hero_name,
				abilities 	= {},
				str 		= value["AttributeBaseStrength"] 		or 0,
				agi 		= value["AttributeBaseAgility"] 		or 0,
				int 		= value["AttributeBaseIntelligence"] 	or 0,
				str_plus 	= value["AttributeStrengthGain"] 		or 0,
				agi_plus 	= value["AttributeAgilityGain"] 		or 0,
				int_plus 	= value["AttributeIntelligenceGain"] 	or 0,
				bat 		= value["AttackRate"] 					or 0,
				movespeed 	= value["MovementSpeed"] 				or 0,
				attack 		= ( (value["AttackDamageMin"] or 0) 
											+ (value["AttackDamageMax"] or 0) ) / 2 or 0,
				base_att	= PickMenu:GetAttributeNumber(value["AttributePrimary"]),
				picked 		= 0,
			}
			for i = 1, 6 do 
				local ability_name = value["Ability" .. i];
				
				if ability_name and ability_name~= "attribute_bonus" then
					table.insert(done_table[hero_name].abilities, ability_name);
				end
			end
		end
	end

	kv_table = {} -- delete old info

	--Parse custom heroes and changed default heroes
	kv_table = LoadKeyValues('scripts/npc/npc_heroes_custom.txt') 

	for hero_name, value in pairs(kv_table) do

		if value and type(value) == "table" and value["IsGod"] then	done_table[hero_name] = nil; end -- deleting god's heroes

		if hero_name and value and type(value) == "table" and not value["IsGod"] then

			if value["override_hero"] then
				done_table[hero_name] = done_table[hero_name] or {
					name 		= value["override_hero"],
					real_name 	= hero_name,
					abilities 	= {},
					str 		= 0,
					agi 		= 0,
					int 		= 0,
					agi_plus 	= 0,
					str_plus 	= 0,
					int_plus 	= 0,
					bat 		= 0,
					movespeed 	= 0,
					attack 		= 0,
					base_att	= 0,
					picked 		= 0,
				}
			end

			local counter = 1;
			for i = 1, 6 do 
				local ability_name = value["Ability" .. i];

				if ability_name and ability_name~= "attribute_bonus" then
					done_table[hero_name].abilities[counter] = ability_name;
					counter = counter + 1;
				end
			end

			done_table[hero_name].str 		= value["AttributeBaseStrength"] 		or done_table[hero_name].str or 0
			done_table[hero_name].agi 		= value["AttributeBaseAgility"] 		or done_table[hero_name].agi or 0
			done_table[hero_name].int 		= value["AttributeBaseIntelligence"] 	or done_table[hero_name].int or 0
			done_table[hero_name].str_plus 	= value["AttributeStrengthGain"] 		or done_table[hero_name].str_plus or 0
			done_table[hero_name].agi_plus 	= value["AttributeAgilityGain"] 		or done_table[hero_name].agi_plus or 0
			done_table[hero_name].int_plus 	= value["AttributeIntelligenceGain"] 	or done_table[hero_name].int_plus or 0
			done_table[hero_name].bat 		= value["AttackRate"] 					or done_table[hero_name].bat or 0
			done_table[hero_name].movespeed = value["MovementSpeed"] 				or done_table[hero_name].movespeed or 0
			done_table[hero_name].attack 	= ( (value["AttackDamageMin"] or 0) 
											  + (value["AttackDamageMax"] or 0) ) / 2 or done_table[hero_name].attack or 0
			done_table[hero_name].base_att 	= PickMenu:GetAttributeNumber(value["AttributePrimary"]) or done_table[hero_name].base_att or 0;

		end
	end

	for i, x in pairs(_G.tHeroesRadiant) do
		print("Hero:", x:GetUnitName(), " RealName:", x.picked_hero)
		if x.picked_hero and done_table[x.picked_hero] and not IsAbadoned(x)  then
			done_table[x.picked_hero].picked = 1;
		end
	end

	for i, x in pairs(_G.tHeroesDire) do
		if x.picked_hero and done_table[x.picked_hero] and not IsAbadoned(x) then
			done_table[x.picked_hero].picked = 1;
			print("Hero:", x:GetUnitName(), " RealName:", x.picked_hero)
		end
	end

	return done_table
end

function PickMenu:IsHeroAlreadyPicked( abstract_hero_name )
	for _, hero in pairs(_G.tHeroesRadiant) do
		if hero.picked_hero == abstract_hero_name and not IsAbadoned(hero) then
			return true
		end
	end

	for _, hero in pairs(_G.tHeroesDire) do
		if hero.picked_hero == abstract_hero_name and not IsAbadoned(hero) then
			return true
		end
	end

	return false 
end

function PickMenu:_init()
	print("[PickMenu] Init custom pick menu")
	--CustomGameEventManager:RegisterListener("pick_menu_player_load",	Dynamic_Wrap(PickMenu, "OnPlayerLoadPickMenu"))
	CustomGameEventManager:RegisterListener("pick_menu_onpick",			Dynamic_Wrap(PickMenu, "OnHeroCustomPick"))
	CustomGameEventManager:RegisterListener("pick_menu_onpickrandom",	Dynamic_Wrap(PickMenu, "PickRandomHero"))
	CustomGameEventManager:RegisterListener("pick_menu_menu_closed",	Dynamic_Wrap(PickMenu, "OnMenuClosed"))

	--1ListenToGameEvent('player_connect_full', 							Dynamic_Wrap(PickMenu, 'OnConnectFull'), self)
	LinkLuaModifier( "modifier_stun",				'modifiers/modifier_stun', 				LUA_MODIFIER_MOTION_NONE )
	
	if not DEFAULT_HERO_PICK or not RADIANT_BASE_POINT or not DIRE_BASE_POINT or not STUN_MODIFIER then 
		print("[PickMenu] ERROR: SOME CONSTANT IS UNDEFINED!") 
	else
		print("[PickMenu] Init custom pick menu success")
	end
end


function PickMenu:OnConnectFull( keys )
	local entIndex 		= keys.index+1
    local player 		= EntIndexToHScript(entIndex)
    local playerID 		= player:GetPlayerID()
   

	if not player or not playerID then return end

	print_d("onconnectfull pick menu, pid=" .. playerID)
--[[
   	Timers:CreateTimer(0.03, function() 
   		if GameRules:State_Get() <= DOTA_GAMERULES_STATE_HERO_SELECTION then return 0.1 end


	   	if not PickMenu:IsPlayerPickHero( playerID ) then
	   		Timers:CreateTimer(3, function()
	   				
	   				if PickMenu:IsPlayerPickHero( playerID ) then 
	   					return nil 
	   				else
	   					PickMenu:OnPlayerLoadPickMenu( {playerID = playerID} )	
	   				end

	   				return 3
	   			end)
	   	end

	   	print_d("force replace hero to kuru")


	   	if playerid_that_connect[playerID] then 
	   		print_d("player already have forced kura! ebana vrot!")

	   		if(player:GetAssignedHero()) then
	   			return nil; 
	   		end
	   	end

	   	playerid_that_connect[playerID] = true;
	   	print_d("delayem iz cheloveka kuricu")

	   	if player then
		   	local hero = CreateHeroForPlayer(DEFAULT_HERO_PICK, player)
		   	Timers:CreateTimer(2, function() 
		   		if hero and not hero:IsNull() then
		    		hero:AddNoDraw() 
		    		hero:AddNewModifier(hero, nil, STUN_MODIFIER, {})
		    		PickMenu:_RemoveHeroFromHeroTable(_G.tHeroesRadiant, hero)
					PickMenu:_RemoveHeroFromHeroTable(_G.tHeroesDire, hero)

					if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
						point =  Entities:FindByName( nil, RADIANT_BASE_POINT ):GetAbsOrigin()
						print("moving hero to radiant base")
					elseif hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
						point =  Entities:FindByName( nil, DIRE_BASE_POINT ):GetAbsOrigin()
						print("moving hero to dire base")
					end
				
					if not point then return nil end

					FindClearSpaceForUnit(hero, point, false)
				end

				
		    end)
		else 
			playerid_that_connect[playerID] = false;
			return 2;
	   	end

	   	return nil;
	end)
]]
end

function PickMenu:OnPlayerLoadPickMenu( keys )
	print("[PickMenu] OnPlayerLoadPickMenu")
	
	local playerid 		= keys.playerID
	print("onplayerloadmenu pid = ",playerid)
	if not playerid then return end

	local player 		= PlayerResource:GetPlayer(playerid)

	local heroes_table 	= PickMenu:_GetHeroesForPick();
	print("--------OnPlayerLoadPickMenu pre")
	if player:GetTeamNumber() ~= DOTA_TEAM_GOODGUYS and player:GetTeamNumber() ~= DOTA_TEAM_BADGUYS then return end
	if not player or not IsValidEntity(player) or not PlayerResource:IsValidPlayer(playerid) then return end
	print("OnPlayerLoadMenu, pid = ", playerid)
	print("isplayerpickhero?", playerid_that_pick[playerid])

	if not playerid_that_pick[playerid] then
		print("[PickMenu] Player already pick hero!")
		if(not player.is_picking) then
			CustomGameEventManager:Send_ServerToPlayer(player ,"pick_menu_start_menu", heroes_table)
		end
	else 
		print("[PickMenu] Already picked, close pick menu")
		CustomGameEventManager:Send_ServerToPlayer(player ,"pick_menu_close", {}) -- because on start pick menu is active!
	end
end

function PickMenu:IsPlayerPickHero( playerid )
	local player = PlayerResource:GetPlayer(playerid)
	local hero = player: GetAssignedHero() 

	if hero and hero:GetUnitName() == DEFAULT_HERO_PICK and not player.is_picking then 
		playerid_that_pick[playerid] = false;
		return false 
	end

	if player.is_picking == false and hero:GetUnitName() ~= DEFAULT_HERO_PICK then 
		playerid_that_pick[playerid] = true
		return true 
	end

	return playerid_that_pick[playerid]
end

function PickMenu:OnHeroCustomPick( keys )
	print("[PM] OnHeroCustomPick")

	local playerid 		= keys.playerID
	local hero_name		= keys.hero
	local player 		= PlayerResource:GetPlayer(playerid)
	print("[PM] HERO = ", hero_name)

	playerid_that_pick[playerid] = true

	--PlayerResource:ReplaceHeroWith( playerid, hero_name, 600, 0 )
	player.is_picking = true

	Timers:CreateTimer(RandomFloat(0.01, 1.35), function()
		PickMenu:PickHeroForPlayer(playerid, hero_name)
	end)

	--CustomGameEventManager:Send_ServerToAllClients( "pick_menu_disable_hero", data )
end


function PickMenu:HasForbiddenModifier(unit)
	print("Has forbiddenn modifier?")
	for _, modifier_name in pairs(forbidden_modifiers) do
		if unit:HasModifier(modifier_name) then
			print("HAS MODIFIER!")
			return true
		end
	end

	print("NOT HAS MODIFIER")
	return false

end

function IsAbadoned(unit)
    if not unit or not IsValidEntity(unit) then
    	return false 
    end

    local playerid = unit:GetPlayerOwnerID()
    if not playerid then 
    	return false 
    end

    local connection_state = PlayerResource:GetConnectionState(playerid) 

    if connection_state == DOTA_CONNECTION_STATE_ABANDONED then 
        return true 
    else 
        return false
    end
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

function print_d(text)
	CustomGameEventManager:Send_ServerToAllClients("DebugMessage", { msg = text})
end

PickMenu:_init()

