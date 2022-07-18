local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------
local normalsounds =
{
    attack = "dontstarve/bee/killerbee_attack",
    --attack = "dontstarve/creatures/together/bee_queen/beeguard/attack",
    buzz = "dontstarve/bee/bee_fly_LP",
    hit = "dontstarve/creatures/together/bee_queen/beeguard/hurt",
    death = "dontstarve/creatures/together/bee_queen/beeguard/death",
}

local function MortarAttack(inst)
	if not inst.sg:HasStateTag("mortar") then
		local target = FindEntity(inst,20^2,nil,{"_combat"},{"playerghost","bee"})
		if target then
			inst.stabtarget = target
			inst.sg:GoToState("flyup")
		else
			inst:DoTaskInTime(math.random(1,3),MortarAttack)
		end
	end
end


local function OnHitOther(inst,data)
	inst.stuckcount = 100
	local other = data.target
	if other ~= nil and other.components.inventory ~= nil and inst.armorcrunch and not (data.target.sg and data.target.sg:HasStateTag("shell")) then
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
	if inst.beeHolder ~= nil and inst.beeHolder:IsValid() and inst:GetDistanceSqToInst(inst.beeHolder) > 3 and not (inst.sg:HasStateTag("frozen") or inst.sg:HasStateTag("sleeping") or inst.sg:HasStateTag("attack")) and inst.components.health and not inst.components.health:IsDead()  then
		inst.sg:GoToState("rally_at_point")
	end
	if inst.beeHolder ~= nil and inst.beeHolder:IsValid() and inst:GetDistanceSqToInst(inst.beeHolder) < 3 and not (inst.sg:HasStateTag("frozen") or inst.sg:HasStateTag("sleeping") or inst.sg:HasStateTag("attack")) then
		local target = FindEntity(inst,TUNING.BEEGUARD_ATTACK_RANGE^2,nil,{"_combat"},{"playerghost","bee","beehive","wall"})
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
	if inst.components.locomotor.walkspeed ~= TUNING.BEEGUARD_SPEED then
        inst.AnimState:SetBuild("bee_guard_build")
        inst.components.locomotor.walkspeed = TUNING.BEEGUARD_SPEED
        inst.components.combat:SetDefaultDamage(TUNING.BEEGUARD_PUFFY_DAMAGE)
        inst.components.combat:SetAttackPeriod(TUNING.BEEGUARD_PUFFY_ATTACK_PERIOD)
        inst.sounds = normalsounds
        if inst.SoundEmitter:PlayingSound("buzz") then
            inst.SoundEmitter:KillSound("buzz")
            inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
        end
        SpawnPrefab("bee_poof_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
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
	
	local _FocusTarget = inst.FocusTarget
	
	local function FocusTarget(inst,target)
		--TheNet:Announce("triedfocus")
		if inst.beeHolder == nil then
			--TheNet:Announce("nobeeHolder")
			_FocusTarget(inst,target)
		end
	end
	
	inst.FocusTarget = FocusTarget
	
end)
