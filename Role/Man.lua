--��ͨ����

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
	self.path = patrollPath				--��ǰ·��,�ڳ�ʼ���׶�=Ѳ��·��
	self.pathIndex = 1
	self.mapPos = self.path[self.pathIndex]
	self.patrollPath = patrollPath		--Ѳ��·��
	self.patrollPathIndex = 1			--��ǰѲ�ߵ�λ��
	self.patrollDir = 1					--Ѳ�߷���
	self.isPatroll = "patroll"			--�Ƿ���Ѳ��"patroll"/ȥѲ�߿�ʼλ�õ�·��"return"/����"escape"
	self.dir = "d"
	
	self.life = config["life"]
	self.harm = config["harm"]
	self.speed = config["speed"]
	self.leftfoot = true
	self.enemy = nil
	self.isHealthy = config["isHealthy"]		--�Ƿ񱻸�Ⱦ,������ʬԶ�̹�����ʱ��isHealthy--��ֱ��=0ʱ����Ⱦ
	self.attackSpeed = config["attackSpeed"]	--1s�ӹ�������
	self.infectedConfig = infectedConfig
	
	self.aiState = ManPatrollState:create() --AI״̬
	self.state = "alive"				--����״̬
	
	self.askGod = nil
	
	self.res = ManSprite:create(manRes, self.speed, self.life)
	self.res:setPosition(MapUtil:convertBack(self.mapPos[1], self.mapPos[2]))
end

--------------------����--------------------

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

-----------------����------------------------
local function selfCheck(sprite, man)
	--�Զ�������
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

--Ѳ��
function Man:patroll()
	self:stop()
	if self.isPatroll == "escape" or self.isPatroll == "follow" then
		--cclog("isPatroll:escape")
		--֮ǰ�����ܣ�����Ҫ����
		--1.�ҵ�self.mapPos~self.patrollStartPos·����ֻҪ��һ�Σ���
		--2.����path�����ֳ�ʼ��
		local destPos = self.patrollPath[self.patrollPathIndex]
		cclog("findpath(%d,%d)=>(%d,%d)", self.mapPos[1], self.mapPos[2], destPos[1], destPos[2])
		local path = self.askGod:findPath(self.mapPos, destPos)
		self.path = path
		self.pathIndex = 1
		self.isPatroll = "return"
	end
	if self.isPatroll == "return" then
		--cclog("isPatroll:return")
		--�������Ŀ�ĵ�
		local destPos = self.patrollPath[self.patrollPathIndex]
		if self.mapPos[1] == destPos[1] and self.mapPos[2] == destPos[2] then
			self.isPatroll = "patroll"
		--�ڻ�����·��
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
		--���赱һ����patrollʱ������ֹͣ����������������
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
--ѡ��һ������һֱ�ߵ���ͷ
	local nextpos = self:getMapPosition(self.dir) --��һ��λ��
	local state = self:collideCheck(nextpos)
	--�ߵ��˾�ͷ�������·���
	local dirs = {"u", "d", "r", "l"}
	local dir = self.dir
	while state ~= "go" and #(dirs) > 0 do
		--��������ߣ��Ƚ��÷�����Ϊ�µķ���
		if state ~="stop" then self.dir = dir end
		--���һ�����򣬳��Ը÷���
		local rand = math.random(#(dirs))		
		dir = dirs[rand]
		table.remove(dirs, rand)
		nextpos = self:getMapPosition(dir)
		state = self:collideCheck(nextpos)
	end
	if state =="go" then self.dir = dir end
	self:goDir(self.dir)
end

-----------------����---------------------
function Man:escape(dir)
	cclog("esscape")
	if self.isPatroll ~= "esscape" then --֮ǰ����Ѳ��
		--����Ѳ�ߵĿ�ʼλ�ã��Ա��Ժ��һ�ȥ
		self.isPatroll = "escape"
	end
	--��ȡ���ܷ��򣺵������ڵ�λ��->�Լ���λ��
	
	local manDir = CollideUtil:getMapDir(dir[1], dir[2], 0, 0)
	--cclog("enemy dir:(%d,%d), self dir:"..manDir, dir[1], dir[2])
	local nextpos = self:getMapPosition(manDir) --��һ��λ��
	local state = self:collideCheck(nextpos)
	if state ~= "go" then
		--��������ķ���
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
		--����ʧ����		
	end
	self:goDir(manDir)
end

------------------׷��----------------------
function Man:follow(dir)
	cclog("follow")
	if self.isPatroll ~= "follow" then --֮ǰ����Ѳ��
		--����Ѳ�ߵĿ�ʼλ�ã��Ա��Ժ��һ�ȥ
		self.isPatroll = "follow"
	end
	--��ȡ׷�ٷ���	
	local manDir = CollideUtil:getMapDir(0, 0, dir[1], dir[2])
	cclog("enemy dir:(%d,%d), self dir:"..manDir, dir[1], dir[2])
	local nextpos = self:getMapPosition(manDir) --��һ��λ��
	local state = self:collideCheck(nextpos)
	if state ~= "go" then
		--��������ķ���
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
		--����ʧ����		
	end
	self:goDir(manDir)
end

-----------------ֹͣ-------------------------

------------------״̬------------------------

-----------------��������---------------------
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

--��ʾ��׷��
function Man:setAlert(show)
	if self.isHealthy <= 0 then return end
	self.res:setAlert(show)
end


----------------����------------------------
function Man:attackStub(eMapPos)
	self.res:runAttackAnimate(self.dir)
	--AI
	self.res:runDelayFunction(2/self.attackSpeed, selfCheck, {self})
end

-----------------����---------------------
function Man:hurt(value, isInfectionAttack)
	if self:isDied() then return end
	--��Ⱦ����
	if isInfectionAttack then 
		if self:isInfected() then return end --�Ѿ���Ⱦ�����ܵ��˺�
		self.res:infect()
		self.isHealthy = self.isHealthy - 1 
		if self.isHealthy == 0 then self:infect() end
		return
	end
	--��ͨ����
	self.life = self.life - value
	self.res:hurt(self.life)
	if self:isDied() then self:die() end
end

-----------------����---------------------
function Man:die()
	if self.state == "dead" then return end
	--self:stop()
	self.res:dead()
	self.state = "dead"
	self.askGod:manDied(self)	
end

-----------------��Ⱦ---------------------
function Man:infect()
	--�Ѿ���Ⱦ������Ҫ�ٴθ�Ⱦ
	if self.state == "infected" or  self.state == "dead" then return end
	--����ʬ���˵�����
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

