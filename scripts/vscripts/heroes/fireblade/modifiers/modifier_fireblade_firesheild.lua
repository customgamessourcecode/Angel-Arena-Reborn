modifier_fireblade_firesheild = class({})
--------------------------------------------------------------------------------

function modifier_fireblade_firesheild:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function modifier_fireblade_firesheild:OnCreated( keys )
	local unit = self:GetParent()

	self.block_damage = keys.block_damage
	self.taked_damage = 0
	--self.fx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)

	--ParticleManager:SetParticleControlEnt( self.fx, 0, unit, PATTACH_ABSORIGIN_FOLLOW, nil, unit:GetAbsOrigin(), false )
	--ParticleManager:SetParticleControlEnt( self.fx, 1, unit, PATTACH_ABSORIGIN_FOLLOW, nil, unit:GetAbsOrigin(), false )
	--ParticleManager:SetParticleControlEnt( self.fx, 2, unit, PATTACH_ABSORIGIN_FOLLOW, nil, unit:GetAbsOrigin(), false )
	--ParticleManager:SetParticleControlEnt( self.fx, 3, unit, PATTACH_ABSORIGIN_FOLLOW, nil, unit:GetAbsOrigin(), false )
	--ParticleManager:SetParticleControlEnt( self.fx, 4, unit, PATTACH_ABSORIGIN_FOLLOW, nil, unit:GetAbsOrigin(), false )
	
end

--------------------------------------------------------------------------------

function modifier_fireblade_firesheild:IsPurgable()
	return false
end

function modifier_fireblade_firesheild:GetEffectName()
	return "particles/econ/items/phoenix/phoenix_solar_forge/phoenix_solar_forge_ambient.vpcf"
end

--------------------------------------------------------------------------------

function modifier_fireblade_firesheild:DestroyOnExpire()
	return true
end

--------------------------------------------------------------------------------

function modifier_fireblade_firesheild:OnDestroy()
	--ParticleManager:DestroyParticle(self.fx, true)
	self.taked_damage = nil
	self.block_damage = nil
	--self.fx = nil
end

--------------------------------------------------------------------------------

function modifier_fireblade_firesheild:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function modifier_fireblade_firesheild:OnTakeDamage( params )
	if IsServer() then
        if params.unit ~= self:GetParent() then
        	return
        end

        local unit = self:GetParent()
        local ability = self:GetAbility()

        if self.taked_damage + params.damage > self.block_damage then
        	unit:Heal( self.block_damage - self.taked_damage, ability ) 
        	self:Destroy() 
		else
			unit:Heal( params.damage, ability )
			self.taked_damage = self.taked_damage + params.damage
       	end
       
       	
	end

	return 0
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------