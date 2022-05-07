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


local function OnHitOther(inst,data)
	inst.stuckcount = 100
	local other = data.target
	if other ~= nil and other.components.inventory ~= nil and inst.armorcrunch == true and not (data.target.sg and data.target.sg:HasStateTag("shell")) then
		local helm = other.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		local chest = other.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		local hand = other.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if helm ~= nil and helm.components.armor ~= nil then
			helm.components.armor:TakeDamage(200)
		end
		if chest ~= nil and chest.components.armor ~= nil then
			chest.components.armor:TakeDamage(200)
		end
		if hand ~= nil and hand.components.armor ~= nil then
			hand.components.armor:TakeDamage(200)
		end
	end	
end


env.AddPrefabPostInit("beeguard", function(inst)
	if not TheWorld.ismastersim then
		return
	end	
	inst.chargeSpeed = 15 --This is just the default value.
	inst.holding = false
	inst.MortarAttack = MortarAttack
	inst.armorcrunch = false
	inst:ListenForEvent("onhitother", OnHitOther)
end)
