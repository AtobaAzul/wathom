local assets =
{
    Asset("ANIM", "anim/ocupus.zip"),
}

local prefabs =
{
}

SetSharedLootTable( 'um_ocupus_eyetacle',
{
    {'um_ocupus_eyetacle_item',  1.00},
})

local brain = require "brains/um_ocupus_eyetaclebrain"



local function OnDeath(inst)

end

local function OnAttacked(inst, data)
--    print("onattack", data.attacker, data.damage, data.damageresolved)
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeWaterObstaclePhysics(inst, 0.80, 2, 0.75)

	inst.Transform:SetFourFaced()
    inst.AnimState:SetBank("um_ocupus")
    inst.AnimState:SetBuild("ocupus")
    inst.AnimState:PlayAnimation("eyetacle_idle_down", true)

    inst:AddTag("monster")
    inst:AddTag("hostile")


    MakeInventoryFloatable(inst, "med", 0.1, {0.4, 0.4, 0.4})
    inst.components.floater.bob_percent = 0.1
    local land_time = (POPULATING and math.random()*5*FRAMES) or 0
    inst:DoTaskInTime(land_time, function(inst)
        inst.components.floater:OnLandedServer()
    end)	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetBrain(brain)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.runspeed = 2
	
	inst:AddComponent("knownlocations")
	

	
    inst:SetStateGraph("SGum_ocupus_eyetacle")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("inspectable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(300)

    inst:AddComponent("combat")



    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("attacked", OnAttacked)
    ------------------

	inst.original = inst:GetPosition() 
    return inst
end

local function fneyetacle()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("um_ocupus")
    inst.AnimState:SetBuild("ocupus")
    inst.AnimState:PlayAnimation("eyetacle_item", true)
    inst.AnimState:UsePointFiltering(true)

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
	
    inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)
	
    inst:AddComponent("inventoryitem")
	

	
    inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime((4*TUNING.PERISH_TWO_DAY))
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = -3
    inst.components.edible.hungervalue = 25
    inst.components.edible.sanityvalue = -10
    inst.components.edible.foodtype = FOODTYPE.MEAT
	inst.components.edible.secondaryfoodtype = FOODTYPE.MONSTER
		
    return inst
end

return Prefab("um_ocupus_eyetacle", fn, assets),
Prefab("um_ocupus_eyetacle_item",fneyetacle)
