local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local WS = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = WS.CurrentCamera

-- Настройки читов
local Settings = {
    MenuKey = Enum.KeyCode.RightControl,
    MenuVisible = false,
    MenuMinimized = false,
    
    SilentAim = {
        Enabled = false,
        FOV = 60,
        HitChance = 100,
        TargetPart = "Head",
        VisibleCheck = true
    },
    
    Visuals = {
        FOVCircle = true,
        ESP = false,
        CircleColor = Color3.fromRGB(0, 255, 255),
        CircleThickness = 1
    },
    
    FOVAim = {
        Enabled = false,
        TargetPart = "Head",
        Smoothness = 0 -- Мгновенное наведение
    }
}

-- Создание меню в стиле CS2
local function CreateCS2Menu()
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "CS2CheatMenu"
    MainGui.Parent = CG
    MainGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = Settings.MenuVisible
    MainFrame.Parent = MainGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
    })
    UIGradient.Rotation = 90
    UIGradient.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Text = "CS2 CHEAT MENU"
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = Header

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Text = "-"
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -35, 0.5, -15)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 18
    MinimizeButton.Parent = Header

    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 6)
    MinimizeCorner.Parent = MinimizeButton

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 40)
    TabContainer.Position = UDim2.new(0, 0, 0, 40)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -20, 1, -100)
    ContentFrame.Position = UDim2.new(0, 10, 0, 90)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame

    local Tabs = {
        {Name = "AIMBOT", Icon = "🎯"},
        {Name = "VISUALS", Icon = "👁️"},
        {Name = "MISC", Icon = "⚙️"}
    }

    local function CreateTabButton(tabData, index)
        local TabButton = Instance.new("TextButton")
        TabButton.Text = tabData.Icon .. " " .. tabData.Name
        TabButton.Size = UDim2.new(0.33, -5, 1, 0)
        TabButton.Position = UDim2.new(0.33 * (index - 1), 5, 0, 0)
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        TabButton.TextColor3 = Color3.new(1, 1, 1)
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 12
        TabButton.Parent = TabContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        return TabButton
    end

    local function CreateToggle(name, position, settingTable, settingKey)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.Position = position
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = ContentFrame

        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Text = name
        ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.TextColor3 = Color3.new(1, 1, 1)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.TextSize = 14
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Text = ""
        ToggleButton.Size = UDim2.new(0, 50, 0, 25)
        ToggleButton.Position = UDim2.new(1, -50, 0.5, -12)
        ToggleButton.BackgroundColor3 = Settings[settingTable][settingKey] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
        ToggleButton.Parent = ToggleFrame

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 12)
        ToggleCorner.Parent = ToggleButton

        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Size = UDim2.new(0, 21, 0, 21)
        ToggleIndicator.Position = Settings[settingTable][settingKey] and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        ToggleIndicator.BackgroundColor3 = Color3.new(1, 1, 1)
        ToggleIndicator.Parent = ToggleButton

        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 10)
        IndicatorCorner.Parent = ToggleIndicator

        ToggleButton.MouseButton1Click:Connect(function()
            Settings[settingTable][settingKey] = not Settings[settingTable][settingKey]
            ToggleButton.BackgroundColor3 = Settings[settingTable][settingKey] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
            
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = game:GetService("TweenService"):Create(
                ToggleIndicator,
                tweenInfo,
                {Position = Settings[settingTable][settingKey] and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}
            )
            tween:Play()
        end)

        return ToggleFrame
    end

    local function CreateSlider(name, position, settingTable, settingKey, min, max)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
        SliderFrame.Position = position
        SliderFrame.BackgroundTransparency = 1
        SliderFrame.Parent = ContentFrame

        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Text = name .. ": " .. Settings[settingTable][settingKey]
        SliderLabel.Size = UDim2.new(1, 0, 0, 20)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.TextColor3 = Color3.new(1, 1, 1)
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.TextSize = 14
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderFrame

        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, 0, 0, 5)
        Track.Position = UDim2.new(0, 0, 0, 30)
        Track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        Track.Parent = SliderFrame

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((Settings[settingTable][settingKey] - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        Fill.Parent = Track

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill

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
                Settings[settingTable][settingKey] = value
                SliderLabel.Text = name .. ": " .. value
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    local AimbotTab = Instance.new("Frame")
    AimbotTab.Size = UDim2.new(1, 0, 1, 0)
    AimbotTab.BackgroundTransparency = 1
    AimbotTab.Visible = true
    AimbotTab.Parent = ContentFrame

    CreateToggle("Silent Aim", UDim2.new(0, 0, 0, 0), "SilentAim", "Enabled")
    CreateSlider("FOV Size", UDim2.new(0, 0, 0, 40), "SilentAim", "FOV", 10, 200)
    CreateSlider("Hit Chance", UDim2.new(0, 0, 0, 100), "SilentAim", "HitChance", 0, 100)
    CreateToggle("Visible Check", UDim2.new(0, 0, 0, 160), "SilentAim", "VisibleCheck")
    CreateToggle("FOV Aim (PKM)", UDim2.new(0, 0, 0, 200), "FOVAim", "Enabled")

    local VisualsTab = Instance.new("Frame")
    VisualsTab.Size = UDim2.new(1, 0, 1, 0)
    VisualsTab.BackgroundTransparency = 1
    VisualsTab.Visible = false
    VisualsTab.Parent = ContentFrame

    CreateToggle("FOV Circle", UDim2.new(0, 0, 0, 0), "Visuals", "FOVCircle")
    CreateToggle("ESP", UDim2.new(0, 0, 0, 40), "Visuals", "ESP")

    for i, tabData in ipairs(Tabs) do
        local TabButton = CreateTabButton(tabData, i)
        TabButton.MouseButton1Click:Connect(function()
            AimbotTab.Visible = i == 1
            VisualsTab.Visible = i == 2
        end)
    end

    MinimizeButton.MouseButton1Click:Connect(function()
        Settings.MenuMinimized = not Settings.MenuMinimized
        if Settings.MenuMinimized then
            MainFrame.Size = UDim2.new(0, 350, 0, 40)
            MinimizeButton.Text = "+"
        else
            MainFrame.Size = UDim2.new(0, 350, 0, 400)
            MinimizeButton.Text = "-"
        end
    end)

    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Settings.MenuKey then
            Settings.MenuVisible = not Settings.MenuVisible
            MainFrame.Visible = Settings.MenuVisible
        end
    end)

    return MainGui
end

-- Логика Silent Aim
local function GetClosestTarget()
    if not Settings.SilentAim.Enabled then return nil end
    if math.random(1, 100) > Settings.SilentAim.HitChance then return nil end

    local mousePos = UIS:GetMouseLocation()
    local closest = {Player = nil, Distance = Settings.SilentAim.FOV}

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local targetPart = player.Character:FindFirstChild(Settings.SilentAim.TargetPart)
        if not targetPart then continue end

        if Settings.SilentAim.VisibleCheck then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            
            local raycastResult = WS:Raycast(
                Camera.CFrame.Position,
                (targetPart.Position - Camera.CFrame.Position).Unit * 1000,
                raycastParams
            )
            
            if raycastResult and not raycastResult.Instance:IsDescendantOf(player.Character) then
                continue
            end
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
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

-- FOV Aim (Мгновенное наведение при ПКМ)
local function FOVAim()
    if not Settings.FOVAim.Enabled then return end
    if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

    local closest = GetClosestTarget()
    if closest then
        local targetPos = closest.Part.Position
        local cameraCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        Camera.CFrame = cameraCFrame
    end
end

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.Visuals.FOVCircle
FOVCircle.Color = Settings.Visuals.CircleColor
FOVCircle.Thickness = Settings.Visuals.CircleThickness
FOVCircle.Filled = false
FOVCircle.Transparency = 1

local function UpdateFOVCircle()
    local mousePos = UIS:GetMouseLocation()
    FOVCircle.Position = mousePos
    FOVCircle.Radius = Settings.SilentAim.FOV
    FOVCircle.Visible = Settings.Visuals.FOVCircle and (Settings.SilentAim.Enabled or Settings.FOVAim.Enabled)
end

-- ESP
local ESPDrawings = {}

local function UpdateESP()
    if Settings.Visuals.ESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if not rootPart then continue end

                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local height = 70
                    local width = 30
                    if not ESPDrawings[player] then
                        ESPDrawings[player] = {
                            Box = Drawing.new("Square")
                        }
                        ESPDrawings[player].Box.Filled = false
                        ESPDrawings[player].Box.Thickness = 1
                        ESPDrawings[player].Box.Color = Color3.new(1, 0, 0)
                    end
                    local box = ESPDrawings[player].Box
                    box.Visible = true
                    box.Position = Vector2.new(screenPos.X - width/2, screenPos.Y - height/2)
                    box.Size = Vector2.new(width, height)
                else
                    if ESPDrawings[player] then
                        ESPDrawings[player].Box.Visible = false
                    end
                end
            else
                if ESPDrawings[player] then
                    ESPDrawings[player].Box.Visible = false
                end
            end
        end
    else
        for _, drawings in pairs(ESPDrawings) do
            drawings.Box.Visible = false
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    if ESPDrawings[player] then
        ESPDrawings[player].Box:Remove()
        ESPDrawings[player] = nil
    end
end)

-- Хук для Silent Aim
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    
    if Settings.SilentAim.Enabled and method == "Raycast" then
        local args = {...}
        local targetData = GetClosestTarget()
        if targetData then
            local origin = args[1]
            local direction = (targetData.Part.Position - origin).Unit * 1000
            return oldNamecall(self, origin, direction, args[3])
        end
    end
    
    return oldNamecall(self, ...)
end)

CreateCS2Menu()

RS.RenderStepped:Connect(function()
    UpdateFOVCircle()
    UpdateESP()
    FOVAim()
end)

print("Чит успешно загружен! Нажмите RightControl для открытия меню")
