require "prefabutil"
require "modutil"

local assets =
{
    Asset("ANIM", "anim/sorrel.zip"),
}

SetSharedLootTable( 'sorrel',
{
    {'greenfoliage',    1},
    {'greenfoliage',    1},
    {'greenfoliage',    0.50},
})

local function OnSave(inst, data)
    data.rotation = inst.Transform:GetRotation()
    --data.scale = { inst.Transform:GetScale() }
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.rotation ~= nil then
            inst.Transform:SetRotation(data.rotation)
        end
        if data.scale ~= nil then
            inst.Transform:SetScale(data.scale[1] or 1, data.scale[2] or 2, data.scale[3] or 3)
        end
    end
end

local function onharvest(inst, picker, produce)
    if inst:HasTag("blooming") then
        --MAKE THIS A HAYFEVER THINGFGAAA
    end
    --inst.components.harvestable.maxproduce = 10 --idk
    inst.AnimState:PlayAnimation("idle", true)
end

local function bloom(inst)
    if TheWorld.state.isspring then
        if inst.components.harvestable:CanBeHarvested() then
            inst.AnimState:PlayAnimation("idle_flower", true)
        end
        inst.components.harvestable.product = "petals"
        inst:AddTag("blooming")
    elseif inst.components.harvestable:CanBeHarvested() then
            inst.AnimState:PlayAnimation("idle2", true)
            inst.components.harvestable.product = "greenfoliage"
    else
        inst.AnimState:PlayAnimation("idle", true)
    end
end

local function ongrow(inst, produce)
    if inst:HasTag("blooming") then
        inst.AnimState:PlayAnimation("idle_flower", true)
    else
        inst.AnimState:PlayAnimation("idle2", true)
    end
end

local function onworkfinished(inst, digger)
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sorrel")
    inst.AnimState:SetBuild("sorrel")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)
    inst.AnimState:PlayAnimation("idle2", true)
    inst:AddTag("NOBLOCK")

    inst:AddComponent("harvestable")
    inst.components.harvestable:SetUp("greenfoliage", nil, TUNING.GRASS_REGROW_TIME/2, onharvest, ongrow)

    inst:WatchWorldState("phase", bloom)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onworkfinished)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('sorrel')
    --[[if not TheWorld.ismastersim then
        return inst
    end]]


    inst.Transform:SetRotation(math.random() * 360)

    --inst.Transform:SetScale(1.2, 1.5, 1.2)

    local scale = GetRandomMinMax(1.33, 1.66)
    inst.Transform:SetScale(scale, scale, scale)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("um_sorrel", fn, assets)
