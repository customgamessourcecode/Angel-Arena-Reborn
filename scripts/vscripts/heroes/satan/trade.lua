local talent_name_damage = "satan_special_bonus_trade_damage"
local talent_name_duration = "satan_special_bonus_trade_duration"

function OnSpellStart( keys )
	local caster 		= keys.caster 
	local modifier_name = keys.modifier_name
	local ability 		= keys.ability
	local damage 		= (ability:GetSpecialValueFor("health_lose") or 0) / 100
	local damage_total 	= (ability:GetSpecialValueFor("damage_get") or 0) / 100
	local duration  	= ability:GetSpecialValueFor("duration") or 0
	local damage_int_pct_add = 1

	if caster:IsRealHero() then
		damage_int_pct_add = caster:GetIntellect()
		damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
	end 
	
	if caster:HasTalent(talent_name_damage) then
		local talent_ability = caster:FindAbilityByName(talent_name_damage)

		damage_total = damage_total + (talent_ability:GetSpecialValueFor("value") or 0) / 100
	end

	if caster:HasTalent(talent_name_duration) then
		local talent_ability = caster:FindAbilityByName(talent_name_duration)

		duration = duration + talent_ability:GetSpecialValueFor("value") or 0
	end

	damage = (caster:GetMaxHealth()*damage)

	ApplyDamage({ victim = caster, attacker = caster, damage = damage / damage_int_pct_add, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})

	damage_total = damage * damage_total

	caster:RemoveModifierByName(modifier_name)

	ability:ApplyDataDrivenModifier(caster, caster, modifier_name, {duration = duration}) 

	caster:SetModifierStackCount(modifier_name, caster, damage_total)
end