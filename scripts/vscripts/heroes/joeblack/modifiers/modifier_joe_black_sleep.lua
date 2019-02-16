modifier_joe_black_sleep = class({})

--------------------------------------------------------------------------------
function modifier_joe_black_sleep:IsHidden()
    return false
end

--------------------------------------------------------------------------------
function modifier_joe_black_sleep:IsPurgable()
    return true
end

--------------------------------------------------------------------------------
function modifier_joe_black_sleep:DestroyOnExpire()
    return true
end

--------------------------------------------------------------------------------
function modifier_joe_black_sleep:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }

    return funcs
end

--------------------------------------------------------------------------------
function modifier_joe_black_sleep:OnTakeDamage(params)
    if IsServer() then

        if params.unit ~= self:GetParent() then
            return
        end
        if (params.attacker:GetTeamNumber() ~= params.unit:GetTeamNumber()) then
            self:Destroy()
        end
    end
end

--------------------------------------------------------------------------------
function modifier_joe_black_sleep:GetEffectName()
    return "particles/units/heroes/hero_bane/bane_nightmare.vpcf"
end

--------------------------------------------------------------------------------
function modifier_joe_black_sleep:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------
function modifier_joe_black_sleep:GetPlaybackRateOverride()
    return self:GetAbility():GetSpecialValueFor("animation_rate")
end

--------------------------------------------------------------------------------
function modifier_joe_black_sleep:GetOverrideAnimation(params)
    return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------
function modifier_joe_black_sleep:CheckState()
    local state = {
        [MODIFIER_STATE_NIGHTMARED] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
        [MODIFIER_STATE_SPECIALLY_DENIABLE] = true,
    }

    return state
end
