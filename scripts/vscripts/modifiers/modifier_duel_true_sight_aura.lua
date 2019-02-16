if modifier_duel_true_sight_aura == nil then modifier_duel_true_sight_aura = class({}) end

LinkLuaModifier( "modifier_duel_true_sight", 'modifiers/modifier_duel_true_sight', LUA_MODIFIER_MOTION_NONE )

function modifier_duel_true_sight_aura:OnCreated(kv)
	self.radius = kv.radius or 500 

	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_duel_true_sight_aura:IsAura()
	return true
end

function modifier_duel_true_sight_aura:IsHidden()
	return false
end

function modifier_duel_true_sight_aura:IsPurgable()
	return false
end

function modifier_duel_true_sight_aura:RemoveOnDeath()
	return false
end

function modifier_duel_true_sight_aura:AllowIllusionDuplicate()
	return true
end

function modifier_duel_true_sight_aura:GetAuraRadius()
	return self.radius
end

function modifier_duel_true_sight_aura:DeclareFunctions()
	local funcs = {	MODIFIER_EVENT_ON_DEATH }; return funcs;
end

function modifier_duel_true_sight_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_duel_true_sight_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_OTHER
end

function modifier_duel_true_sight_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_duel_true_sight_aura:GetModifierAura()
	return "modifier_duel_true_sight"
end

function modifier_duel_true_sight_aura:GetTexture()
	return "item_gem"
end

function modifier_duel_true_sight_aura:OnDeath( keys )
	if IsServer() then
		local dead_hero = keys.unit 

		if dead_hero ~= self:GetParent() then return end
		if dead_hero.IsReincarnating and dead_hero:IsReincarnating() then return end 

		self:Destroy()
	end
end

function modifier_duel_true_sight_aura:OnIntervalThink()
	if not IsServer() then return end 

	local hero = self:GetParent()

	local enemyUnits = FindUnitsInRadius(hero:GetOpposingTeamNumber() ,
                              hero:GetAbsOrigin(),
                              nil,
                              self.radius,
                              DOTA_UNIT_TARGET_TEAM_BOTH,
                              DOTA_UNIT_TARGET_OTHER,
                              DOTA_UNIT_TARGET_FLAG_NONE+DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                              FIND_ANY_ORDER,
                              false)

	for _, tree in pairs(enemyUnits) do 
		if tree:GetClassname() == "npc_dota_treant_eyes" then
			tree:AddNewModifier(hero, self:GetAbility(), "modifier_truesight", {duration = 0.11}) 
		end 
	end 
end 