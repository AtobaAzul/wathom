--------------------------------------------Define your prefab tables here, if you use the devcapture, check your log! it'll print it out there!
local testTable = {
	{x = 2, z = 2, prefab = "researchlab"},
	{x = -2, z = -2, prefab = "grass"},
}

local testTable2 = {
	{x = 2, z = 2, prefab = "evergreen"},
	{x = -2, z = -2, prefab = "pighouse"},
}

local moonOil= {{x = 2.3026733398438, z = -1.0947265625, prefab = "berrybush2", barren = true}, {x = 0.20166015625, z = 2.874267578125, prefab = "diseasecurebomb"}, {x = 0.12664794921875, z = -3.0437316894531, prefab = "berrybush2", barren = true}, {x = -2.5693359375, z = 2.8862609863281, prefab = "skeleton"}, {x = 2.6016540527344, z = -3.5547180175781, prefab = "berrybush2", barren = true}, {x = 4.4106750488281, z = -1.0917358398438, prefab = "berrybush2", barren = true}, {x = 1.545654296875, z = -5.4557189941406, prefab = "berrybush2", barren = true}, {x = 5.70166015625, z = -3.125732421875, prefab = "berrybush2", barren = true}, {x = 4.70166015625, z = -5.125732421875, prefab = "berrybush2", barren = true}}

local failedFisherman = {{x = 0.25729179382324, z = 0.0169677734375, prefab = "boat"}, {x = 0.26235771179199, z = 0.0379638671875, prefab = "oceanfishingrod"}, {x = -0.73764228820801, z = 0.0379638671875, prefab = "spoiled_fish_small"}, {x = 0.26235771179199, z = 1.0379638671875, prefab = "oar_driftwood"}, {x = -0.73764228820801, z = -0.9620361328125, prefab = "rainhat"}, {x = 1.262357711792, z = 0.0379638671875, prefab = "spoiled_fish"}, {x = 1.262357711792, z = -0.9620361328125, prefab = "oceanfishingbobber_crow"}, {x = 0.26235771179199, z = -1.9620361328125, prefab = "spoiled_fish_small"}, {x = -0.73764228820801, z = -1.9620361328125, prefab = "oceanfishinglure_spoon_blue"}, {x = -1.8909931182861, z = -1.2286071777344, prefab = "skeleton"}, {x = 1.762357711792, z = -1.4620361328125, prefab = "anchor"}, {x = 1.262357711792, z = 2.0379638671875, prefab = "steeringwheel"}, {x = -0.60257911682129, z = 2.4951782226563, prefab = "spoiled_fish"}, {x = -2.237642288208, z = 1.5379638671875, prefab = "fish_box"}, {x = -2.737642288208, z = 0.0379638671875, prefab = "reflectivevest"}, {x = 3.2787704467773, z = 0.67807006835938, prefab = "mast"}, {x = 2.0960941314697, z = -2.6328430175781, prefab = "spoiled_fish_small"},}

local tridentTrap = {{x = -0.11500549316406, z = 0.022003173828125, prefab = "boat"},{x = 0.082992553710938, z = -0.53201293945313, prefab = "skeleton"},{x = -2.5630035400391, z = -0.38201904296875, prefab = "trident"},{x = -1.9049987792969, z = -3.052001953125, prefab = "kelphat"},{x = -0.11500549316406, z = 3.9720153808594, prefab = "walkingplank"},{x = -5.0675048828125, z = -3.3525085449219, prefab = "waterplant"},{x = 5.9154357910156, z = -1.4754943847656, prefab = "kelpstack"},{x = 5.6349945068359, z = 5.0979919433594, prefab = "waterplant"},{x = -0.02606201171875, z = -8.1777648925781, prefab = "kelpstack"},{x = -5.6940002441406, z = -6.3179931640625, prefab = "waterplant"},{x = -8.6000061035156, z = -0.291015625, prefab = "waterplant"},{x = 7.7899932861328, z = -3.9909973144531, prefab = "waterplant"},{x = -5.8800048828125, z = 6.5719909667969, prefab = "waterplant"},{x = -9.2021789550781, z = 4.3088073730469, prefab = "kelpstack"},{x = -10.143005371094, z = -2.2720031738281, prefab = "waterplant"},{x = 10.478988647461, z = 0.014984130859375, prefab = "waterplant"},{x = 10.060989379883, z = 3.8970031738281, prefab = "kelpstack"},{x = 2.6760406494141, z = 10.781585693359, prefab = "waterplant"},{x = -4.1473693847656, z = 11.030029296875, prefab = "waterplant"},{x = 8.2198028564453, z = 12.277801513672, prefab = "kelpstack"},{x = -0.41177368164063, z = -15.673431396484, prefab = "waterplant"},{x = -17.333633422852, z = 4.5759887695313, prefab = "waterplant"},{x = 16.108764648438, z = 8.3994140625, prefab = "waterplant"}}

local demoTable = { 	{x = 0.75909423828125, z = -1.0461730957031, prefab = "log"}, 	{x = -0.3468017578125, z = -1.5800933837891, prefab = "log"}, 	{x = -0.52099609375, z = 1.6518249511719, prefab = "log"}, 	{x = -1.7550659179688, z = 0.57977294921875, prefab = "log"}, 	{x = 1.7808227539063, z = -1.3889923095703, prefab = "log"}, 	{x = -1.9171752929688, z = -1.6593780517578, prefab = "seastack"}, 	{x = 2.6639404296875, z = 0.544677734375, prefab = "log"}, 	{x = 0.17535400390625, z = -2.7806091308594, prefab = "log"}, 	{x = 1.5282592773438, z = 2.39404296875, prefab = "seastack"}, 	{x = -2.5726318359375, z = 1.4523315429688, prefab = "log"}, 	{x = -1.505126953125, z = 2.6280517578125, prefab = "log"}, 	{x = 0.27471923828125, z = 3.4244842529297, prefab = "log"}, 	{x = 3.203857421875, z = 1.6869049072266, prefab = "log"}, 	{x = 3.5248413085938, z = -0.87544250488281, prefab = "seastack"}, 	{x = -0.51788330078125, z = 3.9206237792969, prefab = "log"}, 	{x = 1.7034912109375, z = 3.7448883056641, prefab = "log"}, 	{x = -4.234619140625, z = 0.46084594726563, prefab = "seastack"}, 	{x = -3.4193725585938, z = 2.6381988525391, prefab = "log"}, 	{x = -2.8687744140625, z = 3.2518157958984, prefab = "log"}, 	{x = -2.4285888671875, z = 4.8321075439453, prefab = "seastack"}, 	{x = 3.6779174804688, z = 5.6669464111328, prefab = "splash"}, }

local returnedTable = { 	{x = 0.46360778808594, z = -0.46786499023438, prefab = "berrybush" },	{x = 0.2960205078125, z = 2.3464012145996, prefab = "berrybush" , barren = true},	{x = -2.6017761230469, z = -0.11078262329102, prefab = "grass" },	{x = 0.2960205078125, z = -2.6535987854004, prefab = "berrybush_juicy" , barren = true},	{x = 3.2960205078125, z = -0.65359878540039, prefab = "grass" , barren = true},	{x = -4.1174926757813, z = -0.54916763305664, prefab = "berrybush_juicy" },	{x = 2.2460174560547, z = -8.7035980224609, prefab = "green_mushroom" },	{x = 8.9960174560547, z = -3.9135971069336, prefab = "rabbithole" },}

--Place the next table above MEEEE^
--------------------------------------------
local function UncompromisingSpawnGOOOOO(inst,data)
	local x,y,z = inst.Transform:GetWorldPosition()
	local rotx = 1
	local rotz = 1
	
	if inst.rotatable == true then --This rotates the vvhole 
		if math.random() > 0.5 then
			rotx = -1
		end
		if math.random() > 0.5 then
			rotz = -1
		end
	end
	--TheNet:Announce("code ran") --For Troubleshooting
	for i,v in ipairs(data) do
		--TheNet:Announce(i) --For Troubleshooting
		--TheNet:Announce("Prefab: "..v.prefab) --For Troubleshooting
		local prefab = SpawnPrefab(v.prefab)
		prefab.Transform:SetPosition(x+v.x*rotx,(v.y and v.y+y) or 0,z+v.z*rotz)
		if v.diseased then
			--If vve ever add back acid rain I guess vve could have this, vvhatever
		end
		if v.barren and prefab.components.pickable then
			prefab.components.pickable:MakeBarren()
		end
		if v.withered and prefab.components.witherable then
			prefab.components.witherable:ForceWither()
		end
	end
end

local function superspawner(extension,data,rotatable)

	local function makefn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddNetwork()
		inst.entity:SetPristine()
			
		if not TheWorld.ismastersim then
			return inst
		end
		
		inst.spawnTable = data
		inst.rotatable = rotatable
		--TheNet:Announce("INIT") --For Troubleshooting
		inst:DoTaskInTime(0,
			function(inst)
				--TheNet:Announce("Code Ran") --For Troubleshooting
				UncompromisingSpawnGOOOOO(inst,inst.spawnTable)
				inst:Remove() 
			end)
		return inst
	end
	
	return Prefab("umss_"..extension, makefn)
end


--Version 1.0
-- Return your spavvners by filling out superspawner("extension", definedTable), 
--"extension" shovvs hovv your spavvner is named, definedTable is the table defined above at the top of the file
--The last paramater is vvhether or not you allovv rotation... setting it to true vvill mean the spavvner can also rotate the vvhole 
--preset before spavving about the center, setting it to false means it *ALVVAYS* spavvns at the same orientation.

--IMPORTANT NOTE: DO NOT USE CAMEL CASE FOR THE EXTENSION, FOR SOME REASON THE GAME VVOULD NOT CREATE PREFABS IN CAMEL CASE I HAVE NO IDEA VVHY IT'S ABSURD
--FYI CAMEL CASE EXAMPLES": "logCamp","oceanZone","seaGore","moonGut","moonFested",moonMavv","beMooned"
return superspawner("test1", returnedTable,true),
	superspawner("test2", testTable2,true),
	superspawner("demotable", demoTable,true),
	superspawner("moonoil", moonOil, true),
	superspawner("failedfisherman", failedFisherman, false),
	superspawner("tridenttrap", tridentTrap, true)--testing if rotating boats function properly!


