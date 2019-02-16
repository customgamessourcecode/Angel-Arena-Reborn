modifier_warlock_golems = class({})

function modifier_warlock_golems:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
 
	return funcs
end

function modifier_warlock_golems:IsHidden()
	return true
end

function modifier_warlock_golems:IsPurgable()
	return false
end

function modifier_warlock_golems:GetModifierExtraHealthBonus(params)
	local time = GameRules:GetGameTime() / 60

	return 100*time
end

function modifier_warlock_golems:GetModifierBaseAttack_BonusDamage(params)
	local time = GameRules:GetGameTime() / 60


	return 15*time
end

function modifier_warlock_golems:GetModifierPhysicalArmorBonus(params)
	local time = GameRules:GetGameTime() / 60

	return time * 0.7
end

function modifier_warlock_golems:OnCreated(event)
end