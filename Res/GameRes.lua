--��Ϸ�������棬���������Դ
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
	--������Դ������zombie, man, superman����Դ
	self.otherRes = {}
	
	--��ʼ���˵���
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
	
	--������ҳ
	self.homeItem = cc.MenuItemImage:create("stage/home.png", "stage/home.png")
	self.homeItem:setPosition(0, 0)
	self.homeItem:retain()
	
	--����
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
	
	--�˳���ť
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
	
	--�������Ķ���
	self.blood = cc.Sprite:create("effect/blood.png")
	self.blood:setOpacity(0)
	self.blood:retain()
	
	--����ڵ�ͼ�е�λ�õ�hash:<sprite, pos>, pos��1��ʼ����������ʾλ��
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

--------------------------������Ϣ��---------------------------
--ľͷ����Ϣ��
function GameRes:getMessageBox(content)
	local layer = cc.Sprite:create("stage/message.png")
    --layer:addChild(self.msg, 1)
	
	--д����
	local message = self:getLabel(content, "fonts/msyh.ttf", 20, cc.c3b(0, 0, 0), 240)
	message:setPosition( 70, 190 )
	layer:addChild(message,2)
	return layer
end

--RPG̸���ı�����
function GameRes:getTalkBox(content, x)
	if x == nil then x = 0 end
	local layer = cc.Sprite:create()
	--���Ʊ���
	local draw = cc.DrawNode:create()
    layer:addChild(draw, 1)
	draw:drawRect(cc.p(0,0), cc.p(900,300), cc.c4f(0,0,0,0.9))
	draw:drawSolidRect(cc.p(0,0), cc.p(900,300), cc.c4f(0,0,0,0.7))

	--д����
	local message = self:getLabel(content, "fonts/msyh.ttf", 20, cc.c3b(255, 255, 255), 600)
	message:setPosition( 40 + x, 200 )
	layer:addChild(message,2)
	return layer
end

----------------------------����-----------------------------------------
function GameRes:getLabel(content, fontPath, fontSize, color, width)
	local ttfConfig = {}
    ttfConfig.fontFilePath=fontPath
    ttfConfig.fontSize = fontSize
	local say = cc.Label:createWithTTF(ttfConfig, content, cc.VERTICAL_TEXT_ALIGNMENT_CENTER, width)
    say:setAnchorPoint( 0, 1 )
    say:setColor(color)
	return say
end

-----------------------------�˵�----------------------------------------
--�ؿ��˵�
function GameRes:registerFun(fun, index)
	self.villageMenuItem[index]:registerScriptTapHandler(fun)
end

function GameRes:getVillageMenu(index)
	local menu = cc.Menu:create(self.villageMenuItem[index])
	return menu
end
--���ܲ˵�
function GameRes:registerIntroFun(fun)
	self.introMenuItem:registerScriptTapHandler(fun)
end

function GameRes:getIntroMenu()
	local menu = cc.Menu:create(self.introMenuItem)
	return menu
end
--������ҳ�˵�
function GameRes:registerHomeFun(fun)
	self.homeItem:registerScriptTapHandler(fun)
end

function GameRes:getHomeMenu()
	local menu = cc.Menu:create(self.homeItem)
	return menu
end

------------------------------������Դ��----------------------
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



