modifier_joe_black_protection_lua = class({})

--------------------------------------------------------------------------------

function modifier_joe_black_protection_lua:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_joe_black_protection_lua:IsPurgable()
	return true
end

--------------------------------------------------------------------------------

function modifier_joe_black_protection_lua:DestroyOnExpire()
	return true
end

--------------------------------------------------------------------------------
function modifier_joe_black_protection_lua:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}

	return state
end