local require = GLOBAL.require

PrefabFiles = require("uncompromising_prefabs")
PreloadAssets = {
	Asset("IMAGE", "images/UM_tip_icon.tex"),
	Asset("ATLAS", "images/UM_tip_icon.xml"),
}
ReloadPreloadAssets()
--Start the game mode
SignFiles = require("uncompromising_writeables")

modimport("init/init_gamemodes/init_uncompromising_mode")
modimport("init/init_wathom")

if GetModConfigData("funny rat") then
	AddModCharacter("winky", "FEMALE")

	GLOBAL.TUNING.WINKY_HEALTH = 175
	GLOBAL.TUNING.WINKY_HUNGER = 150
	GLOBAL.TUNING.WINKY_SANITY = 125
	GLOBAL.STRINGS.CHARACTER_SURVIVABILITY.winky = "Stinky"
end

GLOBAL.FUELTYPE.BATTERYPOWER = "BATTERYPOWER"
GLOBAL.FUELTYPE.SALT = "SALT"
GLOBAL.FUELTYPE.EYE = "EYE"
GLOBAL.FUELTYPE.SLUDGE = "SLUDGE"
GLOBAL.UPGRADETYPES.ELECTRICAL = "ELECTRICAL"
GLOBAL.UPGRADETYPES.SLUDGE_CORK = "SLUDGE_CORK"
GLOBAL.MATERIALS.SLUDGE = "sludge"
GLOBAL.MATERIALS.COPPER = "copper"

RemapSoundEvent("dontstarve/together_FE/DST_theme_portaled", "UMMusic/music/uncomp_char_select")
RemapSoundEvent("dontstarve/music/music_FE", "UMMusic/music/uncomp_main_menu")

AddShardModRPCHandler("UncompromisingSurvival", "Hayfever_Stop", function()
	--print("RPC Hayfever_Stop")
	GLOBAL.TheWorld:PushEvent("beequeenkilled")
end)

AddShardModRPCHandler("UncompromisingSurvival", "Hayfever_Start", function(...)
	--print("RPC Hayfever_Start")
	GLOBAL.TheWorld:PushEvent("beequeenrespawned")
end)

local function WathomMusicToggle(toggle)
	if toggle then
		print("start music")
		GLOBAL.TheWorld:PushEvent("enabledynamicmusic", false)
		if not GLOBAL.TheFocalPoint.SoundEmitter:PlayingSound("wathommusic") then
			GLOBAL.TheFocalPoint.SoundEmitter:PlaySound("dontstarve/music/UMMusic/music/wathom_amped", "wathommusic")
		end
		print("PLEASE DO THE MUSIC I BEG YOU")
	else
		print("stop music")
		GLOBAL.TheWorld:PushEvent("enabledynamicmusic", true)
		GLOBAL.TheFocalPoint.SoundEmitter:KillSound("wathommusic")
		print("PLEASE I BEG YOU TURNIT OFF!!!!!!!!!!")
	end
end

AddClientModRPCHandler("UncompromisingSurvival", "WathomMusicToggle", WathomMusicToggle)


AddShardModRPCHandler("UncompromisingSurvival", "DeerclopsDeath", function(...)
	if not GLOBAL.TheWorld.ismastershard then
		print("RPC DeerclopsDeath")
		GLOBAL.TheWorld:PushEvent("hasslerkilled")
	end
end)

AddShardModRPCHandler("UncompromisingSurvival", "DeerclopsRemoved", function(...)
	if not GLOBAL.TheWorld.ismastershard then
		print("RPC DeerclopsRemoved")
		GLOBAL.TheWorld:PushEvent("hasslerremoved")
	end
end)

AddShardModRPCHandler("UncompromisingSurvival", "DeerclopsStored", function(...)
	if not GLOBAL.TheWorld.ismastershard then
		print("RPC DeerclopsStored")
		GLOBAL.TheWorld:PushEvent("storehassler")
	end
end)

AddShardModRPCHandler("UncompromisingSurvival", "DeerclopsDeath_caves", function(...)
	if GLOBAL.TheWorld.ismastershard then
		print("RPC DeerclopsDeath")
		GLOBAL.TheWorld:PushEvent("hasslerkilled_secondary")
	end
end)

AddShardModRPCHandler("UncompromisingSurvival", "DeerclopsRemoved_caves", function(...)
	if GLOBAL.TheWorld.ismastershard then
		print("RPC DeerclopsRemoved")
		GLOBAL.TheWorld:PushEvent("hasslerremoved")
	end
end)

AddShardModRPCHandler("UncompromisingSurvival", "DeerclopsStored_caves", function(...)
	if GLOBAL.TheWorld.ismastershard then
		print("RPC DeerclopsStored")
		GLOBAL.TheWorld:PushEvent("storehassler")
	end
end)
--[[
AddShardModRPCHandler("UncompromisingSurvival", "AcidMushroomsUpdate", function(shard_id, data)
    GLOBAL.TheWorld:PushEvent("acidmushroomsdirty", {shard_id = shard_id, uuid = data.uuid, targets = data.targets})
end)

AddShardModRPCHandler("UncompromisingSurvival", "AcidMushroomsTargetFinished", function(shard_id, data)
    GLOBAL.TheWorld:PushEvent("master_acidmushroomsfinished", data)
end)]]

GLOBAL.TUNING.DSTU.MODROOT = MODROOT
print("MOD ROOT HERE YOU DUMMY: " .. GLOBAL.TUNING.DSTU.MODROOT) --had to get a way around MODROOT being modmain env. only.
