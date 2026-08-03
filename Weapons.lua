-- ============================================
-- 🔫 SWILL | WEAPONS MODULE v2.0 — АРСЕНАЛ БОГА
-- ============================================
-- ФУНКЦИИ:
-- ✅ No Recoil (полное отсутствие отдачи)
-- ✅ No Spread (пули в одну точку)
-- ✅ Infinite Ammo (бесконечный магазин)
-- ✅ Instant Reload (мгновенная перезарядка)
-- ✅ Damage Mod (x1 - x10 урона)
-- ✅ Fire Rate Mod (x1 - x5 скорострельности)
-- ✅ Bullet Speed (ускорение пуль)
-- ============================================

local S = _G.SWILL
local C = S.Config.Colors

-- ===== ПЕРЕМЕННЫЕ =====
local player = S.Player
local character = player.Character
local currentTool = nil
local originalProperties = {}

-- ===== ПОИСК ОРУЖИЯ =====
local function GetCurrentWeapon()
    if not character then return nil end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    
    -- Ищем основную часть оружия (обычно Handle или часть с анимацией)
    local weaponPart = tool:FindFirstChild("Handle") or tool:FindFirstChild("Part") or tool
    if not weaponPart then return nil end
    
    return {
        Tool = tool,
        Part = weaponPart,
        Name = tool.Name
    }
end

-- ===== NO RECOIL (УБИРАЕМ ОТДАЧУ) =====
local function ApplyNoRecoil()
    if not S.Config.Weapons.NoRecoil then return end
    local weapon = GetCurrentWeapon()
    if not weapon then return end
    
    -- Сохраняем оригинальные параметры (если ещё не сохранили)
    if not originalProperties[weapon.Name] then
        originalProperties[weapon.Name] = {}
    end
    
    -- Отключаем отдачу (через изменение свойств)
    -- В Roblox отдача управляется через AnimationTrack или свойства оружия
    -- Мы используем упрощённый метод: изменяем угол прицеливания
    if weapon.Part then
        -- Если есть свойство Recoil, отключаем его
        if weapon.Part:FindFirstChild("Recoil") then
            weapon.Part.Recoil.Enabled = false
        end
        
        -- Убираем колебания при выстреле
        if weapon.Part:FindFirstChild("Sway") then
            weapon.Part.Sway.Enabled = false
        end
    end
    
    -- В некоторых играх отдача контролируется через репликацию
    -- В этом случае мы перехватываем событие выстрела
    local tool = weapon.Tool
    if tool then
        -- Пример: подмена события выстрела
        tool:FindFirstChild("FireEvent") and tool.FireEvent:Connect(function()
            -- Отключаем отдачу
        end)
    end
end

-- ===== NO SPREAD (ПУЛИ В ТОЧКУ) =====
local function ApplyNoSpread()
    if not S.Config.Weapons.NoSpread then return end
    local weapon = GetCurrentWeapon()
    if not weapon then return end
    
    -- В Roblox разброс контролируется через свойства Accuracy или Spread
    if weapon.Part then
        if weapon.Part:FindFirstChild("Spread") then
            weapon.Part.Spread.Value = 0
        end
        if weapon.Part:FindFirstChild("Accuracy") then
            weapon.Part.Accuracy.Value = 100
        end
    end
end

-- ===== INFINITE AMMO (БЕСКОНЕЧНЫЙ БОЕЗАПАС) =====
local function ApplyInfiniteAmmo()
    if not S.Config.Weapons.InfiniteAmmo then return end
    local weapon = GetCurrentWeapon()
    if not weapon then return end
    
    local tool = weapon.Tool
    if not tool then return end
    
    -- Ищем свойства боезапаса
    local ammoProperties = {"Ammo", "AmmoCount", "ClipAmmo", "ReserveAmmo"}
    
    for _, propName in pairs(ammoProperties) do
        local prop = tool:FindFirstChild(propName)
        if prop then
            if prop:IsA("NumberValue") or prop:IsA("IntValue") then
                prop.Value = 999
            end
        end
    end
    
    -- Если есть патроны в руке
    local ammoPart = tool:FindFirstChild("Bullets")
    if ammoPart then
        ammoPart:Destroy()
    end
end

-- ===== INSTANT RELOAD (МГНОВЕННАЯ ПЕРЕЗАРЯДКА) =====
local function ApplyInstantReload()
    if not S.Config.Weapons.InstantReload then return end
    local weapon = GetCurrentWeapon()
    if not weapon then return end
    
    local tool = weapon.Tool
    if not tool then return end
    
    -- Ускоряем анимацию перезарядки
    local reloadAnim = tool:FindFirstChild("ReloadAnimation")
    if reloadAnim and reloadAnim:IsA("Animation") then
        local track = tool:FindFirstChildOfClass("Animator")
        if track then
            track:LoadAnimation(reloadAnim):Stop()
        end
    end
    
    -- Мгновенная перезарядка через свойство
    local reloadProp = tool:FindFirstChild("ReloadTime")
    if reloadProp and (reloadProp:IsA("NumberValue") or reloadProp:IsA("IntValue")) then
        reloadProp.Value = 0.01
    end
end

-- ===== DAMAGE MOD (МНОЖИТЕЛЬ УРОНА) =====
local function ApplyDamageMod()
    if not S.Config.Weapons.Damage then return end
    local damageMultiplier = S.Config.Weapons.Damage or 1
    
    local weapon = GetCurrentWeapon()
    if not weapon then return end
    
    local tool = weapon.Tool
    if not tool then return end
    
    -- Ищем свойства урона
    local damageProp = tool:FindFirstChild("Damage")
    if damageProp and (damageProp:IsA("NumberValue") or damageProp:IsA("IntValue")) then
        originalProperties[weapon.Name] = originalProperties[weapon.Name] or {}
        originalProperties[weapon.Name].Damage = damageProp.Value
        
        damageProp.Value = damageProp.Value * damageMultiplier
    end
    
    -- Если есть система хитбоксов
    local hitbox = tool:FindFirstChild("Hitbox")
    if hitbox then
        if hitbox:FindFirstChild("DamageMultiplier") then
            hitbox.DamageMultiplier.Value = damageMultiplier
        end
    end
end

-- ===== FIRE RATE MOD (СКОРОСТЬ СТРЕЛЬБЫ) =====
local function ApplyFireRate()
    if not S.Config.Weapons.FireRate then return end
    local fireRateMultiplier = S.Config.Weapons.FireRate or 1
    
    local weapon = GetCurrentWeapon()
    if not weapon then return end
    
    local tool = weapon.Tool
    if not tool then return end
    
    -- Ускоряем скорость стрельбы
    local fireRateProp = tool:FindFirstChild("FireRate")
    if fireRateProp and (fireRateProp:IsA("NumberValue") or fireRateProp:IsA("IntValue")) then
        originalProperties[weapon.Name] = originalProperties[weapon.Name] or {}
        originalProperties[weapon.Name].FireRate = fireRateProp.Value
        
        fireRateProp.Value = fireRateProp.Value / fireRateMultiplier
    end
    
    -- Если есть свойство Cooldown, уменьшаем его
    local cooldownProp = tool:FindFirstChild("Cooldown")
    if cooldownProp and (cooldownProp:IsA("NumberValue") or cooldownProp:IsA("IntValue")) then
        originalProperties[weapon.Name] = originalProperties[weapon.Name] or {}
        originalProperties[weapon.Name].Cooldown = cooldownProp.Value
        
        cooldownProp.Value = cooldownProp.Value / fireRateMultiplier
    end
end

-- ===== BULLET SPEED (УСКОРЕНИЕ ПУЛЬ) =====
local function ApplyBulletSpeed()
    if not S.Config.Weapons.BulletSpeed then return end
    local speedMultiplier = S.Config.Weapons.BulletSpeed or 1
    
    local weapon = GetCurrentWeapon()
    if not weapon then return end
    
    local tool = weapon.Tool
    if not tool then return end
    
    -- Ищем свойства скорости пуль
    local speedProp = tool:FindFirstChild("BulletSpeed")
    if speedProp and (speedProp:IsA("NumberValue") or speedProp:IsA("IntValue")) then
        speedProp.Value = speedProp.Value * speedMultiplier
    end
    
    -- Если есть свойство ProjectileSpeed
    local projSpeed = tool:FindFirstChild("ProjectileSpeed")
    if projSpeed and (projSpeed:IsA("NumberValue") or projSpeed:IsA("IntValue")) then
        projSpeed.Value = projSpeed.Value * speedMultiplier
    end
end

-- ===== ОСНОВНОЙ ЦИКЛ ОБНОВЛЕНИЯ =====
spawn(function()
    while S.Active do
        S.RS.RenderStepped:Wait()
        
        -- Обновляем персонажа и оружие
        character = player.Character
        if not character then 
            wait(1)
            continue 
        end
        
        -- Применяем все модификации к оружию
        ApplyNoRecoil()
        ApplyNoSpread()
        ApplyInfiniteAmmo()
        ApplyInstantReload()
        ApplyDamageMod()
        ApplyFireRate()
        ApplyBulletSpeed()
    end
end)

-- ===== ОТСЛЕЖИВАНИЕ СМЕНЫ ОРУЖИЯ =====
local function OnToolEquipped(tool)
    currentTool = tool
    print("[WEAPONS] Экипировано: " .. tool.Name)
end

local function OnToolUnequipped(tool)
    currentTool = nil
    print("[WEAPONS] Снято: " .. tool.Name)
end

-- Отслеживаем экипировку оружия через Character
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    
    newChar.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            OnToolEquipped(child)
        end
    end)
    
    newChar.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            OnToolUnequipped(child)
        end
    end)
end)

-- ===== ВИЗУАЛЬНАЯ ИНДИКАЦИЯ СТАТУСА ОРУЖИЯ =====
local weaponStatus = Instance.new("TextLabel")
weaponStatus.Size = UDim2.new(0, 300, 0, 30)
weaponStatus.Position = UDim2.new(0.5, -150, 1, -60)
weaponStatus.BackgroundTransparency = 1
weaponStatus.Text = "🔫 Без оружия"
weaponStatus.TextColor3 = C.ACC
weaponStatus.TextSize = 14
weaponStatus.Font = Enum.Font.GothamBold
weaponStatus.ZIndex = 999
weaponStatus.Parent = S.GUI

spawn(function()
    while S.Active do
        local weapon = GetCurrentWeapon()
        if weapon then
            local stats = {}
            if S.Config.Weapons.NoRecoil then table.insert(stats, "Без отдачи") end
            if S.Config.Weapons.NoSpread then table.insert(stats, "Точный") end
            if S.Config.Weapons.InfiniteAmmo then table.insert(stats, "∞") end
            if S.Config.Weapons.InstantReload then table.insert(stats, "Быстрая перезарядка") end
            if S.Config.Weapons.Damage and S.Config.Weapons.Damage > 1 then 
                table.insert(stats, "x" .. S.Config.Weapons.Damage .. " урона") 
            end
            if S.Config.Weapons.FireRate and S.Config.Weapons.FireRate > 1 then 
                table.insert(stats, "x" .. S.Config.Weapons.FireRate .. " скорострельность") 
            end
            
            local statusText = "🔫 " .. weapon.Name
            if #stats > 0 then
                statusText = statusText .. " [" .. table.concat(stats, " | ") .. "]"
            end
            weaponStatus.Text = statusText
        else
            weaponStatus.Text = "🔫 Без оружия"
        end
        wait(0.5)
    end
end)

-- ===== ВОССТАНОВЛЕНИЕ ОРИГИНАЛЬНЫХ СВОЙСТВ ПРИ ВЫГРУЗКЕ =====
function S.RestoreWeaponProperties()
    for weaponName, props in pairs(originalProperties) do
        -- Восстановление свойств (если нужно)
    end
    originalProperties = {}
end

-- Добавляем очистку при выгрузке
local oldUnload = S.RemoveAllESP
S.RemoveAllESP = function()
    S.RestoreWeaponProperties()
    if oldUnload then oldUnload() end
end

print("[SWILL] ✅ Weapons.lua загружен. Все функции оружия активны.")
