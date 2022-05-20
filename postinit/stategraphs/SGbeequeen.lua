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
				soldier.components.sleeper:GoToSleep(20)
			end
		end
	end	
end

local function SetSpinSpeed(inst,speed,changeDir)
	if inst.beeHolder then
		for i, beeHolder in ipairs(inst.beeHolder) do	
			beeHolder.components.linearcircler.setspeed = speed
		end
	end
end

local function StartFlapping(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/wings_LP", "flying")
end

local function RestoreFlapping(inst)
    if not inst.SoundEmitter:PlayingSound("flying") then
        StartFlapping(inst)
    end
end

local function StopFlapping(inst)
    inst.SoundEmitter:KillSound("flying")
end


env.AddStategraphPostInit("SGbeequeen", function(inst) --For some reason it's called "SGbeequeen" instead of just... beequeen, funky

	local _OldOnExit 
	if inst.states["spawnguards"].onexit then
		_OldOnExit = inst.states["spawnguards"].onexit
	end
	inst.states["spawnguards"].onexit = function(inst)
		if inst.mode == "defensive" then
			inst.AllocatebeeHolders(inst)
			inst:DoTaskInTime(0,function(inst) inst.sg:GoToState("defensive_spin") end)
		end
		if _OldOnExit then
			_OldOnExit(inst)
		end
	end
	
	local _OldOnEnter
	if inst.states["flyaway"].onenter then
		_OldOnEnter = inst.states["flyaway"].onenter
	end

	inst.states["flyaway"].onenter = function(inst)
		for i,v in ipairs(inst.beeHolder) do
			v:Remove()
		end
		if _OldOnEnter then
			_OldOnEnter(inst)
		end
	end

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
        tags = { "busy", "nosleep", "nofreeze", "noattack", "ability" },

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
        end,

        timeline =
        {
            --[[TimeEvent(4 * FRAMES, ShakeIfClose),
            TimeEvent(31 * FRAMES, DoScreech),
            TimeEvent(32 * FRAMES, DoScreechAlert),
            TimeEvent(35 * FRAMES, StartFlapping),]]
            CommonHandlers.OnNoSleepTimeEvent(38 * FRAMES, function(inst)
				local function isvalid(ent)
					local tags = { "INLIMBO", "epic", "notarget", "invisible", "noattack", "flight", "playerghost", "shadow", "shadowchesspiece", "shadowcreature","bee","beehive"}
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
        tags = { "busy", "nosleep", "nofreeze", "ability"  },

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
			inst.components.sanityaura.aura = 0
			inst.components.timer:StartTimer("mortar_atk", 20)
        end,
		
        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

    },
	
    State{
        name = "command_charge_loop",
        tags = { "busy", "nosleep", "nofreeze",  "ability"  },

        onenter = function(inst)
            FaceTarget(inst)
			AdjustGuardSpeeds(inst,15)
            inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("command2")
			inst.AnimState:PushAnimation("idle_loop",true)
        end,

        timeline =
        {
			--Finish the 1st Charge
            TimeEvent(14 * FRAMES, DoScreech),
            TimeEvent(20 * FRAMES, DoScreechAlert),
            TimeEvent(30 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
				DoScreech(inst)
				DoScreechAlert(inst)
				AdjustGuardSpeeds(inst,20)
				inst:TellSoldiersToCharge(inst)
            end),
			
			
			--2nd Charge
            TimeEvent(70 * FRAMES, function(inst)
				inst.AnimState:PlayAnimation("command2")
				inst.AnimState:PushAnimation("idle_loop",true)
				--TheNet:Announce("Starting Second")
				AdjustGuardSpeeds(inst,20)
				inst.direction2 = "back"
                inst:CrossChargeRepeat(inst)
            end),
            TimeEvent(100 * FRAMES, function(inst)
				AdjustGuardSpeeds(inst,20)
				DoScreech(inst)
				DoScreechAlert(inst)
                inst:TellSoldiersToCharge(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),
	
			--3rd Charge
            TimeEvent(130 * FRAMES, function(inst)
				inst.AnimState:PlayAnimation("command2")
				inst.AnimState:PushAnimation("idle_loop",true)
				--TheNet:Announce("Starting Third")
				AdjustGuardSpeeds(inst,20)
				inst.direction2 = "forth"
                inst:CrossChargeRepeat(inst)
            end),
            TimeEvent(170 * FRAMES, function(inst)
				AdjustGuardSpeeds(inst,20)
				DoScreech(inst)
				DoScreechAlert(inst)
                inst:TellSoldiersToCharge(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),	

			--4th Charge
            TimeEvent(200 * FRAMES, function(inst)
				inst.AnimState:PlayAnimation("command2")
				inst.AnimState:PushAnimation("idle_loop",true)
				--TheNet:Announce("Starting Fourth")
				inst.direction2 = "back"
				AdjustGuardSpeeds(inst,20)
                inst:CrossChargeRepeat(inst)
            end),
            TimeEvent(230 * FRAMES, function(inst)
				AdjustGuardSpeeds(inst,20)
				DoScreech(inst)
				DoScreechAlert(inst)
                inst:TellSoldiersToCharge(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),	

			--5th Charge
            TimeEvent(270 * FRAMES, function(inst)
				inst.AnimState:PlayAnimation("command2")
				inst.AnimState:PushAnimation("idle_loop",true)
				--TheNet:Announce("Starting Fifth")
				inst.direction2 = "forth"
				AdjustGuardSpeeds(inst,20)
                inst:CrossChargeRepeat(inst)
            end),
            TimeEvent(300 * FRAMES, function(inst)
				AdjustGuardSpeeds(inst,20)
				DoScreech(inst)
				DoScreechAlert(inst)
                inst:TellSoldiersToCharge(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),	
			
            TimeEvent(350 * FRAMES, function(inst)
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
			inst.components.timer:StartTimer("cross_atk", math.random(40,60))
        end,
    },
	
    State{
        name = "command_charge_pre",
        tags = {"busy", "nosleep", "nofreeze", "ability"},

        onenter = function(inst)
            FaceTarget(inst)
            inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("command2")
			inst.AnimState:PushAnimation("idle_loop",true)
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
        name = "defensive_spin",
        tags = {"busy", "ability" },

        onenter = function(inst)
			if inst.components.timer:TimerExists("spin_bees") then
				inst.components.timer:StopTimer("spin_bees")
			end
			inst.AnimState:PlayAnimation("command1")
			inst.AnimState:PushAnimation("command3",false)
            FaceTarget(inst)
            inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
            inst.components.locomotor:StopMoving()
			inst.spinUp = true
			inst.spinSpeed = 0.01
			SetSpinSpeed(inst,inst.spinSpeed)
        end,
		
        timeline =
        {
            TimeEvent(8 * FRAMES, DoScreech),
            TimeEvent(9 * FRAMES, DoScreechAlert),
            TimeEvent(11 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/attack_pre")
            end),
        },	
		
		onupdate = function(inst)
			if inst.spinUp == true then
				inst.spinSpeed = inst.spinSpeed + FRAMES/10
				if inst.spinSpeed > 0.2 then
					inst.spinUp = false
				end
			elseif inst.spinSpeed > 0 and inst.components.health and inst.components.health:GetPercent() > 0.5 then
					inst.spinSpeed = inst.spinSpeed - FRAMES/10
				else
					inst.spinSpeed = 0.05
			end
			SetSpinSpeed(inst,inst.spinSpeed)
		end,
		
		
		onexit = function(inst)
			if inst.components.health and inst.components.health:GetPercent() < 0.5 then
				SetSpinSpeed(inst,0.05)--spinnning vvhile moving makes bees disappear
			else
				SetSpinSpeed(inst,0)
			end
			inst.components.timer:StartTimer("spin_bees",15)
			inst.components.sanityaura.aura = 0		
		end,
		
        events=
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
	
    State{
        name = "tired", --Bee Queen is Tired after rapidly commanding the army
        tags = {"busy", "ability","tired"},

        onenter = function(inst)
			inst.AnimState:PlayAnimation("tired_pre")
			inst.AnimState:PushAnimation("tired_loop",true)
			inst.sg:SetTimeout(9)
        end,
		
        timeline =
        {
            TimeEvent(9 * FRAMES, StopFlapping),
        },		
		
        ontimeout = function(inst)
			inst.sg:GoToState("idle")
        end, 		

    },
    State{
        name = "tired_pst", --Bee Queen is Tired after rapidly commanding the army
        tags = {"busy", "ability" },

        onenter = function(inst)
			inst.AnimState:PlayAnimation("tired_pst")
        end,
		
        events=
        {
            EventHandler("animover", function(inst)
				StartFlapping(inst)
                inst.sg:GoToState("idle")
            end),
        },	

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

