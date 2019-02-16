local Constants = require('consts') 	
	
LinkLuaModifier( "modifier_rune_dd_one",	 	'modifiers/modifier_rune_dd_one',  		LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rune_dd_two", 		'modifiers/modifier_rune_dd_two',  		LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rune_dd_three", 		'modifiers/modifier_rune_dd_three',  	LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rune_haster_max", 	'modifiers/modifier_rune_haster_max',  	LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rune_illusion_one", 	'modifiers/modifier_rune_illusion_one', LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rune_illusion_two", 	'modifiers/modifier_rune_illusion_two', LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rune_regen_add", 	'modifiers/modifier_rune_regen_add',	LUA_MODIFIER_MOTION_NONE )

function Haste(keys)
	local ability = keys.ability
	local caster = keys.caster 

	if ability and IsValidEntity(ability) then 
		ability:RemoveSelf()
	end

	caster:AddNewModifier(caster, nil, "modifier_rune_haste", { duration = 22 })

	if RollPercentage(20) then
		caster:AddNewModifier(caster, nil, "modifier_rune_haster_max", {duration = 40}) --glimmers cape modifier
	end

	UpdateAmulets(caster)
end

function DoubleDamage(keys)
	local ability = keys.ability
	local caster = keys.caster 

	if ability and IsValidEntity(ability) then 
		ability:RemoveSelf()
	end

	caster:AddNewModifier(caster, nil, "modifier_rune_doubledamage", { duration = 45 })

	if caster:HasItemInInventory("item_kings_bar") or caster:HasItemInInventory("item_rapier") then -- +60% damage
		caster:AddNewModifier(caster, nil, "modifier_rune_dd_one", {duration = 45})
	end

	if RollPercentage(10) then -- +400% damage
		caster:AddNewModifier(caster, nil, "modifier_rune_dd_two",  {duration = 45} )
	end

	if RollPercentage(10) then -- +20% damage resist
		caster:AddNewModifier(caster, nil, "modifier_rune_dd_three",  {duration = 45} )
	end

	UpdateAmulets(caster)

end

function Arcane(keys)
	local ability = keys.ability
	local caster = keys.caster 

	if ability and IsValidEntity(ability) then 
		ability:RemoveSelf()
	end

	caster:AddNewModifier(caster, nil, "modifier_rune_arcane", { duration = 50 })

	UpdateAmulets(caster)
end

function Invis(keys)
	local ability = keys.ability
	local caster = keys.caster 

	if ability and IsValidEntity(ability) then 
		ability:RemoveSelf()
	end

	caster:AddNewModifier(caster, nil, "modifier_rune_invis", { duration = 45 })

	if RollPercentage(20) then
		caster:AddNewModifier(caster, nil, "modifier_rune_haste", {duration = 40}) --glimmers cape modifier
	end

	UpdateAmulets(caster)
end

function Regen(keys)
	local ability = keys.ability
	local caster = keys.caster 

	if ability and IsValidEntity(ability) then 
		ability:RemoveSelf()
	end

	caster:AddNewModifier(caster, nil, "modifier_rune_regen", { duration = 30 })
	caster:AddNewModifier(caster, nil, "modifier_rune_regen_add", { duration = 30} )

	UpdateAmulets(caster)
end

function Bounty(keys)
	local ability = keys.ability
	local caster = keys.caster 

	if ability and IsValidEntity(ability) then 
		ability:RemoveSelf()
	end

	if not caster:IsRealHero() then
		caster = caster:GetPlayerOwner():GetAssignedHero() 
	end

	local multiplier = 1
	local time = math.ceil(GameRules:GetGameTime() / 60)

	-- default gold and exp 
	local gold_per_min = 2
	local exp_per_min = 5
	local gold_bonus = 50
	local exp_bonus = 50

	caster:ModifyGold(gold_bonus + gold_per_min*time, false, 0) 
	caster:AddExperience(exp_bonus + exp_per_min*time, 0, true, true)

	-- custom additional gold and etc
	local constant_gold_for_minute = 35
	local constant_gold_double_midas = 320 + constant_gold_for_minute*time
	local constant_gold_one_midas = 200 + constant_gold_for_minute*time/2


	if caster:GetUnitName() == "npc_dota_hero_alchemist" then multiplier = 2 end
	if caster:HasItemInInventory("item_advanced_midas") then
		caster:ModifyGold(constant_gold_double_midas*multiplier, false, 0) 
		if RollPercentage(20) then
			caster:ModifyGold(constant_gold_double_midas*multiplier, false, 0) 
		end
	end
	if caster:HasItemInInventory("item_hand_of_midas") then
		caster:ModifyGold(constant_gold_one_midas*multiplier, false, 0) 
	end

	if RollPercentage(20) then
		local level = caster:GetLevel()
		local need_exp = Constants.XP_PER_LEVEL_TABLE[level+1]
		local old_exp = Constants.XP_PER_LEVEL_TABLE[level]
		if not need_exp then need_exp = 0 end
		if not old_exp then old_exp = 0 end
		caster:HeroLevelUp(true)
		caster:AddExperience(need_exp - old_exp, 0, true, true)
	end

	UpdateAmulets(caster)
end

function UpdateAmulets(hero)
	local item
	for i = 0, 5 do
		item = hero:GetItemInSlot(i)
		if item and item:GetPurchaser() == hero then
			if item and (item:GetName() == "item_power_amulet" or item:GetName() == "item_mystic_amulet" or item:GetName() == "item_strange_amulet" )then

				if item:GetCurrentCharges() < 5 then
					item:SetCurrentCharges(item:GetCurrentCharges() + 2)
				else
					item:SetCurrentCharges(item:GetCurrentCharges() + 1)
				end
			
				return
			end
		end
	end
end