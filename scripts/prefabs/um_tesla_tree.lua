-- Essentially just a copy-pasted normal driftwood tree, but, you know, ours.
-- Not sure if it'll have any special interactions or anything.
-- It's large, so we'll need both the left AND right chopping anims.
local um_tesla_tree_assets = {
    Asset("ANIM", "anim/um_tesla_tree.zip"),
    Asset("MINIMAP_IMAGE", "driftwood_small1")
}

local prefabs = {"um_copper_pipe", "goldnugget"}

SetSharedLootTable('um_tesla_tree', 
{
    {'um_copper_pipe', 1.0}, 
    {'um_copper_pipe', 1.0}, 
    {'um_copper_pipe', 1.0},
    {'goldnugget', 1.0}, 
    {'goldnugget', 1.0}, 
    {'goldnugget', 1.0}
})

local function on_chop(inst, chopper, remaining_chops)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("turnoftides/common/together/driftwood/chop")
    end

    if remaining_chops > 0 then inst.AnimState:PlayAnimation("chop_normal") end
end

local function dig_up_driftwood_stump(inst, chopper)
    inst.components.lootdropper:SpawnLootPrefab("um_copper_pipe")
    inst:Remove()
end

local function make_stump(inst)
    inst.AnimState:PlayAnimation("stump")
    inst:RemoveComponent("workable")
    inst:RemoveComponent("hauntable")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetOnFinishCallback(dig_up_driftwood_stump)
    inst.components.workable:SetWorkLeft(3)
    inst:AddTag("stump")
end

local function on_chopped_down(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/appear_wood")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble", nil, .4)

    inst.AnimState:PlayAnimation("fall")
    inst.components.lootdropper:DropLoot()
    inst:ListenForEvent("animover", make_stump)
end

local function GetStatus(inst) return
    (inst:HasTag("stump") and "CHOPPED") or nil end

local function onsave(inst, data)
    if inst:HasTag("stump") then data.stump = true end
end

local function onload(inst, data)
    if data == nil then return end

    if data.stump then make_stump(inst) end
end

local DAMAGE_SCALE = 0.5
local function OnCollide(inst, data)
    local boat_physics = data.other.components.boatphysics
    if boat_physics ~= nil then
        local hit_velocity = math.floor(math.abs(boat_physics:GetVelocity() * data.hit_dot_velocity) * DAMAGE_SCALE / boat_physics.max_velocity + 0.5)
        inst.components.workable:WorkedBy(data.other, hit_velocity * TUNING.SEASTACK_MINE)
    end
end

local function fn(type_name)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .25)

    -- All driftwood trees are sharing a single minimap icon, since they're functionally the same.
    inst.MiniMapEntity:SetIcon("driftwood_small1.png")
    inst.MiniMapEntity:SetPriority(-1)

    inst:AddTag("tree")
    inst:AddTag("ignorewalkableplatforms")

    inst.AnimState:SetBank("um_tesla_tree")
    inst.AnimState:SetBuild("um_tesla_tree")

    inst.AnimState:PlayAnimation("idle")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst.Transform:SetScale(1.5, 1.5, 1.5)

    inst.AnimState:SetMultColour(0.60, 0.60, 0.60, 1)

    if math.random() > 0.5 then
		inst.AnimState:SetScale(-1, 1)
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("um_tesla_tree")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)

    MakeInventoryFloatable(inst, "small", 0.1, {1.3, 0.9, 1.3})
    inst.components.floater.bob_percent = 0.1

    local land_time = (POPULATING and math.random() * 5 * FRAMES) or 0
    inst:DoTaskInTime(land_time, function(inst)
        inst.components.floater:OnLandedServer()
    end)

    inst:ListenForEvent("on_collide", OnCollide)

    inst.components.workable:SetWorkLeft(TUNING.DRIFTWOOD_TREE_CHOPS)

    inst.components.workable:SetOnWorkCallback(on_chop)
    inst.components.workable:SetOnFinishCallback(on_chopped_down)

    MakeHauntableWork(inst)


    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    MakeWaterObstaclePhysics(inst, 0.80, 2, 0.75)

    inst.OnSave = onsave
    inst.OnLoad = onload

    MakeSnowCovered(inst)

    return inst
end

local function copper_tree() return fn("um_tesla_tree", false) end

return Prefab("um_tesla_tree", copper_tree, um_tesla_tree_assets, prefabs)
