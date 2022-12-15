local require = GLOBAL.require


PrefabFiles = require("wathom_prefabs")
PreloadAssets = {

}
ReloadPreloadAssets()
--Start the game mode

modimport("init/init_gamemodes/init_uncompromising_mode")
modimport("init/init_wathom")

local function WathomMusicToggle(level)
	if level ~= nil then
		GLOBAL.TheWorld:PushEvent("enabledynamicmusic", false)
		GLOBAL.TheWorld.wathom_enabledynamicmusic = false
		if not GLOBAL.TheFocalPoint.SoundEmitter:PlayingSound("wathommusic") then
			GLOBAL.TheFocalPoint.SoundEmitter:PlaySound("UMMusic/music/" .. level, "wathommusic")
		end
	else
		if not GLOBAL.TheWorld.wathom_enabledynamicmusic then --just so other things that killed the music don't get messed up.
			GLOBAL.TheWorld:PushEvent("enabledynamicmusic", true)
			GLOBAL.TheWorld.wathom_enabledynamicmusic = true
		end
		GLOBAL.TheFocalPoint.SoundEmitter:KillSound("wathommusic")
	end
end

--wathomcustomvoice/wathomvoiceevent
local function DoAdrenalineUpStinger(sound)
	if type(sound) =="string" then
		GLOBAL.TheFrontEnd:GetSound():PlaySound("wathomcustomvoice/wathomvoiceevent/"..sound)
	else
		GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/characters/wathgrithr/inspiration_down")
	end
end

AddClientModRPCHandler("UncompromisingSurvival", "WathomMusicToggle", WathomMusicToggle)
AddClientModRPCHandler("UncompromisingSurvival", "WathomAdrenalineStinger", DoAdrenalineUpStinger)
