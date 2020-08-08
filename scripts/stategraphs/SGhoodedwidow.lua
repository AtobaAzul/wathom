require("stategraphs/commonstates")

local actionhandlers =
{
}

local events=
{
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("nointerrupt") and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst, data)
        if not inst.components.health:IsDead() then
            local weapon = inst.components.combat and inst.components.combat:GetWeapon()
            if weapon then
                if weapon:HasTag("snotbomb") then
                    inst.sg:GoToState("launchprojectile", data.target)
                else
                    inst.sg:GoToState("attack", data.target)
                end
            end
        end
    end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnLocomote(false,true),
    CommonHandlers.OnFreeze(),
}

local states=
{

    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle", true)
			if math.random() < .2 then
				inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream_short")
			end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "nointerrupt"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack") end),
            TimeEvent(25*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack_grunt") end),
            TimeEvent(28*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe") end),
            TimeEvent(28*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },

        events=
        {
            EventHandler("animover", function(inst)inst.sg:GoToState("idle") end),
        },
    },

  	State{
		name = "hit",
        tags = {"busy", "hit"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/hurt")
        end,

        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
		name = "taunt",
        tags = {"busy"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream")
        end,

        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },



	State{
		name = "poop_pre",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
			local angle = TheCamera:GetHeadingTarget()*DEGREES -- -22.5*DEGREES
			inst.Transform:SetRotation(angle / DEGREES)
            inst.AnimState:PlayAnimation("poop_pre")

        end,

        timeline=
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream_short") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("poop_loop") end),
        },
    },

    State{
        name = "poop_loop",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            local angle = TheCamera:GetHeadingTarget()*DEGREES -- -22.5*DEGREES
            inst.Transform:SetRotation(angle / DEGREES)
            inst.AnimState:PlayAnimation("poop_loop")

        end,

        timeline=
        {
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/givebirth_voice") end),

            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/givebirth_foley") end),
            TimeEvent(10*FRAMES, function(inst)
                if inst.components.incrementalproducer then
                    inst.components.incrementalproducer:TryProduce()
                end
            end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                if inst.components.incrementalproducer and inst.components.incrementalproducer:CanProduce() then
                    inst.sg:GoToState("poop_loop")
                else
                    inst.sg:GoToState("poop_pst")
                end
            end),
        },
    },

    State{
        name = "poop_pst",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            local angle = TheCamera:GetHeadingTarget()*DEGREES -- -22.5*DEGREES
            inst.Transform:SetRotation(angle / DEGREES)
            inst.AnimState:PlayAnimation("poop_pst")

        end,
        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/die")
            inst.AnimState:PlayAnimation("death")
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },
    State{
        name = "launchprojectile",
        tags = {"attack", "busy"},
        
        onenter = function(inst, target)    
			inst.sg.statemem.target = target
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("poop_pre")
            inst.AnimState:PushAnimation("poop_loop", false)
            inst.AnimState:PushAnimation("poop_pst", false)
        end,
        
        
        timeline=
        {
            TimeEvent(19*FRAMES, function(inst)
                --inst.SoundEmitter:PlaySound(inst.sounds.spit)
            end),
            TimeEvent(27*FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
				inst.WebReady = false
				inst:DoTaskInTime(35,function(inst) inst.WebReady = true end)
            end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "fall",
        tags = {"busy"},
        onenter = function(inst, data)
			inst.components.locomotor:Stop()
            inst.Physics:SetDamping(0)
            inst.Physics:SetMotorVel(0,-20,0)
            inst.AnimState:PlayAnimation("distress_loop", true)
        end,
        
        onupdate = function(inst)
		
            local pt = Point(inst.Transform:GetWorldPosition())
			inst.Physics:SetMotorVel(0,-20,0)
            if pt.y < 2 then
                inst.Physics:SetMotorVel(0,0,0)

                inst.components.groundpounder:GroundPound()


                pt.y = 0
                
                inst.Physics:Stop()
                inst.Physics:SetDamping(5)
                inst.Physics:Teleport(pt.x,pt.y,pt.z)
                inst.DynamicShadow:Enable(true)
            inst.sg:GoToState("taunt")
            end
        end,

    }

}

CommonStates.AddSleepStates(states,
	{
		sleeptimeline = {
	        TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/sleeping") end),
		},
	},
	{
		onsleep = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/fallasleep")
		end,
		onwake = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/wakeup")
		end
	}
)


CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(32*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(38*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
	},
})

CommonStates.AddFrozenStates(states)


return StateGraph("spiderqueen", states, events, "idle", actionhandlers)

