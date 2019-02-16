joe_black_face_of_death = class({})

local talent_name_1 = "joe_black_special_unique_cooldown"
local talent_name_2 = "joe_black_special_unique_aoe"

function joe_black_face_of_death:GetAOERadius()
	radius = 0;

	local net_table = CustomNetTables:GetTableValue( "heroes", "joe_black_face_of_death_talent_2" )

	if(net_table) then
		radius = net_table.radius
	end

	return radius
end

function joe_black_face_of_death:GetCooldown( nLevel )
	local cd = self.BaseClass.GetCooldown(self, nLevel)

	local net_table = CustomNetTables:GetTableValue( "heroes", "joe_black_face_of_death" )

	if(net_table) then
		cd = net_table.cooldown
	end

	return cd 
end

function joe_black_face_of_death:OnAbilityPhaseStart()
	if self:GetCaster():HasAbility(talent_name_1) then
		local talent_ability = self:GetCaster():FindAbilityByName(talent_name_1)
	
		if talent_ability:GetLevel() ~= 0 then
			cd = talent_ability:GetSpecialValueFor("value")

			CustomNetTables:SetTableValue( "heroes", "joe_black_face_of_death", { cooldown = cd } )
		end
	end

	if self:GetCaster():HasAbility(talent_name_2) then
		local talent_ability = self:GetCaster():FindAbilityByName(talent_name_2)
	
		if talent_ability:GetLevel() ~= 0 then
			radius = talent_ability:GetSpecialValueFor("value")

			CustomNetTables:SetTableValue( "heroes", "joe_black_face_of_death_talent_2", { radius = radius } )
		
		end
	end

	return true
end

function joe_black_face_of_death:OnSpellStart()
	local caster 			= self:GetCaster() 
	local original_target	= self:GetCursorTarget()
	local projectile_speed 	= self:GetSpecialValueFor( "projectile_speed" )	
	local cd = self:GetCooldown(self:GetLevel()) 
	local radius 			= self:GetAOERadius()

	EmitSoundOn("Hero_Abaddon.DeathCoil.Cast", caster)
	EmitSoundOn("Hero_Abaddon.DeathCoil.Target", target)

	local units = FindUnitsInRadius(caster:GetTeamNumber() , original_target:GetAbsOrigin() , nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	for _, target in pairs(units) do 

		local info = {
			Target = target,
			Source = caster,
			Ability = self,
			EffectName = "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf",
			bDodgeable = false,
			bProvidesVision = true,
			iMoveSpeed = projectile_speed,
	        iVisionRadius = 0,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}

		ProjectileManager:CreateTrackingProjectile( info )

		if IsServer() then
			local damage_pct 		= self:GetSpecialValueFor( "heal_percent") / 100
			local heal 				= self:GetSpecialValueFor( "damage" ) + caster:GetIntellect()*damage_pct

			if target:GetTeamNumber() ~= caster:GetTeamNumber() then
				target:TriggerSpellReflect(self)
				
				if not target:TriggerSpellAbsorb( self ) then 
					Util:DealPercentDamage(target, caster, DAMAGE_TYPE_MAGICAL, heal, 0)
				end
			else
				target:Heal( heal, caster )
			end
			
		end
	end
end