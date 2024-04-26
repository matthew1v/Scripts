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
		
		local old = self.instance.Parent
		self.instance.Parent = lplr.Character
		invokeRemote(self.instance:FindFirstChildOfClass("BindableFunction"):FindFirstChildOfClass("RemoteFunction"), "UndoRemove", {instance})
		task.delay(0.3, function()
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
	end
	
	for i, v in next, game:GetService("Players"):GetPlayers() do
		if name == "all" then
			table.insert(plrs, v)
			continue
		elseif name == "others" then
			if v ~= lplr then
				table.insert(plrs, v)
			end
			continue
		end
		
		if name:lower():find(v.Name:lower()) or v.Name:lower():format(name:lower()) then
			table.insert(plrs, v)
		end
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
		"\n" .. "removetools [all? | others? | username] [aliases: notools, remtools, rtools]"
	)
end)

importCommand("admin", {"rank"}, function(players)
	for i, v in next, players do
		if v == lplr then continue end
		if table.find(admins, v) then continue end
		if not table.find(admins, v) then
			table.insert(admins, v)
			adminconnections[v.UserId] = v.Chatted:Connect(chatted)
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
	end
end)
