local Adrenaline = Class(function(self, inst)
    self.inst = inst

    if TheWorld.ismastersim then
        self.classified = inst.player_classified
    elseif self.classified == nil and inst.player_classified ~= nil then
        self:AttachClassified(inst.player_classified)
    end
end)

--------------------------------------------------------------------------

function Adrenaline:OnRemoveFromEntity()
    if self.classified ~= nil then
        if TheWorld.ismastersim then
            self.classified = nil
        else
            self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
            self:DetachClassified()
        end
    end
end

Adrenaline.OnRemoveEntity = Adrenaline.OnRemoveFromEntity

function Adrenaline:AttachClassified(classified)
    self.classified = classified
    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
end

function Adrenaline:DetachClassified()
    self.classified = nil
    self.ondetachclassified = nil
end

--------------------------------------------------------------------------

function Adrenaline:SetCurrent(current)
    if self.classified ~= nil then
        self.classified:SetValue("currentadrenaline", current)
    end
end

function Adrenaline:SetMax(max)
    if self.classified ~= nil then
        self.classified:SetValue("maxadrenaline", max)
    end
end

function Adrenaline:Max()
    return 100
end

function Adrenaline:GetPercent()
    if self.inst.components.adrenaline ~= nil then
        return self.inst.components.adrenaline:GetPercent()
    elseif self.classified ~= nil then
        return self.classified.currentadrenaline:value() / self.classified.maxadrenaline:value()
    else
        return 1
    end
end

function Adrenaline:GetCurrent()
    if self.inst.components.adrenaline ~= nil then
        return self.inst.components.adrenaline.current
    elseif self.classified ~= nil then
        return self.classified.currentadrenaline:value()
    else
        return 100
    end
end

function Adrenaline:IsAmped()
    return self.classified ~= nil and self.classified.isamped:value() or self.inst:HasTag("amped")
end

function Adrenaline:SetAmped(isamped)
    print("SETAMPED!!!")
    if self.classified ~= nil and self.classified.isamped ~= nil then
        self.classified.isamped:set(isamped)
    end
    if isamped then
        print("pushing event! starting music")
        self.classified:PushEvent("wathommusic_start")
        self.inst.player_classified:PushEvent("wathommusic_start")
        self.inst:PushEvent("wathommusic_start")
    else
        print("pushing event! stopping music")
        self.classified:PushEvent("wathommusic_end")
        self.inst.player_classified:PushEvent("wathommusic_end")
        self.inst:PushEvent("wathommusic_end")
    end
end



return Adrenaline
