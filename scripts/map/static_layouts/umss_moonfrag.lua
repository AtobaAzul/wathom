--a simple template static layout wihout anything for umss
--this is for when countprefabs is not ideal.

return {
    version = "1.1",
    luaversion = "5.1",
    orientation = "orthogonal",
    width = 8,
    height = 8,
    tilewidth = 64,
    tileheight = 64,
    properties = {},
    tilesets = {
      {
        name = "ground",
        firstgid = 1,
        filename = "E:/Klei/DST_Feature/tools/tiled/dont_starve/ground.tsx",
        tilewidth = 64,
        tileheight = 64,
        spacing = 0,
        margin = 0,
        image = "E:/Klei/DST_Feature/tools/tiled/dont_starve/tiles.png",
        imagewidth = 512,
        imageheight = 384,
        properties = {},
        tiles = {}
      }
    },
    layers = {
      {
        type = "tilelayer",
        name = "BG_TILES",
        x = 0,
        y = 0,
        width = 8,
        height = 8,
        visible = true,
        opacity = 1,
        properties = {},
        encoding = "lua",
        data = {
          34, 0,  0,  0,  0,  0,  34, 34,
          0,  34, 34, 0,  0,  0,  0,  34,
          0,  34, 0,  0,  0,  34, 0,  0,
          0,  0,  0,  34, 34, 34, 0,  0,
          0,  34, 34, 34, 34, 0,  0,  34,
          34, 34, 34, 34, 34, 0,  0,  34,
          0,  34, 34, 34, 34, 0,  0,  0,
          0,  34, 0,  0,  34, 34, 0,  0
        }
      },
      {
        type = "objectgroup",
        name = "FG_OBJECTS",
        visible = true,
        opacity = 1,
        properties = {},
        objects = {
          {
            name = "",
            type = "umss_moonfrag",
            shape = "rectangle",
            x = 256,
            y = 256,
            width = 0,
            height = 0,
            visible = true,
            properties = {}
          },
        }
      }
    }
  }