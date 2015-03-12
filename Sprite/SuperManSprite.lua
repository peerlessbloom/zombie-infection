require "Res/SuperManRes"
require "Sprite/CharacterSprite"

SuperManSprite = class("SuperManSprite", function() return ManSprite.new() end)
function SuperManSprite:create(manRes, speed, life)
	local m = SuperManSprite.new()
	m:init(manRes, speed, life)
	return m
end


------------------sprite的封装------------------------


------------------运行动画--------------------






