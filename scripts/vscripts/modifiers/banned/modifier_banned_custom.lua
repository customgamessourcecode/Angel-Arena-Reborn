modifier_banned_custom = class({})

--------------------------------------------------------------------------------
function modifier_banned_custom:IsHidden()
    return false
end

--------------------------------------------------------------------------------
function modifier_banned_custom:OnCreated(event)
end

--------------------------------------------------------------------------------
function modifier_banned_custom:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
function modifier_banned_custom:GetTexture()
    return "shadow_shaman_voodoo"
end

--------------------------------------------------------------------------------
function modifier_banned_custom:GetEffectName()
    return "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle_body.vpcf"
end

--------------------------------------------------------------------------------
function modifier_banned_custom:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }
    return state
end

--------------------------------------------------------------------------------