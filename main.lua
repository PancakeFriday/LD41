Object = require "classic"
lume = require "lume"
Animation = require "animation"
Vector = require "vector"

DEBUG = false

local Player = require "player"
local Map = require "map"

FONT = {}
for i=1,40 do
	table.insert(FONT, love.graphics.newFont("font/LektonCode/LektonCode-Regular.ttf", i))
	FONT[#FONT]:setFilter("nearest","nearest")
end

love.graphics.setDefaultFilter("nearest","nearest")
love.graphics.setBackgroundColor(35/255,17/255,43/255)

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

end

function love.update(dt)
	Map:update(dt)
end

function love.draw()
	Map:draw()
end

function love.keypressed(key)
	if key == "d" then
		DEBUG = not DEBUG
	end
	Map:keypressed(key)
end
