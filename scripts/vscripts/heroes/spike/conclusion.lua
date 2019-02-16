local forbidden_refresh = {
	["item_refresher"] 					= 1,
	["item_recovery_orb"]				= 1,	
}

function OnSpellStart( keys ) 
	local caster = keys.caster
	local ability = keys.ability

	caster:Purge(false, true, false, true, false )
	while(caster:HasModifier("modifier_huskar_burning_spear_counter")) do
		caster:RemoveModifierByName("modifier_huskar_burning_spear_counter")
	end
	caster:RemoveModifierByName("modifier_huskar_burning_spear_debuff")
	caster:RemoveModifierByName("modifier_dazzle_weave_armor")
	caster:RemoveModifierByName("modifier_dazzle_weave_armor_debuff")

	ability.list = {}

	for i = 0, caster:GetAbilityCount() - 1 do
		local refresh_ability = caster:GetAbilityByIndex(i)
		
		if refresh_ability and refresh_ability ~= ability and not forbidden_refresh[refresh_ability:GetName()] then
			if(refresh_ability:GetCooldownTimeRemaining() > 0) then
				ability.list[refresh_ability:GetName()] = refresh_ability:GetCooldownTimeRemaining() 
			end

			refresh_ability:EndCooldown()
		end

	end

	for i = 0, 11 do
		local refresh_item = caster:GetItemInSlot(i)
		
		if refresh_item and refresh_ability ~= ability and not forbidden_refresh[refresh_item:GetName()]  then
			if(refresh_item:GetCooldownTimeRemaining() > 0) then
				ability.list[refresh_item:GetName()] = refresh_item:GetCooldownTimeRemaining() 
			end

			refresh_item:EndCooldown()
		end

	end
	Util:PrintKeys(ability.list)
end

function Active_OnDestroy( keys )
	local caster = keys.caster 
	local ability = keys.ability 

	for i = 0, caster:GetAbilityCount() - 1 do
		local refresh_ability = caster:GetAbilityByIndex(i)
		
		if refresh_ability then
			if(refresh_ability:GetCooldownTimeRemaining() < 1) and ability.list[refresh_ability:GetName()]  then
				refresh_ability:StartCooldown( ability.list[refresh_ability:GetName()] )
			end
		end

	end

	for i = 0, 11 do
		local refresh_item = caster:GetItemInSlot(i)
		
		if refresh_item then
			if(refresh_item:GetCooldownTimeRemaining() < 1) and ability.list[refresh_item:GetName()] then
				refresh_item:StartCooldown( ability.list[refresh_item:GetName()] )
			end
		end

	end
end

function Active_CooldownIncrease( keys )
	local ability = keys.event_ability
	local multipler = keys.Multipler / 100
	print("new cd = ", ability:GetCooldown(ability:GetLevel() - 1) )
	ability:EndCooldown() 
	ability:StartCooldown(multipler * ability:GetCooldown(ability:GetLevel() - 1) )
end
