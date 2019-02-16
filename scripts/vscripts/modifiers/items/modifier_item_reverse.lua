modifier_item_reverse = class({})

function modifier_item_reverse:DeclareFunctions() return 
{
	MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	MODIFIER_PROPERTY_MOVESPEED_LIMIT,
}
end

function modifier_item_reverse:GetModifierMoveSpeed_Limit(params)
	return 1000
end

function modifier_item_reverse:GetModifierIgnoreMovespeedLimit(params)
	return true
end

function modifier_item_reverse:AllowIllusionDuplicate()
	return false
end

function modifier_item_reverse:IsHidden()
	return true
end

function modifier_item_reverse:IsPurgable()
	return true
end

function modifier_item_reverse:OnCreated(params)
end
