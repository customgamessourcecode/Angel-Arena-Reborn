modifier_devour_helm_active = class({})
--------------------------------------------------------------------------------

function modifier_devour_helm_active:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function modifier_devour_helm_active:GetTexture()
	return "../items/custom/devour_helm_big"
end

--------------------------------------------------------------------------------

function modifier_devour_helm_active:IsPurgable()
	return false
end


--------------------------------------------------------------------------------

function modifier_devour_helm_active:DestroyOnExpire()
	return true
end

--------------------------------------------------------------------------------

function modifier_devour_helm_active:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

--------------------------------------------------------------------------------

function modifier_devour_helm_active:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
 
	return state
end

--------------------------------------------------------------------------------

function modifier_devour_helm_active:OnCreated( kv )

	self.caster = self:GetCaster() 
	self.parent = self:GetParent()
	local ability = self:GetAbility()
	
	if ability then
		ability.target = self:GetParent()
	else
		self:Destroy() 
		return
	end

	if IsServer() then
		self.parent:AddNoDraw() 

		Timers:CreateTimer(0.001, function() 
			if not self or not self.caster or not self.parent or not self.caster:IsAlive() or not self:GetAbility() then 
				
				if self and not self:IsNull() then
					self:Destroy() 
				end

				return nil 
			end 

			local flag = false 

			for i = 0, 5 do
				if self.caster:GetItemInSlot(i) == self:GetAbility() then
					flag = true
				end
			end

			for i = DOTA_ITEM_SLOT_7, DOTA_ITEM_SLOT_9 do
				if self.caster:GetItemInSlot(i) == self:GetAbility() then
					flag = true
				end
			end

			if not flag then 
				if self then
					self:Destroy() 
				end
				return nil
			end

			self.parent:SetAbsOrigin(self.caster:GetAbsOrigin())

			return 0.1
		end)
	end
end

--------------------------------------------------------------------------------

function modifier_devour_helm_active:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER ,
	}

	return funcs
end

-- or 0 its for client, because CLIENT DOESNT HAVE ENUMERATIONS =.=
local allow_order = {
	[DOTA_UNIT_ORDER_CAST_TOGGLE 			or 0] = true,
	[DOTA_UNIT_ORDER_SELL_ITEM	 			or 0] = true,
	[DOTA_UNIT_ORDER_PURCHASE_ITEM			or 0] = true,
	[DOTA_UNIT_ORDER_DISASSEMBLE_ITEM		or 0] = true,
	[DOTA_UNIT_ORDER_MOVE_ITEM				or 0] = true,
	[DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO		or 0] = true,
	[DOTA_UNIT_ORDER_GLYPH					or 0] = true,
	[DOTA_UNIT_ORDER_TAUNT					or 0] = true,
	[DOTA_UNIT_ORDER_STOP					or 0] = true,
	[DOTA_UNIT_ORDER_TRAIN_ABILITY			or 0] = true,
	[DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH 	or 0] = true,
	[DOTA_UNIT_ORDER_GIVE_ITEM 				or 0] = true,
	[DOTA_UNIT_ORDER_PICKUP_ITEM 			or 0] = true,
	[27 									or 0] = true, --pick on self item
}
---------------------------------------------------------------------------------

function modifier_devour_helm_active:OnOrder(kv)
	if IsServer() then
		for i,x in pairs(kv) do print(i,x) end
		if kv.unit ~= self:GetParent() then
        	return
        end

        local ability = self:GetAbility()

        if allow_order[kv.order_type] then return end 
        
        
        if ability then
        	ability.target = nil
        end

        self:Destroy() 
	end
end

---------------------------------------------------------------------------------

function modifier_devour_helm_active:OnDestroy()
	if IsServer() then
		self.parent:RemoveNoDraw() 
	end

	local ability = self:GetAbility()

	if ability then
		ability.target = nil 
		if IsServer() then
			local cd = ability:GetCooldownTime()
			
			if cd == 0 then
				cd = ability:GetCooldown(ability:GetLevel() )
			end

			ability:StartCooldown(cd)
		end
	end

	self.caster = nil
	self.parent = nil
end