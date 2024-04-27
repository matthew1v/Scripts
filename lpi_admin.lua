local BuildingToolsExploiter = {};
local lplr = game.Players.LocalPlayer

function getItem(item)
	if lplr.Backpack:FindFirstChild(item) then
		return lplr.Backpack:FindFirstChild(item)
	end

	if lplr.Character:FindFirstChild(item) then
		return lplr.Character:FindFirstChild(item)
	end

	return nil
end

do
	local ToolExploiter = {}
	ToolExploiter.__index = ToolExploiter

	function invokeRemote(remote, ...)
		if remote:IsA("RemoteEvent") then
			remote:FireServer(...)
		elseif remote:IsA("RemoteFunction") then
			remote:InvokeServer(...)
		end
	end

	function BuildingToolsExploiter.new()
		return setmetatable({
			instance = getItem("F3X") or getItem("Building Tools");
		}, ToolExploiter)
	end

	function ToolExploiter:Destroy(instance)
		if not self.instance then
			error("Failed to delete object, because F3X was not found!")
			return nil
		end

		task.spawn(function()
			local old = self.instance.Parent
			self.instance.Parent = lplr.Character
			invokeRemote(self.instance:FindFirstChildOfClass("BindableFunction"):FindFirstChildOfClass("RemoteFunction"), "UndoRemove", {instance})
			task.wait(1)
			self.instance.Parent = old
		end)
	end
end

local commands = {}

function getPlayer(name)
    local plrs = {}

    if name == "me" then
        table.insert(plrs, lplr)
        return plrs
    elseif name == "all" then
        return game.Players:GetPlayers()
    elseif name == "others" then
        for _, v in ipairs(game.Players:GetPlayers()) do
            if v ~= lplr then
                table.insert(plrs, v)
            end
        end
        return plrs
    else
        -- Look for players whose username matches or contains the provided name
        local lowerName = name:lower()
        for _, v in ipairs(game.Players:GetPlayers()) do
            if v.Name:lower():match(lowerName) then
                table.insert(plrs, v)
            end
        end
        return plrs
    end

    return plrs
end

function importCommand(command, aliases, func)
	commands[command] = {
		aliases = aliases,
		func = func
	}
end
local admins = {}
local adminconnections = {}

function say(msg)
	game.StarterGui:SetCore( "ChatMakeSystemMessage",  { Text = "[Vex Admin] " .. msg, Color = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Ubuntu, FontSize = Enum.FontSize.Size24 } )
end

say("Hello! Thanks for using Vex Admin.\nTo view commands, please type:\n!cmds\nPrefixes: !, ., ?\nExamples:\n?kick username\n.ban username\n!kill others\nSuffixes for targets: others, all, everyone, me, [username?]\nCheck out the commands by typing\n!cmds\n& then pressing F9 (to close press F9 again or press the X button on top right of the console menu)")

function chatted(message, rec)
	message = message:lower()
	local prefix = message:sub(1, 1)
	local command = message:sub(2, #message)
	local player = getPlayer(command:split(" ")[2])
	command = command:split(" ")[1]
	if prefix == "!" or prefix == "." or prefix == "?" then
		for name, commandcontents in next, commands do
			local foundalias = false
			if command == name then foundalias = true end
			for index, alias in next, commandcontents.aliases do
				if foundalias then break end
				if command == alias then
					foundalias = true
					break
				end
			end

			if foundalias then
				return pcall(function()
					commandcontents.func(player)
				end)
			end
		end
	end
end

importCommand("commands", {"cmds"}, function(players)
	print("Vex Admin [LPI]\nPrefixes: . ? !\nExample:\n?kill all\n.notools all\n!admin username\n\nCommands:" .. "\n" ..
		"admin [all? | others? | username] [aliases: rank]" ..
		"\n" .. "unadmin [all? | others? | username] [aliases: unrank, demote]" ..
		"\n" .. "kill [all? | others? | username] [aliases: respawn]" ..
		"\n" .. "removetools [all? | others? | username] [aliases: notools, remtools, rtools]" ..
		"\n" .. "permnotools [all? | others? | username] [aliases: premtools, prtools]"
	)
end)

importCommand("admin", {"rank"}, function(players)
	for i, v in next, players do
		if v == lplr then continue end
		if table.find(admins, v) then continue end
		if not table.find(admins, v) then
			table.insert(admins, v)
			adminconnections[v.UserId] = v.Chatted:Connect(chatted)
			say("Gave admin to " .. v.Name .. "!")
		end
	end
end)

importCommand("unadmin", {"unrank", "demote"}, function(players)
	for i, v in next, players do
		if v == lplr then continue end
		if table.find(admins, v) then
			table.remove(admins, table.find(admins, v))
			adminconnections[v.UserId]:Disconnect()
			adminconnections[v.UserId] = nil
			say("Removed admin from " .. v.Name .. "!")
		end
	end
end)

importCommand("kill", {"respawn"}, function(players)
	local F3X = BuildingToolsExploiter.new()
	for i, v in next, players do
		if v == lplr then continue end
		if table.find(admins, v) then continue end
		if v.Character ~= nil then
			F3X:Destroy(v.Character:FindFirstChild("Torso"):FindFirstChild("Neck"))
			F3X:Destroy(v.Character:FindFirstChild("Head"))
			say("Killed " .. v.Name .. "!")
		end
	end
end)

importCommand("removetools", {"notools", "remtools", "rtools"}, function(players)
	local F3X = BuildingToolsExploiter.new()
	for i, v in next, players do
		if v == lplr then continue end
		if table.find(admins, v) then continue end
		local connection
		task.spawn(function()
			task.wait(5)
			connection:Disconnect()
		end)
		connection = v.Character.ChildAdded:Connect(function(v)
			if v:IsA("Tool") then
				F3X:Destroy(v)
			end
		end)
		if v.Character ~= nil then
			for ii, vv in next, v.Character:GetChildren() do
				if vv:IsA("Tool") then
					F3X:Destroy(vv)
				end
			end
		end
		for ii, vv in next, v.Backpack:GetChildren() do
			if vv:IsA("Tool") then
				F3X:Destroy(vv)
			end
		end
		say("Removed all tools for " .. v.Name .. "!")
	end
end)

local notools = false
function permnotoolsplayer(player)
	local v = player
	if v == lplr then return end
	if table.find(admins, v) then return end
	player.Character.ChildAdded:Connect(function(item)
		local F3X = BuildingToolsExploiter.new()
		if item:IsA("Tool") then
			if notools then
				if v == lplr or table.find(admins, v) then return nil end
				F3X:Destroy(item)
			end
		end
	end)
	player.CharacterAdded:Connect(function(character)
		character.ChildAdded:Connect(function(item)
			local F3X = BuildingToolsExploiter.new()
			if item:IsA("Tool") then
				if notools then
					if v == lplr or table.find(admins, v) then return nil end
					F3X:Destroy(item)
				end
			end
		end)
	end)
end

for i, v in next, game:GetService("Players"):GetPlayers() do
	permnotoolsplayer(v)
end

local banned = {}
local delay2 = false
local serverlock = false
importCommand("serverlock", {"lockserver", "slock"}, function(players)
	if delay2 then return nil end
	delay2 = true
	serverlock = not serverlock
	say("Server lock is now toggled! [set: " .. (serverlock and "enabled" or "disabled") .. "]")
	task.wait(1)
	delay2 = false
end)
game.Players.PlayerAdded:Connect(function(v)
	if table.find(banned, v.Name) or serverlock then
		local F3X = BuildingToolsExploiter.new()
		F3X:Destroy(v)
	end
	permnotoolsplayer(v)
end)

local delay = false
importCommand("permnotools", {"premtools", "prtools"}, function(players)
	if delay then return nil end
	delay = true
	notools = not notools
	say("No Tools is now toggled! [set: " .. (notools and "enabled" or "disabled") .. "]")
	task.wait(1)
	delay = false
end)

importCommand("kick", {"disconnect", "forceleave"}, function(players)
	for i, v in next, players do
		task.spawn(function()
			local F3X = BuildingToolsExploiter.new()
			if v == lplr then return end
			if table.find(admins, v) then return end
			say("Kicked " .. v.Name .. "!")
			F3X:Destroy(v)
		end)
	end
end)

importCommand("destroyserver", {"destroyworkspace", "destroyall"}, function(players)
	for i, v in next, workspace:GetChildren() do
        if v.Name == lplr.Name then continue end
        local isAdmin = false
        for ii, vv in next, admins do
            if v.Name == vv.Name then
                isAdmin = true
            end
        end
        if isAdmin then continue end
        BuildingToolsExploiter.new():Destroy(v)
    end
end)

importCommand("ban", {}, function(players)
	for i, v in next, players do
		task.spawn(function()
			local F3X = BuildingToolsExploiter.new()
			if v == lplr then return end
			if table.find(admins, v) then return end
			say("Banned " .. v.Name .. "!")
			table.insert(banned, v.Name)
			F3X:Destroy(v)
		end)
	end
end)

lplr.Chatted:Connect(function(message, rec)
	message = message:lower()
	local prefix = message:sub(1, 1)
	local command = message:sub(2, #message)
	local player = getPlayer(command:split(" ")[2] or "")
	command = command:split(" ")[1]
	if prefix == "!" or prefix == "." or prefix == "?" then
		for name, commandcontents in next, commands do
			local foundalias = false
			if command == name then foundalias = true end
			for index, alias in next, commandcontents.aliases do
				if foundalias then break end
				if command == alias then
					foundalias = true
					break
				end
			end

			if foundalias then
				return pcall(function()
					commandcontents.func(player)
				end)
			end
		end
		
		say("Could not find this command!")
	end
end)

local xd = false
game:GetService("RunService").RenderStepped:Connect(function()
	if xd then return end
	if (getItem("F3X") or getItem("Building Tools")) then return nil end
	xd = true
	local last = lplr.Character:GetPivot()
	repeat task.wait(0.5)
		lplr.Character:PivotTo(workspace.GearBoardManagerModel.LoadOut.SlotDisplayButton:GetPivot())
		fireclickdetector(workspace.GearBoardManagerModel.LoadOut.SlotDisplayButton:FindFirstChildOfClass("ClickDetector"))
	until (getItem("F3X") or getItem("Building Tools"))
	lplr.Character:PivotTo(last)
	xd = false
end)
