fireblade_weapon_quenching = class({})

local abilities = {
	["fireblade_smoldering"] = "fireblade_fiery_stream",
	["fireblade_weapon_ignition"] = "fireblade_weapon_quenching",
	["fireblade_firesheild"] = "fireblade_burn_offering",
}

function fireblade_weapon_quenching:OnSpellStart( keys )
	local caster = self:GetCaster()

	for ability_two, ability_one in pairs(abilities) do 

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
	caster:RemoveModifierByName("modifier_fireblade_weapon_ignition_buff") 

	if caster.fx_l then
		ParticleManager:DestroyParticle(caster.fx_l, true)
		caster.fx_l = nil
	end

	if caster.fx_r then
		ParticleManager:DestroyParticle(caster.fx_r, true)
		caster.fx_r = nil
	end
end
