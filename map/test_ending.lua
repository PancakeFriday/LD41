return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "1.1.2",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 30,
  height = 14,
  tilewidth = 16,
  tileheight = 16,
  nextobjectid = 5,
  properties = {},
  tilesets = {
    {
      name = "main",
      firstgid = 1,
      filename = "main.tsx",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      image = "tilesheet.png",
      imagewidth = 320,
      imageheight = 500,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      terrains = {},
      tilecount = 620,
      tiles = {
        {
          id = 94,
          animation = {
            {
              tileid = 74,
              duration = 200
            },
            {
              tileid = 75,
              duration = 200
            },
            {
              tileid = 76,
              duration = 200
            },
            {
              tileid = 77,
              duration = 200
            },
            {
              tileid = 76,
              duration = 200
            },
            {
              tileid = 75,
              duration = 200
            }
          }
        },
        {
          id = 95,
          animation = {
            {
              tileid = 75,
              duration = 200
            },
            {
              tileid = 76,
              duration = 100
            },
            {
              tileid = 77,
              duration = 200
            },
            {
              tileid = 76,
              duration = 200
            },
            {
              tileid = 75,
              duration = 200
            },
            {
              tileid = 74,
              duration = 200
            }
          }
        },
        {
          id = 430,
          animation = {
            {
              tileid = 434,
              duration = 400
            },
            {
              tileid = 474,
              duration = 300
            },
            {
              tileid = 514,
              duration = 200
            },
            {
              tileid = 474,
              duration = 100
            }
          }
        },
        {
          id = 450,
          animation = {
            {
              tileid = 436,
              duration = 400
            },
            {
              tileid = 476,
              duration = 300
            },
            {
              tileid = 516,
              duration = 200
            },
            {
              tileid = 476,
              duration = 100
            }
          }
        },
        {
          id = 470,
          animation = {
            {
              tileid = 435,
              duration = 400
            },
            {
              tileid = 475,
              duration = 300
            },
            {
              tileid = 515,
              duration = 200
            },
            {
              tileid = 475,
              duration = 100
            }
          }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "for-test",
      x = 0,
      y = 0,
      width = 30,
      height = 14,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
      }
    },
    {
      type = "objectgroup",
      name = "Collisions",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 1,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 192,
          width = 480,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 3,
          name = "",
          type = "",
          shape = "rectangle",
          x = 256,
          y = 144,
          width = 32,
          height = 48,
          rotation = 0,
          visible = true,
          properties = {
            ["type"] = "ending"
          }
        }
      }
    },
    {
      type = "objectgroup",
      name = "Enemies",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 4,
          name = "cat",
          type = "",
          shape = "rectangle",
          x = 321,
          y = 184,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
