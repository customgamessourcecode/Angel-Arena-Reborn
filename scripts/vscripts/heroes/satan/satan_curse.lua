satan_curse = class({})
LinkLuaModifier("modifier_satan_curse", "heroes/satan/modifier_satan_curse", LUA_MODIFIER_MOTION_NONE)

function satan_curse:IsHiddenWhenStolen() 		return false end

function satan_curse:OnSpellStart( ... )
	if not IsServer() then return end

	local caster 		= self:GetCaster()
	local target 		= self:GetCursorTarget()

	target:TriggerSpellReflect(self)

	caster:EmitSound("doom_bringer_doom_ability_doom_0" .. RandomInt(1,7))
	
	if target:TriggerSpellAbsorb(self) then return end

	local duration = self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster,self, "modifier_satan_curse", {duration = duration})
end

