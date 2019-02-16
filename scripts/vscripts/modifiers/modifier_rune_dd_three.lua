modifier_rune_dd_three = class({})

function modifier_rune_dd_three:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
 
	return funcs
end

function modifier_rune_dd_three:GetModifierIncomingDamage_Percentage(params)
	return -10
end

function modifier_rune_dd_three:AllowIllusionDuplicate()
	return false
end

function modifier_rune_dd_three:IsHidden()
	return false
end

function modifier_rune_dd_three:IsPurgable()
	return true
end

function modifier_rune_dd_three:OnCreated(event)

end

function modifier_rune_dd_three:GetTexture()
	return "rune_doubledamage"
end