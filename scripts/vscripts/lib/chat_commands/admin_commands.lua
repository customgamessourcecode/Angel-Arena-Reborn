--[[
Admin commands
 -kick 1      				-- helper command to fix teammate-man. 
 -check_userid				-- helper command to fix teammate-man 
 -pause, -p					-- set pause on 
 -unpause, -up				-- set pause off
 -debug_playerinfo 			-- print debug info for our player
 -check_modifiers			-- print modifier list for player hero
 -check_skills				-- print skills and cd list for player hero
 -get_gold					-- print all players gold(pseudo-stash)
 -test						-- make the arena great again
]]

--LinkLuaModifier( "modifier_hero_passive", 'modifiers/modifier_hero_passive', 		LUA_MODIFIER_MOTION_NONE )

Commands = Commands or class({})

local admin_ids = {
    [73911256] = 1, -- cry
    [104356809] = 1, -- Sheodar
    [136098003] = 1, -- homie
}

function IsAdmin(player)
    local steam_account_id = PlayerResource:GetSteamAccountID(player:GetPlayerID())
    return (admin_ids[steam_account_id] == 1)
end

function Commands:kick(player, arg)
    if not IsAdmin(player) then return end

    if not arg[1] then return end

    PlayerResource:ForceDisconnect(tonumber(arg[1]))
end

function Commands:stop(player, arg)
    if not IsAdmin(player) then return end
    if not arg[1] then return end
    local hero
    if tonumber(arg[1]) and PlayerResource:GetPlayer(tonumber(arg[1])) and PlayerResource:GetPlayer(tonumber(arg[1])):GetAssignedHero() then
        hero = PlayerResource:GetPlayer(tonumber(arg[1])):GetAssignedHero()
    end
    if hero and hero:GetPlayerOwnerID() and hero:GetUnitName() then
        if not hero:HasModifier("modifier_banned_custom") and hero and hero:GetPlayerOwnerID() and hero:GetUnitName() then
            hero:AddNewModifier(hero, nil, "modifier_banned_custom", { duration = -1 })
        elseif hero:HasModifier("modifier_banned_custom") and hero and hero:GetPlayerOwnerID() and hero:GetUnitName() then
            hero:RemoveModifierByName("modifier_banned_custom")
        end
    end
end

function Commands:check_userid(player, arg)
    if not IsAdmin(player) then return end

    local all_heroes = HeroList:GetAllHeroes()
    for _, hero in pairs(all_heroes) do
        if hero and hero:GetPlayerOwnerID() and hero:GetUnitName() then
            messageToClient(player, "[" .. tostring(hero:GetPlayerOwnerID()) .. "] - " .. hero:GetUnitName())
        end
    end
end

function Commands:pause(player, arg)
    if not IsAdmin(player) then return end

    PauseGame(true)
end

function Commands:p(player, arg) self:pause(player, arg); end

function Commands:unpause(player, arg)
    if not IsAdmin(player) then return end

    PauseGame(false)
end

function Commands:up(player, arg) self:unpause(player, arg); end

function Commands:debug_playerinfo(player, arg)
    if not IsAdmin(player) then return end

    PrintPlayerInfo(player)
end

function Commands:check_modifiers(player, arg)
    if not IsAdmin(player) then return end

    CheckModifiers(player)
end

function Commands:cm(player, arg)
    if not IsAdmin(player) then return end

    CheckModifiers(player)
end

function Commands:check_skills(player, arg)
    if not IsAdmin(player) then return end

    CheckSkills(player)
end

function Commands:frameTime(player, arg)
    if not IsAdmin(player) then return end

    messageToClient(player, "Server frame time " .. tostring(FrameTime()))
end

function Commands:d_Time(player, arg)
    if not IsAdmin(player) then return end

    messageToClient(player, "Time " .. tostring(Time()))
end

function Commands:get_gold(player, arg)
    if not IsAdmin(player) then return end

    CheckPlayersSaveGold(player)
end

function Commands:r(player, arg)
    if not IsAdmin(player) then return end

    SendToServerConsole('script_reload');
end

function Commands:test(player, arg)
    if not IsAdmin(player) then return end
    -- -test
    local hero = player:GetAssignedHero()

    local ent = PlayerResource:GetSelectedHeroEntity(0)

    local id = Geometrics:AddLine(ent:GetPlayerCursorPosition(), ent:GetAbsOrigin())
    print(id)
end

function Commands:test2(player, arg)
    if not IsAdmin(player) then return end
    --	local hero = player:GetAssignedHero()
    --
    --	local ent = PlayerResource:GetSelectedHeroEntity( 0 )
    --
    --	Geometrics:RemoveLine( tonumber(arg[1]) )
    print_d(1)
end

function Commands:ctime(player, arg)
    if not IsAdmin(player) then return end

    messageToClient(player, "ctime:")

    if not PlayerResource.__internal__ or not PlayerResource.__internal__["playerid_info"] or not PlayerResource.__internal__["playerid_info"]["connection_times"] then
        messageToClient(player, "something gonna wrong in -ctime")
    end

    for i, x in pairs(PlayerResource.__internal__["playerid_info"]["connection_times"]) do
        if i and x then
            messageToClient(player, tostring(i) .. " : " .. tostring(x))
        end
    end
end

function Commands:cstates(player, arg)
    if not IsAdmin(player) then return end

    local tbl = PlayerResource:GetAllHeroes()
    --print(tbl, #tbl)

    for _, hero in pairs(tbl) do
        local playerid = hero:GetPlayerOwnerID()
        local conn = "-"
        local disc = "-"
        local abad = "-"

        if hero:IsPlayerConnected() then conn = "+" end
        if hero:IsPlayerAbandoned() then abad = "+" end
        if hero:IsPlayerDisconnected() then disc = "+" end

        messageToClient(player, "[" .. tostring(playerid) .. " : " .. hero:GetUnitName() .. "] = C[" .. conn .. "] D[" .. disc .. "] A[" .. abad .. "]")
    end
end

function Commands:setcstate(player, arg)
    if not IsAdmin(player) then return end

    if not arg[1] or not arg[2] or not arg[3] then return end

    local pid = tonumber(arg[1])
    local c_type = tonumber(arg[2])
    local val = arg[3]

    if val == "nil" then
        val = nil
    elseif val == "1" then
        val = true
    else
        val = false
    end

    if c_type == 0 then
        PlayerResource:SetConnected(pid, val)
    end

    if c_type == 1 then
        PlayerResource:SetDisconnected(pid, val)
    end

    if c_type == 2 then
        PlayerResource:SetAbandoned(pid, val)
    end
end

--------------------------------------------- Helper functions -----------------------------------------------
function PrintPlayerInfo(player)
    local radiant = _G.tHeroesRadiant
    local dire = _G.tHeroesDire

    messageToClient(player, "Radiant Players:")
    for i, x in pairs(radiant) do
        if x then
            messageToClient(player, " |-> playerid:" .. x:GetPlayerOwnerID() .. " hero_name = '" .. x:GetUnitName() .. "'' hero level = " .. x:GetLevel() .. " Gold = " .. x:GetGold() .. " steamid:" .. PlayerResource:GetSteamAccountID(x:GetPlayerOwnerID()))
        end
    end

    messageToClient(player, "Dire Players:")
    for i, x in pairs(dire) do
        if x then
            messageToClient(player, " |-> playerid:" .. x:GetPlayerOwnerID() .. " hero_name = " .. x:GetUnitName() .. " hero level = " .. x:GetLevel() .. " Gold = " .. x:GetGold() .. " steamid:" .. PlayerResource:GetSteamAccountID(x:GetPlayerOwnerID()))
        end
    end
end

function CheckPlayersSaveGold(player)
    messageToClient(player, "Check players gold:")
    for i, x in pairs(tPlayers) do
        if x then
            if x.gold then
                messageToClient(player, " |-> playerid[" .. i .. "] save gold [" .. x.gold .. "]")
            end
        end
    end
end

function _GetNearestUnitUnderPoint(point, radius)
    local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE

    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, point, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, flags, 0, false)

    if not units or #units < 0 then return nil end

    local res_unit = nil
    local res_len = nil

    for _, unit in pairs(units) do
        local ln = 999999

        if unit and unit.GetAbsOrigin then
            ln = (unit:GetAbsOrigin() - point):Length()
        end

        if not res_len or ln < res_len then
            res_unit = unit
            res_len = ln
        end
    end

    return res_unit
end

function CheckModifiers(player)
    if not player then return end
    local hero = player:GetAssignedHero()

    if hero then
        local pos = hero:GetPlayerCursorPosition()

        hero = _GetNearestUnitUnderPoint(pos, 100)
    end

    if not hero then return end

    messageToClient(player, "Unit '" .. hero:GetUnitName() .. "' modifiers:")

    for i = 0, hero:GetModifierCount() - 1 do
        messageToClient(player, " |-> " .. hero:GetModifierNameByIndex(i))
    end
end

function CheckSkills(player)
    if not player then return end
    local hero = player:GetAssignedHero()
    if not hero then end

    messageToClient(player, "hero '" .. hero:GetUnitName() .. "' skills:")
    local ability
    for i = 0, hero:GetAbilityCount() - 1 do
        ability = hero:GetAbilityByIndex(i)
        if ability then
            messageToClient(player, " |-> " .. ability:GetName() .. " cd = " .. ability:GetCooldownTimeRemaining())
        end
    end
end

function messageToClient(player, text)
    CustomGameEventManager:Send_ServerToPlayer(player, "DebugMessage", { msg = text })
end