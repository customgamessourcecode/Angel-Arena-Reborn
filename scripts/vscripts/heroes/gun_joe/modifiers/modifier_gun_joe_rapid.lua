modifier_gun_joe_rapid = class({})
--------------------------------------------------------------------------------

function modifier_gun_joe_rapid:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_gun_joe_rapid:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_gun_joe_rapid:DestroyOnExpire()
	return false
end

--------------------------------------------------------------------------------

function modifier_gun_joe_rapid:OnCreated( kv )
	if IsServer() then
		self:GetAbility():EndCooldown() 
	end

	self.cooldown 			= self:GetAbility():GetSpecialValueFor( "cooldown" )
	self.bonus_attackspeed 	= self:GetAbility():GetSpecialValueFor( "bonus_attackspeed" )
	self.bonus_movespeed 	= self:GetAbility():GetSpecialValueFor( "bonus_movespeed" )

end

--------------------------------------------------------------------------------

function modifier_gun_joe_rapid:OnRefresh( kv )
	self.cooldown 			= self:GetAbility():GetSpecialValueFor( "cooldown" )
	self.bonus_attackspeed 	= self:GetAbility():GetSpecialValueFor( "bonus_attackspeed" )
	self.bonus_movespeed 	= self:GetAbility():GetSpecialValueFor( "bonus_movespeed" )
end

--------------------------------------------------------------------------------

function modifier_gun_joe_rapid:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_gun_joe_rapid:GetModifierMoveSpeedBonus_Constant( params )
	if(self:GetParent():HasModifier("modifier_gun_joe_rapid_cd")) then
		return 0
	end

	return self.bonus_movespeed
end

--------------------------------------------------------------------------------

function modifier_gun_joe_rapid:GetModifierAttackSpeedBonus_Constant( params )
	if(self:GetParent():HasModifier("modifier_gun_joe_rapid_cd")) then
		return 0
	end
	

	return self.bonus_attackspeed
end

--------------------------------------------------------------------------------

function modifier_gun_joe_rapid:OnTakeDamage( params )
	  if IsServer() then

        if params.unit ~= self:GetParent() then
        	return
        end

        local talent_ability = self:GetParent():FindAbilityByName("gun_joe_special_bonus_rapid_cd")

        if params.attacker and not params.attacker:IsHero() then
        	return
        end 

	    if(talent_ability) then
	    	if(talent_ability:GetLevel() ~=0) then
	    		self.cooldown = self:GetAbility():GetSpecialValueFor("cooldown") + talent_ability:GetSpecialValueFor("value")
	    	end
	    end

	    self:GetAbility():StartCooldown(self.cooldown)
		self:GetCaster():AddNewModifier(self:GetCaster(), nil, "modifier_gun_joe_rapid_cd", {duration = self.cooldown} )
	end

	self:GetAbility():GetCooldown(self:GetAbility():GetLevel() )


	return 0
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------