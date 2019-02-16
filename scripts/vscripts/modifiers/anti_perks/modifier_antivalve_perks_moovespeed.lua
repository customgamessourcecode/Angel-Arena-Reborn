modifier_antivalve_perks_moovespeed = class({})
function modifier_antivalve_perks_moovespeed:DeclareFunctions() return
{
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
}
end

--------------------------------------------------------------------------------
function modifier_antivalve_perks_moovespeed:IsHidden() return true; end

function modifier_antivalve_perks_moovespeed:IsPurgable() return false; end

function modifier_antivalve_perks_moovespeed:DestroyOnExpire() return true; end

--------------------------------------------------------------------------------
function modifier_antivalve_perks_moovespeed:OnCreated(event)
end

--------------------------------------------------------------------------------
function modifier_antivalve_perks_moovespeed:GetModifierMoveSpeedBonus_Percentage(event)
    local parent = self:GetParent()
    local value_low_speed = self:GetParent():GetModifierStackCount("modifier_antivalve_perks_moovespeed", parent)
    local main_attribute = self:GetParent():GetModifierStackCount("modifier_antivalve_perks_main_attribute", parent)
    --                                1     2     3
    --                               STR   AGI   INT
    local movespeed_per_one_agi = { 0.05, 0.05, 0.05 }

    return -(value_low_speed * movespeed_per_one_agi[main_attribute])
end