-- Tracker.lua
-- Плавное вращение камеры к выбранной цели

local Tracker = {}
local core

function Tracker.Init(_core)
    core = _core
    Tracker.Config = {
        MaxDistance = 200,
        FOV = 90,
        SmoothTime = 0.12,
        IgnoreWalls = false,
        AimAt = "Head", -- or "Torso"
        AutoDrop = false,
    }
    Tracker._running = false
end

local RunService = game:GetService("RunService")

local function getTarget()
    local players = core.Services.Players:GetPlayers()
    local localPlr = core.Services.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local best, bestDist = nil, math.huge
    for _, plr in ipairs(players) do
        if plr ~= localPlr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos = plr.Character:FindFirstChild(Tracker.Config.AimAt) or plr.Character:FindFirstChild("HumanoidRootPart")
            if pos then
                local rel = (pos.Position - camera.CFrame.Position)
                local dist = rel.Magnitude
                if dist < Tracker.Config.MaxDistance and dist < bestDist then
                    best = plr
                    bestDist = dist
                end
            end
        end
    end
    return best
end

function Tracker.Start()
    if Tracker._running then return end
    Tracker._running = true
    Tracker._conn = RunService:BindToRenderStep("DELTA_TRACK", Enum.RenderPriority.Camera.Value + 2, function(dt)
        local target = getTarget()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(Tracker.Config.AimAt) or target.Character:FindFirstChild("HumanoidRootPart")
            if aimPart and workspace.CurrentCamera then
                local cam = workspace.CurrentCamera
                local targetCFrame = CFrame.new(cam.CFrame.Position, aimPart.Position)
                -- smooth interpolate
                local newCFrame = cam.CFrame:lerp(CFrame.new(cam.CFrame.Position) * CFrame.Angles(0,0,0) * CFrame.new(Vector3.new(0,0,0)), 0) -- no-op base, we lerp directly
                -- simpler: set camera to lookAt using CFrame:new
                local cframe = CFrame.new(cam.CFrame.Position, aimPart.Position)
                cam.CFrame = cam.CFrame:Lerp(cframe, math.clamp(Tracker.Config.SmoothTime*60*dt, 0, 1))
                if Tracker.Config.AutoDrop then
                    -- simulate small drop by moving camera down a bit after lock
                    cam.CFrame = cam.CFrame * CFrame.new(0, -0.02, 0)
                end
            end
        end
    end)
end

function Tracker.Stop()
    if Tracker._conn then
        RunService:UnbindFromRenderStep("DELTA_TRACK")
        Tracker._conn = nil
    end
    Tracker._running = false
end

return Tracker
