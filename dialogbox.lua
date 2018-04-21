local Dialogbox = Object:extend()

local MAXWIDTH = 10
local TEXTSPEED = 0.03

function Dialogbox.getDimensions(text)
	local textwidth, numlines = FONT[40]:getWrap(text, (MAXWIDTH*16 + 10)*4)
	numlines = #numlines
	local maxx = math.min(MAXWIDTH, math.floor(textwidth/(16*4)))
	local maxy = math.ceil(numlines/2)
	if numlines == 1 then
		maxy = maxy - 1
	end

	return (maxx+2)*16, (maxy+2)*16
end

function Dialogbox:new(text,x,y)
	self.img = love.graphics.newImage("img/dialogbox.png")
	self.img:setFilter("nearest","nearest")
	self.quads = {}
	for y = 0,2 do
		self.quads[y] = {}
		for x = 0,2 do
			self.quads[y][x] = love.graphics.newQuad(x*16,y*16,16,16,self.img:getWidth(),self.img:getHeight())
		end
	end

	self.time = 0
	self.text = text
	self.x = x
	self.y = y

	self.done = false
end

function Dialogbox:update(dt)
	self.time = self.time + dt
	local numchars = math.floor((self.time)/TEXTSPEED)
	if numchars >= self.text:len() then
		self.done = true
	end
end

function Dialogbox:draw()
	local numchars = math.floor(self.time/TEXTSPEED)

	love.graphics.setFont(FONT[40])
	local textwidth, numlines = FONT[40]:getWrap(self.text, (MAXWIDTH*16 + 10)*4)
	local _, wrappedtext = FONT[40]:getWrap(self.text:sub(1,numchars), (MAXWIDTH*16 + 10)*4)
	numlines = #numlines

	local maxx = math.min(MAXWIDTH, math.floor(textwidth/(16*4)))
	local maxy = math.max(0,numlines - 2)

	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	-- top left
	love.graphics.draw(self.img, self.quads[0][0],0,0)
	-- top border
	for i=1,maxx do
		love.graphics.draw(self.img, self.quads[0][1],i*16,0)
	end
	-- top right
	love.graphics.draw(self.img, self.quads[0][2],(maxx+1)*16,0)

	if numlines > 2 then
		-- left border
		for i=1,maxy do
			love.graphics.draw(self.img, self.quads[1][0],0,i*16)
		end
		-- right border
		for i=1,maxy do
			love.graphics.draw(self.img, self.quads[1][2],(maxx+1)*16,i*16)
		end
	end

	-- center
	for y=1, maxy do
		for x=1, maxx do
			love.graphics.draw(self.img, self.quads[1][1],x*16,y*16)
		end
	end

	-- bottom left
	love.graphics.draw(self.img, self.quads[2][0],0,(maxy+1)*16)
	-- bottom right
	love.graphics.draw(self.img, self.quads[2][2],(maxx+1)*16,(maxy+1)*16)
	-- bottom border
	for i=1,maxx do
		love.graphics.draw(self.img, self.quads[2][1],i*16,(maxy+1)*16)
	end
	love.graphics.setColor(0,0,0)
	for i,v in pairs(wrappedtext) do
		love.graphics.printUnscaled(v, 5, (i-1)*FONT[40]:getHeight()/4 + 4)
	end
	love.graphics.setColor(1,1,1)
	love.graphics.pop()
end

return Dialogbox
