STRINGS = GLOBAL.STRINGS
-- [              DSTU Related Overrides                  ]

STRINGS.DSTU = {
	ACID_PREFIX =
    {
        NONE = "",
        GENERIC = "Corroding",
        RABBITHOLE = "",
        CLOTHING = "Eroding",
        FUEL = "Caustic",
        TOOL = "Rusting",
        FOOD = "Sour",
        POUCH = "Deteriorating",
        WETGOOP = "Toxic",
    },

}

table.insert(GLOBAL.CHARACTER_GENDERS.FEMALE, "winky")

STRINGS.NAMES.WINKY = "Winky"
STRINGS.CHARACTER_TITLES.winky = "The Vile Vermin"
STRINGS.CHARACTER_NAMES.winky = "winky"
STRINGS.CHARACTER_DESCRIPTIONS.winky = "*Is a Rat\n*Can dig interconnected burrows\n*'Is weak, but fast'\n*Can eat horrible foods\n*Hates to lose hold of things"
STRINGS.CHARACTER_QUOTES.winky = "\"Squeak!\""

STRINGS.ACTIONS.CREATE_BURROW = "Make Burrow"
STRINGS.ACTIONS.ACTIVATE.RECRUITRAT = "Recruit A Rat"

STRINGS.ACTIONS.TURNOFF.HARPOON = "Break Reel"
STRINGS.ACTIONS.ACTIVATE.HARPOON = "Reel"
STRINGS.ACTIONS.CASTSPELL.HARPOON = "Throw Harpoon"

STRINGS.PIG_GUARD_PIGKING_TALK_LOOKATWILSON = { "NO SMASH HOUSES", "US WATCHING YOU", "BE GOOD HERE", "WATCHING YOU" }
STRINGS.PIG_GUARD_PIGKING_TALK_LOOKATWILSON_NIGHT = { "KING SLEEPING, YOU GO NOW", "YOU LEAVE NOW", "STAY AND WE GET MEAN", "KING NEED SLEEP, GO AWAY" }
STRINGS.PIG_GUARD_PIGKING_TALK_LOOKATWILSON_EVENING = { "KING BED TIME SOON, YOU GO NOW", "NO DISTURB KING SLEEP", "KING NEEDS BEAUTY SLEEP, GO", "NIGHT SOON, YOU LEAVE NOW" }
STRINGS.PIG_GUARD_PIGKING_TALK_LOOKATWILSON_FRIEND = { "KING SAY PROTECT", "PROTECT YOU", "WHERE MONSTERS?", "PROTECT!", "PROTECT KING!", "PROTECT FRIEND!" }

-- Hey look! I actually did something! -Canis
STRINGS.CHARACTER_DESCRIPTIONS.willow = STRINGS.CHARACTER_DESCRIPTIONS.willow.."\n󰀕Lighter lasts long on the right hands\n󰀕Can ignite things in the cold"
STRINGS.CHARACTER_DESCRIPTIONS.wx78 = STRINGS.CHARACTER_DESCRIPTIONS.wx78.."󰀕Systems are not repaired via lightning"
STRINGS.CHARACTER_DESCRIPTIONS.wickerbottom = STRINGS.CHARACTER_DESCRIPTIONS.wickerbottom.."\n󰀕Reading requires brainpower"
STRINGS.CHARACTER_DESCRIPTIONS.wes = STRINGS.CHARACTER_DESCRIPTIONS.wes.."\n󰀕Expanded inner dialogue" --"\n󰀕Pengulls are fond of mimes"
STRINGS.CHARACTER_DESCRIPTIONS.waxwell = STRINGS.CHARACTER_DESCRIPTIONS.waxwell.."\n󰀕Can summon his old puppets"
STRINGS.CHARACTER_DESCRIPTIONS.warly = STRINGS.CHARACTER_DESCRIPTIONS.warly.."\n󰀕Absorbs nutrients better, but prefers more variety"
STRINGS.CHARACTER_DESCRIPTIONS.winona = STRINGS.CHARACTER_DESCRIPTIONS.winona.."\n󰀕Works hard until lunch\n󰀕Generators are for workers only"

if GetModConfigData("wortox") == "UMNERF" then
	STRINGS.CHARACTER_DESCRIPTIONS.wortox = STRINGS.CHARACTER_DESCRIPTIONS.wortox.."\n󰀕Some weak creatures have no meaningful Soul \n󰀕Medium max health"
end

if GetModConfigData("wortox") == "SHOT" then
	STRINGS.CHARACTER_DESCRIPTIONS.wortox = STRINGS.CHARACTER_DESCRIPTIONS.wortox.."\n󰀕Souls take time to heal"
end

STRINGS.CHARACTER_DESCRIPTIONS.wathgrithr = STRINGS.CHARACTER_DESCRIPTIONS.wathgrithr.."\n󰀕Less passionate in combat"

if TUNING.DSTU.WORMWOOD_CONFIG_FIRE then
	STRINGS.CHARACTER_DESCRIPTIONS.wormwood = STRINGS.CHARACTER_DESCRIPTIONS.wormwood.."\n󰀕Is dangerously flammable"
end

STRINGS.UNCOMP_TOOLTIP = {
	AMULET = "- Only revives the player upon death while worn.\n- Increased heal rate at lower health.\n- Never breaks, can be refueled with Nightmare Fuel.",
	MINIFAN = "- Staves off heat, and hayfever.",
	ARMORRUINS = "- Prevents knockback effects.\n- Reduces insanity aura effects by 40%.",
	SWEATERVEST = "- Reduces insanity aura effects by 70%.",
	FEATHERFAN = "- Grants large amounts of Hayfever protection when blown.",
	PERDFAN = "- Grants large amounts of Hayfever protection when blown.",
	SKELETONHAT = "- Will not spawn the Creeping Fear when worn.",
	ICEPACK = "- Will not burn.",
	COOKIECUTTERHAT = "- Reflects 75% of damage taken back at attacker.",
	HAMBAT = "- Rots faster.\n- Can be eaten by certain mobs.",
	TOWNPORTAL = "- Gathers nearby items when channeling.",
	PUMPKIN_LANTERN = "- Has a positive sanity aura.",
	NIGHTLIGHT = "- Fuels itself at night by taking nearby players sanity.",
	ARMOR_SANITY = "- Reduced sanity drain on damage taken.",
	TOPHAT = "- Reduces sanity loss from various magic items.",
	MOONDIAL = "- Can become a source of water when a certain item is placed inside...",
	ARMORDRAGONFLY = "- Summons mini Lavae allies when worn.",
	GLASSCUTTER = "- Deals slightly more damage to Shadows.",
	FEATHERHAT = "- Provides safety from territorial Pengulls.",
	YELLOWAMULET = "- No longer breaks when empty.",
	ORANGEAMULET = "- No longer breaks when empty.\n- Can be fueled with Nightmare Fuel.\n- Will pick certain plants too!",
	PURPLEAMULET = "- Grants bonus Nightmare Fuel from slain Shadows.",
	PIGGYBACK = "- No Passive -10% movement speed while worn.\n- Decreases Player speed by 1% per item held.",

	PREMIUMWATERINGCAN = "- Can contain and preserve ocean fish.",
	RAINHAT = "- Slightly increased rain protection.",

	ARMORMARBLE = "- Prevents knockback effects.",
	TURF_DRAGONFLY = "- Prevents snowpile build-up.",
	BEEBOX = "- Reduced yield per stage.",
	BLOWDART_YELLOW = "- Stuns certain mechanical enemies.",
	DRAGONFLYCHEST = "- Has even more item slots.\n- May hurt would be thieves.",
	WARDROBE = "- Can store a lot of equipment.",

	--uncomp content
	RAT_WHIP = "- Stronger when well fed.",
	AIR_CONDITIONER = "- Can crush up Mushrooms for helpful stat clouds.",
	ANCIENT_AMULET_RED = "- Drops soul orbs when attacked, which will replenish lost health when picked up.",
	ARMOR_GLASSMAIL = "- Summons spinning Glass Shards when attacking enemies.\n- Loses shards when damage is taken.",
	HONEY_LOG = "- Provides protection from Hayfever. Mostly useful for other allies.",
	SALTPACK = "- Drops piles of salt, preventing buildup of Snow Piles.",
	SPOREPACK = "- Provides lots of storage space.\n- Rots food.",
	UM_BEAR_TRAP_EQUIPPABLE_TOOTH = "- Slows down anything it's attached to. Deployable and throwable.",
    UM_BEAR_TRAP_EQUIPPABLE_GOLD = "- Slows down anything it's attached to. Deployable and throwable.",
	WATERMELON_LANTERN = "- Has a positive sanity aura.",
	HAT_RATMASK = "- Finds rat burrows\n- Shows sources of unwanted attention.",
	SKULLCHEST_CHILD = "- Shares it's contents with other Skull Chests.",
	SNOWGOGGLES = "- Provides protection from Snow/Sand Storms",
}

local TOOLTIP = STRINGS.UNCOMP_TOOLTIP

if not TUNING.DSTU.ELECTRICALMISHAP then
	TOOLTIP.NIGHTSTICK = "- No longer breaks when empty.\n- Can be fueled by various electrical items, generators, and potatoes."
	TOOLTIP.BUGZAPPER = "- Deals bonus damage, and area damage to Insects.\n- Deals electrical damage.\n- Can be fueled by various electrical items, generators, and potatoes."
else
	TOOLTIP.NIGHTSTICK = "- No longer breaks when empty.\n- Functions as a portable lightning rod.\n- Regains fuel when struck by lightning or when charged at generators."
	TOOLTIP.BUGZAPPER = "- Deals bonus damage, and area damage to Insects.\n- Deals electrical damage.\n - Can be charged at generators."
end

if TUNING.DSTU.SEWING_KIT then
	TOOLTIP.SEWINGKIT = "- Doubled uses, but repairs less per use."
end

if TUNING.DSTU.FLINGO_SETTING == "Fuelmuncher" then
	TOOLTIP.FIRESUPPRESSOR = "- Drains fuel on each throw.\n- Increased maximum fuel."
elseif TUNING.DSTU.FLINGO_SETTING == "Waterballs" then
	TOOLTIP.FIRESUPPRESSOR = "- No longer freezes on hit."
end

if TUNING.DSTU.LONGPIG then
	TOOLTIP.REVIVER = "- Requires flesh from a dead survivor."
end

if TUNING.DSTU.EYEBRELLAREWORK == false then
	TOOLTIP.EYEBRELLAHAT = "- Reduced heat protection."
else
	TOOLTIP.EYEBRELLAHAT = "- Reduced heat protection.\n- Can't be sewn, but may be repaired."
end

if TUNING.DSTU.SNOWSTORMS then
	TOOLTIP.CAMPFIRE = "- Provides protection from Snow Storms."
	TOOLTIP.TORCH = "- Provides protection from Snow Storms."
	TOOLTIP.FIREPIT = "- Provides protection from Snow Storms."
	TOOLTIP.WALL_HAY_ITEM = "- Provides protection from Snow Storms."
	TOOLTIP.WALL_WOOD_ITEM = "- Provides protection from Snow Storms."
	TOOLTIP.WALL_STONE_ITEM = "- Provides protection from Snow Storms."
	TOOLTIP.WALL_RUINS_ITEM = "- Provides protection from Snow Storms."
	TOOLTIP.WALL_MOONROCK_ITEM = "- Provides protection from Snow Storms."
	TOOLTIP.YELLOWSTAFF = "- Dwarf Stars provide protection from Snow Storms."
	TOOLTIP.MOLEHAT = "- Grants protection against Snow Storms / Sand Storms when worn."
else
	TOOLTIP.MOLEHAT = "- Grants protection against Sand Storms when worn."
end

if TUNING.DSTU.HAYFEVER then
	TOOLTIP.GASMASK = "- Prevents Hayfever while worn.\n- Provides protection against spore clouds."
	TOOLTIP.PLAGUEMASK = "- Prevents Hayfever while worn.\n- Provides protection against spore clouds."
else
	TOOLTIP.GASMASK = "- Provides protection against spore clouds."
	TOOLTIP.PLAGUEMASK = "- Provides protection against spore clouds."
end

if TUNING.DSTU.GOTOBED then
	TOOLTIP.BEDROLL_STRAW = "- May restore maximum health."
	TOOLTIP.BEDROLL_FURRY = "- May restore maximum health."
	TOOLTIP.TENT = "- May restore maximum health."
	TOOLTIP.SIESTAHUT = "- A bit less efficient.\n- May restore maximum health."
else
	TOOLTIP.SIESTAHUT = "- A bit less efficient."
end

if TUNING.DSTU.SLEEPINGBUFF > 1 then
	TOOLTIP.BEDROLL_STRAW = TOOLTIP.BEDROLL_STRAW.."\n- Faster healing rate."
	TOOLTIP.BEDROLL_FURRY = TOOLTIP.BEDROLL_FURRY.."\n- Faster healing rate."
	TOOLTIP.TENT = TOOLTIP.TENT.."\n- Faster healing rate."
	TOOLTIP.SIESTAHUT = TOOLTIP.SIESTAHUT.."\n- Faster healing rate."
end

if TUNING.DSTU.POCKET_POWERTRIP ~= 0 then
	TOOLTIP.TRUNKVEST_SUMMER = "- Now has pockets!\n- Slightly increased rain protection."
	TOOLTIP.TRUNKVEST_WINTER = "- Now has pockets!"
	TOOLTIP.REFLECTIVEVEST = "- Now has pockets!"
end

if GetModConfigData("canedurability") then--is this modmain env.?
	TOOLTIP.CANE = "- Has durability, only drains when walking."
end

if TUNING.DSTU.WANDA_NERF then
	TOOLTIP.POCKETWATCH_WEAPON = "- Deals less damage against shadows."
	TOOLTIP.POCKETWATCH_REVIVE = "- Increased cooldown."
end

if TUNING.DSTU.INSUL_THERMALSTONE then
	TOOLTIP.HEATROCK = "- Reduced inherent insulation.\n- Inherits part of players insulation."
end

STRINGS.STANTON_GREET = {"Care to drink with the dead?", "How's about a drink?", "C'mon and drink with me."}
STRINGS.STANTON_GIVE = {"There ya go.", "The finest."}
STRINGS.STANTON_RULES = {"I only drink with one at a time."}
STRINGS.STANTON_GLOAT = {"Ha! I knew you were soft.", "Ha! You lose!"}

STRINGS.STANTON_POET1 = { "When it's six to midnight and the boney hand of death is nigh."}
STRINGS.STANTON_POET2 = { "You better drink your drink and shut your mouth."}
STRINGS.STANTON_POET3 = { "If you draw against his hand, you can never win." }
STRINGS.STANTON_POET4 = { "Go ahead… drink with the living dead." }
STRINGS.STANTON_POET5 = { "Drink with the living dead." }

--TIDDLER FRIENDLY MAN STRINGS BELOW--

STRINGS.CHARACTERS.GENERIC.DESCRIBE.SPEAKER_SPECTER = "This is making me feel under the weather..."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SPEAKER_RUSTED = "This is making me feel under the weather..."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SPEAKER_BRINE = "This is making me feel under the weather..."

for _, sound in pairs({"talk_LP", "talk_end"}) do
RemapSoundEvent( "dontstarve/characters/tiddle_stranger/"..sound, "tiddle_stranger/characters/tiddle_stranger/"..sound )
end

	STRINGS.TIDDLESTRANGER_RNE_IGNORED = {"...Guess you ain't interested.", "Nevermind, then.", "..."}
	STRINGS.NAMES.TIDDLESTRANGER_RNE = "Kind Stranger"
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.TIDDLESTRANGER_RNE = "He says a lot of nothing."
	STRINGS.CHARACTERS.WX78.DESCRIBE.TIDDLESTRANGER_RNE = "ERROR: UNKNOWN ENTITY"
	STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.TIDDLESTRANGER_RNE = "I wonder what lies beneath that mysterious garb."
	STRINGS.CHARACTERS.WAXWELL.DESCRIBE.TIDDLESTRANGER_RNE = "I don't remember that one."
	STRINGS.CHARACTERS.WENDY.DESCRIBE.TIDDLESTRANGER_RNE = "A guardian angel?"
	STRINGS.CHARACTERS.WILLOW.DESCRIBE.TIDDLESTRANGER_RNE = "Who the heck are you?"
	STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.TIDDLESTRANGER_RNE = "Is creepy strange man."
	STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.TIDDLESTRANGER_RNE = "An eerie prophet!"
	STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.TIDDLESTRANGER_RNE = "Helpy friend"
	STRINGS.CHARACTERS.WURT.DESCRIBE.TIDDLESTRANGER_RNE = "Flort. Stranger danger."
	STRINGS.CHARACTERS.WARLY.DESCRIBE.TIDDLESTRANGER_RNE = "Greetings, uh... I didn't get your name?"
	STRINGS.CHARACTERS.WORTOX.DESCRIBE.TIDDLESTRANGER_RNE = "Hyuyuyu! A trickster after my own heart!"
	STRINGS.CHARACTERS.WINONA.DESCRIBE.TIDDLESTRANGER_RNE = "Those shoulders don't seem practical."
	STRINGS.CHARACTERS.WOODIE.DESCRIBE.TIDDLESTRANGER_RNE = "I like your funny words, magic man."

	STRINGS.TIDDLESTRANGER_RNE_GREETING = {"Hey there, friend!", "Oh, hello there!", "Hey, friend!"}
	STRINGS.TIDDLESTRANGER_RNE_FAREWELL = {
	    {
        	"I spent a lot of time making these.",
        	"Finding all the materials wasn't easy.",
        	"...",
        	"So don't go losing it.",
	    },
	    {
        	"I'd suggest you keep a high flame going.",
        	"There's some dangerous stuff lurking in the dark.",
        	"...",
        	"Not sure where it all came from, to be honest.",
	    },
	    {
        	"Nights ain't as comfy as they used to be.",
        	"Strange occurances, creatures in the dark...",
        	"I'd keep my eyes and ears open, and a light by my side if I were you.",
	    },
	}
	STRINGS.TIDDLESTRANGER_RNE_ENDSPEECH = {"Try it on, and find out.", "I think it would look nice on you, so just try it on!", "No strings attached, just wear it!"}

	STRINGS.TIDDLESTRANGER_RNE_SCENARIO = {
	    METEOR = {
		"Stars sure are nice tonight.", "How 'bout a closer look?"
	    },
	    SPIDERS = {
		"How 'bout a little game?", "I got a nice little prize in it for ya.", "The rules are simple:", "You beat my pet, you get the prize!"
	    },
	    LIGHT = {
		"Allow me to shed some light on the situation!"
	    },
	}

	STRINGS.TIDDLESTRANGER_RNE_SCENARIO_END = {
	    METEOR = {
		"Woops! Too close.", "Sorry 'bout that."
	    },
	    SPIDERS = {
		"Oh. Ya did it.", "Well! Fair's fair.", "Hope ya enjoy it!", "Now I need to find a new pet..."
	    },
	    LIGHT = {
		"That's the best I got.", "Hope that helped, now."
	    },
	}

	STRINGS.TIDDLESTRANGER_RNE_SPIDERWON = {"Guess ya didn't have it in ya after all.", "Oops. I didn't think ya'd DIE.", "Now ain't that a darn shame."}

	STRINGS.TIDDLESTRANGER_RNE_DEFAULT = {
	    {
        	"I've been practicing arts and crafts lately.",
        	"I thought I'd make ya something...Nice.",
        	"What do they do?",
        	"...",
	    },
	    {
        	"You look like you could use a new face!",
        	"Lucky for you, I have several!",
        	"...Masks, that is.",
        	"Whats their purpose?",
        	"...",
    	    },
	    {
		"Ever wanted to start a collection?",
        	"Well I have just the thing!",
       	 	"Hand crafted masks! No curses, I promise.",
        	"...",
    	    },
	}

	STRINGS.TIDDLESTRANGER_RNE_BANTER = {
	    {
        	"I should be on that throne right now... oh, the things I'd make."
    	    },
	    {
        	"Don't ya have... things you need to do, friend?",
    	    },
	    {
        	"I appreciate the company an all, but this is gettin' a bit awkward.",
    	    },
	    {
        	"You just gonna stand there all day, friend?",
    	    },
	    {
        	"You just gonna stand there all day, friend?",
    	    },
	    {
        	"You're still here. Why are you still here?",
    	    },
	    {
        	"Wanna hear a joke?",
		"...",
        	"Ah...I forgot what it was.",
    	    },
	    {
        	"Me? I'm quite old, ya'know.",
        	"Not, like, ancient or anything. But... old.",
	    },
	    {
        	"So... ya like jazz?",
        	"Been too long since I seen a gig.",
    	    },
	    {
        	"I know many things, ya'know. Learned so much.",
        	"Understand how this world works...",
		"...but I can't understand why you're still here.",
    	    },
	    {
        	"Pst... can I interest you in some forbidden knowledge?",
		"I'm just kiddin' ya. That's MY knowledge.",
	    },
	}

	STRINGS.TIDDLESTRANGER_RNE_ADVICE = {
	    BUSY = {
        	"Oh. I see you're busy.",
        	"I'll just come back later.",
    	    },
	    HARBINGERS = {
        	"You're doin' great!",
        	"But this sickness ain't about to give up so easily.",
        	"Keep an ear out, ya hear me?",
		"Somethin's comin' your way...",
    	    },
	    KILLED = {
        	"You did it! You put them pests right in their place!",
        	"But they'll be back...",
        	"I'm sure you can handle 'em, though.",
		"Anyways, I just came around to congratulate you."
    	    },
	    MEDICINE = {
        	"You feeling alright? You don't look so good...",
        	"You'd better get that treated!",
        	"I heard somethin' about some misty swamp.",
		"Fellas lookin' for a cure I think.",
		"Maybe he could help...",
    	    },
	    REVIVER = {
        	"Look at you!",
		"A real asset to the team!",
		"They'd all be dead without you, ya'know.",
		"Keep up the good work!",
		"And don't let no one tell you what's what.",
		"You're better than those slackers."
    	    },
	    MURDERER = {
        	"You're rackin' up quite the headcount!",
        	"I ain't judgin' none. Honest.",
        	"Strong feasting on the weak;",
		"Dog eat dog world;",
		"Survival of the fittest;",
		"All that good stuff."
    	    },
	    CUREFOUND = {
        	"I hear ya found the cure!",
        	"Ain't that just dandy.",
        	"Shame it's in such limited supply, huh?",
		"I hear there's another source...",
    	    },
	}


