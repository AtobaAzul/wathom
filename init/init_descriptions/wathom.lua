	-- Wilson's speech file
-- The strings here are also used when other characters are missing a line
-- If you've added an object to the mod, this is where to add placeholder strings
-- Keep things organized
GLOBAL.STRINGS.CHARACTERS.WATHOM = require "speech_wathom"

ANNOUNCE = GLOBAL.STRINGS.CHARACTERS.WATHOM
DESCRIBE = GLOBAL.STRINGS.CHARACTERS.WATHOM.DESCRIBE
ACTIONFAIL = GLOBAL.STRINGS.CHARACTERS.WATHOM.ACTIONFAIL

--	[ 		Wathom Descriptions		]   --
	DESCRIBE.WATHOM =
        {
            GENERIC = "%s, meaning? Maker's replacement?",
            ATTACKER = "%s, self-sabotaging.",
            MURDERER = "Goals, jeapordized. %s, role challenged!",
            REVIVER = "Against us, nothing better.",
            GHOST = "Unsettled. Superiority, proven?",
            FIRESTARTER = "%s, flames. Answers.",
        }		
