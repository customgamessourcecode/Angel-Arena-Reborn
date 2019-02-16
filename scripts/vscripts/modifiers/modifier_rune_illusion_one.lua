modifier_rune_illusion_one = class({})

function modifier_rune_illusion_one:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
 
	return funcs
end

function modifier_rune_illusion_one:GetModifierBaseDamageOutgoing_Percentage(params)
	return 30
end

function modifier_rune_illusion_one:GetModifierMoveSpeedBonus_Constant(params)
	return 50
end

function modifier_rune_illusion_one:AllowIllusionDuplicate()
	return false
end

function modifier_rune_illusion_one:IsHidden()
	return false
end

function modifier_rune_illusion_one:IsPurgable()
	return true
end

function modifier_rune_illusion_one:OnCreated(params)

end

function modifier_rune_illusion_one:GetTexture()
	return "templar_assassin_self_trap"
end