local assets =
{
    Asset("ANIM", "anim/magnerang.zip"),
    Asset("ANIM", "anim/swap_magnerang.zip"),
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
    owner.AnimState:OverrideSymbol("swap_object", "swap_magnerang", "swap_boomerang")
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
			local reel = SpawnPrefab("um_magnerangreel")
			reel.Transform:SetPosition(inst.x, inst.y, inst.z)
			reel.target = target
			reel.AnimState:PlayAnimation("place")
		end
	end
	
    inst:Remove()
end

local function pipethrown(inst, owner, target)
	if owner ~= nil then
		local x, y, z = owner.Transform:GetWorldPosition()
		inst.x = x
		inst.y = y
		inst.z = z
	end
	
	inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    inst.AnimState:PlayAnimation("spin_loop", true)
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
	
	local proj = SpawnPrefab("um_magnerang_projectile")
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

    inst.AnimState:SetBank("boomerang")
    inst.AnimState:SetBuild("magnerang")
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
    inst.components.weapon:SetDamage(10)
    -------

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/um_magnerang.xml"
	
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

local function onhit_return(inst, attacker, target)
	if target ~= nil then
		local x, y, z = target.Transform:GetWorldPosition()
		local magnerang = SpawnPrefab("um_magnerang")
		magnerang.Transform:SetPosition(x, 1.5, z)
		magnerang.target = target
	end
	
	if inst.reel ~= nil then
		inst.reel:Remove()
	end
	
    inst:Remove()
end

local function onmiss_return(inst)
	if inst.reel ~= nil then
		inst.reel:Remove()
	end
	
    inst:Remove()
end

local function harpoon()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("boomerang")
    inst.AnimState:SetBuild("magnerang")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("thrown")
    inst:AddTag("weapon")
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
    inst.components.weapon:SetDamage(10)
    inst.components.weapon:SetRange(8, 10)

    inst:AddComponent("projectile")
    inst.components.projectile:SetOnThrownFn(pipethrown)
    inst.components.projectile:SetRange(TUNING.WALRUS_DART_RANGE)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetLaunchOffset(Vector3(3, 2, 0))
    inst.components.projectile:SetSpeed(10)
    inst.components.projectile:SetOnHitFn(onhit)

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
	if inst.magnet_damage < 200 and inst ~= nil and inst:IsValid() and inst.target ~= nil and inst.target:IsValid() then
		local px, py, pz = inst.target.Transform:GetWorldPosition()
			
		local distmult = (inst:GetDistanceSqToInst(inst.target) / 200)
		print(distmult)
		
		inst.magnet_damage = inst.magnet_damage + distmult
		
		if distmult >= 0.15 then
			local platform = inst:GetCurrentPlatform()
				
			if platform ~= nil and platform:IsValid() then
				if inst._cdtask == nil then
					
					inst._cdtask = inst:DoTaskInTime(.5, OnCooldown)
						
					local row_dir_x, row_dir_z = VecUtil_Normalize(px - x, pz - z)
						
					local boat_physics = platform.components.boatphysics
					
					boat_physics:ApplyForce(row_dir_x, row_dir_z, .15 * distmult)
				end
			end
				
			if inst.target.components.locomotor ~= nil then
				local rad = math.rad(inst.target:GetAngleToPoint(x, y, z))
				local velx = math.cos(rad) --* 4.5
				local velz = -math.sin(rad) --* 4.5
					
				local locationmodifier = platform ~= nil and 0.5 or 1.5
					
				local dx, dy, dz = px + (((FRAMES * 4) * velx) * locationmodifier) * distmult, 0, pz + (((FRAMES * 4) * velz) * locationmodifier) * distmult
						
				local ground = TheWorld.Map:IsPassableAtPoint(dx, dy, dz)
				local boat = TheWorld.Map:GetPlatformAtPoint(dx, dz)
				if dx ~= nil and (ground or boat or inst.target.components.locomotor:CanPathfindOnWater()) then
					inst.target.Physics:Teleport(dx, py, dz)
				end
			end
		end
	else
		inst:KillRopes()
		return
	end
end

local function KillRopes(inst)
	inst.SoundEmitter:PlaySound("UCSounds/harpoon/break")

	inst:AddTag("NOCLICK")
	
	inst.components.updatelooper:RemoveOnUpdateFn(Vac)
	
	if inst.hitfx ~= nil then
		inst.hitfx:Remove()
	end
	
	if inst.target ~= nil then
		local x, y, z = inst.target.Transform:GetWorldPosition()
	
		local proj = SpawnPrefab("um_magnerang_projectile")
		if x ~= nil then
			proj.Transform:SetPosition(x, 1.5, z)
			proj.components.projectile:Throw(inst.target, inst)
			proj.components.projectile:SetOnHitFn(onhit_return)
			proj.components.projectile:SetOnMissFn(onmiss_return)
			proj.reel = inst
		else
			proj.Transform:SetPosition(inst.Transform:GetWorldPosition())
			proj.components.projectile:Throw(inst, inst)
			proj.components.projectile:SetOnHitFn(onhit_return)
			proj.components.projectile:SetOnMissFn(onmiss_return)
			proj.reel = inst
		end
	else
		SpawnPrefab("um_magnerang_projectile").Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
end

local function InitializeRope(inst)
	if inst.target ~= nil and inst.target:IsValid() then
		local hitfx = SpawnPrefab("um_magneranghitfx")
		hitfx.Transform:SetPosition(inst.target.Transform:GetWorldPosition())
		
		inst.hitfx = hitfx
		
		hitfx.entity:SetParent(inst.target.entity)
		
		if hitfx ~= nil and inst.target.components.combat then
			local follower = hitfx.entity:AddFollower()
			follower:FollowSymbol(inst.target.GUID, inst.target.components.combat.hiteffectsymbol, 0, 0, 0)
		end
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
	
	inst.magnet_damage = 0
	
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
	
	inst.KillRopes = KillRopes
	
    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(Vac)
	
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

    inst.AnimState:SetBank("um_magneranghitfx")
    inst.AnimState:SetBuild("um_magneranghitfx")
    inst.AnimState:PlayAnimation("idle")
	inst.Transform:SetEightFaced()
	
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")
	inst:AddTag("fx")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.SoundEmitter:PlaySound("monkeyisland/autopilot/magnet_lp_start")
	
	inst.persists = false
	
    return inst
end
-------------------------------------------------------------------------------
return Prefab("um_magnerang", fncommon, assets, prefabs),
		Prefab("um_magnerang_projectile", harpoon, assets, prefabs),
		Prefab("um_magnerangreel", reel, assets, prefabs),
		Prefab("um_magneranghitfx", fnhit, assets, prefabs)