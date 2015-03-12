--这是一个僵尸类，也是用户控制的英雄

require "Sprite/ZombieSprite"
require "Role/Character"
require "Attack/Attack"

Zombie = class("Zombie",function() return Character.new() end)
function Zombie:create(zombieRes, config)
	local z = Zombie.new()
	z:init(zombieRes, config)
	return z
end

function Zombie:init(zombieRes, config)
	self.mapPos = {config["x"], config["y"]}
	self.path = nil
	self.pathIndex = 0
	self.dir = "d"
	
	self.life = config["life"]
	self.harm = config["harm"]
	self.harmFar = config["harmFar"]
	self.speed = config["speed"]
	self.leftfoot = true
	self.isHealthy = config["isHealthy"]
	self.enemy = nil
	
	self.askGod = nil
	
	self.res = ZombieSprite:create(zombieRes, self.speed, self.life)
	self.res:setPosition(MapUtil:convertBack(self.mapPos[1], self.mapPos[2]))
end

function Zombie:update()
end
------------------获取坐标--------------------
local function selfStop(sprite, zombie)
	zombie[1]:stop()
end
function Zombie:resetPosition()
	self:stop()
	self.isGoDir = "stop"
	local curpos = self:getPosition()
	local pos = {MapUtil:convertBack(self.mapPos[1], self.mapPos[2])}
	local dif = CollideUtil:getDist(curpos[1], curpos[2], pos[1], pos[2])
	local t = dif / (40.0 * self.speed)
	self.res:runZombieAnimate(self.dir, self.leftfoot)
	self.res:runZombieMoveTo(pos, selfStop, {self}, t)
end

-----------------行走-------------------------
local function selfCheck(sprite, zombie)
	if zombie[1].isGoDir == "dir" then zombie[1]:goDir(zombie[1].dir) 
	elseif zombie[1].isGoDir == "path" then zombie[1]:go()
	else zombie[1]:stop() end
end

function Zombie:goStub(curpos, nextpos, dir)
	--cclog("Zombie go "..dir.." (%d, %d)", nextpos[1], nextpos[2])
	self.res:runZombieAnimate(dir, self.leftfoot)
	--local mapposX, mapposY = curpos[1], curpos[2]
	--local curposition = self:getPosition()
	--cclog("cur:(%f,%f), should:(%f,%f)", curposX, curposY, mapposX, mapposY)
	--if curposition[1] ~= mapposX or curposition[2] ~= mapposY then
	--	self.res:runZombieMoveFromTo(curpos, nextpos, selfCheck, {self})
	--else
		local curpos = self:getPosition()
		local dif = CollideUtil:getDist(curpos[1], curpos[2], nextpos[1], nextpos[2])
		local t = dif / (40.0 * self.speed)
		self.res:runZombieMoveTo(nextpos, selfCheck, {self}, t)
		self.askGod:mapMoveTo(450 - nextpos[1], 300 - nextpos[2], t)
	--end
end

function Zombie:waitStub(curpos)
	cclog("Zombie wait (%d, %d)", curpos[1], curpos[2])
	self.res:runZombieWait(curpos, selfCheck, {self})
end

function Zombie:stopStub(curpos)
	self.isGoDir = "stop"
	cclog("Zombie stop (%d, %d)", curpos[1], curpos[2])
end

--for test
function Zombie:collideCheck(pos)
	local tag = self.askGod:isValid(pos[1], pos[2])
	--cclog("collide check(%d, %d)=>%d", pos[1], pos[2], tag)
	if tag == 1 then return "stop"
	elseif tag == 2 or tag == 3 then return "wait", tag
	else	return "go"
	end
end

-----------------停止------------------------

----------------锁定敌人---------------------
function Zombie:setEnemy(e)
	if self.enemy ~= nil then self.enemy:setAlert(false) end
	if e == nil then self.enemy = nil return true end
	if e:isInfected() then return false end
	self.enemy = e
	e:setAlert(true)
	return true
end

-----------------攻击------------------------
function Zombie:attackStub(eMapPos, goDir)
	local attackDir = self.dir
	self.dir = goDir
	self.res:runZombieAnimate(attackDir, self.leftfoot)
	self.res:runAttackAnimate(attackDir, selfCheck, {self})
end

--攻击失败，则继续走、停
function Zombie:attackFailStub()
	selfCheck(nil, {self})
end

function Zombie:searchStub()
	self:checkView(nil, false)
	return self:isAttackable()
end

function Zombie:attackFar()
	if self:isAttackable(3) == false then
		local dist, dir, enemy = self:checkView(nil, false)
		if self:isAttackable(3) == false then return end
		--self.dir = CollideUtil:getMapDir(0, 0, dir[1], dir[2])
	end
	self.res:runZombieAnimate(self.dir, self.leftfoot)
	local pos = self:getMapPosition()
	--cclog("%d, %d", pos[1], pos[2])
	local attack = Attack:create(2, self.enemy, self.harmFar, self:getMapPosition(), self.askGod)
	attack:go()	
end
----------------升级----------------------
function Zombie:upgrade()
	if self.askGod.gameover then return end
	cclog("upgrade")
	self.life = self.life + 10
	self.speed = self.speed + 0.1
	self.harm = self.harm + 1
	self.res:resetSpeed(self.speed)
	self.res:updateState(self.life)
end

-----------------受伤---------------------
function Zombie:hurt(value)
	self.life = self.life - value
	self.res:hurt(self.life)
	if self:isDied() then 
		self:die() 
	end
end

-----------------死亡---------------------
function Zombie:die()
	self.res:dead()
	self.askGod:manWin()
end

function Zombie:isInfected()
	return true
end