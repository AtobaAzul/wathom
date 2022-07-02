local env = env
GLOBAL.setfenv(1, GLOBAL)
-----------------------------------------------------------------
--Not sure how I'd do this without overwriting
env.AddComponentPostInit("boatleak", function(self)
    function self:SetState(state, skip_open)
        if state == self.current_state then return end

        local anim_state = self.inst.AnimState
    
        if state == "small_leak" then
            self.inst:RemoveTag("boat_repaired_patch")
            self.inst:AddTag("boat_leak")
    
            anim_state:SetBuild(self.leak_build)
            anim_state:SetBankAndPlayAnimation("boat_leak", "leak_small_pre")
            anim_state:PushAnimation("leak_small_loop", true)
            anim_state:SetSortOrder(0)
            anim_state:SetOrientation(ANIM_ORIENTATION.BillBoard)
            anim_state:SetLayer(LAYER_WORLD)
            if skip_open then
                anim_state:SetTime(11 * FRAMES)
            end
    
            self.inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/fountain_small_LP", "small_leak")
    
            self.has_leaks = true
    
            if self.onsprungleak ~= nil then
                self.onsprungleak(self.inst, state)
            end
        elseif state == "med_leak" then
            self.inst:RemoveTag("boat_repaired_patch")
            self.inst:AddTag("boat_leak")
    
            anim_state:SetBuild(self.leak_build)
            anim_state:SetBankAndPlayAnimation("boat_leak", "leak_med_pre")
            anim_state:PushAnimation("leak_med_loop", true)
            anim_state:SetSortOrder(0)
            anim_state:SetOrientation(ANIM_ORIENTATION.BillBoard)
            anim_state:SetLayer(LAYER_WORLD)
            if skip_open then
                anim_state:SetTime(11 * FRAMES)
            end
    
            self.inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/fountain_medium_LP", "med_leak")
    
            if not self.has_leaks then
                self.has_leaks = true
    
                if self.onsprungleak ~= nil then
                    self.onsprungleak(self.inst, state)
                end
            end
        elseif state == "repaired" then
            self:ChangeToRepaired("boat_repair_build")
        elseif state == "repaired_tape" then
            self:ChangeToRepaired("boat_repair_tape_build")
        elseif state == "repaired_treegrowth" then
            self:ChangeToRepaired("treegrowthsolution","waterlogged2/common/repairgoop")
            self.inst.AnimState:SetBankAndPlayAnimation("treegrowthsolution", "pre_idle")
            self.inst:ListenForEvent("animover", function()
                if self.inst.AnimState:IsCurrentAnimation("pre_idle") then
                    self.inst.AnimState:PlayAnimation("idle")
                elseif self.inst.AnimState:IsCurrentAnimation("idle") then
                    self.inst:Remove()
                end
            end)
        elseif state == "repaired_sludge" then
            self:ChangeToRepaired("treegrowthsolution","waterlogged2/common/repairgoop")
            self.inst.AnimState:SetBankAndPlayAnimation("treegrowthsolution", "pre_idle")
            self.inst.AnimState:SetMultColour(100,200,0, 1)
            self.inst:ListenForEvent("animover", function()
                if self.inst.AnimState:IsCurrentAnimation("pre_idle") then
                    self.inst.AnimState:PlayAnimation("idle")
                elseif self.inst.AnimState:IsCurrentAnimation("idle") then
                    self.inst:Remove()
                end
            end)
        end
        self.current_state = state
    end
end)
