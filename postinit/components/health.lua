local env = env
GLOBAL.setfenv(1, GLOBAL)

local function MayKill(self, amount)
	if self.currenthealth + amount <= 0 then
		return true
	end
end

env.AddComponentPostInit("health", function(self)
	if not TheWorld.ismastersim then return end

	local _DoDelta = self.DoDelta
	--(self:HasTag("wathom") and self:HasTag("amped")
	function self:DoDelta(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
		if MayKill(self, amount) and HasLLA(self) and self.inst:HasTag("deathamp") and cause == "deathamp" then
			if not self.inst:HasTag("playerghost") and self.inst.ToggleUndeathState ~= nil then
				self.inst:ToggleUndeathState(self.inst, false)
			end
			TriggerLLA(self) --Don't trigger the LLA here, let it happen in our ovvn component, so this doesn't break vvhenever canis moves it to his ovvn mod.
		elseif self.inst:HasTag("deathamp") and cause ~= "deathamp" then
			self.inst.components.adrenaline:DoDelta(amount*0.2)
		elseif MayKill(self, amount) and (self.inst:HasTag("wathom") and self.inst:HasTag("amped")) and cause ~= "deathamp" then --suggest that vve add a trigger here to shovv that vvathom is still being hit, despite his lack of flinching or anything.
			if not self.inst:HasTag("deathamp") then
				self.inst:AddTag("deathamp")
				self.inst:ToggleUndeathState(self.inst, true)
				_DoDelta(self, -self.currenthealth + 1, nil, nil, true) --needed to do this for ignore_invincible...
			end
		elseif not self.inst:HasTag("deathamp") then -- No positive healing if you're on your last breath
			_DoDelta(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
		end
	end
end)
