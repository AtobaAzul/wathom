local prefabs =
{
	"spider",
    "spider_warrior",
    "silk",
    "spidereggsack",
    "spiderqueen",
}

local assets =
{
    Asset("ANIM", "anim/spider_cocoon.zip"),
	Asset("SOUND", "sound/spider.fsb"),
}

SetSharedLootTable('webbedcreature_deer',
{
    {"meat",    1.00},
    {"meat",    0.5},
    {"boneshard",    1.00},
    {"boneshard",    0.5},
    {"bluegem",    0.5},
    {"redgem",    0.5},
})

SetSharedLootTable('webbedcreature_beefalo',
{
    {"meat",    1.00},
    {"meat",    1.00},
    {"beefalowool",    1.00},
    {"beefalowool",    1.00},
    {"beefalowool",    0.5},
    {"horn",    0.5},
    {"poop",    0.5},
    {"poop",    0.5},
    {"poop",    0.5},
})

SetSharedLootTable('webbedcreature_mossling',
{
    {"meat",    1.00},
    {"drumstick",    1.00},
    {"goose_feather",    1.00},
    {"goose_feather",    1.00},
})

SetSharedLootTable('webbedcreature_pigman',
{
    {"meat",    1.00},
    {"pigskin",    1.00},
    {"tophat",    1.00},
})

SetSharedLootTable('webbedcreature_bunnyman',
{
    {"meat",    1.00},
    {"meat",    0.5},
    {"carrot",    1.00},
    {"carrot",    1.00},
    {"manrabbit_tail",    1.00},
    {"manrabbit_tail",    0.5},
})

SetSharedLootTable('webbedcreature_koalefant_summer',
{
    {"meat",    1.00},
    {"meat",    1.00},
    {"meat",    1.00},
    {"meat",    1.00},
    {"poop",    1.00},
    {"poop",    0.5},
    {"phlegm",    0.5},
})

SetSharedLootTable('webbedcreature_little_walrus',
{
    {"meat",    1.00},
    {"earmuffshat",    1.00},
    {"bluegem",    1.00},
})

SetSharedLootTable('webbedcreature_tallbird',
{
    {"meat",    1.00},
    {"smallmeat",    0.5},
    {"tallbirdegg",    1.00},
    {"cutgrass",    1.00},
    {"cutgrass",    0.5},
    {"twigs",    1.00},
    {"twigs",    0.5},
})

SetSharedLootTable('webbedcreature_warg',
{
    {"monstermeat",    1.00},
    {"monstersmallmeat",    0.5},
    {"houndstooth",    1.00},
    {"houndstooth",    0.5},
    {"boneshard",    1.00},
    {"boneshard",    0.5},
    {"bluegem",    0.5},
    {"redgem",    0.5},
})

SetSharedLootTable('webbedcreature_krampus',
{
    {"monstermeat",    1.00},
    {"monstersmallmeat",    0.5},
    {"charcoal",    1.00},
    {"charcoal",    0.5},
    {"boneshard",    1.00},
    {"krampus_sack",    0.05},
    {"bluegem",    0.5},
    {"redgem",    0.5},
})

SetSharedLootTable('webbedcreature_walrus',
{
    {"meat",    1.00},
    {"meat",    1.00},
    {"blowdart_pipe",    0.5},
})

SetSharedLootTable('webbedcreature_bishop',
{
    {"trinket_6",    1.00},
})

SetSharedLootTable('webbedcreature_spat',
{
    {"meat",    1.00},
    {"meat",    0.5},
    {"steelwool",    1.00},
    {"steelwool",    0.5},
    {"phlegm",    1.00},
})

local function SetStage(inst, stage)
	if stage <= 3 then

    
		inst.AnimState:PlayAnimation(inst.anims.init)
		inst.AnimState:PushAnimation(inst.anims.idle, true)
	end  
end

local function SetSmall(inst)
    inst.anims = {
    	hit="cocoon_small_hit", 
    	idle="cocoon_small", 
    	init="grow_sac_to_small", 
    	freeze="frozen_small", 
    	thaw="frozen_loop_pst_small",
    }
    SetStage(inst, 1)
end


local function SetMedium(inst)
    inst.anims = {
    	hit="cocoon_medium_hit", 
    	idle="cocoon_medium", 
    	init="grow_small_to_medium", 
    	freeze="frozen_medium", 
    	thaw="frozen_loop_pst_medium",
    }
    SetStage(inst, 2)
end

local function SetLarge(inst)
    inst.anims = {
    	hit="cocoon_large_hit", 
    	idle="cocoon_large", 
    	init="grow_medium_to_large", 
    	freeze="frozen_large", 
    	thaw="frozen_loop_pst_large",
    }
    SetStage(inst, 3)
end



local function OnKilled(inst)
	inst.AnimState:PlayAnimation("cocoon_dead")
	local x, y, z = inst.Transform:GetWorldPosition()
    inst.SoundEmitter:KillSound("loop")
	inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_destroy")
	local creature = nil
	if inst.size ~= nil then
		if inst.size == 1 then
		creature = "deer"
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("meat",    0.5)
		inst.components.lootdropper:AddChanceLoot("boneshard",    1.00)
		inst.components.lootdropper:AddChanceLoot("boneshard",    0.5)
		inst.components.lootdropper:AddChanceLoot("bluegem",    0.5)
		inst.components.lootdropper:AddChanceLoot("redgem",    0.5)
		end
		if inst.size == 2 then
		creature = "beefalo"
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("beefalowool",    1.00)
		inst.components.lootdropper:AddChanceLoot("beefalowool",    1.00)
		inst.components.lootdropper:AddChanceLoot("beefalowool",    0.5)
		inst.components.lootdropper:AddChanceLoot("horn",    0.5)
		inst.components.lootdropper:AddChanceLoot("poop",    0.5)
		end
		if inst.size == 3 then
		creature = "mossling"
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("drumstick",    1.00)
		inst.components.lootdropper:AddChanceLoot("goose_feather",    1.00)
		inst.components.lootdropper:AddChanceLoot("goose_feather",    1.00)
		end
		if inst.size == 4 then
		creature = "pigman"
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("pigskin",    1.00)
		inst.components.lootdropper:AddChanceLoot("tophat",    1.00)
		end
		if inst.size == 5 then
		creature = "bunnyman"
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("carrot",    1.00)
		inst.components.lootdropper:AddChanceLoot("carrot",    1.00)
		inst.components.lootdropper:AddChanceLoot("manrabbit_tail",    1.00)
		inst.components.lootdropper:AddChanceLoot("manrabbit_tail",    0.5)
		end
		if inst.size == 6 then
		creature = "koalefant_summer"
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("poop",    1.00)
		inst.components.lootdropper:AddChanceLoot("poop",    0.5)
		inst.components.lootdropper:AddChanceLoot("phlegm",    0.5)
		end
		if inst.size == 7 then
		creature = "little_walrus"
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("earmuffshat",    1.00)
		inst.components.lootdropper:AddChanceLoot("bluegem",    1.00)
		end
		if inst.size == 8 then
		creature = "tallbird"
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("smallmeat",    0.5)
		inst.components.lootdropper:AddChanceLoot("tallbirdegg",    1.00)
		inst.components.lootdropper:AddChanceLoot("cutgrass",    1.00)
		inst.components.lootdropper:AddChanceLoot("cutgrass",    0.5)
		inst.components.lootdropper:AddChanceLoot("twigs",    1.00)
		inst.components.lootdropper:AddChanceLoot("twigs",    0.5)
		end
		if inst.size == 9 then
		creature = "spiderqueen"
		end
		if inst.size == 10 then
		creature = "warg"
		inst.components.lootdropper:AddChanceLoot("monstermeat",    1.00)
		inst.components.lootdropper:AddChanceLoot("monstersmallmeat",    0.5)
		inst.components.lootdropper:AddChanceLoot("houndstooth",    1.00)
		inst.components.lootdropper:AddChanceLoot("houndstooth",    0.5)
		inst.components.lootdropper:AddChanceLoot("boneshard",    1.00)
		inst.components.lootdropper:AddChanceLoot("boneshard",    0.5)
		inst.components.lootdropper:AddChanceLoot("bluegem",    0.5)
		inst.components.lootdropper:AddChanceLoot("redgem",    0.5)
		end
		if inst.size == 11 then
		creature = "krampus"
		inst.components.lootdropper:AddChanceLoot("monstermeat",    1.00)
		inst.components.lootdropper:AddChanceLoot("monstersmallmeat",    0.5)
		inst.components.lootdropper:AddChanceLoot("charcoal",    1.00)
		inst.components.lootdropper:AddChanceLoot("charcoal",    0.5)
		inst.components.lootdropper:AddChanceLoot("boneshard",    1.00)
		inst.components.lootdropper:AddChanceLoot("krampus_sack",    0.05)
		inst.components.lootdropper:AddChanceLoot("bluegem",    0.5)
		inst.components.lootdropper:AddChanceLoot("redgem",    0.5)
		end
		if inst.size == 12 then
		creature = "walrus"
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("meat",   0.5)
		inst.components.lootdropper:AddChanceLoot("blowdart_pipe",    0.5)
		end
		if inst.size == 13 then
		creature = "bishop"
		inst.components.lootdropper:AddChanceLoot("trinket_6",    1.00)
		end
		if inst.size == 14 then
		creature = "spat"
		inst.components.lootdropper:AddChanceLoot("meat",    1.00)
		inst.components.lootdropper:AddChanceLoot("meat",    0.5)
		inst.components.lootdropper:AddChanceLoot("steelwool",    1.00)
		inst.components.lootdropper:AddChanceLoot("steelwool",    0.5)
		inst.components.lootdropper:AddChanceLoot("phlegm",    1.00)
		end	
	
		inst.components.lootdropper:DropLoot()
	--[[if creature ~= nil and not creature == "spiderqueen" then
		inst.components.lootdropper:SetChanceLootTable('webbedcreature_'..creature)
	end]]
	
    local deadcreature = SpawnPrefab(creature)
	deadcreature.Transform:SetPosition(x, y, z)
	if creature == "spiderqueen" then
	deadcreature:AddTag("nodecomposepls")
	end
	deadcreature.components.health:Kill()
	else
    local deadcreature = SpawnPrefab("pigman")
	deadcreature.Transform:SetPosition(x, y, z)
	deadcreature.components.health:Kill()
	end
	local spawner = SpawnPrefab("webbedcreaturespawner")
	spawner.Transform:SetPosition(x, y, z)
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spidernest_LP", "loop")
end

local function OnEntitySleep(inst)
	inst.SoundEmitter:KillSound("loop")
end

local function onsave(inst,data)
if inst.size ~= nil then
data.size = inst.size
else
data.size = math.random(1,14)
end
end
local function onload(inst,data)
if data and data.size ~= nil then
inst.size = data.size
else
inst.size = math.random(1,14)
end
end
local function SetSize(inst)
if inst.size == 1 then   --No Eyed Deer
SetMedium(inst)
end
if inst.size == 2 then   --Beefalo
SetLarge(inst)
end
if inst.size == 3 then   --Mossling
SetMedium(inst)
end
if inst.size == 4 then   --Pigman
SetSmall(inst)
end
if inst.size == 5 then   --Bunnyman
SetSmall(inst)
end
if inst.size == 6 then   --koalefant
SetLarge(inst)
end
if inst.size == 7 then   --wee mactusk
SetSmall(inst)
end
if inst.size == 8 then   --Tallbird
SetMedium(inst)
end
if inst.size == 9 then   --SpiderQueen
SetLarge(inst)
end
if inst.size == 10 then   --Varg
SetLarge(inst)
end
if inst.size == 11 then   --Krampus
SetMedium(inst)
end
if inst.size == 12 then   --Mactusk
SetMedium(inst)
end
if inst.size == 13 then   --Clockwork Knight
SetSmall(inst)
end
if inst.size == 14 then   --Ewecus
SetLarge(inst)
end
end

local function Regen(inst, attacker)
    if not inst.components.health:IsDead() then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_hit")
        inst.AnimState:PlayAnimation(inst.anims.hit)
        inst.AnimState:PushAnimation(inst.anims.idle)
		if attacker:HasTag("widowsgrasp") then
		inst.components.health:Kill()
		elseif attacker:HasTag("player") and not attacker:HasTag("mime") and not attacker:HasTag("widowsgrasp") then
 		attacker.components.talker:Say(GetString(attacker.prefab, "WEBBEDCREATURE"))  
		end
	end
end
local function fn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		inst.entity:AddSoundEmitter()


		--MakeObstaclePhysics(inst, .5)


		inst.AnimState:SetBank("spider_cocoon")
		inst.AnimState:SetBuild("spider_cocoon")
		inst.AnimState:PlayAnimation("cocoon_small", true)
		
		inst:AddTag("structure")
		inst:AddTag("webbedcreature")
		inst:AddTag("noauradamage")
		--inst:AddTag("notarget")
		inst:AddTag("prey")
		inst:AddTag("houndfriend")
		inst:AddTag("antlion_sinkhole_blocker")
		
		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		-------------------
		inst:AddComponent("health")
		inst.components.health:SetMaxHealth(1000000)
		inst.components.health.absorb = 1
		--inst.components.health.invincible = true
		inst:AddComponent("combat")       
        inst.components.combat:SetOnHit(Regen)
		inst:ListenForEvent("death", OnKilled)
		
		inst:AddComponent("lootdropper")
		
		MakeLargePropagator(inst)

		inst:AddComponent("inspectable")
		inst:DoTaskInTime(0,SetSize)
		MakeSnowCovered(inst)
		inst.OnSave = onsave
		inst.OnLoad = onload
		inst.OnEntitySleep = OnEntitySleep
		inst.OnEntityWake = OnEntityWake
		inst.size = math.random(1,14)
		return inst
end


	

return Prefab( "webbedcreature", fn, assets, prefabs )

