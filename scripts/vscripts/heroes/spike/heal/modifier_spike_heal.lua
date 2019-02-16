modifier_spike_heal = class({})

--------------------------------------------------------------------------------
function modifier_spike_heal:IsHidden()
    return true
end

--------------------------------------------------------------------------------
function modifier_spike_heal:IsDebuff()
    return false
end

--------------------------------------------------------------------------------
function modifier_spike_heal:OnCreated(kv)
    self.heal_per_sec = self:GetAbility():GetSpecialValueFor("heal_per_sec")
end

-------------------------------------------------------------------------------
function modifier_spike_heal:OnRefresh(kv)
    self.heal_per_sec = self:GetAbility():GetSpecialValueFor("heal_per_sec")
end

-------------------------------------------------------------------------------
function modifier_spike_heal:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
    }
    return funcs
end

-------------------------------------------------------------------------------
function modifier_spike_heal:GetModifierHealthRegenPercentage(params)
    if self:GetParent():PassivesDisabled() then return end
    return self.heal_per_sec
end

-------------------------------------------------------------------------------