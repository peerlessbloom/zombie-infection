--控制Zombie类的所有资源

require "Res/CharacterRes"

ZombieRes = class("ZombieRes", function() return CharacterRes.new() end)
function ZombieRes:create()
	local m = ZombieRes.new()
	m:init()
	return m
end

function ZombieRes:init()
	self.sprite = cc.Sprite:create("sprite/z/d_1.png")
	self.sprite:setAnchorPoint(0, 0.5)
	self:initAnimation()
	self.sprite:retain()
end

function ZombieRes:delete()
	for k, v in pairs(self.animations) do
		self.animations[k]:release()
	end
	
	for k, v in pairs(self.attacks) do
		self.attacks[k]:release()
	end
	
	self.hurts:release()
	self.sprite:release()
end

-----------------加载动画--------------------
function ZombieRes:initAnimation()
	--走路动画
	self.animations = {}
	local animateAry = 
	{d1 = {"sprite/z/d_1.png", "sprite/z/d_2.png"},
	 u1 = {"sprite/z/u_1.png", "sprite/z/u_2.png"},
	 d2 = {"sprite/z/d_1.png","sprite/z/d_3.png"},
	 u2 = {"sprite/z/u_1.png","sprite/z/u_3.png"},
	 l = {"sprite/z/l_1.png", "sprite/z/l_2.png"},
	 r = {"sprite/z/r_1.png", "sprite/z/r_2.png"}
	}
	for k, v in pairs(animateAry) do
		local animation = cc.Animation:create()
		for j =1, #(v) do
			animation:addSpriteFrameWithFile(v[j])
		end
		animation:setDelayPerUnit(1 / 2)
		animation:setRestoreOriginalFrame(true)
		self.animations[k] = animation
		self.animations[k]:retain()
	end
	
	--攻击动画
	self.attacks = {}
	local attackAry = 
	{d = {"sprite/z/attack/d_1.png", "sprite/z/attack/d_2.png"},
	 u = {"sprite/z/attack/u_1.png", "sprite/z/attack/u_2.png"},
	 l = {"sprite/z/attack/l_1.png", "sprite/z/attack/l_2.png"},
	 r = {"sprite/z/attack/r_1.png", "sprite/z/attack/r_2.png"}
	}
	
	for k, v in pairs(attackAry) do
		local animation = cc.Animation:create()
		for j =1, #(v) do
			animation:addSpriteFrameWithFile(v[j])
		end
		animation:setDelayPerUnit(1 / 2)
		animation:setRestoreOriginalFrame(true)
		self.attacks[k] = animation
		self.attacks[k]:retain()
	end
	
	--受伤动画
	self.hurts = {}
	local hurtAry = {"effect/attack1.png", "effect/attack2.png","effect/attack3.png","effect/attack4.png"}
	local animation = cc.Animation:create()
	for k, v in pairs(hurtAry) do
		animation:addSpriteFrameWithFile(v)
	end
	animation:setDelayPerUnit(1 / 2)
	animation:setRestoreOriginalFrame(true)
	self.hurts = cc.Animate:create(animation)
	self.hurts:retain()
end

-----------------获取动画----------------------
function ZombieRes:setAnimateSpeed(speed)
	for k, v in pairs(self.animations) do
		self.animations[k]:setDelayPerUnit(1 / (2 * speed)) --2 frames 
	end
	for k, v in pairs(self.attacks) do
		self.attacks[k]:setDelayPerUnit(1 / (3 * speed)) --3 frames 
	end
end
	
--攻击动画
function ZombieRes:getAttackAnimate(dir)
	return cc.Animate:create(self.attacks[dir]) 
end

--受伤动画
function ZombieRes:getHurtAnimate()
	return self.hurts
end

--走路动画
function ZombieRes:getAnimate(dir)
	if dir == "l" or dir == "r" then 
		return cc.Animate:create(self.animations[dir]) 
	end
	if isLeftStep then dir = dir.."1" else dir = dir.."2" end
	return cc.Animate:create(self.animations[dir])
end

------------------获取血条------------------------
function ZombieRes:getLifeBar(curlife, totallife)
	local layer = cc.Sprite:create()
	local draw = cc.DrawNode:create()
    layer:addChild(draw, 1)
	draw:drawSolidRect(cc.p(0,0), cc.p(40,8), cc.c4f(0,0.5,1,1))
	local w = 40 * curlife / totallife
	draw:drawSolidRect(cc.p(0,0), cc.p(w,8), cc.c4f(1,0,0,1))
	local stateSet = {string.format("%d/%d", curlife, totallife)}
	local state = self:getLabel(stateSet, "fonts/arial.ttf", 10)
	state:setAnchorPoint( 0, 0 )
	state:setPosition( 8, -2 )
    state:setColor(cc.c3b(0, 0, 0))
	layer:addChild(state,1)
	
	layer:setAnchorPoint( 0, 1 )
	layer:setPosition( 0, 62 )
	return layer
end