CollideUtil = class ("CollideUtil")

--这里的位置是映射到像素的位置
function CollideUtil:getDir(x1, y1, x2, y2)
	if y1 == y2 and x1 < x2 then return "r" end
	if y1 == y2 and x1 > x2 then return "l" end
	if x1 == x2 and y1 < y2 then return "u" end
	if x1 == x2 and y1 > y2 then return "d" end
	return "d"
end

function CollideUtil:getDist(x1, y1, x2, y2)
	local difx = x1 - x2
	local dify = y1 - y2
	return math.sqrt(difx * difx + dify * dify)
end

--map中的相对距离
function CollideUtil:getMapDist(x1, y1, x2, y2)
	local difx = math.abs(x1 - x2)
	local dify = math.abs(y1 - y2)
	return math.max(difx, dify)
end

--map中的相对位置
function CollideUtil:getMapDir(x1, y1, x2, y2)
	if y1 == y2 and x1 < x2 then return "r" end
	if y1 == y2 and x1 > x2 then return "l" end
	if y1 < y2 then return "d" end
	if y1 > y2 then return "u" end
	return "d"
end

function CollideUtil:convertDir(deltaX, deltaY)
	if deltaY == 0 and deltaX < 0 then return "r" end
	if deltaY == 0 and deltaX > 0 then return "l" end
	if deltaY < 0 then return "d" end
	if deltaY > 0 then return "u" end
	return "d"
end

function CollideUtil:getNextMapPos(x, y, dir)
	if dir == "u" then	return {x, y - 1}
	elseif dir == "d" then return {x, y + 1}
	elseif dir == "l" then return {x - 1, y}
	elseif dir == "r" then return {x + 1, y}
	else return {x,y} end
end