require "Res/ZombieRes"
require "Sprite/CharacterSprite"

ZombieSprite = class("ZombieSprite", function() return CharacterSprite.new() end)
function ZombieSprite:create(zombieRes, speed, life)
	local m = ZombieSprite.new()
	m:init(zombieRes, speed, life)
	return m
end

function ZombieSprite:init(zombieRes, speed, life)
	self.res = zombieRes
	self:resetSpeed(speed)
	self.sprite = zombieRes.sprite
	self.life = life		--�ܵ�����
	self:initState(life)
end

function ZombieSprite:resetSpeed(speed)
	self.speed = speed
	self.res:setAnimateSpeed(self.speed)
end

------------------sprite�ķ�װ-----------------------

------------------����һ������-----------------------

------------------����Ѫ��---------------------------
function ZombieSprite:initState(life)
	if life > self.life then self.life = life end
	self.lifeLayer = self.res:getLifeBar(life, self.life)
	self.sprite:addChild(self.lifeLayer, 2)
end

function ZombieSprite:updateState(life)
	self.lifeLayer:getParent():removeChild(self.lifeLayer)
	self:initState(life)
end

------------------���ж���--------------------
--�ý�ʬ����һ�ζ���
function ZombieSprite:runZombieAnimate(dir, isLeftStep)
	self.sprite:runAction(cc.RepeatForever:create(self.res:getAnimate(dir, isLeftStep)))
end

--�ý�ʬ������
function ZombieSprite:runZombieMoveFromTo(from, to, callbackFun, callbackArg)
	self.sprite:runAction( cc.Sequence:create( cc.MoveTo:create(1 / self.speed, cc.p(from[1], from[2])),
												cc.MoveTo:create(1 / self.speed, cc.p(to[1], to[2])),
											   cc.CallFunc:create(callbackFun, callbackArg)
						 )
	  )
end

function ZombieSprite:runZombieMoveTo(to, callbackFun, callbackArg, t)
	if t == nil then t = 1/self.speed end
	self.sprite:runAction( cc.Sequence:create( cc.MoveTo:create(t, cc.p(to[1], to[2])),
											   cc.CallFunc:create(callbackFun, callbackArg)
						 )
	  )
end

function ZombieSprite:runZombieWait(cur, callbackFun, callbackArg)
	self.sprite:runAction( cc.Sequence:create( cc.DelayTime:create(1 / self.speed), cc.MoveTo:create(1 / self.speed, cc.p(cur[1], cur[2])),
											   cc.CallFunc:create(callbackFun, callbackArg)
						 )
	  )
end

local function selfRelease(sp)
	sp:getParent():removeChild(sp)
end


--��ʾ���˶���
function ZombieSprite:hurt(life)
	self:updateState(life)
	--����Ҫ˵�Ļ�
	--local whatToSay = {"Mmmmmmm", "Errrrr", "Brainnnnnn"}
	--local say = self.res:getLabel(whatToSay, "fonts/Zombie.ttf")
    --say:setAnchorPoint( 0, 1 )
	--say:setPosition( 35, 75 )
    --say:setColor(cc.c3b(255, 0, 0))
	--self.sprite:addChild(say, 1)
	--say:runAction(cc.Sequence:create( cc.FadeOut:create(0.5), cc.CallFunc:create(selfRelease)))
	--��������
	
	self.sprite:setOpacity(0)
	self.sprite:runAction(cc.Sequence:create(cc.DelayTime:create(0.07), cc.FadeIn:create(0)))
	
	local hurtNear = cc.Sprite:create()
	self.sprite:addChild(hurtNear, 10)
	hurtNear:setAnchorPoint(0, 0)
	hurtNear:setPosition(10, 0)
	local hurtAnimate = self.res:getHurtAnimate()
	hurtNear:runAction(cc.Sequence:create(hurtAnimate, cc.CallFunc:create(selfRelease)))
end

--��ʾ��ȥ�Ķ���
function ZombieSprite:dead()
	local deadSprite = cc.Sprite:create("effect/dead.png")
	self.lifeLayer:getParent():removeChild(self.lifeLayer)
	deadSprite:setAnchorPoint(0, 0)
	self.sprite:addChild(deadSprite, 1)
	self.sprite:setOpacity(0)
	deadSprite:runAction(cc.Sequence:create( cc.FadeIn:create(0.2), cc.FadeOut:create(2), cc.CallFunc:create(selfRelease)))
end

--�ý�ʬ����
function ZombieSprite:runAttackAnimate(dir, callbackFun, callbackArg)
	self.sprite:runAction(cc.Sequence:create( self.res:getAttackAnimate(dir),
											  cc.CallFunc:create(callbackFun, callbackArg))
	)
end