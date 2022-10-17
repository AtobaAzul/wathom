function c_setadrenaline(p)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.components.adrenaline ~= nil then
        player.components.adrenaline:SetPercent(p)
    end
end