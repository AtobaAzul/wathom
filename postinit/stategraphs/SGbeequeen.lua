local env = env
GLOBAL.setfenv(1, GLOBAL)

local function DoScreech(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, 1, .015, .3, inst, 30)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/taunt")
end

local function DoScreechAlert(inst)
    inst.components.epicscare:Scare(5)
    inst.components.commander:AlertAllSoldiers()
end

local function FaceTarget(inst)
    local target = inst.components.combat.target
    if inst.sg.mem.focustargets ~= nil then
        local mindistsq = math.huge
        for i = #inst.sg.mem.focustargets, 1, -1 do
            local v = inst.sg.mem.focustargets[i]
            if v:IsValid() and v.components.health ~= nil and not v.components.health:IsDead() and not v:HasTag("playerghost") then
                local distsq = inst:GetDistanceSqToInst(v)
                if distsq < mindistsq then
                    mindistsq = distsq
                    target = v
                end
            else
                table.remove(inst.sg.mem.focustargets, i)
                if #inst.sg.mem.focustargets <= 0 then
                    inst.sg.mem.focustargets = nil
                    break
                end
            end
        end
    end
    if target ~= nil and target:IsValid() then
        inst:ForceFacePoint(target.Transform:GetWorldPosition())
    end
end

local function AdjustGuardSpeeds(inst,speed)
	local soldiers = inst.components.commander:GetAllSoldiers()
	if #soldiers > 0 then
		for i, soldier in ipairs(soldiers) do	
			if soldier.components.health and not soldier.components.health:IsDead() then
				soldier.chargeSpeed = speed
			end
		end
	end		
end

local function PutArmyToSleep(inst)
	local soldiers = inst.components.commander:GetAllSoldiers()
	if #soldiers > 0 then
		for i, soldier in ipairs(soldiers) do	
			if soldier.components.health and not soldier.components.health:IsDead() and soldier.components.sleeper then
				soldier.components.sleeper:GoToSleep(12)
			end
		end
	end	
end

env.AddStategraphPostInit("SGbeequeen", function(inst) --For some reason it's called "SGbeequeen" instead of just... beequeen, funky
local function TrySpawnBigLeak(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
    local boat = inst:GetCurrentPlatform()
    if boat then
        local leak = SpawnPrefab("boat_leak")
        leak.Transform:SetPosition(x, y, z)
        leak.components.boatleak.isdynamic = true
        leak.components.boatleak:SetBoat(boat)
        leak.components.boatleak:SetState(4, true)

        table.insert(boat.components.hullhealth.leak_indicators_dynamic, leak)
    end

end

local events=
	{        
	}

local states = {
    State{
        name = "stomp",
        tags = { "busy", "nosleep", "nofreeze", "noattack" },

        onenter = function(inst)
			--inst.brain:Stop()
            --StopFlapping(inst)
            inst.Transform:SetNoFaced()
            inst.components.locomotor:StopMoving()
            inst.components.health:SetInvincible(true)
            inst.AnimState:PlayAnimation("stomp_pre")
			inst.AnimState:PushAnimation("stomp",false)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/enter")
            inst.sg.mem.wantstoscreech = true
			inst.components.locomotor:WalkForward()
        end,

        timeline =
        {
            --[[TimeEvent(4 * FRAMES, ShakeIfClose),
            TimeEvent(31 * FRAMES, DoScreech),
            TimeEvent(32 * FRAMES, DoScreechAlert),
            TimeEvent(35 * FRAMES, StartFlapping),]]
            CommonHandlers.OnNoSleepTimeEvent(38 * FRAMES, function(inst)
				local function isvalid(ent)
					local tags = { "INLIMBO", "epic", "notarget", "invisible", "noattack", "flight", "playerghost", "shadow", "shadowchesspiece", "shadowcreature","bee"}
					for i,v in ipairs(tags) do
						if ent:HasTag(v) then
							return false
						end
					end
					return true
				end
				inst.components.combat:SetAreaDamage(3.5,1.67,isvalid)
				inst.components.combat:DoAttack()
                inst.components.combat:SetAreaDamage(0,0,isvalid)
				inst.components.groundpounder:GroundPound()
				TrySpawnBigLeak(inst)
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("screech"),
        },

        onexit = function(inst)
            --RestoreFlapping(inst)
            inst.Transform:SetSixFaced()
            inst.components.health:SetInvincible(false)
        end,
    },
	
    State{
        name = "command_mortar",
        tags = { "focustarget", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            FaceTarget(inst)
            inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("command2")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, DoScreech),
            TimeEvent(9 * FRAMES, DoScreechAlert),
            TimeEvent(11 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst.sg.mem.wantstofocustarget = nil
                inst.sg.mem.focuscount = 0
                inst.sg.mem.focustargets = nil
                inst.components.timer:StartTimer("focustarget_cd", inst.focustarget_cd)

                local soldiers = inst.components.commander:GetAllSoldiers()
                if #soldiers > 0 and inst.components.combat and inst.components.combat.target then
					for i, soldier in ipairs(soldiers) do
						soldier:MortarAttack(soldier)
					end  
                end
            end),
            CommonHandlers.OnNoSleepTimeEvent(25 * FRAMES, function(inst)
                inst.sg:AddStateTag("caninterrupt")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },
		
        onexit = function(inst)
			inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
			inst.components.timer:StartTimer("mortar_atk", 20)
        end,
		
        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

    },
	
    State{
        name = "command_charge_loop",
        tags = { "focustarget", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            FaceTarget(inst)
			AdjustGuardSpeeds(inst,15)
            inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("command2")
        end,

        timeline =
        {
			--Finish the 1st Charge
            TimeEvent(14 * FRAMES, DoScreech),
            TimeEvent(18 * FRAMES, DoScreechAlert),
            TimeEvent(20 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
				DoScreech(inst)
				DoScreechAlert(inst)
				AdjustGuardSpeeds(inst,20)
				inst:TellSoldiersToCharge(inst)
            end),
			
			
			--2nd Charge
            TimeEvent(50 * FRAMES, function(inst)
				inst.AnimState:PlayAnimation("command2")
				--TheNet:Announce("Starting Second")
				AdjustGuardSpeeds(inst,20)
				inst.direction2 = "back"
                inst:CrossChargeRepeat(inst)
            end),
            TimeEvent(80 * FRAMES, function(inst)
				AdjustGuardSpeeds(inst,25)
				DoScreech(inst)
				DoScreechAlert(inst)
                inst:TellSoldiersToCharge(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),
	
			--3rd Charge
            TimeEvent(110 * FRAMES, function(inst)
				inst.AnimState:PlayAnimation("command2")
				--TheNet:Announce("Starting Third")
				AdjustGuardSpeeds(inst,30)
				inst.direction2 = "forth"
                inst:CrossChargeRepeat(inst)
            end),
            TimeEvent(140 * FRAMES, function(inst)
				AdjustGuardSpeeds(inst,30)
				DoScreech(inst)
				DoScreechAlert(inst)
                inst:TellSoldiersToCharge(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),	

			--4th Charge
            TimeEvent(170 * FRAMES, function(inst)
				inst.AnimState:PlayAnimation("command2")
				--TheNet:Announce("Starting Fourth")
				inst.direction2 = "back"
				AdjustGuardSpeeds(inst,30)
                inst:CrossChargeRepeat(inst)
            end),
            TimeEvent(200 * FRAMES, function(inst)
				AdjustGuardSpeeds(inst,35)
				DoScreech(inst)
				DoScreechAlert(inst)
                inst:TellSoldiersToCharge(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),	

			--5th Charge
            TimeEvent(230 * FRAMES, function(inst)
				inst.AnimState:PlayAnimation("command2")
				--TheNet:Announce("Starting Fifth")
				inst.direction2 = "forth"
				AdjustGuardSpeeds(inst,40)
                inst:CrossChargeRepeat(inst)
            end),
            TimeEvent(250 * FRAMES, function(inst)
				AdjustGuardSpeeds(inst,35)
				DoScreech(inst)
				DoScreechAlert(inst)
                inst:TellSoldiersToCharge(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),	
			
            TimeEvent(280 * FRAMES, function(inst)
                inst.sg:AddStateTag("caninterrupt")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
				inst.sg:GoToState("tired")
            end),
        },
		
        onexit = function(inst)
			inst.components.sanityaura.aura = 0
			inst:ReleaseArmyFromState(inst)
			PutArmyToSleep(inst)
			inst.components.timer:StartTimer("cross_atk", math.random(30,60))
        end,
    },
	
    State{
        name = "command_charge_pre",
        tags = { "focustarget", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            FaceTarget(inst)
            inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("command2")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, DoScreech),
            TimeEvent(9 * FRAMES, DoScreechAlert),
            TimeEvent(11 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),
            CommonHandlers.OnNoSleepTimeEvent(25 * FRAMES, function(inst)
                inst.sg:AddStateTag("caninterrupt")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },
		
        onexit = function(inst)
			inst.components.sanityaura.aura = 0
			inst.chargeTask = inst:DoPeriodicTask(0.1, function(inst) inst:CheckForReadyCharge(inst) end)
			--inst.components.timer:StartTimer("mortar_atk", 20)
        end,
		
        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

    },
	
    State{
        name = "tired", --Bee Queen is Tired after rapidly commanding the army
        tags = {"busy"},

        onenter = function(inst)
			inst.AnimState:PlayAnimation("sleep_pre")
			inst.AnimState:PushAnimation("sleep_loop",true)
			inst.sg:SetTimeout(9)
        end,
		
        ontimeout = function(inst)
			inst.sg:GoToState("idle")
        end, 		

    },
}

for k, v in pairs(events) do
    assert(v:is_a(EventHandler), "Non-event added in mod events table!")
    inst.events[v.name] = v
end

for k, v in pairs(states) do
    assert(v:is_a(State), "Non-state added in mod state table!")
    inst.states[v.name] = v
end

end)

