-- TELEPORTS FOR MAP 10x10

function teleport_trigger_activate(trigger)
	local hero = trigger.activator
	if not hero then return end
    local trigger_name = trigger.caller:GetName()
	if trigger_name == "TRIGGER_RT_1" then
		TeleportUnitToPointName(hero, "TELEPORT_DIRE_1", true, true)
		trigger.caller:EmitSound("DOTA_Item.BlinkDagger.Activate") 
		print("teleport to tr1")
	end
	if trigger_name == "TRIGGER_RT_2" then
		TeleportUnitToPointName(hero, "TELEPORT_DIRE_2", true, true)
		trigger.caller:EmitSound("DOTA_Item.BlinkDagger.Activate") 
		print("teleport to tr2")
	end
	if trigger_name == "TRIGGER_DT_1" then
		TeleportUnitToPointName(hero, "TELEPORT_RADIANT_1", true, true)
		trigger.caller:EmitSound("DOTA_Item.BlinkDagger.Activate") 
		print("teleport to dt1")
	end
	if trigger_name == "TRIGGER_DT_2" then
		TeleportUnitToPointName(hero, "TELEPORT_RADIANT_2", true, true)
		trigger.caller:EmitSound("DOTA_Item.BlinkDagger.Activate") 
		print("teleport to dt2")
	end

end