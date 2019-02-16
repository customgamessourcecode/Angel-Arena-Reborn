modifier_antivalve_perks_main_attribute = class({})

--------------------------------------------------------------------------------
function modifier_antivalve_perks_main_attribute:IsHidden() return true; end

--------------------------------------------------------------------------------
function modifier_antivalve_perks_main_attribute:IsPurgable() return false; end

--------------------------------------------------------------------------------
function modifier_antivalve_perks_main_attribute:DestroyOnExpire() return true; end

--------------------------------------------------------------------------------
function modifier_antivalve_perks_main_attribute:OnCreated(event) end
--------------------------------------------------------------------------------