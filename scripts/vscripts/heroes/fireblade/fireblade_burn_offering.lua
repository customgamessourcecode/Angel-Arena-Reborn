function SoulBurnStart( keys )
	local caster 		= keys.caster 
	local target 		= keys.target
	local damage 		= keys.Damage 

	if caster:HasTalent("fireblade_talent_burn_offering_damage") then
		damage = damage + caster:GetAverageTrueAttackDamage(nil) 
	end

	local damage_int_pct_add = 1
	if caster:IsRealHero() then
		damage_int_pct_add = caster:GetIntellect()
		damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
	end 


	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
end
