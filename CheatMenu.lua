-- NeonHub CS2 Cheat Menu
-- Автор: YourName
-- Версия: 1.0

-- Сервисы
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local WS = game:GetService("Workspace")
local TS = game:GetService("TweenService")

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Настройки
local Settings = {
    MenuKey = Enum.KeyCode.RightControl,
    MenuVisible = false,
    
    SilentAim = {
        Enabled = false,
        FOV = 60,
        HitChance = 100,
        TargetPart = "Head",
        VisibleCheck = true
    },
    
    Visuals = {
        ESP = false,
        BoxESP = true,
        NameESP = true,
        HealthESP = true,
        FOVCircle = true,
        CircleColor = Color3.fromRGB(0, 255, 255),
        CircleThickness = 2
    },
    
    Misc = {
        HitboxExpansion = false,
        HitboxMultiplier = 1.2
    }
}

-- Кэш
local ESPCache = {}
local Drawings = {}
local OriginalSizes = {}

-- FOV Circle
local function CreateFOVCircle()
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Color = Settings.Visuals.CircleColor
    circle.Thickness = Settings.Visuals.CircleThickness
    circle.Filled = false
    circle.Transparency = 1
    Drawings.FOVCircle = circle
end

local function UpdateFOVCircle()
    if not Drawings.FOVCircle then return end
    
    local mousePos = UIS:GetMouseLocation()
    Drawings.FOVCircle.Position = mousePos
    Drawings.FOVCircle.Radius = Settings.SilentAim.FOV
    Drawings.FOVCircle.Visible = Settings.Visuals.FOVCircle and Settings.SilentAim.Enabled
    Drawings.FOVCircle.Color = Settings.Visuals.CircleColor
    Drawings.FOVCircle.Thickness = Settings.Visuals.CircleThickness
end

-- ESP
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    ESPCache[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Text")
    }
    
    local esp = ESPCache[player]
    
    -- Box ESP
    esp.Box.Visible = false
    esp.Box.Color = Color3.fromRGB(0, 255, 0)
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    
    -- Name ESP
    esp.Name.Visible = false
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = 13
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Text = player.Name
    
    -- Health ESP
    esp.Health.Visible = false
    esp.Health.Color = Color3.fromRGB(255, 255, 255)
    esp.Health.Size = 13
    esp.Health.Center = true
    esp.Health.Outline = true
end

local function UpdateESP()
    if not Settings.Visuals.ESP then return end
    
    for player, esp in pairs(ESPCache) do
        if not player or not player.Character then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
            goto continue
        end
        
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        local head = player.Character:FindFirstChild("Head")
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        
        if not (rootPart and head and humanoid) then goto continue end
        
        local rootPos, rootVis = WS.CurrentCamera:WorldToViewportPoint(rootPart.Position)
        local headPos = WS.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        
        if rootVis then
            local height = (headPos.Y - rootPos.Y) * 2
            local width = height * 0.6
            
            -- Box ESP
            esp.Box.Visible = Settings.Visuals.BoxESP
            esp.Box.Size = Vector2.new(width, height)
            esp.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
            
            -- Name ESP
            esp.Name.Visible = Settings.Visuals.NameESP
            esp.Name.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 15)
            
            -- Health ESP
            esp.Health.Visible = Settings.Visuals.HealthESP
            esp.Health.Position = Vector2.new(rootPos.X, rootPos.Y + height/2 + 5)
            esp.Health.Text = "HP: "..math.floor(humanoid.Health)
            esp.Health.Color = Color3.fromRGB(
                255 - (humanoid.Health / humanoid.MaxHealth) * 255,
                (humanoid.Health / humanoid.MaxHealth) * 255,
                0
            )
        else
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
        end
        
        ::continue::
    end
end

-- Silent Aim
local function GetClosestTarget()
    if not Settings.SilentAim.Enabled then return nil end
    if math.random(1, 100) > Settings.SilentAim.HitChance then return nil end
    
    local camera = WS.CurrentCamera
    local mousePos = UIS:GetMouseLocation()
    local closest = {Player = nil, Distance = Settings.SilentAim.FOV}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local targetPart = player.Character:FindFirstChild(Settings.SilentAim.TargetPart)
        if not targetPart then continue end
        
        -- Visible Check
        if Settings.SilentAim.VisibleCheck then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            
            local raycastResult = WS:Raycast(
                camera.CFrame.Position,
                (targetPart.Position - camera.CFrame.Position).Unit * 1000,
                raycastParams
            )
            
            if raycastResult and raycastResult.Instance ~= targetPart then
                continue
            end
        end
        
        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if distance < closest.Distance then
                closest.Player = player
                closest.Distance = distance
                closest.Part = targetPart
            end
        end
    end
    
    return closest.Player and closest
end

-- Hitbox Expansion
local function ApplyHitboxExpansion()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if Settings.Misc.HitboxExpansion then
                    if not OriginalSizes[part] then
                        OriginalSizes[part] = part.Size
                    end
                    part.Size = OriginalSizes[part] * Settings.Misc.HitboxMultiplier
                    part.Transparency = 0.5
                elseif OriginalSizes[part] then
                    part.Size = OriginalSizes[part]
                    part.Transparency = 0
                end
            end
        end
    end
end

-- Меню
local function CreateMenu()
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "NeonHub"
    MainGui.Parent = CG
    MainGui.ResetOnSpawn = false

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = Settings.MenuVisible
    MainFrame.Parent = MainGui

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Header.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = "NEON HUB"
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(0, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = Header

    -- Tabs
    local Tabs = Instance.new("Frame")
    Tabs.Size = UDim2.new(1, 0, 0, 40)
    Tabs.Position = UDim2.new(0, 0, 0, 40)
    Tabs.BackgroundTransparency = 1
    Tabs.Parent = MainFrame

    -- Content
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -100)
    Content.Position = UDim2.new(0, 10, 0, 90)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    -- Toggle Function
    local function CreateToggle(name, pos, setting, callback)
        local Toggle = Instance.new("TextButton")
        Toggle.Text = name .. ": " .. (Settings[setting[1]][setting[2]] and "ON" or "OFF")
        Toggle.Size = UDim2.new(1, 0, 0, 30)
        Toggle.Position = pos
        Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.Font = Enum.Font.Gotham
        Toggle.TextSize = 14
        Toggle.Parent = Content
        
        Toggle.MouseButton1Click:Connect(function()
            Settings[setting[1]][setting[2]] = not Settings[setting[1]][setting[2]]
            Toggle.Text = name .. ": " .. (Settings[setting[1]][setting[2]] and "ON" or "OFF")
            if callback then callback() end
        end)
    end

    -- Slider Function
    local function CreateSlider(name, pos, setting, min, max, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
        SliderFrame.Position = pos
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = Content
        
        local Label = Instance.new("TextLabel")
        Label.Text = name .. ": " .. Settings[setting[1]][setting[2]]
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.Parent = SliderFrame
        
        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, 0, 0, 5)
        Track.Position = UDim2.new(0, 0, 0, 30)
        Track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        Track.Parent = SliderFrame
        
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((Settings[setting[1]][setting[2]] - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        Fill.Parent = Track
        
        local dragging = false
        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
                percent = math.clamp(percent, 0, 1)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                local value = math.floor(min + (max - min) * percent)
                Settings[setting[1]][setting[2]] = value
                Label.Text = name .. ": " .. value
                if callback then callback(value) end
            end
        end)
        
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- Aimbot Tab
    CreateToggle("Silent Aim", UDim2.new(0, 0, 0, 0), {"SilentAim", "Enabled"}, UpdateFOVCircle)
    CreateSlider("FOV Size", UDim2.new(0, 0, 0, 40), {"SilentAim", "FOV"}, 10, 200, UpdateFOVCircle)
    CreateSlider("Hit Chance", UDim2.new(0, 0, 0, 100), {"SilentAim", "HitChance"}, 0, 100)
    CreateToggle("Visible Check", UDim2.new(0, 0, 0, 160), {"SilentAim", "VisibleCheck"})

    -- Visuals Tab
    CreateToggle("ESP", UDim2.new(0, 0, 0, 0), {"Visuals", "ESP"}, UpdateESP)
    CreateToggle("Box ESP", UDim2.new(0, 0, 0, 40), {"Visuals", "BoxESP"}, UpdateESP)
    CreateToggle("Name ESP", UDim2.new(0, 0, 0, 80), {"Visuals", "NameESP"}, UpdateESP)
    CreateToggle("Health ESP", UDim2.new(0, 0, 0, 120), {"Visuals", "HealthESP"}, UpdateESP)
    CreateToggle("FOV Circle", UDim2.new(0, 0, 0, 160), {"Visuals", "FOVCircle"}, UpdateFOVCircle)
    CreateSlider("Circle Thickness", UDim2.new(0, 0, 0, 200), {"Visuals", "CircleThickness"}, 1, 5, UpdateFOVCircle)

    -- Misc Tab
    CreateToggle("Hitbox Expansion", UDim2.new(0, 0, 0, 0), {"Misc", "HitboxExpansion"}, ApplyHitboxExpansion)
    CreateSlider("Hitbox Multiplier", UDim2.new(0, 0, 0, 40), {"Misc", "HitboxMultiplier"}, 1, 3, ApplyHitboxExpansion)

    -- Toggle Menu
    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Settings.MenuKey then
            Settings.MenuVisible = not Settings.MenuVisible
            MainFrame.Visible = Settings.MenuVisible
        end
    end)

    return MainGui
end

-- Инициализация
CreateFOVCircle()
CreateMenu()

-- Обработка игроков
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(player)
    if ESPCache[player] then
        for _, drawing in pairs(ESPCache[player]) do
            drawing:Remove()
        end
        ESPCache[player] = nil
    end
end)

-- Main Loop
RS.RenderStepped:Connect(function()
    UpdateFOVCircle()
    UpdateESP()
    ApplyHitboxExpansion()
end)

print("NeonHub loaded! Press RightControl to open menu")
