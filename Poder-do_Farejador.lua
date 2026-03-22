-- Script Hub Rayfield - "Poder do Furry" por ShadowStriker

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local window = Rayfield:CreateWindow({
    Name = "Poder do Furry",
    LoadingTitle = "Poder do Furry",
    LoadingSubtitle = "by ShadowStriker",
    ConfigurationSaving = {
        Enabled = false
    }
})

local furryTab = window:CreateTab({
    Name = "Furry",
    Icon = "rbxassetid://3926305904", -- Um ícone padrão, troque se quiser algo melhor
    PremiumOnly = false
})

local playerService = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = playerService.LocalPlayer

local enabled = false
local showFootprints = false
local connections = {}
local allFootprints = {} -- Tabela para armazenar as pegadas criadas, para reset

-- Função para criar uma pegada num ponto
local function createFootprint(position, playerName)
    local footprint = Instance.new("Part")
    footprint.Name = "PlayerFootprint"
    footprint.Size = Vector3.new(1,0.1,2)
    footprint.Position = position
    footprint.Anchored = true
    footprint.CanCollide = false
    footprint.BrickColor = BrickColor.new("Bright yellow")
    footprint.Material = Enum.Material.Neon
    footprint.TopSurface = Enum.SurfaceType.Smooth

    -- BillGui para mostrar o nome do player ao clicar
    local clickDetector = Instance.new("ClickDetector", footprint)
    clickDetector.MouseClick:Connect(function()
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0,100,0,30)
        billboard.Adornee = footprint
        billboard.Parent = footprint
        billboard.AlwaysOnTop = true

        local txt = Instance.new("TextLabel")
        txt.Parent = billboard
        txt.Size = UDim2.new(1,0,1,0)
        txt.Text = playerName
        txt.BackgroundTransparency = 1
        txt.TextStrokeTransparency = 0
        txt.TextColor3 = Color3.new(1,1,0)

        wait(2)
        billboard:Destroy()
    end)

    footprint.Parent = workspace
    table.insert(allFootprints, footprint)
end

-- Função para rastrear jogadores e criar as pegadas
local function startFootprintSystem()
    local trackTable = {}

    -- Monitorar todos os jogadores menos o localplayer
    for _,plr in pairs(playerService:GetPlayers()) do
        if plr ~= localPlayer and plr.Character then
            local humanoidRootPart = plr.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                trackTable[plr] = humanoidRootPart.Position
            end
        end
    end

    -- Connections
    connections["FootprintRun"] = runService.Heartbeat:Connect(function()
        if not enabled then return end
        for _,plr in pairs(playerService:GetPlayers()) do
            if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local root = plr.Character.HumanoidRootPart
                local oldPos = trackTable[plr]
                -- Checa se andou mais que 2 studs
                if oldPos == nil or (root.Position - oldPos).magnitude > 2 then
                    -- Cria pegada
                    createFootprint(root.Position - Vector3.new(0, 2.5, 0), plr.DisplayName or plr.Name)
                    trackTable[plr] = root.Position
                end
            end
        end
    end)

    -- Se um jogador novo entrar
    connections["PlayerAdded"] = playerService.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function(char)
            wait(1)
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                trackTable[plr] = root.Position
            end
        end)
    end)
end

local function stopFootprintSystem()
    -- Disconecta todos para não continuar rastreando
    for _,conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end

local function resetFootprints()
    -- Remove todas as pegadas do mapa
    for _,pg in pairs(allFootprints) do
        pcall(function() pg:Destroy() end)
    end
    allFootprints = {}
end

-- Switch: Ativar/desativar o Farejador
furryTab:CreateToggle({
    Name = "Farejador",
    CurrentValue = false,
    Flag = "FarejadorToggle",
    Callback = function(Value)
        enabled = Value
        if enabled then
            startFootprintSystem()
        else
            stopFootprintSystem()
        end
    end
})

-- Botão para resetar as pegadas
furryTab:CreateButton({
    Name = "Reset",
    Callback = function()
        resetFootprints()
    end
})
