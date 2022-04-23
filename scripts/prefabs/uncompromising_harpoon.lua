local assets =
{
    Asset("ANIM", "anim/blow_dart.zip"),
    Asset("ANIM", "anim/swap_blowdart.zip"),
    Asset("ANIM", "anim/swap_blowdart_pipe.zip"),
}

local prefabs =
{
    "impact",
}

local prefabs_yellow =
{
    "impact",
    "electrichitsparks",
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_blowdart", "swap_blowdart")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onhit(inst, attacker, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx ~= nil and target.components.combat then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
        if attacker ~= nil and attacker:IsValid() then
            impactfx:FacePoint(attacker.Transform:GetWorldPosition())
        end
		
		if inst.x ~= nil and target.components.locomotor then
			local reel = SpawnPrefab("uncompromising_harpoonreel")
			reel.Transform:SetPosition(inst.x, inst.y, inst.z)
			reel.target = target
		end
    end
	
    inst:Remove()
end

local function onthrown(inst, data)
	if data ~= nil and data.thrower then
		local x, y, z = data.thrower.Transform:GetWorldPosition()
		inst.x = x
		inst.y = y
		inst.z = z
	end

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.components.inventoryitem.pushlandedevents = false
end

local function common(anim, tags, removephysicscolliders)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blow_dart")
    inst.AnimState:SetBuild("blow_dart")
    inst.AnimState:PlayAnimation(anim)

    inst:AddTag("blowdart")
    inst:AddTag("sharp")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    if tags ~= nil then
        for i, v in ipairs(tags) do
            inst:AddTag(v)
        end
    end

    if removephysicscolliders then
        RemovePhysicsColliders(inst)
    end

    MakeInventoryFloatable(inst, "small", 0.05, {0.75, 0.5, 0.75})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(60)
    inst.components.projectile:SetOnHitFn(onhit)
    inst:ListenForEvent("onthrown", onthrown)
    -------

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    MakeHauntableLaunch(inst)

    return inst
end

-------------------------------------------------------------------------------
-- Pipe Dart (Damage)
-------------------------------------------------------------------------------
local function pipeequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_blowdart_pipe", "swap_blowdart_pipe")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function pipethrown(inst)
    inst.AnimState:PlayAnimation("dart_pipe")
    inst:AddTag("NOCLICK")
    inst.persists = false
end

local function pipe()
    local inst = common("idle_pipe")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.equippable:SetOnEquip(pipeequip)
    inst.components.weapon:SetDamage(TUNING.PIPE_DART_DAMAGE)
    inst.components.projectile:SetOnThrownFn(pipethrown)

    local swap_data = {sym_build = "swap_blowdart_pipe", bank = "blow_dart", anim = "idle_pipe"}
    inst.components.floater:SetBankSwapOnFloat(true, -4, swap_data)

    return inst
end

local function Vac(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	if inst ~= nil and inst:IsValid() and inst.target ~= nil and inst.target:IsValid() then
		if inst:GetDistanceSqToInst(inst.target) ~= nil and inst:GetDistanceSqToInst(inst.target) > inst.distance then
			local px, py, pz = inst.target.Transform:GetWorldPosition()
				
			local rad = math.rad(inst.target:GetAngleToPoint(x, y, z))
			local velx = math.cos(rad) --* 4.5
			local velz = -math.sin(rad) --* 4.5
			
			local dx, dy, dz = px + ((FRAMES * 5) * velx) * inst.Transform:GetScale(), 0, pz + ((FRAMES * 5) * velz) * inst.Transform:GetScale()
				
			local ground = TheWorld.Map:IsPassableAtPoint(dx, dy, dz)
			local boat = TheWorld.Map:GetPlatformAtPoint(dx, dz)
			if dx ~= nil and (ground or boat) then
				inst.target.Transform:SetPosition(dx, dy, dz)
			end
			
			local tensionmult = inst.target:HasTag("epic") and 2 or inst.target:HasTag("smallcreature") and .5 or 1
			inst.tension = inst.tension + (1 * tensionmult)
		elseif inst.tension > 1 then
			inst.tension = inst.tension - 0.1
		end
	else
		inst:Remove()
	end
		
	if inst ~= nil and inst.tension >= 200 then
		inst:Remove()
	end
	
	
	if inst ~= nil and inst:IsValid() and inst.target ~= nil and inst.target:IsValid() and inst.rope20 ~= nil and inst:GetDistanceSqToInst(inst.target) ~= nil then
		local scale = (inst:GetDistanceSqToInst(inst.target) / 100)
		
		--[[if scale > 1 then
			scale = 1
		end]]
		
		for i2 = 1, 20 do
			local p2x, p2y, p2z = inst.target.Transform:GetWorldPosition()
			local rad2 = math.rad(inst:GetAngleToPoint(p2x, p2y, p2z))
			local velx2 = math.cos(rad2) --* 4.5
			local velz2 = -math.sin(rad2) --* 4.5

			local dx, dy, dz = x + (((i2 * velx2) / 2) * scale), (0.06 * i2), z + (((i2 * velz2) / 2) * scale)
			if i2 == 1 then
				inst.rope1.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 2 then
				inst.rope2.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 3 then
				inst.rope3.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 4 then
				inst.rope4.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 5 then
				inst.rope5.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 6 then
				inst.rope6.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 7 then
				inst.rope7.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 8 then
				inst.rope8.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 9 then
				inst.rope9.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 10 then
				inst.rope10.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 11 then
				inst.rope11.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 12 then
				inst.rope12.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 13 then
				inst.rope13.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 14 then
				inst.rope14.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 15 then
				inst.rope15.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 16 then
				inst.rope16.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 17 then
				inst.rope17.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 18 then
				inst.rope18.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 19 then
				inst.rope19.Transform:SetPosition(dx, dy, dz)
			elseif i2 == 20 then
				inst.rope20.Transform:SetPosition(dx, dy, dz)
			end
		end
	elseif inst.rope20 ~= nil then
		for i2 = 1, 20 do
			if i2 == 1 then
				inst.rope1:Remove()
			elseif i2 == 2 then
				inst.rope2:Remove()
			elseif i2 == 3 then
				inst.rope3:Remove()
			elseif i2 == 4 then
				inst.rope4:Remove()
			elseif i2 == 5 then
				inst.rope5:Remove()
			elseif i2 == 6 then
				inst.rope6:Remove()
			elseif i2 == 7 then
				inst.rope7:Remove()
			elseif i2 == 8 then
				inst.rope8:Remove()
			elseif i2 == 9 then
				inst.rope9:Remove()
			elseif i2 == 10 then
				inst.rope10:Remove()
			elseif i2 == 11 then
				inst.rope11:Remove()
			elseif i2 == 12 then
				inst.rope12:Remove()
			elseif i2 == 13 then
				inst.rope13:Remove()
			elseif i2 == 14 then
				inst.rope14:Remove()
			elseif i2 == 15 then
				inst.rope15:Remove()
			elseif i2 == 16 then
				inst.rope16:Remove()
			elseif i2 == 17 then
				inst.rope17:Remove()
			elseif i2 == 18 then
				inst.rope18:Remove()
			elseif i2 == 19 then
				inst.rope19:Remove()
			elseif i2 == 20 then
				inst.rope20:Remove()
			end
		end
	end
end

local function InitializeRope(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	if inst.target ~= nil then
		for i = 1, 20 do
			if i == 1 then
				inst.rope1 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope1.Transform:SetPosition(x, y, z)
			elseif i == 2 then
				inst.rope2 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope2.Transform:SetPosition(x, y, z)
			elseif i == 3 then
				inst.rope3 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope3.Transform:SetPosition(x, y, z)
			elseif i == 4 then
				inst.rope4 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope4.Transform:SetPosition(x, y, z)
			elseif i == 5 then
				inst.rope5 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope5.Transform:SetPosition(x, y, z)
			elseif i == 6 then
				inst.rope6 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope6.Transform:SetPosition(x, y, z)
			elseif i == 7 then
				inst.rope7 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope7.Transform:SetPosition(x, y, z)
			elseif i == 8 then
				inst.rope8 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope8.Transform:SetPosition(x, y, z)
			elseif i == 9 then
				inst.rope9 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope9.Transform:SetPosition(x, y, z)
			elseif i == 10 then
				inst.rope10 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope10.Transform:SetPosition(x, y, z)
			elseif i == 11 then
				inst.rope11 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope11.Transform:SetPosition(x, y, z)
			elseif i == 12 then
				inst.rope12 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope12.Transform:SetPosition(x, y, z)
			elseif i == 13 then
				inst.rope13 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope13.Transform:SetPosition(x, y, z)
			elseif i == 14 then
				inst.rope14 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope14.Transform:SetPosition(x, y, z)
			elseif i == 15 then
				inst.rope15 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope15.Transform:SetPosition(x, y, z)
			elseif i == 16 then
				inst.rope16 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope16.Transform:SetPosition(x, y, z)
			elseif i == 17 then
				inst.rope17 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope17.Transform:SetPosition(x, y, z)
			elseif i == 18 then
				inst.rope18 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope18.Transform:SetPosition(x, y, z)
			elseif i == 19 then
				inst.rope19 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope19.Transform:SetPosition(x, y, z)
			elseif i == 20 then
				inst.rope20 = SpawnPrefab("uncompromising_harpoonrope")
				inst.rope20.Transform:SetPosition(x, y, z)
			end
		end
	end
end

local function OnCooldown(inst)
    inst._cdtask = nil
end


local function DoPuff(inst, channeler)
	if inst._cdtask == nil then
        inst._cdtask = inst:DoTaskInTime(1, OnCooldown)
		if inst.distance > 25 then
			inst.distance = inst.distance - 25
		end
	end
end

local function OnStopChanneling(inst)
	inst.channeler = nil
end

local function reel()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("boat_wheel")
    inst.AnimState:SetBuild("boat_wheel")
    inst.AnimState:PlayAnimation("idle")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.target = nil
	inst.distance = 100
	inst.tension = 1

    inst:AddComponent("inspectable")
	
    inst:AddComponent("channelable")
    inst.components.channelable:SetChannelingFn(DoPuff, OnStopChanneling)
    inst.components.channelable.use_channel_longaction_noloop = true
    inst.components.channelable.skip_state_channeling = true
	inst:DoTaskInTime(0, InitializeRope)
	inst:DoPeriodicTask(FRAMES, Vac)
	
	inst.persists = false
	
    return inst
end

local function rope()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("snowball")
    inst.AnimState:SetBuild("snowball")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.persists = false
	
    return inst
end
-------------------------------------------------------------------------------
return Prefab("uncompromising_harpoon", pipe, assets, prefabs),
		Prefab("uncompromising_harpoonreel", reel, assets, prefabs),
		Prefab("uncompromising_harpoonrope", rope, assets, prefabs)
