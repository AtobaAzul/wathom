local Widget = require "widgets/widget"
local Image = require "widgets/image"

local wathomOL =  Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "wathomOL")
    self:UpdateWhilePaused(false)
    self:SetClickable(false)

    self.bg = self:AddChild(Image("images/woodie.xml", "beaver_vision_OL.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)

    self:Hide()
	
	inst:WatchWorldState("isnight", function()
		inst:DoTaskInTime(TheWorld.state.isnight and 0 or 1, function(inst)
			if not TheWorld:HasTag("cave") then
				if TheWorld.state.isnight then
					self:TurnOn()
					self:Show()	
					print("OVERLAY WORKING")		
				else
					self:TurnOff()
					self:Hide()	
				end
			end
		end)
	end)	
	
	if TheWorld:HasTag("cave") or TheWorld.state.isnight then
		self:TurnOn()
		self:Show()	
		print("OVERLAY WORKING")		
	else
		self:TurnOff()
		self:Hide()		
	end	

end)

return wathomOL
