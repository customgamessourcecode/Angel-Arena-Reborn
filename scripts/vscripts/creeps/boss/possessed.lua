function PossessedCourage(event)
	local caster    = event.caster
	local damage    = event.Damage or 0
	local target    = event.attacker
	local ability   = event.ability
	local block_pct = event.BlockDamage / 100 or 0
	local radius    = event.Radius or 0
	if not caster or not target or not ability then return end
	if damage < 10 then return end

	caster:Heal(damage*block_pct, ability)

	local units = FindUnitsInRadius(target:GetOpposingTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false) 

	if not units then return end

	for i,x in pairs(units) do
		caster:PerformAttack(x, true, true, true, true, true, false, true) 
	end

end

function CheckHealth(event)
	local caster = event.caster
	local ability = event.ability
	local modifier_name_70 = event.modifier_70
	local modifier_name_50 = event.modifier_50
	local modifier_name_25 = event.modifier_25

	if not caster or not ability then return end

	local health = caster:GetHealth() 
	local max_health = caster:GetMaxHealth() 

	if not caster:HasModifier(modifier_name_70) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier_name_70, nil) 
	end
	
	if health/max_health < 0.5 then
		if not caster:HasModifier(modifier_name_50) then
			ability:ApplyDataDrivenModifier(caster, caster, modifier_name_50, nil) 
		end
	else
		caster:RemoveModifierByName(modifier_name_50)
	end

	if health/max_health < 0.25 then
		if not caster:HasModifier(modifier_name_25) then
			ability:ApplyDataDrivenModifier(caster, caster, modifier_name_25, nil) 
		end
	else
		caster:RemoveModifierByName(modifier_name_25)
	end
end


function CheckIlussion(event)
	local caster = event.attacker

	if not caster then end
	
	if caster:IsIllusion() then
		caster:ForceKill(true)
	end
end

