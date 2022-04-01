
local MakePlayerCharacter = require "prefabs/player_common"


local assets = {

        Asset( "ANIM", "anim/player_basic.zip" ),
        Asset( "ANIM", "anim/player_idles_shiver.zip" ),
        Asset( "ANIM", "anim/player_actions.zip" ),
        Asset( "ANIM", "anim/player_actions_axe.zip" ),
        Asset( "ANIM", "anim/player_actions_pickaxe.zip" ),
        Asset( "ANIM", "anim/player_actions_shovel.zip" ),
        Asset( "ANIM", "anim/player_actions_blowdart.zip" ),
        Asset( "ANIM", "anim/player_actions_eat.zip" ),
        Asset( "ANIM", "anim/player_actions_item.zip" ),
        Asset( "ANIM", "anim/player_actions_uniqueitem.zip" ),
        Asset( "ANIM", "anim/player_actions_bugnet.zip" ),
        Asset( "ANIM", "anim/player_actions_fishing.zip" ),
        Asset( "ANIM", "anim/player_actions_boomerang.zip" ),
        Asset( "ANIM", "anim/player_bush_hat.zip" ),
        Asset( "ANIM", "anim/player_attacks.zip" ),
        Asset( "ANIM", "anim/player_idles.zip" ),
        Asset( "ANIM", "anim/player_rebirth.zip" ),
        Asset( "ANIM", "anim/player_jump.zip" ),
        Asset( "ANIM", "anim/player_amulet_resurrect.zip" ),
        Asset( "ANIM", "anim/player_teleport.zip" ),
        Asset( "ANIM", "anim/wilson_fx.zip" ),
        Asset( "ANIM", "anim/player_one_man_band.zip" ),
        Asset( "ANIM", "anim/shadow_hands.zip" ),
        Asset( "SOUND", "sound/sfx.fsb" ),
        Asset( "SOUND", "sound/wilson.fsb" ),
        Asset( "ANIM", "anim/beard.zip" ),

		-- Don't forget to include your character's custom assets!
        Asset( "ANIM", "anim/winky.zip" ),
		Asset( "ANIM", "anim/ghost_winky_build.zip" ),
}
local prefabs = {}

local function GetPointSpecialActions(inst, pos, useitem, right)
    if right and useitem == nil then
        local rider = inst.replica.rider
        if rider == nil or not rider:IsRiding() then
            return { ACTIONS.CREATE_BURROW }
        end
    end
    return {}
end

local function OnSetOwner(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
    end
end

local function common_postinit(inst)
    inst.avatar_tex   = "avatar_winky.tex"
    inst.avatar_atlas = "images/avatars/avatar_winky.xml"

    inst.avatar_ghost_tex   = "avatar_ghost_winky.tex"
    inst.avatar_ghost_atlas = "images/avatars/avatar_ghost_winky.xml"
	
    inst:AddTag("playermonster")
    inst:AddTag("monster")
	
    inst:ListenForEvent("setowner", OnSetOwner)
end

local start_inv =
{
}

local function checkfav(inst, food)
	if food ~= nil and food.components.edible.foodtype == FOODTYPE.HORRIBLE then
		local value = food.prefab == "powcake" and 5 or 0
	
		inst.components.hunger:DoDelta(10 + value)
		inst.components.health:DoDelta(10 + value)
		inst.components.sanity:DoDelta(10 + value)
	end
end

local function OnPickSomething(inst, data)
end

local function OnDropItem(inst)
	inst.components.sanity:DoDelta(-5)
end

local function sanityfn(inst)
	local sanityvalue = -5

	for i = 1, inst.components.inventory.maxslots do
		if inst.components.inventory:GetItemInSlot(i) ~= nil then
			sanityvalue = sanityvalue + 0.1
		end
	end

    return sanityvalue
end

local function master_postinit(inst)

	 -- Minimap icon
    inst.MiniMapEntity:SetIcon("winky.tex")
    inst:AddTag("winky")
    inst:AddTag("ratwhisperer")

	-- choose which sounds this character will play
	--inst.soundsname = "winnie"
	inst.soundsname = "winky"
	
    inst.components.foodaffinity:AddPrefabAffinity("powcake", 20)
	inst.components.eater:SetCanEatHorrible()
	inst.components.eater:SetStrongStomach(true) -- can eat monster meat!
	inst.components.eater:SetCanEatRawMeat(true)
	inst.components.eater:SetOnEatFn(checkfav)
	
    inst.components.sanity.night_drain_mult = TUNING.WENDY_SANITY_MULT
    inst.components.sanity.neg_aura_mult = TUNING.WENDY_SANITY_MULT

	-- todo: Add an example special power here.
	inst.components.health:SetMaxHealth(175)
	inst.components.hunger:SetMax(150)
	inst.components.sanity:SetMax(125)
    --inst.components.sanity.custom_rate_fn = sanityfn
	
	inst.components.combat.damagemultiplier = TUNING.WENDY_DAMAGE_MULT
	if TheWorld.state.isnight then
		inst.components.locomotor:SetExternalSpeedMultiplier(inst, "im_winky_mother_frikker", 1.25) 
	else
		inst.components.locomotor:SetExternalSpeedMultiplier(inst, "im_winky_mother_frikker", 1.15)
	end

	inst:WatchWorldState("isnight", function() 
		if TheWorld.state.isnight then
			inst.components.locomotor:SetExternalSpeedMultiplier(inst, "im_winky_mother_frikker", 1.25) 
		else
			inst.components.locomotor:SetExternalSpeedMultiplier(inst, "im_winky_mother_frikker", 1.15)
		end
	end)
	
    --inst:ListenForEvent("picksomething", OnPickSomething)
    inst:ListenForEvent("dropitem", OnDropItem)
    --inst:ListenForEvent("itemlose", OnDropItem)
end


STRINGS.CHARACTERS.WINKY= require "speech_winky"
STRINGS.CHARACTERS.WINKY= require "speech_winkyum"

return MakePlayerCharacter("winky", prefabs, assets, common_postinit, master_postinit, start_inv)