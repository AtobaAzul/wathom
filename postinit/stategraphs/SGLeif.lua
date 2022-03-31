local env = env
GLOBAL.setfenv(1, GLOBAL)

env.AddStategraphPostInit("leif", function(inst)


local _OldAttackEvent = inst.events["doattack"].fn
	inst.events["doattack"].fn = function(inst, data)
		if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
			if inst.rootready then
				local stump = FindEntity(inst, TUNING.LEIF_MAXSPAWNDIST, nil, {"stump","evergreen"}, { "leif","burnt","deciduoustree" })
				if stump ~= nil and TUNING.DSTU.PINELINGS == true then
					inst.sg:GoToState("summon", data.target)
				else
					inst.sg:GoToState("snare", data.target)
				end
			else
				_OldAttackEvent(inst, data)
			end
		else
			_OldAttackEvent(inst, data)
		end
	end
		--[[
local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(false,true),
    CommonHandlers.OnFreeze(),
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not
     inst.sg:HasStateTag("attack") and not
      inst.sg:HasStateTag("waking") and not
       inst.sg:HasStateTag("sleeping") and 
        (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("frozen")) then
            inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/hurt_VO")
      end
    end),

    EventHandler("doattack", function(inst, data) 
            if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
                    if inst.rootready then
							local stump = FindEntity(inst, TUNING.LEIF_MAXSPAWNDIST, nil, {"stump","evergreen"}, { "leif","burnt","deciduoustree" })
							if stump ~= nil and TUNING.DSTU.PINELINGS == true then
							inst.sg:GoToState("summon", data.target)
							else
                            inst.sg:GoToState("snare", data.target)
							end
						else
                            inst.sg:GoToState("attack", data.target) 
                    end 
			end
             end),

    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("gotosleep", function(inst) inst.sg:GoToState("sleeping") end),
    EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
    EventHandler("bosshide", function(inst) inst.sg:GoToState("hide") end),
    
    
}
]]
local states = {

	State{
        name = "snare",
        tags = { "attack", "busy", "snare" },

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("special")
            --V2C: don't trigger attack cooldown
            --inst.components.combat:StartAttack()
			inst.sg.statemem.target = target
			inst.rootready = false
			
        end,
		
        onexit = function(inst)
			inst.components.combat:SetRange(inst.oldrange)
        end,

        timeline =
        {
            --TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/attack1_pbaoe_pre") end),
            TimeEvent(25 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/leif/foley") end),
			TimeEvent(34 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/leif/footstep") end),
            TimeEvent(35 * FRAMES, function(inst)
                inst.components.combat:DoAreaAttack(inst, 3.5, nil, nil, nil, { "INLIMBO", "epic", "stumpling", "notarget", "invisible", "noattack", "flight", "playerghost", "shadow", "shadowchesspiece", "shadowcreature" })
                if inst.sg.statemem.target ~= nil then
                    inst:SpawnSnare(inst.sg.statemem.target)
					inst.components.combat:SetRange(inst.oldrange)
                end
            end),
			
            TimeEvent(36 * FRAMES, function(inst)
						inst:DoTaskInTime(800*FRAMES, function(inst) 
						inst.rootready = true
						inst.components.combat:SetRange(3*inst.oldrange)
						end)
                inst.sg:RemoveStateTag("busy")
            end),
			
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
	
	State{
        name = "summon",
        tags = { "attack", "busy", "snare" },

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("special")
            --V2C: don't trigger attack cooldown
            --inst.components.combat:StartAttack()
			inst.sg.statemem.target = target
			inst.rootready = false
			
        end,
		
        onexit = function(inst)
			inst.components.combat:SetRange(inst.oldrange)
        end,

        timeline =
        {
            --TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/attack1_pbaoe_pre") end),
            TimeEvent(25 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/leif/foley") end),
			TimeEvent(34 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/leif/footstep") end),
            TimeEvent(35 * FRAMES, function(inst)
                inst.components.combat:DoAreaAttack(inst, 3.5, nil, nil, nil, { "INLIMBO", "epic", "notarget", "invisible", "noattack", "flight", "playerghost", "shadow", "shadowchesspiece", "shadowcreature" })
                if inst.sg.statemem.target ~= nil then
                    inst:SummonStumplings(inst.sg.statemem.target)
					inst.components.combat:SetRange(inst.oldrange)
                end
            end),
			
            TimeEvent(50 * FRAMES, function(inst)
						inst:DoTaskInTime(800*FRAMES, function(inst) 
						inst.rootready = true
						inst.components.combat:SetRange(3*inst.oldrange)
						end)
                inst.sg:RemoveStateTag("busy")
            end),
			
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
	
	State{
        name = "hide",
        tags = {"hiding", "sleeping", "busy"},

        onenter = function(inst)
			inst:AddTag("notarget")
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("transform_tree", false)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/transform_VO")
			inst.sg:SetTimeout(10)
        end,
        events=
        {
		    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() then inst.sg:GoToState("wake") end end),
        },
		
        onexit = function(inst)
			inst:RemoveTag("notarget")
        end,
		
		ontimeout = function(inst)
			inst:RemoveTag("notarget")
            inst.sg:GoToState("wake")
        end,
        
        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/foley") end),
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/foley") end),
        },
    },
}

--[[for k, v in pairs(events) do
    assert(v:is_a(EventHandler), "Non-event added in mod events table!")
    inst.events[v.name] = v
end]]

for k, v in pairs(states) do
    assert(v:is_a(State), "Non-state added in mod state table!")
    inst.states[v.name] = v
end

end)

