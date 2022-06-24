local assets =
{
    Asset("ANIM", "anim/boat_net.zip"),
    Asset("ANIM", "anim/swap_boat_net.zip"),
}

local prefabs =
{
    "fishingnetvisualizer"
}

local PROJECTILE_COLLISION_MASK = COLLISION.GROUND

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_boat_net", "swap_boat_net")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function ResetPhysics(inst)
	inst.Physics:SetFriction(0.1)
	inst.Physics:SetRestitution(0.5)
	inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(PROJECTILE_COLLISION_MASK)
end

local function OnHit(inst, attacker, target)
    local x, y, z = inst.Transform:GetWorldPosition()

    if not TheWorld.Map:IsOceanAtPoint(x, y, z) then
		inst.AnimState:PlayAnimation("xxx")
		inst.AnimState:PushAnimation("idle")
		inst.components.finiteuses:Use(1)
		
		inst:RemoveTag("NOCLICK")
		inst.persists = true
		inst.returntrip = false
		
		inst.SoundEmitter:KillSound("spin_loop")
		
		if inst.components.finiteuses:GetUses() > 0 then
			ResetPhysics(inst)
		end
		
		for i, v in pairs(inst.captured_entities) do
			v:ReturnToScene()
			v.Transform:SetPosition(x, y, z)
			
			for n, b in ipairs(inst.captured_entities) do
				if b == v then
					table.remove(inst.captured_entities, n)
				end
			end
		end
		
    else
		inst.SoundEmitter:KillSound("spin_loop")
		
		inst.AnimState:PlayAnimation("throw_pst")
		if not inst.returntrip then
		
		local entities = TheSim:FindEntities(x, y, z, 3)
			for k,v in pairs(entities) do
				if v ~= inst and v.components.inventoryitem ~= nil then
					
					table.insert(inst.captured_entities, v)
					
					if v:IsValid() then
						v:RemoveFromScene()
					end
				end
			end
		end
		
		
		--inst.animtask = inst:ListenForEvent("animover", function()
		inst:DoTaskInTime(2, function()
			inst.returntrip = true
			
			local pos = attacker:GetPosition()
			inst.components.complexprojectile:Launch(pos, attacker)
			inst.components.complexprojectile.targetoffset = {x=0,y=1.5,z=0}
			
			--[[if inst.animtask ~= nil then
				inst.animtask:Cancel()
			end
			
			inst.animtask = nil]]
		end)
    end

    --inst:Remove()
end

local function onthrown(inst)
    inst:AddTag("NOCLICK")
    inst.persists = false
	
	
	if inst.returntrip then
		inst.AnimState:PlayAnimation("pull_pre")
		inst.AnimState:PushAnimation("pull_loop", true)
	else
		inst.AnimState:PlayAnimation("throw_pre")
		inst.AnimState:PushAnimation("throw_loop", true)
	end
	
    inst.SoundEmitter:PlaySound("wolfgang1/dumbbell/throw_twirl", "spin_loop")
	
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:SetCollisionMask(PROJECTILE_COLLISION_MASK)
end

local function OnAddProjectile(inst)
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(onthrown)
    inst.components.complexprojectile:SetOnHit(OnHit)
end

local function ReticuleTargetFn()
    local pos = Vector3()
    for r = 6.5, 3.5, -.25 do
        pos.x, pos.y, pos.z = ThePlayer.entity:LocalToWorldSpace(r, 0, 0)
        if TheWorld.Map:IsOceanAtPoint(pos.x, pos.y, pos.z, false) then
            return pos
        end
    end
    return pos
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ease = true

    inst:AddTag("allow_action_on_impassable")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("boat_net")
    inst.AnimState:SetBuild("boat_net")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("boat_net.png")

	--MakeInventoryFloatable(inst, "small", 0.1, 0.8)
    MakeInventoryFloatable(inst, "large", nil, {0.68, 0.5, 0.68})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.captured_entities = {}
	inst.returntrip = false

    inst:AddComponent("locomotor")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.FISHING_NET_USES)
    inst.components.finiteuses:SetUses(TUNING.FISHING_NET_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    --inst.components.finiteuses:SetConsumption(ACTIONS.CAST_NET, 1)

    inst:AddComponent("inventoryitem")
	
	inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(onthrown)
    inst.components.complexprojectile:SetOnHit(OnHit)
		
    --inst:AddComponent("oceanthrowable")
	--inst.components.oceanthrowable:SetOnAddProjectileFn(OnAddProjectile)
	
    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    --inst.components.equippable:SetOnPocket(onpocket)
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("burnable")
    inst.components.burnable.canlight = false
    inst.components.burnable.fxprefab = nil

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("uncompromising_fishingnet", fn, assets, prefabs)--[[,
		Prefab("uncompromising_fishingnet_return", fn, assets, prefabs)]]