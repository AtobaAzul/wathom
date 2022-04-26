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
    end
	
	if inst.x ~= nil then
		local reel = SpawnPrefab("uncompromising_harpoonreel")
		reel.Transform:SetPosition(inst.x, inst.y, inst.z)
		reel.target = target
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

local function spawntornado(staff, target)
	local owner = staff.components.inventoryitem.owner
	
	if owner == nil then
		return
	end
	
	local x, y, z = owner.Transform:GetWorldPosition()
	local boat = TheWorld.Map:GetPlatformAtPoint(x, z)
	
	if target.components ~= nil and target.components.workable and not owner:GetCurrentPlatform() then
		return
	end
	
	local proj = SpawnPrefab("uncompromising_harpoon_projectile")
	proj.Transform:SetPosition(x, y, z)
	proj.components.projectile:Throw(owner, target)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blow_dart")
    inst.AnimState:SetBuild("blow_dart")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("quickcast")
    inst:AddTag("nopunch")

    inst.spelltype = "SCIENCE"

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

local function harpoon()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blow_dart")
    inst.AnimState:SetBuild("blow_dart")
    inst.AnimState:PlayAnimation("idle_pipe")

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
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetLaunchOffset(Vector3(3, 2, 0))
    inst.components.projectile:SetSpeed(60)
    inst.components.projectile:SetOnHitFn(onhit)
    inst:ListenForEvent("onthrown", onthrown)

    inst.persists = false

    return inst
end

local function KillRopes(inst)
	if inst.harpoontask ~= nil then
		inst.harpoontask:Cancel()
	end
		
	inst.harpoontask = nil
		
	for i, ropes in ipairs(inst.ropes) do
		ropes:DoTaskInTime(1/i, function(ropes)
			if ropes.entity:IsVisible() then
				SpawnPrefab("wood_splinter_jump").Transform:SetPosition(ropes.Transform:GetWorldPosition())
			end
			
			ropes:Remove()
			if inst ~= nil and i == 1 then
				inst:Remove()
			end
		end)
	end
end

local function OnCooldown(inst)
    inst._cdtask = nil
end

local function Vac(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	if inst ~= nil and inst:IsValid() and inst.target ~= nil and inst.target:IsValid() then
		if inst:GetDistanceSqToInst(inst.target) ~= nil and inst:GetDistanceSqToInst(inst.target) > inst.distance then
			local px, py, pz = inst.target.Transform:GetWorldPosition()
			
			local platform = inst:GetCurrentPlatform()
			
			if platform ~= nil and platform:IsValid() then
				if inst._cdtask == nil then
					local rowdistmult = (inst:GetDistanceSqToInst(inst.target) / 100)
				
					inst._cdtask = inst:DoTaskInTime(1, OnCooldown)
					
					local row_dir_x, row_dir_z = VecUtil_Normalize(px - x, pz - z)
					
					local boat_physics = platform.components.boatphysics
				
					boat_physics:ApplyRowForce(row_dir_x, row_dir_z, 1 * rowdistmult, 3)
				end
			elseif inst.target.components.locomotor ~= nil then
				local rad = math.rad(inst.target:GetAngleToPoint(x, y, z))
				local velx = math.cos(rad) --* 4.5
				local velz = -math.sin(rad) --* 4.5
				
				local dx, dy, dz = px + (((FRAMES * 5) * velx) * 2), 0, pz + (((FRAMES * 5) * velz) * 2)
					
				local ground = TheWorld.Map:IsPassableAtPoint(dx, dy, dz)
				local boat = TheWorld.Map:GetPlatformAtPoint(dx, dz)
				if dx ~= nil and (ground or boat) then
					inst.target.Transform:SetPosition(dx, py, dz)
				end
			end
			
			local tensionmult = inst.target:HasTag("epic") and 2 or inst.target:HasTag("smallcreature") and .5 or 1
			inst.tension = inst.tension + (1 * tensionmult)
		elseif inst.tension > 1 then
			inst.tension = inst.tension - 0.1
		end
	else
		KillRopes(inst)
		return
	end
		
	if inst ~= nil and inst.tension >= 200 then
		if inst.harpoontask ~= nil then
			inst.harpoontask:Cancel()
		end
		
		inst.harpoontask = nil
		KillRopes(inst)
		return
	end
	
	if inst ~= nil and inst:IsValid() and inst.target ~= nil and inst.target:IsValid() and inst.ropes ~= nil and inst:GetDistanceSqToInst(inst.target) ~= nil then
		local scale = (inst:GetDistanceSqToInst(inst.target) / 5)
		
		for i2, ropes in ipairs(inst.ropes) do
			local p2x, p2y, p2z = inst.target.Transform:GetWorldPosition()
			local rad2 = math.rad(inst:GetAngleToPoint(p2x, p2y, p2z))
			local velx2 = math.cos(rad2) --* 4.5
			local velz2 = -math.sin(rad2) --* 4.5
			
			local dx, dy, dz = x + ((i2 * velx2) / 2), (0.06 * i2), z + ((i2 * velz2) / 2)
			if p2y < 5 then
				if i2 <= (scale + 2) then
					--[[local dest = inst.target:GetPosition()
					local direction = (dest - ropes:GetPosition()):GetNormalized()
					local angle = math.acos(direction:Dot(Vector3(1, 0, 0))) / DEGREES
					ropes.Transform:SetRotation(angle)
					ropes:FacePoint(dest)]]
					
					--ropes:FacePoint(inst.target.Transform:GetWorldPosition())
					ropes.Transform:SetRotation(inst:GetAngleToPoint(p2x, p2y, p2z))
					ropes:Show()
					ropes.Transform:SetPosition(dx, (0.06 * i2) + (p2y * (i2 / 25)), dz)
				else
					ropes:Hide()
				end
			else
				KillRopes(inst)
				return
			end
		end
	elseif inst.ropes ~= nil then
		
		KillRopes(inst)
	end
end

local function InitializeRope(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	
	inst.ropes = {}
	
	for i = 1, 25 do
		local ropes = SpawnPrefab("uncompromising_harpoonrope")
		ropes.Transform:SetPosition(x, y, z)
		table.insert(inst.ropes, ropes)
	end
end

local function DoPuff(inst, channeler)
	if inst.distance > 15 then
		inst.distance = inst.distance - 15
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
	inst.harpoontask = inst:DoPeriodicTask(FRAMES, Vac)
	inst:DoTaskInTime(30, KillRopes)
	
	inst.persists = false
	
    return inst
end

local function rope()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("harpoon_rope")
    inst.AnimState:SetBuild("harpoon_rope")
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
return Prefab("uncompromising_harpoon", fn, assets, prefabs),
		Prefab("uncompromising_harpoon_projectile", harpoon, assets, prefabs),
		Prefab("uncompromising_harpoonreel", reel, assets, prefabs),
		Prefab("uncompromising_harpoonrope", rope, assets, prefabs)
