spike_heal = class({})
LinkLuaModifier( "modifier_spike_heal", "heroes/spike/heal/modifier_spike_heal", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function spike_heal:GetIntrinsicModifierName()
    return "modifier_spike_heal"
end

--------------------------------------------------------------------------------