modifier_creep_leveling_80 = class({})

function modifier_creep_leveling_80:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_EXTRA_MANA_BONUS,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}
 
	return funcs
end

function modifier_creep_leveling_80:IsHidden()
	return true
end

function modifier_creep_leveling_80:IsPurgable()
	return false
end

function modifier_creep_leveling_80:OnCreated(keys)
	local event = CustomNetTables:GetTableValue("creeps", "modifier_creep_leveling_80" )

	if not event then return end 

	self.hp 		= (event["hp"] or 0) - 100
	self.mp 		= (event["mp"] or 0) - 100
	self.bat 		= event["bat"]
	self.armor 		= event["armor"]
	self.damage 	= event["dmg_max"]
end

function modifier_creep_leveling_80:GetModifierExtraManaBonus(params)
	return self.mp
end

function modifier_creep_leveling_80:GetModifierExtraHealthBonus(params)
	return self.hp
end

function modifier_creep_leveling_80:GetModifierBaseAttack_BonusDamage(params)
	return self.damage 
end

function modifier_creep_leveling_80:GetModifierBaseAttackTimeConstant(params)
	return self.bat
end

function modifier_creep_leveling_80:GetModifierPhysicalArmorBonus(params)
	return self.armor
end
