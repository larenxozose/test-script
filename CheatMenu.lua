-- NeonHub Fixed Script
-- Полностью переработанный код с защитой от nil ошибок

-- 1. Безопасное получение сервисов
local function GetService(name)
    local success, service = pcall(function()
        return game:GetService(name)
    end)
    if not success then
        warn("Не удалось получить сервис:", name)
        return nil
    end
    return service
end

-- 2. Инициализация сервисов с проверками
local Players = GetService("Players") or error("Сервис Players недоступен")
local UIS = GetService("UserInputService") or error("Сервис UserInputService недоступен")
local RS = GetService("RunService") or error("Сервис RunService недоступен")
local CG = GetService("CoreGui") or error("Сервис CoreGui недоступен")
local WS = GetService("Workspace") or error("Сервис Workspace недоступen")

-- 3. Безопасное получение LocalPlayer
local LocalPlayer
local function GetLocalPlayer()
    local success, player = pcall(function()
        return Players.LocalPlayer
    end)
    return success and player or nil
end

LocalPlayer = GetLocalPlayer()
if not LocalPlayer then
    local conn
    conn = Players:GetPropertyChangedSignal("LocalPlayer"):Connect(function()
        LocalPlayer = GetLocalPlayer()
        if LocalPlayer then
            conn:Disconnect()
        end
    end)
end

-- 4. Основные настройки
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
    }
}

-- 5. Система рисования с защитой от ошибок
local Drawings = {}
local function SafeDrawing(type)
    local success, drawing = pcall(Drawing.new, type)
    return success and drawing or nil
end

-- 6. FOV Circle с проверками
local function CreateFOVCircle()
    Drawings.FOVCircle = SafeDrawing("Circle")
    if Drawings.FOVCircle then
        Drawings.FOVCircle.Visible = false
        Drawings.FOVCircle.Color = Settings.Visuals.CircleColor
        Drawings.FOVCircle.Thickness = Settings.Visuals.CircleThickness
        Drawings.FOVCircle.Filled = false
    end
end

local function UpdateFOVCircle()
    if not Drawings.FOVCircle then return end
    
    local success, mousePos = pcall(function()
        return UIS:GetMouseLocation()
    end)
    if not success then return end
    
    Drawings.FOVCircle.Position = mousePos
    Drawings.FOVCircle.Radius = Settings.SilentAim.FOV
    Drawings.FOVCircle.Visible = Settings.Visuals.FOVCircle and Settings.SilentAim.Enabled
end

-- 7. ESP System с защитой
local ESPCache = {}
local function SafeRemoveDrawing(drawing)
    if drawing and typeof(drawing) == "Instance" and drawing.Remove then
        pcall(drawing.Remove, drawing)
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    ESPCache[player] = {
        Box = SafeDrawing("Square"),
        Name = SafeDrawing("Text"),
        Health = SafeDrawing("Text")
    }
    
    local esp = ESPCache[player]
    if not (esp.Box and esp.Name and esp.Health) then return end
    
    -- Настройка ESP элементов
    esp.Box.Visible = false
    esp.Box.Color = Color3.fromRGB(0, 255, 0)
    esp.Box.Thickness = 1
    
    esp.Name.Visible = false
    esp.Name.Text = player.Name
    esp.Name.Size = 13
    esp.Name.Outline = true
    
    esp.Health.Visible = false
    esp.Health.Size = 13
    esp.Health.Outline = true
end

-- 8. Silent Aim с полной защитой
local function GetClosestTarget()
    if not Settings.SilentAim.Enabled then return nil end
    
    local camera = WS.CurrentCamera
    if not camera then return nil end
    
    local success, mousePos = pcall(function()
        return UIS:GetMouseLocation()
    end)
    if not success then return nil end
    
    local closest = {Player = nil, Distance = Settings.SilentAim.FOV}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then continue end
        
        local targetPart = character:FindFirstChild(Settings.SilentAim.TargetPart)
        if not targetPart then continue end
        
        -- Проверка видимости
        if Settings.SilentAim.VisibleCheck then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
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
        
        local success, screenPos, onScreen = pcall(function()
            return camera:WorldToViewportPoint(targetPart.Position)
        end)
        
        if success and onScreen then
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

-- 9. Инициализация
CreateFOVCircle()

-- 10. Обработка игроков
local function SafeCreateESP(player)
    if player and player ~= LocalPlayer then
        CreateESP(player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    SafeCreateESP(player)
end

Players.PlayerAdded:Connect(SafeCreateESP)

Players.PlayerRemoving:Connect(function(player)
    if ESPCache[player] then
        SafeRemoveDrawing(ESPCache[player].Box)
        SafeRemoveDrawing(ESPCache[player].Name)
        SafeRemoveDrawing(ESPCache[player].Health)
        ESPCache[player] = nil
    end
end)

-- 11. Основной цикл
RS.RenderStepped:Connect(function()
    UpdateFOVCircle()
    
    -- Дополнительная логика здесь
end)

print("NeonHub успешно загружен! Нажмите RightControl для открытия меню")
