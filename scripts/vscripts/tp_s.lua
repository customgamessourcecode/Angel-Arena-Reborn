function hc_menu_open(trigger)
    print("[LUA]Trying open menu!")
    if IsServer() then
        
        _G.Bosses.deaths = _G.Bosses.deaths or {}
        _G.Bosses.deaths["npc_dota_custom_guardian"] = _G.Bosses.deaths["npc_dota_custom_guardian"] or 0

        if IsBossAliveGlobal("npc_dota_custom_guardian") or _G.Bosses.deaths["npc_dota_custom_guardian"] == 0 or not _G.Bosses.deaths["npc_dota_custom_guardian"] then 
            print("GUARDIAN ARE ALIVE!")
            return 
        end
    end
    if not trigger.activator:GetPlayerOwner() then 
        return
    end

   PickMenu:OpenGodsMenu(trigger.activator:GetPlayerOwner())
end

function hc_menu_close(trigger)
    print("[LUA]Trying close menu")
    if not trigger.activator then return end
    if not trigger.activator:GetPlayerOwner() then 
        return
    end

    PickMenu:CloseRepickMenu(trigger.activator:GetPlayerOwner())
end


-- OUTDATED
function IsInDuel(unit)
    local point = unit:GetAbsOrigin() 
    local flag = false
    for _,thing in pairs(Entities:FindAllInSphere(point, 10) )  do
        if (thing:GetName() == "trigger_box_duel") then
            flag = true
            print("on duel makaka")
        end
    end
    if flag == false then
        local duel_center =  Entities:FindByName( nil, "DUEL_ARENA_CENTER" ):GetAbsOrigin()
        print("not on duel")
        GridNav:DestroyTreesAroundPoint(point, 15, true)
        FindClearSpaceForUnit(unit, duel_center, false)
        unit:Stop()
    end

    return flag
end
