fireblade_weapon_ignition = class({})

LinkLuaModifier( "modifier_fireblade_weapon_ignition_buff", 'heroes/fireblade/modifiers/modifier_fireblade_weapon_ignition_buff', LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_fireblade_weapon_ignition_debuff", 'heroes/fireblade/modifiers/modifier_fireblade_weapon_ignition_debuff', LUA_MODIFIER_MOTION_NONE )

local abilities = {
	["fireblade_smoldering"] = "fireblade_fiery_stream",
	["fireblade_weapon_ignition"] = "fireblade_weapon_quenching",
	["fireblade_firesheild"] = "fireblade_burn_offering",
}

function fireblade_weapon_ignition:OnSpellStart( keys )
	local caster = self:GetCaster()

	for ability_one, ability_two in pairs(abilities) do 
		if caster:HasAbility(ability_two) and caster:HasAbility(ability_one) then
			caster:SwapAbilities(ability_one, ability_two, false, true)
			
			local ability1 = caster:FindAbilityByName(ability_one)
			local ability2 = caster:FindAbilityByName(ability_two)
			
			if ability1:GetLevel() > ability2:GetLevel() then
				ability2:SetLevel(ability1:GetLevel()) 
			else
				ability1:SetLevel(ability2:GetLevel()) 
			end
		end
	end

	if not caster:HasTalent("fireblade_talent_ignition_no_dmg") then
		local dmg_table = {
			victim = caster, 
			attacker = caster, 
			damage = self:GetSpecialValueFor("activate_damage"),
			damage_type = self:GetAbilityDamageType(),
			ability = self,
			damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
		}

		ApplyDamage(dmg_table)

	end
	caster:AddNewModifier(caster, self, "modifier_fireblade_weapon_ignition_buff", {}) 

	caster.fx_l = ParticleManager:CreateParticle( "particles/dire_fx/fire_barracks_glow_b.vpcf", PATTACH_CUSTOMORIGIN, caster )
    ParticleManager:SetParticleControlEnt( caster.fx_l, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon_l" , caster:GetOrigin(), true )
    ParticleManager:SetParticleControlEnt( caster.fx_l, 1, caster, PATTACH_POINT_FOLLOW, "attach_weapon_l" , caster:GetOrigin(), true )
   	ParticleManager:SetParticleControlEnt( caster.fx_l, 2, caster, PATTACH_POINT_FOLLOW, "attach_weapon_l" , caster:GetOrigin(), true )

   	caster.fx_r = ParticleManager:CreateParticle( "particles/dire_fx/fire_barracks_glow_b.vpcf", PATTACH_CUSTOMORIGIN, caster )
    ParticleManager:SetParticleControlEnt( caster.fx_l, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon_r" , caster:GetOrigin(), true )
    ParticleManager:SetParticleControlEnt( caster.fx_l, 1, caster, PATTACH_POINT_FOLLOW, "attach_weapon_r" , caster:GetOrigin(), true )
   	ParticleManager:SetParticleControlEnt( caster.fx_l, 2, caster, PATTACH_POINT_FOLLOW, "attach_weapon_r" , caster:GetOrigin(), true )
end
