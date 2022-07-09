local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------
local UpvalueHacker = require("tools/upvaluehacker")

local function DisableThatStuff(inst)
	TheWorld:PushEvent("beequeenkilled")
		
	if TheWorld.net ~= nil then
		TheWorld.net:AddTag("queenbeekilled")
	end
	
	SendModRPCToShard(GetShardModRPC("UncompromisingSurvival", "Hayfever_Stop"), nil)
end
env.AddPrefabPostInit("beeguard", function(inst)
	inst:AddTag("ignorewalkableplatforms")
end)

local function StompHandler(inst,data)
	--TheNet:Announce(inst.stomprage)
	if inst.sg:HasStateTag("tired") then
		inst.AnimState:PlayAnimation("tired_hit")
		inst.AnimState:PushAnimation("tired_loop",true)
	end
	if inst.mode == "aggressive" then
		inst.stomprage = inst.stomprage + 0.25
	else
		inst.stomprage = inst.stomprage + 2
	end
	if data.attacker and data.attacker.components.combat and inst.stompready then
		if inst.components.combat.target ~= nil then
			if data.attacker ~= inst.components.combat.target then
				inst.stomprage = inst.stomprage + 1
			end
		end
		local x,y,z = data.attacker.Transform:GetWorldPosition()
		if TheWorld.Map:GetPlatformAtPoint(x, z) ~= nil then
			inst.stomprage = inst.stomprage + 10
		end
		if inst.stomprage > 20 and not inst.sg:HasStateTag("ability") then
			inst:ForceFacePoint(x,y,z)
			inst.stomprage = 0
			inst.stompready = false
			inst:DoTaskInTime(math.random(8,10),function(inst) inst.stompready = true end)
			inst.sg:GoToState("stomp")
		end
	end
end

local function StompRageCalmDown(inst)
	if inst.stomprage < 3 then
		inst.stomprage = 0
	else
		inst.stomprage = inst.stomprage - 3
	end
end

local function ReleaseArmyFromState(inst)
	local soldiers = inst.components.commander:GetAllSoldiers()
	if #soldiers > 0 then
		for i, soldier in ipairs(soldiers) do	
			if soldier.components.health and not soldier.components.health:IsDead() then
				soldier.sg:GoToState("idle")
			end
		end
	end
	if inst.chargeTask then
		inst.chargeTask:Cancel()
		inst.chargeTask = nil
	end
end

local function TellSoldiersToCharge(inst)
	--TheNet:Announce("Telling Soldiers to Charge")
	local soldiers = inst.components.commander:GetAllSoldiers()
	for i, soldier in ipairs(soldiers) do	
		if soldier.components.health and not soldier.components.health:IsDead() then
			soldier.sg:GoToState("charge")
		end
	end
end

local function CheckForReadyCharge(inst)
	if inst.components.combat and inst.components.combat.target then
		local soldiers = inst.components.commander:GetAllSoldiers()
		local canCharge = true
		if #soldiers > 0 then
			for i, soldier in ipairs(soldiers) do	
				if soldier.components.health and not soldier.components.health:IsDead() then
					if soldier.holding == false then
						canCharge = false
					end
				end
			end
		end	
		
		if canCharge then
			inst.sg:GoToState("command_charge_loop")
			inst.chargeTask:Cancel()
			inst.chargeTask = nil
		end
	else
		ReleaseArmyFromState(inst)
	end
end

local function CrossChargeRepeat(inst)
	--TheNet:Announce("Telling Soldiers to move to CrossChargeRepeat")
	if inst.components.health and not inst.components.health:IsDead() and inst.components.combat and inst.components.combat.target then
		local x1,y1,z1 = inst.components.combat.target.Transform:GetWorldPosition()
		local x2,y2,z2 = inst.Transform:GetWorldPosition()
		local x = x1
		local z = z1
		local soldiers = inst.components.commander:GetAllSoldiers()
		local direction = "x"
		local x_diff = 1
		local z_diff = 1
		local extra = math.random(-3,3)
		if #soldiers > 0 and inst.components.combat and inst.components.combat.target then
			for i, soldier in ipairs(soldiers) do
				local rand 
				local pt = inst:GetPosition() --One Point
				local pt2 = inst:GetPosition() --The Other
				pt.x = x
				pt.z = z
				
				if soldier.direction == "x" then
					rand = 5*(#soldiers/4-x_diff)+extra
					x_diff = x_diff + 1
					if inst.direction2 == "back" then
						pt.x = x + 13
						pt2.x = x - 13
					else
						pt.x = x - 13
						pt2.x = x + 13										
					end
					pt.z = z+rand
					pt2.z = z+rand
					direction = "z"
					soldier.direction = "x"
				else
					rand = 5*(#soldiers/4-z_diff)
					z_diff = z_diff + 1
					if inst.direction2 == "back" then
						pt.z = z + 13
						pt2.z = z - 13
					else
						pt.z = z - 13
						pt2.z = z + 13					
					end
					pt.x = x+rand
					pt2.x = x+rand	
					direction = "x"
					soldier.direction = "z"
				end
				
				soldier.rallyPoint = pt
				soldier.chargePoint = pt2

 
				soldier.sg:GoToState("rally_at_point")
			end  
		end
	end
end

local function CrossCharge(inst)
	if inst.components.health and not inst.components.health:IsDead() and inst.components.combat and inst.components.combat.target then
		inst.sg:GoToState("command_charge_pre")
		local x1,y1,z1 = inst.components.combat.target.Transform:GetWorldPosition()
		local x2,y2,z2 = inst.Transform:GetWorldPosition()
		local x = x1
		local z = z1
		local soldiers = inst.components.commander:GetAllSoldiers()
		local direction = "x"
		local x_diff = 1
		local z_diff = 1
		
		if #soldiers > 0 and inst.components.combat and inst.components.combat.target then
			for i, soldier in ipairs(soldiers) do
				local rand 
				local pt = inst:GetPosition()
				local pt2 = inst:GetPosition()
				pt.x = x
				pt.z = z

				if direction == "x" then
					rand = 5*(#soldiers/4-x_diff)
					x_diff = x_diff + 1
					pt.x = x - 13
					pt2.x = x + 13
					pt.z = z+rand
					pt2.z = z+rand
					direction = "z"
					soldier.direction = "x"
				else
					rand = 5*(#soldiers/4-z_diff)
					z_diff = z_diff + 1
					pt.z = z - 13
					pt2.z = z + 13
					pt.x = x+rand
					pt2.x = x+rand	
					direction = "x"
					soldier.direction = "z"
				end

				soldier.rallyPoint = pt
				soldier.chargePoint = pt2

				if soldier.components.health and not soldier.components.health:IsDead() then
					soldier.sg:GoToState("rally_at_point")
				end
			end  
		end
	end
end

local function prepareForCross(inst) --VVe need there to be a certain number of guards before vve can properly do the cross attack
	if inst.components.health and not inst.components.health:IsDead() then
		local soldiers = inst.components.commander:GetAllSoldiers()
		if #soldiers < 7 then
			inst.sg:GoToState("spawnguards")
		else
			inst.prepareForCross:Cancel()
			inst.prepareForCross = nil
			CrossCharge(inst)
		end
	end
end

local function UM_BQ_Checks(inst,data)
	if data.name == "mortar_atk" and inst.components.combat and inst.components.combat.target and inst.components.health and not inst.components.health:IsDead() and inst.components.health:GetPercent() > 0.5 and inst.mode == "aggressive" then
		inst.sg:GoToState("command_mortar")
	elseif data.name == "mortar_atk" then
		inst.components.timer:StartTimer("mortar_atk", 20)
	end
	if data.name == "cross_atk" and inst.components.combat and inst.components.combat.target and inst.components.health and not inst.components.health:IsDead() and inst.components.health:GetPercent() < 0.5 and inst.mode == "aggressive" then
		inst.prepareForCross = inst:DoPeriodicTask(4,prepareForCross)
	elseif data.name =="cross_atk" then
		inst.components.timer:StartTimer("cross_atk", 20)
	end
	if data.name == "spin_bees" and inst.components.combat and inst.components.combat.target and inst.components.health and not inst.components.health:IsDead() and inst.components.health:GetPercent()  and inst.mode == "defensive" and inst.components.health:GetPercent() > 0.5 then
		inst.sg:GoToState("defensive_spin")
	elseif data.name =="spin_bees" then
		inst.components.timer:StartTimer("spin_bees", 20)		
	end
end

local function SpawnbeeHolder(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	local LIMIT = 4
	inst.beeHolder = {}
	for i = 1,8 do
		inst.beeHolder[i] = SpawnPrefab("beequeen_beering")
		inst.beeHolder[i].WINDSTAFF_CASTER = inst
		inst.beeHolder[i].components.linearcircler:SetCircleTarget(inst)
		inst.beeHolder[i].components.linearcircler:Start()
		inst.beeHolder[i].components.linearcircler.randAng = i*0.125/1.5
		inst.beeHolder[i].components.linearcircler.clockwise = false
		inst.beeHolder[i].components.linearcircler.distance_limit = LIMIT
		inst.beeHolder[i].components.linearcircler.setspeed = 0
	end
end

local function ReleasebeeHolders(inst)
	local soldiers = inst.components.commander:GetAllSoldiers()
	if #soldiers > 0 then
		for i, soldier in ipairs(soldiers) do
			if soldier.components.health and not soldier.components.health:IsDead() then
				soldier:BeeFree(soldier)
			end
		end
	end
	for i,beeHolder in ipairs(inst.beeHolder) do
		if beeHolder.bee then
			beeHolder.bee = nil
		end
	end
end

local function AllocatebeeHolders(inst)
	local soldiers = inst.components.commander:GetAllSoldiers()
	if #soldiers > 0 then
		for i, soldier in ipairs(soldiers) do
			--TheNet:Announce("i = "..i)
			--print("i = "..i)
			if soldier.components.health and not soldier.components.health:IsDead() and not soldier.notGuarding then
				if soldier.beeHolder == nil then
					for j,v in ipairs(inst.beeHolder) do
						--TheNet:Announce("j = "..j)
						--print("j = "..j)
						if v.bee == nil and soldier.beeHolder == nil then
							--print("ALLOCATED")
							v.bee = soldier
							soldier.beeHolder = v
							soldier:BeeHold(soldier)
						end
					end
				end
			end
		end
	end
end

local function ModeChange(inst)
	if inst.components.health and not inst.components.health:IsDead() then
		local soldier_is_stuck = false -- Are my soldiers pinned?????
		local soldiers = inst.components.commander:GetAllSoldiers()
		if #soldiers > 0 then
			for i, soldier in ipairs(soldiers) do
				if soldier.components.health and not soldier.components.health:IsDead() and soldier.sg:HasStateTag("stuck") then
					soldier_is_stuck = true
				end
			end
		end
		if inst.sg:HasStateTag("ability") or inst.sg:HasStateTag("sleep") or inst.sg:HasStateTag("frozen") or inst.sg:HasStateTag("attack") or soldier_is_stuck then
			inst:DoTaskInTime(1,ModeChange) --If I'm super busy then mode change after I'm done.
		else
			if inst.mode == "aggressive" then
				inst.mode = "defensive"
				inst.sg:GoToState("spawnguards")
			elseif	inst.mode == "defensive" then
				ReleasebeeHolders(inst)
				inst.mode = "aggressive"
				if inst.components.health:GetPercent() > 0.5 then
					if inst.components.timer:TimerExists("mortar_atk") then
						inst.components.timer:StopTimer("mortar_atk")
					end
					inst.sg:GoToState("command_mortar")
				else
					if inst.components.timer:TimerExists("cross_atk") then
						inst.components.timer:StopTimer("cross_atk")
					end
					inst.prepareForCross = inst:DoPeriodicTask(4,prepareForCross)
				end
			end
		end
	end
end

env.AddPrefabPostInit("beequeen", function(inst)
	if not TheWorld.ismastersim then
		return
	end
	
	if TUNING.DSTU.VETCURSE ~= "off" then
		inst:AddComponent("vetcurselootdropper")
		inst.components.vetcurselootdropper.loot = "um_beegun"
	end
	
    inst.Physics:CollidesWith(COLLISION.FLYERS)
	
	if inst.components.health ~= nil then
		inst.components.health:SetMaxHealth(TUNING.BEEQUEEN_HEALTH)
	end
	
	inst:AddComponent("groundpounder") --Groundpounder is visual only
	inst.components.groundpounder.destroyer = true
	inst.components.groundpounder.damageRings = 0
    inst.components.groundpounder.destructionRings = 1
    inst.components.groundpounder.platformPushingRings = 2
    inst.components.groundpounder.numRings = 1
	inst:ListenForEvent("death", DisableThatStuff)
	inst:ListenForEvent("death", ReleasebeeHolders)
	
	inst.stomprage = 0
	inst.stompready = true
	inst:DoPeriodicTask(3, StompRageCalmDown)
	inst:ListenForEvent("attacked", StompHandler)
	
	inst.components.timer:StartTimer("mortar_atk", 15)
	
	inst.components.timer:StartTimer("cross_atk", 15)
	
	inst.components.timer:StartTimer("spin_bees", 15)
	
	inst:ListenForEvent("timerdone", UM_BQ_Checks)
	
	inst.chargeTask = nil
	inst.chargeCount = 0
	inst.TellSoldiersToCharge = TellSoldiersToCharge
	inst.CheckForReadyCharge = CheckForReadyCharge
	inst.CrossChargeRepeat = CrossChargeRepeat
	inst.ReleaseArmyFromState = ReleaseArmyFromState
	inst.AllocatebeeHolders = AllocatebeeHolders
	
	
	-- No more honey when attacking
	local OnMissOther = UpvalueHacker.GetUpvalue(Prefabs.beequeen.fn, "OnMissOther")
	local OnAttackOther = UpvalueHacker.GetUpvalue(Prefabs.beequeen.fn, "OnAttackOther")
    inst:RemoveEventCallback("onattackother", OnAttackOther)
    inst:RemoveEventCallback("onmissother", OnMissOther)
	
	inst:DoTaskInTime(0,SpawnbeeHolder)
	--inst:DoTaskInTime(10,AllocatebeeHolders)
	inst.mode = "aggressive"
	inst:DoPeriodicTask(math.random(40,60),ModeChange)
end)

local function OnTagTimer(inst, data)
	if data.name == "hivegrowth" then
		TheWorld:PushEvent("beequeenrespawned")
		if TheWorld.net ~= nil then
			TheWorld.net:RemoveTag("queenbeekilled")
		end
		
		SendModRPCToShard(GetShardModRPC("UncompromisingSurvival", "Hayfever_Start"), nil)
	end
end

env.AddPrefabPostInit("beequeenhive", function(inst)
	if not TheWorld.ismastersim then
		return
	end

    inst:ListenForEvent("timerdone", OnTagTimer)
end)