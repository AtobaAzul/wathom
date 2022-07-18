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
            inst:ListenForEvent(
                "on_landed",
                function(inst)
                    if inst:IsOnOcean() then
                        SpawnPrefab("wave_splash").Transform:SetPosition(inst.Transform:GetWorldPosition())
                    end
                    inst:RemoveComponent("groundshadowhandler")
                end
            )
        end
    end
end

local UmExplosive =
    Class(
    function(self, inst)
        self.inst = inst

        self.effects = {}
        self.detonator = nil
        self.
        self.dud = false
    end,
    nil,
    {
        launch_away = launch_away
    }
)

--optional param to make enemies retaliate
function UmExplosive:Detonate(attacker)
    local inst = self.inst

    local x, y, z = inst.Transform:GetWorldPosition()
    local position = inst:GetPosition()
    local range_scale = 2.5 + (inst.components.stackable:StackSize() * 0.5) * ((table.contains(inst.effects, "shaped") and 0.5) or (table.contains(inst.effects, "he") and 2) or (table.contains(inst.effects, "le") and 1.5) or 1)

    inst.components.combat:DoAreaAttack(inst, range_scale, nil, nil, nil, AREAATTACK_EXCLUDETAGS)

    local affected_entities = TheSim:FindEntities(x, 0, z, range_scale, nil, AREAATTACK_EXCLUDETAGS) -- Set y to zero to look for objects floating on the floor

    for i, affected_entity in ipairs(affected_entities) do
        --[[if affected_entity.detonator_type ~= nil then THIS GIVES A STACK OVERFLOW I HAVE NO IDEA WHY
            affected_entity.components.burnable.onburnt(affected_entity)
        else]]
        if affected_entity.components.workable ~= nil and (table.contains(inst.effects, "he") or table.contains(inst.effects, "le")) then
            affected_entity.components.workable:Destroy(inst)
        end

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
        elseif affected_entity.prefab == "bullkelp_plant" then -- Spawn kelp roots along with kelp is a bullkelp plant is hit
            local ae_x, ae_y, ae_z = affected_entity.Transform:GetWorldPosition()

            if affected_entity.components.pickable and affected_entity.components.pickable:CanBePicked() then             -- Generic pickup item
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
        elseif affected_entity.components.burnable ~= nil and table.contains(inst.effects, "fire") then
            affected_entity.components.burnable:Ignite()
        elseif affected_entity.components.inventoryitem ~= nil then
            launch_away(affected_entity, position)
        elseif affected_entity.waveactive then
            affected_entity:DoSplash()
        end
    end

    if inst:IsOnOcean() and not table.contains(inst.effects, "waterproof") then
        -- Landed on ground
        SpawnPrefab("crab_king_waterspout").Transform:SetPosition(inst.Transform:GetWorldPosition())
    else
        if table.contains(inst.effects, "fire") then
            local fx = SpawnPrefab("halloween_firepuff_1")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            fx.Transform:SetScale(
                (inst.detonator_type == "he" and 4) or 2,
                (inst.detonator_type == "he" and 4) or 2,
                (inst.detonator_type == "he" and 4) or 2
            )
        elseif inst.detonator_type == "le" then
            local fx = SpawnPrefab("explode_small")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            fx.Transform:SetScale(1, 1, 1)
        elseif inst.detonator_type == "prox" then
            local fx = SpawnPrefab("blueberryexplosion")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            fx.Transform:SetScale(2.5, 2.5, 2, 5)
            local fx1 = SpawnPrefab("explode_small")
            fx1.Transform:SetPosition(inst.Transform:GetWorldPosition())
            fx1.Transform:SetScale(1, 1, 1)
            SpawnPrefab("blueberryexplosion").Transform:SetPosition(inst.Transform:GetWorldPosition())
        elseif inst.detonator_type == "he" then
            local fx = SpawnPrefab("electric_explosion")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            fx.Transform:SetScale(1, 1, 1)
        end

        if inst.detonator_type == "he" then
            inst.components.groundpounder.numRings = inst.components.stackable:StackSize()
            inst.components.groundpounder.destructionRings = inst.components.stackable:StackSize() * 1.5
            inst.components.groundpounder.damageRings = inst.components.stackable:StackSize() * 1.5
            inst.components.groundpounder.ring_fx_scale = 0.75 * inst.components.stackable:StackSize() * 0.1
            inst.components.groundpounder:GroundPound()
        end
        if table.contains(inst.effects, "shaped") then
            SpawnPrefab("cannonball_used").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
        if TheWorld.components.dockmanager ~= nil then
            -- Damage any docks we hit.
            TheWorld.components.dockmanager:DamageDockAtPoint(x, y, z, 200)
        end
    end
    inst:Remove()
end
