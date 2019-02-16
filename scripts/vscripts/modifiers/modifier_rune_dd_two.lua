modifier_rune_dd_two = class({})

function modifier_rune_dd_two:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}
 
	return funcs
end

function modifier_rune_dd_two:GetModifierBaseDamageOutgoing_Percentage(params)
	return 300
end

function modifier_rune_dd_two:AllowIllusionDuplicate()
	return false
end

function modifier_rune_dd_two:IsHidden()
	return false
end

function modifier_rune_dd_two:IsPurgable()
	return true
end

function modifier_rune_dd_two:OnCreated(event)

end


function modifier_rune_dd_two:GetTexture()
	return "rune_doubledamage"
end