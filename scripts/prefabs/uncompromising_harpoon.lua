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
	if inst.target ~= nil then
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
		end
	end
end

local function OnCooldown(inst)
    inst._cdtask = nil
end


local function DoPuff(inst, channeler)
	if inst._cdtask == nil then
        inst._cdtask = inst:DoTaskInTime(1, OnCooldown)
		if inst.distance > 50 then
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
	inst.distance = 200

    inst:AddComponent("inspectable")
	
    inst:AddComponent("channelable")
    inst.components.channelable:SetChannelingFn(DoPuff, OnStopChanneling)
    inst.components.channelable.use_channel_longaction_noloop = true
    inst.components.channelable.skip_state_channeling = true
	
	inst:DoPeriodicTask(FRAMES, Vac)
	
	inst.persists = false
	
    return inst
end
-------------------------------------------------------------------------------
return Prefab("uncompromising_harpoon", pipe, assets, prefabs),
		Prefab("uncompromising_harpoonreel", reel, assets, prefabs)
