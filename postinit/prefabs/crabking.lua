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
		local messagebottletreasures = require("messagebottletreasures_um")
		local red = inst.countgems(inst).red
		local blue = inst.countgems(inst).blue
		local purple = inst.countgems(inst).purple
		local yellow = inst.countgems(inst).yellow
		local orange = inst.countgems(inst).orange
		local green = inst.countgems(inst).green
		local opal = inst.countgems(inst).opal+1
		local pearl = inst.countgems(inst).pearl*3

		print("Count:")
		print("RED: "..red.."   ".."BLUE: "..blue.."   ".."PURPLE: "..purple)
		print("YELLOW: "..yellow.."   ".."ORANGE: "..orange.."   ".."GREEN: "..green)


		print("Chances:")
		print("RED: "..red.."0%".."   ".."BLUE: "..blue.."0%".."   ".."PURPLE: "..purple.."0%")
		print("YELLOW: "..yellow.."0%".."   ".."ORANGE: "..orange.."0%".."   ".."GREEN: "..green.."0%")

		if math.random(10) < red then
			print("congrats! you got a red chest!")
		end
		if math.random(10) < blue then
			print("congrats! you got a blue chest!")
		end
		if math.random(10) < purple then
			print("congrats! you got a purple chest!")
		end
		if math.random(5) < yellow then
			print("congrats! you got a yellow chest!")
		end
		if math.random(5) < orange then
			print("congrats! you got a orange chest!")
		end
		if math.random(5) < green then
			print("congrats! you got a green chest!")
		end
		if opal >= 1 then
			print("congrats! you got a rainbow chest!")
		end
	end)

	local DAMAGE_SCALE = 0.5
	local function OnCollide(inst, data)
		local boat_physics = data.other.components.boatphysics
		if boat_physics ~= nil then
			local hit_velocity = math.floor(math.abs(boat_physics:GetVelocity() * data.hit_dot_velocity) * DAMAGE_SCALE / boat_physics.max_velocity + 0.5)
			print(hit_velocity)
			if inst.components.health ~= nil then
				inst.components.health:DoDelta(-400*hit_velocity)
			end
		end
	end
	inst:ListenForEvent("on_collide", OnCollide)
end)