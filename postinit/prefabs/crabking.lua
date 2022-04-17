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
		local opalcount = 4 + inst.countgems(inst).opal
		local opalcount2 = (4 + inst.countgems(inst).opal)/2
		for i = 1, opalcount do
			print(opalcount)
			messagebottletreasures.GenerateTreasure(pos, "royal_sunkenchest").Transform:SetPosition(pos.x + math.random(-2, 2), pos.y, pos.z + math.random(-2, 2))
		end
		for i = 1, opalcount2 do
			print(opalcount2)
			messagebottletreasures.GenerateTreasure(pos, "sunkenchest").Transform:SetPosition(pos.x + math.random(-2, 2), pos.y, pos.z + math.random(-2, 2))
		end
	end)
end)