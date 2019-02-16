modifier_fireblade_weapon_ignition_buff = class({})


--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_buff:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_buff:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_buff:IsPermanent()
	return true
end

--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_buff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_buff:DestroyOnExpire()
	return true
end

--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end
--------------------------------------------------------------------------------

function modifier_fireblade_weapon_ignition_buff:OnAttackLanded(kv)
	if not IsServer() then return end

	local caster = self:GetCaster()
    if kv.attacker ~= caster then return end

   	local dmg_table = {
		victim = kv.target, 
		attacker = caster, 
		damage = self:GetAbility():GetSpecialValueFor("attack_constant") + caster:GetTalentSpecialValueFor("fireblade_talent_weapon_bonus_damage"),
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self:GetAbility(),
	}

	ApplyDamage(dmg_table)

	kv.target:AddNewModifier(caster, self:GetAbility(), "modifier_fireblade_weapon_ignition_debuff", 
		{ duration = self:GetAbility():GetSpecialValueFor("burn_duration") + caster:GetTalentSpecialValueFor("fireblade_talent_weapon_bonus_duration")})
end

--------------------------------------------------------------------------------
