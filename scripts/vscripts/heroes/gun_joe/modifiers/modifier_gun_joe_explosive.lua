modifier_gun_joe_explosive = class({})

local talent_name_3 = "gun_joe_special_bonus_explosive_bullets_radius"

--------------------------------------------------------------------------------

function modifier_gun_joe_explosive:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function modifier_gun_joe_explosive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_gun_joe_explosive:DestroyOnExpire()
	return true
end

--------------------------------------------------------------------------------

function modifier_gun_joe_explosive:OnCreated( kv )
	self.damage 			= self:GetAbility():GetSpecialValueFor( "bonus_damage" )
	self.radius 			= self:GetAbility():GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------

function modifier_gun_joe_explosive:OnRefresh( kv )
	local net_table = CustomNetTables:GetTableValue( "heroes", "modifier_gun_joe_explosive") 

	self.damage 			= self:GetAbility():GetSpecialValueFor( "bonus_damage" )
	if net_table and net_table.radius then
		self.radius = net_table.radius
	else
		print("BUG DETECTED")
		self.radius 			= self:GetAbility():GetSpecialValueFor( "radius" )
	end
end

--------------------------------------------------------------------------------

function modifier_gun_joe_explosive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_gun_joe_explosive:OnAttackLanded( params )
	  if IsServer() then
        if params.attacker ~= self:GetParent() then
        	return
        end

        if IsServer() then
			local talent_ability 	= self:GetCaster():FindAbilityByName(talent_name_3)

			local radius = self:GetAbility():GetSpecialValueFor( "radius" )

			if self:GetCaster():HasAbility(talent_name_3) then
				radius = radius + talent_ability:GetSpecialValueFor("value")
			end
			CustomNetTables:SetTableValue( "heroes", "modifier_gun_joe_explosive", 
				{radius = radius  } )
			print("onrefresh")
		end

		local net_table = CustomNetTables:GetTableValue( "heroes", "modifier_gun_joe_explosive") 

		if net_table and net_table.radius then
			self.radius = net_table.radius
		else
			print("BUG DETECTED")
		end

        self:SetStackCount( self:GetStackCount() - 1 )

        if(self:GetStackCount() == 0) then
        	self:GetParent():RemoveModifierByName(self:GetName() )
        end

        local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.target)
		ParticleManager:SetParticleControlEnt( nFXIndex, 2, params.target, PATTACH_POINT_FOLLOW, "attach_head", params.target:GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		EmitSoundOn( "Hero_Techies.Pick", self:GetCaster()  )

        local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), params.target:GetOrigin(), params.target, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )

		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then

					local damage = {
						victim = enemy,
						attacker = self:GetCaster(),
						damage = self.damage,
						damage_type = DAMAGE_TYPE_MAGICAL,
					}
					ApplyDamage( damage )
				end
			end
		end
	end

	return 0
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------