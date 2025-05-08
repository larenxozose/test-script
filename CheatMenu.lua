-- Попытка безопасно получить сервисы
local success, UserInputService = pcall(game.GetService, game, "UserInputService")
if not success or not UserInputService then
    print("Ошибка: Не удалось получить UserInputService")
    return
end

local success2, Players = pcall(game.GetService, game, "Players")
if not success2 or not Players then
    print("Ошибка: Не удалось получить Players")
    return
end

local success3, RunService = pcall(game.GetService, game, "RunService")
if not success3 or not RunService then
    print("Ошибка: Не удалось получить RunService")
    return
end

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    print("Ошибка: LocalPlayer не найден")
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
local success4, CoreGui = pcall(game.GetService, game, "CoreGui")
if success4 and CoreGui then
    ScreenGui.Parent = CoreGui
else
    print("Ошибка: Не удалось получить CoreGui, GUI не будет отображаться")
    return
end
ScreenGui.IgnoreGuiInset = true

local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 200, 0, 300)
MenuFrame.Position = UDim2.new(0, 10, 0, 10)
MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuFrame.BorderSizePixel = 0
MenuFrame.Parent = ScreenGui

-- Функция для создания текста
local function CreateLabel(text, position, parent)
    if not parent then return end
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
    if not parent then return end
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
    if not parent then return end
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
    local button = MenuFrame:FindFirstChildWhichIsA("TextButton")
    if button then
        button.Text = "Toggle ESP: " .. (Settings.ESPEnabled and "ON" or "OFF")
    end
end, MenuFrame)

CreateButton("Toggle Silent Aim: OFF", UDim2.new(0, 10, 0, 90), function()
    Settings.SilentAimEnabled = not Settings.SilentAimEnabled
    local button = MenuFrame:FindFirstChildWhichIsA("TextButton", true)
    if button then
        button.Text = "Toggle Silent Aim: " .. (Settings.SilentAimEnabled and "ON" or "OFF")
    end
end, MenuFrame)

CreateSlider("Silent Aim FOV: 50", UDim2.new(0, 10, 0, 130), 10, 100, function(value)
    Settings.SilentAimFOV = math.floor(value)
    local label = MenuFrame:FindFirstChildWhichIsA("TextLabel", true)
    if label then
        label.Text = "Silent Aim FOV: " .. Settings.SilentAimFOV
    end
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
    if player.Character then
        CreateESP(player)
    end
    player.CharacterAdded:Connect(function()
        CreateESP(player)
    end)
end

-- Реализация Silent Aim
RunService.RenderStepped:Connect(function()
    if not Settings.SilentAimEnabled then return end

    local success5, workspace = pcall(game.GetService, game, "Workspace")
    if not success5 or not workspace then
        print("Ошибка: Не удалось получить Workspace")
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then
        print("Ошибка: Камера не найдена")
        return
    end

    local mousePos = UserInputService:GetMouseLocation()
    if not mousePos then
        print("Ошибка: Не удалось получить позицию мыши")
        return
    end

    local closestPlayer = nil
    local closestDistance = Settings.SilentAimFOV

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

    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        print("Silent Aim на: " .. closestPlayer.Name)
    end
end)
