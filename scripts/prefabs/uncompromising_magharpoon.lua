local assets =
{
    Asset("ANIM", "anim/blow_dart.zip"),
    Asset("ANIM", "anim/swap_blowdart.zip"),
    Asset("ANIM", "anim/swap_blowdart_pipe.zip"),
}

local _turnoffstring = ACTIONS.TURNOFF.strfn

ACTIONS.TURNOFF.strfn = function(act)
    local tar = act.target
	return tar ~= nil and tar:HasTag("harpoonreel") and "HARPOON" or _turnoffstring(act)
end

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
    owner.AnimState:OverrideSymbol("swap_object", "swap_um_harpoon", "swap_um_harpoon")
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
    end
	
	
	if inst.x ~= nil then
		local ground = TheWorld.Map:IsPassableAtPoint(inst.x, inst.y, inst.z)
		local boat = TheWorld.Map:GetPlatformAtPoint(inst.x, inst.z)
		
		if ground or boat then
			--[[local hitpoint = SpawnPrefab("spear")
			hitpoint.Transform:SetPosition(inst.x, inst.y, inst.z)
			hitpoint.entity:SetParent(target.entity)]]
			
			local reel = SpawnPrefab("uncompromising_magharpoonreel")
			reel.Transform:SetPosition(inst.x, inst.y, inst.z)
			reel.target = target
			reel.AnimState:PlayAnimation("place")
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
end

local function pipethrown(inst)
    --inst.AnimState:PlayAnimation("dart_pipe")
    inst:AddTag("NOCLICK")
    inst.persists = false
end

local function spawntornado(inst, target)
	local owner = inst.components.inventoryitem.owner
	
	if owner == nil then
		return
	end
	
	local x, y, z = owner.Transform:GetWorldPosition()
	local boat = TheWorld.Map:GetPlatformAtPoint(x, z)
	
	if target.components ~= nil and target.components.workable and not owner:GetCurrentPlatform() then
		return
	end
	
	local proj = SpawnPrefab("uncompromising_magharpoon_projectile")
	proj.Transform:SetPosition(x, y, z)
	proj.components.projectile:Throw(owner, target)
	
	inst:Remove()
end

local function fncommon()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("um_harpoon")
    inst.AnimState:SetBuild("um_harpoon")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("quickcast")
    inst:AddTag("nopunch")

    inst.spelltype = "HARPOON"

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "small", 0.05, {0.75, 0.5, 0.75})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(34)
    -------
	
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SPEAR_USES)
    inst.components.finiteuses:SetUses(TUNING.SPEAR_USES)

    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/uncompromising_harpoon.xml"
	
    inst:AddComponent("spellcaster")
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canonlyuseonworkable = true
    inst.components.spellcaster.canonlyuseoncombat = true
    inst.components.spellcaster.quickcast = true
    inst.components.spellcaster.canuseonpoint = false
    inst.components.spellcaster.canuseonpoint_water = false
    inst.components.spellcaster:SetSpellFn(spawntornado)
    inst.components.spellcaster.castingstate = "castspell_tornado"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

local function KillRopes(inst)
	inst.SoundEmitter:PlaySound("UCSounds/harpoon/break")

	inst:AddTag("NOCLICK")

	if inst.harpoontask ~= nil then
		inst.harpoontask:Cancel()
	end
		 
	inst.harpoontask = nil
	
	if inst.hitfx ~= nil then
		inst.hitfx:Remove()
	end
	
	inst:Remove()
end

local function harpoon()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("um_harpoon")
    inst.AnimState:SetBuild("um_harpoon")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("blowdart")
    inst:AddTag("sharp")
    inst:AddTag("weapon")
    inst:AddTag("projectile")
	inst:AddTag("NOCLICK")
	RemovePhysicsColliders(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(34)
    inst.components.weapon:SetRange(8, 10)

    inst:AddComponent("projectile")
    inst.components.projectile:SetOnThrownFn(pipethrown)
    inst.components.projectile:SetRange(TUNING.WALRUS_DART_RANGE)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetLaunchOffset(Vector3(3, 2, 0))
    inst.components.projectile:SetSpeed(60)
    inst.components.projectile:SetOnHitFn(onhit)
    inst:ListenForEvent("onthrown", onthrown)

    inst.persists = false

    return inst
end

local function OnCooldown(inst)
    inst._cdtask = nil
end

local function CooldownSound(inst)
    inst._soundcd = nil
end

local function Vac(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	if inst ~= nil and inst:IsValid() and inst.target ~= nil and inst.target:IsValid() then
		local px, py, pz = inst.target.Transform:GetWorldPosition()
			
		local distmult = (inst:GetDistanceSqToInst(inst.target) / 100)
		print(distmult)
				
				
		local platform = inst:GetCurrentPlatform()
			
		if platform ~= nil and platform:IsValid() then
			if inst._cdtask == nil then
				
				inst._cdtask = inst:DoTaskInTime(.5, OnCooldown)
					
				local row_dir_x, row_dir_z = VecUtil_Normalize(px - x, pz - z)
					
				local boat_physics = platform.components.boatphysics
				
				boat_physics:ApplyForce(row_dir_x, row_dir_z, .25 * distmult)
			end
		end
			
		if inst.target.components.locomotor ~= nil then
			local rad = math.rad(inst.target:GetAngleToPoint(x, y, z))
			local velx = math.cos(rad) --* 4.5
			local velz = -math.sin(rad) --* 4.5
				
			local locationmodifier = platform ~= nil and 0.5 or 1.5
				
			local dx, dy, dz = px + (((FRAMES * 5) * velx) * locationmodifier) * distmult, 0, pz + (((FRAMES * 5) * velz) * locationmodifier) * distmult
					
			local ground = TheWorld.Map:IsPassableAtPoint(dx, dy, dz)
			local boat = TheWorld.Map:GetPlatformAtPoint(dx, dz)
			if dx ~= nil and (ground or boat or inst.target.components.locomotor:CanPathfindOnWater()) then
				inst.target.Physics:Teleport(dx, py, dz)
			end
		end
	else
		KillRopes(inst)
		return
	end
end

local function InitializeRope(inst)
	if inst.target ~= nil and inst.target:IsValid() then
		local hitfx = SpawnPrefab("uncompromising_magharpoonhitfx")
		hitfx.Transform:SetPosition(inst.target.Transform:GetWorldPosition())
		
		hitfx.entity:SetParent(inst.target.entity)
	end
end

local function DoPuff(inst, channeler)
	inst.SoundEmitter:PlaySound("UCSounds/harpoon/reel")
	inst.AnimState:PlayAnimation("reel")

    inst.components.activatable.inactive = true
	
	if inst.power > 15 then
		inst.power = inst.power - 15
	end
end

local function OnStopChanneling(inst)
	inst.channeler = nil
end

local function GetVerb(inst)
	return "HARPOON"
end

local function reel()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
	
	inst:AddTag("harpoonreel")

    inst.AnimState:SetBank("UM_harpoonreel")
    inst.AnimState:SetBuild("UM_harpoonreel")
    inst.AnimState:PlayAnimation("idle")

    MakeSnowCoveredPristine(inst)
	
	inst.GetActivateVerb = GetVerb

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.target = nil

    inst:AddComponent("inspectable")
	
	--[[inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = DoPuff
    inst.components.activatable.inactive = true
	inst.components.activatable.quickaction = true]]
	
    inst:AddComponent("machine")
    inst.components.machine.turnonfn = KillRopes
    inst.components.machine.turnofffn = KillRopes
    inst.components.machine.cooldowntime = 0.5
	inst.components.machine.ison = true
	
	inst:DoTaskInTime(0, InitializeRope)
	inst.harpoontask = inst:DoPeriodicTask(0.05, Vac)
	inst:DoTaskInTime(60, KillRopes)
	
	inst.persists = false
	
    return inst
end

local function fnhit()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("um_harpoonhitfx")
    inst.AnimState:SetBuild("um_harpoonhitfx")
    inst.AnimState:PlayAnimation("idle")
	inst.Transform:SetEightFaced()
	
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")
	inst:AddTag("fx")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.persists = false
	
    return inst
end
-------------------------------------------------------------------------------
return Prefab("uncompromising_magharpoon", fncommon, assets, prefabs),
		Prefab("uncompromising_magharpoon_projectile", harpoon, assets, prefabs),
		Prefab("uncompromising_magharpoonreel", reel, assets, prefabs),
		Prefab("uncompromising_magharpoonhitfx", fnhit, assets, prefabs)