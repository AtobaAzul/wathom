-- this is responsible for selecting which biomes will be which, and ensuring the 3 sirens exist.
-- current idea I have for the biomes is this:
-- 6-9 biomes, 3 of which are active and the other are innactive
-- Inactive biomes are random, and do not contain the siren, and are year-round, but suffle around when sirens start existing.
-- relevant events (to listen in the area handler prefab):
-- generate_inactive
-- generate_main
-- clear

local types = {"siren_throne", "ocean_speaker", "siren_bird_nest"}

local AreaHandler = Class(function(self, inst)
    self.inst = inst
    self.sirens = {}
    self.handlers = {}

end, nil, {})

function AreaHandler:GetHandlers() return self.handlers end

function AreaHandler:GetSirens()
    print("GetSirens")
    if self.handlers ~= {} then
        for k, v in ipairs(self.handlers) do
            if v.sirenpoint ~= nil then
                table.insert(self.sirens, v.sirenpoint)
                TheNet:Announce("Getting all sirens... " .. v.sirenpoint)
            else
                TheNet:Announce("sirenpoint was nil!")
            end
        end
    end
    return self.sirens
end

-- inactive biomes are purely random.
function AreaHandler:GenerateInactiveBiomes()
    for k, v in ipairs(self.handlers) do
        if v.sirenpoint == nil then -- any area handlers without a siren.
            v:PushEvent("generate_inactive")
        end
    end
end

function AreaHandler:SelectMainBiomes()
    -- initial selection
    TheNet:Announce("SeletMainBiomes")
    -- TODO: make it randomize which biomes will be sirens!!

    if not table.contains(self.sirens, "siren_throne") then
        for k, v in pairs(self.handlers) do
            if v.sirenpoint == nil then
                v.sirenpoint = "siren_throne"
                v:PushEvent("generate_main")
                TheNet:Announce("no siren throne, selecting...")
                self:GetSirens()
                break
            end
        end
    end

    if not table.contains(self.sirens, "ocean_speaker") then
        for k, v in ipairs(self.handlers) do
            if v.sirenpoint == nil then
                v.sirenpoint = "ocean_speaker"
                v:PushEvent("generate_main")
                TheNet:Announce("no ocean speaker, selecting...")
                self:GetSirens()
                break
            end
        end
    end

    if not table.contains(self.sirens, "siren_bird_nest") then
        for k, v in ipairs(self.handlers) do
            if v.sirenpoint == nil then
                v.sirenpoint = "siren_bird_nest"
                v:PushEvent("generate_main")
                TheNet:Announce("no bird nest, selecting...")
                self:GetSirens()
                break
            end
        end
    end
end

function AreaHandler:Clear()
    for k, v in ipairs(self.handlers) do
        v.sirenpoint = nil
        v:PushEvent("clear")
    end
    self.sirens = {}
    -- self:GetSirens()
    TheNet:Announce("cleared sirens.")
end

-- Clears biomes, selects main biomes and then creates innactive biomes.
function AreaHandler:FullGenerate()
    self:Clear()
    self:SelectMainBiomes()
    self:GenerateInactiveBiomes()
end

return AreaHandler
