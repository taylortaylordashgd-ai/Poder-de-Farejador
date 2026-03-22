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
    Icon = "rbxassetid://3926305904",
    PremiumOnly = false
})

local playerService = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = playerService.LocalPlayer

local enabled = false
local connections = {}
local allSpheres = {}

-- Função para criar uma esfera achatada pequena no chão
local function createSphere(position, playerName)
    local sphere = Instance.new("Part")
    sphere.Name = "PlayerSphere"
    sphere.Shape = Enum.PartType.Ball
    sphere.Size = Vector3.new(1.4, 0.2, 1.4)
    sphere.Position = Vector3.new(position.X, position.Y + 0.1, position.Z)
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.BrickColor = BrickColor.new("Bright yellow")
    sphere.Material = Enum.Material.Neon
    sphere.TopSurface = Enum.SurfaceType.Smooth

    -- Sistema de click para mostrar o nome
    local clickDetector = Instance.new("ClickDetector", sphere)
    clickDetector.MouseClick:Connect(function()
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0,110,0,36)
        billboard.Adornee = sphere
        billboard.Parent = sphere
        billboard.AlwaysOnTop = true

        local txt = Instance.new("TextLabel")
        txt.Parent = billboard
        txt.Size = UDim2.new(1,0,1,0)
        txt.Text = playerName
        txt.BackgroundTransparency = 1
        txt.TextStrokeTransparency = 0
        txt.TextScaled = true
        txt.TextColor3 = Color3.fromRGB(255,255,86)

        wait(2)
        billboard:Destroy()
    end)

    sphere.Parent = workspace
    table.insert(allSpheres, sphere)
end

-- Função para rastrear jogadores e criar as esferas achatadas
local function startSphereSystem()
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

    connections["SphereRun"] = runService.Heartbeat:Connect(function()
        if not enabled then return end
        for _,plr in pairs(playerService:GetPlayers()) do
            if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local root = plr.Character.HumanoidRootPart
                local oldPos = trackTable[plr]
                if oldPos == nil or (root.Position - oldPos).magnitude > 2 then
                    -- Cria esfera achatada onde o player passou
                    createSphere(Vector3.new(root.Position.X, workspace.FallenPartsDestroyHeight+0.5, root.Position.Z), plr.DisplayName or plr.Name)
                    trackTable[plr] = root.Position
                end
            end
        end
    end)

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

local function stopSphereSystem()
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
end

furryTab:CreateToggle({
    Name = "Farejador",
    CurrentValue = false,
    Flag = "FarejadorToggle",
    Callback = function(Value)
        enabled = Value
        if enabled then
            startSphereSystem()
        else
            stopSphereSystem()
        end
    end
})

furryTab:CreateButton({
    Name = "Reset",
    Callback = function()
        resetSpheres()
    end
})
