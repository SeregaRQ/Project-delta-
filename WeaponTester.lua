-- WeaponTester.lua
-- Образовательный тестер: задаёт глобальные множители для оружия

local WeaponTester = {}
local core

function WeaponTester.Init(_core)
    core = _core
    WeaponTester.Config = {
        Recoil = 0,
        Spread = 0,
        InfiniteAmmo = false,
        DamageMult = 1,
        FireRateMult = 1,
    }
    -- Expose APIs for local weapon scripts to read
    _G.DeltaWeaponTest = _G.DeltaWeaponTest or {}
    _G.DeltaWeaponTest.Config = WeaponTester.Config
end

function WeaponTester.Start()
    -- no-op; scripts in weapons can check _G.DeltaWeaponTest.Config
end

function WeaponTester.Stop()
    -- reset to defaults
    if _G.DeltaWeaponTest then
        _G.DeltaWeaponTest.Config.Recoil = 0
        _G.DeltaWeaponTest.Config.Spread = 0
        _G.DeltaWeaponTest.Config.InfiniteAmmo = false
        _G.DeltaWeaponTest.Config.DamageMult = 1
        _G.DeltaWeaponTest.Config.FireRateMult = 1
    end
end

return WeaponTester
