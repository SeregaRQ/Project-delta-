-- Menu.lua
-- Панель управления с вкладками, элементами >=50px и поддержкой перетаскивания

local Menu = {}
local core

function Menu.Init(_core)
    core = _core
    Menu._ui = {}
end

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local function makeButton(text, size)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, size, 0, size)
    b.BackgroundColor3 = Color3.fromRGB(30,30,30)
    b.Text = text
    b.Font = core.Config.Visual.Font
    b.TextSize = 24
    b.TextColor3 = Color3.new(1,1,1)
    b.AutoButtonColor = false
    return b
end

local function makeToggle(label, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,220,0,60)
    frame.BackgroundTransparency = 1
    local text = Instance.new("TextLabel", frame)
    text.Size = UDim2.new(1,-70,1,0)
    text.Position = UDim2.new(0,10,0,0)
    text.BackgroundTransparency = 1
    text.Text = label
    text.TextColor3 = Color3.new(1,1,1)
    text.Font = core.Config.Visual.Font
    text.TextSize = 20

    local toggle = Instance.new("Frame", frame)
    toggle.Size = UDim2.new(0,50,0,50)
    toggle.Position = UDim2.new(1,-60,0,5)
    toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    toggle.Name = "Toggle"
    toggle.ClipsDescendants = true
    local knob = Instance.new("Frame", toggle)
    knob.Size = UDim2.new(0,44,0,44)
    knob.Position = UDim2.new(0,3,0,3)
    knob.BackgroundColor3 = default and Color3.fromRGB(80,200,80) or Color3.fromRGB(160,160,160)
    knob.Name = "Knob"

    -- touch handling
    local enabled = default
    local function set(v)
        enabled = v
        local goal = { BackgroundColor3 = v and Color3.fromRGB(80,200,80) or Color3.fromRGB(160,160,160) }
        TweenService:Create(knob, TweenInfo.new(0.18), { BackgroundColor3 = goal.BackgroundColor3 }):Play()
    end
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            set(not enabled)
        end
    end)

    return frame, function() return enabled end, set
end

local function makeSlider(label, minv, maxv, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,300,0,60)
    frame.BackgroundTransparency = 1
    local text = Instance.new("TextLabel", frame)
    text.Size = UDim2.new(1,-20,0,24)
    text.Position = UDim2.new(0,10,0,0)
    text.BackgroundTransparency = 1
    text.Text = label .. ": " .. tostring(default)
    text.TextColor3 = Color3.new(1,1,1)
    text.Font = core.Config.Visual.Font
    text.TextSize = 18

    local bar = Instance.new("Frame", frame)
    bar.Position = UDim2.new(0,10,0,30)
    bar.Size = UDim2.new(1,-20,0,20)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    bar.Name = "Bar"

    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.new((default-minv)/(maxv-minv),0,1,0)
    knob.BackgroundColor3 = Color3.fromRGB(120,180,240)
    knob.Name = "Knob"

    local dragging = false
    local function setValueFromInput(input)
        if input.Position and input.UserInputType == Enum.UserInputType.Touch then
            local relative = input.Position.X - bar.AbsolutePosition.X
            local frac = math.clamp(relative / bar.AbsoluteSize.X, 0, 1)
            local val = minv + frac * (maxv-minv)
            knob.Size = UDim2.new(frac,0,1,0)
            text.Text = label .. ": " .. string.format("%.2f", val)
            return val
        end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setValueFromInput(input)
        end
    end)
    bar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            setValueFromInput(input)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return frame, function() return tonumber((string.match(text.Text, ": (.*)$") or tostring(default))) end
end

function Menu.Start()
    -- build base window
    if not core or not core.ScreenGui then return end
    local s = core.ScreenGui
    local win = Instance.new("Frame")
    win.Size = UDim2.new(0,360,0,540)
    win.Position = UDim2.new(0,20,0,60)
    win.BackgroundColor3 = Color3.fromRGB(20,20,20)
    win.Parent = s

    -- draggable via touch
    local dragging = false
    local dragOffset = Vector2.new(0,0)
    win.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragOffset = Vector2.new(input.Position.X - win.AbsolutePosition.X, input.Position.Y - win.AbsolutePosition.Y)
        end
    end)
    win.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            win.Position = UDim2.new(0, input.Position.X - dragOffset.X, 0, input.Position.Y - dragOffset.Y)
        end
    end)
    win.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    local title = Instance.new("TextLabel", win)
    title.Size = UDim2.new(1,0,0,50)
    title.BackgroundTransparency = 1
    title.Text = "Delta Debug Menu"
    title.Font = core.Config.Visual.Font
    title.TextSize = 22
    title.TextColor3 = Color3.new(1,1,1)

    -- Tabs area (simplified): we'll create vertical list of controls for demo
    local content = Instance.new("ScrollingFrame", win)
    content.Position = UDim2.new(0,0,0,50)
    content.Size = UDim2.new(1,0,1,-50)
    content.CanvasSize = UDim2.new(0,0)
    content.BackgroundTransparency = 1

    -- Populate sample controls
    local y = 6
    local function add(obj)
        obj.Position = UDim2.new(0,10,0,y)
        obj.Parent = content
        y = y + obj.Size.Y.Offset + 10
        content.CanvasSize = UDim2.new(0,0,0,y)
    end

    local t1_on, t1_get, t1_set = makeToggle("Визуализация", true)
    add(t1_on)
    local slider1, slider1_get = makeSlider("Скорость игрока", 1, 10, 1)
    add(slider1)

    local unloadBtn = Instance.new("TextButton")
    unloadBtn.Size = UDim2.new(0,320,0,60)
    unloadBtn.Text = "💀 ВЫГРУЗИТЬ"
    unloadBtn.Font = core.Config.Visual.Font
    unloadBtn.TextSize = 22
    unloadBtn.BackgroundColor3 = Color3.fromRGB(50,10,10)
    unloadBtn.Parent = content
    add(unloadBtn)

    unloadBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            -- call global unload if exists
            if _G and _G.DEBUG and type(_G.DEBUG.Stop) == "function" then
                _G.DEBUG.Stop()
            end
        end
    end)
end

function Menu.Stop()
    -- destroy UI elements created under core.ScreenGui if any
    pcall(function()
        for _, child in ipairs(core.ScreenGui:GetChildren()) do
            if child.Name ~= "_DEBUG_ColdUnload" then
                child:Destroy()
            end
        end
    end)
end

return Menu
