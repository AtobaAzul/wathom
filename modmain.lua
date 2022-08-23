local require = GLOBAL.require

PrefabFiles = require("uncompromising_prefabs")
PreloadAssets = {
	Asset( "IMAGE", "images/UM_tip_icon.tex" ),
	Asset( "ATLAS", "images/UM_tip_icon.xml" ),
}
ReloadPreloadAssets()
--Start the game mode
SignFiles = require("uncompromising_writeables")

modimport("init/init_assets")

local GROUND_OCEAN_COLOR = { -- Color for the main island ground tiles
    primary_color = { 0, 0, 0, 25 },
    secondary_color = { 0, 20, 33, 0 },
    secondary_color_dusk = { 0, 20, 33, 80 },
    minimap_color = { 46, 32, 18, 64 }
}

AddTile(
    "HOODEDFOREST", --tile_name 1
    "LAND", --tile_range 2
    { --tile_data 3
        ground_name = "hoodedmoss",
        old_static_id = 102,
    },
    { --ground_tile_def 4
        name = "hoodedmoss.tex",
        atlas = "hoodedmoss.xml",
        noise_texture = "noise_hoodedmoss.tex",
        runsound = "dontstarve/movement/walk_grass",
        walksound = "dontstarve/movement/walk_grass",
        snowsound = "dontstarve/movement/run_snow",
        mudsound = "dontstarve/movement/run_mud",
        colors = GROUND_OCEAN_COLOR
    },
    { --minimap_tile_def 5
        name = "hoodedmoss.tex",
        atlas = "hoodedmoss.xml",
        noise_texture = "mini_noise_hoodedmoss.tex"
    },
    { --turf_def 6
        name = "hoodedmoss",
        anim = "hoodedmoss",
        bank_build = "hfturf"
    }
)

AddTile(
    "ANCIENTHOODEDFOREST",
    "LAND",
    {
        ground_name = "ancienthoodedturf",
        old_static_id = 110,
    },
    {
        name = "ancienthoodedturf.tex",
        atlas = "ancienthoodedturf.xml",
        noise_texture = "noise_jungle.tex",
        runsound = "dontstarve/movement/walk_grass",
        walksound = "dontstarve/movement/walk_grass",
        snowsound = "dontstarve/movement/run_snow",
        mudsound = "dontstarve/movement/run_mud",
        colors = GROUND_OCEAN_COLOR
    },
    {
        name = "ancienthoodedturf.tex",
        atlas = "ancienthoodedturf.xml",
        noise_texture = "mini_noise_jungle.tex"
    },
    {
        name = "ancienthoodedturf",
        anim = "ancienthoodedturf",
        bank_build = "hfturf"
    }
)

ChangeTileRenderOrder(GLOBAL.WORLD_TILES.HOODEDFOREST, GLOBAL.WORLD_TILES.DIRT)
ChangeTileRenderOrder(GLOBAL.WORLD_TILES.ANCIENTHOODEDFOREST, GLOBAL.WORLD_TILES.DIRT)

ChangeMiniMapTileRenderOrder(GLOBAL.WORLD_TILES.HOODEDFOREST, GLOBAL.WORLD_TILES.DIRT)
ChangeMiniMapTileRenderOrder(GLOBAL.WORLD_TILES.ANCIENTHOODEDFOREST, GLOBAL.WORLD_TILES.DIRT)

modimport("init/init_gamemodes/init_uncompromising_mode")

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

RemapSoundEvent( "dontstarve/together_FE/DST_theme_portaled", "UMMusic/music/uncomp_char_select" )
RemapSoundEvent( "dontstarve/music/music_FE", "UMMusic/music/uncomp_main_menu" )

AddShardModRPCHandler("UncompromisingSurvival", "Hayfever_Stop", function(...)
	--print("RPC Hayfever_Stop")
	GLOBAL.TheWorld:PushEvent("beequeenkilled")
end)

AddShardModRPCHandler("UncompromisingSurvival", "Hayfever_Start", function(...)
	--print("RPC Hayfever_Start")
	GLOBAL.TheWorld:PushEvent("beequeenrespawned")
end)

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
print("MOD ROOT HERE YOU DUMMY: "..GLOBAL.TUNING.DSTU.MODROOT)--had to get a way around MODROOT being modmain env. only.