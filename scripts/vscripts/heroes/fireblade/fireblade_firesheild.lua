fireblade_firesheild = class({})

LinkLuaModifier( "modifier_fireblade_firesheild", 'heroes/fireblade/modifiers/modifier_fireblade_firesheild', LUA_MODIFIER_MOTION_NONE )

local sound_name = "Hero_EmberSpirit.FlameGuard.Loop"

function fireblade_firesheild:OnSpellStart( keys )
	if not IsServer() then return end
	
	local caster = self:GetCaster()

	local units = FindUnitsInRadius(caster:GetTeamNumber() , caster:GetAbsOrigin() , nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	for _,x in pairs(units) do 
		x:AddNewModifier(caster, self, "modifier_fireblade_firesheild", 
			{ 	duration = self:GetSpecialValueFor("duration"), 
				block_damage = self:GetSpecialValueFor("block_damage") + caster:GetTalentSpecialValueFor("fireblade_talent_sheild_block")
			}) 
		print(x:GetUnitName() )
	end
	print("block damage = ", self:GetSpecialValueFor("block_damage") + caster:GetTalentSpecialValueFor("fireblade_talent_sheild_block"))
	EmitSoundOn( sound_name, caster )
end