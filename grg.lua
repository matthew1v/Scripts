local lplr = game.Players.LocalPlayer
local map = workspace.Arena.VisualArena
function getSeat()
    for i, v in next, map:GetDescendants() do
        if v:IsA("Seat") or v:IsA("SeatPart") or v:IsA("VehicleSeat") and v.Occupant == nil then
            return v
        end
    end
end
print(getSeat())
