local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------
local UpvalueHacker = require("tools/upvaluehacker")

local function MortarAttack(inst)
	if inst.components.health and not inst.components.health:IsDead() and inst.components.combat and inst.components.combat.target then
		inst.stabtarget = inst.components.combat.target --This is actually the fallback, we want them to attack the closest target
		local x,y,z = inst.Transform:GetWorldPosition()
		local combat = TheSim:FindEntities(x,y,z,12,{"_combat"},{"playerghost","bee","epic"})
		if math.random() > 0.25 then --Occasionally make the bee just keep going after the intended player, EVEN IF they're not actually the closest option.
			for i,ent in ipairs(combat) do
			local distance = 1000000
				if (ent.components.combat and ent.components.combat.target) or ent:HasTag("player") then --Target is fighting nearby (or they are a player), try for the closest option
					if ent:GetDistanceSqToInst(inst) < distance then
						distance = ent:GetDistanceSqToInst(inst)
						inst.stabtarget = ent
					end
				end
			end
		end
		inst.sg:GoToState("flyup")
	end
end

env.AddPrefabPostInit("beeguard", function(inst)
	if not TheWorld.ismastersim then
		return
	end	
	inst.MortarAttack = MortarAttack
	--inst:DoTaskInTime(5,function(inst) inst:MortarAttack(inst) end) For testing purposes
end)
