--控制Man类的所有资源

require "Res/CharacterRes"

ManRes = class("ManRes", function() return CharacterRes.new() end)
function ManRes:create(manNum)
	local m = ManRes.new()
	m:init(manNum)
	return m
end

function ManRes:init(manNum)
	self.sprites = {}--普通状态
	self.iSprites = {}--感染状态
	--被盯上了
	self.alertSprite = cc.Sprite:create("effect/setEyes.png")
	self.alertSprite:retain()
	--初始化所有人的显示资源
	--TODO:batch sprite
	for i = 1, manNum do
		local curSprite = cc.Sprite:create("sprite/m1/d_1.png")
		curSprite:setAnchorPoint(0, 0.5)
		curSprite:retain()
		table.insert(self.sprites, curSprite)
		local curiSprite = cc.Sprite:create("sprite/m1/i_d_1.png")
		curiSprite:setAnchorPoint(0, 0.5)
		curiSprite:retain()
		table.insert(self.iSprites, curiSprite)
	end
	self.poolSize = manNum
	self.cur = 1
	self:initAnimation()
end

function ManRes:delete()
	for i = 1,2 do
		for k, v in pairs(self.animations[i]) do
			self.animations[i][k]:release()
		end
		for k, v in pairs(self.attacks[i]) do
			self.attacks[i][k]:release()
		end
		self.hurts[i]:release()
	end
	self.alertSprite:release()
	for i = 1, self.poolSize do
		self.sprites[i]:release()
		self.iSprites[i]:release()
	end
end


--请求资源，返回资源以及资源号
function ManRes:requireRes()
	if self.cur > self.poolSize then
		return nil, 0
	end
	local resNum = self.cur
	self.cur = self.cur + 1
	return resNum
end

function ManRes:getRes(resNum, isInfected)
	if isInfected then return self.iSprites[resNum]
	else return self.sprites[resNum] end
end

-----------------加载动画--------------------
function ManRes:initAnimation()
	--走路动画
	self.animations = {}
	local animateAry = 
	{
	{d1 = {"sprite/m1/d_1.png", "sprite/m1/d_2.png"},
	 u1 = {"sprite/m1/u_1.png", "sprite/m1/u_2.png"},
	 d2 = {"sprite/m1/d_1.png","sprite/m1/d_3.png"},
	 u2 = {"sprite/m1/u_1.png","sprite/m1/u_3.png"},
	 l = {"sprite/m1/l_1.png", "sprite/m1/l_2.png"},
	 r = {"sprite/m1/r_1.png", "sprite/m1/r_2.png"}
	},
	{d1 = {"sprite/m1/i_d_1.png", "sprite/m1/i_d_2.png"},
	 u1 = {"sprite/m1/i_u_1.png", "sprite/m1/i_u_2.png"},
	 d2 = {"sprite/m1/i_d_1.png","sprite/m1/i_d_3.png"},
	 u2 = {"sprite/m1/i_u_1.png","sprite/m1/i_u_3.png"},
	 l = {"sprite/m1/i_l_1.png", "sprite/m1/i_l_2.png"},
	 r = {"sprite/m1/i_r_1.png", "sprite/m1/i_r_2.png"}
	}
	}
	
	for i = 1,2 do
		self.animations[i] = {}
		for k, v in pairs(animateAry[i]) do
			local animation = cc.Animation:create()
			for j =1, #(v) do
				animation:addSpriteFrameWithFile(v[j])
			end
			animation:setDelayPerUnit(1 / 2)
			animation:setRestoreOriginalFrame(true)
			self.animations[i][k] = animation
			self.animations[i][k]:retain()
		end
	end
	
	--攻击动画
	self.attacks = {}
	local attackAry = 
	{
	{d = {"sprite/m1/attack/d_1.png", "sprite/m1/attack/d_2.png"},
	 u = {"sprite/m1/attack/u_1.png", "sprite/m1/attack/u_2.png"},
	 l = {"sprite/m1/attack/l_1.png", "sprite/m1/attack/l_2.png"},
	 r = {"sprite/m1/attack/r_1.png", "sprite/m1/attack/r_2.png"}
	},
	{d = {"sprite/m1/attack/i_d_1.png", "sprite/m1/attack/i_d_2.png"},
	 u = {"sprite/m1/attack/i_u_1.png", "sprite/m1/attack/i_u_2.png"},
	 l = {"sprite/m1/attack/i_l_1.png", "sprite/m1/attack/i_l_2.png"},
	 r = {"sprite/m1/attack/i_r_1.png", "sprite/m1/attack/i_r_2.png"}
	}
	}
	
	for i = 1,2 do
		self.attacks[i] = {}
		for k, v in pairs(attackAry[i]) do
			local animation = cc.Animation:create()
			for j =1, #(v) do
				animation:addSpriteFrameWithFile(v[j])
			end
			animation:setDelayPerUnit(1 / 2)
			animation:setRestoreOriginalFrame(true)
			self.attacks[i][k] = animation
			self.attacks[i][k]:retain()
		end
	end
	
	--受伤动画
	self.hurts = {}
	local hurtAry = {
		{"effect/attack1.png", "effect/attack2.png","effect/attack3.png","effect/attack4.png"},
		{"effect/z_attack1.png", "effect/z_attack2.png","effect/z_attack3.png"}
		}
	for i = 1,2 do
		local animation = cc.Animation:create()
		for k, v in pairs(hurtAry[i]) do
			animation:addSpriteFrameWithFile(v)
		end
		animation:setDelayPerUnit(1 / 2)
		animation:setRestoreOriginalFrame(true)
		self.hurts[i] = cc.Animate:create(animation)
		self.hurts[i]:retain()
	end
end

-----------------获取动画----------------------
--设置动画速度
function ManRes:setAnimateSpeed(speed)
	for i = 1,2 do
		for k, v in pairs(self.animations[i]) do
			self.animations[i][k]:setDelayPerUnit(1 / (2 * speed)) --2 frames 
		end
	end
	
	for i = 1,2 do
		for k, v in pairs(self.attacks[i]) do
			self.attacks[i][k]:setDelayPerUnit(1 / (2 * speed)) --4 frames 
		end
	end
end

--走路动画
function ManRes:getAnimate(infected, dir, isLeftStep)
	local animations = nil
	if infected then animations = self.animations[2]
	else animations = self.animations[1] end
	
	if dir == "l" or dir == "r" then 
		return cc.Animate:create(animations[dir])
	end
	if isLeftStep then dir = dir.."1" else dir = dir.."2" end
	return cc.Animate:create(animations[dir])
end

--攻击动画
function ManRes:getAttackAnimate(infected, dir)
	local animations = nil
	if infected then animations = self.attacks[2]
	else animations = self.attacks[1] end
	
	return cc.Animate:create(animations[dir])
end

--受伤动画
function ManRes:getHurtAnimate(infected)
	if infected then return self.hurts[2]
	else return self.hurts[1] end
end

------------------加载血条---------------------
function ManRes:getLifeBar(curlife, totallife)
	local layer = cc.Sprite:create()
	local draw = cc.DrawNode:create()
    layer:addChild(draw, 1)
	draw:drawSolidRect(cc.p(0,0), cc.p(40,8), cc.c4f(1,0,0.5,1))
	local w = 40 * curlife / totallife
	draw:drawSolidRect(cc.p(0,0), cc.p(w,8), cc.c4f(0,1,0,1))
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
