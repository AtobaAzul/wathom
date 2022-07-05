local assets =
{
    Asset("ANIM", "anim/lantern.zip"),
    Asset("ANIM", "anim/swap_lantern.zip"),
    Asset("SOUND", "sound/wilson.fsb"),
    Asset("INV_IMAGE", "lantern_lit"),
}

local prefabs =
{
    "lanternlight",
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    --inst.AnimState:PlayAnimation("hit")
    --inst.AnimState:PushAnimation("idle", false)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
end

local function UpdateLight(inst)
	local velocity = 0
	local sandstorm = 0

	local x, y, z = inst.Transform:GetWorldPosition()

	local boat = TheWorld.Map:GetPlatformAtPoint(x, z)
	
	if boat ~= nil and boat:HasTag("boat") and boat.components ~= nil and boat.components.boatphysics ~= nil then
		velocity = boat.components.boatphysics:GetVelocity() * 2.5
	end
	
	if TheWorld.components.sandstorms then
		sandstorm = TheWorld.Map:FindVisualNodeAtPoint(x, y, z, "sandstorm") and 5 or 0
	end
	
	local snowstorm = ((TheWorld.net ~= nil and TheWorld.net:HasTag("snowstormstartnet")) or TheWorld:HasTag("snowstormstart")) and 5 or 0
	
	local finalnums = velocity + sandstorm + snowstorm
	
	if inst.lightlevel > finalnums then
		inst.lightlevel = inst.lightlevel - 0.05
	elseif inst.lightlevel < finalnums then
		inst.lightlevel = inst.lightlevel + 0.05
	end
	
	if inst.lightlevel < 0 then
		inst.lightlevel = 0
	end
	
	local lerpval = Lerp(.4, .7, inst.lightlevel / 7)
	
	if lerpval > .7 then
		lerpval = .7
	end
	
	if inst.lightlevel > 0 then
		inst.Light:SetIntensity(lerpval)
		inst.Light:SetRadius(inst.lightlevel * 1.5)
		inst.Light:SetFalloff(.9)
		
		if not inst.AnimState:IsCurrentAnimation("spin") then
			inst.AnimState:PlayAnimation("spin", true)
		end
	else
		--inst.Light:Enable(false)
		inst.Light:SetIntensity(lerpval)
		inst.Light:SetRadius(inst.lightlevel * 1.5)
		inst.Light:SetFalloff(.9)
	
		if not inst.AnimState:IsCurrentAnimation("idle") then
			inst.AnimState:PlayAnimation("idle")
		end
	end
	
	
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("structure")
	
    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)
	inst.Light:Enable(true)
	
    inst.AnimState:SetBank("um_windturbine")
    inst.AnimState:SetBuild("um_windturbine")
    inst.AnimState:PlayAnimation("idle")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.lightlevel = 0
	
    inst:AddComponent("lootdropper")
	
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
	
    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(UpdateLight)

    MakeSnowCovered(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    MakeHauntableWork(inst)
	
    return inst
end

return Prefab("um_windturbine", fn, assets, prefabs)