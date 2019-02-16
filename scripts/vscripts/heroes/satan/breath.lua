local talent_name = "satan_special_bonus_breath_damage"

function DealDamage( keys )
	local damage = keys.damage or 0

	if keys.caster:HasTalent(talent_name) then
		damage = damage + keys.caster:GetTalentSpecialValueFor(talent_name)
	end

	damage = damage + keys.caster:GetStrength() * (keys.damage_from_str / 100)

	if not keys.target:IsHero() and not keys.target:IsAncient() and not keys.target:IsSummoned() then
		local multipler = keys.creep_mult
		
		if IsUnitBossGlobal(keys.target) then 
			multipler = multipler / 4 
		end

		ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = damage * multipler, damage_type = DAMAGE_TYPE_MAGICAL})
	else
		ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end