-- Основной скрипт для меню чита
local success, UserInputService = pcall(game.GetService, game, "UserInputService")
local success2, Players = pcall(game.GetService, game, "Players")
local success3, RunService = pcall(game.GetService, game, "RunService")
local LocalPlayer = success2 and Players and Players.LocalPlayer

if not (success and success2 and success3) or not LocalPlayer then
    return
end

-- Настройки чита
local Settings = {
    ESPEnabled = false,
    SilentAimEnabled = false,
    SilentAimFOV = 50, -- Поле зрения для Silent Aim
    MenuVisible = true
}

-- Создание GUI для меню
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.IgnoreGuiInset = true

local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 200, 0, 300)
MenuFrame.Position = UDim2.new(0, 10, 0, 10)
MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuFrame.BorderSizePixel = 0
MenuFrame.Parent = ScreenGui

-- Функция для создания текста
local function CreateLabel(text, position, parent)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 180, 0, 30)
    Label.Position = position
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSans
    Label.Parent = parent
end

-- Функция для создания кнопки
local function CreateButton(text, position, callback, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 180, 0, 30)
    Button.Position = position
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.SourceSans
    Button.Parent = parent
    Button.MouseButton1Click:Connect(callback)
end

-- Функция для создания слайдера
local function CreateSlider(text, position, min, max, callback, parent)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0, 180, 0, 50)
    SliderFrame.Position = position
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 180, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSans
    Label.Parent = SliderFrame

    local Slider = Instance.new("TextButton")
    Slider.Size = UDim2.new(0, 180, 0, 10)
    Slider.Position = UDim2.new(0, 0, 0, 30)
    Slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Slider.Text = ""
    Slider.Parent = SliderFrame

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0.5, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    Fill.BorderSizePixel = 0
    Fill.Parent = Slider

    local dragging = false
    Slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    Slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local sliderX = Slider.AbsolutePosition.X
            local sliderWidth = Slider.AbsoluteSize.X
            local relative = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
            Fill.Size = UDim2.new(relative, 0, 1, 0)
            local value = min + (max - min) * relative
            callback(value)
        end
    end)
end

-- Создание элементов меню
CreateLabel("Cheat Menu", UDim2.new(0, 10, 0, 10), MenuFrame)
CreateButton("Toggle ESP: OFF", UDim2.new(0, 10, 0, 50), function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    MenuFrame:FindFirstChildWhichIsA("TextButton").Text = "Toggle ESP: " .. (Settings.ESPEnabled and "ON" or "OFF")
end, MenuFrame)

CreateButton("Toggle Silent Aim: OFF", UDim2.new(0, 10, 0, 90), function()
    Settings.SilentAimEnabled = not Settings.SilentAimEnabled
    MenuFrame:FindFirstChildWhichIsA("TextButton", true).Text = "Toggle Silent Aim: " .. (Settings.SilentAimEnabled and "ON" or "OFF")
end, MenuFrame)

CreateSlider("Silent Aim FOV: 50", UDim2.new(0, 10, 0, 130), 10, 100, function(value)
    Settings.SilentAimFOV = math.floor(value)
    MenuFrame:FindFirstChildWhichIsA("TextLabel", true).Text = "Silent Aim FOV: " .. Settings.SilentAimFOV
end, MenuFrame)

-- Скрытие/показ меню по правому Shift
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        Settings.MenuVisible = not Settings.MenuVisible
        MenuFrame.Visible = Settings.MenuVisible
    end
end)

-- Реализация ESP
local function CreateESP(player)
    if player == LocalPlayer or not Settings.ESPEnabled then return end
    local character = player.Character
    if not character then return end

    local Highlight = Instance.new("Highlight")
    Highlight.Adornee = character
    Highlight.FillColor = Color3.fromRGB(255, 0, 0)
    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0
    Highlight.Parent = character

    player.CharacterRemoving:Connect(function()
        Highlight:Destroy()
    end)
end

-- Обновление ESP для всех игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        CreateESP(player)
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function()
        CreateESP(player)
    end)
    if player.Character then
        CreateESP(player)
    end
end)

-- Реализация Silent Aim
RunService.RenderStepped:Connect(function()
    if not Settings.SilentAimEnabled then return end

    local closestPlayer = nil
    local closestDistance = Settings.SilentAimFOV
    local camera = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()

    if not camera then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("Head") then continue end
        local head = player.Character.Head
        local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end

    -- Симуляция прицеливания (без прямого управления мышью)
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        -- Логика Silent Aim: можно модифицировать оружие или камеру
        print("Silent Aim на: " .. closestPlayer.Name)
    end
end)
