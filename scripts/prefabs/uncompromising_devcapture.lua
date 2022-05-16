require "prefabutil"

local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("open")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", false)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
end

local function onhammered(inst, worker)
    inst:Remove()
end

local function onhit(inst, worker)
	inst:Remove()
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
end

local function OnStopChanneling(inst)
	if inst.channeler ~= nil then
		--inst.channeler.sg:GoToState("idle")
	end
	inst.channeler = nil
end

local function Capture(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	local itemsinside = inst.components.container:GetAllItems()
	local range = 0
	for i,v in ipairs(itemsinside) do
		if v.prefab == "log" then
			range = range + 0.5*v.components.stackable:StackSize()
		end
		v:AddTag("DEVBEHOLDER")
	end
	--TheNet:Announce(range)
	local ents = TheSim:FindEntities(x,y,z,range,nil,{"DEVBEHOLDER","player","bird"})
	

	local totaltable = "local returnedTable = { "
	--print("	{x = 2, z = 2, prefab = \"evergreen\"},")
	for i,v in ipairs(ents) do
		local px,py,pz = v.Transform:GetWorldPosition()
		local vx = px-x
		local vy = py-y
		local vz = pz-z
		totaltable = totaltable.."	{x = "..vx..", z = "..vz..", prefab = \""..v.prefab.."\""
		if v.components.pickable and v.components.pickable:IsBarren() then
			totaltable = totaltable..", barren = true"
		end
		if v.components.witherable and v.components.witherable:IsWithered() then
			totaltable = totaltable..", withered = true"
		end
		totaltable = totaltable.."},"
	end
	totaltable = totaltable.."}"
	print(totaltable)
	TheNet:Announce("Prefabs Captured, Check your Log")
	inst:Remove()
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:AddTag("structure")
	inst:AddTag("chest")
	inst:AddTag("DEVBEHOLDER")
		
    inst.AnimState:SetBank("chest")
    inst.AnimState:SetBuild("treasure_chest")
    inst.AnimState:PlayAnimation("closed")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("uncompromising_devcapture")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("channelable")
    inst.components.channelable:SetChannelingFn(Capture, OnStopChanneling)
    inst.components.channelable.use_channel_longaction_noloop = true
    --inst.components.channelable.skip_state_stopchanneling = true
    inst.components.channelable.skip_state_channeling = true
	
    return inst
end

return Prefab("uncompromising_devcapture", fn) --Version 1.0


