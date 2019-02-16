fireblade_smoldering = class({})
--LinkLuaModifier( "modifier_fireblade_smoldering", 'heroes/gun_joe/modifiers/modifier_fireblade_smoldering', LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

local talent_name_1 = "modifier_fireblade_smoldering_talent"

--local particle_name = "particles/units/heroes/hero_ember_spirit/ember_spirit_hit_warp.vpcf"
local particle_name = "particles/units/heroes/hero_nevermore/nevermore_shadowraze_ember.vpcf"
local sound_name = "Hero_EmberSpirit.FireRemnant.Create"

function fireblade_smoldering:OnSpellStart( keys )
	local caster = self:GetCaster()
	local heal_const = self:GetSpecialValueFor("heal_const")
	local heal_percent = self:GetSpecialValueFor("heal_percent") / 100

	local heal = caster:GetMaxMana() * heal_percent + heal_const

	

	if caster:HasTalent("fireblade_talent_smoldering_half_mana") then
		if heal / 2 > caster:GetMana() then
			heal = caster:GetMana() 
		end

		caster:SpendMana(heal / 2, self)
	else 
		if heal > caster:GetMana() then
			heal = caster:GetMana() 
		end
		caster:SpendMana(heal, self)
	end

	caster:Heal(heal, self)

	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, Vector(150,0,0))
	EmitSoundOn(sound_name, caster)
end

--[[
function fireblade_smoldering:GetCooldown( nLevel )
	if IsServer() then
		local cd = self:GetSpecialValueFor("cooldown")

		if self:GetCaster():HasAbility(talent_name_1) then
			local talent_ability = self:GetCaster():FindAbilityByName(talent_name_1)
			
			cd = cd + talent_ability:GetSpecialValueFor("value")

			CustomNetTables:SetTableValue( "heroes", "fireblade", {cooldown = cd } )

			return cd
		end
		return cd
	else
		local net_table = CustomNetTables:GetTableValue( "heroes", "fireblade" )

		if(net_table) then
			return net_table.cooldown
		else
			return self.BaseClass.GetCooldown(self, nLevel)
		end
	end
end
]]