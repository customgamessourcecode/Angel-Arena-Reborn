shadowsong_magic_fire = class({})

function shadowsong_magic_fire:IsHiddenWhenStolen() 		return false end

function shadowsong_magic_fire:OnSpellStart( ... )
	if not IsServer() then return end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	target:TriggerSpellReflect(self)

	target:EmitSound("Hero_Antimage.ManaBreak")

	local mana_to_burn = math.min(target:GetMana(), self:GetSpecialValueFor("manaburn"))

	ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )

	if target:TriggerSpellAbsorb(self) then return end

	SendOverheadEventMessage(caster, OVERHEAD_ALERT_MANA_LOSS, target, mana_to_burn, nil)
	
	target:ReduceMana(mana_to_burn)
	local damage_info = {
		victim = target,
		attacker = caster,
		damage = mana_to_burn,
		damage_type = DAMAGE_TYPE_MAGICAL
	}

	ApplyDamage(damage_info)
end