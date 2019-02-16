item_vampire_claw = class({})
LinkLuaModifier("modifier_item_vampire_claw", 'items/vampire_claw/modifier_item_vampire_claw', LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function item_vampire_claw:GetIntrinsicModifierName()
    return "modifier_item_vampire_claw"
end
