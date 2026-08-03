-- MovementController.lua
-- Контролирует скорость игрока, полёт, noclip и телепорт

local Movement = {}
local core

function Movement.Init(_core)
    core = _core
    Movement.Config = {
        SpeedMultiplier = 1,
        Fly = false,
        Noclip = false,
    }
    Movement._conns = {}
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function getCharacter()
    local plr = Players.LocalPlayer
    if plr then return plr.Character end
    return nil
end

function Movement.SetSpeed(mult)
    local char = getCharacter()
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        hum.WalkSpeed = (16 * (mult or 1))
        Movement.Config.SpeedMultiplier = mult or 1
    end
end

function Movement.ToggleNoclip(enable)
    Movement.Config.Noclip = enable and true or false
    if enable then
        Movement._conns.noclip = RunService.Stepped:Connect(function()
            local char = getCharacter()
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end)
    else
        if Movement._conns.noclip then
            Movement._conns.noclip:Disconnect()
            Movement._conns.noclip = nil
        end
    end
end

function Movement.ToggleFly(enable)
    Movement.Config.Fly = enable and true or false
    local char = getCharacter()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if enable then
        Movement._flyconn = RunService.Heartbeat:Connect(function(dt)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and char and char.PrimaryPart then
                -- simple fly: zero gravity and allow upward movement via touch is left to UI controls
                hum.PlatformStand = true
                -- gently keep position
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if Movement._flyconn then Movement._flyconn:Disconnect() Movement._flyconn = nil end
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.PlatformStand = false end) end
    end
end

function Movement.TeleportTo(target)
    local char = getCharacter()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    if type(target) == "Vector3" then
        hrp.CFrame = CFrame.new(target)
    elseif typeof(target) == "Instance" and target:IsA("BasePart") then
        hrp.CFrame = target.CFrame + Vector3.new(0,3,0)
    end
end

function Movement.SuperJump(mult)
    local char = getCharacter()
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = 50 * (mult or 1)
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

function Movement.Start()
    -- no continuous behavior by default
end

function Movement.Stop()
    pcall(function()
        if Movement._conns.noclip then Movement._conns.noclip:Disconnect() end
        if Movement._flyconn then Movement._flyconn:Disconnect() end
    end)
end

return Movement
