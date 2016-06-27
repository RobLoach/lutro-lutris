local lib = nil
if (love ~= nil) then
  lib = love
elseif (lutro ~= nil) then
  lib = lutro
end

-- Dependencies
require('vendor')
require('conf')

-- Load
function lib.load()
	-- Load the available games
	local success, result = pcall(getInstalledGames)
	if success then
		games = result
	else
		games = {}
	end

	-- Allow the user to launch Lutro.
	table.insert(games, 1, {
		slug = '',
		name = 'Launch Lutris',
	})

	-- Allow the user to launch Lutro.
	table.insert(games, {
		slug = 'quit',
		name = 'Quit Lutris Launcher',
	})

	-- Initialization
	if (lutro ~= nil) then
		font = lutro.graphics.newImageFont("resources/sofia24.png",
		" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
		lib.graphics.setFont(font)
	end

	-- Background
	lib.graphics.setBackgroundColor(1, 53, 146)
	bg = lutro.graphics.newImage("resources/bg.png")

	lineHeight = 30
	currentSelection = 1

	logo = lib.graphics.newImage('resources/logo.png')
end

-- Draw
function lib.draw()
	lutro.graphics.clear()
	lutro.graphics.draw(bg, 0, 0)
	lib.graphics.draw(logo, lineHeight, lineHeight)

	-- Show each game.
	local y = lineHeight * 4
	for i, game in ipairs(games) do
		-- Display the menu cursor if needed
		if currentSelection == i then
			lib.graphics.rectangle('fill', 256 + lineHeight * 2, y + lineHeight / 4, lineHeight / 3, lineHeight / 3)
		end
		-- Display the menu item
		lib.graphics.print(game.name, 256 + lineHeight * 3, y)
		y = y + lineHeight
	end
end

-- Process input
function lib.keypressed(key)
	if key == "down" then
		currentSelection = currentSelection + 1
		if currentSelection > table.getn(games) then
			currentSelection = table.getn(games)
		end
	elseif key == "up" then
		currentSelection = currentSelection - 1
		if currentSelection < 1 then
			currentSelection = 1
		end
	elseif key == "return" or key == "x" then
		game = games[currentSelection]
		launchGame(game.slug)
	end
end

-- Launch the given game slug through Lutris.
function launchGame(slug)
	if (slug == 'quit') then
		lib.event.quit(0)
	else
		os.execute('lutris lutris:' .. game.slug .. ' &')
		--local f = io.popen('lutris lutris:' .. slug)
		--f:close()
	end
end

-- Retrieve the installed Lutro games.
function getInstalledGames()
	-- Dependencies
	local json = require('lunajson')

	-- Load installed Lutris games
	local output = capture('lutris --json --list-games --installed')
	return json.decode(output)
end

-- Capture the standard output from running an executable.
function capture(cmd, raw)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then return s end
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end
