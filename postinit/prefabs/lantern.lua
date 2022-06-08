local env = env
GLOBAL.setfenv(1, GLOBAL)

env.AddPrefabPostInit("lantern", function(inst)
    if inst.components.equippable ~= nil then
        local OnEquip_old = inst.components.equippable.onequipfn

        inst.components.equippable.onequipfn = function(inst, owner)
            local numupgrades = inst.components.upgradeable.numupgrades
            print(numupgrades)
            if numupgrades > 0 then
                owner:AddTag("batteryuser")
            end

            if OnEquip_old ~= nil then
                OnEquip_old(inst, owner)
            end
        end

        local OnUnequip_old = inst.components.equippable.onunequipfn

        inst.components.equippable.onunequipfn = function(inst, owner)

            if owner.components.upgrademoduleowner == nil then
                local item = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

                if (item ~= nil and not item:HasTag("electricaltool")) or item == nil then
                    owner:RemoveTag("batteryuser")
                end
            end

            if OnUnequip_old ~= nil then
                OnUnequip_old (inst, owner)
            end
        end
    end

    local function OnUpgrade(inst)
        if inst ~= nil then
            inst:SetPrefabNameOverride("LANTERN_ELECTRICAL")
            inst.components.upgradeable.upgradetype = nil
            inst.components.fueled.accepting = false
            inst.components.fueled.maxfuel = inst.components.fueled.maxfuel*2
            inst:AddTag("electricaltool")
        end --but wait! won't that fuck everything up?
    end     --maybe I could alter in onequip instead too.

    inst:AddComponent("upgradeable")
    inst.components.upgradeable.upgradetype = UPGRADETYPES.ELECTRICAL
    inst.components.upgradeable.onupgradefn = OnUpgrade

    inst:AddTag("NORATCHECK")
end)