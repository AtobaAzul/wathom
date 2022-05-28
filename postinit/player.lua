local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------

env.AddPlayerPostInit(function(inst)
    if TUNING.DSTU.VETCURSE == "always" then
        if inst ~= nil and inst.components.health ~= nil and not inst:HasTag("playerghost") then
            if not inst:HasTag("vetcurse") then
                inst.components.debuffable:AddDebuff("buff_vetcurse", "buff_vetcurse")
                inst:PushEvent("foodbuffattached", {buff = "ANNOUNCE_ATTACH_BUFF_VETCURSE", 1})
            end
        end
    elseif TUNING.DSTU.VETCURSE == "off" and inst:HasTag("vetcurse") then
        if inst ~= nil and inst.components.debuffable ~= nil then
            inst.components.debuffable:RemoveDebuff("buff_vetcurse")
        end --help I can't get this stupid thing to work!!
    end

    local function ChargeItem(item)
        if item.components.fueled ~= nil then
            local percent = item.components.fueled:GetPercent()
            local refuelnumber = 0

            if percent + 0.33 > 1 then
                refuelnumber = 1
            else
                refuelnumber = percent + 0.33
            end

            item.components.fueled:SetPercent(refuelnumber)
        elseif item.components.finiteuses ~= nil then
            local percent = item.components.finiteuses:GetPercent()
            local refuelnumber = 0

            if percent + 0.33 > 1 then
                refuelnumber = 1
            else
                refuelnumber = percent + 0.33
            end

            item.components.finiteuses:SetPercent(refuelnumber)
        end
    end

    local function OnChargeFromBattery(inst, battery)
        local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        print(item)

        if item == nil then
            print("no handslot item - using headslot")
            item =  inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
            print(item)
        end

        if item == nil then
            print("no headslot item - using bodyslot")
            item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            print(item)
        end

        if inst.components.upgrademoduleowner == nil then
            if (item ~= nil and item.components.finiteuses ~= nil and item.components.finiteuses:GetPercent() == 1) or (item ~= nil and item.components.fueld ~= nil and item.components.fueled:GetPercent() >= 0.995) then
                return false, "CHARGE_FULL"
            else
                ChargeItem(item)
                if not inst.components.inventory:IsInsulated() then
                    inst.sg:GoToState("electrocute")
                    inst.components.health:DoDelta(-TUNING.HEALING_SMALL, false, "lightning")
                    inst.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
                    if inst.components.talker ~= nil then
                        inst:DoTaskInTime(FRAMES * 30, inst.components.talker:Say(GetString(inst, "ANNOUNCE_CHARGE_SUCCESS_ELECTROCUTED")))
                    end
                else
                    if inst.components.talker ~= nil then
                        inst:DoTaskInTime(FRAMES * 30, inst.components.talker:Say(GetString(inst, "ANNOUNCE_CHARGE_SUCCESS_INSULATED")))
                    end
                end
                return true
            end
        else
            if ((item ~= nil and item.components.finiteuses ~= nil and item.components.finiteuses:GetPercent() == 1) or (item ~= nil and item.components.fueld ~= nil and item.components.fueled:GetPercent() >= 0.995)) and inst.components.upgrademoduleowner:ChargeIsMaxed() then
                return false, "CHARGE_FULL"
            else
                ChargeItem(item)
                if not inst.components.upgrademoduleowner:ChargeIsMaxed() then
                    inst.components.upgrademoduleowner:AddCharge(1)
                end
                if not inst.components.inventory:IsInsulated() then
                    inst.sg:GoToState("electrocute")
                    inst.components.health:DoDelta(-TUNING.HEALING_SMALL, false, "lightning")
                    inst.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
                    if inst.components.talker ~= nil then
                        inst:DoTaskInTime(FRAMES * 30, inst.components.talker:Say(GetString(inst, "ANNOUNCE_CHARGE_SUCCESS_ELECTROCUTED")))
                    end
                else
                    if inst.components.talker ~= nil then
                        inst:DoTaskInTime(FRAMES * 30, inst.components.talker:Say(GetString(inst, "ANNOUNCE_CHARGE_SUCCESS_INSULATED")))
                    end
                end
                return true
            end
        end
    end

    inst:AddComponent("batteryuser") --just the component by itself doesn't do anything
    inst.components.batteryuser.onbatteryused = OnChargeFromBattery
end)
