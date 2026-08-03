-- ============================================
-- 🎛️ SWILL | MENU MODULE v2.0 — ПОЛНЫЙ КОНТРОЛЬ
-- ============================================
-- ФУНКЦИИ:
-- ✅ Вкладки: Visual, Aimbot, Movement, Weapons, World
-- ✅ Переключатели (Toggle) с анимацией
-- ✅ Ползунки (Slider) с отображением значения
-- ✅ Выбор цвета для ESP
-- ✅ Кнопка выгрузки
-- ✅ Перетаскивание
-- ============================================

local S = _G.SWILL
local C = S.Config.Colors

-- ===== КНОПКА ОТКРЫТИЯ МЕНЮ =====
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleBtn.Position = UDim2.new(0.85, 0, 0.75, 0)
ToggleBtn.BackgroundColor3 = C.ACC
ToggleBtn.Text = "👁️"
ToggleBtn.TextSize = 26
ToggleBtn.ZIndex = 100
ToggleBtn.Parent = S.GUI
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

-- Перетаскивание кнопки
local isDragging = false
local dragStart = Vector2.zero
local btnStartPos = UDim2.new()

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        btnStartPos = ToggleBtn.Position
        task.wait(0.15)
        if not isDragging then
            MenuFrame.Visible = not MenuFrame.Visible
        end
    end
end)

S.UIS.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        ToggleBtn.Position = UDim2.new(
            btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
            btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
        )
    end
end)

S.UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

-- ===== ОСНОВНОЕ МЕНЮ =====
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 380, 0, 520)
MenuFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
MenuFrame.BackgroundColor3 = C.BG
MenuFrame.Visible = false
MenuFrame.ZIndex = 50
MenuFrame.Parent = S.GUI
Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 14)

-- ===== ЗАГОЛОВОК =====
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = C.SEC
Header.ZIndex = 51
Header.Parent = MenuFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔥 SWILL MENU"
Title.TextColor3 = C.ACC
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 52
Title.Parent = Header

-- Перетаскивание меню
local isMenuDragging = false
local menuDragStart = Vector2.zero
local menuStartPos = UDim2.new()

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isMenuDragging = true
        menuDragStart = input.Position
        menuStartPos = MenuFrame.Position
    end
end)

S.UIS.InputChanged:Connect(function(input)
    if isMenuDragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - menuDragStart
        MenuFrame.Position = UDim2.new(
            menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X,
            menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y
        )
    end
end)

S.UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isMenuDragging = false
    end
end)

-- Крестик
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(0.85, 0, 0.1, 0)
CloseBtn.BackgroundColor3 = C.RED
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = C.WHT
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 52
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

CloseBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        MenuFrame.Visible = false
    end
end)

-- ===== ВКЛАДКИ =====
local Tabs = {"Visual", "Aimbot", "Movement", "Weapons", "World"}
local currentTab = "Visual"
local tabButtons = {}

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -10, 0, 40)
TabContainer.Position = UDim2.new(0, 5, 0, 55)
TabContainer.BackgroundTransparency = 1
TabContainer.ZIndex = 51
TabContainer.Parent = MenuFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.Parent = TabContainer

-- Создание вкладок
for _, tabName in pairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 65, 0, 30)
    btn.BackgroundColor3 = C.SEC
    btn.Text = tabName
    btn.TextColor3 = C.WHT
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 52
    btn.Parent = TabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            currentTab = tabName
            UpdateContent()
        end
    end)
    
    tabButtons[tabName] = btn
end

-- ===== КОНТЕНТ (ПРОКРУТКА) =====
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -10, 1, -120)
Content.Position = UDim2.new(0, 5, 0, 100)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.CanvasSize = UDim2.new(0, 0, 0, 400)
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = C.ACC
Content.ZIndex = 51
Content.Parent = MenuFrame

local ContentList = Instance.new("UIListLayout")
ContentList.Padding = UDim.new(0, 8)
ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.Parent = Content

-- ===== ФУНКЦИЯ СОЗДАНИЯ ПЕРЕКЛЮЧАТЕЛЯ =====
local function CreateToggle(name, default, callback)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(1, -8, 0, 55)
    sec.BackgroundColor3 = C.SEC
    sec.ZIndex = 51
    sec.Parent = Content
    Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 0, 22)
    lbl.Position = UDim2.new(0.05, 0, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = C.WHT
    lbl.TextSize = 14
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 52
    lbl.Parent = sec
    
    local sw = Instance.new("TextButton")
    sw.Size = UDim2.new(0, 50, 0, 28)
    sw.Position = UDim2.new(0.76, 0, 0.28, 0)
    sw.BackgroundColor3 = default and C.GRN or C.BG
    sw.Text = ""
    sw.AutoButtonColor = false
    sw.ZIndex = 52
    sw.Parent = sec
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 20, 0, 20)
    dot.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)
    dot.BackgroundColor3 = C.WHT
    dot.BorderSizePixel = 0
    dot.ZIndex = 53
    dot.Parent = sw
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local state = default
    local function flip()
        state = not state
        S.TS:Create(dot, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 4, 0.5, -10)
        }):Play()
        S.TS:Create(sw, TweenInfo.new(0.15), {
            BackgroundColor3 = state and C.GRN or C.BG
        }):Play()
        callback(state)
    end
    
    sw.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            flip()
        end
    end)
    
    return {Get = function() return state end}
end

-- ===== ФУНКЦИЯ СОЗДАНИЯ ПОЛЗУНКА =====
local function CreateSlider(name, min, max, default, callback)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(1, -8, 0, 80)
    sec.BackgroundColor3 = C.SEC
    sec.ZIndex = 51
    sec.Parent = Content
    Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.8, 0, 0, 22)
    lbl.Position = UDim2.new(0.05, 0, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = name .. " (" .. default .. ")"
    lbl.TextColor3 = C.WHT
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 52
    lbl.Parent = sec
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.85, 0, 0, 10)
    slider.Position = UDim2.new(0.075, 0, 0.65, 0)
    slider.BackgroundColor3 = C.GRY
    slider.ZIndex = 52
    slider.Parent = sec
    Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = C.ACC
    fill.ZIndex = 53
    fill.Parent = slider
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 26, 0, 26)
    knob.Position = UDim2.new((default-min)/(max-min), -13, 0.5, -13)
    knob.BackgroundColor3 = C.WHT
    knob.Text = ""
    knob.ZIndex = 54
    knob.Parent = slider
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local value = default
    
    local function update(val)
        val = math.clamp(val, min, max)
        value = val
        fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
        knob.Position = UDim2.new((val-min)/(max-min), -13, 0.5, -13)
        lbl.Text = name .. " (" .. math.round(val) .. ")"
        callback(val)
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    S.UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    S.UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position.X - slider.AbsolutePosition.X
            local frac = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
            update(min + frac * (max - min))
        end
    end)
    
    return {Get = function() return value end}
end

-- ===== КНОПКА ВЫГРУЗКИ =====
local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(0, 340, 0, 55)
UnloadBtn.Position = UDim2.new(0.5, -170, 1, -65)
UnloadBtn.BackgroundColor3 = C.RED
UnloadBtn.Text = "💀 ВЫГРУЗИТЬ ВСЁ"
UnloadBtn.TextColor3 = C.WHT
UnloadBtn.TextSize = 16
UnloadBtn.Font = Enum.Font.GothamBold
UnloadBtn.ZIndex = 52
UnloadBtn.Parent = MenuFrame
Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 10)

UnloadBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        S.Active = false
        S.RemoveAllESP()
        S.RestoreWeaponProperties()
        S.GUI:Destroy()
        _G.SWILL = nil
        print("[SWILL] 💀 Система полностью выгружена.")
    end
end)

-- ===== ОБНОВЛЕНИЕ КОНТЕНТА =====
local function ClearContent()
    for _, child in pairs(Content:GetChildren()) do
        if child ~= ContentList then
            child:Destroy()
        end
    end
end

local function UpdateContent()
    ClearContent()
    
    if currentTab == "Visual" then
        -- ESP Toggle
        CreateToggle("ESP", S.Config.ESP.Enabled, function(v)
            S.Config.ESP.Enabled = v
            if v then
                for _, p in pairs(S.Players:GetPlayers()) do
                    if p ~= S.Player then
                        S.CreateESP(p)
                    end
                end
            else
                S.RemoveAllESP()
            end
        end)
        
        CreateToggle("Box ESP", S.Config.ESP.Box or false, function(v)
            S.Config.ESP.Box = v
        end)
        
        CreateToggle("Tracer", S.Config.ESP.Tracer or false, function(v)
            S.Config.ESP.Tracer = v
        end)
        
        CreateToggle("Skeleton", S.Config.ESP.Skeleton or false, function(v)
            S.Config.ESP.Skeleton = v
        end)
        
        CreateToggle("Chams", S.Config.ESP.Chams or false, function(v)
            S.Config.ESP.Chams = v
        end)
        
        CreateToggle("Glow", S.Config.ESP.Glow or false, function(v)
            S.Config.ESP.Glow = v
        end)
        
    elseif currentTab == "Aimbot" then
        CreateToggle("Aimbot", S.Config.Aimbot.Enabled, function(v)
            S.Config.Aimbot.Enabled = v
        end)
        
        CreateToggle("Wallcheck", S.Config.Aimbot.Wallcheck, function(v)
            S.Config.Aimbot.Wallcheck = v
        end)
        
        CreateToggle("RCS", S.Config.Aimbot.RCS or false, function(v)
            S.Config.Aimbot.RCS = v
        end)
        
        CreateToggle("Triggerbot", S.Config.Aimbot.Triggerbot or false, function(v)
            S.Config.Aimbot.Triggerbot = v
        end)
        
        -- Target Selector
        local targetNames = {"Head", "Body", "Legs"}
        for _, target in pairs(targetNames) do
            CreateToggle("Target: " .. target, S.Config.Aimbot.Target == target, function(v)
                if v then
                    S.Config.Aimbot.Target = target
                end
            end)
        end
        
        CreateSlider("Distance", 50, 500, S.Config.Aimbot.Distance, function(v)
            S.Config.Aimbot.Distance = v
        end)
        
        CreateSlider("Smooth", 1, 50, S.Config.Aimbot.Smooth * 100, function(v)
            S.Config.Aimbot.Smooth = v / 100
        end)
        
        CreateSlider("FOV Radius", 50, 400, S.Config.FOV.Radius, function(v)
            S.Config.FOV.Radius = v
        end)
        
    elseif currentTab == "Movement" then
        CreateSlider("Speed", 1, 10, S.Config.Movement.Speed or 1, function(v)
            S.Config.Movement.Speed = v
        end)
        
        CreateToggle("Flight", S.Config.Movement.Flight or false, function(v)
            S.Config.Movement.Flight = v
            if v then
                if S.Player.Character and S.Player.Character:FindFirstChild("Humanoid") then
                    S.Player.Character.Humanoid.PlatformStand = true
                end
            else
                if S.Player.Character and S.Player.Character:FindFirstChild("Humanoid") then
                    S.Player.Character.Humanoid.PlatformStand = false
                end
            end
        end)
        
        CreateToggle("No Clip", S.Config.Movement.NoClip or false, function(v)
            S.Config.Movement.NoClip = v
        end)
        
        CreateSlider("Jump Power", 1, 10, S.Config.Movement.JumpPower or 1, function(v)
            S.Config.Movement.JumpPower = v
        end)
        
        CreateToggle("Air Control", S.Config.Movement.AirControl or false, function(v)
            S.Config.Movement.AirControl = v
        end)
        
        CreateToggle("No Fall Damage", S.Config.Movement.NoFallDamage or false, function(v)
            S.Config.Movement.NoFallDamage = v
        end)
        
        CreateToggle("Auto Sprint", S.Config.Movement.AutoSprint or false, function(v)
            S.Config.Movement.AutoSprint = v
        end)
        
    elseif currentTab == "Weapons" then
        CreateToggle("No Recoil", S.Config.Weapons.NoRecoil or false, function(v)
            S.Config.Weapons.NoRecoil = v
        end)
        
        CreateToggle("No Spread", S.Config.Weapons.NoSpread or false, function(v)
            S.Config.Weapons.NoSpread = v
        end)
        
        CreateToggle("Infinite Ammo", S.Config.Weapons.InfiniteAmmo or false, function(v)
            S.Config.Weapons.InfiniteAmmo = v
        end)
        
        CreateToggle("Instant Reload", S.Config.Weapons.InstantReload or false, function(v)
            S.Config.Weapons.InstantReload = v
        end)
        
        CreateSlider("Damage", 1, 10, S.Config.Weapons.Damage or 1, function(v)
            S.Config.Weapons.Damage = v
        end)
        
        CreateSlider("Fire Rate", 1, 5, S.Config.Weapons.FireRate or 1, function(v)
            S.Config.Weapons.FireRate = v
        end)
        
        CreateSlider("Bullet Speed", 1, 5, S.Config.Weapons.BulletSpeed or 1, function(v)
            S.Config.Weapons.BulletSpeed = v
        end)
        
    elseif currentTab == "World" then
        local dayOptions = {"Day", "Night"}
        for _, option in pairs(dayOptions) do
            CreateToggle(option, S.Config.World.Day == option, function(v)
                if v then
                    S.Config.World.Day = option
                end
            end)
        end
        
        local weatherOptions = {"Clear", "Rain", "Fog", "Snow"}
        for _, option in pairs(weatherOptions) do
            CreateToggle(option, S.Config.World.Weather == option, function(v)
                if v then
                    S.Config.World.Weather = option
                end
            end)
        end
        
        CreateToggle("Fog", S.Config.World.Fog or false, function(v)
            S.Config.World.Fog = v
        end)
        
        CreateToggle("Free Camera", S.Config.World.FreeCam or false, function(v)
            S.Config.World.FreeCam = v
            -- Здесь нужно вызвать функцию ToggleFreeCam из World.lua
        end)
        
        CreateToggle("Item ESP", S.Config.World.ItemESP or false, function(v)
            S.Config.World.ItemESP = v
        end)
        
        CreateToggle("Vehicle ESP", S.Config.World.VehicleESP or false, function(v)
            S.Config.World.VehicleESP = v
        end)
    end
end

-- ===== ПЕРВОНАЧАЛЬНОЕ ОБНОВЛЕНИЕ =====
UpdateContent()

print("[SWILL] ✅ Menu.lua загружен. Интерфейс готов.")
print("[SWILL] 👁️ Нажми на кнопку в правом нижнем углу для открытия меню.")
