require("stategraphs/commonstates")


local events =
{
    CommonHandlers.OnLocomote(true, true),
    EventHandler("attacked", function(inst)
        if not (inst.sg:HasStateTag("jumping") or inst.components.health:IsDead()) and not CommonHandlers.HitRecoveryDelay(inst) then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("knockback", function(inst, data)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("knockback", data)
        end
    end),
    EventHandler("updatepetmastery", function(inst, data)
        if inst._pet_level ~= nil and data ~= nil and inst._pet_level == data.newlevel then
            --cancel change
            inst.sg.mem.queuelevelchange = nil
        else
            inst.sg.mem.queuelevelchange = true
            if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) and inst.sg.currentstate.name ~= "appear" then
                inst.sg:GoToState("levelup")
            end
        end
    end),
    EventHandler("death", function(inst)
        inst.sg:GoToState("death")
    end),
    EventHandler("locomote", function(inst)
        --[[if not inst.sg:HasStateTag("busy") and inst.circling == false then
            local is_moving = inst.sg:HasStateTag("moving")
            local wants_to_move = inst.components.locomotor:WantsToMoveForward()
            if not inst.sg:HasStateTag("attack") and is_moving ~= wants_to_move then
                if wants_to_move then
                    inst.sg:GoToState("premoving")
                elseif not is_moving then
                    inst.sg:GoToState("idle")
                end
            end
        end]]
    end), 
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate", "canslide" },

        onenter = function(inst)
            if inst.sg.mem.queuelevelchange then
                inst.sg:GoToState("eyetacle_idle")
            else
                inst.AnimState:PlayAnimation("eyetacle_idle", true)
            end
        end,
    },

    State{
        name = "appear",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("eyetacle_appear")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.aura:Enable(true)
        end,
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("eyetacle_hit")
            inst.Physics:Stop()
			CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

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
        name = "death",
        tags = { "busy", "noattack", "nointerrupt" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("tacle_death")--inst.AnimState:PlayAnimation("dissipate")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.components.lootdropper ~= nil then
                        inst.components.lootdropper:DropLoot()
                    end
                    inst:PushEvent("detachchild")
                    inst:Remove()
                end
            end)
        },
    },
    State{
        name = "premoving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("eyetacle_idle")
        end,

        timeline=
        {
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end),
        },
    },

    State{
        name = "run",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PushAnimation("eyetacle_idle")
        end,

        timeline=
        {
         },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end),
        },
    },
    State{
        name = "run_pst",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("eyetacle_idle")
        end,

        timeline=
        {
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "frozen",
        tags = {"busy", "frozen"},

        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("eyetacle_frozen")
            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
        	inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/frozen")
        	inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/sizzle_snow")
            -- Tell clients to no longer target this entity because it will die when it thaws.
            inst.replica.health:SetIsDead(true)
        end,

        events =
        {
            EventHandler("unfreeze", function(inst)	inst.components.health:Kill() end ),
            EventHandler("onthaw", function(inst) inst.sg:GoToState("thaw") end ),
        },
    },

    State{
        name = "thaw",
        tags = {"busy", "thawing"},

        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("eyetacle_frozen_loop_pst", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")
        end,

        events =
        {
            EventHandler("unfreeze", function(inst) inst.components.health:Kill() end),
        },
    },
}

return StateGraph("um_ocupus_eyetacle", states, events, "idle")
