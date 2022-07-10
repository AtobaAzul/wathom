local assets = {
	Asset("ANIM", "anim/siren_bubble.zip"),
}

local MAX_GOO_VARIATIONS = 7
local MAX_RECENT_GOO = 4
local GOO_PERIOD = .2

local GOO_LEVELS =
{
    {
        min_scale = .5,
        max_scale = .8,
        threshold = 8,
        duration = 1.2,
    },
    {
        min_scale = .5,
        max_scale = 1.1,
        threshold = 2,
        duration = 2,
    },
    {
        min_scale = 1,
        max_scale = 1.3,
        threshold = 1,
        duration = 4,
    },
}

local function PickGoo(inst)
    local rand = table.remove(inst.availablegoo, math.random(#inst.availablegoo))
    table.insert(inst.usedgoo, rand)
    if #inst.usedgoo > MAX_RECENT_GOO then
        table.insert(inst.availablegoo, table.remove(inst.usedgoo, 1))
    end
    return rand
end

local function DoGooTrail(inst)
    local level = GOO_LEVELS[3]

    inst.goocount = inst.goocount + 1

    if inst.goothreshold > level.threshold then
        inst.goothreshold = level.threshold
    end

    if inst.goocount >= inst.goothreshold then
        local hx, hy, hz = inst.Transform:GetWorldPosition()
        inst.goocount = 0
        if inst.goothreshold < level.threshold then
            inst.goothreshold = math.ceil((inst.goothreshold + level.threshold) * .5)
        end

        local fx = nil
        if TheWorld.Map:IsPassableAtPoint(hx, hy, hz) then
            fx = SpawnPrefab("honey_trail")
            fx:SetVariation(PickGoo(inst), GetRandomMinMax(level.min_scale, level.max_scale), level.duration + math.random() * .5)
			fx.AnimState:SetMultColour(0.05,0.2,0.4,1)
        else
            fx = SpawnPrefab("splash_sink")
        end
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
		fx.Transform:SetScale(0.5,0.5,0.5)
    end
end

local function StartGoo(inst)
    if inst.gootask == nil then
        inst.goothreshold = GOO_LEVELS[1].threshold
        inst.goocount = math.ceil(inst.goothreshold * .5)
        inst.gootask = inst:DoPeriodicTask(GOO_PERIOD, DoGooTrail, 0)
    end
end

local function StopGoo(inst)
    if inst.gootask ~= nil then
        inst.gootask:Cancel()
        inst.gootask = nil
    end
end

local function Pop(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z,2,{"_health"},{"siren"})
	for i,v in ipairs(ents) do
		if not v.components.health:IsDead() and v.components.combat then
			v.components.combat:GetAttacked(inst,20)
		end
	end
end

local function ShouldPop(inst)
	if FindEntity(inst,2,nil,{"_combat"}) then
		inst.popping = true
		inst.AnimState:PushAnimation("disappear",false)
		inst.AnimState:PushAnimation("blast",false)
		inst:DoTaskInTime(0.5,Pop)
		inst:ListenForEvent("animqueueover",function(inst) inst:Remove() end)
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

local function ArtificialLocomote(inst,destination,speed)
	if destination and speed then
		speed = speed*FRAMES
		local hypoten = math.sqrt(inst:GetDistanceSqToPoint(destination))
		local x,y,z = inst.Transform:GetWorldPosition()
		local x_final,y_final,z_final
		
		x_final = ((destination.x-x)/hypoten)*speed+x
		z_final = ((destination.z-z)/hypoten)*speed+z
		
		inst.Transform:SetPosition(x_final,y,z_final)
	
	end
end

local function PointCalc_x(inst)
	local x = inst:GetPosition().x
	local x_target = inst.target:GetPosition().x
	if math.abs(x_target - x) < 0.5 then
		inst.direction = "z"
	else
		inst.targetPoint = inst:GetPosition()
		if (x_target - x) > 0 then
			inst.targetPoint.x = inst.targetPoint.x + 4
		else
			inst.targetPoint.x = inst.targetPoint.x - 4
		end
	end
end

local function PointCalc_z(inst)
	local z = inst:GetPosition().z
	local z_target = inst.target:GetPosition().z
	if math.abs(z_target - z) < 0.5 then
		inst.direction = "x"
	else
		inst.targetPoint = inst:GetPosition()
		if z_target - z > 0 then
			inst.targetPoint.z = inst.targetPoint.z + 4
		else
			inst.targetPoint.z = inst.targetPoint.z - 4
		end
	end
end


local function PickDirection(inst)
	if math.abs(inst:GetPosition().x - inst.target:GetPosition().x) > math.abs(inst:GetPosition().z - inst.target:GetPosition().z) then
		inst.direction = "z"
	else
		inst.direction = "x"
	end
end

local function Locomotion(inst)
	if inst.direction then
		if inst.direction == "x" then
			PointCalc_x(inst)
		else
			PointCalc_z(inst)
		end
		if inst.targetPoint then
			ArtificialLocomote(inst,inst.targetPoint,2)
		end
	else
		PickDirection(inst)
	end
end

local function OnUpdate(inst)
	if inst.target and inst.target.components.health and not inst.target.components.health:IsDead() then
		Locomotion(inst)
	elseif not inst.targetTask then
		inst.targetTask = inst:DoPeriodicTask(1,FindTarget)
	end
	if not inst.popping then
		ShouldPop(inst)
	end
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
	
	MakeFlyingCharacterPhysics(inst, 1, .5)
	
    inst:AddTag("projectile")

    inst.entity:SetPristine()


    if not TheWorld.ismastersim then
        return inst
    end
	
    inst.AnimState:SetBank("siren_bubble")
    inst.AnimState:SetBuild("siren_bubble")
	inst.AnimState:PlayAnimation("idle_loop",true)
	
	inst.target = nil
	inst.persists = false
	inst:DoTaskInTime(0,FindTarget)
	inst:DoPeriodicTask(FRAMES,OnUpdate)
	
    inst.gootask = nil
    inst.goocount = 0
    inst.goothreshold = 0
    inst.usedgoo = {}	
	inst.availablegoo = {}
    for i = 1, MAX_GOO_VARIATIONS do
        table.insert(inst.availablegoo, i)
    end
	StartGoo(inst)
	
    return inst
end

return Prefab("siren_bubble", fn, assets)
