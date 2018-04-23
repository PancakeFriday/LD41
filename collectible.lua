local HC = require "hardoncollider"
local Collectible = Object:extend()

Collectible.greyscaleshader = love.graphics.newShader[[
	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
	  vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
	  number average = (pixel.r+pixel.b+pixel.g)/3.0;
	  pixel.r = average;
	  pixel.g = average;
	  pixel.b = average;
	  return pixel;
	}
]]

function Collectible:new(id,x,y)
	self.x = x
	self.y = y

	self.img = love.graphics.newImage("img/collectibles.png")
	self.img:setFilter("nearest","nearest")
	self.quad = love.graphics.newQuad((tonumber(id)-1)*16,0,16,16,self.img:getWidth(),self.img:getHeight())
	self.time = 0
	self.bbox = HC.rectangle(self.x, self.y, 16, 16)
	self.bbox.type = "collectible"
	self.bbox.object = self

	self.collected = false
end

function Collectible:update(dt)
	if not self.collected then
		self.time = self.time + dt
	end
end

function Collectible:draw()
	if not self.collected then
		love.graphics.push()
		love.graphics.translate(self.x, self.y)
		love.graphics.draw(self.img, self.quad, 0, math.sin(self.time*2.5)*3)
		love.graphics.pop()
	end
end

function Collectible:draw_ui(l,t,w,h)
	love.graphics.push()
	love.graphics.translate(l,t)
	if not self.collected then
		love.graphics.setShader(self.greyscaleshader)
	end
	love.graphics.draw(self.img, self.quad)
	love.graphics.setShader()
	love.graphics.pop()
end

return Collectible
