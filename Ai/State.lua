require "Util/logUtil"

State = class("State")

function State:create()
	local s = State.new()
	return s
end

function State:handle(character)
end
