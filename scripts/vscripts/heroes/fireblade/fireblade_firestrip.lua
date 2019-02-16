fireblade_firestrip = class({})

local sound_name = "Hero_EmberSpirit.SleightOfFist.Cast"
local tgt_sound_name = "Hero_EmberSpirit.SleightOfFist.Damage"
local particle_name = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf"
local tgt_particle_name =  "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf"

function fireblade_firestrip:OnSpellStart( keys )
	--if not IsServer() then return end
	local caster 			= self:GetCaster()
	local radius 			= self:GetSpecialValueFor("radius")
	local magical_damage 	= self:GetSpecialValueFor("bonus_damage")

	local damage 			= 0
	local fxIdx = ParticleManager:CreateParticle( particle_name, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( fxIdx, 0, caster:GetAbsOrigin()  )
	ParticleManager:SetParticleControl( fxIdx, 1, Vector( radius, 0, 0 ) )

	Timers:CreateTimer( 0.2, function()
			ParticleManager:DestroyParticle( fxIdx, false )
			ParticleManager:ReleaseParticleIndex( fxIdx )
		end
	)

	EmitSoundOn( sound_name, caster )
	EmitSoundOn( tgt_sound_name, caster )

	local _units = FindUnitsInRadius(caster:GetTeamNumber() , caster:GetAbsOrigin() , nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false) 
	
	if not _units then
		print("NO UNITS HERE")
		return 
	end

	for _, unit in pairs(_units) do

		damage = caster:GetAverageTrueAttackDamage(nil) 

		local damage_table = {
			victim = unit, 
			attacker = caster, 
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}

		if caster:HasTalent("fireblade_talent_firestrip_unique") then
			caster:PerformAttack(unit, true, true, true, false, true, false, false) 
			print("deal attack")
		else
			ApplyDamage(damage_table)
		end

		damage_table.damage = magical_damage
		damage_table.damage_type = self:GetAbilityDamageType() 

		ApplyDamage(damage_table)

		local fxIdx2 = ParticleManager:CreateParticle( tgt_particle_name, PATTACH_ABSORIGIN_FOLLOW, unit )

		Timers:CreateTimer( 0.2, function()
				ParticleManager:DestroyParticle( fxIdx2, false )
				ParticleManager:ReleaseParticleIndex( fxIdx2 )
				return nil
			end
		)
	end

end


local talent_name = "fireblade_talent_firestrip_cooldown"

function fireblade_firestrip:GetCooldown( nLevel )
	if IsServer() then
		local cd = self:GetSpecialValueFor("cooldown")

		if self:GetCaster():HasAbility(talent_name) then
			local talent_ability = self:GetCaster():FindAbilityByName(talent_name)
			
			cd = cd + talent_ability:GetSpecialValueFor("value")

			CustomNetTables:SetTableValue( "heroes", "fireblade_firestrip", {cooldown = cd } )

			return cd
		end
		return cd
	else
		local net_table = CustomNetTables:GetTableValue( "heroes", "fireblade_firestrip" )

		if(net_table) then
			return net_table.cooldown
		else
			return self.BaseClass.GetCooldown(self, nLevel)
		end
	end
end
