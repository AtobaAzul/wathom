local env = env
GLOBAL.setfenv(1, GLOBAL)

env.AddComponentPostInit("builder", function(self)
    local _UnlockRecipe = self.UnlockRecipe
	
	function self:UnlockRecipe(recname)
		local recipe = GetValidRecipe(recname)
		if self.inst:HasTag("wathom") and recipe ~= nil  then
			if self.inst.components.sanity ~= nil then
				self.inst.components.sanity:DoDelta(-TUNING.SANITY_MED)
			end
			
			self:AddRecipe(recname)
			self.inst:PushEvent("unlockrecipe", { recipe = recname })
		else
			return _UnlockRecipe(self, recname)
		end
    end
end)