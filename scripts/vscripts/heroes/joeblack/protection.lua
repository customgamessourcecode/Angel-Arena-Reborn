LinkLuaModifier( "modifier_joe_black_protection_lua", 'heroes/joeblack/modifiers/modifier_joe_black_protection_lua', LUA_MODIFIER_MOTION_NONE )

local talent_name = "joe_black_special_protection"
local talent_modifier = "modifier_joe_black_protection_lua"


function OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target 
	target:Purge(false, true, false, true, false )
	while(target:HasModifier("modifier_huskar_burning_spear_counter")) do
		target:RemoveModifierByName("modifier_huskar_burning_spear_counter")
	end
	target:RemoveModifierByName("modifier_huskar_burning_spear_debuff")
	target:RemoveModifierByName("modifier_dazzle_weave_armor")
	target:RemoveModifierByName("modifier_dazzle_weave_armor_debuff")

	if caster:HasAbility(talent_name) and caster:FindAbilityByName(talent_name):GetLevel() ~= 0 then
		print("apply spell immune")
		target:AddNewModifier(caster, nil, talent_modifier, {duration = keys.ability:GetSpecialValueFor("duration") } ) 
	end
end