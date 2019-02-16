modifier_item_vampire_claw = class({})
--------------------------------------------------------------------------------
function modifier_item_vampire_claw:IsHidden()
    return true
end

--------------------------------------------------------------------------------
function modifier_item_vampire_claw:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
function modifier_item_vampire_claw:DestroyOnExpire()
    return false
end

--------------------------------------------------------------------------------
function modifier_item_vampire_claw:IsHidden()
    return true
end

-----------------------------------------------------------------------------
function modifier_item_vampire_claw:OnCreated(kv)
    self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
    self.lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal")
    self.armor_dis_coef = self:GetAbility():GetSpecialValueFor("armor_dis_coef")
end

--------------------------------------------------------------------------------
function modifier_item_vampire_claw:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

--------------------------------------------------------------------------------
function modifier_item_vampire_claw:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

--------------------------------------------------------------------------------
function modifier_item_vampire_claw:GetModifierPreAttack_BonusDamage(kv)
    return self.bonus_damage;
end

-------------------------------------------------------------------------------
function modifier_item_vampire_claw:OnAttackLanded(params)
    if self:GetParent():PassivesDisabled() then return end
    if not IsServer() then return end
    if self:GetParent() == params.attacker then
        local target = params.target
        local armor_value = target:GetPhysicalArmorValue()
        local armor = 0.05 * armor_value / (1 + 0.05 * math.abs(armor_value)) * self.armor_dis_coef
        if armor < 0 then armor = 0 end
        local steal = params.damage * (self.lifesteal / 100)
        steal = steal - steal * armor
        params.attacker:Heal(steal, self)
        local particle = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_OVERHEAD_FOLLOW, params.attacker)
        ParticleManager:SetParticleControl(particle, 0, params.attacker:GetAbsOrigin())
        SendOverheadEventMessage(params.unit, OVERHEAD_ALERT_HEAL, params.attacker, steal, nil)
    end
end

-------------------------------------------------------------------------------