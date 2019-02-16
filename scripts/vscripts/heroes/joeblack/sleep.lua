joe_black_sleep = class({})

LinkLuaModifier( "modifier_joe_black_sleep", 'heroes/joeblack/modifiers/modifier_joe_black_sleep', LUA_MODIFIER_MOTION_NONE )

function joe_black_sleep:OnSpellStart()
	local caster 			= self:GetCaster() 
	local target	= self:GetCursorTarget()

	if not target then return end

	if target:TriggerSpellAbsorb( self ) then
		return 
	end

	EmitSoundOn("Hero_Bane.Nightmare.Loop", caster)
	EmitSoundOn("Hero_Bane.Nightmare.Loop", target)

	if IsServer() then
		target:AddNewModifier(caster, self, "modifier_joe_black_sleep", {duration = self:GetSpecialValueFor("duration")})
	end
end