local Menu = Object:extend()

local Dialogbox = require "dialogbox"

love.graphics.setBackgroundColor(0,0,0)

function Menu:new()
	self.start = Dialogbox("Start game", 50, 80)
	self.quit = Dialogbox("Quit", 110, 80)
	self.title = love.graphics.newImage("img/titleimage.png")
	self.title:setFilter("nearest","nearest")
	self.arrow = love.graphics.newImage("img/arrow.png")
	self.arrow:setFilter("nearest","nearest")
	self.arrow_yoff = 0

	self.time = 0
	self.selection = 0
end

function Menu:update(dt)
	self.time = self.time + dt
	self.start:update(dt)
	self.quit:update(dt)

	self.arrow_yoff = (math.sin(self.time*2)^2)*10
end

function Menu:draw()
	love.graphics.push()
	love.graphics.scale(4,4)
	love.graphics.translate(40,30)
	love.graphics.draw(self.title,23,-10)
	self.start:draw()
	self.quit:draw()
	love.graphics.draw(self.arrow, 67+self.selection*50, 100+self.arrow_yoff)
	love.graphics.pop()
end

function Menu:keypressed(key)
	if love.keyboard.isDown("left") or love.keyboard.isDown("right") then
		self.selection = (self.selection+1)%2
	end
	if love.keyboard.isDown("return") then
		if self.selection == 1 then
			love.event.quit()
		else
			Gamestate = "Map"
		end
	end
end

return Menu()
