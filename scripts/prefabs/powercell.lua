local assets =
{
    Asset("ANIM", "anim/pigskin.zip"),
}

local function discharge(inst)
    local cell = (inst.components.stackable and inst.components.stackable:Get(1)) or inst
    cell:Remove()
end

local function OnBurnt(inst)
    --DO NOT BURN BATTERIES.
    local x, y, z = inst.Transform:GetWorldPosition()
    
	SpawnPrefab("electric_explosion").Transform:SetPosition(x,0,z)
	SpawnPrefab("bishop_charge_hit").Transform:SetPosition(inst.Transform:GetWorldPosition())
	
	local ents = TheSim:FindEntities(x, 0, z, 5, {"_health"}, { "shadow", "INLIMBO", "chess" })
	
	if #ents > 0 then
		for i, v in ipairs(ents) do			
			if v.components.health ~= nil and not v.components.health:IsDead() then
				if not (v.components.inventory ~= nil and v.components.inventory:IsInsulated()) then
					if v.sg ~= nil then
						v.sg:GoToState("electrocute")
					end

					v.components.health:DoDelta(-30*inst.components.stackable:StackSize(), nil, inst.prefab, nil, inst) --From the onhit stuff...
				else
					v.components.health:DoDelta(-15*inst.components.stackable:StackSize(), nil, inst.prefab, nil, inst)
				end
					
			else
				if not inst:HasTag("electricdamageimmune") and v.components.health ~= nil then
					v.components.health:DoDelta(-30*inst.components.stackable:StackSize(), nil, inst.prefab, nil, inst) --From the onhit stuff...
				end
			end
		end
    end
	
    inst:Remove()
end

local function OnUse(inst)
	local owner = inst.components.inventoryitem.owner
    local item = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    print(item)

    if item == nil then
        print("no handslot item - using headslot")
        item =  owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        print(item)
    end

    if item == nil then
        print("no headslot item - using bodyslot")
        item = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
        print(item)
    end

    if ((item ~= nil and item.components.finiteuses ~= nil and item.components.finiteuses:GetPercent() == 1) or (item ~= nil and item.components.fueld ~= nil and item.components.fueled:GetPercent() >= 0.995)) and (inst.components.upgrademoduleowner ~= nil and inst.components.upgrademoduleowner:ChargeIsMaxed()) then
        return false, "CHARGE_FULL"
    else
        local battery = (inst.components.stackable and inst.components.stackable:Get(1)) or inst
        if owner:HasTag("batteryuser") then
            owner.components.batteryuser:ChargeFrom(battery)
        else
            return false
        end
        if inst.components.upgrademoduleowner ~= nil and not inst.components.upgrademoduleowner:ChargeIsMaxed() then
            inst.components.upgrademoduleowner:AddCharge(1)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()


    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("pigskin")
    inst.AnimState:SetBuild("pigskin")
    inst.AnimState:PlayAnimation("idle")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.sinks = true--thow batteries in the ocean wOOOOOOOO

    inst:AddComponent("battery")
    inst.components.battery.canbeused = true
    inst.components.battery.onused = discharge

    return inst
end

return Prefab("powercell", fn, assets)