-- Исправленный полный скрипт

-- Безопасное получение сервисов
local function GetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or nil
end

local UserInputService = GetService("UserInputService")
local Players = GetService("Players")
local RunService = GetService("RunService")

if not (UserInputService and Players and RunService) then
    print("Ошибка: Не удалось получить необходимые сервисы")
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
    SilentAimFOV = 50,
    MenuVisible = true
}

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = GetService("CoreGui") or game:GetService("CoreGui")
ScreenGui.IgnoreGuiInset = true

local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 200, 0, 300)
MenuFrame.Position = UDim2.new(0, 10, 0, 10)
MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = Settings.MenuVisible
MenuFrame.Parent = ScreenGui

-- Функции создания элементов GUI
local function CreateLabel(text, position, parent)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 180, 0, 30)
    Label.Position = position
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSans
    Label.Parent = parent
end

local function CreateButton(text, position, callback, parent)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 180, 0, 30)
    Button.Position = position
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = text
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 14
    Button.Font = Enum.Font.SourceSans
    Button.Parent = parent
    Button.MouseButton1Click:Connect(callback)
end

local function CreateSlider(text, position, min, max, callback, parent)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0, 180, 0, 50)
    SliderFrame.Position = position
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Parent = SliderFrame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 10)
    Track.Position = UDim2.new(0, 0, 0, 30)
    Track.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Track.Parent = SliderFrame

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0.5, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    Fill.Parent = Track

    local dragging = false
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
            percent = math.clamp(percent, 0, 1)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            callback(math.floor(min + (max - min) * percent))
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Инициализация меню
CreateLabel("Cheat Menu", UDim2.new(0, 10, 0, 10), MenuFrame)

CreateButton("ESP: OFF", UDim2.new(0, 10, 0, 50), function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    MenuFrame:FindFirstChildWhichIsA("TextButton").Text = "ESP: " .. (Settings.ESPEnabled and "ON" or "OFF")
end, MenuFrame)

CreateButton("Silent Aim: OFF", UDim2.new(0, 10, 0, 90), function()
    Settings.SilentAimEnabled = not Settings.SilentAimEnabled
    MenuFrame:FindFirstChildWhichIsA("TextButton", true).Text = "Silent Aim: " .. (Settings.SilentAimEnabled and "ON" or "OFF")
end, MenuFrame)

CreateSlider("FOV: 50", UDim2.new(0, 10, 0, 130), 10, 100, function(value)
    Settings.SilentAimFOV = value
    MenuFrame:FindFirstChildWhichIsA("TextLabel", true).Text = "FOV: " .. value
end, MenuFrame)

-- Управление видимостью меню
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        Settings.MenuVisible = not Settings.MenuVisible
        MenuFrame.Visible = Settings.MenuVisible
    end
end)

-- Система ESP
local Highlights = {}

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        if Settings.ESPEnabled and player.Character then
            if not Highlights[player] then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = player.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.Parent = player.Character
                Highlights[player] = highlight
            end
        else
            if Highlights[player] then
                Highlights[player]:Destroy()
                Highlights[player] = nil
            end
        end
    end
end

Players.PlayerAdded:Connect(UpdateESP)
Players.PlayerRemoving:Connect(UpdateESP)
LocalPlayer.CharacterAdded:Connect(UpdateESP)

-- Система Silent Aim
RunService.RenderStepped:Connect(function()
    if not Settings.SilentAimEnabled then return end
    
    local camera = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    
    local closest = {
        Player = nil,
        Distance = Settings.SilentAimFOV
    }

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not (player.Character and player.Character:FindFirstChild("Head")) then continue end

        local headPos = player.Character.Head.Position
        local screenPos, visible = camera:WorldToViewportPoint(headPos)
        
        if visible then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if distance < closest.Distance then
                closest.Player = player
                closest.Distance = distance
            end
        end
    end

    if closest.Player then
        -- Здесь можно добавить логику прицеливания
        print("[AIM] Target: " .. closest.Player.Name)
    end
end)

-- Первоначальное обновление
UpdateESP()
print("Скрипт успешно запущен!")
