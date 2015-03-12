require "Res/GameRes"

SuccessScene = class("SuccessScene")

function SuccessScene:create()
	local s = SuccessScene.new()
	s:init()
	return s.scene
end


function SuccessScene:init()
	self.scene = cc.Scene:create()
	local bg = GameRes:getInstance().bgGray
	bg:setAnchorPoint( 0, 0 )
	self.scene:addChild(bg, 0)
	local tt = GameRes:getInstance().title1
	tt:setPosition(200, 500)
	tt:setAnchorPoint( 0, 0 )
	self.scene:addChild(tt, 1)
	local s = GameRes:getInstance().success
	s:setPosition(300, 300)
	s:setAnchorPoint( 0, 0 )
	self.scene:addChild(s, 1)

	local function goHome()
		cc.Director:getInstance():popScene()
	end
		
	GameRes:getInstance():registerHomeFun(goHome)
	local home = GameRes:getInstance():getHomeMenu()
	home:setPosition(850, 550)
	self.scene:addChild(home)	
end
	