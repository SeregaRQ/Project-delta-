-- Main.lua
-- Загрузчик модулей по raw GitHub URL
-- Требования: только touch-взаимодействия при управлении UI

local OWNER = "SeregaRQ"
local REPO = "Project-delta-"
local BRANCH = "main"

local function raw(name)
    return ("https://raw.githubusercontent.com/%s/%s/%s/%s"):format(OWNER, REPO, BRANCH, name)
end

_G.DEBUG = _G.DEBUG or { modules = {}, running = false }

local ModulesOrder = {
    "Core.lua",
    "Visualizer.lua",
    "Tracker.lua",
    "MovementController.lua",
    "WeaponTester.lua",
    "WorldManager.lua",
    "Menu.lua",
    "Tracker.lua", -- harmless duplicate protection in loader, kept for safety in ordering examples
}

-- We'll explicitly load files present in repo root
local ModuleFiles = {
    "Core.lua",
    "Visualizer.lua",
    "Tracker.lua",
    "MovementController.lua",
    "WeaponTester.lua",
    "WorldManager.lua",
    "Menu.lua",
}

local LoadedModules = {}

local function safeLoad(url)
    local ok, res = pcall(function() return loadstring(game:HttpGet(url)) end)
    if not ok or type(res) ~= "function" then
        return nil, "failed to load: " .. tostring(res)
    end
    local ok2, mod = pcall(res)
    if not ok2 then
        return nil, "error executing module: " .. tostring(mod)
    end
    return mod
end

local function loadAll()
    local core
    -- load Core first
    local coreUrl = raw("Core.lua")
    local coreMod, err = safeLoad(coreUrl)
    if not coreMod then
        warn("[Main] Could not load Core.lua:", err)
        return false
    end
    core = coreMod
    if core.Init then
        pcall(core.Init)
    end
    LoadedModules.Core = core

    -- load other modules and give them core reference where needed
    for _, name in ipairs(ModuleFiles) do
        if name ~= "Core.lua" then
            local url = raw(name)
            local mod, err2 = safeLoad(url)
            if not mod then
                warn("[Main] Could not load", name, err2)
            else
                -- pass core if module expects it
                if type(mod.Init) == "function" then
                    pcall(function() mod.Init(core) end)
                end
                LoadedModules[name:gsub("%.lua$","")] = mod
                table.insert(_G.DEBUG.modules, name)
            end
        end
    end
    return true
end

local function startAll()
    _G.DEBUG.running = true
    for k, m in pairs(LoadedModules) do
        if type(m.Start) == "function" then
            pcall(m.Start)
        end
    end
end

local function stopAll()
    _G.DEBUG.running = false
    for k, m in pairs(LoadedModules) do
        if type(m.Stop) == "function" then
            pcall(m.Stop)
        end
    end
    -- try to clear core-created objects
    if LoadedModules.Core and type(LoadedModules.Core.Cleanup) == "function" then
        pcall(LoadedModules.Core.Cleanup)
    end
end

-- Emergency unload button (simple clickable GUI element created locally)
local function createEmergencyUnload()
    local UIS = game:GetService("UserInputService")
    -- create a small ScreenGui with a large touch area to unload
    local s = Instance.new("ScreenGui")
    s.Name = "_DEBUG_ColdUnload"
    s.ResetOnSpawn = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,120,0,60)
    btn.Position = UDim2.new(1,-130,0,10)
    btn.AnchorPoint = Vector2.new(0,0)
    btn.Text = "💀 ВЫГРУЗИТЬ"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 26
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(220,60,60)
    btn.Parent = s
    s.Parent = game:GetService("CoreGui")

    local function onTouch(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            stopAll()
            pcall(function() s:Destroy() end)
            -- clear globals
            _G.DEBUG = nil
        end
    end

    -- use InputBegan only for touch
    btn.InputBegan:Connect(function(input)
        pcall(function()
            if input.UserInputType == Enum.UserInputType.Touch then
                onTouch(input)
            end
        end)
    end)
end

-- loader flow
local ok = loadAll()
if ok then
    startAll()
    pcall(createEmergencyUnload)
else
    warn("[Main] Loader failed, aborting start")
end

-- expose stop/start to global for testing on mobile touch (no keyboard)
_G.DEBUG.Start = startAll
_G.DEBUG.Stop = stopAll

return {
    Loaded = LoadedModules,
    Start = startAll,
    Stop = stopAll,
}
