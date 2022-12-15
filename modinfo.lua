name = "[DEV] Wathom"
description =
[[
HOLY FUCKING SHIT IT'S WATHOM]]

author = "󰀈 The Uncomp Dev Team 󰀈"

version = "1"

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

server_filter_tags = {
	"uncompromising",
	"wathom",
	"collab",
	"overhaul",
	"hard",
	"difficult",
	"madness",
	"challenge",
	"hardcore"
}

priority = -10

------------------------------
-- local functions to makes things prettier
local function BinaryConfig(name, label, hover, default)
    return { name = name, label = label, hover = hover, options = { {description = "Enabled", data = true, hover = "Enabled."}, {description = "Disabled", data = false, hover = "Disabled."}, }, default = default, }
end
------------------------------

configuration_options =
{
	BinaryConfig("wathom_maxdmg", "Wathom: Damage Cap", "Wathom's damage is capped at 600 to limit his absurd burst damage potential.", true),
	{
		name = "wathom_ampvulnerability",
		label = "Amped Vulnerability",
		hover = "Wathom takes more damage when amped.",
		options =
		{
			{description = "5x (Default)", data = 5},
			{description = "4x", data = 4},
			{description = "3x", data = 3},
			{description = "2x", data = 2},
		},
		default = 5,
	},
	{
		name = "wathom_armordamage",
		label = "Armor Damage Priority",
		hover = "Wathom can take increased damage, choose if armor damage is ignored.",
		options =
		{
			{description = "Include Armor", data = true, hover = "Wathom multiplies incoming damage by the current damage multiplier."},
			{description = "Don't include armor", data = false, hover = "Wathom multiplies resulting damage by the current damage multiplier."},
		},
		default = true,
	},
}
