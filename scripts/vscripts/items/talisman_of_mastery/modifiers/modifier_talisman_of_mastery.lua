modifier_talisman_of_mastery = class({})
--------------------------------------------------------------------------------

function modifier_talisman_of_mastery:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_talisman_of_mastery:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_talisman_of_mastery:DestroyOnExpire()
	return false
end

--------------------------------------------------------------------------------

function modifier_talisman_of_mastery:OnCreated( kv )
    self.bonus_hp_regen = self:GetAbility():GetSpecialValueFor("bonus_hp_regen")
    self.bonus_str = self:GetAbility():GetSpecialValueFor("bonus_str")
    self.bonus_attack = self:GetAbility():GetSpecialValueFor("bonus_attack")
end

function modifier_talisman_of_mastery:GetAttributes() 
    return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT
end

--------------------------------------------------------------------------------

function modifier_talisman_of_mastery:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_talisman_of_mastery:GetModifierConstantHealthRegen( params )
	return self.bonus_hp_regen or 0
end

--------------------------------------------------------------------------------

function modifier_talisman_of_mastery:GetModifierBonusStats_Strength( params )
	return self.bonus_str or 0
end

--------------------------------------------------------------------------------

function modifier_talisman_of_mastery:GetModifierPreAttack_BonusDamage( params )
	return self.bonus_attack or 0
end

--------------------------------------------------------------------------------

function modifier_talisman_of_mastery:OnTakeDamage( params )
	if IsServer() then
        if params.attacker ~= self:GetParent() then
        	return
        end

        if not params.attacker:IsRealHero() or not params.unit:IsRealHero() or params.unit:GetTeamNumber() == params.attacker:GetTeamNumber() then return end

        if self:GetAbility():GetCooldownTimeRemaining() ~= 0 then return end
        
        if params.damage < 10 then return end
       
        for i = 0, 5 do
            if self:GetCaster():GetItemInSlot(i) and self:GetCaster():GetItemInSlot(i):GetName() == self:GetAbility():GetName() then
                if self:GetAbility() ~= self:GetCaster():GetItemInSlot(i) then
                    return
                else
                    break
                end
            end
        end

        local dmg_to_exp = self:GetAbility():GetSpecialValueFor("damage_to_exp") or 0
        local min_exp = self:GetAbility():GetSpecialValueFor("min_exp") or 0 
        local max_exp = self:GetAbility():GetSpecialValueFor("max_exp") or 0

        if not params.attacker:IsRangedAttacker() then 
            min_exp = min_exp * 2
            max_exp = max_exp * 2
            dmg_to_exp = dmg_to_exp * 2
        end

        if( (dmg_to_exp / 100) * params.damage < min_exp) then
             params.attacker:AddExperience(min_exp, 0, true, true)   
        else 
            if( (max_exp / 100) * params.damage > max_exp) then
                 params.attacker:AddExperience(max_exp, 0, true, true)   
            else
                 params.attacker:AddExperience((dmg_to_exp/ 100) * params.damage , 0, true, true)
            end
        end

        self:GetAbility():StartCooldown(2.5)
	end
	return 0
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------