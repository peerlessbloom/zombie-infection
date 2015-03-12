--警察蜀黍

require "Sprite/SuperManSprite"
require "Ai/SuperManState"
require "Role/Man"

SuperMan = class("SuperMan", function() return Man.new() end)
function SuperMan:create(manRes, patrollPath, config, infectedConfig)
	local m = SuperMan.new()
	m:init(manRes, patrollPath, config, infectedConfig)
	return m
end

function SuperMan:init(manRes, patrollPath, config, infectedConfig)
	self.path = patrollPath				--当前路径,在初始化阶段=巡逻路径
	self.pathIndex = 1
	self.mapPos = self.path[self.pathIndex]
	self.patrollPath = patrollPath		--巡逻路径
	self.patrollDir = 1					--巡逻方向
	self.patrollPathIndex = 1			--当前巡逻的位置
	self.isPatroll = "patroll"			--是否在巡逻"patroll"/去巡逻开始位置的路上"return"/逃跑"escape"
	self.dir = "d"
	
	self.life = config["life"]
	self.harm = config["harm"]						--进程攻击
	self.harmFar = config["harmFar"]				--远程攻击
	self.speed = config["speed"]
	self.leftfoot = true
	self.enemy = nil
	self.isHealthy = config["isHealthy"]			--是否被感染,当被僵尸远程攻击的时候，isHealthy--，直到=0时被感染
	self.attackSpeed = config["attackSpeed"]		--每秒攻击数
	self.infectedConfig = infectedConfig
	
	self.aiState = SuperManPatrollState:create() --AI状态
	self.state = "alive"				--人类状态
	
	self.askGod = nil
	
	self.res = SuperManSprite:create(manRes, self.speed, self.life)
	self.res:setPosition(MapUtil:convertBack(self.mapPos[1], self.mapPos[2]))
end

--------------------坐标--------------------

-------------------行走---------------------
local function selfCheck(sprite, man)
	cclog("superman self check")
	--自动机部分
	man[1]:update()
end

-----------------停止-------------------------

-----------------状态-------------------------

-----------------锁定敌人---------------------

-----------------攻击-------------------------
function SuperMan:attackFar()
	if self:isAttackable(3) == false then
		local dist, dir, enemy = self:checkView()
		if self:isAttackable(3) == false then 
			self:update()
			return 
		end
		self.dir = CollideUtil:convertDir(dir[1], dir[2])
	end
	
	local pos = self:getMapPosition()
	local attack = Attack:create(1, self.enemy, self.harmFar, self:getMapPosition(), self.askGod)
	--AI
	self.res:runDelayFunction(1/self.attackSpeed, selfCheck, {self})
	attack:go()
end

-----------------受伤---------------------

-----------------死亡---------------------

-----------------感染---------------------
function SuperMan:infect()
	--已经感染，不需要再次感染
	if self.state == "infected" or  self.state == "dead" then return end
	--设置尸化人的属性
	self.isHealthy = self.infectedConfig["isHealthy"]
	self.life = self.infectedConfig["life"]
	self.harm = self.infectedConfig["harm"]
	self.speed = self.infectedConfig["speed"]
	self:setEnemy(nil)
	pos = self:getPosition()
	self.res:setSprite(true, pos, self.life)
	self.res:updateState(self.life)
	--self:patroll()
	self.askGod:manInfected(self)
	self.state = "infected"
	self:update()
end