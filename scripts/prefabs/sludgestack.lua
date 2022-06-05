--[[
    ]]




local assets =
{
    Asset("ANIM", "anim/water_rock_01.zip"),
    Asset("MINIMAP_IMAGE", "seastack"),
}

local prefabs =
{
    "rock_break_fx",
    "waterplant_baby",
    "waterplant_destroy",
}

SetSharedLootTable( 'sludgestack',
{
    {'rocks',  1.00},
    {'rocks',  1.00},
    {'sludge',  1.00},
    {'sludge',  1.00},
    {'sludge',  1.00},
    {'sludge',  1.00},
    {'sludge',  0.50},
})
local function Generate(pt)
	local prefab = "sludgestack"

	local stack = SpawnPrefab(prefab)
	if stack ~= nil then
		local x, y, z = pt.x, pt.y, pt.z
		stack.Transform:SetPosition(x, y, z)
	end
	return stack
end
local function createStacks(inst)
    local pos = inst:GetPosition()
    
    for i = 1, math.random(4,8) do
        Generate(pos).Transform:SetPosition(pos.x + math.random(-15, 15), pos.y, pos.z + math.random(-15, 15))
    end
    inst:Remove()
end--I'm *pretty* sure this isn't how you do this but eh, it works! -Atobá

local function OnWork(inst, worker, workleft)
    if workleft <= 0 then
        TheWorld:PushEvent("CHEVO_seastack_mined", {target=inst,doer=worker})
        local pt = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pt:Get())

        local loot_dropper = inst.components.lootdropper

        inst:SetPhysicsRadiusOverride(nil)

        loot_dropper:DropLoot(pt)

        inst:Remove()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("seastack.png")

    inst:SetPhysicsRadiusOverride(2.35)

    MakeWaterObstaclePhysics(inst, 0.80, 2, 0.75)

    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("seastack")

    inst.AnimState:SetBank("water_rock01")
    inst.AnimState:SetBuild("water_rock_01")
    inst.AnimState:PlayAnimation("1_full")
    inst.AnimState:SetMultColour(0.5, 0.5, 0.5, 1)

    MakeInventoryFloatable(inst, "med", 0.1, {1.1, 0.9, 1.1})
    inst.components.floater.bob_percent = 0

    local land_time = (POPULATING and math.random()*5*FRAMES) or 0
    inst:DoTaskInTime(land_time, function(inst)
        inst.components.floater:OnLandedServer()
    end)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('sludgestack')
    inst.components.lootdropper.max_speed = 2
    inst.components.lootdropper.min_speed = 0.3
    inst.components.lootdropper.y_speed = 14
    inst.components.lootdropper.y_speed_variance = 4
    inst.components.lootdropper.spawn_loot_inside_prefab = true

    inst:AddComponent("inspectable")

    inst:AddComponent("harvestable")
    inst.components.harvestable:SetUp("sludge", nil, TUNING.GRASS_REGROW_TIME, nil, nil)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.SEASTACK_MINE)
    inst.components.workable:SetOnWorkCallback(OnWork)
    inst.components.workable.savestate = true

    --inst:AddComponent("upgradeable")
    --inst.components.upgradeable.upgradetype = --UPGRADETYPES.BUCKET have to learn how to upgrade component stuff!!!
    --inst.components.upgradeable.onupgradefn = on_upgraded

    MakeHauntableWork(inst)

    --------SaveLoad might need it idk
    --inst.OnSave = onsave
    --inst.OnLoad = onload

    return inst
end

local function spawner_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst:AddTag("CLASSIFIED")

	inst:DoTaskInTime(0, createStacks)

    return inst
end


return Prefab("sludgestack", fn, assets, prefabs),
       Prefab("sludgestack_spawner", spawner_fn, assets, prefabs)