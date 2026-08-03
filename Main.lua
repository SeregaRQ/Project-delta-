-- ============================================
-- 🔧 SWILL | MAIN LOADER v1.0
-- ЗАГРУЗЧИК ВСЕХ МОДУЛЕЙ (ПО ПОРЯДКУ)
-- ============================================

print("[SWILL] Запуск Main.lua...")

-- Очистка старой сессии (если была)
if _G.SWILL then
    if _G.SWILL.GUI then
        _G.SWILL.GUI:Destroy()
    end
    _G.SWILL = nil
end

-- Создаём глобальное хранилище
_G.SWILL = {
    Active = true,
    Modules = {},
    Loaded = {}
}

local S = _G.SWILL

-- Функция безопасной загрузки модуля
local function LoadModule(name, code)
    if not S.Active then 
        warn("[SWILL] Система деактивирована, загрузка " .. name .. " отменена.")
        return false
    end
    
    local fn, err = loadstring(code)
    if fn then
        local success, result = pcall(fn)
        if success then
            S.Loaded[name] = true
            print("[SWILL] ✅ " .. name .. " загружен")
            return true
        else
            warn("[SWILL] ❌ Ошибка выполнения " .. name .. ": " .. tostring(result))
            return false
        end
    else
        warn("[SWILL] ❌ Ошибка компиляции " .. name .. ": " .. tostring(err))
        return false
    end
end

-- Код модулей (встроенный, чтобы не было проблем с GitHub)
local Modules = {
    Core = [[
        -- ============================================
        -- 🔧 SWILL | CORE MODULE v1.0
        -- БАЗА: GUI, ЦВЕТА, ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
        -- ============================================
        
        local S = _G.SWILL
        
        -- Конфиг
        S.Config = {
            Colors = {
                BG = Color3.fromRGB(20, 20, 28),
                SEC = Color3.fromRGB(30, 30, 40),
                ACC = Color3.fromRGB(255, 160, 0),
                WHT = Color3.fromRGB(255, 255, 255),
                GRY = Color3.fromRGB(150, 150, 165),
                RED = Color3.fromRGB(255, 55, 55),
                GRN = Color3.fromRGB(40, 200, 80),
                BLU = Color3.fromRGB(55, 130, 255),
            },
            ESP = { Enabled = false },
            Aimbot = { Enabled = false, Distance = 300, Smooth = 0.25, Wallcheck = true, Target = "Head" },
            FOV = { Radius = 180 },
            Movement = { Speed = 1, Flight = false, NoClip = false },
            Weapons = { NoRecoil = false, NoSpread = false, InfiniteAmmo = false }
        }
        
        -- Сервисы
        S.Player = game:GetService("Players").LocalPlayer
        S.Players = game:GetService("Players")
        S.UIS = game:GetService("UserInputService")
        S.RS = game:GetService("RunService")
        S.TS = game:GetService("TweenService")
        S.Workspace = workspace
        S.Camera = workspace.CurrentCamera
        
        -- GUI
        local PG = S.Player:WaitForChild("PlayerGui")
        S.GUI = Instance.new("ScreenGui")
        S.GUI.Name = "SWILL_CORE"
        S.GUI.ResetOnSpawn = false
        S.GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        S.GUI.Parent = PG
        
        print("[SWILL] Core.lua загружен")
    ]],
    
    FOV = [[
        -- ============================================
        -- 🔧 SWILL | FOV MODULE v1.0
        -- КРУГ В ЦЕНТРЕ ЭКРАНА
        -- ============================================
        
        local S = _G.SWILL
        local C = S.Config.Colors
        
        -- Контейнер FOV
        local fovContainer = Instance.new("Frame")
        fovContainer.Size = UDim2.new(0, 360, 0, 360)
        fovContainer.Position = UDim2.new(0.5, -180, 0.5, -180)
        fovContainer.BackgroundTransparency = 1
        fovContainer.ZIndex = 999
        fovContainer.Parent = S.GUI
        
        -- Сам круг
        local fovCircle = Instance.new("Frame")
        fovCircle.Size = UDim2.new(1, 0, 1, 0)
        fovCircle.BackgroundTransparency = 1
        fovCircle.BorderSizePixel = 2
        fovCircle.BorderColor3 = C.WHT
        fovCircle.ZIndex = 1000
        fovCircle.Parent = fovContainer
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = fovCircle
        
        S.FOV = {
            Container = fovContainer,
            Circle = fovCircle,
            Update = function(radius)
                local size = radius * 2
                fovContainer.Size = UDim2.new(0, size, 0, size)
                fovContainer.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
            end
        }
        
        -- Обновление в реальном времени
        S.RS.RenderStepped:Connect(function()
            local cam = S.Camera
            if cam then
                local radius = S.Config.FOV.Radius
                local size = radius * 2
                fovContainer.Size = UDim2.new(0, size, 0, size)
                fovContainer.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
            end
        end)
        
        print("[SWILL] FOV.lua загружен")
    ]],
    
    ESP = [[
        -- ============================================
        -- 🔧 SWILL | ESP MODULE v1.0
        -- ВИЗУАЛЬНАЯ ИНФОРМАЦИЯ ОБ ИГРОКАХ
        -- ============================================
        
        local S = _G.SWILL
        local espObjects = {}
        
        local function CreateESP(player)
            if player == S.Player then return end
            if espObjects[player] then 
                -- Обновляем, если уже есть
                return 
            end
            
            local char = player.Character
            if not char then return end
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
            if not root then return end
            
            -- BillboardGui
            local bill = Instance.new("BillboardGui")
            bill.Name = "SWILL_ESP"
            bill.Size = UDim2.new(0, 200, 0, 40)
            bill.StudsOffset = Vector3.new(0, 3, 0)
            bill.AlwaysOnTop = true
            bill.MaxDistance = 3000
            bill.Parent = root
            
            -- Имя
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0, 18)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = S.Config.Colors.WHT
            nameLabel.TextSize = 14
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextStrokeTransparency = 0.3
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.Parent = bill
            
            -- Дистанция
            local distLabel = Instance.new("TextLabel")
            distLabel.Size = UDim2.new(1, 0, 0, 16)
            distLabel.Position = UDim2.new(0, 0, 0, 18)
            distLabel.BackgroundTransparency = 1
            distLabel.Text = "0m"
            distLabel.TextColor3 = S.Config.Colors.GRY
            distLabel.TextSize = 12
            distLabel.Font = Enum.Font.Gotham
            distLabel.TextStrokeTransparency = 0.3
            distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            distLabel.Parent = bill
            
            -- Highlight (подсветка)
            local highlight = Instance.new("Highlight")
            highlight.Name = "SWILL_ESP"
            highlight.FillColor = S.Config.Colors.WHT
            highlight.FillTransparency = 0.85
            highlight.OutlineColor = S.Config.Colors.ACC
            highlight.OutlineTransparency = 0.3
            highlight.Parent = char
            
            espObjects[player] = {
                Billboard = bill,
                Highlight = highlight,
                NameLabel = nameLabel,
                DistLabel = distLabel
            }
        end
        
        local function RemoveESP(player)
            local obj = espObjects[player]
            if obj then
                if obj.Billboard then obj.Billboard:Destroy() end
                if obj.Highlight then obj.Highlight:Destroy() end
                espObjects[player] = nil
            end
        end
        
        function S.RemoveAllESP()
            for player, obj in pairs(espObjects) do
                if obj.Billboard then obj.Billboard:Destroy() end
                if obj.Highlight then obj.Highlight:Destroy() end
            end
            espObjects = {}
        end
        
        -- Обработка появления/исчезновения игроков
        S.Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                if S.Config.ESP.Enabled then
                    task.wait(0.5)
                    CreateESP(p)
                end
            end)
            if S.Config.ESP.Enabled and p.Character then
                CreateESP(p)
            end
        end)
        
        S.Players.PlayerRemoving:Connect(RemoveESP)
        
        -- Обновление дистанции и цвета
        spawn(function()
            while S.Active do
                S.RS.RenderStepped:Wait()
                if S.Config.ESP.Enabled then
                    local myChar = S.Player.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    for player, obj in pairs(espObjects) do
                        local char = player.Character
                        if char then
                            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                            if root and myRoot then
                                local dist = (myRoot.Position - root.Position).Magnitude
                                obj.DistLabel.Text = string.format("%.0f m", dist)
                                if dist < 30 then
                                    obj.NameLabel.TextColor3 = S.Config.Colors.RED
                                elseif dist < 100 then
                                    obj.NameLabel.TextColor3 = S.Config.Colors.ACC
                                else
                                    obj.NameLabel.TextColor3 = S.Config.Colors.WHT
                                end
                            end
                        end
                    end
                end
            end
        end)
        
        print("[SWILL] ESP.lua загружен")
    ]],
    
    Aimbot = [[
        -- ============================================
        -- 🔧 SWILL | AIMBOT MODULE v1.0
        -- СИСТЕМА НАВЕДЕНИЯ
        -- ============================================
        
        local S = _G.SWILL
        
        local function GetClosestTarget()
            local myChar = S.Player.Character
            if not myChar then return nil end
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return nil end
            local cam = S.Camera
            if not cam then return nil end
            
            local cfg = S.Config.Aimbot
            local bestTarget = nil
            local bestAngle = math.huge
            
            for _, p in pairs(S.Players:GetPlayers()) do
                if p ~= S.Player then
                    local char = p.Character
                    if char then
                        local humanoid = char:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            local targetPart = char:FindFirstChild(cfg.Target) or char:FindFirstChild("HumanoidRootPart")
                            if targetPart then
                                local pos = targetPart.Position
                                local dist = (myRoot.Position - pos).Magnitude
                                if dist <= cfg.Distance then
                                    if cfg.Wallcheck then
                                        local ray = Ray.new(cam.CFrame.Position, (pos - cam.CFrame.Position).Unit * dist)
                                        local hit = S.Workspace:FindPartOnRay(ray, myChar)
                                        if hit and not hit:IsDescendantOf(char) then
                                            continue
                                        end
                                    end
                                    local screenPos, onScreen = cam:WorldToViewportPoint(pos)
                                    if onScreen then
                                        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                                        local angle = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                                        if angle < bestAngle and angle < S.Config.FOV.Radius then
                                            bestAngle = angle
                                            bestTarget = targetPart
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            return bestTarget
        end
        
        spawn(function()
            while S.Active do
                S.RS.RenderStepped:Wait()
                if S.Config.Aimbot.Enabled then
                    local target = GetClosestTarget()
                    if target then
                        local cam = S.Camera
                        if cam then
                            local targetPos = target.Position
                            local lookAt = CFrame.lookAt(cam.CFrame.Position, targetPos)
                            cam.CFrame = cam.CFrame:Lerp(lookAt, S.Config.Aimbot.Smooth)
                        end
                    end
                end
            end
        end)
        
        print("[SWILL] Aimbot.lua загружен")
    ]],
    
    Menu = [[
        -- ============================================
        -- 🔧 SWILL | MENU MODULE v1.0
        -- ПАНЕЛЬ УПРАВЛЕНИЯ
        -- ============================================
        
        local S = _G.SWILL
        local C = S.Config.Colors
        
        -- Кнопка открытия меню
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
                    Menu.Visible = not Menu.Visible
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
        
        -- Меню
        local Menu = Instance.new("Frame")
        Menu.Size = UDim2.new(0, 350, 0, 400)
        Menu.Position = UDim2.new(0.5, -175, 0.5, -200)
        Menu.BackgroundColor3 = C.BG
        Menu.Visible = false
        Menu.ZIndex = 50
        Menu.Parent = S.GUI
        Instance.new("UICorner", Menu).CornerRadius = UDim.new(0, 14)
        
        -- Заголовок
        local Header = Instance.new("Frame")
        Header.Size = UDim2.new(1, 0, 0, 45)
        Header.BackgroundColor3 = C.SEC
        Header.ZIndex = 51
        Header.Parent = Menu
        Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(0.7, 0, 1, 0)
        Title.Position = UDim2.new(0.05, 0, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "🔧 SWILL MENU"
        Title.TextColor3 = C.ACC
        Title.TextSize = 16
        Title.Font = Enum.Font.GothamBold
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.ZIndex = 52
        Title.Parent = Header
        
        -- Крестик
        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 32, 0, 32)
        CloseBtn.Position = UDim2.new(0.85, 0, 0.12, 0)
        CloseBtn.BackgroundColor3 = C.RED
        CloseBtn.Text = "✕"
        CloseBtn.TextColor3 = C.WHT
        CloseBtn.TextSize = 16
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.ZIndex = 52
        CloseBtn.AutoButtonColor = false
        CloseBtn.Parent = Header
        Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
        
        CloseBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                Menu.Visible = false
            end
        end)
        
        -- Контент (прокручиваемый)
        local Content = Instance.new("ScrollingFrame")
        Content.Size = UDim2.new(1, -10, 1, -100)
        Content.Position = UDim2.new(0, 5, 0, 50)
        Content.BackgroundTransparency = 1
        Content.BorderSizePixel = 0
        Content.CanvasSize = UDim2.new(0, 0, 0, 400)
        Content.ScrollBarThickness = 4
        Content.ScrollBarImageColor3 = C.ACC
        Content.ZIndex = 51
        Content.Parent = Menu
        
        local List = Instance.new("UIListLayout")
        List.Padding = UDim.new(0, 10)
        List.HorizontalAlignment = Enum.HorizontalAlignment.Center
        List.SortOrder = Enum.SortOrder.LayoutOrder
        List.Parent = Content
        
        -- Функция создания переключателя
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
            sw.Size = UDim2.new(0, 48, 0, 26)
            sw.Position = UDim2.new(0.76, 0, 0.3, 0)
            sw.BackgroundColor3 = default and C.GRN or C.BG
            sw.Text = ""
            sw.AutoButtonColor = false
            sw.ZIndex = 52
            sw.Parent = sec
            Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
            
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 18, 0, 18)
            dot.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)
            dot.BackgroundColor3 = C.WHT
            dot.BorderSizePixel = 0
            dot.ZIndex = 53
            dot.Parent = sw
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            
            local state = default
          
