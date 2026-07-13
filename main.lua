Input = require 'libraries.boipushy.Input'
Object = require 'libraries.classic.classic'
ECS = require 'libraries.concord'
sti = require 'libraries.sti'
wf = require 'libraries.windfield'
anim8 = require 'libraries.anim8'
loveli = require 'libraries.LOVELi'
lume = require 'libraries.lume'

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")

require 'globals'
require 'assets'
require 'utils'

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end
end

function love.load(arg)
	load_data()

    input = Input()
    init_input()

	local object_files = {}
    recursive_enumerate('framework', object_files)
    require_files(object_files)

	recursive_enumerate('rooms', object_files)
    require_files(object_files)

	ECS.utils.loadNamespace("ecs/")
	ECS.utils.loadNamespace("ecs/systems/")

	local flags = {}
	flags.vsync = love.window.getVSync()
	love.window.setMode(DRAW_WIDTH * 4, DRAW_HEIGHT * 4, flags)

	update_draw_scaling()

	current_room = nil
    go_to_room('TitleRoom')

	--tmp
	camera = Camera(DRAW_WIDTH+16, DRAW_HEIGHT+16)
end

function love.update(dt)
	if current_room then 
        current_room:update(dt) 
    end

	if input:pressed('debug') then
		DEBUG = not DEBUG
	elseif input:pressed('quit') then
		love.event.quit()
	elseif input:pressed('count_objects') then
        print("Before collection: " .. collectgarbage("count")/1024)
        collectgarbage()
        print("After collection: " .. collectgarbage("count")/1024)
        print("Object count: ")
        local counts = type_count()
        for k, v in pairs(counts) do print(k, v) end
        print("-------------------------------------")
	end
end

function love.draw()
	love.graphics.setCanvas(DRAW_BUF)
		love.graphics.clear(0, 0, 0, 1)
		current_room:draw()

	love.graphics.setCanvas()
		love.graphics.draw(DRAW_BUF, 0, 0, 0, DRAW_SCALE, DRAW_SCALE)
end

function love.keypressed(key, scancode, isrepeat)
	if current_room.keypressed then
		current_room:keypressed(key, scancode, isrepeat)
	end
end

function love.quit()
	save_data()
end

function init_input()
	input:bind('escape', 'quit')

	input:bind('w', 'up_action')
	input:bind('up', 'up_action')
	
	input:bind('a', 'left')
	input:bind('left', 'left')
	input:bind('d', 'right')
	input:bind('right', 'right')

	input:bind('s', 'down_action')
	input:bind('down', 'down_action')

	input:bind('k', 'attact')
	input:bind('j', 'jump')
	input:bind('j', 'accept_action')
	input:bind('e', 'accept_action')

	input:bind('escape', 'ui_cancel')
	input:bind('space', 'jump')

	input:bind('n', 'debug')
	input:bind('lshift', 'sprint')
	input:bind('f1', 'count_objects')
end

function recursive_enumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        local fileInfo = love.filesystem.getInfo(file)
        if fileInfo.type == "file" then
            table.insert(file_list, file)
        elseif fileInfo.type == "directory" then
            recursive_enumerate(file, file_list)
        end
    end
end

function require_files(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
		print('file ', file)
        require(file)
    end
end

function go_to_room(room_type, ...)
	if current_room and current_room.destroy then current_room:destroy() end
    current_room = _G[room_type](...)
end

function load_data()
    local contents, _ = love.filesystem.read("game.save")
    if contents then
		local deserialized_data = lume.deserialize(contents)
		GAME_DATA.AUDIO_VOLUME = deserialized_data.AUDIO_VOLUME
		GAME_DATA.MUSIC_VOLUME = deserialized_data.MUSIC_VOLUME
	end
end

function save_data()
	local serialized_data = lume.serialize(GAME_DATA)
	love.filesystem.write("game.save", serialized_data)
end