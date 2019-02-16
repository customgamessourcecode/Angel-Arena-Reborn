modifier_visage_familiars = class({})

function modifier_visage_familiars:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
 
	return funcs
end

function modifier_visage_familiars:IsHidden()
	return true
end

function modifier_visage_familiars:IsPurgable()
	return false
end

function modifier_visage_familiars:GetModifierBaseAttack_BonusDamage(params)
	local time = GameRules:GetGameTime()

	if time >= 600 then
		if time >= 3600 then time = 3600 end 

		return time/30 - time/150 
	end 

	return 0
end

function modifier_visage_familiars:GetModifierExtraHealthBonus(params)
	local time = GameRules:GetGameTime()

	if time >= 600 then
		if time >= 3600 then time = 3600 end 

		return 0.6*time - 5 math.sqrt(time)
	end 

	return 0 
end

function modifier_visage_familiars:GetModifierPhysicalArmorBonus(params)
	local time = GameRules:GetGameTime()

	if time >= 600 then
		if time >= 3600 then time = 3600 end 

		return 0.7*(time/100) - 1000/time)
	end 

	return 0 
end