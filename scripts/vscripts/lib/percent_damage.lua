PercentDamage = PercentDamage or class({})

function PercentDamage:_init()
	_G.skill_callback = {}

	PercentDamage:ListenAbilityCallback("pudge_rot", 							PudgeRot )
	PercentDamage:ListenAbilityCallback("item_radiance_2", 						Radiance )
	PercentDamage:ListenAbilityCallback("item_radiance_3", 						Radiance )
	PercentDamage:ListenAbilityCallback("techies_land_mines", 					TechiesMine )
	PercentDamage:ListenAbilityCallback("techies_suicide", 						TechiesSuicide )
	PercentDamage:ListenAbilityCallback("techies_remote_mines", 				TechiesMineUlt )
	PercentDamage:ListenAbilityCallback("lina_laguna_blade", 					LineLagunaBlade )
	PercentDamage:ListenAbilityCallback("ogre_magi_ignite",						OgreIgnite) 
	PercentDamage:ListenAbilityCallback("oracle_purifying_flames",				PurifyingFlames) 
	PercentDamage:ListenAbilityCallback("jakiro_macropyre",						Macropyre)
	PercentDamage:ListenAbilityCallback("pugna_life_drain",						LifeDrain )
	PercentDamage:ListenAbilityCallback("pugna_nether_ward",					NetherWard)
	PercentDamage:ListenAbilityCallback("luna_eclipse",							Eclipse)
	PercentDamage:ListenAbilityCallback("nevermore_shadowraze1",				ShadowRaze)
	PercentDamage:ListenAbilityCallback("nevermore_shadowraze2",				ShadowRaze)
	PercentDamage:ListenAbilityCallback("nevermore_shadowraze3",				ShadowRaze)
	PercentDamage:ListenAbilityCallback("bristleback_quill_spray",				QuillSpray)
	PercentDamage:ListenAbilityCallback("lina_dragon_slave",					LinaSkills)
	PercentDamage:ListenAbilityCallback("lina_light_strike_array",				LinaSkills)
	PercentDamage:ListenAbilityCallback("bane_brain_sap",						BaneBrainSap)
	PercentDamage:ListenAbilityCallback("venomancer_poison_sting",				VenomancerPoison)
	PercentDamage:ListenAbilityCallback("earthshaker_aftershock",				Aftershock)
	PercentDamage:ListenAbilityCallback("death_prophet_exorcism", 				DeathProphetExorcism)
	PercentDamage:ListenAbilityCallback("axe_culling_blade", 					AxeUltimate)
	PercentDamage:ListenAbilityCallback("treant_eyes_in_the_forest", 			TreantUltimate)
	PercentDamage:ListenAbilityCallback("treant_overgrowth", 					TreantUltimate)

	local MagicalDamageFromMainAtt = {
		"rattletrap_rocket_flare",
		"lion_finger_of_death",
		"axe_battle_hunger",
		"lich_chain_frost",
		"juggernaut_blade_fury",
		"beastmaster_primal_roar",
		"earth_spirit_boulder_smash",
		"visage_soul_assumption",
		"crystal_maiden_freezing_field",
		"sandking_epicenter",
		"dark_seer_vacuum",
		"shadow_shaman_ether_shock",
		"rattletrap_battery_assault",
		"winter_wyvern_splinter_blast",
		"windrunner_powershot",
		"oracle_fortunes_end",
		"leshrac_lightning_storm",
		"leshrac_pulse_nova",
		"jakiro_dual_breath",
		"jakiro_ice_path",
		"jakiro_liquid_fire",
		"puck_illusory_orb",
		"batrider_firefly",
		"phantom_lancer_spirit_lance",
		"naga_siren_rip_tide",
		"tusk_ice_shards",
		"beastmaster_wild_axes",
		"kunkka_ghostship",
		"silencer_curse_of_the_silent",
		"pugna_nether_blast",
		"troll_warlord_whirling_axes_melee",
		"troll_warlord_whirling_axes_ranged",
		"spirit_breaker_greater_bash",
		"spirit_breaker_nether_strike",
		"centaur_hoof_stomp",
		"undying_decay",
		"undying_soul_rip",
		"luna_lucent_beam",
		"dark_seer_ion_shell",
		"night_stalker_void",
		"bounty_hunter_shuriken_toss",
		"brewmaster_earth_hurl_boulder",
		"brewmaster_fire_permanent_immolation",
		"wisp_spirits",
		"nyx_assassin_impale",
		"nyx_assassin_vendetta",
		"sandking_sand_storm",
		"sandking_caustic_finale",
		"gyrocopter_rocket_barrage",
		"disruptor_thunder_strike",
		"ancient_apparition_cold_feet",
		"dragon_knight_breathe_fire",
		"shadow_demon_shadow_poison",
		"storm_spirit_overload",
	}

	for _, skillname in pairs(MagicalDamageFromMainAtt) do 
		PercentDamage:ListenAbilityCallback(skillname, DamageFromMainAttMagical)
	end 


	local PureDamageFromMainAtt = {
		"shredder_chakram",
		"shredder_chakram_2",
		"pudge_meat_hook",
		"chen_test_of_faith",
	}

	for _, skillname in pairs(PureDamageFromMainAtt) do 
		PercentDamage:ListenAbilityCallback(skillname, DamageFromMainAttPure)
	end 

	local PhysDamageFromMainAtt = {
		"slardar_slithereen_crush",
	}

	for _, skillname in pairs(PhysDamageFromMainAtt) do 
		PercentDamage:ListenAbilityCallback(skillname, DamageFromMainAttPhysical)
	end 


end	

function _DamageFromMainAtt(keys, damage_type)
	local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage

	if not ability then return end
	
	local percent_damage 	= ability:GetSpecialValueFor("damage_pct") / 100
	
	damage = percent_damage * caster:GetPrimaryStatValue() 

	Util:DealPercentDamageOfMaxHealth(target, caster, damage_type, damage, 0)
end 

function DamageFromMainAttPhysical(keys)
	_DamageFromMainAtt(keys, DAMAGE_TYPE_PHYSICAL)
end 

function DamageFromMainAttMagical(keys)
	_DamageFromMainAtt(keys, DAMAGE_TYPE_MAGICAL)
end 

function DamageFromMainAttPure(keys)
	_DamageFromMainAtt(keys, DAMAGE_TYPE_PURE)
end 

function PudgeRot( keys )
	local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage
	local percent_damage 	= ability:GetSpecialValueFor("rot_damage_str") / 100

	if not ability or not caster or not target or not damage or not percent_damage then return end
	
	damage = caster:GetStrength() * percent_damage 

	Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, damage, 0)
end

function TreantUltimate(keys)
	local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage

	if not ability then return end
	
	local percent_damage 

	if target:IsCreep() then
		percent_damage = ability:GetSpecialValueFor("damage_pct_creep") / 100
	else
		percent_damage = ability:GetSpecialValueFor("damage_pct") / 100
	end 
	
	damage = percent_damage * caster:GetPrimaryStatValue() 

	Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, damage, 0)
end 

function AxeUltimate(keys)
	local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	
	local hp_limit 	= ability:GetSpecialValueFor("hp_limit") / 100
	
	local target_hp = target:GetHealth() / target:GetMaxHealth() 

	if target_hp < hp_limit then 
		Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_PURE, 0, 100)
		ability:EndCooldown()
	end 
end 


function Aftershock( keys )
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage
	local ability 			= keys.ability

	if not ability then print("earthshaker 3 skill nil for percent damage"); return end
	local bonus_dmg 		= ability:GetSpecialValueFor("damage_from_str");

	Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, caster:GetStrength() * bonus_dmg , 0)
end

function VenomancerPoison( keys )
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage
	local ability 			= keys.ability

	if not ability then print("veno 2 skill nil for percent damage"); return end
	local percent_damage 	= ability:GetSpecialValueFor("dmg_pct") / 100

	Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, caster:GetAgility() * percent_damage, 0)
end

function BaneBrainSap( keys )
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage
	local ability 			= keys.ability
	local multipler 		= (ability:GetSpecialValueFor("brain_sap_heal_pct") or 0) / 100

	local heal = Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_PURE, caster:GetIntellect() * multipler , 0)
	caster:Heal(heal, ability)
end

function LinaSkills( keys )
	local caster 			= keys.caster
	local target 			= keys.target
	local ability 			= keys.ability
	local multipler 		= ability:GetSpecialValueFor("damage_by_int") or 0
	local damage 			= caster:GetIntellect() * multipler

	Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, damage , 0)
end

function QuillSpray( keys )
	local caster 			= keys.caster
	local target 			= keys.target
	local ability 			= keys.ability
	local multipler 		= ability:GetSpecialValueFor("damage_by_str") or 0
	local multipler_hero 	= ability:GetSpecialValueFor("damage_by_str_hero") or 0

	local damage 			
	if target:IsHero() then 
		damage = caster:GetStrength() * multipler_hero 
	else 
		damage = caster:GetStrength() * multipler
	end 


	Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_PHYSICAL, damage , 0)
end

function DeathProphetExorcism( keys )
	local caster 			= keys.caster
	local target 			= keys.target
	
	local ability 			= keys.ability

	if not ability then print("death prophet ultimate nil ability!(percentdamage)"); return; end

	local chance 			= ability:GetSpecialValueFor("chance") or 0
	local dmg_pct 			= (ability:GetSpecialValueFor("damage_to_magical") or 0 ) / 100
	local damage 			= ability:GetSpecialValueFor("average_damage") or 0

	if not RollPercentage(chance) then return end 

	damage 			= Util:DisableSpellAmp(caster, damage * dmg_pct )

	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
end

function ShadowRaze( keys )
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage
	local ability 			= keys.ability
	
	damage 			= caster:GetAverageTrueAttackDamage(nil)/2

	Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, damage , 0)
end

function Eclipse(keys)
	local caster 			= keys.caster
	local ability 			= caster:FindAbilityByName("luna_lucent_beam")
	local target 			= keys.target
	local damage 			= keys.damage
	
	if not ability then print("luna 4 skill nil 1 ability for percent damage"); return end
	local percent_damage 	= ability:GetSpecialValueFor("damage_pct") / 100
	
	damage = percent_damage * caster:GetAgility() 

	Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, damage, 0)
end

function NetherWard( keys )
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage
	local owner 			= caster:GetOwnerEntity() 
	local ability 			= owner:FindAbilityByName("pugna_nether_ward")
	local multipler 		= ability:GetSpecialValueFor("damage_by_int") 
	local damage 			= owner:GetIntellect() * multipler;

	Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, damage, 0)
end

function LifeDrain( keys )
	local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage
	if not ability then print("Pugna 4 skill nil ability for percent damage"); return end
	
	local percent_damage 	= ability:GetSpecialValueFor("damage_pct") / 100
	
	if target:IsMagicImmune() then return end 
	
	Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, caster:GetIntellect() * percent_damage, 0)

	local heal = caster:GetIntellect() * percent_damage
	
	caster:Heal(heal, caster) 
end

function Macropyre( keys )
	local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage
	if not ability then print("jakiro 4 skill nil ability for percent damage"); return end
	
	local percent_damage 	= ability:GetSpecialValueFor("damage_pct") / 100

	Util:DealPercentDamageOfMaxHealth(target, caster, ability:GetAbilityDamageType() , caster:GetIntellect() * percent_damage, 0)
end

function PurifyingFlames( keys )
	local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage
	if not ability then print("oracle 3 skill nil ability for percent damage"); return end
	
	local percent_damage 	= ability:GetSpecialValueFor("damage_pct") / 100

	if caster:GetTeamNumber() == target:GetTeamNumber() then return end

	if caster:GetTeamNumber() ~= target:GetTeamNumber() then
		Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, percent_damage * caster:GetIntellect(), 0)
	end
end

function OgreIgnite( keys )
	local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage
	if not ability then print("Ogre magi 2 skill nil percent damage"); return end
	
	local percent_damage 	= ability:GetSpecialValueFor("damage_pct") / 100
	local percent_damage_creep = ability:GetSpecialValueFor("damage_pct_creep") / 100

	if IsUnitBossGlobal(target) then end

	if not target:IsHero() and not IsUnitBossGlobal(target) then
		Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, caster:GetIntellect() * percent_damage_creep, 0)
	else
		Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, caster:GetIntellect() * percent_damage, 0)
	end
end

function LineLagunaBlade( keys )
	--print("lina start")
	local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage
	if not ability then return end
	local percent_damage 	= ability:GetSpecialValueFor("damage_pct") / 100
	local damage_type 		= ability:GetAbilityDamageType() 

	Util:DealPercentDamageOfMaxHealth(target, caster, damage_type, caster:GetIntellect() * percent_damage, 0)
end

function TechiesMineUlt( keys )
	----print("techies start")
	--local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage

	if caster == target then return end

	local percent_damage 	= 15
	
	if IsUnitBossGlobal(target) then  
		percent_damage = percent_damage / 3
	end

	Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, 0, percent_damage)
end

function TechiesSuicide( keys )
	----print("techies start")
	--local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage

	
	if caster == target then return end
	local percent_damage 	= 25 --ability:GetSpecialValueFor("damage_pct");
	
	if IsUnitBossGlobal(target) then  
		percent_damage = percent_damage / 5
	end

	Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, 0, percent_damage)

end

function TechiesMine( keys )
	----print("techies start")
	--local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage

	if caster == target then return end

	local percent_damage 	= 5.0; -- CAUSE FUCKED ABILITY DONT WORK

	Util:DealPercentDamageOfMaxHealth(target, caster, DAMAGE_TYPE_MAGICAL, 0, percent_damage)
	
end

function Radiance( keys )
	local ability 			= keys.ability
	local caster 			= keys.caster
	local target 			= keys.target
	local damage 			= keys.damage

	if not ability then 
		print("null ability for radiance ")
		return 
	end
	
	local pct 				= ability:GetSpecialValueFor("aura_damage_stats")

	if not ability or not caster or not target or not damage or not pct then return end

	if not caster:IsRealHero() and not caster:IsIllusion() then
		caster = caster:GetPlayerOwner()
		if not IsValidEntity(caster) then return end
		caster = caster:GetAssignedHero() 
	end

	Util:DealDamageFromStats(target, caster, DAMAGE_TYPE_MAGICAL, pct, pct, pct, false)
end

function PercentDamage:ListenAbilityCallback(ability_name, func) -- return callback id
	if type(ability_name) ~= "string" or type(func) ~= "function" then 
		print("Failure to attach function! skill name or function have wrong type.")
		print("Ability Name = ", ability_name)
		return
	end
	_G.skill_callback[ability_name] = _G.skill_callback[ability_name] or {}

	table.insert(_G.skill_callback[ability_name], func)

	return #_G.skill_callback[ability_name];
end

PercentDamage:_init();
