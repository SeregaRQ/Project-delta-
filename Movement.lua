-- ============================================
-- 🏃 SWILL | MOVEMENT MODULE v2.0 — БЫСТРЕЕ ВЕТРА
-- ============================================
-- ФУНКЦИИ:
-- ✅ Speed Hack (x1 - x10)
-- ✅ Flight (полёт в любом направлении)
-- ✅ No Clip (проход сквозь стены)
-- ✅ Teleport (к цели по кнопке)
-- ✅ Jump Hack (супер-прыжок + бесконечные прыжки)
-- ✅ Air Control (управление в воздухе)
-- ✅ No Fall Damage (игнорирование падения)
-- ✅ Auto Sprint (постоянный бег)
-- ============================================

local S = _G.SWILL
local C = S.Config.Colors

-- ===== ПЕРЕМЕННЫЕ =====
local player = S.Player
local character = player.Character
local humanoid = character and character:FindFirstChild("Humanoid")
local rootPart = character and character:FindFirstChild("HumanoidRootPart")

-- ===== SPEED HACK (УВЕЛИЧЕНИЕ СКОРОСТИ) =====
local function ApplySpeedHack()
    if not S.Config.Movement.Speed then return end
    local speedMultiplier = S.Config.Movement.Speed or 1
    
    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = 16 * speedMultiplier
    end
end

-- ===== JUMP HACK (СУПЕР-ПРЫЖОК) =====
local function ApplyJumpHack()
    if not S.Config.Movement.JumpPower then return end
    local jumpMultiplier = S.Config.Movement.JumpPower or 1
    
    if humanoid and humanoid.Parent then
        humanoid.JumpPower = 50 * jumpMultiplier
        humanoid.JumpHeight = 50 * jumpMultiplier
    end
end

-- ===== FLIGHT (ПОЛЁТ) =====
local flightActive = false
local flightVelocity = Vector3.new(0, 0, 0)
local flightSpeed = 50
local isFlying = false

local function ToggleFlight()
    flightActive = not flightActive
    S.Config.Movement.Flight = flightActive
    
    if flightActive then
        if humanoid and humanoid.Parent then
            humanoid.PlatformStand = true
            humanoid.AutoRotate = false
        end
        print("[FLIGHT] Включён")
    else
        if humanoid and humanoid.Parent then
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
        end
        flightVelocity = Vector3.new(0, 0, 0)
        print("[FLIGHT] Выключен")
    end
end

-- Управление полётом (через свайпы или клавиши)
S.UIS.InputBegan:Connect(function(input)
    if not flightActive then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        -- Определяем направление полёта по позиции касания
        local screenPos = input.Position
        local viewport = S.Camera.ViewportSize
        local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
        
        local direction = (screenPos - center).Unit
        local forward = S.Camera.CFrame.LookVector
        local right = S.Camera.CFrame.RightVector
        local up = S.Camera.CFrame.UpVector
        
        -- Движение в зависимости от зоны экрана
        if screenPos.Y < center.Y then
            flightVelocity = forward * flightSpeed
        elseif screenPos.Y > center.Y then
            flightVelocity = -forward * flightSpeed
        elseif screenPos.X < center.X then
            flightVelocity = -right * flightSpeed
        elseif screenPos.X > center.X then
            flightVelocity = right * flightSpeed
        end
        
        -- Подъём/спуск по двойному тапу
        if input.UserInputType == Enum.UserInputType.Touch then
            -- Простая реализация: нажатие вверх/вниз
        end
    end
end)

-- ===== NO CLIP (ПРОХОД СКВОЗЬ СТЕНЫ) =====
local function ApplyNoClip()
    if not S.Config.Movement.NoClip then return end
    if not rootPart then return end
    
    rootPart.CanCollide = false
    rootPart.CanTouch = false
    
    -- Если есть другие части тела, тоже отключаем коллизии
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
                part.CanTouch = false
            end
        end
    end
end

-- ===== TELEPORT (К ЦЕЛИ) =====
function S.TeleportToTarget(targetPlayer)
    if not targetPlayer then return end
    
    local targetChar = targetPlayer.Character
    if not targetChar then return end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    if rootPart then
        rootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 3, 0))
        print("[TELEPORT] Телепорт к " .. targetPlayer.Name)
    end
end

-- ===== AIR CONTROL (УПРАВЛЕНИЕ В ВОЗДУХЕ) =====
local airControlActive = false

local function ApplyAirControl()
    if not S.Config.Movement.AirControl then return end
    if not humanoid or not rootPart then return end
    
    -- Позволяем двигаться в воздухе как на земле
    if humanoid:GetState() == Enum.HumanoidStateType.Jumping or 
       humanoid:GetState() == Enum.HumanoidStateType.Falling then
        -- Простая реализация: увеличиваем воздушное управление
        humanoid.AirControl = 1.0
    else
        humanoid.AirControl = 0.1
    end
end

-- ===== NO FALL DAMAGE (БЕЗ УРОНА ОТ ПАДЕНИЯ) =====
local function ApplyNoFallDamage()
    if not S.Config.Movement.NoFallDamage then return end
    if not humanoid then return end
    
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
end

-- ===== AUTO SPRINT (ПОСТОЯННЫЙ БЕГ) =====
local function ApplyAutoSprint()
    if not S.Config.Movement.AutoSprint then return end
    if not humanoid then return end
    
    humanoid.AutoRotate = true
    humanoid.Running:Connect(function(speed)
        if speed > 0 then
            humanoid.WalkSpeed = humanoid.WalkSpeed * 1.2 -- небольшое ускорение
        end
    end)
end

-- ===== ОСНОВНОЙ ЦИКЛ ДВИЖЕНИЯ =====
spawn(function()
    while S.Active do
        S.RS.RenderStepped:Wait()
        
        -- Обновляем персонажа
        character = player.Character
        if not character then 
            wait(1)
            continue 
        end
        
        humanoid = character:FindFirstChild("Humanoid")
        rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not rootPart then 
            wait(1)
            continue 
        end
        
        -- Применяем все эффекты
        ApplySpeedHack()
        ApplyJumpHack()
        ApplyNoClip()
        ApplyNoFallDamage()
        ApplyAirControl()
        ApplyAutoSprint()
        
        -- Flight
        if flightActive then
            if rootPart then
                rootPart.Velocity = flightVelocity
                -- Поддержание высоты
                if flightVelocity.Y == 0 then
                    rootPart.Velocity = Vector3.new(flightVelocity.X, 0, flightVelocity.Z)
                end
            end
        end
    end
end)

-- ===== ОБРАБОТКА ПЕРЕРОЖДЕНИЯ =====
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:FindFirstChild("Humanoid")
    rootPart = character:FindFirstChild("HumanoidRootPart")
    
    -- Восстанавливаем состояние после перерождения
    if S.Config.Movement.Flight then
        flightActive = true
        if humanoid then
            humanoid.PlatformStand = true
            humanoid.AutoRotate = false
        end
    end
end)

-- ===== КОМАНДЫ ДЛЯ ТЕЛЕПОРТА =====
-- Можно вызывать из меню: S.TeleportToTarget(S.Players:FindFirstChild("Имя"))
-- Или использовать функцию для автоматического телепорта к ближайшему врагу

function S.TeleportToClosestEnemy()
    local closest = nil
    local closestDist = math.huge
    
    for _, p in pairs(S.Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root and rootPart then
                    local dist = (rootPart.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = p
                    end
                end
            end
        end
    end
    
    if closest then
        S.TeleportToTarget(closest)
    end
end

-- ===== ВИЗУАЛЬНАЯ ИНДИКАЦИЯ СТАТУСА =====
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(0, 200, 0, 30)
statusText.Position = UDim2.new(0.5, -100, 0, 50)
statusText.BackgroundTransparency = 1
statusText.Text = ""
statusText.TextColor3 = C.WHT
statusText.TextSize = 14
statusText.Font = Enum.Font.GothamBold
statusText.ZIndex = 999
statusText.Parent = S.GUI

spawn(function()
    while S.Active do
        local status = ""
        if S.Config.Movement.Flight then status = status .. "✈️ " end
        if S.Config.Movement.NoClip then status = status .. "👻 " end
        if S.Config.Movement.Speed and S.Config.Movement.Speed > 1 then 
            status = status .. "⚡ x" .. S.Config.Movement.Speed .. " " 
        end
        if status == "" then status = "🦿 Нормальный режим" end
        statusText.Text = status
        wait(0.5)
    end
end)

print("[SWILL] ✅ Movement.lua загружен. Все функции движения активны.")
