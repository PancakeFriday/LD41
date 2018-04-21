Object = require "classic"
lume = require "lume"
Animation = require "animation"

local Player = require "player"
local Map = require "map"

love.graphics.setDefaultFilter("nearest","nearest")
love.graphics.setBackgroundColor(50/255,70/255,270/255)

function love.load()

end

function love.update(dt)
	Player:update(dt)
	Map:update(dt)
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(4,4)
	Player:draw()
	Map:draw()

	love.graphics.pop()
end
