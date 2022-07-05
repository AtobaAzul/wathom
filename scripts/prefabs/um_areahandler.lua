local function SpawnOuterRing(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	local radius = math.random(35,42)
	local angle
	for angle = 1,360,60 do
		local radius1 = radius + math.random(-4,4)
		local x1 = x + radius1*math.cos(angle*3.14/180)
		local z1 = z + radius1*math.sin(angle*3.14/180)
		local wreck = SpawnPrefab("specter_shipwreck")
		wreck.Transform:SetPosition(x1,y,z1)
	end
end

local function RegenAreaSpecter(inst)
	SpawnOuterRing(inst)
end
local function RegenAreaBrine(inst)
	SpawnOuterRing(inst)
end
local function RegenAreaRusted(inst)
	SpawnOuterRing(inst)
end

local function SpawnSiren(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	if inst.sirenpoint ~= nil then
		local speaker = SpawnPrefab(inst.sirenpoint)
		speaker.Transform:SetPosition(x,y,z)
	end
end

local function SpawnTest(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	local test = SpawnPrefab("saltstack")
	test.Transform:SetPosition(x,y,z)
end

local function Clear(inst)
	TheNet:Announce("clear")
end

--[[
local function specterfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:SetPristine()
		
    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.sirenpoint = "siren_throne"
	
	inst:DoTaskInTime(0, SpawnSiren)
	inst:ListenForEvent("generate_inactive", TheNet:Announce("event pushed!!"))
	--inst:DoTaskInTime(0,RegenArea)
    return inst
end

local function rustedfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:SetPristine()
		
    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.sirenpoint = "ocean_speaker"
	
	--since more than one hazard spawns and we're not using tasks, they could've ended up seperate.
	inst:DoTaskInTime(0, SpawnSiren)
	--inst:DoTaskInTime(0,RegenArea)
    return inst
end]]

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.sirenpoint = nil

	inst:ListenForEvent("generate_inactive", SpawnTest)
	inst:ListenForEvent("generate_main", SpawnSiren)
	inst:ListenForEvent("clear", Clear)
	table.insert(TheWorld.components.um_areahandler.handlers, inst)

	--inst:DoTaskInTime(0,RegenArea)
    return inst
end

return Prefab("um_areahandler", fn)
