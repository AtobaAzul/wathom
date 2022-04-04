local env = env
GLOBAL.setfenv(1, GLOBAL)
local function StartBuzz(inst)
    inst:EnableBuzz(true)
end

local function StopBuzz(inst)
    inst:EnableBuzz(false)
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
				inst.stuckcount = 0
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
            inst.AnimState:PlayAnimation("stuck_loop",false)
			if inst.stuckcount > 5 then
				inst.AnimState:PushAnimation("stuck_pst",false)
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

