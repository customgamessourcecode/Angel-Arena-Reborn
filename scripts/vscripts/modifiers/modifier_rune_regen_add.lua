modifier_rune_regen_add = class({})

function modifier_rune_regen_add:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE ,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE ,
		MODIFIER_EVENT_ON_TAKEDAMAGE, 
	}
 
	return funcs
end

function modifier_rune_regen_add:GetModifierPercentageManaRegen(params)
	return 4
end

function modifier_rune_regen_add:GetModifierHealthRegenPercentage(params)
	return 4
end

function modifier_rune_regen_add:IsHidden()
	return false
end

function modifier_rune_regen_add:IsPurgable()
	return true
end


function modifier_rune_regen_add:GetTexture()
	return "rune_regen"
end

function modifier_rune_regen_add:OnTakeDamage( params )
	if IsServer() then

        if params.unit ~= self:GetParent() then
        	return
        end

        self:Destroy() 
        
    end
end