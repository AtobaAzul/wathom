-- borrowed from https://github.com/xfbs/PiL3/blob/master/05Functions/combinations.lua
-- returns array in a format {{1,2}, {1,3} ...}
-- every element in returned array is a table with one combination
local function combinations(arr, r)
    -- do noting if r is bigger then length of arr
    if (r > #arr) then
        return {}
    end

    -- for r = 0 there is only one possible solution and that is a combination of lenght 0
    if (r == 0) then
        return {}
    end

    if (r == 1) then
        -- if r == 1 than retrn only table with single elements in table
        -- e.g. {{1}, {2}, {3}, {4}}

        local return_table = {}
        for i = 1, #arr do
            table.insert(return_table, {arr[i]})
        end

        return return_table
    else
        -- else return table with multiple elements like this
        -- e.g {{1, 2}, {1, 3}, {1, 4}}

        local return_table = {}

        -- create new array without the first element
        local arr_new = {}
        for i = 2, #arr do
            table.insert(arr_new, arr[i])
        end

        -- combinations of (arr-1, r-1)
        for i, val in pairs(combinations(arr_new, r - 1)) do
            local curr_result = {}
            table.insert(curr_result, arr[1])
            for j, curr_val in pairs(val) do
                table.insert(curr_result, curr_val)
            end
            table.insert(return_table, curr_result)
        end

        -- combinations of (arr-1, r)
        for i, val in pairs(combinations(arr_new, r)) do
            table.insert(return_table, val)
        end

        return return_table
    end
end

local MAX_HONEY_VARIATIONS = 7
local MAX_RECENT_HONEY = 4
local HONEY_PERIOD = .2
local HONEY_LEVELS = {
    {
        min_scale = .5,
        max_scale = .8,
        threshold = 8,
        duration = 1.2
    },
    {
        min_scale = .5,
        max_scale = 1.1,
        threshold = 2,
        duration = 2
    },
    {
        min_scale = 1,
        max_scale = 1.3,
        threshold = 1,
        duration = 4
    }
}

local function PickHoney(inst)
    local rand = table.remove(inst.availablehoneyslow, math.random(#inst.availablehoneyslow))
    table.insert(inst.usedhoneyslow, rand)
    if #inst.usedhoneyslow > MAX_RECENT_HONEY then
        table.insert(inst.availablehoneyslow, table.remove(inst.usedhoneyslow, 1))
    end
    return rand
end

local function DoHoneyTrail(inst)
    local level = HONEY_LEVELS[(inst.sg ~= nil and not inst.sg:HasStateTag("moving") and 1) or (inst.components.locomotor ~= nil and inst.components.locomotor.walkspeed <= TUNING.BEEQUEEN_SPEED and 2) or 3]

    inst.honeyslowcount = inst.honeyslowcount + 1

    if inst.honeyslowthreshold > level.threshold then
        inst.honeyslowthreshold = level.threshold
    end

    if inst.honeyslowcount >= inst.honeyslowthreshold then
        local hx, hy, hz = inst.Transform:GetWorldPosition()
        inst.honeyslowcount = 0
        if inst.honeyslowthreshold < level.threshold then
            inst.honeyslowthreshold = math.ceil((inst.honeyslowthreshold + level.threshold) * .5)
        end
        local x, y, z = inst.Transform:GetWorldPosition()
        local fx = nil
        if TheWorld.Map:IsPassableAtPoint(hx, hy, hz) then
            fx = SpawnPrefab("wixiehoney_trail")
            fx:SetVariation(PickHoney(inst), GetRandomMinMax(level.min_scale, level.max_scale), level.duration + math.random() * .5)
        else
            fx = SpawnPrefab("splash_sink")
        end
        fx.Transform:SetPosition(x, 0, z)
    end

    inst.honeyslowcancelcount = inst.honeyslowcancelcount + 1

    if inst.honeyslowcancelcount >= inst.honeyslowmax then
        if inst.honeyslowtask ~= nil then
            inst.honeyslowtask:Cancel()
            inst.honeyslowtask = nil
        end
    end
end

local MUST_ONE_OF_TAGS = {"_combat", "_health", "blocker"}
local AREAATTACK_EXCLUDETAGS = {
    "INLIMBO",
    "notarget",
    "noattack",
    "flight",
    "invisible",
    "playerghost"
}

local INITIAL_LAUNCH_HEIGHT = 0.1
local SPEED_XZ = 4
local SPEED_Y = 16
local ANGLE_VARIANCE = 20

local function launch_away(inst, position, use_variant_angle)
    if inst.Physics == nil then
        return
    end

    -- Launch outwards from impact point. Calculate angle from position, with some variance
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    inst.Physics:Teleport(ix, iy + INITIAL_LAUNCH_HEIGHT, iz)
    inst.Physics:SetFriction(0.2)

    local px, py, pz = position:Get()
    local random = use_variant_angle and math.random() * ANGLE_VARIANCE * -ANGLE_VARIANCE / 2 or 0
    local angle = ((180 - inst:GetAngleToPoint(px, py, pz)) + random) * DEGREES
    local sina, cosa = math.sin(angle), math.cos(angle)
    inst.Physics:SetVel(SPEED_XZ * cosa, SPEED_Y, SPEED_XZ * sina)

    -- Add a drop shadow component to the item as it flies through the air, then remove it when it lands
    if inst.components.inventoryitem then
        if not TheNet:IsDedicated() then
            inst:ListenForEvent("on_landed", function(inst)
                if inst:IsOnOcean() then
                    SpawnPrefab("wave_splash").Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
            end)
        end
    end
end

local function Detonate(inst, attacker, target)
    local radius =
        ((inst.explosive_type == "he" and 3) or (inst.explosive_type == "me" and 2) or 1) +
        (inst.components.stackable:StackSize() * 0.75) *
        ((table.contains(inst.effects, "pipe") and 2) or
        (table.contains(inst.effects, "shrapnel") and 4) and (table.contains(inst.effects, "shaped") and 0.25) or
        1)

    local scaling =
        (inst.components.stackable:StackSize() * 0.75) *
        ((table.contains(inst.effects, "pipe") and 2) or
        (table.contains(inst.effects, "shrapnel") and 4) and (table.contains(inst.effects, "shaped") and 0.25) or
        1)

    -- Do splash damage
    inst.components.combat.defaultdamage = inst.components.combat.defaultdamage * (1 + scaling / 10)
    inst.components.combat:DoAreaAttack(inst, radius, nil, nil, nil, AREAATTACK_EXCLUDETAGS)

    -- Look for stuff on the ocean/ground and launch them
    local x, y, z = inst.Transform:GetWorldPosition()
    print(x, y, z)

    if inst:HasTag("INLIMBO") then
        x, y, z = inst.components.inventoryitem:GetGrandOwner().Transform:GetWorldPosition()
    end

    print(x, y, z)

    local position = inst:GetPosition()
    local affected_entities = TheSim:FindEntities(x, 0, z, radius, nil, AREAATTACK_EXCLUDETAGS, nil) -- Set y to zero to look for objects floating on the ocean
    if not inst.dud then
        for i, affected_entity in ipairs(affected_entities) do
            -- Look for fish in the splash radius, kill and spawn their loot if hit
            if affected_entity.components.oceanfishable ~= nil then
                if affected_entity.fish_def and affected_entity.fish_def.loot then
                    local loot_table = affected_entity.fish_def.loot
                    for i, product in ipairs(loot_table) do
                        local loot = SpawnPrefab(product)
                        if loot ~= nil then
                            local ae_x, ae_y, ae_z = affected_entity.Transform:GetWorldPosition()
                            loot.Transform:SetPosition(ae_x, ae_y, ae_z)
                            launch_away(loot, position, true)
                        end
                    end
                    affected_entity:Remove()
                end
            end

            --retaliate, mainly for impact bombs
            if (attacker ~= nil or inst.attacker ~= nil) and affected_entity.components.combat ~= nil and ((attacker.components.health ~= nil and not attacker.components.health:IsDead()) or (inst.attacker.components.health ~= nil and not inst.attacker.components.health:IsDead())) then
                affected_entity.components.combat:SetTarget(attacker)
            end

            -- Spawn kelp roots along with kelp is a bullkelp plant is hit
            if affected_entity.prefab == "bullkelp_plant" then
                local ae_x, ae_y, ae_z = affected_entity.Transform:GetWorldPosition()

                if affected_entity.components.pickable and affected_entity.components.pickable:CanBePicked() then
                    local product = affected_entity.components.pickable.product
                    local loot = SpawnPrefab(product)

                    if loot ~= nil then
                        loot.Transform:SetPosition(ae_x, ae_y, ae_z)
                        if loot.components.inventoryitem ~= nil then
                            loot.components.inventoryitem:InheritMoisture(TheWorld.state.wetness, TheWorld.state.iswet)
                        end
                        if loot.components.stackable ~= nil and affected_entity.components.pickable.numtoharvest > 1 then
                            loot.components.stackable:SetStackSize(affected_entity.components.pickable.numtoharvest)
                        end
                        launch_away(loot, position)
                    end
                end

                local uprooted_kelp_plant = SpawnPrefab("bullkelp_root")
                if uprooted_kelp_plant ~= nil then
                    uprooted_kelp_plant.Transform:SetPosition(ae_x, ae_y, ae_z)
                    launch_away(uprooted_kelp_plant, position + Vector3(0.5 * math.random(), 0, 0.5 * math.random()))
                end

                affected_entity:Remove()
            end
            -- Generic pickup item
            if affected_entity.components.inventoryitem ~= nil then
                launch_away(affected_entity, position)
            end

            if affected_entity.waveactive then
                affected_entity:DoSplash()
            end

            if affected_entity.components.burnable ~= nil and table.contains(inst.effects, "fire") then
                affected_entity.components.burnable:Ignite()
            end

            if affected_entity.components.workable ~= nil and inst.explosive_type == "he" then
                affected_entity.components.workable:Destroy(inst)
            end

            if table.contains(inst.effects, "stun") then
                --stun or panic enemies
                if affected_entity.components.health ~= nil and not affected_entity.components.health:IsDead() and affected_entity:HasTag("stunnedbybomb") then
                    affected_entity:PushEvent("stunbomb")
                elseif affected_entity.components.hauntable ~= nil and affected_entity.components.hauntable.panicable then
                    affected_entity.components.hauntable:Panic(TUNING.BATTLESONG_PANIC_TIME * (1 + scaling / 10))
                end
            end

            if
                table.contains(inst.effects, "sticky") and
                    (affected_entity.sg ~= nil or affected_entity.components.locomotor ~= nil) and
                    inst.honeyslowtask == nil
             then
                affected_entity.honeyslowcancelcount = 0
                affected_entity.honeyslowmax = 75 * (1 + scaling / 10)
                affected_entity.honeyslowthreshold = HONEY_LEVELS[1].threshold
                affected_entity.availablehoneyslow = {}
                affected_entity.usedhoneyslow = {}
                for i = 1, MAX_HONEY_VARIATIONS do
                    table.insert(affected_entity.availablehoneyslow, i)
                end
                affected_entity.honeyslowcount = math.ceil(affected_entity.honeyslowthreshold * .5)

                if affected_entity.honeyslowtask ~= nil then
                    affected_entity.honeyslowtask:Cancel()
                    affected_entity.honeyslowtask = nil
                end

                if affected_entity.sg ~= nil or affected_entity.components.locomotor ~= nil then
                    affected_entity.honeyslowtask = affected_entity:DoPeriodicTask(HONEY_PERIOD, DoHoneyTrail)
                end
            end

            if table.contains(inst.effects, "magic") then
                local tentacle = SpawnPrefab("shadowtentacle")
                tentacle.Transform:SetPosition(affected_entity.Transform:GetWorldPosition())
                if affected_entity.components.health ~= nil and not affected_entity.components.health:IsDead() then
                    tentacle.components.combat:SetTarget(affected_entity)
                end
            end
        end
        if table.contains(inst.effects, "fire") then
            if table.contains(inst.effects, "magic") then
                local fx = SpawnPrefab("cursed_firesplash")
                fx.Transform:SetPosition(x, 0, z)
                fx.Transform:SetScale(1 + (scaling / 10), 1 + (scaling / 10), 1 * (scaling / 10))
            else
                local fx = SpawnPrefab("halloween_firepuff_" .. math.random(3))
                fx.Transform:SetPosition(x, y, z)
                fx.Transform:SetScale(1 + (scaling / 10), 1 + (scaling / 10), 1 * (scaling / 10))
            end
        elseif inst.explosive_type == "he" then
            --FX DON'T HAVE AnimState WHY?!?
            --fx.AnimState:SetMultColour(1,1,1,0.5)
            --if table.contains(inst.effecats, "magic") then
            --    fx.AnimState:SetHue(math.random())
            --end
            local fx = SpawnPrefab("electric_explosion")
            fx.Transform:SetPosition(x, 0, z)
            fx.Transform:SetScale(1 + (scaling / 10), 1 + (scaling / 10), 1 * (scaling / 10))
            inst.components.groundpounder:GroundPound()
        elseif inst.explosive_type == "me" then
            --fx.AnimState:SetMultColour(1,1,1,0.5)
            --if table.contains(inst.effects, "magic") then
            --    fx.AnimState:SetHue(math.random())
            --end
            local fx = SpawnPrefab("explode_small")
            fx.Transform:SetPosition(x, 0, z)
            fx.Transform:SetScale(1 + (scaling / 10), 1 + (scaling / 10), 1 * (scaling / 10))
        elseif inst.explosive_type == "le" then
            local fx = SpawnPrefab("explosivehit")
            fx.Transform:SetPosition(x, 0, z)
            fx.Transform:SetScale(1 + (scaling / 10), 1 + (scaling / 10), 1 * (scaling / 10))
            local fx1 = SpawnPrefab("lavaarena_spawnerdecor_fx_" .. math.random(3))
            fx1.Transform:SetPosition(x, 0, z)
            fx1.Transform:SetScale(1 + (scaling / 10), 1 + (scaling / 10), 1 * (scaling / 10))
            --fx.AnimState:SetMultColour(1,1,1,0.5)
            --if table.contains(inst.effects, "magic") then
            --    fx.AnimState:SetHue(math.random())
            --end
        end

        if TheWorld.components.dockmanager ~= nil then
            -- Damage any docks we hit.
            TheWorld.components.dockmanager:DamageDockAtPoint(x, 0, z, 100 * inst.components.stackable:StackSize())
        end
    else
        SpawnPrefab("lavaarena_creature_teleport_smoke_fx_" .. math.random(3)).Transform:SetPosition(inst.Transform:GetWorldPosition())
        SpawnPrefab("lavaarena_spawnerdecor_fx_" .. math.random(3)).Transform:SetPosition(inst.Transform:GetWorldPosition())
    end

    inst:Remove()
end

local function calculate_mine_test_time()
    return TUNING.STARFISH_TRAP_TIMING.BASE + (math.random() * TUNING.STARFISH_TRAP_TIMING.VARIANCE)
end

local function OnTimerDone(inst)
    local radius =
        ((inst.explosive_type == "he" and 3) or (inst.explosive_type == "me" and 2) or 1) +
        (inst.components.stackable:StackSize() * 0.75) *
        ((table.contains(inst.effects, "pipe") and 2) or
        (table.contains(inst.effects, "shrapnel") and 4) and (table.contains(inst.effects, "shaped") and 0.25) or
        1)

    inst:AddComponent("mine")
    inst.components.mine:SetRadius(radius)
    inst.components.mine:SetAlignment(nil) -- mines trigger on EVERYTHING on the ground, players and non-players alike.
    inst.components.mine:SetOnExplodeFn(Detonate)
    inst.components.mine:SetOnSprungFn(SpawnPrefab("dr_warmer_loop").Transform:SetPosition(inst.Transform:GetWorldPosition()))
    inst.components.mine:SetTestTimeFn(calculate_mine_test_time)
    inst.components.mine:SetReusable(false)

    inst.components.mine:Reset()
    inst.components.mine:StartTesting()

    inst.components.inventoryitem.canbepickedup = false
end

local function OnHit(inst, attacker, target)
    print(tostring(attacker))
    inst.bomb_attacker = attacker

    if inst.detonator_type == "impact" then
        local fx = SpawnPrefab("winona_battery_high_shatterfx")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx.AnimState:SetHue(0.5)
        Detonate(inst, attacker)
    else
        MakeInventoryPhysics(inst)
        inst.AnimState:PlayAnimation("idle")
        inst:RemoveTag("NOCLICK")
        inst.persists = true

        if inst.detonator_type == "prox" then
            inst.components.timer:StartTimer("arm", 10 * (math.random(0, 1) + math.random()), false)
        end
        if attacker.prefab == "boat_cannon" then
            Detonate(inst)
        end
    end
end

local function onthrown(inst)
    inst:AddTag("NOCLICK")
    inst.persists = false

    inst.AnimState:PlayAnimation("spin_loop", true)

    inst.Physics:SetMass(1)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_waterballoon", "swap_waterballoon")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    -- Attack range is 8, leave room for error
    -- Min range was chosen to not hit yourself (2 is the hit range)
    for r = 6.5, 3.5, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function ActivateEquippable(inst)
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true
end

local function OnUsed(inst)
    if not inst.components.rechargeable:IsCharged() then --allow winding it up for longer delay
        inst.components.rechargeable:SetChargeTime(inst.components.rechargeable.chargetime + 5)
    else
        inst.components.rechargeable:Discharge(10)
    end
end

local function OnPutInInventory(inst)
    if not inst.components.inventoryitem:GetGrandOwner():HasTag("player") then
        OnUsed(inst)
    end
end

local function CanActivate(inst, doer)
    if not inst.components.timer:TimerExists("arm") then
        return true
    else
        return false
    end
end

local function OnActivated(inst, doer)
    inst.components.timer:StartTimer("arm", 10 * (math.random(0, 1) + math.random()), false)
end

local detonators_ = {
    "fuse", --rope - nothing, since all bombs explode when burnt.
    "impact", --bottle - explodes on impact.
    "prox", --boomberry - explodes when stuff walks nearby after armed.
    "timed" --transistor - explodes after 10s of being activated.
}

--kinda want to get more goofy effects in but not sure *what*
local effects_ = {
    "pipe", --copper pipe - *slightly* increased range and damage.
    "shrapnel", --rocks (any type) - increases range but decreases damage.
    "shaped", --cut stone - decreases range but increases damage.
    "stun", --undecided - makes enemies panic/get stunned.
    "magic", --nightmare fuel - improves other effects.
    --"sticky",     --honey  - slowdowns affected entites. Gonna wait for Wixie merge to UM so I can just reuse the round debuff for this.
    "waterproof", --sludge - makes bombs not sink, ignites when fired from a cannon.
    "fire" --charcoal - turns the bomb incendiary.
}

if KnownModIndex:IsModEnabled("workshop-2758491764") then
    table.insert(effects_, "sticky")
end

local explosives_ = {
    "he",
    "me",
    "le"
}

local bomb

local function MakeBomb(inst)
    local detonator_type
    local effects = {}
    local explosive_type
    local dud = false

    if inst == "um_bomb_dud" then
        dud = true
    end

    if string.match(inst, "he_") then
        explosive_type = "he"
    elseif string.match(inst, "me_") then
        explosive_type = "me"
    elseif string.match(inst, "le_") then
        explosive_type = "le"
    end

    if string.match(inst, "fuse_") then
        detonator_type = "fuse"
    elseif string.match(inst, "impact_") then
        detonator_type = "impact"
    elseif string.match(inst, "prox_") then
        detonator_type = "prox"
    elseif string.match(inst, "timed_") then
        detonator_type = "timed"
    end

    if string.match(inst, "shrapnel") then
        table.insert(effects, "shrapnel")
    end
    if string.match(inst, "shock") then
        table.insert(effects, "shock")
    end
    if string.match(inst, "magic") then
        table.insert(effects, "magic")
    end
    if string.match(inst, "sticky") then
        table.insert(effects, "sticky")
    end
    if string.match(inst, "shaped") then
        table.insert(effects, "shaped")
    end
    if string.match(inst, "gas") then
        table.insert(effects, "gas")
    end
    if string.match(inst, "waterproof") then
        table.insert(effects, "waterproof")
    end
    if string.match(inst, "fire") then
        table.insert(effects, "fire")
    end
    if string.match(inst, "web") then
        table.insert(effects, "web")
    end
    local other_inst = inst
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        -- projectile (from complexprojectile component) added to pristine state for optimization
        inst:AddTag("projectile")
        inst:AddTag("weapon")
        inst:AddTag("um_bomb")
        inst:AddTag("rechargeable")

        inst.AnimState:SetBank("waterballoon")
        inst.AnimState:SetBuild("waterballoon")
        inst.AnimState:PlayAnimation("idle")

        inst.entity:SetPristine()

        inst.projectileprefab = other_inst
        inst.entity:AddTag("boatcannon_ammo")
        -- what the hell is the inst.entity anyways?!

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("locomotor")

        inst:AddComponent("complexprojectile")
        inst.components.complexprojectile:SetHorizontalSpeed(20)
        inst.components.complexprojectile:SetGravity(-40)

        inst.effects = effects
        inst.detonator_type = detonator_type
        inst.explosive_type = explosive_type
        inst.dud = dud

        inst:AddComponent("reticule")
        inst.components.reticule.targetfn = ReticuleTargetFn
        inst.components.reticule.ease = true

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.sinks = true

        if table.contains(effects, "waterproof") then
            MakeInventoryFloatable(inst, "med", 0.05, 0.65)
            inst.components.inventoryitem.sinks = false
        end

        MakeSmallBurnable(inst)
        inst.components.burnable:SetOnBurntFn(Detonate)
        inst.components.burnable.burntime = 5

        MakeSmallPropagator(inst)

        inst:AddComponent("equippable")
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.components.equippable.equipstack = true

        if inst.detonator_type == "timed" then
            --inst.components.equippable.equipstack = false

            inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

            inst:AddComponent("rechargeable")
            inst.components.rechargeable:SetOnChargedFn(Detonate)
            --inst.components.rechargeable:SetChargeTime(10) that just makes it blow up after being created lmfao
            --inst.components.rechargeable:SetOnDischargedFn(ActivateEquippable)

            inst:AddComponent("useableitem")
            inst.components.useableitem:SetOnUseFn(OnUsed)
        end

        inst.components.complexprojectile:SetHorizontalSpeed(15)
        inst.components.complexprojectile:SetGravity(-35)
        inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
        inst.components.complexprojectile:SetOnLaunch(onthrown)
        inst.components.complexprojectile:SetOnHit(OnHit)

        inst:AddTag("allow_action_on_impassable")

        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(0)
        inst.components.weapon:SetRange(12, 14)

        inst:AddComponent("groundpounder")
        inst.components.groundpounder.destroyer = true -- HELP THIS ISN'T WORKING
        inst.components.groundpounder.ringDelay = 0.1
        inst.components.groundpounder.initialRadius = 1
        inst.components.groundpounder.radiusStepDistance = 2
        inst.components.groundpounder.pointDensity = .25
        if table.contains(effects, "fire") then
            inst.components.groundpounder.burner = true
        end

        inst:AddComponent("stackable")

        inst:AddComponent("inspectable")

        local radius =
            ((inst.explosive_type == "he" and 3) or (inst.explosive_type == "me" and 2) or 1) +
            (inst.components.stackable:StackSize() * 0.75) *
            ((table.contains(inst.effects, "pipe") and 2) or
            (table.contains(inst.effects, "shrapnel") and 4) and
            (table.contains(inst.effects, "shaped") and 0.25) or
            1)

        local damage =
            ((inst.explosive_type == "he" and 200) or (inst.explosive_type == "me" and 100) or 50) *
            ((table.contains(inst.effects, "pipe") and 1.25) or 1) *
            ((table.contains(inst.effects, "shrapnel") and 0.75) or 1) *
            ((table.contains(inst.effects, "shaped") and 1.5) or 1)

        inst:AddComponent("combat")
        inst.components.combat:SetDefaultDamage(damage)
        inst.components.combat:SetAreaDamage(radius)

        if inst.detonator_type == "prox" then
            inst:AddComponent("timer")
            inst:ListenForEvent("timerdone", OnTimerDone)

            inst:AddComponent("activatable")
            inst.components.activatable.forcerightclickaction = true
            inst.components.activatable.CanActivateFn = CanActivate
            inst.components.activatable.OnActivate = OnActivated
        end
        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(inst, fn)
end

local all_bombs = {}

for k, eff in ipairs(combinations(effects_, 2)) do
    for i, det in ipairs(detonators_) do
        for l, expl in ipairs(explosives_) do
            bomb = "um_bomb_" .. expl .. "_" .. det .. "_" .. unpack(eff) .. "_" .. string.gsub(unpack(eff, 2), "_", "")
            table.insert(all_bombs, bomb)
        end
    end
end

table.insert(all_bombs, "um_bomb_dud")
printwrap("Registering all bomb types", all_bombs)

local bomb_prefabs = {}

for k, v in ipairs(all_bombs) do
    local bombs = MakeBomb(v)
    table.insert(bomb_prefabs, bombs)
end

return unpack(bomb_prefabs)