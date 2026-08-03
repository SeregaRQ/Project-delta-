-- Core.lua
-- Создаёт ScreenGui, сервисы и конфиг
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Core = {}
Core.Created = {}
Core.Config = {
    Visual = {
        NameColor = Color3.fromRGB(255,255,255),
        DistanceColor = Color3.fromRGB(200,200,200),
        HealthColor = Color3.fromRGB(0,200,80),
        Font = Enum.Font.SourceSansBold,
    },
    Sizes = {
        TouchMin = 50, -- px
    }
}

function Core.MakeScreenGui(name)
    local s = Instance.new("ScreenGui")
    s.Name = name or "DeltaCore"
    s.ResetOnSpawn = false
    s.Parent = game:GetService("CoreGui")
    table.insert(Core.Created, s)
    return s
end

function Core.Init()
    -- create base ScreenGui
    Core.ScreenGui = Core.MakeScreenGui("DeltaDebugGui")
    -- safe references
    Core.Services = {
        RunService = RunService,
        Players = Players,
        TweenService = TweenService,
    }
    -- helper for cleanup
    function Core.Cleanup()
        for _, obj in ipairs(Core.Created) do
            pcall(function() if obj and obj.Parent then obj:Destroy() end end)
        end
        Core.Created = {}
    end
end

-- safe utility for creating UI elements
function Core.New(cls, props)
    local ok, obj = pcall(function()
        local o = Instance.new(cls)
        for k,v in pairs(props or {}) do
            pcall(function() o[k] = v end)
        end
        return o
    end)
    if not ok then return nil end
    table.insert(Core.Created, obj)
    return obj
end

-- touch helper
function Core.IsTouchInput(input)
    return input and input.UserInputType == Enum.UserInputType.Touch
end

return Core
