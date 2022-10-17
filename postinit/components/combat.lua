local env = env
GLOBAL.setfenv(1, GLOBAL)

env.AddComponentPostInit("combat", function(self)
    if not TheWorld.ismastersim then return end

    local _GetAttacked = self.GetAttacked

    function self:GetAttacked(attacker, damage, weapon, stimuli, ...)
        if self.inst ~= nil and self.inst:HasTag("wathom") and self.inst.AmpDamageTakenModifier ~= nil and damage and (self.inst.components.rider ~= nil and not self.inst.components.rider:IsRiding() or self.inst.components.rider == nil) and TUNING.WATHOM.WATHOM_ARMOR_DAMAGE then
            -- Take extra damage
            damage = damage * self.inst.AmpDamageTakenModifier
            return _GetAttacked(self, attacker, damage, weapon, stimuli)
        elseif self.inst ~= nil and attacker ~= nil and attacker:HasTag("wathom") and TUNING.WATHOM.WATHOM_MAX_DAMAGE_CAP then
            if damage > 600 then
                damage = 600
            end
            return _GetAttacked(self, attacker, damage, weapon, stimuli, ...)
        else
            return _GetAttacked(self, attacker, damage, weapon, stimuli, ...)
        end
    end
end)