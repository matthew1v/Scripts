local lplr = game.Players.LocalPlayer
local tp = function(cf)
    if lplr and lplr.Character then
        lplr.Character:PivotTo(cf)
    end
end

game.UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and game.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        tp(game.Players.LocalPlayer:GetMouse().Hit)
    end
end)
