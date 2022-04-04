local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------

--Behold the mind of the sleep-deprived college student! (Don't push me till we know that klei doesn't change AG and mess this up, though I did make sure to do everything as compat friendly as possible, more than any other piece of work I've done before, for sure.)
local easing = require("easing")
local UpvalueHacker = require("tools/upvaluehacker")
local function CheckForceJump(inst,data) -- Secondary means to force the leap if for some reason the player isn't in a position for it to happen naturally
	if data.name == "forceleapattack" and inst.components.combat and inst.components.combat.target and inst.components.health and not inst.components.health:IsDead() then
		inst.forceleap = true
	elseif data.name == "forceleapattack" or not inst.components.timer:TimerExists("forceleapattack") then
		inst.components.timer:StartTimer("forceleapattack", math.random(30,45))
	end
	--This is actually the only way the belch happens
	if data.name == "forcebelch" and inst.components.combat and inst.components.combat.target and inst.components.health and not inst.components.health:IsDead() and inst.components.health:GetPercent() < 0.6 then
		inst.forcebelch = true
	elseif data.name == "forcebelch" or not inst.components.timer:TimerExists("forcebelch") then
		inst.components.timer:StartTimer("forcebelch", math.random(30,45))
	end
end


--[[
local function LaunchProjectile(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = (inst.Transform:GetRotation() + 90) * DEGREES
    local x1 = x + .1 * math.sin(angle)
    local z1 = z + .1 * math.cos(angle)	
	local goo = SpawnPrefab("guardian_goo")
	if inst.tentbelch == true then
		inst.tentbelch = false
		goo.tentacle = true
	end
    goo.Transform:SetPosition(x1, y+3, z1)
	goo.Transform:SetRotation(angle / DEGREES)
	goo._caster = inst
	
	Launch2(goo, inst, inst.projectilespeed, 2, 2, 3)--15+inst.projectilespeed^1.2)
end]]

local function ShootProjectile(inst)
	local target = inst.belchtarget
	if target ~= nil then
		local x, y, z = inst.Transform:GetWorldPosition()
		local projectile = SpawnPrefab("guardian_goo")
		if inst.tentbelch == true then
			inst.tentbelch = false
			projectile.tentacle = true
		end
		local targetpos = target:GetPosition()
		projectile.Transform:SetPosition(x, y, z)
		local a, b, c = target.Transform:GetWorldPosition()
		local targetpos = target:GetPosition()
		targetpos.x = targetpos.x + math.random(-4,4)
		targetpos.z = targetpos.z + math.random(-4,4)
		local dx = a - x
		local dz = c - z
		local rangesq = dx * dx + dz * dz
		local maxrange = 20
		local bigNum = 15
		local speed = easing.linear(rangesq, bigNum, 3, maxrange * maxrange * 2)
		projectile:AddTag("canthit")
		--projectile.components.wateryprotection.addwetness = TUNING.WATERBALLOON_ADD_WETNESS/2
		projectile.components.complexprojectile:SetHorizontalSpeed(speed+math.random(4,9))
		--projectile.components.complexprojectile:SetGravity(-25)
		projectile.components.complexprojectile:Launch(targetpos, inst, inst)
	end
end

env.AddPrefabPostInit("minotaur", function(inst)
	if not TheWorld.ismastersim then
		return
	end
	inst.forceleap = false
	inst.forcebelch = false
	inst.tentbelch = true
	inst.combo = 0
	inst.components.timer:StartTimer("forceleapattack", math.random(30,45))
	inst.components.timer:StartTimer("forcebelch", math.random(30,45))
	inst:ListenForEvent("timerdone", CheckForceJump)
	
	local _OnAttacked = UpvalueHacker.GetUpvalue(Prefabs.minotaur.fn, "OnAttacked")
	local function OnAttacked(inst, data)
		if not inst.sg:HasStateTag("newbuild") then
			_OnAttacked(inst,data)
		end
	end
	inst:RemoveEventCallback("attacked",_OnAttacked)
	UpvalueHacker.SetUpvalue(Prefabs.minotaur.fn, OnAttacked,"OnAttacked")
	
	inst:ListenForEvent("attacked",OnAttacked)
	
	inst.LaunchProjectile = ShootProjectile
end)
