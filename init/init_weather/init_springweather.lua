local env = env
GLOBAL.setfenv(1, GLOBAL)


env.AddPrefabPostInit("forest", function(inst)
    if not TheWorld.ismastersim then
        return
    end
	
	inst:AddComponent("UM_springweather")
	inst:AddComponent("UM_scorpionholes")
end)

env.AddPrefabPostInit("cave", function(inst)
    if not TheWorld.ismastersim then
        return
    end
	
	inst:AddComponent("UM_springweather")
	
end)

