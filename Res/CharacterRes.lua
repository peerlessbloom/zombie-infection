---------------------------------------------
--                 人物资源基类
---------------------------------------------

CharacterRes = class("CharacterRes")

function CharacterRes:init()
end

function CharacterRes:delete()
end

-----------------加载动画--------------------
function CharacterRes:initAnimation()
end

-----------------获取动画----------------------
--走路动画
function CharacterRes:getAnimate()
end

----------------加载文字---------------------
function CharacterRes:getLabel(wordSet, fontPath, fontSize)
	if fontSize == nil then fontSize = 16 end
	local ttfConfig = {}
    ttfConfig.fontFilePath=fontPath
    ttfConfig.fontSize = fontSize
	local say = cc.Label:createWithTTF(ttfConfig, wordSet[math.random(#(wordSet))], cc.VERTICAL_TEXT_ALIGNMENT_CENTER, 80)
    return say
end