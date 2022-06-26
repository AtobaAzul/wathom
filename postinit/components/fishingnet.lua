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

env.AddComponentPostInit("fishingnetvisualizer", function(self)
	local _OldBeginOpening = self.BeginOpening
	
	function self:BeginOpening()
		if self.inst.item ~= nil then
			self.inst.item.netweight = 1
		end
	
		local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
		local fishies = TheSim:FindEntities(my_x,my_y,my_z, self.collect_radius, {"oceanfishable"})
		for k, v in pairs(fishies) do
			local fish = SpawnPrefab(v.prefab.."_inv")
			if self.inst.item ~= nil and v.components.weighable ~= nil then
				local minweight = v.components.weighable.min_weight
			
				if minweight < 100 then
					self.inst.item.netweight = self.inst.item.netweight + 2
				elseif minweight >= 100 and minweight < 200 then
					self.inst.item.netweight = self.inst.item.netweight + 4
				elseif minweight >= 200 then
					self.inst.item.netweight = self.inst.item.netweight + 6
				end
			end
			
			v:Remove()
			
			table.insert(self.captured_entities, fish)
			self.captured_entities_collect_distance[fish] = 0
		end
		
		return _OldBeginOpening(self)
	end
end)