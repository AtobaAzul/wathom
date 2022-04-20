local env = env
GLOBAL.setfenv(1, GLOBAL)

env.AddPrefabPostInit("crabking", function(inst)
	if not TheWorld.ismastersim then
		return
	end
	if TUNING.DSTU.VETCURSE ~= "off" then
		inst:AddComponent("vetcurselootdropper")
		inst.components.vetcurselootdropper.loot = "crabclaw"
	end
	inst.components.lootdropper:AddChanceLoot("dormant_rain_horn",1.00)
	--hoarder ck
	inst:ListenForEvent("death", function(inst)
		local pos = inst:GetPosition()
		local messagebottletreasures = require("messagebottletreasures")
		local red = inst.countgems(inst).red
		local blue = inst.countgems(inst).blue
		local purple = inst.countgems(inst).purple
		local yellow = inst.countgems(inst).yellow
		local orange = inst.countgems(inst).orange
		local green = inst.countgems(inst).green
		local opal = inst.countgems(inst).opal+1
		local pearl = inst.countgems(inst).pearl*3

		if red > 2 then
			red = 2
		end
		if blue > 2 then
			blue = 2
		end
		if purple > 2 then
			purple = 2
		end
		if yellow > 2 then
			yellow = 2
		end
		if orange > 2 then
			orange = 2
		end
		if green > 2 then
			green = 2
		end
		if opal > 2 then
			opal = 2
		end

		local royalcount = 3+(red + blue + purple + yellow + orange + green + pearl)*opal
		local normalcount = (1+(red + blue + purple + yellow + orange + green + pearl)*opal)
		local royalpos = royalcount*0.33
		local normalpos = normalcount*1.25

		print(royalcount)
		print(normalcount)
		for i = 1, royalcount do
			messagebottletreasures.GenerateTreasure(pos, "sunken_royalchest").Transform:SetPosition(pos.x + math.random(-royalpos, royalpos), pos.y, pos.z + math.random(-royalpos, royalpos))
		end
		for i = 1, normalcount do
			messagebottletreasures.GenerateTreasure(pos, "sunkenchest").Transform:SetPosition(pos.x + math.random(-normalpos, normalpos), pos.y, pos.z + math.random(-normalpos, normalpos))
		end
	end)
end)