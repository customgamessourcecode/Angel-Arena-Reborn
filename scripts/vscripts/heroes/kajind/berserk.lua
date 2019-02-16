function OnAttack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = keys.Damage / 100

	if caster:IsIllusion() then return end

	local damage_int_pct_add = caster:GetIntellect()

	if damage_int_pct_add then
		damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
	else
		damage_int_pct_add = 1;
	end

	local total_damage = Util:DisableSpellAmp(caster, target:GetHealth() * damage) 


	if IsUnitBossGlobal(target) then 
		total_damage = total_damage / 2
	end

	ApplyDamage({ victim = target, attacker = caster, damage = total_damage,	damage_type = DAMAGE_TYPE_PURE }) 

end
