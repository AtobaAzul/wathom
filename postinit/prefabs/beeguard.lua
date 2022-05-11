local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------
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

local function DefensiveTask(inst)
	if inst:GetDistanceSqToInst(inst.beeHolder) > 3 and not (inst.sg:HasStateTag("frozen") or inst.sg:HasStateTag("sleeping") or inst.sg:HasStateTag("attack")) and inst.components.health and not inst.components.health:IsDead()  then
		inst.sg:GoToState("rally_at_point")
	end
	if inst:GetDistanceSqToInst(inst.beeHolder) < 3 and not (inst.sg:HasStateTag("frozen") or inst.sg:HasStateTag("sleeping") or inst.sg:HasStateTag("attack")) then
		local target = FindEntity(inst,TUNING.BEEGUARD_ATTACK_RANGE^2,nil,{"_combat"},{"playerghost","bee","beehive"})
		if inst.components.combat and inst.components.health and not inst.components.health:IsDead() then
			if target then
				inst.components.combat:SuggestTarget(target)
				inst.sg:GoToState("defensiveattack")
			end
			if inst.components.combat.target then
				inst:ForceFacePoint(inst.components.combat.target.Transform:GetWorldPosition())
			end
		end
	end
end

local function BeeFree(inst)
	if inst.defensiveTask then
		inst.defensiveTask:Cancel()
		inst.defensiveTask = nil
	end
	inst.beeHolder = nil
	inst.rallyPoint = nil
	inst.chargePoint = nil
	inst.brain:Start()
	if inst.components.health and not inst.components.health:IsDead() then
		inst:DoTaskInTime(0,function(inst) inst.sg:GoToState("idle") end)
	end
	local x,y,z = inst.Transform:GetWorldPosition()
	inst.entity:SetParent(nil)
	inst.Transform:SetPosition(x,y,z)
end

local function BeeHold(inst)
	if inst.beeHolder then
		inst.defensiveTask = inst:DoPeriodicTask(FRAMES,DefensiveTask)
	end
end

local function IHaveDied(inst)
	if inst.beeHolder then
		inst.beeHolder.bee = nil
	end
end

env.AddPrefabPostInit("beeguard", function(inst)
	if not TheWorld.ismastersim then
		return
	end	
	inst.chargeSpeed = 15 --This is just the default value.
	inst.holding = false
	inst.MortarAttack = MortarAttack
	inst.BeeHold = BeeHold
	inst.BeeFree = BeeFree
	inst.armorcrunch = false
	inst:ListenForEvent("onhitother", OnHitOther)
	inst:ListenForEvent("ondeath",IHaveDied)
end)
