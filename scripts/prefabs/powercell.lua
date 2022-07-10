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

--hacky workaround but the best way I could do it
--without having to mess with actions.
local function ondeploy(inst, pt, deployer)
    local cell = (inst.components.stackable and inst.components.stackable:Get(1)) or inst
    if deployer:HasTag("batteryuser") then
        deployer.components.batteryuser:ChargeFrom(cell)
    else
        return false
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

    inst:AddTag("battery")
    inst:AddTag("powercell")
    
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
	inst.components.inventoryitem.atlasname = "images/inventoryimages/powercell.xml"
    inst.components.inventoryitem.sinks = true--thow batteries in the ocean wOOOOOOOO

    inst:AddComponent("battery")
    inst.components.battery.onused = discharge

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable.restrictedtag = "batteryuser"
    return inst
end

return Prefab("powercell", fn, assets)