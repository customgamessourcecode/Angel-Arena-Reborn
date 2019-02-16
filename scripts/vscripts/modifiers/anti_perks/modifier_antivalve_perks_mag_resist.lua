modifier_antivalve_perks_mag_resist = class({})
function modifier_antivalve_perks_mag_resist:DeclareFunctions() return
{
    MODIFIER_EVENT_ON_TAKEDAMAGE,
}
end

--------------------------------------------------------------------------------
function modifier_antivalve_perks_mag_resist:IsHidden() return true; end

function modifier_antivalve_perks_mag_resist:IsPurgable() return false; end

function modifier_antivalve_perks_mag_resist:DestroyOnExpire() return true; end

--------------------------------------------------------------------------------
function modifier_antivalve_perks_mag_resist:OnCreated(event)
end

--------------------------------------------------------------------------------
function modifier_antivalve_perks_mag_resist:OnTakeDamage(params)
    if not IsServer() then return end
    if params.damage_type ~= DAMAGE_TYPE_MAGICAL then return end
    if params.unit ~= self:GetParent() then return end
    local parent = self:GetParent()
    --                                1       2       3
    --                               STR     AGI     INT
    local magresist_per_one_str = { 0.0800, 0.0800, 0.0800 }
    local main_attribute = self:GetParent():GetModifierStackCount("modifier_antivalve_perks_main_attribute", parent)
    local value_low_speed = self:GetParent():GetModifierStackCount("modifier_antivalve_perks_mag_resist", parent)

    -- Резист от силы
    local add_resist = (magresist_per_one_str[main_attribute] * value_low_speed) / 100

    -- резист от всех источников
    local mag_resist_current = self:GetParent():GetMagicalArmorValue()

    -- резист от всех источников за исключением силы(см. формулу сопротивления магии из дотки)
    local mag_resist_real = mag_resist_current / (1 - add_resist) + (1 - (1 / (1 - add_resist)))

    local damage_already_dealed = params.original_damage * (1 - mag_resist_current)

    -- clamp value between [0, +inf]
    if damage_already_dealed < 0 then damage_already_dealed = 0 end

    local damage = (params.original_damage * (1 - mag_resist_real)) - damage_already_dealed
    -----------------------------------------------------------------------------------------------------
    ------------------------------ Костыль для батрайдера -----------------------------------------------
    -----------------------------------------------------------------------------------------------------
    if params.inflictor and params.attacker and (params.inflictor:GetName() == "batrider_sticky_napalm") then
        return
    end
    -----------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------

    ApplyDamage({
        victim = params.unit,
        attacker = params.attacker,
        damage = damage,
        damage_type = DAMAGE_TYPE_PURE,
        ability = params.ability
    })
end