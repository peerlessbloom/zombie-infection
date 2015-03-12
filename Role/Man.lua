--普通村民

require "Sprite/ManSprite"
require "Role/Character"
require "Ai/ManState"
require "Ai/InfectedManState"

Man = class("Man", function() return Character.new() end)

function Man:create(manRes, patrollPath, config, infectedConfig)
	local m = Man.new()
	m:init(manRes, patrollPath, config, infectedConfig)
	return m
end

function Man:init(manRes, patrollPath, config, infectedConfig)
	self.path = patrollPath				--当前路径,在初始化阶段=巡逻路径
	self.pathIndex = 1
	self.mapPos = self.path[self.pathIndex]
	self.patrollPath = patrollPath		--巡逻路径
	self.patrollPathIndex = 1			--当前巡逻的位置
	self.patrollDir = 1					--巡逻方向
	self.isPatroll = "patroll"			--是否在巡逻"patroll"/去巡逻开始位置的路上"return"/逃跑"escape"
	self.dir = "d"
	
	self.life = config["life"]
	self.harm = config["harm"]
	self.speed = config["speed"]
	self.leftfoot = true
	self.enemy = nil
	self.isHealthy = config["isHealthy"]		--是否被感染,当被僵尸远程攻击的时候，isHealthy--，直到=0时被感染
	self.attackSpeed = config["attackSpeed"]	--1s钟攻击次数
	self.infectedConfig = infectedConfig
	
	self.aiState = ManPatrollState:create() --AI状态
	self.state = "alive"				--人类状态
	
	self.askGod = nil
	
	self.res = ManSprite:create(manRes, self.speed, self.life)
	self.res:setPosition(MapUtil:convertBack(self.mapPos[1], self.mapPos[2]))
end

--------------------坐标--------------------

function Man:nextPatrollPos()
	self.patrollPathIndex = self.patrollPathIndex + self.patrollDir
	if self.patrollPathIndex > #(self.patrollPath) then
		self.patrollPathIndex = #(self.patrollPath)
		self.patrollDir = -1
	elseif self.patrollPathIndex < 1 then
		self.patrollPathIndex = 1
		self.patrollDir = 1
	end
	local nextpos = self.patrollPath[self.patrollPathIndex]
	local state = self:collideCheck(nextpos)
	return state , {MapUtil:convertBack(nextpos[1], nextpos[2])}
end

-----------------行走------------------------
local function selfCheck(sprite, man)
	--自动机部分
	man[1]:update()
end

function Man:goStub(curpos, nextpos, dir)
	self.res:runManAnimate(dir, self.leftfoot)
	local dif = CollideUtil:getDist(curpos[1], curpos[2], nextpos[1], nextpos[2])
	local t = dif / (40.0 * self.speed)
	self.res:runManMove(nextpos[1], nextpos[2], selfCheck, {self}, t)
end

function Man:waitStub(curpos)
	self.res:runDelayFunction(1/ self.speed, selfCheck, {self})
end

function Man:stopStub(curpos)
	self.res:runDelayFunction(1/ self.speed, selfCheck, {self})
end

--巡逻
function Man:patroll()
	self:stop()
	if self.isPatroll == "escape" or self.isPatroll == "follow" then
		--cclog("isPatroll:escape")
		--之前在逃跑，现在要回来
		--1.找到self.mapPos~self.patrollStartPos路径（只要找一次？）
		--2.设置path，各种初始化
		local destPos = self.patrollPath[self.patrollPathIndex]
		cclog("findpath(%d,%d)=>(%d,%d)", self.mapPos[1], self.mapPos[2], destPos[1], destPos[2])
		local path = self.askGod:findPath(self.mapPos, destPos)
		self.path = path
		self.pathIndex = 1
		self.isPatroll = "return"
	end
	if self.isPatroll == "return" then
		--cclog("isPatroll:return")
		--如果到达目的地
		local destPos = self.patrollPath[self.patrollPathIndex]
		if self.mapPos[1] == destPos[1] and self.mapPos[2] == destPos[2] then
			self.isPatroll = "patroll"
		--在回来的路上
		else
			self:go()
			return
		end		
	end
	if self.isPatroll == "patroll" then
		--cclog("isPatroll:patroll")
		local curpos = self:getPosition()
		self.mapPos = self.patrollPath[self.patrollPathIndex]
		local state, nextpos = self:nextPatrollPos()
		self.dir = CollideUtil:getDir(curpos[1], curpos[2], nextpos[1], nextpos[2])
		if state == "stop" then return
		--假设当一个人patroll时，不会停止下来，除非是逃跑
		--elseif state == "wait" then
		--	self:waitStub(curpos)
		--	return
		end
		--update
		if self.leftfoot then self.leftfoot = false else self.leftfoot = true end
		self.mapPos = self.patrollPath[self.patrollPathIndex]
		self.res:runManAnimate(self.dir, self.leftfoot)
		local dif = CollideUtil:getDist(curpos[1], curpos[2], nextpos[1], nextpos[2])
		local t = dif / (40.0 * self.speed)
		self.res:runManMove(nextpos[1], nextpos[2], selfCheck, {self}, t)
	end
end

function Man:randomPatroll()
	cclog("random patroll")
--选择一个方向，一直走到尽头
	local nextpos = self:getMapPosition(self.dir) --下一个位置
	local state = self:collideCheck(nextpos)
	--走到了尽头，尝试新方向
	local dirs = {"u", "d", "r", "l"}
	local dir = self.dir
	while state ~= "go" and #(dirs) > 0 do
		--如果可以走，先将该方向设为新的方向
		if state ~="stop" then self.dir = dir end
		--随机一个方向，尝试该方向
		local rand = math.random(#(dirs))		
		dir = dirs[rand]
		table.remove(dirs, rand)
		nextpos = self:getMapPosition(dir)
		state = self:collideCheck(nextpos)
	end
	if state =="go" then self.dir = dir end
	self:goDir(self.dir)
end

-----------------逃跑---------------------
function Man:escape(dir)
	cclog("esscape")
	if self.isPatroll ~= "esscape" then --之前还在巡逻
		--保存巡逻的开始位置，以便以后找回去
		self.isPatroll = "escape"
	end
	--获取逃跑方向：敌人所在的位置->自己的位置
	
	local manDir = CollideUtil:getMapDir(dir[1], dir[2], 0, 0)
	--cclog("enemy dir:(%d,%d), self dir:"..manDir, dir[1], dir[2])
	local nextpos = self:getMapPosition(manDir) --下一个位置
	local state = self:collideCheck(nextpos)
	if state ~= "go" then
		--尝试另外的方向
		local otherDirs = nil
		if manDir == "u" or manDir == "d" then otherDirs = {"l", "r"}
		else otherDirs = {"u", "d"} end
		for i = 1, 2 do
			nextpos = self:getMapPosition(otherDirs[i])
			state = self:collideCheck(nextpos)
			if state == "go" then
				self:goDir(otherDirs[i])
				return
			end
		end
		--尝试失败了		
	end
	self:goDir(manDir)
end

------------------追踪----------------------
function Man:follow(dir)
	cclog("follow")
	if self.isPatroll ~= "follow" then --之前还在巡逻
		--保存巡逻的开始位置，以便以后找回去
		self.isPatroll = "follow"
	end
	--获取追踪方向	
	local manDir = CollideUtil:getMapDir(0, 0, dir[1], dir[2])
	cclog("enemy dir:(%d,%d), self dir:"..manDir, dir[1], dir[2])
	local nextpos = self:getMapPosition(manDir) --下一个位置
	local state = self:collideCheck(nextpos)
	if state ~= "go" then
		--尝试另外的方向
		local otherDirs = nil
		if manDir == "u" or manDir == "d" then otherDirs = {"l", "r"}
		else otherDirs = {"u", "d"} end
		for i = 1, 2 do
			nextpos = self:getMapPosition(otherDirs[i])
			state = self:collideCheck(nextpos)
			if state == "go" then
				self:goDir(otherDirs[i])
				return
			end
		end
		--尝试失败了		
	end
	self:goDir(manDir)
end

-----------------停止-------------------------

------------------状态------------------------

-----------------锁定敌人---------------------
-- return sucess or not
function Man:setEnemy(e)
	if e == nil then 
		self.enemy = nil
		return true
	end
	if e:isInfected() == self:isInfected() then
		self.enemy = nil
		return false
	end
	self.enemy = e
	return true
end

--显示被追踪
function Man:setAlert(show)
	if self.isHealthy <= 0 then return end
	self.res:setAlert(show)
end


----------------攻击------------------------
function Man:attackStub(eMapPos)
	self.res:runAttackAnimate(self.dir)
	--AI
	self.res:runDelayFunction(2/self.attackSpeed, selfCheck, {self})
end

-----------------受伤---------------------
function Man:hurt(value, isInfectionAttack)
	if self:isDied() then return end
	--感染攻击
	if isInfectionAttack then 
		if self:isInfected() then return end --已经感染，不受到伤害
		self.res:infect()
		self.isHealthy = self.isHealthy - 1 
		if self.isHealthy == 0 then self:infect() end
		return
	end
	--普通攻击
	self.life = self.life - value
	self.res:hurt(self.life)
	if self:isDied() then self:die() end
end

-----------------死亡---------------------
function Man:die()
	if self.state == "dead" then return end
	--self:stop()
	self.res:dead()
	self.state = "dead"
	self.askGod:manDied(self)	
end

-----------------感染---------------------
function Man:infect()
	--已经感染，不需要再次感染
	if self.state == "infected" or  self.state == "dead" then return end
	--设置尸化人的属性
	cclog("set infected attribute")
	self.isHealthy = self.infectedConfig["isHealthy"]
	self.life = self.infectedConfig["life"]
	self.harm = self.infectedConfig["harm"]
	self.speed = self.infectedConfig["speed"]
	self:setEnemy(nil)
	pos = self:getPosition()
	self.res:setSprite(true, pos, self.life)
	self.askGod:manInfected(self)
	self.state = "infected"
	self:update()
end

function Man:isInfected()
	return self.isHealthy <= 0
end

