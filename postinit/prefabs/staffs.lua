local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------

env.AddPrefabPostInit("icestaff", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    local _onattack = inst.components.weapon.onattack

    local function OnAttack(inst, attacker, target, skipsanity)
        if attacker:HasTag("wathom") then
            local ret = _onattack(inst, attacker, target, skipsanity)
            local x, y, z = target.Transform:GetWorldPosition()

            local ents = TheSim:FindEntities(x, y, z, 4, nil,
                { "player", "playerghost", "notarget", "companion", "abigail", "INLIMBO" })

            if target.components.freezable ~= nil then
                target.components.freezable:AddColdness(1)
            end
            for k, v in ipairs(ents) do
                if v ~= target then
                    if v.components.freezable ~= nil then
                        v.components.freezable:AddColdness(2)
                        v.components.freezable:SpawnShatterFX()
                    end
                end
            end
            if target.components.health ~= nil then
                target.components.health:DoDelta(-34)
            end
            return ret
        else
            return _onattack(inst, attacker, target, skipsanity)
        end
    end

    inst.components.weapon:SetOnAttack(OnAttack)
end)

env.AddPrefabPostInit("firestaff", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    local _onattack = inst.components.weapon.onattack

    local function OnAttack(inst, attacker, target, skipsanity)
        if attacker:HasTag("wathom") then
            local ret = _onattack(inst, attacker, target, skipsanity)
            local x, y, z = target.Transform:GetWorldPosition()

            local ents = TheSim:FindEntities(x, y, z, 4, { "_health" },
                { "player", "playerghost", "notarget", "companion", "abigail", "INLIMBO" })

            for k, v in ipairs(ents) do
                if v ~= target then
                    if v.components.burnable ~= nil then
                        v.components.burnable:Ignite(true)
                    end
                end
                if v.components.health ~= nil and not v.components.health:IsDead() and v.components.combat ~= nil then
                    v.components.combat:GetAttacked(attacker, 34, nil)
                end
            end
            return ret
        else
            return _onattack(inst, attacker, target, skipsanity)
        end
    end

    inst.components.weapon:SetOnAttack(OnAttack)
end)

local function SpikeWaves(inst, target, attacker, angle)
    local target_index = {}
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local rad = math.rad(angle)
    local velx = math.cos(rad) * 1.25
    local velz = -math.sin(rad) * 1.25
    for i = 1, 5 do
        inst:DoTaskInTime(FRAMES * i * 1.5, function()
            local dx, dy, dz = ix + (i * velx), 0, iz + (i * velz)
            local fx = SpawnPrefab("warg_mutated_ember_fx")
            fx.Transform:SetPosition(dx + math.random(), dy, dz + math.random())
            fx:RestartFX(0.25 + math.random())
            fx:DoTaskInTime(math.random() + 0.5 , fx.KillFX)

            if math.random() > 0.5 then
                local fx2 = SpawnPrefab("warg_mutated_breath_fx")
                fx2.Transform:SetPosition(dx + math.random(), dy, dz + math.random())
                fx2:RestartFX(.25 + math.random())
                fx2:DoTaskInTime(math.random() + 0.5, fx2.KillFX)
                fx2.Transform:SetScale(0.5, 0.5, 0.5)
            end
            inst:DoTaskInTime(.6, function()
                local ents = TheSim:FindEntities(dx, dy, dz, 1.5, { "_health", "_combat" }, { "FX", "NOCLICK", "INLIMBO", "notarget", "player", "playerghost", "companion"})
                for k, v in ipairs(ents) do
                    if  v ~= inst and v.components.combat ~= nil and attacker.components.combat ~= nil and attacker.components.combat:IsValidTarget(v) then
                        v.components.combat:GetAttacked(attacker, 0, nil, nil, { planar = 17.5 })
                    end
                end
            end)
        end)
    end
end

env.AddPrefabPostInit("staff_lunarplant", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    local _onattack = inst.components.weapon.onattack

    local function OnAttack(inst, attacker, target, skipsanity)
        if attacker:HasTag("wathom") then
            inst.components.weapon:SetProjectile(nil)
            local ret = _onattack(inst, attacker, target, skipsanity)

            for angle = -20, 20, 4 do
                SpikeWaves(inst, target, attacker, angle + attacker.Transform:GetRotation())
                target.components.combat:GetAttacked(attacker, 0, nil, nil, { planar = 34 })
            end
            inst.SoundEmitter:PlaySound("rifts/lunarthrall_bomb/explode")

            return ret
        else
            inst.components.weapon:SetProjectile("brilliance_projectile_fx")
            return _onattack(inst, attacker, target, skipsanity)
        end
    end

    inst.components.weapon:SetOnAttack(OnAttack)
end)
