local Players = game:GetService("Players")
local SetupVelocity = Vector3.one * 9e9
local LocalPlayer = Players.LocalPlayer

function aliveCheck(player)
	if player then
		if player.Character then
			if player.Character:FindFirstChildOfClass("Humanoid") then
				if player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
					return true
				end
			end
		end
	end
	
	return false
end

function getNonFlungPlayers()
	local plrs = {}
	if not LocalPlayer.Character then return plrs end
	
	for i, v in next, Players:GetPlayers() do
		if LocalPlayer ~= v and aliveCheck(v) then
			local root = v.Character:FindFirstChild("HumanoidRootPart")
			if root ~= nil then
				if root.Velocity.Y < 90 and (root.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude < 11592 then
					table.insert(plrs, v)
				end
			end
		end
	end
	
	return plrs
end

function setupFling()
	if aliveCheck(LocalPlayer) then
		for i, v in next, LocalPlayer.Character:GetChildren() do
			task.spawn(function() if v:IsA("BasePart") then v.CanCollide = false end end)
			task.spawn(function()
				if v:IsA("BasePart") then
					local old = v.Velocity
					v.Velocity = SetupVelocity
					game:GetService("RunService").RenderStepped:Wait()
					v.Velocity = old
				end
			end)
		end
	end
end

game:GetService("RunService").Heartbeat:Connect(setupFling)

for i = 1, 100 do
	if aliveCheck(LocalPlayer) then
		local target = getNonFlungPlayers()[math.random(1, #getNonFlungPlayers())]
		if target ~= nil then
			repeat
				if aliveCheck(LocalPlayer) then
					LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(target.Character:GetPivot().p - Vector3.new(0, 1, 0) + (target.Character.PrimaryPart.Velocity / 8.5), Vector3.new(
						math.random(-9999, 9999), math.random(-9999, 9999), math.random(-9999, 9999)
					))
				end
				task.wait()
			until not aliveCheck(target)
		end
	end
	task.wait()
end
