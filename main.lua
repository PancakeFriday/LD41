Object = require "classic"
lume = require "lume"
Animation = require "animation"

local Player = require "player"
local Map = require "map"

love.graphics.setDefaultFilter("nearest","nearest")

function love.load()

end

function love.update(dt)
	Map:update(dt)
	Player:update(dt)
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(4,4)
	Map:draw()
	Player:draw()

	love.graphics.pop()
end
