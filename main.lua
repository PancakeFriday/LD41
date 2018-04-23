Object = require "classic"
lume = require "lume"
Animation = require "animation"
Vector = require "vector"

DEBUG = false

FONT = {}
for i=1,40 do
	table.insert(FONT, love.graphics.newFont("font/LektonCode/LektonCode-Regular.ttf", i))
	FONT[#FONT]:setFilter("nearest","nearest")
end

local Player = require "player"
local Menu = require "menu"
local Map = require "map"

love.graphics.setDefaultFilter("nearest","nearest")

function love.graphics.printUnscaled(...)
	local args = {...}
	love.graphics.push()
	local s = Map.camera:getScale()
	local px, py = Map.camera:getPosition()
	love.graphics.translate(-args[2]-px, -args[3]-py)
	love.graphics.scale(1/s, 1/s)
	love.graphics.translate((args[2]*s+px*s), (args[3]*s+py*s))
	args[2] = args[2]*s
	args[3] = args[3]*s
	love.graphics.print(unpack(args))
	love.graphics.pop()
end

function string.starts(String,Start)
	return string.sub(String,1,string.len(Start))==Start
	end

function string.ends(String,End)
	return End=='' or string.sub(String,-string.len(End))==End
end


function love.load()
	math.randomseed(os.time())
	Map.loaded = false
	Gamestate = "Menu"
end

function love.update(dt)
	if Gamestate == "Menu" then
		Menu:update(dt)
	elseif Gamestate == "Map" then
		if not Map.loaded then
			Map:loadLevel("map/level1.lua")
		end
		Map:update(dt)
	end
end

function love.draw()
	if Gamestate == "Menu" then
		Menu:draw()
	elseif Gamestate == "Map" then
		Map:draw()
	end
end

function love.keypressed(key)
	--if key == "d" then
		--DEBUG = not DEBUG
	--end

	if Gamestate == "Menu" then
		Menu:keypressed(key)
	elseif Gamestate == "Map" then
		Map:keypressed(key)
	end
end
