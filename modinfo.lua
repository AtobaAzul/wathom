name = "Wathom, the Forgotten Parody"
description = [[
󰀔 [ Version 1.0.3.2 : "Standalone Release" ]

"A hunter with an uncontrollable surplus of energy, Wathom lives on after crawling out of the Abyss he was imprisoned in."

Wathom, the Forgotten Parody from 󰀕 Uncompromising Mode, is now available as a standalone mod!
*Apex Predator
*Gets amped up with adrenaline
*Causes animals to panic
*The faster he goes, the harder he falls

Wathom completely changes the core fundamentals of gameplay; As he gains more and more Adrenaline through combat, he runs faster, hits harder, and leaps further. However, all it could take is one hit to wreck your health meter. Are you ready for the personification of Risk and Reward?

󰀏 Note: Disable this mod if running Uncompromising mode, as you will run into issues. Enable Wathom through the config menu instead!
󰀏 Stay Up-to-Date on Wathom's development by joining Uncomp's Discord!

]]

author = "󰀈 The Uncomp Dev Team 󰀈"

version = "1.0.3.2"

forumthread = "/topic/111892-announcement-uncompromising-mode/"

api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
hamlet_compatible = false

forge_compatible = false

all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = { "wathom" }

priority = -10

------------------------------
-- local functions to makes things prettier
local function BinaryConfig(name, label, hover, default)
    return {
        name = name,
        label = label,
        hover = hover,
        options = {
            { description = "Enabled",  data = true,  hover = "Enabled." },
            { description = "Disabled", data = false, hover = "Disabled." }
        },
        default = default
    }
end
------------------------------

configuration_options = {
    BinaryConfig("wathom_maxdmg_", "Damage Cap",
        "Wathom's damage is capped at 600 to limit his absurd burst damage potential.",
        false), {
    name = "wathom_ampvulnerability",
    label = "Amped Vulnerability",
    hover = "Wathom takes more damage when amped.",
    options = {
        { description = "5x (Default)", data = 5 },
        { description = "4x",           data = 4 }, { description = "3x", data = 3 },
        { description = "2x", data = 2 }
    },
    default = 5
}, {
    name = "wathom_armordamage",
    label = "Armor Damage Priority",
    hover = "Wathom can take increased damage, choose if armor damage is ignored.",
    options = {
        {
            description = "Include Armor",
            data = true,
            hover = "Wathom multiplies incoming damage by the current damage multiplier."
        }, {
        description = "Don't include armor",
        data = false,
        hover = "Wathom multiplies resulting damage by the current damage multiplier."
    }
    },
    default = true
}
}
