local talent_name = "satan_special_bonus_might_nocd"

function OnTakeDamage( keys )
	local cd = keys.ability:GetCooldownTimeRemaining() 
	
	if cd > 0 then return end

	if not RollPercentage(keys.chance) then return end

	local caster = keys.caster 
	local target = keys.attacker
	local range = keys.ability:GetSpecialValueFor("radius")
	
	if not caster:IsRealHero() or not target then return end
	if caster == target then return end
	if caster:PassivesDisabled() then return end
	if target:IsMagicImmune() then return end
	
	if not caster:HasTalent(talent_name) then
		keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel() - 1))
	end
	
	if ( (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D() > range )	then return end

	keys.ability:ApplyDataDrivenModifier(caster, target, keys.modifier_name, {duration = keys.ability:GetSpecialValueFor("stun_duration")})
end