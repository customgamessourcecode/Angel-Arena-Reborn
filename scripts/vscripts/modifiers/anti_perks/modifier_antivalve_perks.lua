modifier_antivalve_perks = class({})

--                                1       2       3
--                               STR     AGI     INT
local magresist_per_one_str = { 0.0800, 0.0800, 0.0800 }
local movespeed_per_one_agi = { 0.0500, 0.0500, 0.0500 }
-----------------------------------------------------------------------------
function modifier_antivalve_perks:AddStuckBuff(name, amount)
    local parent = self:GetParent()
    parent:AddNewModifier(parent, nil, name, { duration = -1 })
    parent:SetModifierStackCount(name, parent, amount)
end
--------------------------------------------------------------------------------
function modifier_antivalve_perks:IsHidden() return true; end

--------------------------------------------------------------------------------
function modifier_antivalve_perks:IsPurgable() return false; end

--------------------------------------------------------------------------------
function modifier_antivalve_perks:DestroyOnExpire() return true; end

--------------------------------------------------------------------------------
function modifier_antivalve_perks:OnCreated(kv)
    if not IsServer() then return end
    local parent = self:GetParent()
    Timers:CreateTimer("modifier_antivalve_perks" .. tostring(parent:entindex()), {
        useGameTime = false,
        endTime = 0.1,
        callback = function()
            if not parent:IsAlive() then return nil end
            self:AddStuckBuff("modifier_antivalve_perks_main_attribute", parent:GetPrimaryAttribute()+1)
            self:AddStuckBuff("modifier_antivalve_perks_moovespeed", parent:GetAgility())
            self:AddStuckBuff("modifier_antivalve_perks_mag_resist", parent:GetStrength())
            return 0.1
        end
    })
end

--------------------------------------------------------------------------------
function modifier_antivalve_perks:OnDestroy(params)
    if not IsServer() then return end
    Timers:RemoveTimer("modifier_antivalve_perks" .. tostring(self:GetParent():entindex()))
end
--------------------------------------------------------------------------------