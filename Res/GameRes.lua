--游戏启动画面，主界面的资源
GameRes = class("GameRes")

function GameRes:getInstance()
	if self.res == nil then
		self.res = GameRes.new()
		self.res:init()
	end
	return self.res
end

function GameRes:init()
	self.bg = cc.Sprite:create("stage/bg.png")
	self.title = cc.Sprite:create("stage/title.png")
	self.title1 = cc.Sprite:create("stage/title1.png")
	self.bgGray = cc.Sprite:create("stage/bg1.png")
	self.mBgGray = cc.Sprite:create("stage/select1.jpg")
	self.cvsts = {cc.Sprite:create("stage/a.png"), cc.Sprite:create("stage/b.png")}
	self.success = cc.Sprite:create("stage/success.png")
	self.failure = cc.Sprite:create("stage/failure.png")
	--self.msg = cc.Sprite:create("stage/message.png")
	self.bg:retain()
	self.bgGray:retain()
	self.title:retain()
	self.title1:retain()
	self.mBgGray:retain()
	self.success:retain()
	self.failure:retain()
	--self.msg:retain()
	self.cvsts[1]:retain()
	self.cvsts[2]:retain()
	--其他资源，包含zombie, man, superman的资源
	self.otherRes = {}
	
	--初始化菜单项
	self.villageMenuItem = {}
	local menuImgPath = {{"stage/s11.png", "stage/s1.png"}, {"stage/s22.png", "stage/s2.png"}}
	for i = 1, #(menuImgPath) do
		local menuItem = cc.MenuItemImage:create(menuImgPath[i][1], menuImgPath[i][2])
		menuItem:setPosition(0, 0)
		menuItem:retain()
		table.insert(self.villageMenuItem, menuItem)
	end
	
	self.introMenuItem = cc.MenuItemImage:create("stage/z11.png", "stage/z1.png")
	self.introMenuItem:setPosition(0, 0)
	self.introMenuItem:retain()
	
	--返回主页
	self.homeItem = cc.MenuItemImage:create("stage/home.png", "stage/home.png")
	self.homeItem:setPosition(0, 0)
	self.homeItem:retain()
	
	--音乐
	local effectPath = cc.FileUtils:getInstance():fullPathForFilename("stage/loop_soft.mp3")
    cc.SimpleAudioEngine:getInstance():preloadEffect(effectPath)
	local effectID = cc.SimpleAudioEngine:getInstance():playEffect(effectPath, true)
	
	local function stopBGM()
		cc.SimpleAudioEngine:getInstance():stopEffect(effectID)
		self.mStart:setVisible(true)
		self.mStop:setVisible(false)
	end

	local function startBGM()
		cc.SimpleAudioEngine:getInstance():playEffect(effectPath, true)
		self.mStart:setVisible(false)
		self.mStop:setVisible(true)
	end
	local mStartItem = cc.MenuItemImage:create("stage/m1.png", "stage/m1.png")
	local mStopItem = cc.MenuItemImage:create("stage/m2.png", "stage/m2.png")
	mStartItem:setPosition(0, 0)
	mStopItem:setPosition(0, 0)		
	mStartItem:registerScriptTapHandler(startBGM)
	mStopItem:registerScriptTapHandler(stopBGM)
	
	self.mStart = cc.Menu:create(mStartItem)
	self.mStart:retain()
	self.mStart:setVisible(false)
	self.mStop = cc.Menu:create(mStopItem)
	self.mStop:retain()
	
	--退出按钮
	local function quitGame()
		cc.Director:getInstance():popScene()
		self:delete()
		cc.Director:getInstance():endToLua()
	end
	local quitItem = cc.MenuItemImage:create("stage/q.png", "stage/q.png")
	quitItem:setPosition(0, 0)
	quitItem:registerScriptTapHandler(quitGame)
	self.quitMenu = cc.Menu:create(quitItem)
	self.quitMenu:retain()
	
	--鼠标所点的东西
	self.blood = cc.Sprite:create("effect/blood.png")
	self.blood:setOpacity(0)
	self.blood:retain()
	
	--存放在地图中的位置的hash:<sprite, pos>, pos从1开始，递增，表示位置
	self.mapOrder = {}
	self.mapOrder["pos"] = 1
end

function GameRes:delete()
	self.bg:release()
	self.bgGray:release()
	self.title:release()
	self.title1:release()
	self.mBgGray:release()
	self.success:release()
	self.failure:release()
	--self.msg:release()
	self.cvsts[1]:release()
	self.cvsts[2]:release()
	self.introMenuItem:release()
	self.homeItem:release()
	self.quitMenu:release()
	
	for i = 1, #(self.villageMenuItem) do
		self.villageMenuItem[i]:release()
	end
	
	self.mStart:release()
	self.mStop:release()
	
	self.blood:release()
end

--------------------------绘制信息框---------------------------
--木头的消息框
function GameRes:getMessageBox(content)
	local layer = cc.Sprite:create("stage/message.png")
    --layer:addChild(self.msg, 1)
	
	--写文字
	local message = self:getLabel(content, "fonts/msyh.ttf", 20, cc.c3b(0, 0, 0), 240)
	message:setPosition( 70, 190 )
	layer:addChild(message,2)
	return layer
end

--RPG谈话的背景框
function GameRes:getTalkBox(content, x)
	if x == nil then x = 0 end
	local layer = cc.Sprite:create()
	--绘制背景
	local draw = cc.DrawNode:create()
    layer:addChild(draw, 1)
	draw:drawRect(cc.p(0,0), cc.p(900,300), cc.c4f(0,0,0,0.9))
	draw:drawSolidRect(cc.p(0,0), cc.p(900,300), cc.c4f(0,0,0,0.7))

	--写文字
	local message = self:getLabel(content, "fonts/msyh.ttf", 20, cc.c3b(255, 255, 255), 600)
	message:setPosition( 40 + x, 200 )
	layer:addChild(message,2)
	return layer
end

----------------------------文字-----------------------------------------
function GameRes:getLabel(content, fontPath, fontSize, color, width)
	local ttfConfig = {}
    ttfConfig.fontFilePath=fontPath
    ttfConfig.fontSize = fontSize
	local say = cc.Label:createWithTTF(ttfConfig, content, cc.VERTICAL_TEXT_ALIGNMENT_CENTER, width)
    say:setAnchorPoint( 0, 1 )
    say:setColor(color)
	return say
end

-----------------------------菜单----------------------------------------
--关卡菜单
function GameRes:registerFun(fun, index)
	self.villageMenuItem[index]:registerScriptTapHandler(fun)
end

function GameRes:getVillageMenu(index)
	local menu = cc.Menu:create(self.villageMenuItem[index])
	return menu
end
--介绍菜单
function GameRes:registerIntroFun(fun)
	self.introMenuItem:registerScriptTapHandler(fun)
end

function GameRes:getIntroMenu()
	local menu = cc.Menu:create(self.introMenuItem)
	return menu
end
--返回主页菜单
function GameRes:registerHomeFun(fun)
	self.homeItem:registerScriptTapHandler(fun)
end

function GameRes:getHomeMenu()
	local menu = cc.Menu:create(self.homeItem)
	return menu
end

------------------------------处理资源类----------------------
function GameRes:addRes(res)
	table.insert(self.otherRes, res)
end

function GameRes:deleteOtherRes()
	for i = 1, #(self.otherRes) do
		self.otherRes[i]:delete()
	end
	self.otherRes = {}
	self.mapOrder = {}
	self.mapOrder["pos"] = 1
end



