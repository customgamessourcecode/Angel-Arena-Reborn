local particle_name 	= "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf"

function AbaddonCoilStart( event )
	-- Variables
	local caster 			= event.caster
	local target 			= event.target
	local ability 			= event.ability
	local damage_pct 		= ability:GetSpecialValueFor( "percent") / 100
	local damage 			= ability:GetSpecialValueFor( "target_damage" ) + Util:DisableSpellAmp(caster, caster:GetStrength()*damage_pct)
	local heal 				= ability:GetSpecialValueFor( "heal_amount" ) + caster:GetStrength()*damage_pct
	local projectile_speed 	= ability:GetSpecialValueFor( "missile_speed" )
	local self_damage 		= ability:GetSpecialValueFor( "self_damage" )

	-- Play the ability sound
	caster:EmitSound("Hero_Abaddon.DeathCoil.Cast")
	target:EmitSound("Hero_Abaddon.DeathCoil.Target")

	-- If the target and caster are on a different team, do Damage. Heal otherwise
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		--ApplyDamage({ victim = target, attacker = caster, damage = damage,	damage_type = DAMAGE_TYPE_MAGICAL })
		Util:DealPercentDamage(target, caster, DAMAGE_TYPE_MAGICAL, damage, damage_pct)
	else
		target:Heal( heal, caster)
	end
	ApplyDamage({ victim = caster, attacker = caster, damage = Util:DisableSpellAmp(caster, self_damage),	damage_type = DAMAGE_TYPE_MAGICAL })
	--Util:DealPercentDamage(caster, caster, DAMAGE_TYPE_MAGICAL, self_damage, damage_pct*caster:GetHealth() )

	-- Create the projectile
	local info = {
		Target = target,
		Source = caster,
		Ability = ability,
		EffectName = particle_name,
		bDodgeable = false,
			bProvidesVision = true,
			iMoveSpeed = projectile_speed,
        iVisionRadius = 0,
        iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( info )

end