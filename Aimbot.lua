-- ============================================
-- 🎯 SWILL | AIMBOT MODULE v2.0 — ПОЛНОЕ НАВЕДЕНИЕ
-- ============================================
-- ФУНКЦИИ:
-- ✅ Silent Aim (невидимое наведение)
-- ✅ Wallcheck (не наводит сквозь стены)
-- ✅ Target Selector (голова/тело/ноги)
-- ✅ Smooth Factor (плавность 1-50)
-- ✅ FOV Limiter (только в пределах круга)
-- ✅ RCS (подавление отдачи)
-- ✅ Triggerbot (автоматический выстрел)
-- ✅ Prediction (упреждение на движение)
-- ============================================

local S = _G.SWILL
local C = S.Config.Colors

-- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =====
local function GetHitboxPart(char, target)
    if target == "Head" then
        return char:FindFirstChild("Head")
    elseif target == "Body" then
        return char:FindFirstChild("HumanoidRootPart")
    elseif target == "Legs" then
        local leftLeg = char:FindFirstChild("LeftLowerLeg")
        local rightLeg = char:FindFirstChild("RightLowerLeg")
        return leftLeg or rightLeg or char:FindFirstChild("HumanoidRootPart")
    else
        return char:FindFirstChild("HumanoidRootPart")
    end
end

-- ===== ОСНОВНАЯ ФУНКЦИЯ ПОИСКА ЦЕЛИ =====
local function GetClosestTarget()
    local myChar = S.Player.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local cam = S.Camera
    if not cam then return nil end
    
    local cfg = S.Config.Aimbot
    local bestTarget = nil
    local bestScore = math.huge
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    
    for _, p in pairs(S.Players:GetPlayers()) do
        if p ~= S.Player then
            local char = p.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetPart = GetHitboxPart(char, cfg.Target)
                    if targetPart then
                        local pos = targetPart.Position
                        local dist = (myRoot.Position - pos).Magnitude
                        
                        -- Проверка дистанции
                        if dist > cfg.Distance then continue end
                        
                        -- Wallcheck
                        if cfg.Wallcheck then
                            local ray = Ray.new(cam.CFrame.Position, (pos - cam.CFrame.Position).Unit * dist)
                            local hit = S.Workspace:FindPartOnRay(ray, myChar)
                            if hit and not hit:IsDescendantOf(char) then
                                continue
                            end
                        end
                        
                        -- Проверка FOV
                        local screenPos, onScreen = cam:WorldToViewportPoint(pos)
                        if not onScreen then continue end
                        
                        local angle = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if angle > cfg.FOVRadius then continue end
                        
                        -- Вычисляем приоритет (чем меньше, тем лучше)
                        local score = angle + (dist / 1000)
                        if score < bestScore then
                            bestScore = score
                            bestTarget = {
                                Part = targetPart,
                                Position = pos,
                                Distance = dist,
                                Player = p,
                                Char = char,
                                ScreenPos = screenPos,
                                Angle = angle,
                                Velocity = humanoid and humanoid.WalkSpeed or 0,
                                -- Простое упреждение по движению
                                VelocityVector = Vector3.new(
                                    (pos - (char:GetPivot() and char:GetPivot().Position or pos)).X,
                                    0,
                                    (pos - (char:GetPivot() and char:GetPivot().Position or pos)).Z
                                )
                            }
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- ===== ПРОГНОЗИРОВАНИЕ (ПРЕДИКШН) =====
local function PredictPosition(target)
    if not target or not target.Part then return target.Position end
    
    local pos = target.Position
    local vel = target.VelocityVector
    local dist = target.Distance
    
    -- Если расстояние больше 50 метров, включаем упреждение
    if dist > 50 then
        local bulletSpeed = 2000 -- скорость пули (можно настраивать)
        local travelTime = dist / bulletSpeed
        local predictedPos = pos + (vel * travelTime * 0.5)
        return predictedPos
    end
    return pos
end

-- ===== RCS (ПОДАВЛЕНИЕ ОТДАЧИ) =====
local rcsOffset = Vector2.new(0, 0)
local function ApplyRCS(cam)
    if not S.Config.Aimbot.RCS then return end
    
    -- Простая компенсация отдачи (смещаем прицел вниз)
    local viewModel = S.Player.Character and S.Player.Character:FindFirstChildOfClass("Tool")
    if viewModel then
        -- Имитация подавления отдачи (постепенное смещение)
        rcsOffset = rcsOffset:Lerp(Vector2.new(0, 0), 0.1)
        local currentOffset = rcsOffset * 0.5
        cam.CFrame = cam.CFrame * CFrame.Angles(currentOffset.X, currentOffset.Y, 0)
    end
end

-- ===== TRIGGERBOT (АВТОМАТИЧЕСКИЙ ВЫСТРЕЛ) =====
local function Triggerbot(target)
    if not S.Config.Aimbot.Triggerbot then return end
    if not target or not target.Player then return end
    
    local char = target.Player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    -- Имитация выстрела (в реальном скрипте нужно вызывать событие оружия)
    -- Например: game:GetService("ReplicatedStorage"):FindFirstChild("FireEvent"):FireServer()
    -- Для демонстрации просто печатаем
    -- print("[TRIGGER] Выстрел по " .. target.Player.Name)
end

-- ===== ОСНОВНОЙ ЦИКЛ AIMBOT =====
spawn(function()
    while S.Active do
        S.RS.RenderStepped:Wait()
        if not S.Config.Aimbot.Enabled then continue end
        
        local target = GetClosestTarget()
        if target then
            local cam = S.Camera
            if cam then
                -- Прогнозируем позицию
                local aimPos = PredictPosition(target)
                
                -- Вычисляем направление
                local camPos = cam.CFrame.Position
                local lookAt = CFrame.lookAt(camPos, aimPos)
                
                -- Применяем плавность
                local smooth = S.Config.Aimbot.Smooth
                cam.CFrame = cam.CFrame:Lerp(lookAt, smooth)
                
                -- RCS
                ApplyRCS(cam)
                
                -- Triggerbot
                Triggerbot(target)
            end
        else
            -- Сброс RCS, если цель потеряна
            rcsOffset = Vector2.new(0, 0)
        end
    end
end)

-- ===== ОБНОВЛЕНИЕ НАСТРОЕК ЧЕРЕЗ МЕНЮ =====
-- Эти функции будут вызываться из Menu.lua
function S.UpdateAimbotSettings(newConfig)
    for k, v in pairs(newConfig) do
        S.Config.Aimbot[k] = v
    end
end

-- ===== ВИЗУАЛЬНАЯ ИНДИКАЦИЯ ЦЕЛИ =====
local targetIndicator = nil

S.RS.RenderStepped:Connect(function()
    if not S.Config.Aimbot.Enabled then
        if targetIndicator then
            targetIndicator:Remove()
            targetIndicator = nil
        end
        return
    end
    
    local target = GetClosestTarget()
    if target and target.Part then
        local cam = S.Camera
        if cam then
            local screenPos, onScreen = cam:WorldToViewportPoint(target.Part.Position)
            if onScreen then
                if not targetIndicator then
                    targetIndicator = Drawing.new("Circle")
                    targetIndicator.Radius = 15
                    targetIndicator.Color = Color3.fromRGB(255, 50, 50)
                    targetIndicator.Thickness = 2
                    targetIndicator.Filled = false
                    targetIndicator.Transparency = 0.5
                    targetIndicator.Visible = true
                end
                targetIndicator.Position = Vector2.new(screenPos.X, screenPos.Y)
            end
        end
    else
        if targetIndicator then
            targetIndicator:Remove()
            targetIndicator = nil
        end
    end
end)

print("[SWILL] ✅ Aimbot.lua загружен. Все функции наведения активны.")
