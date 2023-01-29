local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------

local function onkilledbyother(inst, attacker)
    if attacker ~= nil and attacker.components.sanity ~= nil then
        attacker.components.sanity:DoDelta(-33)
    end
end

env.AddPrefabPostInit("gestalt_guard", function(inst)
	if not TheWorld.ismastersim then
		return
	end
	
    if inst.components.health ~= nil then
        inst.components.health:SetMaxHealth(400)
    end
	
	inst.components.combat:SetDefaultDamage(40)
	inst.components.combat:SetAttackPeriod(0.2)
end)