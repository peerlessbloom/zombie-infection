require "Res/ManRes"
require "Sprite/CharacterSprite"

ManSprite = class("ManSprite", function() return CharacterSprite.new() end)
function ManSprite:create(manRes, speed, life)
	local m = ManSprite.new()
	m:init(manRes, speed, life)
	return m
end

function ManSprite:init(manRes, speed, life)
	self.resNum = manRes:requireRes()
	self.res = manRes
	self:resetSpeed(speed)
	self.isInfected = false
	self.fontPath = "fonts/Man.ttf"
	self.sprite = self.res:getRes(self.resNum, self.isInfected)
	self.life = life		--总的生命
	self:initState(life)
end

function ManSprite:resetSpeed(speed)
	self.speed = speed
	self.res:setAnimateSpeed(self.speed)
end

------------------返回血条---------------------------
function ManSprite:initState(life)
	self.lifeLayer = self.res:getLifeBar(life, self.life)
	self.sprite:addChild(self.lifeLayer, 2)
end

function ManSprite:updateState(life)
	self.lifeLayer:getParent():removeChild(self.lifeLayer)
	self:initState(life)
end

------------------sprite的封装------------------------
function ManSprite:setSprite(isInfected, pos, life)
	self.isInfected = isInfected
	if isInfected then self.fontPath = "fonts/Zombie.ttf"
	else self.fontPath = "fonts/Man.ttf" end
	local preSprite = self.sprite
	local parent = preSprite:getParent()
	self.sprite = self.res:getRes(self.resNum, isInfected)
	parent:removeChild(preSprite)
	parent:addChild(self.sprite, 1)
	self.sprite:setPosition(pos[1], pos[2])
	self:initState(life)
	local mapOrder = GameRes:getInstance().mapOrder
	mapOrder[self.sprite] = mapOrder["pos"]
	mapOrder["pos"] = mapOrder["pos"] + 1
	mapOrder[preSprite] = -1
end

------------------运行动画--------------------
--让人运行一段动画
function ManSprite:runManAnimate(dir, isLeftStep)
	self.sprite:runAction(cc.RepeatForever:create(self.res:getAnimate(self.isInfected, dir, isLeftStep)))
end

--让人走起来
function ManSprite:runManMove( x, y, callbackFun, callbackArg, t)
	t = t or 1/self.speed
	self.sprite:runAction( cc.Sequence:create( cc.MoveTo:create(t, cc.p(x, y)),
											   cc.CallFunc:create(callbackFun, callbackArg)
						 )
	  )
end

--等一段时间后运行自检函数
function ManSprite:runDelayFunction(delay, callbackFun, callbackArg)
	self.sprite:runAction( cc.Sequence:create( cc.DelayTime:create(delay),
											   cc.CallFunc:create(callbackFun, callbackArg)
						 )
	  )
end

--显示被追踪
function ManSprite:setAlert(show)
	if show then 
		self.sprite:addChild(self.res.alertSprite)
		self.res.alertSprite:setPosition(20, 35)
	else self.sprite:removeChild(self.res.alertSprite) end
end

local function selfRelease(sp)
	sp:getParent():removeChild(sp)
end

--显示受伤动画
function ManSprite:hurt(life)
	self:updateState(life)
	self.sprite:runAction(cc.Sequence:create(cc.FadeOut:create(0), cc.DelayTime:create(0.07), 
						  cc.FadeIn:create(0)))
	local hurtNear = cc.Sprite:create()
	self.sprite:addChild(hurtNear, 10)
	hurtNear:setAnchorPoint(0, 0)
	local attackByInfected = true
	if self.isInfected then 
		attackByInfected = false
		hurtNear:setPosition(10, 0)
	end
	local hurtAnimate = self.res:getHurtAnimate(attackByInfected)
	hurtNear:runAction(cc.Sequence:create(hurtAnimate, cc.CallFunc:create(selfRelease)))
end

--显示感染动画
function ManSprite:infect()	
	local infectSprite = cc.Sprite:create("effect/infect.png")
	infectSprite:setAnchorPoint(0, 0)
	self.sprite:addChild(infectSprite, 1)
	infectSprite:runAction(cc.Sequence:create( cc.FadeIn:create(0.2), cc.FadeOut:create(1), cc.CallFunc:create(selfRelease)))
end

local function selfRemoveSprite(sp, s)
	sp:getParent():removeChild(sp)
	--local parent = s.sprite:getParent()
	--parent:removeChild(s.sprite)
	--GameRes:getInstance().mapOrder[s.sprite] = -1
end

--显示死去的动画
function ManSprite:dead()
	local deadSprite = cc.Sprite:create("effect/dead.png")
	self.lifeLayer:getParent():removeChild(self.lifeLayer)
	deadSprite:setAnchorPoint(0, 0)
	deadSprite:setPosition(self.sprite:getPosition())
	self.sprite:getParent():addChild(deadSprite, 3)
	local parent = self.sprite:getParent()
	parent:removeChild(self.sprite)
	deadSprite:runAction(cc.Sequence:create( cc.FadeIn:create(0.2), cc.Spawn:create(cc.MoveBy:create(2, cc.p(0, 20)), cc.FadeOut:create(2)), cc.CallFunc:create(selfRemoveSprite, self)))
end

--显示检查周围的动画
function ManSprite:runCheckAnimate(x, y)
	local checkSprite = cc.Sprite:create("effect/sight.png")
	checkSprite:setAnchorPoint(0, 0)
	local manX, manY = self:getPosition()
	checkSprite:setPosition(manX + x, manY - 40 + y)
	self.sprite:getParent():addChild(checkSprite, 0)
	checkSprite:runAction(cc.Sequence:create( cc.FadeIn:create(1 / (2 * self.speed)), cc.FadeOut:create(1 / (2 * self.speed)), cc.CallFunc:create(selfRelease)))
end

--让人近程攻击
function ManSprite:runAttackAnimate(dir)	
	self.sprite:runAction(cc.RepeatForever:create(self.res:getAttackAnimate(self.isInfected, dir)))
end
