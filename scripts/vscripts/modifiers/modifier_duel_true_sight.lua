if modifier_duel_true_sight == nil then modifier_duel_true_sight = class({}) end

function modifier_duel_true_sight:CheckState()
	if self:GetParent():GetUnitName() == "npc_dota_techies_land_mine" then 
		return {}
	else 
		return { [MODIFIER_STATE_INVISIBLE] = false }
	end 
end

function modifier_duel_true_sight:IsHidden()
	return true
end

function modifier_duel_true_sight:IsPurgable()
	return false
end

function modifier_duel_true_sight:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end