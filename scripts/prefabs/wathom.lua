local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset( "SOUNDPACKAGE", "sound/wathomcustomvoice.fev"),
	Asset( "SOUND", "sound/wathomcustomvoice.fsb")
}

-- Your character's stats
TUNING.WATHOM_HEALTH = 225
TUNING.WATHOM_HUNGER = 120
TUNING.WATHOM_SANITY = 120

-- Custom starting inventory
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WATHOM = {
	"flint",
	"flint",
	"twigs",
	"twigs", -- Placeholder :)
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WATHOM
end
local prefabs = FlattenTree(start_inv, true)

-- When the character is revived from human
local function onbecamehuman(inst)
	-- Set speed when not a ghost (optional)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wathom_speed_mod", 1)
end

local function onbecameghost(inst)
	-- Remove speed modifier when becoming a ghost
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "wathom_speed_mod")
end

-------------------------------------------


local function AmpTimer(inst)
    if inst.components.adrenalinecounter:GetPercent() < 0.24 then
        inst.components.grogginess.grog_amount = 0.5
    end 
end

local function AmpTimer2(inst)
	    if inst.components.adrenalinecounter:GetPercent() > 0.25 and not inst.adrenalpause then
    inst.components.adrenalinecounter:DoDelta(-1) -- Draining adrenaline when not in combat. Need to make this not work if Wathom attacks/gets hit in the past 5 seconds.
		end
		
		if inst.components.adrenalinecounter:GetPercent() < 0.25 then
    inst.components.adrenalinecounter:DoDelta(1) -- Slowly regaining to normal levels.
		end
		
end


local function AttackOther(inst,data)
    if data and data.target and inst.components.adrenalinecounter:GetPercent() > 0.24 and ((data.target.components.combat and data.target.components.combat.defaultdamage > 0) or (data.target.prefab == "dummytarget" or data.target.prefab == "antlion" or data.target.prefab == "stalker_atrium" or data.target.prefab == "stalker"))  then
		inst.adrenalpause = true
		if inst.adrenalresume then
			inst.adrenalresume:Cancel()
			inst.adrenalresume = nil
		end
		inst.adrenalresume = inst:DoTaskInTime(10,function(inst) inst.adrenalpause = false end)
		inst.components.adrenalinecounter:DoDelta(1)
	end
end

local function OnHealthDelta(inst, data)
    if data.amount < 0 then
        inst.components.adrenalinecounter:DoDelta(data.amount * -0.5) -- This gives Wathom adrenaline when attacked!
    end
end



---------------------------------------------

local function GetPointSpecialActions(inst, pos, useitem, right)
    if right and useitem == nil then
        local rider = inst.replica.rider
        if rider == nil or not rider:IsRiding() then
              return { ACTIONS.WATHOMBARK }
		end
	end
    return {}
end

local function OnSetOwner(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
    end
end



local WATHOM_COLOURCUBES =
{
    day = "images/colour_cubes/ruins_dim_cc.tex",
    dusk = "images/colour_cubes/ruins_dim_cc.tex",
    night = "images/colour_cubes/ruins_dim_cc.tex",
    full_moon = "images/colour_cubes/ruins_dim_cc.tex",
}

-- When loading or spawning the character
local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)
--	inst.components.playervision:SetCustomCCTable(nil)
--    inst.components.playervision:ForceNightVision(false) -- So Wathom doesn't get flashbanged by his nightvision.

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end


-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst) 
	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "wathom.tex" ) 

	inst:AddTag("wathom")
	inst:AddTag("monster")
    inst:AddTag("playermonster")	
	
	inst:AddTag("nightvision")
	
	inst:ListenForEvent("setowner", OnSetOwner)
	
	inst.OnLoad = onload
    inst.OnNewSpawn = onload
    -- Wathom's Nightvision aboveground
	
	if TheWorld:HasTag("cave") or TheWorld.state.isnight then
		inst.components.playervision:ForceNightVision(true)
		inst.components.playervision:SetCustomCCTable(WATHOM_COLOURCUBES)
	else	
		inst.components.playervision:ForceNightVision(false)
		inst.components.playervision:SetCustomCCTable(nil)	
    end
	
    inst:WatchWorldState("isnight", function() 
		inst:DoTaskInTime(TheWorld.state.isnight and 0 or 1,function(inst) 
			if not TheWorld:HasTag("cave") then
			  if TheWorld.state.isnight then
				  inst.components.playervision:ForceNightVision(true)
				  inst.components.playervision:SetCustomCCTable(WATHOM_COLOURCUBES) 
				  else
					inst.components.playervision:ForceNightVision(false)
					inst.components.playervision:SetCustomCCTable(nil)
				end
			end
		end)
    end)	
end

local function UpdateAdrenaline(inst)
	local AmpLevel = inst.components.adrenalinecounter:GetPercent()
		
	if AmpLevel < 0.25 then
		inst.components.combat.attackrange = 2
	elseif AmpLevel < 0.32 then
		inst.components.combat.attackrange = 4
	elseif AmpLevel < 0.45 then
		inst.components.combat.attackrange = 5
	else
		--inst.components.combat.attackrange = 8 --So I could tell it vvas vvorking -AXE
	end
	-- and so on...
end
	
-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
	inst:AddTag("monster")
    inst:AddTag("playermonster")	
    inst.adrenalinecheck = 0 -- I have no idea what this does. It's left over from SCP-049.

	-- Set starting inventory
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
	
	-- choose which sounds this character will play
	inst.soundsname = "wathomvoiceevent"
	inst.talker_path_override = "wathomcustomvoice/"
	
	-- Uncomment if "wathgrithr"(Wigfrid) or "webber" voice is used
    --inst.talker_path_override = "dontstarve_DLC001/characters/"
	
	-- Carnivore
	    if inst.components.eater ~= nil then
        inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODTYPE.MEAT, FOODTYPE.GOODIES })
    end
	
	inst.components.eater:SetCanEatRawMeat(true) 
	
	inst.components.foodaffinity:AddPrefabAffinity("bonestew", 20) -- replace with hardshell tacos when implementing in uncomp
	
	-- Stats	
	inst.components.health:SetMaxHealth(TUNING.WATHOM_HEALTH)
	inst.components.hunger:SetMax(TUNING.WATHOM_HUNGER)
	inst.components.sanity:SetMax(TUNING.WATHOM_SANITY)
	
	-- Damage multiplier (In reality, Wathom won't deal double damage. The time it takes for him to attack is about twice as long as other characters.
    inst.components.combat.damagemultiplier = 2

	-- Hunger rate (optional)
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE

	-- Idle animation
	inst.customidleanim = "spooked"

 -- Wathom's Nightvision in the caves


	-- stuff relating to Wathom's adrenaline timer. This can most likely be optimized.
    inst:DoPeriodicTask(0.5, function() AmpTimer(inst) end)
    inst:DoPeriodicTask(1, function() AmpTimer2(inst) end)

	inst:ListenForEvent("healthdelta", OnHealthDelta)
	inst:ListenForEvent("onattackother",AttackOther)

	-- Wathom's immunity to night drain during the night.
	inst.components.sanity.night_drain_mult = 0
	
	-- Night Vision enabler
--	inst.components.playervision:ForceNightVision(true) -- Should only force this if it's night or in caves.
    inst:WatchWorldState("isnight", function() 
		inst:DoTaskInTime(TheWorld.state.isnight and 0 or 1,function(inst) 
			if not TheWorld:HasTag("cave") then
			  if TheWorld.state.isnight then
				  inst.components.playervision:ForceNightVision(true)
				  inst.components.playervision:SetCustomCCTable(WATHOM_COLOURCUBES) 
				  else
					inst.components.playervision:ForceNightVision(false)
					inst.components.playervision:SetCustomCCTable(nil)
				end
			end
		end)
    end)
	-- Doubles Wathom's attack range so he can jump at things from further away.
	inst.components.combat.attackrange = 4

	-- then in master_postinit
	inst:ListenForEvent("adrenalinedetla", UpdateAdrenaline) -- detla spelled on purpose because it was a carryover typo from 049 code, whoops.	
end

return MakePlayerCharacter("wathom", prefabs, assets, common_postinit, master_postinit, prefabs)
