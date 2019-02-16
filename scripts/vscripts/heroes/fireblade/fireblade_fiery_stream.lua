fireblade_fiery_stream = class({})

LinkLuaModifier( "modifier_fireblade_fiery_stream_buff", 'heroes/fireblade/modifiers/modifier_fireblade_fiery_stream_buff', LUA_MODIFIER_MOTION_NONE )

local buff_name = "modifier_fireblade_fiery_stream_buff"

function fireblade_fiery_stream:OnSpellStart( kv )
	local caster = self:GetCaster()
	local vPos = self:GetCursorPosition()
	local distance = self:GetSpecialValueFor("distantion")
	local vDirection = vPos - caster:GetOrigin()

	self.damage = self:GetSpecialValueFor("damage")
	self.buff_duration = self:GetSpecialValueFor("buff_duration")

	local info = {
		EffectName = "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
		Ability = self,
		vSpawnOrigin = caster:GetOrigin(), 
		fStartRadius = 200,
		fEndRadius = 200,
		vVelocity = 2400 * vDirection:Normalized() ,
		fDistance = distance,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	}

	ProjectileManager:CreateLinearProjectile( info )
	EmitSoundOn( "Hero_Lina.DragonSlave", self:GetCaster() )
end


function fireblade_fiery_stream:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		local caster = self:GetCaster() 

		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		ApplyDamage( damage )

		if hTarget:IsRealHero() then
			caster:AddNewModifier(caster, self, buff_name, {duration = self.buff_duration})
		end
	end

	return false
end
