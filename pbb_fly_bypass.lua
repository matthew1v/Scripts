for k,v in pairs(getgc(true)) do if pcall(function() return rawget(v,"indexInstance") end) and type(rawget(v,"indexInstance")) == "table" and (rawget(v,"indexInstance"))[1] == "kick" then v.tvk = {"kick",function() return game.Workspace:WaitForChild("") end} end end
local old, old2
local lplr = game.Players.LocalPlayer

old = hookmetamethod(game, "__index", newcclosure(function(self, property)
    if self:IsA("BodyVelocity") or self:IsA("BodyGyro") and not checkcaller() then
        return nil
    end
    
    return old(self, property)
end))

old2 = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
      if self == lplr and tostring(getnamecallmethod()) == "Kick" then
          return ...
      end
      return old2(self, ...)    
end))
