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

local tridentTrap = {{x = -0.11500549316406, z = 0.022003173828125, prefab = "boat"},{x = 0.082992553710938, z = -0.53201293945313, prefab = "skeleton"},{x = -2.5630035400391, z = -0.38201904296875, prefab = "trident"},{x = -1.9049987792969, z = -3.052001953125, prefab = "kelphat"},{x = -5.0675048828125, z = -3.3525085449219, prefab = "waterplant"},{x = 5.9154357910156, z = -1.4754943847656, prefab = "seastack"},{x = 5.6349945068359, z = 5.0979919433594, prefab = "waterplant"},{x = -0.02606201171875, z = -8.1777648925781, prefab = "seastack"},{x = -5.6940002441406, z = -6.3179931640625, prefab = "waterplant"},{x = -8.6000061035156, z = -0.291015625, prefab = "waterplant"},{x = 7.7899932861328, z = -3.9909973144531, prefab = "waterplant"},{x = -5.8800048828125, z = 6.5719909667969, prefab = "waterplant"},{x = -9.2021789550781, z = 4.3088073730469, prefab = "seastack"},{x = -10.143005371094, z = -2.2720031738281, prefab = "waterplant"},{x = 10.478988647461, z = 0.014984130859375, prefab = "waterplant"},{x = 10.060989379883, z = 3.8970031738281, prefab = "seastack"},{x = 2.6760406494141, z = 10.781585693359, prefab = "waterplant"},{x = -4.1473693847656, z = 11.030029296875, prefab = "waterplant"},{x = 8.2198028564453, z = 12.277801513672, prefab = "seastack"},{x = -0.41177368164063, z = -15.673431396484, prefab = "waterplant"},{x = -17.333633422852, z = 4.5759887695313, prefab = "waterplant"},{x = 16.108764648438, z = 8.3994140625, prefab = "waterplant"}}

local impactfulDiscovery = {{x = 0.65742111206055, z = 1.0276489257813, prefab = "armorgrass"},	{x = 1.5654220581055, z = 0.0556640625, prefab = "skeleton"},	{x = -0.34257888793945, z = 2.0276489257813, prefab = "wall_hay"},	{x = 0.90542030334473, z = -1.9273681640625, prefab = "cutstone"},	{x = 1.1044216156006, z = -2.0253295898438, prefab = "twigs"},	{x = 1.1014213562012, z = -2.0663452148438, prefab = "charcoal"},	{x = 1.7684211730957, z = -1.9203491210938, prefab = "twigs"},	{x = 1.3524208068848, z = -2.2423706054688, prefab = "cutstone"},	{x = 2.3867664337158, z = 1.4175415039063, prefab = "rocks"},	{x = 2.2564220428467, z = 1.8826293945313, prefab = "rocks"},	{x = 2.2004203796387, z = 1.9896240234375, prefab = "rocks"},	{x = -0.34257888793945, z = -2.9723510742188, prefab = "wall_hay"},	{x = 0.65742111206055, z = -2.9723510742188, prefab = "wall_hay"},	{x = 1.873420715332, z = -2.4243774414063, prefab = "charcoal"},	{x = 3.1004219055176, z = 0.1966552734375, prefab = "rock_moon"},	{x = 2.6574211120605, z = 3.0276489257813, prefab = "wall_hay"},	{x = 3.7427005767822, z = 1.4929809570313, prefab = "rocks"},	{x = 4.0204219818115, z = 1.888671875, prefab = "rocks"},	{x = 4.5804214477539, z = -1.9083251953125, prefab = "boards"},	{x = 4.6944217681885, z = 2.1366577148438, prefab = "rocks"},	{x = 4.6574211120605, z = -2.9723510742188, prefab = "wall_hay"},	{x = 5.6574211120605, z = -2.9723510742188, prefab = "wall_hay"},	{x = 6.6574211120605, z = -0.97235107421875, prefab = "wall_hay"},	{x = 6.6574211120605, z = -1.9723510742188, prefab = "wall_hay"},	{x = 6.6574211120605, z = -2.9723510742188, prefab = "wall_hay"},	{x = 6.6574211120605, z = 3.0276489257813, prefab = "wall_hay"},}
--funny reference to that one streamer.

local baseFrag_rattyStorage = {{x = 2.5805172920227, z = 0.28851318359375, prefab = "treasurechest"},	{x = 0.85051727294922, z = -2.9224853515625, prefab = "wardrobe"},	{x = 1.850549697876, z = 3.2639770507813, prefab = "uncompromising_ratburrow"},	{x = 3.784517288208, z = -0.760498046875, prefab = "treasurechest"},	{x = 3.8845171928406, z = 1.573486328125, prefab = "treasurechest"},	{x = 5.0455174446106, z = 0.489501953125, prefab = "treasurechest"},	{x = 5.2435173988342, z = 2.8895263671875, prefab = "treasurechest"},	{x = 4.4615173339844, z = -4.6304931640625, prefab = "fence"},	{x = 6.2955173254013, z = 1.7335205078125, prefab = "treasurechest"},	{x = 1.4615173339844, z = 6.3695068359375, prefab = "wall_wood"},	{x = 5.4615173339844, z = -3.6304931640625, prefab = "wall_wood"},	{x = 5.4615173339844, z = 4.3695068359375, prefab = "wall_wood"},	{x = 3.4615173339844, z = 6.3695068359375, prefab = "fence"},	{x = 6.4615173339844, z = 3.3695068359375, prefab = "wall_wood"},	{x = 7.4615173339844, z = 0.3695068359375, prefab = "wall_wood"},	{x = 7.4615173339844, z = -0.6304931640625, prefab = "wall_wood"},	{x = 7.4615173339844, z = 1.3695068359375, prefab = "wall_wood"},	{x = 7.4615173339844, z = -1.6304931640625, prefab = "wall_wood"},	{x = 7.4615173339844, z = 2.3695068359375, prefab = "wall_wood"},}	

local baseFrag_smellyKitchen = {{x = 0.6150016784668, z = -0.224853515625, prefab = "icebox"},	{x = 0.53242874145508, z = 1.4286499023438, prefab = "spoiled_food"},	{x = -1.3295230865479, z = -0.76336669921875, prefab = "spoiled_food"},	{x = -0.2314338684082, z = -1.6725463867188, prefab = "spoiled_food"},	{x = 2.3709182739258, z = -1.2103881835938, prefab = "spoiled_food"},	{x = 1.3190021514893, z = -2.3378295898438, prefab = "cookpot"},	{x = 2.9960021972656, z = -0.71282958984375, prefab = "pottedfern"},	{x = -3.0359973907471, z = 0.619140625, prefab = "pottedfern"},	{x = -0.2299976348877, z = -3.3738403320313, prefab = "endtable"},	{x = -2.4419975280762, z = -2.4668579101563, prefab = "meatrack"},}	

local sunkenboat = {{x = 0.19911193847656, z = -1.0543212890625, prefab = "silk"},	{x = 0.38343811035156, z = 1.3286743164063, prefab = "goggleshat"},	{x = -0.31075286865234, z = -1.7542114257813, prefab = "rope"},	{x = 2.1990814208984, z = -1.0543212890625, prefab = "silk"},	{x = 1.5685577392578, z = 2.0890502929688, prefab = "rope"},	{x = -2.6165618896484, z = -0.67132568359375, prefab = "driftwoodfishingrod"},	{x = 3.4628524780273, z = -0.2178955078125, prefab = "charcoal"},	{x = 1.9804992675781, z = -2.9429321289063, prefab = "boatfragment03"},	{x = 3.5671081542969, z = 0.10784912109375, prefab = "rope"},	{x = -1.8933792114258, z = 3.0784301757813, prefab = "boatfragment04"},	{x = -2.0137176513672, z = -3.0451049804688, prefab = "boatfragment03"},	{x = 0.23040008544922, z = -4.2789916992188, prefab = "boneshard"},	{x = 0.69646453857422, z = -4.405517578125, prefab = "driftwood_log"},	{x = 3.0724182128906, z = 3.4102783203125, prefab = "boatfragment05"},}	

local moonFrag = { 	{x = 3.0202503204346, z = 1.8474426269531, prefab = "moonglass_rock"},	{x = 1.7678489685059, z = -3.0692749023438, prefab = "moon_tree"},	{x = -3.9157600402832, z = -2.7070007324219, prefab = "moonglass_rock"},	{x = -2.8406887054443, z = -5.7943725585938, prefab = "moon_fissure"},	{x = -7.0915050506592, z = -4.1053466796875, prefab = "moon_tree"},	{x = 2.5261497497559, z = -8.7240905761719, prefab = "moonglass_rock"},	{x = -2.5967979431152, z = -9.6219482421875, prefab = "rock_moon"},	{x = -1.0841388702393, z = -10.568328857422, prefab = "moon_tree"},	{x = -9.4409008026123, z = -7.4185180664063, prefab = "moonglass_rock"},	{x = -11.776861190796, z = -5.6201477050781, prefab = "rock_moon"},	{x = 4.3876495361328, z = -12.802825927734, prefab = "rock_moon"},	{x = -9.9292316436768, z = 9.4710998535156, prefab = "moon_tree"},	{x = -8.6973972320557, z = -11.15869140625, prefab = "moon_tree"},	{x = 13.90517616272, z = 13.2392578125, prefab = "rock_avocado_bush"},}	
		--used with 
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
	superspawner("tridenttrap", tridentTrap, false),
	superspawner("impactfuldiscovery", impactfulDiscovery, true),
	superspawner("basefrag_rattystorage", baseFrag_rattyStorage, true),
	superspawner("basefrag_smellykitchen", baseFrag_smellyKitchen, true),
	superspawner("sunkenboat", sunkenboat, true),
	superspawner("moonfrag", moonFrag, false)