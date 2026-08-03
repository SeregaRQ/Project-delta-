-- WorldManager.lua
-- Время суток, погода и свободная камера

local World = {}
local core

function World.Init(_core)
    core = _core
    World.Config = {
        TimeOfDay = 12,
        Weather = "None", -- Rain, Fog, Snow
        FreeCamera = false,
    }
    World._emitters = {}
end

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

function World.SetTime(hour)
    pcall(function() Lighting.TimeOfDay = string.format("%02d:00:00", math.clamp(math.floor(hour),0,23)) end)
    World.Config.TimeOfDay = hour
end

function World.SetWeather(kind)
    World.Config.Weather = kind or "None"
    -- simple implementation: toggle fog and small particle effect attached to camera
    if kind == "Rain" then
        Lighting.FogEnd = 200
        Lighting.FogStart = 0
    elseif kind == "Fog" then
        Lighting.FogEnd = 100
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    end
end

function World.ToggleFreeCamera(enable)
    World.Config.FreeCamera = enable and true or false
    local camera = workspace.CurrentCamera
    if enable then
        camera.CameraType = Enum.CameraType.Scriptable
    else
        camera.CameraType = Enum.CameraType.Custom
    end
end

function World.Start()
    -- attach debug markers to certain items for demonstration
    World._tick = RunService.Heartbeat:Connect(function()
        -- could scan workspace for named items and add small BillboardGuis, keep light
    end)
end

function World.Stop()
    pcall(function()
        if World._tick then World._tick:Disconnect() World._tick = nil end
        -- cleanup any created emitters
        for _, e in ipairs(World._emitters) do pcall(function() e:Destroy() end) end
        World._emitters = {}
    end)
end

return World
