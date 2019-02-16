modifier_rune_illusion_two = class({})

function modifier_rune_illusion_two:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
 
	return funcs
end

function modifier_rune_illusion_two:GetModifierIncomingDamage_Percentage(params)
	return -15
end


function modifier_rune_illusion_two:AllowIllusionDuplicate()
	return false
end

function modifier_rune_illusion_two:IsHidden()
	return false
end

function modifier_rune_illusion_two:IsPurgable()
	return true
end

function modifier_rune_illusion_two:OnCreated(params)

end

function modifier_rune_illusion_two:GetTexture()
	return "templar_assassin_self_trap"
end