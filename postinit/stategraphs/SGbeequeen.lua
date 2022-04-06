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
			inst.components.timer:StartTimer("mortar_atk", 20)
        end,
		
        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
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

