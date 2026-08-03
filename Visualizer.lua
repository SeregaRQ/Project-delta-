-- Visualizer.lua
-- Отображает отладочную информацию над игроками и простые визуалы

local Visualizer = {}
local core

function Visualizer.Init(_core)
    core = _core
    core.Visuals = core.Visuals or {}
end

local function makeBillboard(part)
    if not part then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "DBG_BB"
    bb.Adornee = part
    bb.Size = UDim2.new(0,200,0,60)
    bb.AlwaysOnTop = true
    bb.Parent = core.ScreenGui

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Text = ""
    txt.Font = core.Config.Visual.Font
    txt.TextSize = 16
    txt.TextColor3 = core.Config.Visual.NameColor
    txt.Parent = bb

    return bb, txt
end

function Visualizer.Start()
    if not core then return end
    Visualizer._conn = core.Services.RunService:BindToRenderStep("DEBUG_VIS", Enum.RenderPriority.Camera.Value + 1, function()
        local players = core.Services.Players:GetPlayers()
        local localPlr = core.Services.Players.LocalPlayer
        local camera = workspace.CurrentCamera
        for _, plr in ipairs(players) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                local dist = (hrp.Position - (localPlr.Character and localPlr.Character:FindFirstChild("HumanoidRootPart") and localPlr.Character.HumanoidRootPart.Position or camera.CFrame.Position)).Magnitude
                local name = plr.Name
                -- make or reuse billboard
                local exists = hrp:FindFirstChild("_DBG_BB_REF")
                if not exists then
                    local bb, txt = makeBillboard(hrp)
                    local tag = Instance.new("ObjectValue")
                    tag.Name = "_DBG_BB_REF"
                    tag.Value = bb
                    tag.Parent = hrp
                    hrp:SetAttribute("_dbg_textlabel", tostring(txt:GetDebugId()))
                else
                    local bb = exists.Value
                    if bb and bb:FindFirstChildOfClass("TextLabel") then
                        local txt = bb:FindFirstChildOfClass("TextLabel")
                        txt.Text = string.format("%s\n%.1fm", name, dist)
                    end
                end
                -- Highlight
                local h = plr.Character:FindFirstChild("_DBG_HL")
                if not h then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Name = "_DBG_HL"
                    Highlight.Adornee = plr.Character
                    Highlight.FillTransparency = 0.6
                    Highlight.Parent = hrp
                end
            end
        end
    end)
end

function Visualizer.Stop()
    pcall(function()
        if Visualizer._conn then
            core.Services.RunService:UnbindFromRenderStep("DEBUG_VIS")
            Visualizer._conn = nil
        end
        -- cleanup created billboard/objectvalues/highlights
        for _, plr in ipairs(core.Services.Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                for _, c in ipairs(hrp:GetChildren()) do
                    if c.Name == "_DBG_BB_REF" or c.Name == "_DBG_HL" then
                        pcall(function() c:Destroy() end)
                    end
                end
                -- also find in parts
                for _, part in ipairs(plr.Character:GetDescendants()) do
                    if part:IsA("Highlight") or part.Name == "_DBG_HL" then
                        pcall(function() part:Destroy() end)
                    end
                end
            end
        end
    end)
end

return Visualizer
