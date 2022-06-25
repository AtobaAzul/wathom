local env = env
GLOBAL.setfenv(1, GLOBAL)

env.AddComponentPostInit("fishingnet", function(self)
	local _OldCastNet = self.CastNet
	
	function self:CastNet(pos_x, pos_z, doer)
		if self.inst:HasTag("uncompromising_fishingnetvisualizer") then
			local visualizer = SpawnPrefab("uncompromising_fishingnetvisualizer")
			visualizer.components.fishingnetvisualizer:BeginCast(doer, pos_x, pos_z)
			visualizer.item = self.inst
			self.visualizer = visualizer

			return true
		else
			return _OldIsInsulated(self, pos_x, pos_z, doer)
		end
	end
end)