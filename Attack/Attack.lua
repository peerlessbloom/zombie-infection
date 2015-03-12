require "Util/MapUtil"
local sprites = {"effect/bullet.png", "effect/z_bullet.png"}

Attack = class("Attack")

function Attack:create(spriteId, enemy, harm, pos, god)
	local a = Attack.new()
	a:init(spriteId, enemy, harm, pos, god)
	return a
end

function Attack:init(spriteId, enemy, harm, pos, god)
	self.life = 10			--生命长度
	self.speed = 10			--速度
	self.harm = harm		--伤害值
	self.sprite = cc.Sprite:create(sprites[spriteId])
	self.sprite:setAnchorPoint(cc.p(0,1))
	self.enemy = enemy		--敌人
	self.mapPos = {pos[1], pos[2]} --在地图中的位置
	self.isHit = false
	self.pos = {MapUtil:convertBack(self.mapPos[1], self.mapPos[2])}--位置
	self.askGod = god		--AStarMap
	self.askGod:addToMap(self.sprite, 2)
	self.sprite:setPosition(self.pos[1], self.pos[2])
end

local function selfCheck(sprite, attack)
	--cclog("check attack:%d", attack.life)
	--生命是否结束
	attack.life = attack.life - 1
	if attack.life == 0 then 
		cclog("attack.die")
		attack:die()
		return 
	end
	local eMapPos = attack.enemy:getMapPosition()
	if attack.isHit == true then
		cclog("hurt enemy")
		attack.enemy:hurt(attack.harm, true)
		attack:die() 
		return 
	end
	--检查是否撞到树上
	--cclog("Bullet pos(%d,%d)", attack.mapPos[1], attack.mapPos[2])
	if	attack.askGod:isValid(attack.mapPos[1], attack.mapPos[2]) == 1 then
		cclog("attack tree")
		attack:die()
		return 
	end
	--继续前进
	attack:go()
end

function Attack:getNextPos()
	local ePos = self.enemy:getPosition()
	--cclog("ePos: %f, %f | Pos: %f, %f", ePos[1], ePos[2], self.pos[1], self.pos[2])
	local deltaX = ePos[1] - self.pos[1]
	local deltaY = ePos[2] - self.pos[2]
	local deltaL = math.sqrt(deltaX * deltaX + deltaY * deltaY)
	local delta = {deltaX / deltaL * self.speed, deltaY / deltaL * self.speed}
	--update
	--cclog("delta: %f, %f", delta[1], delta[2])
	self.pos[1] = self.pos[1] + delta[1]
	self.pos[2] = self.pos[2] + delta[2]
	--eMapPos[1] == attack.mapPos[1] and eMapPos[2] == attack.mapPos[2]
	if math.abs(self.pos[1] - ePos[1]) <= self.speed / 2 and math.abs(self.pos[2] - ePos[2]) <= self.speed / 2 then self.isHit = true end
	self.mapPos = {MapUtil:convert(self.pos[1], self.pos[2])}
	--cclog("mapPos of attack: %f, %f", self.mapPos[1], self.mapPos[2])
end

function Attack:go()
	self:getNextPos()
	self.sprite:runAction( cc.Sequence:create( cc.MoveTo:create(1 / self.speed, cc.p(self.pos[1], self.pos[2])),
											   cc.CallFunc:create(selfCheck, self)
						 )
	  )
end

function Attack:die()
	self.sprite:getParent():removeChild(self.sprite)
end
