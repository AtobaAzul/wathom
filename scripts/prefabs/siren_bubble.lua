local function Pop(inst)

	inst:Remove()
end

local function ShouldPop(inst)
	if FindEntity(inst,2,nil,{"_combat"}) then
		--inst.AnimState:PushAnimation("rumble",false)
		inst.AnimState:PushAnimation("explode",false)
		inst:ListenForEvent("animover",Pop)
	end
end

local function FindTarget(inst)
	local target = FindEntity(inst,50,nil,{"_combat"},{"siren"}) --Preemptive exclusion
	if target then
		inst.target = target
		if inst.targetTask then
			inst.targetTask:Cancel()
			inst.targetTask = nil
		end
	end
end

local function Locomotion(inst)
	if inst.target then
		local x_t,y_t,z_t = inst.target.Transform:GetWorldPosition()
		local x,y,z = inst.Transform:GetWorldPosition()
		if math.abs(x-x_t) > math.abs(z-z_t) then
			if x > x_t then
				inst:ForceFacePoint(x-1,y,z)
			else
				inst:ForceFacePoint(x+1,y,z)
			end
		else
			if z > z_t then
				inst:ForceFacePoint(x,y,z-1)
			else
				inst:ForceFacePoint(x,y,z+1)
			end
		end
		inst.components.locomotor:WalkForward()
	end
end

local function OnUpdate(inst)
	if inst.target then
		Locomotion(inst)
	else
		inst.targetTask = inst:DoPeriodicTask(3,FindTarget)
	end
	ShouldPop(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddLight()    
    inst.Light:SetIntensity(.6)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(1)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(false)
	
    MakeInventoryPhysics(inst)
	
    inst:AddTag("projectile")

    inst.entity:SetPristine()


    if not TheWorld.ismastersim then
        return inst
    end
	
    inst.AnimState:SetBank("spore_moon")
    inst.AnimState:SetBuild("mushroom_spore_moon")
    inst.AnimState:PlayAnimation("cough_out",false)
	inst.AnimState:PlayAnimation("idle_flight_loop",true)

    inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.BAT_WALK_SPEED/4
	
	inst.target = nil
	inst.persists = false
	inst:DoTaskInTime(0,FindTarget)
	inst:DoPeriodicTask(FRAMES,OnUpdate)
	
    return inst
end

return Prefab("siren_bubble", fn)
