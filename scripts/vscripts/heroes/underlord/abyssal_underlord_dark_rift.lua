abyssal_underlord_dark_rift = class({})

function abyssal_underlord_dark_rift:IsHiddenWhenStolen() 		return false end

function abyssal_underlord_dark_rift:GetAOERadius( ... )
	return self:GetSpecialValueFor("radius")
end

function abyssal_underlord_dark_rift:OnSpellStart()
	local caster = self:GetCaster()
	local vPoint = self:GetCursorPosition()

	local radius 			= self:GetSpecialValueFor("radius")
	local teleport_delay	= self:GetSpecialValueFor("teleport_delay")

	local part_name 		= "particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient.vpcf"
	local point_part_name 	= "particles/units/heroes/heroes_underlord/abyssal_underlord_darkrift_target.vpcf"

	caster:EmitSound("Hero_AbyssalUnderlord.DarkRift.Cast")
	EmitSoundOnLocationWithCaster(vPoint,"Hero_AbyssalUnderlord.DarkRift.Target", caster )

	local vPart_point = vPoint + Vector(0,0,100)
	local point_part = ParticleManager:CreateParticle(point_part_name, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( point_part, 0, vPart_point )
	ParticleManager:SetParticleControl( point_part, 1, vPart_point )
	ParticleManager:SetParticleControl( point_part, 2, vPart_point )
	ParticleManager:SetParticleControl( point_part, 3, vPart_point )
	ParticleManager:SetParticleControl( point_part, 5, vPart_point )
	ParticleManager:SetParticleControl( point_part, 20, vPart_point )

	local part = ParticleManager:CreateParticle(part_name, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl( part, 0, caster:GetOrigin() )
	ParticleManager:SetParticleControl( part, 1, Vector( radius, 1, 1 ) )
	ParticleManager:SetParticleControl( part, 2, caster:GetOrigin() )

	Timers:CreateTimer(teleport_delay, function()
		ParticleManager:DestroyParticle( part, false)
		ParticleManager:DestroyParticle(point_part, false)
		StopSoundOn("Hero_AbyssalUnderlord.DarkRift.Cast", caster)

		if caster:IsAlive() then
			local allies = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
		
			for _,ally in pairs(allies) do
				ally:SetAbsOrigin(vPoint)
				FindClearSpaceForUnit(ally, vPoint, true)
			end
			return nil
		end 
	end)
end