modifier_rune_haster_max = class({})

function modifier_rune_haster_max:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_MAX ,
	}
 
	return funcs
end

function modifier_rune_haster_max:GetModifierMoveSpeed_Max(params)
	return 5220
end

function modifier_rune_haster_max:AllowIllusionDuplicate()
	return false
end

function modifier_rune_haster_max:IsHidden()
	return false
end

function modifier_rune_haster_max:IsPurgable()
	return true
end

function modifier_rune_haster_max:OnCreated(params)

end

function modifier_rune_haster_max:GetTexture()
	return "rune_haste"
end