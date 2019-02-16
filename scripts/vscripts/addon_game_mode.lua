--[[
-----------------------------------------
Creator: CryDeS
If somebody read this, KILL ME PLEASE
-----------------------------------------
]]

require('spawners')
require('tp_s')
--require('change_hero')
--require('items/shop')
require('lib/teleport')
require('lib/duel_lib')
require('pick_menu')
require('lib/percent_damage')
require('lib/magic_lifesteal')
require('lib/util')
require('lib/utils')
require('lib/creep_spawner')
require('lib/captains_mode')
require('lib/timers')
require('lib/chat_listener')
require('lib/debug/geometrics')
require('lib/replicapable')
require('lib/token')

-- Список модулей которые нужно загружать в InitGameMode, а не при создании VM'ки 
local postRequireList = {
    'lib/base/player',
    'lib/base/base_npc'
}


local Constants = require('consts') -- XP TABLE
local armor_table = require('creeps/armor_table_summon') -- armor to units
--local items_cost 			= require('lib/test') 

MAX_LEVEL = 100

RESPAWN_MODIFER = 0.135
GOLD_PER_TICK = 4.5

HEROKILL_BONUS_GOLD = 100
DUEL_WINNER_GOLD_MULTIPLER = 150
DUEL_WINNER_EXP_MULTIPLER = 75
DUEL_GOLD_PER_MINUTE = 40
DUEL_INTERVAL = 300
DUEL_NOBODY_WINS = 90

GOLD_FOR_COUR = 350

_G.killLimit = 20


_G.nCOUNTDOWNTIMER = DUEL_INTERVAL

_G.tPlayers = {}
_G.tHeroesRadiant = {}
_G.tHeroesDire = {}
_G.Kills = {}
_G.duel_come = false

local is_game_start = false
local is_game_end = false
local is_rune_picked = false

local KillLimit_Vote = {}

local runes = { 0, 1, 2, 3, 4 }

local ban_steam_ip = {
    [163227098] = 1,
    [162720331] = 1,
}

local crash_abilities = {
    ["shadow_demon_disruption"] = 1,
    ["obsidian_destroyer_astral_imprisonment"] = 1,
    ["rubick_telekinesis"] = 1,
    ["disruptor_thunder_strike"] = 1,
}

local forbidden_ability_boss = {
    ["life_stealer_infest"] = 1,
    ["chen_holy_persuasion"] = 1,
    ["enchantress_enchant"] = 1,
    ["item_devour_helm"] = 1,
}

local not_amplify_skills = {
    ["item_rubick_dagon"] = 1,
    ["item_ethereal_blade"] = 1,
    ["lone_druid_spirit_bear"] = 1,
    ["obsidian_destroyer_arcane_orb"] = 1,
}

local forbidden_items_for_clones = {
    ["item_pet_hulk"] = 1,
    ["item_pet_mage"] = 1,
    ["item_pet_wolf"] = 1,
    ["item_refresher"] = 1,
    ["item_recovery_orb"] = 1,
    ["item_soul_vessel"] = 1,
}

local illusion_bug_crash =
{
    ["npc_dota_hero_visage"] = 1,
    ["npc_dota_hero_weaver"] = 1,
}

--local sniper_1skill_damage_decrease =
--{
--	["item_javelin"] = 3,
--	["item_monkey_king_bar"] = 3,
--	["item_maelstrom"] = 2,
--	["item_mjollnir"] = 3,
--	["item_mjollnir_2"] = 3,
--}

if AngelArena == nil then
    _G.AngelArena = class({})
    AngelArena.DeltaTime = 0.5
end

function Activate()
    GameRules.AngelArena = AngelArena()
    GameRules.AngelArena:InitGameMode()
end

function Precache(context)
end

function AngelArena:InitGameMode()
    for _, moduleName in pairs(postRequireList) do
        require(moduleName)
    end

    local GameMode = GameRules:GetGameModeEntity()

    GameRules:SetCustomVictoryMessage("Victory. For the bless of gods")

    --GameRules:SetSafeToLeave(true)

    GameRules:SetPreGameTime(60) -- old 90

    if GetMapName() == "map_5x5_cm" then
        GameRules:SetHeroSelectionTime(50)
        GameRules:SetStrategyTime(10)
    else
        GameMode:SetDraftingHeroPickSelectTimeOverride(60)
        GameMode:SetDraftingBanningTimeOverride(20)
        GameRules:SetStrategyTime(15.0)
        GameRules:SetHeroSelectionTime(90) -- old 60
    end

    GameRules:SetPostGameTime(30)

    if GameRules:IsCheatMode() then
        GameRules:SetHeroSelectionTime(25)
        GameRules:SetStrategyTime(1)
        GameMode:SetDraftingHeroPickSelectTimeOverride(25)
        GameMode:SetDraftingBanningTimeOverride(0)
    end

    GameRules:SetGoldPerTick(GOLD_PER_TICK)

    GameRules:SetHeroRespawnEnabled(true)
    GameRules:SetGoldTickTime(1)
    GameRules:SetShowcaseTime(0.0)
    GameRules:SetTreeRegrowTime(180)
    GameRules:SetUseBaseGoldBountyOnHeroes(true)
    for i = 0, 11 do
        GameMode:SetRuneEnabled(i, true)
    end

    --GameRules:SetRuneSpawnTime(120)

    GameRules:SetCustomGameEndDelay(1)
    GameRules:GetGameModeEntity():SetFountainPercentageHealthRegen(7)
    GameRules:GetGameModeEntity():SetFountainPercentageManaRegen(10)
    GameRules:GetGameModeEntity():SetFountainConstantManaRegen(20)
    --GameMode:SetCustomHeroMaxLevel(MAX_LEVEL)
    GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(Constants.XP_PER_LEVEL_TABLE)
    --GameMode:SetTopBarTeamValuesVisible(false)
    GameMode:SetBuybackEnabled(true)
    GameMode:SetStashPurchasingDisabled(false)
    GameMode:SetLoseGoldOnDeath(true)
    --GameMode:SetTopBarTeamValuesOverride ( true )
    --GameMode:SetTopBarTeamValuesVisible( true )
    GameRules:SetUseUniversalShopMode(true)
    GameRules:SetSameHeroSelectionEnabled(false)

    -- Valve never fix it. 
    --GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_MAGIC_RESISTANCE_PERCENT, 0)
    --GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_STATUS_RESISTANCE_PERCENT, 0)
    --GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP_REGEN, 0)
    --GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_MOVE_SPEED_PERCENT, 0)
    --GameMode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MAGIC_RESISTANCE_PERCENT, 0)

    if GetMapName() == "map_10x10" then
        GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 10)
        GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 10)
    else
        GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 5)
        GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 5)
    end

    --################################## BASE LISTENERS ############################################### --
    ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(AngelArena, "OnHeroPicked"), self)
    ListenToGameEvent("entity_killed", Dynamic_Wrap(AngelArena, "OnEntityKilled"), self)
    ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(AngelArena, 'OnGameStateChange'), self)
    ListenToGameEvent('player_connect_full', Dynamic_Wrap(AngelArena, 'OnConnectFull'), self)
    ListenToGameEvent('player_disconnect', Dynamic_Wrap(AngelArena, 'OnPlayerDisconnect'), self)
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(AngelArena, 'OnNPCSpawned'), self)
    ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(AngelArena, 'OnPickUpItem'), self)
    ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(AngelArena, 'OnRuneActivate'), self)
    ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(AngelArena, 'OnPlayerUsedAbility'), self)
    ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(AngelArena, 'OnPlayerBuyItem'), self)
    ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(AngelArena, 'OnLevelUp'), self)

    ListenToGameEvent("player_chat", Dynamic_Wrap(ChatListener, 'OnPlayerChat'), ChatListener)

    --################################## CUSTOM LISTENERS ############################################### --

    CustomGameEventManager:RegisterListener("PlayerVoteKills", Dynamic_Wrap(AngelArena, 'OnVoteForKillLimit'))

    --################################## BASE MODIFIERS ############################################### --
    LinkLuaModifier("modifier_stun", 'modifiers/modifier_stun', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_dissapear", 'modifiers/modifier_dissapear', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_stop", 'modifiers/modifier_stop', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_medical_tractate", 'modifiers/modifier_medical_tractate', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_boss_power", 'modifiers/modifier_boss_power', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_tester", 'modifiers/modifier_tester', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_dcp_tester", 'modifiers/modifier_dcp_tester', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_sheo_dev", 'modifiers/modifier_sheo_dev', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_godmode", 'modifiers/modifier_godmode', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_banned_custom", 'modifiers/banned/modifier_banned_custom', LUA_MODIFIER_MOTION_NONE)
    -- HACK!
    --LinkLuaModifier( "modifier_antivalve_perks",	'modifiers/modifier_antivalve_perks',	LUA_MODIFIER_MOTION_NONE )
    LinkLuaModifier("modifier_antivalve_perks", 'modifiers/anti_perks/modifier_antivalve_perks', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_antivalve_perks_main_attribute", 'modifiers/anti_perks/modifier_antivalve_perks_main_attribute', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_antivalve_perks_moovespeed", 'modifiers/anti_perks/modifier_antivalve_perks_moovespeed', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_antivalve_perks_mag_resist", 'modifiers/anti_perks/modifier_antivalve_perks_mag_resist', LUA_MODIFIER_MOTION_NONE)

    --################################## RUNES MODIFIERS ############################################### --
    LinkLuaModifier("modifier_rune_dd_one", 'modifiers/modifier_rune_dd_one', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_rune_dd_two", 'modifiers/modifier_rune_dd_two', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_rune_dd_three", 'modifiers/modifier_rune_dd_three', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_rune_haster_max", 'modifiers/modifier_rune_haster_max', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_rune_illusion_one", 'modifiers/modifier_rune_illusion_one', LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_rune_illusion_two", 'modifiers/modifier_rune_illusion_two', LUA_MODIFIER_MOTION_NONE)

    --################################## SUMMON MODIFIERS ############################################### --
    -- Moved to armor_table_summon.lua
    -- LinkLuaModifier( "modifier_summon",'modifiers/heroes/modifier_summon', LUA_MODIFIER_MOTION_NONE )

    --################################## ITEMS MODIFIERS ############################################### --
    LinkLuaModifier("modifier_item_reverse", 'modifiers/items/modifier_item_reverse', LUA_MODIFIER_MOTION_NONE)

    --################################### END MODIFIERS ################################################ --
    Convars:RegisterCommand("radiant_list", function(...) return PrintPlayers(tHeroesRadiant) end, "Function Call 2", 0)
    Convars:RegisterCommand("dire_list", function(...) return PrintPlayers(tHeroesDire) end, "Function Call 3", 0)

    --########################################## FILTERS ############################################### --
    GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(AngelArena, "OrderFilter"), self)
    GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(AngelArena, "GoldFilter"), self)
    GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(AngelArena, "DamageFilter"), self)
    GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(AngelArena, "ModifierGainedFilter"), self)
    GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(AngelArena, "ModifierExpirience"), self)
    GameRules:GetGameModeEntity():SetRuneSpawnFilter(Dynamic_Wrap(AngelArena, "ModifierRuneSpawn"), self)

    _G.Kills[DOTA_TEAM_GOODGUYS] = _G.Kills[DOTA_TEAM_GOODGUYS] or 0
    _G.Kills[DOTA_TEAM_BADGUYS] = _G.Kills[DOTA_TEAM_BADGUYS] or 0
    _G.KillLimit = _G.KillLimit or 0

    --########################################## START FUNCS ########################################### --


    --	StartAntiCampSystem()

    Replicapable:s_tick()

    AngelArena:OnGameStateChange()

    SendToConsole("dota_shop_recommended_open 1")
end


function AngelArena:ModifierRuneSpawn(keys)
    local rune_type = keys.rune_type

    if rune_type == 5 then return true end

    keys.rune_type = runes[RandomInt(1, #runes)]

    return true
end

function AngelArena:OnPlayerDisconnect(event)
    local name = event.name
    local networkid = event.networkid
    local reason = event.reason
    local userid = event.userid

    print_d(name)
    print_d(networkid)
    print_d(reason)
    print_d(userid)
end

function AngelArena:GoldFilter(event)
    if event.reason_const == 12 then
        local time = GameRules:GetGameTime() / 60
        local k = 0.5

        if time > 10 then
            time = time - 10

            k = 1 + 0.15 * (time / 5)
        end

        event["gold"] = event["gold"] + HEROKILL_BONUS_GOLD * k
        print("gold = ", event["gold"])
    end

    return true
end

function SaveGoldForPlayerId(playerid)
    if not PlayerResource:IsValidPlayerID(playerid) then return end

    local player_gold = PlayerResource:GetGold(playerid)

    if not IsAbadonedPlayerID(playerid) then
        tPlayers[playerid] = tPlayers[playerid] or {} -- nil error exception
        tPlayers[playerid].gold = tPlayers[playerid].gold or 0 -- nil error exception

        if player_gold > 80000 then
            local gold_to_save = player_gold - 80000
            tPlayers[playerid].gold = tPlayers[playerid].gold + gold_to_save
            PlayerResource:SpendGold(playerid, gold_to_save, 0)
        end

        if player_gold < 80000 then
            local free_gold = 80000 - player_gold
            local total_saved_gold = tPlayers[playerid].gold
            if total_saved_gold > free_gold then
                tPlayers[playerid].gold = tPlayers[playerid].gold - free_gold
                PlayerResource:ModifyGold(playerid, free_gold, true, 0)
            else
                PlayerResource:ModifyGold(playerid, total_saved_gold, true, 0)
                tPlayers[playerid].gold = 0
            end
        end

        local total_gold = PlayerResource:GetGold(playerid) + tPlayers[playerid].gold -- почему не player_gold? потому что золото игрока изменилось, а эта переменная нет :c

        CustomNetTables:SetTableValue("gold", "player_id_" .. playerid, { gold = total_gold })
    end
end

function AngelArena:OrderFilter(event)
    local order_type = event.order_type
    local iAbility = event.entindex_ability
    local units_table = event.units
    local iUnit = event.units["0"]
    local player_id = event.issuer_player_id_const
    local player = PlayerResource:GetPlayer(player_id)
    local remove_tbl_idx = {}

    --for i,x in pairs(event) do print( i,x ) end

    if units_table and type(units_table) == "table" and player and not GameRules:IsCheatMode() then
        for idx, entUnit in pairs(units_table) do
            local unit = EntIndexToHScript(entUnit)

            if player:GetTeamNumber() ~= unit:GetTeamNumber() then ForceStopUnit(unit); end

            if (unit.personal) then
                if (player_id ~= unit.personal and not (PlayerResource:AreUnitsSharedWithPlayerID(unit.personal, player_id))) then
                    remove_tbl_idx[idx] = true
                end
            end
        end
    end

    for idx, _ in pairs(remove_tbl_idx) do
        local unit_s = event["units"]

        DeepPrint(unit_s)
        table.remove(unit_s, unit_s["0"])
        unit_s[idx .. ""] = nil
        DeepPrint(unit_s)
    end


    if order_type == DOTA_UNIT_ORDER_CAST_TARGET then
        local caster
        for i, x in pairs(event.units) do
            if x then
                caster = EntIndexToHScript(x)
            end
        end

        local ability = EntIndexToHScript(event.entindex_ability)
        local target = EntIndexToHScript(event.entindex_target)
        local caster_id = caster:GetPlayerOwnerID()
        local target_id = target:GetPlayerOwnerID()

        if PlayerResource:IsDisableHelpSetForPlayerID(target_id, caster_id) then
            ForceStopUnit(caster)
        end

        if forbidden_ability_boss[ability:GetName()] and IsUnitBossGlobal(target) then
            ForceStopUnit(caster)
        end

        if target:HasAbility("wisp_tether") and ability:GetName() == "wisp_tether" then return end

        if caster == target and ability:GetName() == "rubick_spell_steal" then
            ForceStopUnit(caster)
        end
    end


    if iAbility and iUnit and type(iUnit) == "number" then
        local hAbility = EntIndexToHScript(iAbility)
        if not hAbility then return true end
        local sAbilityName = hAbility:GetName()
        local hCaster = EntIndexToHScript(iUnit)

        if hCaster and hCaster.IsIllusion and hCaster:IsIllusion() and sAbilityName == "omniknight_guardian_angel" then
            return false
        end
    end

    return true
end

function ForceStopUnit(unit)
    if not unit then return end
    unit:AddNewModifier(unit, nil, "modifier_stop", { duration = 0.01 })
end

function AngelArena:OnPlayerBuyItem(event)
    local playerid = event.PlayerID
    local item_name = event.itemname
    local itemcost = event.itemcost
    local player = PlayerResource:GetPlayer(playerid)
    local hero = player:GetAssignedHero()

    SaveGoldForPlayerId(playerid)
end

function AngelArena:OnPlayerUsedAbility(event)
    local player = PlayerResource:GetPlayer(event.PlayerID)
    local ability_name = event.abilityname
    if not player or not ability_name or not IsValidEntity(player) then return end
    local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)

    if not hero then return end

    if crash_abilities[ability_name] then
        player.crash_timer = 6.0
        Timers:CreateTimer(1.0, function()

            if player.crash_timer == nil or player.crash_timer <= 0 then
                player.crash_timer = nil;
                return nil;
            end
            player.crash_timer = player.crash_timer - 1

            return 1.0
        end)
    end
end

function AngelArena:OnVoteForKillLimit(keys)
    local select_limit = keys.SelectedValue;
    local number = tonumber(select_limit)

    if (number > 200 or number < 50) then return end

    if not select_limit then return end
    KillLimit_Vote[select_limit] = KillLimit_Vote[select_limit] or 0
    KillLimit_Vote[select_limit] = KillLimit_Vote[select_limit] + 1
end

function PrintPlayers(tbl)
    for i, x in pairs(tbl) do
        if x then
            print("i=" .. i .. " player=" .. x:GetUnitName())
        else
            print("i=" .. i .. " player=" .. x)
        end
    end
end

--function StartAntiCampSystem()
--    local fountains = Entities:FindAllByClassname('ent_dota_fountain')
--
--    for _, fountain in pairs(fountains) do
--   		fountain:AddAbility("angel_arena_fountain")
--
--	    local ab = fountain:FindAbilityByName("angel_arena_fountain")
--
--	    if ab then
--	        ab:SetLevel(1)
--		end
--	end
--end

function AngelArena:OnRuneActivate(event)
    local runeid = event.rune
    local playerid = event.PlayerID
    local hero = PlayerResource:GetPlayer(playerid):GetAssignedHero()

    if not hero then return end

    if runeid == DOTA_RUNE_DOUBLEDAMAGE then
        if hero:HasItemInInventory("item_kings_bar") or hero:HasItemInInventory("item_rapier") then -- +60% damage
            hero:AddNewModifier(hero, nil, "modifier_rune_dd_one", { duration = 30 })
        end

        if RollPercentage(10) then -- +400% damage
            hero:AddNewModifier(hero, nil, "modifier_rune_dd_two", { duration = 30 })
        end

        if RollPercentage(10) then -- +20% damage resist
            hero:AddNewModifier(hero, nil, "modifier_rune_dd_three", { duration = 30 })
        end
    end

    if runeid == DOTA_RUNE_BOUNTY then
        local multiplier = 1

        local constant_gold_for_minute = 35
        local constant_gold_double_midas = 200 + constant_gold_for_minute * GameRules:GetGameTime() / 80
        local constant_gold_one_midas = 200 + constant_gold_for_minute * GameRules:GetGameTime() / 120

        local time = GameRules:GetTimeOfDay() / 60

        if hero:GetUnitName() == "npc_dota_hero_alchemist" then multiplier = 2 end

        if hero:HasItemInInventory("item_advanced_midas") then
            hero:ModifyGold(constant_gold_double_midas * multiplier, false, 0)
            if RollPercentage(20) then
                hero:ModifyGold(constant_gold_double_midas * multiplier, false, 0)
            end
        end

        if hero:HasItemInInventory("item_hand_of_midas") then
            hero:ModifyGold(constant_gold_one_midas * multiplier, false, 0)
        end

        if RollPercentage(20) or is_rune_picked == false then
            local level = hero:GetLevel()
            local need_exp = Constants.XP_PER_LEVEL_TABLE[level + 1]
            local old_exp = Constants.XP_PER_LEVEL_TABLE[level]
            if not need_exp then need_exp = 0 end
            if not old_exp then old_exp = 0 end
            hero:HeroLevelUp(true)
            hero:AddExperience(need_exp - old_exp, 0, true, true)
            is_rune_picked = true
        end
    end

    if runeid == DOTA_RUNE_ILLUSION then
        hero:AddNewModifier(hero, nil, "modifier_rune_illusion_one", { duration = 30 }) -- 30%dmg, +20mvspd
        if RollPercentage(40) then
            hero:AddNewModifier(hero, nil, "modifier_rune_illusion_two", { duration = 30 }) --+15dmg resist
        end
    end

    if runeid == DOTA_RUNE_HASTE then
        if RollPercentage(20) then
            hero:AddNewModifier(hero, nil, "modifier_rune_haster_max", { duration = 40 }) --glimmers cape modifier
        end
    end

    if runeid == DOTA_RUNE_INVISIBILITY then
        if RollPercentage(20) then
            hero:AddNewModifier(hero, nil, "modifier_rune_haste", { duration = 40 }) --glimmers cape modifier
        end
    end

    local item
    for i = 0, 5 do
        item = hero:GetItemInSlot(i)
        if item and item:GetPurchaser() == hero then
            if item and (item:GetName() == "item_power_amulet" or item:GetName() == "item_mystic_amulet" or item:GetName() == "item_strange_amulet") then
                item:SetCurrentCharges(item:GetCurrentCharges() + 1)
                return
            end
        end
    end

    item = nil

    for i = DOTA_ITEM_SLOT_7, DOTA_ITEM_SLOT_9 do
        item = hero:GetItemInSlot(i)
        if item and item:GetPurchaser() == hero then
            if item and (item:GetName() == "item_power_amulet" or item:GetName() == "item_mystic_amulet" or item:GetName() == "item_strange_amulet") then
                item:SetCurrentCharges(item:GetCurrentCharges() + 1)
                return
            end
        end
    end
end

function AngelArena:OnPickUpItem(event)
    if not event.ItemEntityIndex then return end
    local unit
    if event.HeroEntityIndex then unit = EntIndexToHScript(event.HeroEntityIndex) end
    if event.UnitEntityIndex then unit = EntIndexToHScript(event.UnitEntityIndex) end
    local item = EntIndexToHScript(event.ItemEntityIndex)

    if not unit or not item then return end

    if unit:IsCourier() then
        if item:GetOwnerEntity() == unit and item:GetPurchaser() == unit then
            UTIL_Remove(item)
        end
    end

    if unit then
        if IsUnitBear(unit) then
            if item:GetPurchaser() == unit then
                local hero_owner = unit:GetOwnerEntity()
                item:SetPurchaser(hero_owner)
            end
        end
    end
end

function AngelArena:OnNPCSpawned(event)

    local spawnedUnit = EntIndexToHScript(event.entindex)
    if not spawnedUnit then return end

    local unitname = spawnedUnit:GetUnitName()
    local unit_owner = spawnedUnit:GetOwnerEntity()

    if spawnedUnit:IsHero() then
        -- Valve perks HACK
        if not spawnedUnit:HasModifier("modifier_antivalve_perks") then
            Timers:CreateTimer(0.3, function()
                spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_antivalve_perks", { duration = -1 })
                return nil
            end)
        end
    end

    if spawnedUnit:IsRealHero() then
        OnHeroRespawn(spawnedUnit)
    end

    --[[ COMMENTED, BECAUSE CHANGE TEAM ITEM DELETED
    if not spawnedUnit:IsHero() and not GameRules:IsCheatMode() then
        if spawnedUnit:GetOwnerEntity() then
            spawnedUnit:SetTeam(spawnedUnit:GetOwnerEntity():GetTeamNumber() )
        end
    end

    if unit_owner and not unitname == "npc_dota_courier" then
        local owner_team = unit_owner:GetTeamNumber()

        if owner_team then spawnedUnit:SetTeam(owner_team) end
    end
    ]]

    if spawnedUnit:HasAbility("summons_attack_magical") then
        spawnedUnit:FindAbilityByName("summons_attack_magical"):SetLevel(1)
    end



    if unitname == "npc_dota_invoker_forged_spirit" then
        Timers:CreateTimer(0.15, function()
            spawnedUnit:SetHealth(9999999) -- full heal
            return nil
        end)
    end

    for i = 1, 7 do
        local f_name = "npc_dota_venomancer_plague_ward_" .. tostring(i)
        if unitname == f_name then
            local poison_ability_venom = spawnedUnit:GetOwner():GetAbilityByIndex(1)
            local cleave_ability = spawnedUnit:FindAbilityByName("venomancer_ward_cleave")
            if cleave_ability then
                cleave_ability:SetLevel(1)
            end
            if poison_ability_venom:GetLevel() > 0 then
                local poison_ability = spawnedUnit:FindAbilityByName("venomancer_poison_sting")
                if poison_ability then
                    poison_ability:SetLevel(poison_ability_venom:GetLevel())
                end
            end
        end
    end

    if IsUnitBear(spawnedUnit) then
        local ability

        local bear_abilities = 
        {
            ["separation_of_souls_bear"] = 1,
            ["lone_druid_spirit_bear_defender"] = 1,
        }

        for i = 0, spawnedUnit:GetAbilityCount() - 1 do
            ability = spawnedUnit:GetAbilityByIndex(i)

            if ability and bear_abilities[ ability:GetName() ] then
                ability:SetLevel(1)
            end
        end
    end

    if armor_table[unitname] then -- see file creeps/armor_table_summon.lua for details
        spawnedUnit:AddNewModifier(spawnedUnit, nil, armor_table[unitname], {})
    end

    --[[
    if (unitname == "npc_dota_techies_land_mine" or unitname == "npc_dota_techies_remote_mine" or unitname == "npc_dota_techies_stasis_trap" or unitname == "npc_dota_thinker") and not DuelLibrary:IsDuelActive() then
        local pos = spawnedUnit:GetAbsOrigin()
        local duel_pos1 = Entities:FindByName(nil, "RADIANT_DUEL_TELEPORT"):GetAbsOrigin();
        local duel_pos2 = Entities:FindByName(nil, "DIRE_DUEL_TELEPORT"):GetAbsOrigin();
        local entities = Entities:FindAllInSphere(pos, 10)

        for i,x in pairs(entities) do
            if x:GetName() == "trigger_box_duel" then
                UTIL_Remove(spawnedUnit)
                print("removed unit")
            end
        end

        if math.abs((pos - duel_pos1):Length2D()) < 700 or (math.abs((pos - duel_pos2):Length2D() )  < 700 ) then
            UTIL_Remove(spawnedUnit)

        end
    end
    ]]

    if spawnedUnit:IsIllusion() and spawnedUnit:IsHero() then
        local originals = Entities:FindAllByName(unitname)
        local done = false
        for i, original_hero in pairs(originals) do
            if original_hero ~= spawnedUnit and not original_hero:IsIllusion() then


                -- потому что дота уходит в окно если дать одну из этих абилок герою визаж или герою вивер
                if not illusion_bug_crash[spawnedUnit:GetUnitName()] then
                    local ability
                    for i = 0, spawnedUnit:GetAbilityCount() - 1 do
                        ability = spawnedUnit:GetAbilityByIndex(i)
                        if ability then spawnedUnit:RemoveAbility(ability:GetAbilityName()) end
                    end
                    for i = 0, original_hero:GetAbilityCount() - 1 do
                        ability = original_hero:GetAbilityByIndex(i)
                        if ability then spawnedUnit:AddAbility(ability:GetAbilityName()) end
                    end
                end

                local str = original_hero:GetBaseStrength() - (original_hero:GetLevel() - 1) * original_hero:GetStrengthGain()
                local agi = original_hero:GetBaseAgility() - (original_hero:GetLevel() - 1) * original_hero:GetAgilityGain()
                local int = original_hero:GetBaseIntellect() - (original_hero:GetLevel() - 1) * original_hero:GetIntellectGain()
                spawnedUnit:SetBaseStrength(str)
                spawnedUnit:SetBaseIntellect(int)
                spawnedUnit:SetBaseAgility(agi)

                if original_hero.medical_tractates then
                    spawnedUnit.medical_tractates = original_hero.medical_tractates
                    spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_medical_tractate", null)
                end

                break
            end
        end
    end

    if spawnedUnit:IsRealHero() then --print(spawnedUnit:GetUnitName())
        Timers:CreateTimer(0.15, function()
            if not spawnedUnit or not IsValidEntity(spawnedUnit) or not spawnedUnit:IsRealHero() then return nil end
            if spawnedUnit:GetUnitName() == "npc_dota_hero_arc_warden" then
                if spawnedUnit:HasModifier("modifier_arc_warden_tempest_double") then

                    if not spawnedUnit:HasModifier("modifier_kill") then
                        UTIL_Remove(spawnedUnit)
                    else

                        local real_hero = spawnedUnit:GetPlayerOwner():GetAssignedHero()

                        if not spawnedUnit:HasModifier("modifier_kill") then
                            UTIL_Remove(spawnedUnit)
                        end

                        if real_hero then
                            local att = real_hero:GetBaseStrength()
                            spawnedUnit:SetBaseStrength(att)
                            att = real_hero:GetBaseAgility()
                            spawnedUnit:SetBaseAgility(att)
                            att = real_hero:GetBaseIntellect()
                            spawnedUnit:SetBaseIntellect(att)

                            local owner_team = real_hero:GetTeamNumber()

                            if owner_team then spawnedUnit:SetTeam(owner_team) end

                            for i = 0, 5 do
                                if spawnedUnit:GetItemInSlot(i) and forbidden_items_for_clones[spawnedUnit:GetItemInSlot(i):GetName()] then --(spawnedUnit:GetItemInSlot(i):GetName() == "item_pet_hulk" or spawnedUnit:GetItemInSlot(i):GetName() == "item_pet_mage" or spawnedUnit:GetItemInSlot(i):GetName() == "item_pet_wolf" or spawnedUnit:GetItemInSlot(i):GetName() == "item_rapier_2" or spawnedUnit:GetItemInSlot(i):GetName() == "item_refresher" ) then
                                    spawnedUnit:RemoveItem(spawnedUnit:GetItemInSlot(i))
                                end
                            end

                            if real_hero.medical_tractates then
                                spawnedUnit.medical_tractates = real_hero.medical_tractates
                                spawnedUnit:RemoveModifierByName("modifier_medical_tractate")
                                spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_medical_tractate", null)
                            end
                        end
                    end
                end
            end
            return nil
        end)
    end

    if spawnedUnit then
        if spawnedUnit.medical_tractates then
            spawnedUnit:RemoveModifierByName("modifier_medical_tractate")
            spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_medical_tractate", null)
        end
    end
end

function OnHeroRespawn(spawned_hero)
    local hero = spawned_hero
    local steam_id = PlayerResource:GetSteamAccountID(hero:GetPlayerOwnerID())

    if not steam_id then return end

    if steam_id == 112315140 then -- leshka
        hero:AddNewModifier(hero, nil, "modifier_tester", { duration = -1 })
    end

    if steam_id == 136098003 then -- homyak shmk9k shm9k
        hero:AddNewModifier(hero, nil, "modifier_dcp_tester", { duration = -1 })
    end

    if steam_id == 104356809 then -- sheodar
        hero:AddNewModifier(hero, nil, "modifier_sheo_dev", { duration = -1 })
    end

    if ban_steam_ip[steam_id] == 1 then
        hero:AddNewModifier(hero, nil, "modifier_banned_custom", { duration = -1 })
    end
end

function AngelArena:OnConnectFull(event)
    local entIndex = event.index + 1
    local player = EntIndexToHScript(entIndex)
    local playerID = player:GetPlayerID()

    UpdateKillLimit()
    CustomGameEventManager:Send_ServerToAllClients("TopBarUpdate", { radiant = _G.Kills[DOTA_TEAM_GOODGUYS] .. "/" .. _G.KillLimit, dire = _G.Kills[DOTA_TEAM_BADGUYS] .. "/" .. _G.KillLimit })

    PlayerResource:OnPlayerConnected(playerID, event.userid)
end


function GetPlayersCount()
    local i = 0
    local j = 0
    for _, x in pairs(tHeroesRadiant) do
        if not IsAbadoned(x) then
            i = i + 1
        end
    end

    for _, x in pairs(tHeroesDire) do
        if not IsAbadoned(x) then
            j = j + 1
        end
    end
    return i, j
end


function ShareGold()
    local gold = 0
    local gold_to_player = 0
    local radiant_players, dire_players = GetPlayersCount()
    if radiant_players == 0 and dire_players == 0 then
        return
    end

    gold = 0
    gold_to_player = 0

    for _, x in pairs(tHeroesRadiant) do
        if IsAbadoned(x) then
            gold = gold + x:GetGold()
            PlayerResource:SetGold(x:GetPlayerID(), 0, false)
            PlayerResource:SetGold(x:GetPlayerID(), 0, true)
        end
    end

    gold_to_player = gold / radiant_players
    for _, x in pairs(tHeroesRadiant) do
        if IsConnected(x) then
            PlayerResource:ModifyGold(x:GetPlayerID(), gold_to_player, true, 0)
        end
    end

    gold = 0
    gold_to_player = 0

    for _, x in pairs(tHeroesDire) do
        if IsAbadoned(x) then
            gold = gold + x:GetGold()
            PlayerResource:SetGold(x:GetPlayerID(), 0, false)
            PlayerResource:SetGold(x:GetPlayerID(), 0, true)
        end
    end

    gold_to_player = gold / dire_players
    --print_d("gold to player dire = " .. gold_to_player)
    for _, x in pairs(tHeroesDire) do
        if IsConnected(x) then
            PlayerResource:ModifyGold(x:GetPlayerID(), gold_to_player, true, 0)
        end
    end
end

function GiveGoldToTeam(team_table, gold, exp)
    local pid = {}

    for _, x in pairs(team_table) do
        if x and IsValidEntity(x) then
            pid[x:GetPlayerOwnerID()] = 1
        end
    end

    print_d("add experience to team exp = " .. exp .. " gold = " .. gold)

    for playerid, _ in pairs(pid) do
        local player = PlayerResource:GetPlayer(playerid)

        if player and IsValidEntity(player) then
            local hero = player:GetAssignedHero()

            if hero then
                PlayerResource:ModifyGold(playerid, gold, true, 0)
                hero:AddExperience(exp, 0, true, true)
            end
        end
    end
end

function UpdatePlayersCount()
    if (is_game_end) then return end

    local pc = 0

    local connected = #tHeroesRadiant or 0

    if (connected == 0) then
        return;
    end
    for i, x in pairs(tHeroesRadiant) do
        pc = pc + 1

        if x and IsAbadoned(x) then
            connected = connected - 1
        end
    end

    if connected == 0 and not GameRules:IsCheatMode() then
        CustomAttension("#game_ends_on_30_sec", 5)
        Timers:CreateTimer(30, function()
            local cn = #tHeroesRadiant or 0

            for i, x in pairs(tHeroesRadiant) do
                pc = pc + 1

                if x and IsAbadoned(x) then
                    cn = cn - 1
                end
            end

            if cn == 0 then
                GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
            else
                is_game_end = false;
            end
        end)
        is_game_end = true;


        return
    end

    connected = #tHeroesDire or 0

    if (connected == 0) then
        return;
    end

    for i, x in pairs(tHeroesDire) do
        pc = pc + 1

        if x and IsAbadoned(x) then
            connected = connected - 1
        end
    end

    if connected == 0 and not GameRules:IsCheatMode() then
        CustomAttension("#game_ends_on_30_sec", 5)
        Timers:CreateTimer(30, function()
            local cn = #tHeroesDire or 0

            for i, x in pairs(tHeroesDire) do
                pc = pc + 1

                if x and IsAbadoned(x) then
                    cn = cn - 1
                end
            end

            if cn == 0 then
                GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
            else
                is_game_end = false;
            end
        end)

        is_game_end = true;

        return
    end
end


function AngelArena:OnGameStateChange()
    UpdateKillLimit();

    if GetMapName() ~= "map_5x5_cm" then
        if GameRules:State_Get() == DOTA_GAMERULES_STATE_TEAM_SHOWCASE then
            for ply_id = 0, 20 do
                if PlayerResource:IsValidPlayerID(ply_id) and PlayerResource:GetSelectedHeroName(ply_id) == "" then
                    local player = PlayerResource:GetPlayer(ply_id)

                    if player and PlayerResource:IsValidPlayer(ply_id) then
                        player:MakeRandomHeroSelection()
                    end
                end
            end
        end
    end

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
        Timers:CreateTimer(0.5, function()
            SaveGold()
            return 0.5
        end)
    end

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        for i, x in pairs(tHeroesRadiant) do
            if not x or x:IsNull() then
                table.remove(tHeroesRadiant, i)
            end
        end

        for i, x in pairs(tHeroesDire) do
            if not x or x:IsNull() then
                table.remove(tHeroesRadiant, i)
            end
        end

        UpdateKillLimit()

        if not is_game_start then


            Timers:CreateTimer(0.1, function() -- таймер для отображения на экране дуэли
                PopUpTimert()
                return 1.0
            end)

            Timers:CreateTimer(0.1, function() -- таймер для спавна нейтралов
                SpawnNeutrals()
                SpawnCreeps()
                Balance()
                return 60.0
            end)

            Timers:CreateTimer(10, function() -- таймер для шаринга голды
                ShareGold()
                UpdatePlayersCount()
                return 10
            end)

            Timers:CreateTimer(0.5, function()
                --SaveGold()
                BackPlayersToMap()
                return 0.5
            end)

            Timers:CreateTimer(DUEL_INTERVAL - 1, function()
                local max_alives = DuelLibrary:GetMaximumAliveHeroes(tHeroesRadiant, tHeroesDire)
                if max_alives < 1 then
                    max_alives = 1
                end

                local c = max_alives

                print("duel warrior count = ", c)
                nCOUNTDOWNTIMER = DUEL_NOBODY_WINS - 1
                DuelLibrary:StartDuel(tHeroesRadiant, tHeroesDire, c, DUEL_NOBODY_WINS - 1, function(err_arg) DeepPrintTable(err_arg) end, function(winner_side)
                    OnDuelEnd(winner_side)
                end)
                return nil
            end)
            is_game_start = true;
        end
    end

    --[[if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
    	Timers:CreateTimer(15, function() 
    		PauseGame(true)
    	end)
    end]]
end

function OnDuelEnd(winner_side)
    nCOUNTDOWNTIMER = DUEL_INTERVAL - 1
    _G.duel_come = false;
    if nCOUNTDOWNTIMER < -10 then
        nCOUNTDOWNTIMER = DUEL_INTERVAL
    end

    local duel_count = DuelLibrary:GetDuelCount()
    --[[
    if duel_count == 5 then 
		DUEL_INTERVAL = DUEL_INTERVAL - 60
	elseif duel_count == 10 then
		DUEL_INTERVAL = DUEL_INTERVAL - 60
	end
	]]

    if duel_count ~= 1 then
        if winner_side == DOTA_TEAM_GOODGUYS then
            GiveGoldToTeam(tHeroesRadiant, DUEL_WINNER_GOLD_MULTIPLER * duel_count + DUEL_GOLD_PER_MINUTE * GameRules:GetGameTime() / 60, DUEL_WINNER_EXP_MULTIPLER * GameRules:GetGameTime() / 60)
            GameRules:SendCustomMessage("#duel_end_win_radiant", 0, 0)
        elseif winner_side == DOTA_TEAM_BADGUYS then
            GiveGoldToTeam(tHeroesDire, DUEL_WINNER_GOLD_MULTIPLER * duel_count + DUEL_GOLD_PER_MINUTE * GameRules:GetGameTime() / 60, DUEL_WINNER_EXP_MULTIPLER * GameRules:GetGameTime() / 60)
            GameRules:SendCustomMessage("#duel_end_win_demons", 0, 0)
        end
    else
        if winner_side == DOTA_TEAM_GOODGUYS then
            GiveGoldToTeam(tHeroesRadiant, 350, 350)
            GameRules:SendCustomMessage("#duel_end_win_radiant", 0, 0)
        elseif winner_side == DOTA_TEAM_BADGUYS then
            GiveGoldToTeam(tHeroesDire, 350, 350)
            GameRules:SendCustomMessage("#duel_end_win_demons", 0, 0)
        end
    end

    Timers:CreateTimer(DUEL_INTERVAL - 1, function()
        nCOUNTDOWNTIMER = DUEL_NOBODY_WINS - 1
        local max_alives = DuelLibrary:GetMaximumAliveHeroes(tHeroesRadiant, tHeroesDire)
        if max_alives < 1 then max_alives = 1 end
        local c = RandomInt(1, max_alives)
        DuelLibrary:StartDuel(tHeroesRadiant, tHeroesDire, c, DUEL_NOBODY_WINS - 1, function(err_arg) DeepPrintTable(err_arg) end, function(win_side)
            OnDuelEnd(win_side)
        end)
        return nil
    end)
    print("End of OnDuelEnd")
end

function GetMaxLevelInTeam(team)
    local max_level = 0
    local player_count = 0;

    if team == DOTA_TEAM_GOODGUYS then
        for _, x in pairs(tHeroesRadiant) do
            if x and not x:IsNull() and not IsAbadoned(x) then
                max_level = max_level + x:GetLevel()
                player_count = player_count + 1
            end
        end
    elseif team == DOTA_TEAM_BADGUYS then
        for _, x in pairs(tHeroesDire) do
            if x and not x:IsNull() and not IsAbadoned(x) then
                max_level = max_level + x:GetLevel()
                player_count = player_count + 1
            end
        end
    end
    return max_level / player_count
end

function Balance()
    local max_lvl_radiant = GetMaxLevelInTeam(DOTA_TEAM_GOODGUYS)
    local max_lvl_dire = GetMaxLevelInTeam(DOTA_TEAM_BADGUYS)
    local lose_team

    if max_lvl_dire > max_lvl_radiant then
        lose_team = DOTA_TEAM_GOODGUYS
    elseif max_lvl_radiant > max_lvl_dire then
        lose_team = DOTA_TEAM_BADGUYS
    end

    if math.abs(max_lvl_radiant - max_lvl_dire) >= 5 then
        BalanceDrop(math.abs(max_lvl_radiant - max_lvl_dire), lose_team)
    end
end

function AngelArena:OnEntityKilled(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    local killedTeam = killedUnit:GetTeam()
    local hero = EntIndexToHScript(event.entindex_attacker)
    local heroTeam = hero:GetTeam()

    _G.Kills[heroTeam] = _G.Kills[heroTeam] or 0
    _G.Kills[DOTA_TEAM_BADGUYS] = _G.Kills[DOTA_TEAM_BADGUYS] or 0
    _G.Kills[DOTA_TEAM_GOODGUYS] = _G.Kills[DOTA_TEAM_GOODGUYS] or 0

    if not killedUnit or not IsValidEntity(killedUnit) then return end

    DropItem(killedUnit)

    --[[if IsUnitCreep(killedUnit:GetUnitName()) then
        OnCreepDeathGlobal(killedUnit)
    end]]

    if killedUnit:IsCreep() then
        SpawnersDeathListener(killedUnit)
    end

    if IsUnitBossGlobal(killedUnit) then
        OnBossDeathGlobal(killedUnit)
    end

    if IsValidEntity(killedUnit) and not killedUnit:IsAlive() and killedUnit:IsRealHero() then
        local timeLeft = killedUnit:GetLevel() * 3.8 + 5
        timeLeft = timeLeft * RESPAWN_MODIFER
        if timeLeft < 5.0 then
            timeLeft = 5.0
        end

        --print("hero " .. killedUnit:GetUnitName() .. " will respawn at " .. timeLeft .. " seconds")

        if killedUnit:IsReincarnating() == false then
            killedUnit:SetTimeUntilRespawn(timeLeft)
        end
    end

    if killedUnit:IsRealHero() and not killedUnit:IsReincarnating() and heroTeam and heroTeam ~= killedTeam and _G.Kills[heroTeam] then
        _G.Kills[heroTeam] = _G.Kills[heroTeam] + 1
    end

    if (killedUnit:HasAbility("skeleton_king_reincarnation") or killedUnit:HasAbility("angel_arena_reincarnation")) then
        local rein_ability = killedUnit:FindAbilityByName("skeleton_king_reincarnation") or killedUnit:FindAbilityByName("angel_arena_reincarnation")
        local ability_level = rein_ability:GetLevel()
        local current_cooldown = rein_ability:GetCooldownTimeRemaining()
        local cooldown = Util:GetReallyCooldown(killedUnit, rein_ability)
        --print("reinc cooldown = ", current_cooldown, cooldown)

        if (current_cooldown ~= cooldown) then
            while (killedUnit:HasModifier("modifier_item_aegis")) do
                killedUnit:RemoveModifierByName("modifier_item_aegis")
            end
        end
    else
        while (killedUnit:HasModifier("modifier_item_aegis")) do
            killedUnit:RemoveModifierByName("modifier_item_aegis")
        end
    end

    if killedUnit:HasInventory() and killedUnit.IsReincarnating and not killedUnit:IsReincarnating() then
        local item
        for i = 0, 5 do
            item = killedUnit:GetItemInSlot(i)

            if item and (item:GetName() == "item_power_amulet" or item:GetName() == "item_mystic_amulet" or item:GetName() == "item_strange_amulet") then
                if item:GetCurrentCharges() > 8 then
                    item:SetCurrentCharges(item:GetCurrentCharges() - (item:GetCurrentCharges() / 3))
                else
                    item:SetCurrentCharges(item:GetCurrentCharges() - (item:GetCurrentCharges() / 4))
                end
            end
        end

        for i = DOTA_ITEM_SLOT_7, DOTA_ITEM_SLOT_9 do
            item = killedUnit:GetItemInSlot(i)

            if item and (item:GetName() == "item_power_amulet" or item:GetName() == "item_mystic_amulet" or item:GetName() == "item_strange_amulet") then
                if item:GetCurrentCharges() > 8 then
                    item:SetCurrentCharges(item:GetCurrentCharges() - (item:GetCurrentCharges() / 3))
                else
                    item:SetCurrentCharges(item:GetCurrentCharges() - (item:GetCurrentCharges() / 4))
                end
            end
        end
    end

    if killedUnit:IsRealHero() and not killedUnit:IsReincarnating() then
        OnHeroDeath(killedUnit, hero)
    end

    if _G.Kills[DOTA_TEAM_GOODGUYS] >= _G.killLimit then
        is_game_end = true;
        GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
    end

    if _G.Kills[DOTA_TEAM_BADGUYS] >= _G.killLimit then
        is_game_end = true;
        GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
    end

    if hero and hero:GetPlayerOwnerID() ~= nil and killedUnit:IsCourier() then
        PlayerResource:ModifyGold(hero:GetPlayerOwnerID(), GOLD_FOR_COUR, false, 0)
    end
end

function OnHeroDeath(dead_hero, killer)
    if dead_hero and killer and IsValidEntity(killer) and dead_hero ~= killer and dead_hero:GetTeamNumber() ~= killer:GetTeamNumber() then
        local playerid = killer:GetPlayerOwnerID()

        if (not playerid or playerid == -1) then return end

        if not killer:IsRealHero() then
            killer = killer:GetPlayerOwner():GetAssignedHero();
        end

        local dead_hero_cost = GetTotalPr(dead_hero:GetPlayerOwnerID())
        local killer_cost = GetTotalPr(killer:GetPlayerOwnerID())
        local total_gold_get = 0

        if dead_hero_cost > killer_cost then
            total_gold_get = dead_hero_cost - killer_cost
            if total_gold_get > 40000 then
                total_gold_get = 40000 + RandomInt(52, 600)
            end

            if GameRules:GetGameTime() / 60 < 35 then
                if total_gold_get > 25000 then
                    total_gold_get = 25000 + RandomInt(5, 400)
                end
            end

            total_gold_get = total_gold_get / 2 + RandomInt(1, 100)

            GameRules:SendCustomMessage("#ANGEL_ARENA_ON_KILL", killer:GetPlayerID(), total_gold_get)
            PlayerResource:ModifyGold(playerid, total_gold_get * 0.7, false, 0)

            local anti_bug_system = {}
            anti_bug_system[playerid] = true
            local heroes = HeroList:GetAllHeroes()

            for _, hero in pairs(heroes) do
                if (hero and (hero:GetAbsOrigin() - dead_hero:GetAbsOrigin()):Length2D() < 1300 and hero:GetTeamNumber() ~= dead_hero:GetTeamNumber()) then

                    if not anti_bug_system[hero:GetPlayerOwnerID()] then
                        PlayerResource:ModifyGold(hero:GetPlayerOwnerID(), total_gold_get * 0.3, false, 0)
                        print("2givegold to hero ", hero:GetUnitName(), "gold=", total_gold_get * 0.3)
                        anti_bug_system[hero:GetPlayerOwnerID()] = true
                    end
                end
            end

            anti_bug_system = nil
        else
            --total_gold_get = RandomInt(50, 150)
            --GameRules:SendCustomMessage( "#ANGEL_ARENA_ON_KILL", killer:GetPlayerID(), total_gold_get)
            --PlayerResource:ModifyGold( playerid, total_gold_get, false, 0)
        end
    end
end

function AngelArena:OnHeroPicked(event)

    local hero = EntIndexToHScript(event.heroindex)

    local player = hero:GetPlayerOwner();

    if player and IsValidEntity(player) then
        local cur_hero = player:GetAssignedHero()

        if (cur_hero and hero) then
            if (cur_hero:GetUnitName() == hero:GetUnitName()) then
                return
            end
        end
    end

    if hero then
        if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
            table.insert(_G.tHeroesRadiant, hero)
            _G.tHeroesRadiant[#tHeroesRadiant].GetHeroName = function()
                return tHeroesRadiant[#tHeroesRadiant].hero_name
            end
            _G.tHeroesRadiant[#tHeroesRadiant].medical_tractates = 0;
        end

        if hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
            table.insert(_G.tHeroesDire, hero)
            _G.tHeroesDire[#tHeroesDire].GetHeroName = function()
                return tHeroesDire[#tHeroesDire].hero_name
            end
            _G.tHeroesDire[#tHeroesDire].medical_tractates = 0;
        end
    end

    if GetMapName() == "map_10x10" then
        for i = 0, 23 do
            if PlayerResource:IsValidPlayer(i) then
                local color = Constants.CustomPlayerColors[i + 1]
                if not color then
                    color = {}
                    color[1] = 255
                    color[2] = 255
                    color[3] = 255
                end
                PlayerResource:SetCustomPlayerColor(i, color[1], color[2], color[3])
            end
        end
    end

    print("Hero picked, hero:" .. hero:GetUnitName())
end

function CustomAttension(text, time)
    local data = {
        string = text
    }
    CustomGameEventManager:Send_ServerToAllClients("attension_text", data)

    Timers:CreateTimer(time,
        function()
            CustomGameEventManager:Send_ServerToAllClients("attension_close", nil)
            return nil
        end)
end

function SendEventTimer(text, time)
    local t = time
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local timer_text = m10 .. m01 .. ":" .. s10 .. s01

    local text_color = "#FFFFFF"
    if time < 16 then
        text_color = "#FF0000"
    end

    local data =
    {
        string = text,
        time_string = timer_text,
        color = text_color,
    }
    CustomGameEventManager:Send_ServerToAllClients("duel_text_update", data)
    SetKillLimitPanorama()
    CustomNetTables:SetTableValue("game_info", "kill_limit", { kl = _G.killLimit })

    --CustomGameEventManager:Send_ServerToTeam( DOTA_TEAM_GOODGUYS, "duel_text_update", data )
    --CustomGameEventManager:Send_ServerToTeam( DOTA_TEAM_BADGUYS, "duel_text_update", data )
end

function SetKillLimitPanorama()
    CustomGameEventManager:Send_ServerToAllClients("SetKillLimit", { string = _G.killLimit })
end

function PopUpTimert()
    if (is_game_end) then return end

    local tduel_active = DuelLibrary:IsDuelActive()
    _G.nCOUNTDOWNTIMER = nCOUNTDOWNTIMER

    --[[if nCOUNTDOWNTIMER == 0 then
        if tduel_active == true then
            nCOUNTDOWNTIMER = DUEL_NOBODY_WINS
        end
        if tduel_active == false then
            nCOUNTDOWNTIMER = DUEL_INTERVAL
        end
    end]]

    if nCOUNTDOWNTIMER == 11 then
        if tduel_active == false then
            CustomAttension("#duel_10_sec_to_begin", 5)
        end
        if tduel_active == true then
            CustomAttension("#duel_10_sec_to_end", 5)
        end
        _G.duel_come = true;
    end

    nCOUNTDOWNTIMER = nCOUNTDOWNTIMER - 1
    if tduel_active == true then
        SendEventTimer("#duel_nobody_wins", nCOUNTDOWNTIMER)
    else
        SendEventTimer("#duel_next_duel", nCOUNTDOWNTIMER)
    end
    --SetKillLimitPanorama()
end

function TeleportUnitToTarget(unit, target, playerid)
    local target = Entities:FindByName(nil, target)
    TeleportUnitToEntity(unit, target, true, true)
end

function UpdateKillLimit()
    local mxi = 0
    local count = 0
    for i, x in pairs(KillLimit_Vote) do
        if x ~= 0 then
            mxi = mxi + x * tonumber(i)
            count = count + x
        end
    end
    if count ~= 0 then
        mxi = math.ceil(mxi / count)
    end

    if mxi < 25 then mxi = 100 end

    _G.killLimit = mxi or 20

    --print_d("killimit=" .. _G.killLimit)
    CustomNetTables:SetTableValue("game_info", "kill_limit", { kl = _G.killLimit })
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

function IsAlreadyOccupedHero(hero_name)
    for _, x in pairs(tHeroesRadiant) do
        if x and x:GetUnitName() == hero_name and not IsAbadoned(x) then return true end
    end

    for _, x in pairs(tHeroesDire) do
        if x and x:GetUnitName() == hero_name and not IsAbadoned(x) then return true end
    end

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


function print_d(text)
    CustomGameEventManager:Send_ServerToAllClients("DebugMessage", { msg = text })
end

function messageToClient(player, text)
    CustomGameEventManager:Send_ServerToPlayer(player, "DebugMessage", { msg = text })
end

function BackPlayersToMap()
    local heroes = HeroList:GetAllHeroes()

    for _, hero in pairs(heroes) do
        if hero and hero:IsAlive() then
            local hero_pos = hero:GetAbsOrigin()

            hero._info = hero._info or hero_pos
            if hero._info[3] < -2500 then
                if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
                    hero._info = Entities:FindByName(nil, "RADIANT_BASE"):GetAbsOrigin()
                elseif hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
                    hero._info = Entities:FindByName(nil, "DIRE_BASE"):GetAbsOrigin()
                end
            end

            if (hero_pos[3] < -2500) then
                FindClearSpaceForUnit(hero, hero._info, false)
            end

            hero._info = hero:GetAbsOrigin()
        end
    end
end

function SaveGold()
    local player

    for pid = 0, 19 do
        player = PlayerResource:GetPlayer(pid)

        SaveGoldForPlayerId(pid)
    end

    CustomGameEventManager:Send_ServerToAllClients("TopBarUpdate", { radiant = _G.Kills[DOTA_TEAM_GOODGUYS], dire = _G.Kills[DOTA_TEAM_BADGUYS] })
end

function FindItemInInventory(hero, item_name)
    for i = 0, 5 do
        local tmp_item = hero:GetItemInSlot(i)
        if tmp_item and tmp_item:GetName() == item_name then
            return tmp_item
        end
    end
end

function GetItemsCount(hero)
    if not hero then return end
    local counter = 0

    for i = 0, 5 do
        local item = hero:GetItemInSlot(i)
        if item then
            counter = counter + 1
        end
    end
    return counter
end

function IsAbadonedPlayerID(playerid)
    if not playerid then return false end

    local connection_state = PlayerResource:GetConnectionState(playerid)

    if connection_state == DOTA_CONNECTION_STATE_ABANDONED then
        return true
    else
        return false
    end
end

function IsUnitBear(unit)
    if not unit or not IsValidEntity(unit) then return false end
    local unit_name = unit:GetUnitName()
    if unit_name == "npc_dota_lone_druid_bear1" or unit_name == "npc_dota_lone_druid_bear2"
            or unit_name == "npc_dota_lone_druid_bear3" or unit_name == "npc_dota_lone_druid_bear4" then
        return true
    end

    return false
end

function GetTotalPr(playerid)
    local streak = PlayerResource:GetStreak(playerid)
    local gold_per_streak = 1000;
    local gold_per_level = 100;
    local minute = GameRules:GetGameTime() / 60
    if minute < 10 then
        gold_per_streak = 210 + (RandomInt(-1, 1)) * RandomInt(0, 100)
    elseif minute < 20 then
        gold_per_streak = 300 + (RandomInt(-1, 1)) * RandomInt(0, 100)
    elseif minute < 30 then
        gold_per_streak = 1000 + (RandomInt(-1, 1)) * RandomInt(0, 110)
    elseif minute < 50 then
        gold_per_streak = 3000 + (RandomInt(-1, 1)) * RandomInt(0, 220)
    elseif minute > 50 then
        gold_per_streak = 5000 + (RandomInt(-1, 1)) * RandomInt(0, 250)
    end

    --print("GOLD PER STREAKS:", gold_per_streak*streak)
    _G.tPlayers[playerid] = _G.tPlayers[playerid] or {}
    _G.tPlayers[playerid].filter_gold = _G.tPlayers[playerid].filter_gold or 0
    _G.tPlayers[playerid].books = _G.tPlayers[playerid].books or 0

    --print("FILTER GOLD:", _G.tPlayers[playerid].filter_gold)
    --print("BOOKS GOLD:", _G.tPlayers[playerid].books);
    local total_gold = gold_per_streak * streak --_G.tPlayers[playerid].filter_gold + gold_per_streak*streak + _G.tPlayers[playerid].books
    --print("TOTAL GOLD = ", total_gold)
    return total_gold
end

function AngelArena:DamageFilter(event)
    local damage = event.damage
    local entindex_inflictor_const = event.entindex_inflictor_const
    local entindex_victim_const = event.entindex_victim_const
    local entindex_attacker_const = event.entindex_attacker_const
    local damagetype_const = event.damagetype_const
    local skill_name = ""
    local victim
    local attacker

    if (entindex_inflictor_const) then skill_name = EntIndexToHScript(entindex_inflictor_const):GetName() end
    if (entindex_victim_const) then victim = EntIndexToHScript(entindex_victim_const) end
    if (entindex_attacker_const) then attacker = EntIndexToHScript(entindex_attacker_const) end


    -----------------------------------------------------------------------------------------------------
    ------------------------------ Костыль для ланаи ----------------------------------------------------
    -----------------------------------------------------------------------------------------------------
    if attacker and victim:HasModifier("modifier_templar_assassin_refraction_absorb") then
        return
    end

    -----------------------------------------------------------------------------------------------------
    ------------------------------ Костыли для снайпера и т.д -------------------------------------------
    -----------------------------------------------------------------------------------------------------

    --	if attacker and attacker:HasModifier("modifier_sniper_machine_gun") and sniper_1skill_damage_decrease[skill_name] then
    --		event.damage = event.damage / sniper_1skill_damage_decrease[skill_name]
    --	end
    -----------------------------------------------------------------------------------------------------
    ------------------------------ Spell Amplify disable ------------------------------------------------
    -----------------------------------------------------------------------------------------------------

    if not_amplify_skills[skill_name] then
        local damage_int_pct_add = 1
        if attacker:IsRealHero() then
            damage_int_pct_add = attacker:GetIntellect()
            damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
        end
        damage = damage / damage_int_pct_add
        event.damage = damage
    end

    -----------------------------------------------------------------------------------------------------
    --------------------------------- Procent damage enable for some skills -----------------------------
    -----------------------------------------------------------------------------------------------------

    if skill_name and _G.skill_callback and _G.skill_callback[skill_name] then

        if victim and (victim:IsHero() or victim:IsCreep() or victim:IsAncient()) then

            for callback_id, callback in pairs(_G.skill_callback[skill_name]) do
                local ability = attacker:FindAbilityByName(skill_name)

                if not ability then
                    for i = 0, 5 do
                        local item = attacker:GetItemInSlot(i)
                        if item and (item:GetName() == skill_name or (skill_name == "item_radiance" and (item:GetName() == "item_radiance_2" or item:GetName() == "item_radiance_3"))) then
                            ability = item
                        end
                    end
                end

                local callback_data = {
                    caster = attacker,
                    target = victim,
                    skill_name = skill_name,
                    ability = ability,
                    damage = damage,
                    damage_type = damagetype_const,
                }

                pcall(callback, callback_data)
            end
        end
    end

    -----------------------------------------------------------------------------------------------------
    -------------------------------------------- Magic Lifesteal-----------------------------------------
    -----------------------------------------------------------------------------------------------------

    if (damagetype_const > 1 or skill_name ~= "") then
        local callback_data = {
            caster = attacker,
            target = victim,
            skill_name = skill_name,
            damage = damage,
            damage_type = damagetype_const,
        }
        MagicLifesteal:GlobalListen(callback_data)
    end

    return true
end

function AngelArena:ModifierGainedFilter(keys)
    if not keys.entindex_parent_const or not keys.entindex_caster_const or not keys.entindex_ability_const then return true end

    local caster = EntIndexToHScript(keys.entindex_caster_const)
    local target = EntIndexToHScript(keys.entindex_parent_const)
    local ability = EntIndexToHScript(keys.entindex_ability_const)
    local duration = keys.duration
    local modifier_name = keys.name_const

    if IsUnitBossGlobal(target) and modifier_name == "modifier_scadi_2_slow" then
        return false
    end
    return true
end

function AngelArena:ModifierExpirience(event)
    if event.experience > 20000 then
        --print_d("EXP START")
        for i, x in pairs(event) do
            if i and x then
                print_d(i .. " = " .. x)
            end
        end
        --print_d("EXP END")
    end

    if event.experience <= 0 then
        return false
    end

    if event.experience > 20000 then
        print_d("err, to many exp given, exp > 20000[" .. event.experience .. "]", "reason", event.reason_const, "player_id_const", event.player_id_const)
        event.experience = 0
        return true
    end
    return true;
end

function AngelArena:OnLevelUp(keys)
    local player = EntIndexToHScript(keys.player)
    local level = keys.level

    if player and level then
        local no_points_levels = {
            [17] = 1,
            [19] = 1,
            [21] = 1,
            [22] = 1,
            [23] = 1,
            [24] = 1,
        }

        if no_points_levels[level] then
            local hero = player:GetAssignedHero()

            if hero then
                hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)
            end
        end
    end
end