local talent_name_1 = "spike_special_bonus_shell_25"
local talent_name_2 = "spike_special_bonus_shell_block"

local forbidden_modifiers_enemy = {
	"modifier_item_blade_mail_reflect",
	"modifier_nyx_assassin_spiked_carapace",
}

local forbidden_modifiers_ally = {
	"modifier_oracle_false_promise",
}

function Shell(params)
	local damage = params.Damage
	local attacker = params.attacker
	local hero = params.caster
	local ability = params.ability
	local return_damage_percent = ability:GetLevelSpecialValueFor("return_damage", ability:GetLevel() - 1) / 100
	print("take damage = ", damage)
	if not hero then return end
	if not attacker then return end

	local damage_int_pct_add = hero:GetIntellect()

	local damage_int_pct_add = 1
	if hero:IsRealHero() then
		damage_int_pct_add = hero:GetIntellect()
		damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
	end 

	if hero:PassivesDisabled() then return end
	if attacker == hero then return end
	if not attacker or hero:IsIllusion() then return end
	 
	
	--[[
	if attacker:HasModifier("modifier_item_blade_mail_reflect") then return end
	if attacker:HasModifier("modifier_nyx_assassin_spiked_carapace") then return end
	if hero:HasModifier("modifier_oracle_false_promise") then return end
	]]

	

	if hero:HasAbility(talent_name_1) and hero:FindAbilityByName(talent_name_1):GetLevel() ~= 0 then
		return_damage_percent = return_damage_percent + hero:FindAbilityByName(talent_name_1):GetSpecialValueFor("value") / 100
	end

	damage = damage*return_damage_percent

	--todo HEAL
	if hero:HasAbility(talent_name_2) and  hero:FindAbilityByName(talent_name_2):GetLevel() ~= 0 then
		if hero:GetHealth() > params.Damage then
			print("deal heal:", damage)
			hero:Heal(damage, ability)
		end
	end

	damage = damage / damage_int_pct_add

	if attacker:IsMagicImmune() then return end
	if attacker:IsInvulnerable() then return end
	if IsUnitBossGlobal(attacker) then return end
	
	for _, x in pairs(forbidden_modifiers_enemy) do
		if attacker:HasModifier(x) then return end
	end
	for _, x in pairs(forbidden_modifiers_ally) do
		if hero:HasModifier(x) then return end
	end

	if damage > 2 then
		print("Return damage = ", damage)
		if attacker:GetHealth() < damage + 1 then
			attacker:Kill(ability, hero)
		else
			attacker:SetHealth(attacker:GetHealth() - damage - 1)
			attacker:Heal(1, ability) 
			local deal_damage = 1 / damage_int_pct_add
			ApplyDamage({ victim = attacker, attacker = hero, damage = deal_damage, damage_type = DAMAGE_TYPE_PURE, abilityReturn = ability})
		end
	end

	if attacker:GetHealth() == 0 then
		attacker:Kill(ability, hero)
	end
end