require "Scene/GameScene"
require "Scene/IntroScene"
require "Res/GameRes"

MainScene = class("MainScene")

function MainScene:create()
	local s = MainScene.new()
	s:init()
	return s.scene
end


function MainScene:init()	
	self.scene = cc.Scene:create()
	local res = GameRes:getInstance()
	local bgGray = res.mBgGray
	bgGray:setAnchorPoint( 0, 0 )
	self.scene:addChild(bgGray, 0)
	
	-- create menu
    local function createMenu()
        local layerMenu = cc.Layer:create()
		
		local function goStage1()
			cc.Director:getInstance():pushScene(GameScene:create(1))
		end
		
		local function goStage2()
			cc.Director:getInstance():pushScene(GameScene:create(2))
		end
		
		local function goIntro()
			cc.Director:getInstance():pushScene(IntroScene:create())
		end

        --添加menuItem
		res:registerFun(goStage1, 1)
		res:registerFun(goStage2, 2)
		res:registerIntroFun(goIntro)
        local menu1 =res:getVillageMenu(1)
		local menu2 = res:getVillageMenu(2)
		local introMenu = res:getIntroMenu()
        menu1:setPosition(283, 170)
		menu2:setPosition(452, 164)
		introMenu:setPosition(813, 119)
        layerMenu:addChild(menu1)
		layerMenu:addChild(menu2)
		layerMenu:addChild(introMenu)
		
		--播放背景音乐
		res.mStart:setPosition(810, 550)
		res.mStop:setPosition(810, 550)
		layerMenu:addChild(res.mStop)
		layerMenu:addChild(res.mStart)
		
		res.quitMenu:setPosition(860, 550)
		layerMenu:addChild(res.quitMenu)
		
        return layerMenu
    end
	
	self.scene:addChild(createMenu())
end


	