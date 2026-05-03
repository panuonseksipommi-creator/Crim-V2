-- === Limppa Hub - Safe ESP + Plus Crosshair + Wallbang | Creator ZenLimppa ===

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Full Bright
local function FullBright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
        end
    end
end

FullBright()

local Window = Rayfield:CreateWindow({
    Name = "Limppa Hub",
    LoadingTitle = "Limppa Hub",
    LoadingSubtitle = "Creator ZenLimppa | Safe ESP + Wallbang",
    ConfigurationSaving = { Enabled = false },
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- Variables
local aimlockEnabled = false
local wallbangEnabled = false
local espEnabled = true
local fovValue = 160
local smoothness = 0.28
local aimPart = "HumanoidRootPart"

local highlights = {}
local aimlockTarget = nil

-- ESP Settings
local espFillColor = Color3.fromRGB(255, 0, 0)
local espOutlineColor = Color3.fromRGB(255, 255, 255)
local espFillTransparency = 0.4
local safeESP = true

-- Plus Crosshair
local crosshairH = Drawing.new("Line")
local crosshairV = Drawing.new("Line")

local function UpdateCrosshair()
    local center = Camera.ViewportSize / 2
    local size = 12
    crosshairH.From = Vector2.new(center.X - size, center.Y)
    crosshairH.To = Vector2.new(center.X + size, center.Y)
    crosshairV.From = Vector2.new(center.X, center.Y - size)
    crosshairV.To = Vector2.new(center.X, center.Y + size)
    crosshairH.Color = Color3.fromRGB(255, 255, 255)
    crosshairV.Color = Color3.fromRGB(255, 255, 255)
    crosshairH.Thickness = 1.5
    crosshairV.Thickness = 1.5
end

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.NumSides = 64
fovCircle.Filled = false
fovCircle.Transparency = 0.7
fovCircle.Visible = true

local function IsEnemy(plr)
    if not safeESP then return true end
    if plr.Team == LocalPlayer.Team then return false end
    if plr.Name:lower():find("admin") or plr.Name:lower():find("mod") then return false end
    return true
end

-- Fixed ESP
local function UpdateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            if highlights[plr] then highlights[plr]:Destroy() highlights[plr] = nil end
            continue
        end

        if not IsEnemy(plr) then
            if highlights[plr] then highlights[plr].Parent = nil end
            continue
        end

        if not highlights[plr] then
            local hl = Instance.new("Highlight")
            hl.Adornee = char
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlights[plr] = hl
        end

        local hl = highlights[plr]
        hl.FillColor = espFillColor
        hl.OutlineColor = espOutlineColor
        hl.FillTransparency = espFillTransparency
        hl.Parent = espEnabled and char or nil
    end
end

local function IsVisible(targetChar)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tRoot = targetChar:FindFirstChild(aimPart) or targetChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(myRoot.Position, (tRoot.Position - myRoot.Position).Unit * 1500, params)
    return not result or result.Instance:IsDescendantOf(targetChar)
end

local function GetClosestPlayer()
    local closest, minDist = nil, fovValue
    local center = Camera.ViewportSize / 2

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then continue end
        if not IsEnemy(plr) then continue end

        local part = plr.Character:FindFirstChild(aimPart) or plr.Character:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if onScreen then
            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            if dist < minDist and IsVisible(plr.Character) then
                minDist = dist
                closest = plr
            end
        end
    end
    return closest
end

-- MB2 Hold
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimlockEnabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimlockEnabled = false
        aimlockTarget = nil
    end
end)

-- UI
CombatTab:CreateToggle({Name = "Aimlock (Hold MB2)", CurrentValue = false, Callback = function(v) aimlockEnabled = v end})
CombatTab:CreateDropdown({Name = "Aim Part", Options = {"Head","HumanoidRootPart","UpperTorso"}, CurrentOption = {"HumanoidRootPart"}, Callback = function(o) aimPart = o[1] end})
CombatTab:CreateSlider({Name = "FOV", Range = {60,500}, Increment = 10, CurrentValue = 160, Callback = function(v) fovValue = v end})
CombatTab:CreateSlider({Name = "Smoothing", Range = {0.1,0.8}, Increment = 0.05, CurrentValue = 0.28, Callback = function(v) smoothness = v end})
CombatTab:CreateToggle({Name = "Wallbang (Silent Aim)", CurrentValue = false, Callback = function(v) wallbangEnabled = v end})

VisualsTab:CreateToggle({Name = "ESP Enabled", CurrentValue = true, Callback = function(v) espEnabled = v end})
VisualsTab:CreateToggle({Name = "Safe ESP", CurrentValue = true, Callback = function(v) safeESP = v end})
VisualsTab:CreateColorPicker({Name = "ESP Fill Color", Color = Color3.fromRGB(255,0,0), Callback = function(c) espFillColor = c end})
VisualsTab:CreateSlider({Name = "ESP Transparency", Range = {0,1}, Increment = 0.05, CurrentValue = 0.4, Callback = function(v) espFillTransparency = v end})

VisualsTab:CreateToggle({Name = "Crosshair", CurrentValue = true, Callback = function(v)
    crosshairH.Visible = v
    crosshairV.Visible = v
end})

VisualsTab:CreateToggle({Name = "FOV Circle", CurrentValue = true, Callback = function(v) fovCircle.Visible = v end})
VisualsTab:CreateSlider({Name = "ClockTime", Range = {0,24}, Increment = 0.5, CurrentValue = 14, Callback = function(v) Lighting.ClockTime = v end})

-- Main Loop
RunService.RenderStepped:Connect(function()
    UpdateESP()
    UpdateCrosshair()
    fovCircle.Position = Camera.ViewportSize / 2
    fovCircle.Radius = fovValue

    if aimlockEnabled then
        if not aimlockTarget or not aimlockTarget.Character or not IsVisible(aimlockTarget.Character) then
            aimlockTarget = GetClosestPlayer()
        end

        if aimlockTarget and aimlockTarget.Character then
            local targetPart = aimlockTarget.Character:FindFirstChild(aimPart) or aimlockTarget.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local current = Camera.CFrame
                local target = CFrame.lookAt(current.Position, targetPart.Position)
                Camera.CFrame = current:Lerp(target, smoothness)
            end
        end
    else
        aimlockTarget = nil
    end
end)

Rayfield:Notify({Title = "Loaded Successfully", Content = "Limppa Hub | Creator ZenLimppa", Duration = 6})
