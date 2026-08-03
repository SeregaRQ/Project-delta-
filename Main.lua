-- ============================================
-- 🔥 SWILL | MAIN LOADER (ЗАГРУЗКА МОДУЛЕЙ)
-- ============================================
print("[SWILL] Загрузка Main.lua...")

-- Очистка старой сессии
if _G.SWILL then
    if _G.SWILL.GUI then
        _G.SWILL.GUI:Destroy()
    end
    _G.SWILL = nil
end

_G.SWILL = { Active = true }

-- Список модулей
local modules = {
    "Core",
    "FOV",
    "ESP",
    "Aimbot",
    "Movement",
    "Weapons",
    "World",
    "Menu"
}

-- Загрузка модулей с GitHub
for _, module in pairs(modules) do
    local url = "https://raw.githubusercontent.com/SeregaRQ/Project-delta-/refs/heads/main/" .. module .. ".lua"
    local success, code = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and code then
        local fn, err = loadstring(code)
        if fn then
            pcall(fn)
            print("[SWILL] ✅ " .. module .. " загружен")
        else
            warn("[SWILL] ❌ Ошибка " .. module .. ": " .. tostring(err))
        end
    else
        warn("[SWILL] ❌ Не удалось загрузить " .. module)
    end
end

print("[SWILL] ✅ Система готова!")
