-- Полный скрипт читов в стиле CS:GO с Silent Aim и круглым FOV

-- Безопасное получение сервисов
local function GetService(name)
    local success, service = pcall(function() return game:GetService(name) end)
    return success and service or error("Не удалось получить сервис: "..name)
end

local UIS = GetService("UserInputService")
local Players = GetService("Players")
local RS = GetService("RunService")
local CG = GetService("CoreGui")
local WS = GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Настройки читов
local Settings = {
    MenuKey = Enum.KeyCode.Insert,
    SilentAim = {
        Enabled = false,
        FOV = 60,
        HitChance = 100,
        TargetPart = "Head",
        VisibleCheck = true
    },
    Visuals = {
        FOVCircle = true,
        CircleColor = Color3.fromRGB(255, 255, 255),
        CircleThickness = 1
    }
}

-- Кэш объектов
local DrawingCache = {}
local Connections = {}

-- Функции для рисования
local function CreateDrawing(type, props)
    local drawing = Drawing.new(type)
    for prop, value in pairs(props) do
        drawing[prop] = value
    end
    table.insert(DrawingCache, drawing)
    return drawing
end

-- Создание FOV круга
local FOVCircle = CreateDrawing("Circle", {
    Visible = Settings.Visuals.FOVCircle,
    Color = Settings.Visuals.CircleColor,
    Thickness = Settings.Visuals.CircleThickness,
    Filled = false
})

-- Обновление позиции FOV круга
local function UpdateFOVCircle()
    if not FOVCircle then return end
    local mousePos = UIS:GetMouseLocation()
    FOVCircle.Position = mousePos
    FOVCircle.Radius = Settings.SilentAim.FOV
    FOVCircle.Visible = Settings.Visuals.FOVCircle and Settings.SilentAim.Enabled
end

-- Silent Aim логика
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

        -- Проверка на видимость
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

-- Хук для стрельбы
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    
    if Settings.SilentAim.Enabled and method == "FindPartOnRay" then
        local targetData = GetClosestTarget()
        if targetData then
            local origin = self == WS and (...) or self
            local direction = (targetData.Part.Position - origin).Unit
            return oldNamecall(self, origin, direction * 1000, ...)
        end
    end
    
    return oldNamecall(self, ...)
end)

-- GUI меню в стиле CS:GO
local Menu = {
    Open = false,
    Main = Instance.new("ScreenGui"),
    Tabs = {}
}

Menu.Main.Name = "CSGOCheatMenu"
Menu.Main.Parent = CG

local function CreateTab(name)
    local tab = {
        Frame = Instance.new("Frame"),
        Name = name,
        Elements = {}
    }
    
    tab.Frame.Size = UDim2.new(0.2, 0, 0.5, 0)
    tab.Frame.Position = UDim2.new(0.01, 0, 0.25, 0)
    tab.Frame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    tab.Frame.BorderSizePixel = 0
    tab.Frame.Visible = false
    tab.Frame.Parent = Menu.Main
    
    local title = Instance.new("TextLabel")
    title.Text = name
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.Parent = tab.Frame
    
    table.insert(Menu.Tabs, tab)
    return tab
end

local function CreateToggle(tab, text, setting, callback)
    local toggle = Instance.new("TextButton")
    toggle.Text = text .. ": " .. (Settings[setting[1]][setting[2]] and "ON" or "OFF")
    toggle.Size = UDim2.new(0.9, 0, 0.08, 0)
    toggle.Position = UDim2.new(0.05, 0, 0.15 + (#tab.Elements * 0.09), 0)
    toggle.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Parent = tab.Frame
    
    toggle.MouseButton1Click:Connect(function()
        Settings[setting[1]][setting[2]] = not Settings[setting[1]][setting[2]]
        toggle.Text = text .. ": " .. (Settings[setting[1]][setting[2]] and "ON" or "OFF")
        if callback then callback() end
    end)
    
    table.insert(tab.Elements, toggle)
end

local function CreateSlider(tab, text, setting, min, max, callback)
    local slider = {
        Frame = Instance.new("Frame"),
        Value = Settings[setting[1]][setting[2]]
    }
    
    slider.Frame.Size = UDim2.new(0.9, 0, 0.1, 0)
    slider.Frame.Position = UDim2.new(0.05, 0, 0.15 + (#tab.Elements * 0.11), 0)
    slider.Frame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
    slider.Frame.Parent = tab.Frame
    
    local label = Instance.new("TextLabel")
    label.Text = text .. ": " .. slider.Value
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Parent = slider.Frame
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0.3, 0)
    track.Position = UDim2.new(0, 0, 0.6, 0)
    track.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    track.Parent = slider.Frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((slider.Value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.Parent = track
    
    local dragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            percent = math.clamp(percent, 0, 1)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            slider.Value = math.floor(min + (max - min) * percent)
            label.Text = text .. ": " .. slider.Value
            Settings[setting[1]][setting[2]] = slider.Value
            if callback then callback(slider.Value) end
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    table.insert(tab.Elements, slider)
end

-- Создание вкладок и элементов
local aimTab = CreateTab("Aimbot")
CreateToggle(aimTab, "Silent Aim", {"SilentAim", "Enabled"}, UpdateFOVCircle)
CreateSlider(aimTab, "FOV", {"SilentAim", "FOV"}, 10, 200, UpdateFOVCircle)
CreateSlider(aimTab, "Hit Chance", {"SilentAim", "HitChance"}, 0, 100)
CreateToggle(aimTab, "Visible Check", {"SilentAim", "VisibleCheck"})

local visualsTab = CreateTab("Visuals")
CreateToggle(visualsTab, "FOV Circle", {"Visuals", "FOVCircle"}, UpdateFOVCircle)

-- Управление меню
Menu.Tabs[1].Frame.Visible = true

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.MenuKey then
        Menu.Open = not Menu.Open
        Menu.Main.Enabled = Menu.Open
    end
end)

-- Основной цикл
RS.RenderStepped:Connect(function()
    UpdateFOVCircle()
end)

-- Очистка
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        for _, drawing in pairs(DrawingCache) do
            drawing:Remove()
        end
        Menu.Main:Destroy()
    end
end)

print("Чит успешно загружен! Нажмите "..tostring(Settings.MenuKey).." для открытия меню")
