local require = GLOBAL.require

--	[ 	Import Prefabs, Assets, Widgets and Util	]	--
modimport("init/init_assets")

--  [   Mock Dragonfly Spit Bait ]    --

--  [  	Over Eating Nerf	     ]    --
--modimport("init/init_food/init_stuffed")
--Currently shelved due to hunger upvalue return error

--	[ 	Import Names and Descriptions	]	--
modimport("init/init_descriptions/generic")
modimport("init/init_descriptions/willow")
modimport("init/init_descriptions/wolfgang")
modimport("init/init_descriptions/wendy")
modimport("init/init_descriptions/wx78")
modimport("init/init_descriptions/wickerbottom")
modimport("init/init_descriptions/woodie")
modimport("init/init_descriptions/wes")
modimport("init/init_descriptions/waxwell")
modimport("init/init_descriptions/wathgrithr")
modimport("init/init_descriptions/webber")
modimport("init/init_descriptions/winona")
modimport("init/init_descriptions/wortox")
modimport("init/init_descriptions/wormwood")
modimport("init/init_descriptions/warly")
modimport("init/init_descriptions/wurt")
modimport("init/init_descriptions/walter")
modimport("init/init_descriptions/wanda")
modimport("init/init_descriptions/wathom")

--	[ 		Number Tuning and PostInits		]	--

modimport("init/init_tuning")
modimport("init/init_postinit")
modimport("init/init_strings")

require("wathomcommands")
