--控制SuperMan类的所有资源

require "Res/ManRes"

SuperManRes = class("SuperManRes", function() return ManRes.new() end)
function SuperManRes:create(manNum)
	local m = SuperManRes.new()
	m:init(manNum)
	return m
end

function SuperManRes:init(manNum)
	self.sprites = {}--普通状态
	self.iSprites = {}--感染状态
	--被盯上了
	self.alertSprite = cc.Sprite:create("effect/setEyes.png")
	self.alertSprite:retain()
	--TODO:batch sprite
	for i = 1, manNum do
		local curSprite = cc.Sprite:create("sprite/m2/d_1.png")
		curSprite:setAnchorPoint(0, 0.5)
		curSprite:retain()
		table.insert(self.sprites, curSprite)
		local curiSprite = cc.Sprite:create("sprite/m2/i_d_1.png")
		curiSprite:setAnchorPoint(0, 0.5)
		curiSprite:retain()
		table.insert(self.iSprites, curiSprite)
	end
	self.poolSize = manNum
	self.cur = 1
	self:initAnimation()
end

-----------------加载动画--------------------
function SuperManRes:initAnimation()
	self.animations = {}
	local animateAry = 
	{
	{d1 = {"sprite/m2/d_1.png", "sprite/m2/d_2.png"},
	 u1 = {"sprite/m2/u_1.png", "sprite/m2/u_2.png"},
	 d2 = {"sprite/m2/d_1.png","sprite/m2/d_3.png"},
	 u2 = {"sprite/m2/u_1.png","sprite/m2/u_3.png"},
	 l = {"sprite/m2/l_1.png", "sprite/m2/l_2.png"},
	 r = {"sprite/m2/r_1.png", "sprite/m2/r_2.png"}
	},
	{d1 = {"sprite/m2/i_d_1.png", "sprite/m2/i_d_2.png"},
	 u1 = {"sprite/m2/i_u_1.png", "sprite/m2/i_u_2.png"},
	 d2 = {"sprite/m2/i_d_1.png","sprite/m2/i_d_3.png"},
	 u2 = {"sprite/m2/i_u_1.png","sprite/m2/i_u_3.png"},
	 l = {"sprite/m2/i_l_1.png", "sprite/m2/i_l_2.png"},
	 r = {"sprite/m2/i_r_1.png", "sprite/m2/i_r_2.png"}
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
	{d = {"sprite/m2/attack/d_1.png", "sprite/m2/attack/d_2.png"},
	 u = {"sprite/m2/attack/u_1.png", "sprite/m2/attack/u_2.png"},
	 l = {"sprite/m2/attack/l_1.png", "sprite/m2/attack/l_2.png"},
	 r = {"sprite/m2/attack/r_1.png", "sprite/m2/attack/r_2.png"}
	},
	{d = {"sprite/m2/attack/i_d_1.png", "sprite/m2/attack/i_d_2.png"},
	 u = {"sprite/m2/attack/i_u_1.png", "sprite/m2/attack/i_u_2.png"},
	 l = {"sprite/m2/attack/i_l_1.png", "sprite/m2/attack/i_l_2.png"},
	 r = {"sprite/m2/attack/i_r_1.png", "sprite/m2/attack/i_r_2.png"}
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

