local assets =
{
    Asset("ANIM", "anim/ocupus_items.zip"),
}


local prefabs =
{
    "ocupus_tentacle",
    "ocupus_tentacle_eye",
    "ocupus_tentacle_cooked",
	"ocupus_beak",
}


local function common(bank, build, anim, tags, dryable, cookable)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(anim)

    inst:AddTag("meat")
    if tags ~= nil then
        for i, v in ipairs(tags) do
            inst:AddTag(v)
        end
    end

    if dryable ~= nil then
        --dryable (from dryable component) added to pristine state for optimization
        inst:AddTag("dryable")
        inst:AddTag("lureplant_bait")
    end

    if cookable ~= nil then
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.foodtype = FOODTYPE.MEAT

    inst:AddComponent("bait")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    if dryable ~= nil and dryable.product ~= nil then
        inst:AddComponent("dryable")
        inst.components.dryable:SetProduct(dryable.product)
        inst.components.dryable:SetDryTime(dryable.time)
		inst.components.dryable:SetBuildFile(dryable.build)
        inst.components.dryable:SetDriedBuildFile(dryable.dried_build)
    end

    if cookable ~= nil then
        inst:AddComponent("cookable")
        inst.components.cookable.product = cookable.product
    end

    return inst
end


local function ocupus_tentacle()
    local inst = common("meat", "meat", "raw", { "catfood", "rawmeat" },  { product = "ocupus_tentacle_cooked" })
    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = -TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_LARGE
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    inst.components.tradable.goldvalue = 1



    return inst
end

local function ocupus_tentacle_eye()
    local inst = common("meat", "meat", "raw", { "catfood", "rawmeat" },  { product = "ocupus_tentacle_cooked" })
    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = -TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_LARGE
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    inst.components.tradable.goldvalue = 1


    return inst
end

local function ocupus_tentacle_cooked()
  
    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = -TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_LARGE
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    inst.components.tradable.goldvalue = 1


    return inst
end

return Prefab("ocupus_tentacle", tentacle_fn, assets), Prefab("ocupus_tentacle_eye", eye_fn, assets), 
