PrefabFiles = {
	"wathom_none"    
}

Assets = {
--	Asset("ANIM", "anim/wathom.zip"),
--	Asset("ANIM", "anim/ghost_wathom_build.zip"),    -- Commented out because the standalone mod doesn't load these and works fine.
	
    Asset( "IMAGE", "bigportraits/wathom.tex" ),
    Asset( "ATLAS", "bigportraits/wathom.xml" ),


    Asset( "IMAGE", "bigportraits/wathom_none.tex" ),
    Asset( "ATLAS", "bigportraits/wathom_none.xml" ),    


    Asset( "IMAGE", "images/saveslot_portraits/wathom.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/wathom.xml" ),


	Asset( "IMAGE", "images/names_wathom.tex" ),
    Asset( "ATLAS", "images/names_wathom.xml" ),    
}

local STRINGS = GLOBAL.STRINGS

STRINGS.NAMES.wathom = "Wathom"
STRINGS.SKIN_NAMES.wathom_none = "Wathom"
STRINGS.SKIN_DESCRIPTIONS.wathom_none = "An inadequate attempt to revive the ones who came before him."

STRINGS.CHARACTER_TITLES.wathom = "The Forgotten Parody"
STRINGS.CHARACTER_NAMES.wathom = "Wathom"
STRINGS.CHARACTER_DESCRIPTIONS.wathom = "*Apex Predator\n*Gets amped up with adrenaline\n*Causes animals to panic\n*The faster he goes, the harder he falls"
STRINGS.CHARACTER_QUOTES.wathom = "\"I HEAR YOU BREATHING.\""
STRINGS.CHARACTER_ABOUTME.wathom = "A hunter with an uncontrollable surplus of energy, Wathom lives on after crawling out of the Abyss he was imprisoned in."
STRINGS.CHARACTER_BIOS.wathom = {
 { title = "Birthday", desc = "January 20" },
 { title = "Favorite Food", desc = "Hardshell Tacos" },
 { title = "From the Abyss", desc = "The civilization that once occupied the ruins always piqued Maxwell's curiosity. Even he on the throne didnt know all the secrets buried within the Constant. Using dusted bones and nightmare fuel, the Shadow King breathed life into a mimic of the ancient race, with the purpose to understand those who came before them. \n \nWathom never knew anything other than dank caverns and pulsating ruins - and when he didn't provide the secrets that he was born to uncover, the only thing he knew from then on was the indefinite darkness of the Abyss, banished and forgotten. At least, until the fallen moon provided climbable cracks in the walls."},
}
STRINGS.CHARACTER_SURVIVABILITY.wathom = "Slim"

TUNING.WATHOM_HEALTH = 200
TUNING.WATHOM_HUNGER = 120
TUNING.WATHOM_SANITY = 120

AddModCharacter("winky", "FEMALE")
AddModCharacter("wathom", "MALE")
