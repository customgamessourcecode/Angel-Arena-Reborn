modifier_fireblade_weapon_ignition_debuff = class({})


--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_debuff:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_debuff:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_debuff:IsPurgable()
	return true
end

--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_debuff:DestroyOnExpire()
	return true
end

--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_debuff:OnCreated( kv )
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor( "burn_damage" )

		self:StartIntervalThink( 1 )
		self:OnIntervalThink()
	end
end

--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_debuff:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_debuff:OnIntervalThink()
	if IsServer() then
		if self:GetCaster():IsAlive() then
			local damage = {
				victim = self:GetParent(),
				attacker = self:GetCaster(),
				damage = self.damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = self:GetAbility()
			}

			ApplyDamage( damage )
		end
	end
end