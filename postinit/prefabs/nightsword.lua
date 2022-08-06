local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------

env.AddPrefabPostInit("nightsword", function(inst)
	if not TheWorld.ismastersim then
		return
	end

    local _onattack = inst.components.weapon.onattack

    local function DrainSanity(inst, attacker, target)
        if attacker.components.sanity ~= nil and attacker.age_state ~= "old" then
            attacker.components.sanity:DoDelta(-0.75*(attacker:HasTag("Funny_Words_Magic_Man") and 0.66 or 1))
        end
        if _onattack ~= nil then--mod compat/future proofing, just in case
            _onattack(inst, attacker, target)
        end
    end

    if inst.components.weapon ~= nil then
        inst.components.weapon:SetOnAttack(DrainSanity)
    end
end)