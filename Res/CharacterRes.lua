---------------------------------------------
--                 ������Դ����
---------------------------------------------

CharacterRes = class("CharacterRes")

function CharacterRes:init()
end

function CharacterRes:delete()
end

-----------------���ض���--------------------
function CharacterRes:initAnimation()
end

-----------------��ȡ����----------------------
--��·����
function CharacterRes:getAnimate()
end

----------------��������---------------------
function CharacterRes:getLabel(wordSet, fontPath, fontSize)
	if fontSize == nil then fontSize = 16 end
	local ttfConfig = {}
    ttfConfig.fontFilePath=fontPath
    ttfConfig.fontSize = fontSize
	local say = cc.Label:createWithTTF(ttfConfig, wordSet[math.random(#(wordSet))], cc.VERTICAL_TEXT_ALIGNMENT_CENTER, 80)
    return say
end