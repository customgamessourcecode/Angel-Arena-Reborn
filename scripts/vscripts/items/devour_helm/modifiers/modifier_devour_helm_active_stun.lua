modifier_devour_helm_active_stun = class({})
--------------------------------------------------------------------------------

function modifier_devour_helm_active_stun:IsHidden()
	return true
end

--------------------------------------------------------------------------------


function modifier_devour_helm_active_stun:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_devour_helm_active_stun:DestroyOnExpire()
	return true
end

--------------------------------------------------------------------------------

function modifier_devour_helm_active_stun:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

--------------------------------------------------------------------------------

function modifier_devour_helm_active_stun:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
 
	return state
end
