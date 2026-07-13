function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function rem(x)
    return x - round(x)
end

function lerp(a, b, t)
    return (a + ((b - a) * t))
end

function centre_text(text, offset, top) 
    local left = (DRAW_WIDTH /2) - (FONT_x2:getWidth(text) / 2)
    love.graphics.print(text, FONT_x2, left + offset, top)
end

function update_draw_scaling()
    DRAW_SCALE = love.graphics.getWidth() / DRAW_WIDTH
    if (DRAW_SCALE - math.floor(DRAW_SCALE) ~= 0) then
        local height = DRAW_HEIGHT * DRAW_SCALE
        print(tostring(height) .. " " .. tostring(love.graphics.getHeight()))
        VIEWPORT_Y = (love.graphics.getHeight() - height) / 2
    else
        VIEWPORT_Y = 0
    end

    if (VIEWPORT_BUF) then
        VIEWPORT_BUF:release()
    end
    
    VIEWPORT_BUF = love.graphics.newCanvas(DRAW_SCALE * DRAW_WIDTH, DRAW_SCALE * DRAW_HEIGHT)
end

function toggle_fullscreen()
    love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
    update_draw_scaling()
end

function count_all(f)
    local seen = {}
	local count_table
	count_table = function(t)
		if seen[t] then return end
		f(t)
		seen[t] = true
		for k,v in pairs(t) do
			if type(v) == "table" then
				count_table(v)
			elseif type(v) == "userdata" then
				f(v)
			end
		end
	end
	count_table(_G)
end

function type_count()
	local counts = {}
	local enumerate = function (o)
		local t = type_name(o)
		counts[t] = (counts[t] or 0) + 1
	end
	count_all(enumerate)
	return counts
end

global_type_table = nil
function type_name(o)
	if global_type_table == nil then
		global_type_table = {}
		for k,v in pairs(_G) do
			global_type_table[v] = k
		end
		global_type_table[0] = "table"
	end
	return global_type_table[getmetatable(o) or 0] or "Unknown"
end