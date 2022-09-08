AddMinimapAtlas("images/map_icons/wathom.xml")

require "class"
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local FRAMES = GLOBAL.FRAMES
FRAMES = GLOBAL.FRAMES
local TimeEvent = GLOBAL.TimeEvent
TimeEvent = GLOBAL.TimeEvent
local EventHandler = GLOBAL.EventHandler
EventHandler = GLOBAL.EventHandler
localEQUIPSLOTS = GLOBAL.EQUIPSLOTS
EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local SpawnPrefab = GLOBAL.SpawnPrefab
local Action = GLOBAL.Action
local ActionHandler = GLOBAL.ActionHandler
Action = GLOBAL.Action
Vector3 = GLOBAL.Vector3
local Vector3 = GLOBAL.Vector3



-- It's 1 AM and I don't want to pick apart which local is needed so I'll just grab all of it.

--------------------------------------------------------------------------
-- 90% of code here is taken from Warfarin, made by the wonderful Tiddler.

-- Setting up new actions

	local function Effect(inst) -- I dumbed the shit out of this.
			if GLOBAL.TheWorld.state.wetness > 25 then
    	local puff = SpawnPrefab("weregoose_splash_med2")
	puff.Transform:SetPosition(inst.Transform:GetWorldPosition())
               end
end

local SGWilson = require "stategraphs/SGwilson"
local SGWilsonClient = require "stategraphs/SGwilson_client"
local Attack_Old
local ClientAttack_Old

for k1, v1 in pairs(SGWilson.actionhandlers) do
  if SGWilson.actionhandlers[k1]["action"]["id"] == "ATTACK" then	
    Attack_Old = SGWilson.actionhandlers[k1]["deststate"]
  end
end

local function Attack_New(inst, action)
  inst.sg.mem.localchainattack = not action.forced or nil
  local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil

	if weapon and inst:HasTag("wathom") and not inst.sg:HasStateTag("attack") then
    return ("wathomleap") 
  else
    return Attack_Old(inst, action)
  end
end

--Client


for k1, v1 in pairs(SGWilsonClient.actionhandlers) do
  if SGWilsonClient.actionhandlers[k1]["action"]["id"] == "ATTACK" then
    ClientAttack_Old = SGWilsonClient.actionhandlers[k1]["deststate"]
  end
end

local function AttackClient_New(inst, action)
  local weapon = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
  
	if weapon and inst:HasTag("wathom") and not inst.sg:HasStateTag("attack") then
    return ("wathomleap_pre") 
  else
    return ClientAttack_Old(inst, action)
  end
end

--Pack it up

AddStategraphActionHandler("wilson", ActionHandler(GLOBAL.ACTIONS.ATTACK, Attack_New))
GLOBAL.package.loaded["stategraphs/SGwilson"] = nil 

AddStategraphActionHandler("wilson_client", ActionHandler(GLOBAL.ACTIONS.ATTACK, AttackClient_New))
GLOBAL.package.loaded["stategraphs/SGwilson_client"] = nil

AddStategraphActionHandler("wilson", ActionHandler(GLOBAL.ACTIONS.ATTACK, Attack_New))
------------------------
-- the MEAT



AddStategraphPostInit("wilson", function(inst)
	local actionhandlers =
	{
		ActionHandler(GLOBAL.ACTIONS.WATHOMBARK,
			function(inst, action)
				return "wathombark"
			end),
			
	}
	
	local states = {
		GLOBAL.State{
			name = "wathombark",
			tags = {"attack", "backstab", "busy", "notalking", "abouttoattack", "pausepredict", "nointerrupt" },

			onenter = function(inst, data)
				local buffaction = inst:GetBufferedAction()
				local target = buffaction ~= nil and buffaction.target or nil			
				inst.AnimState:PlayAnimation("emote_angry", false)
				inst.components.locomotor:Stop()
				inst.components.locomotor:EnableGroundSpeedMultiplier(false)
				if inst.components.playercontroller ~= nil then
				   inst.components.playercontroller:RemotePausePrediction()
				end
			end,

			onexit = function(inst)
			end,

			timeline=
			{
				TimeEvent(0*FRAMES, function(inst) 
					inst.SoundEmitter:PlaySound("wathomcustomvoice/wathomvoiceevent/bark") --place your funky sounds here
						local fx = SpawnPrefab("statue_transition_2")
						if fx ~= nil then
						fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
						fx.Transform:SetScale(1.2,1.2,1.2)
						end
						fx = SpawnPrefab("statue_transition")
						if fx ~= nil then
						fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
						fx.Transform:SetScale(1.2,1.2,1.2)
						end					
				end),


				TimeEvent(12*FRAMES, function(inst) 
					inst.components.locomotor:Stop()
					inst:PerformBufferedAction() --Dis is the important part, canis -Axe 
					inst.sg:RemoveStateTag("busy")
					inst.sg:RemoveStateTag("nointerrupt")					
				end),			

			},

			events=
			{
				EventHandler("animover", function(inst)
					inst.sg:GoToState("idle")
					if not inst.components.playercontroller ~= nil then
						inst.components.playercontroller:Enable(true)
					end
				end),
			},
		},
 
		GLOBAL.State{
			name = "wathomleap",
			tags = {"attack", "backstab", "busy", "notalking", "abouttoattack", "pausepredict", "nointerrupt" },

			onenter = function(inst, data)
			Effect(inst)
				local buffaction = inst:GetBufferedAction()
				local target = buffaction ~= nil and buffaction.target or nil
				inst.components.combat:SetTarget(target)
				inst.components.combat:StartAttack()
	--            inst.components.health:SetInvincible(true) -- I wonder why Tiddler did this?
					--inst.AnimState:PlayAnimation("atk_leap_pre", false)
					inst.AnimState:PlayAnimation("atk_leap", false)
						inst.Transform:SetEightFaced()
			inst.AnimState:ClearOverrideBuild("player_lunge")
			inst.AnimState:ClearOverrideBuild("player_attack_leap")
				inst.components.locomotor:Stop()
				inst.components.locomotor:EnableGroundSpeedMultiplier(false)
				if inst.components.playercontroller ~= nil then
				   inst.components.playercontroller:RemotePausePrediction()
				end

			end,

			onexit = function(inst)
	--            inst.components.health:SetInvincible(false)
				inst.components.combat:SetTarget(nil)
				if inst.sg:HasStateTag("abouttoattack") then
					inst.components.combat:CancelAttack()
				end
						inst.Transform:SetFourFaced()
				inst.components.locomotor:Stop()
						inst.Physics:ClearMotorVelOverride()
				inst.components.locomotor:EnableGroundSpeedMultiplier(true)
			inst.AnimState:AddOverrideBuild("player_lunge")
			inst.AnimState:AddOverrideBuild("player_attack_leap")
			end,

			timeline=
			{
				TimeEvent(0*FRAMES, function(inst) 
				inst.SoundEmitter:PlaySound("wathomcustomvoice/wathomvoiceevent/leap")
				inst.Physics:ClearCollisionMask() -- all of this physics stuff will give the impression that Wathom is jumping over things. It also allows him to slide past targets instead of ending his leap in front.
				inst.components.hunger:DoDelta(-1, 2)
				inst.Physics:CollidesWith(GLOBAL.COLLISION.WORLD)
				inst.Physics:CollidesWith(GLOBAL.COLLISION.OBSTACLES)
				inst.Physics:CollidesWith(GLOBAL.COLLISION.SMALLOBSTACLES)
				local buffaction = inst:GetBufferedAction()
				local target = buffaction ~= nil and buffaction.target or nil
			if target ~= nil then
						inst.sg.statemem.startingpos = inst:GetPosition()
						inst.sg.statemem.targetpos = target:GetPosition()
				if target ~= nil then
						if inst.sg.statemem.startingpos.x ~= inst.sg.statemem.targetpos.x or inst.sg.statemem.startingpos.z ~= inst.sg.statemem.targetpos.z then
							inst.Physics:SetMotorVelOverride(math.sqrt(GLOBAL.distsq(inst.sg.statemem.startingpos.x, inst.sg.statemem.startingpos.z, inst.sg.statemem.targetpos.x, inst.sg.statemem.targetpos.z)) / (12 * FRAMES), 0 ,0)
						end
			end
		end
		inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump") 
				end),


				TimeEvent(12*FRAMES, function(inst) 
							inst.sg:RemoveStateTag("abouttoattack")
				inst.components.locomotor:Stop()
						inst.Physics:ClearMotorVelOverride()
			inst:PerformBufferedAction() 
			inst.components.playercontroller:Enable(false)
				inst.components.locomotor:EnableGroundSpeedMultiplier(true)
						inst.sg:RemoveStateTag("busy")
				end),

				TimeEvent(14*FRAMES, function(inst) 					
				-- This is when the target gets hit.
				inst.Physics:SetMotorVel(10, 0, 0) -- This causes Wathom to slide forward. Update when Adrenaline is implemented.
		SpawnPrefab("dirt_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
				end),	

				TimeEvent(19*FRAMES, function(inst) 					
		SpawnPrefab("dirt_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
				end),	

				TimeEvent(24*FRAMES, function(inst) 
					SpawnPrefab("dirt_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
						inst.sg:RemoveStateTag("busy")
						inst.sg:RemoveStateTag("attack")
						inst.sg:RemoveStateTag("nointerrupt")
						inst.sg:RemoveStateTag("pausepredict")
				inst.sg:AddStateTag("idle")
				inst.Physics:SetMotorVel(0.0, 0, 0) -- Stops Wathom's sliding.
					inst.Physics:Stop()
					inst.Physics:CollidesWith(GLOBAL.COLLISION.CHARACTERS) -- Re-enabling Wathom's normal collision.
						inst.components.playercontroller:Enable(true)
				end),				

			},

			events=
			{
				EventHandler("animover", function(inst)
					inst.sg:GoToState("idle")
									if not inst.components.playercontroller ~= nil then
						inst.components.playercontroller:Enable(true)
						end
				end ),
			},			 
		},
	}
	
	for k, v in pairs(states) do
		GLOBAL.assert(v:is_a(GLOBAL.State), "Non-state added in mod state table!")
		inst.states[v.name] = v
	end
	
	for k, v in pairs(actionhandlers) do
		GLOBAL.assert(v:is_a(GLOBAL.ActionHandler), "Non-action added in mod state table!")
		inst.actionhandlers[v.action] = v
	end
 
end)
	
--client. Uses a "pre" as this should only be used if there's lag.

AddStategraphPostInit("wilson_client", function(inst)
	local actionhandlers =
	{
		ActionHandler(GLOBAL.ACTIONS.WATHOMBARK,
			function(inst, action)
				return "wathombark_pre"
			end),
	}
	local states = {
	GLOBAL.State {
        name = "wathomleap_pre",
        tags = {  "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

		inst.AnimState:PlayAnimation("atk_leap_pre", false)
            inst.AnimState:PushAnimation("atk_leap_lag", false)

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.pos ~= nil then
                    inst:ForceFacePoint(buffaction:GetActionPoint():Get())
                end
            end

            inst.sg:SetTimeout(2)
        end,

        onupdate = function(inst)
            if inst:HasTag("busy") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
	},

	GLOBAL.State {
        name = "wathombark_pre",
        tags = {  "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

			inst.AnimState:PlayAnimation("idle", false)

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.pos ~= nil then
                    inst:ForceFacePoint(buffaction:GetActionPoint():Get())
                end
            end

            inst.sg:SetTimeout(2)
        end,

        onupdate = function(inst)
            if inst:HasTag("busy") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
	}
	}

	for k, v in pairs(states) do
		GLOBAL.assert(v:is_a(GLOBAL.State), "Non-state added in mod state table!")
		inst.states[v.name] = v
	end
	
	for k, v in pairs(actionhandlers) do
		GLOBAL.assert(v:is_a(GLOBAL.ActionHandler), "Non-action added in mod state table!")
		inst.actionhandlers[v.action] = v
	end	
end)




-----------------------------------------------------------------------------------------------------

STRINGS.ACTIONS.WATHOMBARK = "Bark"

local function AddEnemyDebuffFx(fx, target)
    target:DoTaskInTime(math.random()*0.25, function()
        local x, y, z = target.Transform:GetWorldPosition()
        local fx = SpawnPrefab(fx)
        if fx then
            fx.Transform:SetPosition(x, y, z)
        end

        return fx
    end)
end

local wathombark = AddAction(
	"WATHOMBARK",
	GLOBAL.STRINGS.ACTIONS.WATHOMBARK,
	function(act)
    if act.doer ~= nil then -- previously act.target
		local inst = act.doer
		inst.AnimState:AddOverrideBuild("emote_angry")
		inst.components.adrenalinecounter:DoDelta(-20, 2) 
--		inst.SoundEmitter:PlaySound("wathomcustomvoice/wathomvoiceevent/bark") Commented out for now since it already plays the sound before this code is performed
		
				local act_pos = act:GetActionPoint()
				local ents = GLOBAL.TheSim:FindEntities(act_pos.x, act_pos.y, act_pos.z, 10, { "_combat" }, { "companion" })
				for i, v in ipairs(ents) do
					if v.components.hauntable ~= nil and v.components.hauntable.panicable and not
					(v.components.follower ~= nil and v.components.follower:GetLeader() and v.components.follower:GetLeader():HasTag("player")) then
						v.components.hauntable:Panic(TUNING.BATTLESONG_PANIC_TIME)
						AddEnemyDebuffFx("battlesong_instant_panic_fx", v)
					end
				end 
			end
		end
)

wathombark.priority = HIGH_ACTION_PRIORITY
wathombark.rmb = true
wathombark.distance = 36
wathombark.mount_valid = false
 
STRINGS.ACTIONS.WATHOMBARK = "Bark"

-- STRINGS.ACTIONS.AMPUP = "Amp Up!"

---------------------------------------------

local KnownModIndex = GLOBAL.KnownModIndex
local Text = require "widgets/text"
local Image = require "widgets/image"
local NUMBERFONT = GLOBAL.NUMBERFONT

local function GetModName(modname) -- modinfo's modname and internal modname is different.
    for _, knownmodname in ipairs(KnownModIndex:GetModsToLoad()) do
        if KnownModIndex:GetModInfo(knownmodname).name == modname  then
            return knownmodname
        end
    end
end

local function GetModOptionValue(knownmodname, known_option_name)
    local modinfo = KnownModIndex:GetModInfo(knownmodname)
    for _,option in pairs(modinfo.configuration_options) do
        if option.name == known_option_name then
            return option.saved
        end
    end
end

AddPlayerPostInit(function(inst)
    if inst:HasTag("wathom") then

        inst.counter_max = GLOBAL.net_shortint(inst.GUID, "counter_max", "counter_maxdirty") 
        inst.counter_current = GLOBAL.net_shortint(inst.GUID, "counter_current", "counter_currentdirty") 

        if GLOBAL.TheWorld.ismastersim then
            inst:AddComponent("adrenalinecounter")
        end 
    end
end)

local function AmpbadgeDisplays(self)
    if self.owner:HasTag("wathom") then
        local ampbadge = require "widgets/ampbadge"

        self.combinedmod = GetModName("Combined Status")

        self.adrenaline = self:AddChild(ampbadge(self.owner))
        if self.combinedmod ~= nil then
            self.brain:SetPosition(0, 35, 0)
            self.stomach:SetPosition(-62, 35, 0)
            self.heart:SetPosition(62, 35, 0)

            self.adrenaline:SetScale(.9,.9,.9)
            self.adrenaline:SetPosition(-62, -50, 0)
            self.adrenaline.combinedmod = true
            self.adrenaline.showmaxonnumbers = GetModOptionValue(self.combinedmod, "SHOWMAXONNUMBERS")

            self.adrenaline.bg = self.adrenaline:AddChild(Image("images/status_bgs.xml", "status_bgs.tex"))
            self.adrenaline.bg:SetScale(.4,.43,0)
            self.adrenaline.bg:SetPosition(-.5, -40, 0)
        
            self.adrenaline.num:SetFont(NUMBERFONT)
            self.adrenaline.num:SetSize(28)
            self.adrenaline.num:SetPosition(3.5, -40.5, 0)
            self.adrenaline.num:SetScale(1,.78,1)

            self.adrenaline.num:MoveToFront()
            self.adrenaline.num:Show()

            self.adrenaline.maxnum = self.adrenaline:AddChild(Text(NUMBERFONT, self.adrenaline.showmaxonnumbers and 25 or 33))
            self.adrenaline.maxnum:SetPosition(6, 0, 0)
            self.adrenaline.maxnum:MoveToFront()
            self.adrenaline.maxnum:Hide()
        else
            self.adrenaline:SetPosition(-40, -50,0)
            self.brain:SetPosition(40, -50, 0)
            self.stomach:SetPosition(-40,17,0)
        end
        
        --self.inst:ListenForEvent("adrenalinedetla", function(inst, data) self.adrenaline:SetPercent(data.newpercent, self.owner.components.pestilencecounter:Max()) end, self.owner)

        local _SetGhostMode = self.SetGhostMode
        function self:SetGhostMode(ghostmode)
            if not self.isghostmode == not ghostmode then --force boolean
                return
            end

            _SetGhostMode(self, ghostmode)
            if ghostmode then
                self.adrenaline:Hide()
            else
                self.adrenaline:Show()
            end
        end
    end
end

AddClassPostConstruct("widgets/statusdisplays", AmpbadgeDisplays)

-------------------------------------------------------
-- The character select screen lines
STRINGS.CHARACTER_TITLES.wathom = "The Abomination"
STRINGS.CHARACTER_NAMES.wathom = "Wathom"
STRINGS.CHARACTER_DESCRIPTIONS.wathom = "*Apex Predator\n*Gets amped up with adrenaline\n*Causes animals to panic\n*The faster he goes, the harder he falls"
STRINGS.CHARACTER_QUOTES.wathom = "\"I HEAR YOU BREATHING.\""
STRINGS.CHARACTER_SURVIVABILITY.wathom = "Slim"

-- Custom speech strings
--STRINGS.CHARACTERS.WATHOM = require "speech_wathom"

-- The character's name as appears in-game 
STRINGS.NAMES.WATHOM = "Wathom"
STRINGS.SKIN_NAMES.wathom_none = "Wathom"

-- The skins shown in the cycle view window on the character select screen.
-- A good place to see what you can put in here is in skinutils.lua, in the function GetSkinModes
local skin_modes = {
    { 
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle", 
        scale = 0.75, 
        offset = { 0, -25 } 
    },
}

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("wathom", "MALE", skin_modes)
