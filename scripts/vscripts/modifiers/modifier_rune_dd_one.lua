modifier_rune_dd_one = class({})

function modifier_rune_dd_one:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}
 
	return funcs
end

function modifier_rune_dd_one:GetModifierBaseDamageOutgoing_Percentage(params)
	return 60
end

function modifier_rune_dd_one:AllowIllusionDuplicate()
	return false
end

function modifier_rune_dd_one:IsHidden()
	return false
end

function modifier_rune_dd_one:IsPurgable()
	return true
end

function modifier_rune_dd_one:OnCreated(event)

end

function modifier_rune_dd_one:GetTexture()
	return "rune_doubledamage"
end