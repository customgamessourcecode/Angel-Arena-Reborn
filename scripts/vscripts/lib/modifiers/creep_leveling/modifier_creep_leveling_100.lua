modifier_creep_leveling_100 = class({})

function modifier_creep_leveling_100:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_EXTRA_MANA_BONUS,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}
 
	return funcs
end

function modifier_creep_leveling_100:IsHidden()
	return true
end

function modifier_creep_leveling_100:IsPurgable()
	return false
end

function modifier_creep_leveling_100:OnCreated(keys)
	local event = CustomNetTables:GetTableValue("creeps", "modifier_creep_leveling_100" )

	if not event then return end 

	self.hp 		= (event["hp"] or 0) - 100
	self.mp 		= (event["mp"] or 0) - 100
	self.bat 		= event["bat"]
	self.armor 		= event["armor"]
	self.damage 	= event["dmg_max"]
end

function modifier_creep_leveling_100:GetModifierExtraManaBonus(params)
	return self.mp
end

function modifier_creep_leveling_100:GetModifierExtraHealthBonus(params)
	return self.hp
end

function modifier_creep_leveling_100:GetModifierBaseAttack_BonusDamage(params)
	return self.damage 
end

function modifier_creep_leveling_100:GetModifierBaseAttackTimeConstant(params)
	return self.bat
end

function modifier_creep_leveling_100:GetModifierPhysicalArmorBonus(params)
	return self.armor
end
