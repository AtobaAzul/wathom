local require = GLOBAL.require

AddClassPostConstruct( "widgets/controls", function(self, inst)
	local ownr = self.owner
	if ownr == nil then return end
	
	if self.owner:HasTag("wathom") then
		local Wathom_Sonar = require "widgets/wathom_sonar"
		self.wathom_sonar = self:AddChild( Wathom_Sonar(self.owner) )
		self.wathom_sonar:MoveToBack()
	end
end)