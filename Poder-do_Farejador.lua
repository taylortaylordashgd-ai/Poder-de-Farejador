
-- Poder do Furry GUI (por ShadowStriker)
-- GUI custom, visual bonito, funcionalidade de 'Farejador', pegadas como esferas esticadas

local playerService = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = playerService.LocalPlayer

-- Guardar esferas e conexões
local allSpheres = {}
local sniffing = false
local connections = {}

-- Criar GUI Principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PoderDoFurryGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Main Frame com bordas, sombra etc
local mainFrame = Instance.new("Frame")
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0, 370, 0, 280)
mainFrame.BackgroundColor3 = Color3.fromRGB(32, 30, 34)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.05
mainFrame.Parent = screenGui

-- Sombra estilizada
local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(0,14)
local uiStroke = Instance.new("UIStroke", mainFrame)
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(255,200,55)
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Título
local title = Instance.new("TextLabel")
title.Text = "🐾 Poder do Furry"
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(255,212,82)
title.Parent = mainFrame

-- Subtítulo
local subtit = Instance.new("TextLabel")
subtit.Text = "ShadowStriker"
subtit.Size = UDim2.new(1, 0, 0, 20)
subtit.Position = UDim2.new(0, 0, 0, 38)
subtit.BackgroundTransparency = 1
subtit.Font = Enum.Font.Gotham
subtit.TextSize = 16
subtit.TextColor3 = Color3.fromRGB(184, 184, 184)
subtit.TextTransparency = 0.14
subtit.Parent = mainFrame

-- Aba (decorativa)
local tab = Instance.new("TextLabel")
tab.Text = "Furry"
tab.Size = UDim2.new(0,100,0,24)
tab.Position = UDim2.new(0,14,0,66)
tab.BackgroundTransparency = 0
tab.BackgroundColor3 = Color3.fromRGB(33,26,18)
tab.Font = Enum.Font.GothamSemibold
tab.TextSize = 18
tab.TextColor3 = Color3.fromRGB(255,200,80)
tab.ZIndex = 2
tab.Parent = mainFrame
local tabUICorner = Instance.new("UICorner", tab)
tabUICorner.CornerRadius = UDim.new(0,9)

-- Toggle Button: Farejador
local sniffBtn = Instance.new("TextButton")
sniffBtn.Text = "🔍 Ativar Farejador"
sniffBtn.Name = "SnifferButton"
sniffBtn.Size = UDim2.new(1, -34, 0, 40)
sniffBtn.Position = UDim2.new(0, 18, 0, 110)
sniffBtn.BackgroundColor3 = Color3.fromRGB(44,39,25)
sniffBtn.TextColor3 = Color3.fromRGB(254,225,100)
sniffBtn.Font = Enum.Font.GothamBold
sniffBtn.TextSize = 19
sniffBtn.AutoButtonColor = false
sniffBtn.Parent = mainFrame
local sniffUICorner = Instance.new("UICorner", sniffBtn)
sniffUICorner.CornerRadius = UDim.new(0,10)

-- Reset Button
local resetBtn = Instance.new("TextButton")
resetBtn.Text = "🗑️ Resetar Esferas"
resetBtn.Name = "ResetButton"
resetBtn.Size = UDim2.new(1,-34,0,36)
resetBtn.Position = UDim2.new(0,18,0,162)
resetBtn.BackgroundColor3 = Color3.fromRGB(56, 22, 24)
resetBtn.TextColor3 = Color3.fromRGB(255,135,109)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 17
resetBtn.AutoButtonColor = false
resetBtn.Parent = mainFrame
local resetUICorner = Instance.new("UICorner", resetBtn)
resetUICorner.CornerRadius = UDim.new(0, 9)

-- Guia visual e instrução
local infoTip = Instance.new("TextLabel")
infoTip.Text = "Clique na esfera para ver o nome de quem passou."
infoTip.Size = UDim2.new(1, -36, 0, 20)
infoTip.Position = UDim2.new(0, 18, 0, 217)
infoTip.BackgroundTransparency = 1
infoTip.Font = Enum.Font.Gotham
infoTip.TextColor3 = Color3.fromRGB(179,179,179)
infoTip.TextScaled = false
infoTip.TextSize = 15
infoTip.TextXAlignment = Enum.TextXAlignment.Left
infoTip.Parent = mainFrame

-- Cria uma esfera "pegada" esticada
local function createSphere(position, playerName)
    -- Esfera pequena e esticada
    local sphere = Instance.new("Part")
    sphere.Name = "FurryTrack"
    sphere.Shape = Enum.PartType.Ball
    sphere.Size = Vector3.new(1.8, 0.24, 0.7)
    sphere.Position = Vector3.new(position.X, position.Y + 0.11, position.Z)
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.BrickColor = BrickColor.new("New Yeller")
    sphere.Material = Enum.Material.Neon
    sphere.TopSurface = Enum.SurfaceType.Smooth

    local clickDetector = Instance.new("ClickDetector")
    clickDetector.Parent = sphere
    clickDetector.MaxActivationDistance = 16

    clickDetector.MouseClick:Connect(function()
        -- Evita múltiplos
        if sphere:FindFirstChild("FurryBillboard") then return end
        local gui = Instance.new("BillboardGui")
        gui.Name = "FurryBillboard"
        gui.Size = UDim2.new(0, 110, 0, 34)
        gui.Adornee = sphere
        gui.AlwaysOnTop = true
        gui.LightInfluence = 0
        gui.StudsOffset = Vector3.new(0, 0.9, 0)
        gui.Parent = sphere

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.Parent = gui
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.fromRGB(243,219,40)
        txt.TextStrokeTransparency = 0
        txt.TextScaled = true
        txt.Font = Enum.Font.GothamBold
        txt.Text = "👤 "..playerName

        wait(2.2)
        gui:Destroy()
    end)

    sphere.Parent = workspace
    table.insert(allSpheres, sphere)
end

-- Sistema de sniff
local lastPosition = {}

local function startSniffer()
    sniffing = true
    local function step()
        if not sniffing then return end
        for _,plr in pairs(playerService:GetPlayers()) do
            if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local root = plr.Character.HumanoidRootPart
                local oldPos = lastPosition[plr]
                local newPos = root.Position
                if not oldPos or (newPos - oldPos).magnitude >= 2.15 then
                    createSphere(Vector3.new(root.Position.X, workspace.FallenPartsDestroyHeight+3, root.Position.Z), plr.DisplayName or plr.Name)
                    lastPosition[plr] = newPos
                end
            end
        end
    end

    connections["SniffHeartbeat"] = runService.Heartbeat:Connect(step)
    -- Novos jogadores
    connections["SniffPlayerAdded"] = playerService.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function(char)
            wait(1)
            if char:FindFirstChild("HumanoidRootPart") then
                lastPosition[plr] = char.HumanoidRootPart.Position
            end
        end)
    end)
end

local function stopSniffer()
    sniffing = false
    for _,conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end

local function resetSpheres()
    for _,s in pairs(allSpheres) do
        pcall(function() s:Destroy() end)
    end
    allSpheres = {}
    lastPosition = {}
end

-- Toggle e Reset funcionalidade
sniffBtn.MouseButton1Click:Connect(function()
    sniffing = not sniffing
    if sniffing then
        sniffBtn.Text = "✅ Farejador: Ativado"
        sniffBtn.BackgroundColor3 = Color3.fromRGB(73,100,39)
        startSniffer()
    else
        sniffBtn.Text = "🔍 Ativar Farejador"
        sniffBtn.BackgroundColor3 = Color3.fromRGB(44,39,25)
        stopSniffer()
    end
end)

resetBtn.MouseButton1Click:Connect(function()
    resetSpheres()
end)


