local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------

env.AddPrefabPostInit("nightsword", function(inst)
	if not TheWorld.ismastersim then
		return
	end

    local function DrainSanity(inst)
        if inst.components.sanity ~= nil and inst.age_state ~= "old" then
            inst.components.sanity:DoDelta(-0.75*(inst:HasTag("Funny_Words_Magic_Man") and 0.66 or 1))
        end
    end

    local _OnEquip = inst.components.equippable.onequipfn

    inst.components.equippable.onequipfn = function(inst, owner)
        owner:ListenForEvent("onattackother", DrainSanity)

        if _OnEquip ~= nil then
            return _OnEquip(inst, owner)
        end
    end

    local _OnUnequip = inst.components.equippable.onunequipfn

    inst.components.equippable.onunequipfn = function(inst, owner)
        owner:RemoveEventCallback("onattackother", DrainSanity)
        if _OnUnequip ~= nil then
            return _OnUnequip(inst, owner)
        end
    end
end)