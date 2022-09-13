local function onmax(self, max)

    self.inst.counter_max:set(max)
end

local function oncurrent(self, current)

    self.inst.counter_current:set(current)
end

local AdrenalineCounter = Class(function(self, inst)
    self.inst = inst
    self.max = 100
    self.current = 25
    self.adrenalinecheck = 0

    self.inst:ListenForEvent("respawn", function(inst) self:OnRespawn() end)
end,
    nil,
    {
        max = onmax,
        current = oncurrent,
    })

function AdrenalineCounter:OnRespawn()
    local old = self.current
    self.current = 25

    self.inst:PushEvent("adrenalinedelta",
        { oldpercent = old / self.max, newpercent = self.current / self.max, overtime = overtime })
end

function AdrenalineCounter:OnSave()
    return { adrenaline = self.current }
end

function AdrenalineCounter:OnLoad(data)
    if data.adrenaline then
        self.current = data.adrenaline
        self:DoDelta(0)
    end
end

function AdrenalineCounter:GetDebugString()
    return string.format("%2.2f / %2.2f", self.current, self.max)
end

function AdrenalineCounter:DoDelta(delta, overtime)
    local old = self.current
    self.current = self.current + delta
    if self.current < 0 then
        self.current = 0
    elseif self.current > self.max then
        self.current = self.max
    end

    --    if self:GetPercent() <= 0.10 and self.pestilencecheck < 3 then
    --        self.inst.components.talker:Say("I must advance my cure immediately." , 3)
    --        self.pestilencecheck = 3
    --    elseif self:GetPercent() <= 0.33 and self.pestilencecheck < 2 then
    --        self.inst.components.talker:Say("I need a patient with human-like anatomy." , 3)
    --        self.pestilencecheck = 2
    --    elseif self:GetPercent() <= 0.5 and self.pestilencecheck < 1 then
    --        self.inst.components.talker:Say("The Pestilence grows stronger." , 3)
    --        self.pestilencecheck = 1
    --    end

    --    if self:GetPercent() > 0.5 then
    --        self.pestilencecheck = 0
    --    elseif self:GetPercent() > 0.33 then
    --        self.pestilencecheck = 1
    --    elseif self:GetPercent() > 0.10 then
    --        self.pestilencecheck = 2
    --    end

    if self:GetPercent() < 0.24 then
        --        self.inst.components.sanity.dapperness = -20 / 60
        if self.inst.components.grogginess ~= nil then
            self.inst.components.grogginess:AddGrogginess(0.5, 0)
        end
        --        local counterspeedmod = 1 / Remap(0, 1, 0, TUNING.MIN_GROGGY_SPEED_MOD, TUNING.MAX_GROGGY_SPEED_MOD)
        --        self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "countergrogginess", counterspeedmod)
    end

    self.inst:PushEvent("adrenalinedelta",
        { oldpercent = old / self.max, newpercent = self.current / self.max, overtime = overtime })
end

function AdrenalineCounter:GetPercent()
    return self.current / self.max
end

function AdrenalineCounter:GetCurrent()
    return self.current
end

function AdrenalineCounter:SetPercent(p)
    local old = self.current
    self.current = p * self.max
    self.inst:PushEvent("adrenalinedelta", { oldpercent = old / self.max, newpercent = p })
end

return AdrenalineCounter
