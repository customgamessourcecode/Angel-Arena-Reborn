modifier_stun = class({})

function modifier_stun:IsHidden()
	return true
end

function modifier_stun:IsPurgable()
	return false
end

function modifier_stun:OnCreated()

end

function modifier_stun:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	[MODIFIER_STATE_INVISIBLE] = true,
	[MODIFIER_STATE_INVULNERABLE] = true,
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
 
	return state
end
