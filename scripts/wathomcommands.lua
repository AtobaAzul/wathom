function c_setadrenaline(p, target)
    local player = target ~= nil and AllPlayers[target] or ConsoleCommandPlayer()
    if player ~= nil and player.components.adrenaline ~= nil then
        player.components.adrenaline:SetPercent(p)
    end
end