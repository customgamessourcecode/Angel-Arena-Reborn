local talent_name = "joe_black_special_song"
local modifier_name = "modifier_joe_black_song_buff"

function OnSpellStart( keys )
	local caster = keys.caster 
	local target = keys.target
	local ability = keys.ability

	if caster:HasAbility(talent_name) and caster:FindAbilityByName(talent_name):GetLevel() ~= 0 then
		ability:ApplyDataDrivenModifier(caster, target, modifier_name, { duration = ability:GetSpecialValueFor("duration")})
	end
end