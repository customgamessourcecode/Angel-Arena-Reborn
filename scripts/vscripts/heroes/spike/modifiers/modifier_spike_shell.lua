modifier_spike_shell = class({})
--------------------------------------------------------------------------------

function modifier_spike_shell:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_spike_shell:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_spike_shell:DestroyOnExpire()
	return false
end

--------------------------------------------------------------------------------

function modifier_spike_shell:OnCreated( kv )

end

function modifier_spike_shell:GetAttributes() 
    return MODIFIER_ATTRIBUTE_PERMANENT
end

--------------------------------------------------------------------------------

function modifier_spike_shell:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

--------------------------------------------------------------------------------

local talent_name_1 = "spike_special_bonus_shell_25"
local talent_name_2 = "spike_special_bonus_shell_block"


function modifier_spike_shell:OnTakeDamage( params )
	if IsServer() then
        if params.unit ~= self:GetParent() then
        	return
        end

        if testflag(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) then return end 
        if not self:GetAbility() then return end
        if params.unit:PassivesDisabled() then return end 

        local hero = params.unit
        local return_damage = self:GetAbility():GetSpecialValueFor("return_damage") / 100

        if hero:IsIllusion() then return end 
        
        if hero:HasAbility(talent_name_1) and hero:FindAbilityByName(talent_name_1):GetLevel() ~= 0 then
            return_damage = return_damage + hero:FindAbilityByName(talent_name_1):GetSpecialValueFor("value") / 100
        end

        if hero:HasAbility(talent_name_2) and  hero:FindAbilityByName(talent_name_2):GetLevel() ~= 0 then
            if hero:GetHealth() > params.damage - params.damage*return_damage then
                hero:Heal(params.damage*return_damage, ability)
            end
        end

        if params.attacker:IsInvulnerable() then return end
        if IsUnitBossGlobal(params.attacker) then return end

        local damage_int_pct_add = 1
    
        if params.unit:IsRealHero() then
            damage_int_pct_add = params.unit:GetIntellect()
            damage_int_pct_add = damage_int_pct_add / 16 / 100 + 1
        end 

        ApplyDamage({
            victim = params.attacker,
            attacker = params.unit,
            damage = (params.damage * return_damage) / damage_int_pct_add,
            damage_type = DAMAGE_TYPE_PURE,
            ability = self:GetAbility(),
            damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
        })

	end
	return 0
end

function testflag(set, flag)
  return set % (2*flag) >= flag
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------