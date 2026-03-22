-- Script Hub Rayfield - "Poder do Furry" por ShadowStriker

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local window = Rayfield:CreateWindow({
    Name = "Poder do Furry",
    LoadingTitle = "Poder do Furry",
    LoadingSubtitle = "by ShadowStriker",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "PoderDoFurryConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false,
    KeySettings = {
        Title = "",
        Subtitle = "",
        Note = "",
        FileName = "",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = ""
    }
})

local furryTab = window:CreateTab({
    Name = "Furry",
    Icon = "rbxassetid://3926307971", -- ícone de lobo/animal, você pode trocar se quiser
    PremiumOnly = false
})

local playerService = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = playerService.LocalPlayer

local sniffEnabled = false
local connections = {}
local allSpheres = {}

local function createSphere(position, playerName)
    local sphere = Instance.new("Part")
    sphere.Name = "PlayerFootprint"
    sphere.Shape = Enum.PartType.Ball
    sphere.Size = Vector3.new(1.4, 0.2, 1.4)
    sphere.Position = Vector3.new(position.X, position.Y + 0.1, position.Z)
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.BrickColor = BrickColor.new("Bright yellow")
    sphere.Material = Enum.Material.Neon
    sphere.TopSurface = Enum.SurfaceType.Smooth

    local clickDetector = Instance.new("ClickDetector", sphere)
    clickDetector.MouseClick:Connect(function()
        -- Já impede múltiplos billboards
        if sphere:FindFirstChild("ShowNameGui") then return end
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ShowNameGui"
        billboard.Size = UDim2.new(0,110,0,36)
        billboard.Adornee = sphere
        billboard.Parent = sphere
        billboard.AlwaysOnTop = true

        local txt = Instance.new("TextLabel")
        txt.Parent = billboard
        txt.Size = UDim2.new(1,0,1,0)
        txt.Text = playerName
        txt.TextColor3 = Color3.fromRGB(255,255,86)
        txt.BackgroundTransparency = 1
        txt.TextStrokeTransparency = 0
        txt.TextScaled = true

        wait(2)
        billboard:Destroy()
    end)

    sphere.Parent = workspace
    table.insert(allSpheres, sphere)
end

local function startSniffer()
    local lastPosition = {}
    connections["SniffHeartbeat"] = runService.Heartbeat:Connect(function()
        for _,plr in pairs(playerService:GetPlayers()) do
            if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local root = plr.Character.HumanoidRootPart
                local oldPos = lastPosition[plr]
                local newPos = root.Position

                if not oldPos or (newPos - oldPos).magnitude > 2 then
                    createSphere(Vector3.new(root.Position.X, workspace.FallenPartsDestroyHeight+2, root.Position.Z), plr.DisplayName or plr.Name)
                    lastPosition[plr] = newPos
                end
            end
        end
    end)

    -- Para novos jogadores
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

furryTab:CreateSection({Name = "Poder do Furry - ShadowStriker"})

furryTab:CreateToggle({
    Name = "Farejador",
    CurrentValue = false,
    Flag = "FarejadorToggle",
    Callback = function(Value)
        sniffEnabled = Value
        if sniffEnabled then
            startSniffer()
        else
            stopSniffer()
        end
    end
})

furryTab:CreateButton({
    Name = "Reset",
    Callback = function()
        resetSpheres()
    end
})
