local env = env
GLOBAL.setfenv(1, GLOBAL)
local function StartBuzz(inst)
    inst:EnableBuzz(true)
end

local function StopBuzz(inst)
    inst:EnableBuzz(false)
end

local function StopCollide(inst)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function StartCollide(inst)
	inst.Physics:CollidesWith(COLLISION.FLYERS)
	inst.Physics:CollidesWith(COLLISION.CHARACTERS)
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

env.AddStategraphPostInit("SGbeeguard", function(inst) --beeguard time
local events={}
local states = {
    State{
        name = "flyup",
        tags = {"busy", "nosleep", "nofreeze", "noattack","flight"},

        onenter = function(inst)
			SpawnPrefab("bee_poof_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	        if inst.SoundEmitter:PlayingSound("buzz") then
				inst.SoundEmitter:KillSound("buzz")
				inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
			end
			inst.DynamicShadow:Enable(false)
			StartBuzz(inst)
			inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("ascend_pre",false)
			inst.AnimState:PushAnimation("ascend",true)
			inst.sg.statemem.vel = Vector3(3, 10, 0)
			inst.maxflyheight = math.random(8,13)
        end,

		onupdate = function(inst)
			local x,y,z = inst.Transform:GetWorldPosition()
			if y > 4 then
				inst.sg.statemem.vel = Vector3(3, inst.maxflyheight+5-y, 0) --We kinda want it to arc a bit at the top
			end
			inst.Physics:SetMotorVel(inst.sg.statemem.vel:Get())
			if y > inst.maxflyheight then
				inst.sg:GoToState("flydown")
			end
		end,	
    },
	
    State{
        name = "flydown",
        tags = {"busy", "nosleep", "nofreeze", "noattack","flight"},

        onenter = function(inst)
			SpawnPrefab("bee_poof_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
			if inst.SoundEmitter:PlayingSound("buzz") then
				inst.SoundEmitter:KillSound("buzz")
				inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
			end
			StartBuzz(inst)
			inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("stab_pre",false)
			inst.AnimState:PushAnimation("stab",true)
			local horizVel = 3
			local verticalVel = 20
			if inst.stabtarget then
				inst:ForceFacePoint(inst.stabtarget:GetPosition())
				local x,y,z = inst.Transform:GetWorldPosition()
				local x1,y1,z1 = inst.stabtarget.Transform:GetWorldPosition()
				local dist = math.sqrt((x-x1)^2+(z-z1)^2)
				horizVel = dist/(inst.maxflyheight/verticalVel) -- It will be around 0.333 seconds (inst.maxflyheight Length / 25 Length/s) for the bee to reach the ground, so we want to reach the player in this time too! We'll do this by dividing the x-z plane distance between the player and bee by the time the bee should reach the ground.
			end
            inst.sg.statemem.vel = Vector3(horizVel, -verticalVel, 0)
        end,

		onupdate = function(inst)
			inst.Physics:SetMotorVel(inst.sg.statemem.vel:Get())
			local x,y,z = inst.Transform:GetWorldPosition()
			if y < 1 then
				if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
					inst.components.health:Kill()
				else
					inst.DynamicShadow:Enable(true)
					inst.Transform:SetPosition(x,0,z) --Level out the bee so it's not in the wrong plane
					inst.sg:GoToState("stab")				
				end
			end
		end,
    },
	
    State{
        name = "stab",
        tags = { "busy", "nosleep", "nofreeze", "attack", "noattack"}, --We don't want the beeguard to try and attack, but we do need to let the game know this is an attacking state.

        onenter = function(inst)
			inst.stuckcount = 0
			SpawnPrefab("bee_poof_small").Transform:SetPosition(inst.Transform:GetWorldPosition()) --I like the effects XD
			if inst.SoundEmitter:PlayingSound("buzz") then
				inst.SoundEmitter:KillSound("buzz")
				inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
			end			
			StopBuzz(inst)
			inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("stab_pst",false)
        end,
		
		timeline = {
			TimeEvent(3 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound(inst.sounds.attack)
				inst.components.combat:DoAreaAttack(inst, 1.5, nil, nil, nil, {"INLIMBO","bee", "notarget","invisible","playerghost", "shadow"})
			end),
		},
		
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("stuck")
            end),
        },
    },
	
    State{
        name = "stuck",
        tags = {"busy"},

        onenter = function(inst)
			StartBuzz(inst)
			inst.SoundEmitter:PlaySound(inst.sounds.hit)
			inst.components.locomotor:StopMoving()
			if inst.stuckcount > 5 then
				inst.AnimState:PushAnimation("stuck_pst",false)
			else
				inst.AnimState:PlayAnimation("stuck_loop",false)
			end
        end,
		
        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
				StopBuzz(inst)
            end),
        },
		
        events=
        {
            EventHandler("animqueueover", function(inst)
				if inst.stuckcount > 5 then
					inst.sg:GoToState("idle")
				else
					inst.stuckcount = inst.stuckcount + 1
					inst.sg:GoToState("stuck")
				end
            end),
        },
    },
    State{
        name = "charge", --CHARGE! Beeguards charge at the player in formation.
        tags = {"attack","busy","nofreeze","nosleep","noattack","flight","moving"}, --Tags galore...

        onenter = function(inst)
			inst.armorcrunch = true
			StopCollide(inst)
			inst.brain:Stop()
			inst.components.combat:RestartCooldown()
			SpawnPrefab("bee_poof_small").Transform:SetPosition(inst.Transform:GetWorldPosition()) --I like the effects XD
			if inst.SoundEmitter:PlayingSound("buzz") then
				inst.SoundEmitter:KillSound("buzz")
				inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
			end	
			inst.alreadyStabbed = {}
			inst.AnimState:PlayAnimation("run_loop",true)
        end,
		
		onupdate = function(inst)
			inst:ForceFacePoint(inst.chargePoint)
			ArtificialLocomote(inst,inst.chargePoint,inst.chargeSpeed)
			local stabbed = FindEntity(inst,1,function(guy) 
				for i,ent in ipairs(inst.alreadyStabbed) do 
					if guy == ent then
						return false
					end
				end
				return true
			end,
			{"_combat"},{"bee","shadow"})
			if stabbed then
				table.insert(inst.alreadyStabbed,stabbed)
				if stabbed.components.health and not stabbed.components.health:IsDead() then
					local mult = (stabbed:HasTag("player") and 2) or 1
					stabbed.components.combat:GetAttacked(inst,mult*75)
				end
			end
			if inst:GetDistanceSqToPoint(inst.chargePoint) < 1 then
				inst.holdPoint = inst.chargePoint
				inst.sg:GoToState("hold_position")
			end
		end,
		
		onexit = function(inst)
			StartCollide(inst)
			inst.brain:Start()
			inst.armorcrunch = false
		end,
		
    },
    State{
        name = "hold_position",	--All this does is make the beeguard stick on a single position after he finishes charging
        tags = {"busy","nofreeze","nosleep","flight"}, --Tags galore...

        onenter = function(inst)
			StopCollide(inst)
			inst.holding = true
			inst.brain:Stop()
			inst.components.combat:RestartCooldown()
			inst.AnimState:PlayAnimation("idle",true)
			--inst:DoTaskInTime(3,function(inst) inst.sg:GoToState("charge") end) --Temp
			inst.sg:SetTimeout(5)
        end,
		 
        ontimeout = function(inst)
			inst.sg:GoToState("idle")
        end,  	
		
		onupdate = function(inst)
			if inst.components.combat and inst.components.combat.target then
				inst:ForceFacePoint(inst.components.combat.target:GetPosition())
			end
			if inst.holdPoint then
				inst.Transform:SetPosition(inst.holdPoint.x,inst.holdPoint.y,inst.holdPoint.z)
			end
		end,
		
        onexit = function(inst)
			StartCollide(inst)
			inst.brain:Start()
			inst.holding = false
        end,
    },
    State{
        name = "rally_at_point", --Similar to CHARGE but doesn't do damage, bees are just getting ready to charge
        tags = {"attack","busy","nofreeze","nosleep","noattack","flight","moving"}, --Tags galore...

        onenter = function(inst)
			StopCollide(inst)
			inst.brain:Stop()
			inst.components.combat:RestartCooldown()
			if inst.SoundEmitter:PlayingSound("buzz") then
				inst.SoundEmitter:KillSound("buzz")
				inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
			end	
			inst.AnimState:PlayAnimation("run_loop",true)
        end,
		
		onupdate = function(inst)
			inst:ForceFacePoint(inst.rallyPoint)
			ArtificialLocomote(inst,inst.rallyPoint,inst.chargeSpeed)
			if inst:GetDistanceSqToPoint(inst.rallyPoint) < 1 then
				inst.holdPoint = inst.rallyPoint
				inst.sg:GoToState("hold_position")
			end
		end,
		
		onexit = function(inst)
			StartCollide(inst)
			inst.brain:Start()
			if inst:GetDistanceSqToPoint(inst.rallyPoint) > 1 then
				--inst:DoTaskInTime(0.05,function(inst) TheNet:Announce("Tried to go to"..inst.sg.currentstate.name) end)
				inst:DoTaskInTime(0.1,function(inst) 
				inst.sg:GoToState("rally_at_point") end)
			end	
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

