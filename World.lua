-- ============================================
-- 🌍 SWILL | WORLD MODULE v2.0 — ТВОЙ МИР
-- ============================================
-- ФУНКЦИИ:
-- ✅ Day/Night (мгновенная смена времени)
-- ✅ Weather Control (дождь, туман, снег)
-- ✅ Fog Control (плотность тумана)
-- ✅ Free Camera (свободная камера)
-- ✅ Item ESP (аптечки, оружие, броня)
-- ✅ Vehicle ESP (транспорт)
-- ============================================

local S = _G.SWILL
local C = S.Config.Colors

-- ===== ПЕРЕМЕННЫЕ =====
local lighting = game:GetService("Lighting")
local weatherService = game:GetService("Weather") -- если есть
local freeCamActive = false
local freeCamPart = nil
local originalCamCFrame = nil

-- ===== DAY/NIGHT (СМЕНА ВРЕМЕНИ СУТОК) =====
local function ApplyDayNight()
    if not S.Config.World.Day then return end
    
    -- День
    if S.Config.World.Day == "Day" then
        lighting.Brightness = 2
        lighting.ClockTime = 12
        lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        lighting.Ambient = Color3.fromRGB(128, 128, 128)
        lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
    else
        -- Ночь
        lighting.Brightness = 0.5
        lighting.ClockTime = 0
        lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 50)
        lighting.Ambient = Color3.fromRGB(20, 20, 30)
        lighting.ColorShift_Bottom = Color3.fromRGB(50, 50, 100)
    end
end

-- ===== WEATHER CONTROL (УПРАВЛЕНИЕ ПОГОДОЙ) =====
local function ApplyWeather()
    if not S.Config.World.Weather then return end
    local weatherType = S.Config.World.Weather
    
    -- Пытаемся найти систему погоды
    local weatherSystem = workspace:FindFirstChild("WeatherSystem") or workspace:FindFirstChild("Sky")
    
    if weatherSystem then
        if weatherType == "Rain" then
            if weatherSystem:FindFirstChild("Rain") then
                weatherSystem.Rain.Enabled = true
            end
            if weatherSystem:FindFirstChild("Fog") then
                weatherSystem.Fog.Enabled = false
            end
            if weatherSystem:FindFirstChild("Snow") then
                weatherSystem.Snow.Enabled = false
            end
        elseif weatherType == "Fog" then
            if weatherSystem:FindFirstChild("Fog") then
                weatherSystem.Fog.Enabled = true
            end
            if weatherSystem:FindFirstChild("Rain") then
                weatherSystem.Rain.Enabled = false
            end
            if weatherSystem:FindFirstChild("Snow") then
                weatherSystem.Snow.Enabled = false
            end
        elseif weatherType == "Snow" then
            if weatherSystem:FindFirstChild("Snow") then
                weatherSystem.Snow.Enabled = true
            end
            if weatherSystem:FindFirstChild("Rain") then
                weatherSystem.Rain.Enabled = false
            end
            if weatherSystem:FindFirstChild("Fog") then
                weatherSystem.Fog.Enabled = false
            end
        else -- Clear
            if weatherSystem:FindFirstChild("Rain") then
                weatherSystem.Rain.Enabled = false
            end
            if weatherSystem:FindFirstChild("Fog") then
                weatherSystem.Fog.Enabled = false
            end
            if weatherSystem:FindFirstChild("Snow") then
                weatherSystem.Snow.Enabled = false
            end
        end
    else
        -- Упрощённый вариант через Lighting
        if weatherType == "Rain" then
            lighting.Brightness = 0.7
            lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 120)
        elseif weatherType == "Fog" then
            lighting.FogEnd = 50
            lighting.FogStart = 0
        elseif weatherType == "Snow" then
            lighting.Brightness = 0.8
            lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 220)
        else
            lighting.FogEnd = 1000
            lighting.FogStart = 0
            lighting.Brightness = 2
        end
    end
end

-- ===== FOG CONTROL (УПРАВЛЕНИЕ ТУМАНОМ) =====
local function ApplyFog()
    if not S.Config.World.Fog then return end
    local fogDensity = S.Config.World.FogDensity or 0.3
    
    lighting.FogEnd = 100 / fogDensity
    lighting.FogStart = 0
    lighting.FogColor = Color3.fromRGB(180, 180, 200)
end

-- ===== FREE CAMERA (СВОБОДНАЯ КАМЕРА) =====
local function ToggleFreeCam()
    freeCamActive = not freeCamActive
    S.Config.World.FreeCam = freeCamActive
    
    if freeCamActive then
        -- Сохраняем оригинальную камеру
        originalCamCFrame = S.Camera.CFrame
        
        -- Создаём объект для камеры
        if not freeCamPart then
            freeCamPart = Instance.new("Part")
            freeCamPart.Size = Vector3.new(1, 1, 1)
            freeCamPart.Anchored = true
            freeCamPart.CanCollide = false
            freeCamPart.Transparency = 1
            freeCamPart.Parent = S.Workspace
        end
        
        -- Устанавливаем камеру на объект
        S.Camera.CameraSubject = freeCamPart
        S.Camera.CameraType = Enum.CameraType.Custom
        
        print("[FREECAM] Включена")
    else
        -- Возвращаем камеру игроку
        S.Camera.CameraSubject = S.Player.Character
        S.Camera.CameraType = Enum.CameraType.Follow
        
        if freeCamPart then
            freeCamPart:Destroy()
            freeCamPart = nil
        end
        
        print("[FREECAM] Выключена")
    end
end

-- Управление свободной камерой (через Touch)
S.UIS.InputBegan:Connect(function(input)
    if not freeCamActive then return end
    if not freeCamPart then return end
    if input.UserInputType ~= Enum.UserInputType.Touch then return end
    
    -- Перемещение камеры по свайпу
    local screenPos = input.Position
    local viewport = S.Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    
    local direction = (screenPos - center).Unit
    local speed = 50
    
    if screenPos.Y < center.Y - 50 then
        -- Вверх (вперёд)
        freeCamPart.CFrame = freeCamPart.CFrame + S.Camera.CFrame.LookVector * speed
    elseif screenPos.Y > center.Y + 50 then
        -- Вниз (назад)
        freeCamPart.CFrame = freeCamPart.CFrame - S.Camera.CFrame.LookVector * speed
    elseif screenPos.X < center.X - 50 then
        -- Влево
        freeCamPart.CFrame = freeCamPart.CFrame - S.Camera.CFrame.RightVector * speed
    elseif screenPos.X > center.X + 50 then
        -- Вправо
        freeCamPart.CFrame = freeCamPart.CFrame + S.Camera.CFrame.RightVector * speed
    end
end)

-- ===== ITEM ESP (ОТОБРАЖЕНИЕ ПРЕДМЕТОВ) =====
local itemESPObjects = {}

local function CreateItemESP(item)
    if not S.Config.World.ItemESP then return end
    
    -- Фильтруем типы предметов
    local itemName = item.Name
    local isLoot = itemName:find("Health") or itemName:find("Ammo") or 
                   itemName:find("Armor") or itemName:find("Shield") or
                   itemName:find("Weapon") or itemName:find("Chest")
    
    if not isLoot then return end
    
    -- Создаём BillboardGui для предмета
    local bill = Instance.new("BillboardGui")
    bill.Name = "SWILL_ITEM"
    bill.Size = UDim2.new(0, 100, 0, 30)
    bill.StudsOffset = Vector3.new(0, 1, 0)
    bill.AlwaysOnTop = true
    bill.MaxDistance = 200
    bill.Parent = item
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = itemName
    label.TextColor3 = C.ACC
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.3
    label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    label.Parent = bill
    
    -- Добавляем рамку вокруг предмета
    local highlight = Instance.new("Highlight")
    highlight.Name = "SWILL_ITEM"
    highlight.FillColor = C.ACC
    highlight.FillTransparency = 0.8
    highlight.OutlineColor = C.ACC
    highlight.OutlineTransparency = 0.2
    highlight.Parent = item
    
    itemESPObjects[item] = {
        Billboard = bill,
        Highlight = highlight,
        Label = label
    }
end

local function RemoveItemESP(item)
    local obj = itemESPObjects[item]
    if obj then
        if obj.Billboard then obj.Billboard:Destroy() end
        if obj.Highlight then obj.Highlight:Destroy() end
        itemESPObjects[item] = nil
    end
end

-- Поиск предметов на карте
spawn(function()
    while S.Active do
        S.RS.RenderStepped:Wait()
        if not S.Config.World.ItemESP then
            -- Удаляем всё, если выключено
            for item, obj in pairs(itemESPObjects) do
                if obj.Billboard then obj.Billboard:Destroy() end
                if obj.Highlight then obj.Highlight:Destroy() end
            end
            itemESPObjects = {}
            continue
        end
        
        -- Поиск предметов
        local foundItems = {}
        
        -- Ищем в Workspace
        for _, child in pairs(S.Workspace:GetChildren()) do
            if child:IsA("BasePart") and child.Name:find("Health") or 
               child.Name:find("Ammo") or child.Name:find("Armor") or
               child.Name:find("Weapon") or child.Name:find("Chest") then
                if not itemESPObjects[child] then
                    CreateItemESP(child)
                end
                foundItems[child] = true
            end
        end
        
        -- Удаляем ESP для предметов, которых больше нет
        for item, obj in pairs(itemESPObjects) do
            if not foundItems[item] then
                RemoveItemESP(item)
            end
        end
        
        wait(2) -- Обновляем каждые 2 секунды
    end
end)

-- ===== VEHICLE ESP (ОТОБРАЖЕНИЕ ТРАНСПОРТА) =====
local vehicleESPObjects = {}

local function CreateVehicleESP(vehicle)
    if not S.Config.World.VehicleESP then return end
    
    local bill = Instance.new("BillboardGui")
    bill.Name = "SWILL_VEHICLE"
    bill.Size = UDim2.new(0, 100, 0, 30)
    bill.StudsOffset = Vector3.new(0, 3, 0)
    bill.AlwaysOnTop = true
    bill.MaxDistance = 300
    bill.Parent = vehicle
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🚗 " .. vehicle.Name
    label.TextColor3 = Color3.fromRGB(100, 200, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.3
    label.Parent = bill
    
    vehicleESPObjects[vehicle] = {
        Billboard = bill,
        Label = label
    }
end

local function RemoveVehicleESP(vehicle)
    local obj = vehicleESPObjects[vehicle]
    if obj then
        if obj.Billboard then obj.Billboard:Destroy() end
        vehicleESPObjects[vehicle] = nil
    end
end

-- Поиск транспорта
spawn(function()
    while S.Active do
        S.RS.RenderStepped:Wait()
        if not S.Config.World.VehicleESP then
            for vehicle, obj in pairs(vehicleESPObjects) do
                if obj.Billboard then obj.Billboard:Destroy() end
            end
            vehicleESPObjects = {}
            continue
        end
        
        local foundVehicles = {}
        
        for _, child in pairs(S.Workspace:GetChildren()) do
            if child:IsA("Model") and child:FindFirstChild("VehicleSeat") then
                if not vehicleESPObjects[child] then
                    CreateVehicleESP(child)
                end
                foundVehicles[child] = true
            end
        end
        
        for vehicle, obj in pairs(vehicleESPObjects) do
            if not foundVehicles[vehicle] then
                RemoveVehicleESP(vehicle)
            end
        end
        
        wait(2)
    end
end)

-- ===== ОСНОВНОЙ ЦИКЛ =====
spawn(function()
    while S.Active do
        S.RS.RenderStepped:Wait()
        
        -- Применяем изменения мира
        ApplyDayNight()
        ApplyWeather()
        ApplyFog()
    end
end)

-- ===== ВИЗУАЛЬНАЯ ИНДИКАЦИЯ =====
local worldStatus = Instance.new("TextLabel")
worldStatus.Size = UDim2.new(0, 200, 0, 30)
worldStatus.Position = UDim2.new(0.5, -100, 0, 90)
worldStatus.BackgroundTransparency = 1
worldStatus.Text = "🌍 Мир"
worldStatus.TextColor3 = C.GRY
worldStatus.TextSize = 13
worldStatus.Font = Enum.Font.GothamBold
worldStatus.ZIndex = 999
worldStatus.Parent = S.GUI

spawn(function()
    while S.Active do
        local status = "🌍 "
        if S.Config.World.Day == "Day" then status = status .. "☀️ " end
        if S.Config.World.Day == "Night" then status = status .. "🌙 " end
        if S.Config.World.Weather and S.Config.World.Weather ~= "Clear" then 
            status = status .. S.Config.World.Weather .. " " 
        end
        if S.Config.World.Fog then status = status .. "🌫️ " end
        if S.Config.World.FreeCam then status = status .. "📷 " end
        if S.Config.World.ItemESP then status = status .. "📦 " end
        if S.Config.World.VehicleESP then status = status .. "🚗 " end
        
        worldStatus.Text = status
        wait(0.5)
    end
end)

print("[SWILL] ✅ World.lua загружен. Все функции мира активны.")
