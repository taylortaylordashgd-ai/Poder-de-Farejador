
-- Carregue o Rayfield UI Library (supondo que já foi carregado em outro lugar)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local PegadasFolder = Instance.new("Folder")
PegadasFolder.Name = "PegadasFeitas"
PegadasFolder.Parent = workspace

local farejadorAtivo = false
local connections = {}
local pegadaRefs = {} -- Usado para controlar todas as pegadas criadas

-- Função para criar a pegada
local function criarPegada(jogador)
    if not jogador.Character or not jogador.Character:FindFirstChild("HumanoidRootPart") then return end
    local pos = jogador.Character.HumanoidRootPart.Position

    local pegada = Instance.new("Part")
    pegada.Shape = Enum.PartType.Ball
    pegada.Name = "Pegada_"..jogador.Name
    pegada.Size = Vector3.new(0.7, 0.3, 1.2)
    pegada.CanCollide = false
    pegada.Anchored = true
    pegada.Material = Enum.Material.SmoothPlastic
    pegada.Color = Color3.fromRGB(175, 175, 210)
    pegada.Transparency = 0.5
    pegada.Position = Vector3.new(pos.X, pos.Y - 2.4, pos.Z)
    pegada.Parent = PegadasFolder

    -- Deixar achatada no chão
    local mesh = Instance.new("SpecialMesh", pegada)
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Scale = Vector3.new(1.2, 0.28, 2.1)

    -- Clique para mostrar nome
    local click = Instance.new("ClickDetector", pegada)
    click.MaxActivationDistance = 12
    click.MouseClick:Connect(function(plr)
        if plr == LocalPlayer then
            local gui = Instance.new("BillboardGui")
            gui.Size = UDim2.new(0, 140, 0, 32)
            gui.Adornee = pegada
            gui.Parent = pegada
            gui.StudsOffset = Vector3.new(0, 1, 0)
            gui.AlwaysOnTop = true

            local txt = Instance.new("TextLabel", gui)
            txt.BackgroundTransparency = 1
            txt.Size = UDim2.new(1,0,1,0)
            txt.Text = "Jogador: "..jogador.Name
            txt.TextStrokeTransparency = 0.1
            txt.TextColor3 = Color3.fromRGB(255,255,255)
            txt.Font = Enum.Font.FredokaOne
            txt.TextScaled = true

            delay(1.2, function() if gui then gui:Destroy() end end)
        end
    end)

    -- Guardar referência para facilitar reset
    table.insert(pegadaRefs, pegada)
end

-- Função de update das pegadas dos jogadores
local function ativarModoFarejador()
    farejadorAtivo = true

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Conexão de movimento para cada jogador
            connections[player] = RunService.Heartbeat:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    -- Marcar rastro ~cada X studs
                    local ultima = pegadaRefs[#pegadaRefs]
                    if not ultima or (player.Character.HumanoidRootPart.Position - ultima.Position).magnitude > 2 then
                        criarPegada(player)
                    end
                end
            end)
        end
    end

    -- Detectar novos jogadores entrando
    connections["_newPlayer"] = Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            connections[player] = RunService.Heartbeat:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local ultima = pegadaRefs[#pegadaRefs]
                    if not ultima or (player.Character.HumanoidRootPart.Position - ultima.Position).magnitude > 2 then
                        criarPegada(player)
                    end
                end
            end)
        end
    end)
end

local function desativarModoFarejador()
    farejadorAtivo = false
    -- Desconecta todos os Heartbeats e conn's
    for k, v in pairs(connections) do
        if typeof(v) == "RBXScriptConnection" and v.Connected then
            v:Disconnect()
        end
    end
    connections = {}
end

local function resetPegadas()
    for _, peg in ipairs(pegadaRefs) do
        if peg and peg.Parent then
            peg:Destroy()
        end
    end
    pegadaRefs = {}
    -- Ao resetar, começa a rastrear de novo se estiver ativo
    if farejadorAtivo then
        desativarModoFarejador()
        ativarModoFarejador()
    end
end

-- Função para tela embaçada
local blur
local avisoGui

local function iniciarBlur()
    if not Lighting:FindFirstChild("RayField_BlurEffect") then
        blur = Instance.new("BlurEffect")
        blur.Name = "RayField_BlurEffect"
        blur.Size = 12 -- grau do embaçado
        blur.Parent = Lighting
    end
end

local function removerBlur()
    if Lighting:FindFirstChild("RayField_BlurEffect") then
        Lighting:FindFirstChild("RayField_BlurEffect"):Destroy()
    end
end

local function mostrarAviso(callback)
    -- Criar uma tela cheia + blur ativado
    iniciarBlur()
    if avisoGui then avisoGui:Destroy() end

    avisoGui = Instance.new("ScreenGui")
    avisoGui.Name = "AvisoFarejador"
    avisoGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    avisoGui.IgnoreGuiInset = true
    if syn and syn.protect_gui then pcall(function() syn.protect_gui(avisoGui) end) end
    avisoGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

    local fundo = Instance.new("Frame")
    fundo.BackgroundColor3 = Color3.fromRGB(33, 34, 44)
    fundo.BackgroundTransparency = 0.35
    fundo.BorderSizePixel = 0
    fundo.Size = UDim2.new(1,0,1,0)
    fundo.Position = UDim2.new(0,0,0,0)
    fundo.Parent = avisoGui

    local avisoBox = Instance.new("Frame")
    avisoBox.AnchorPoint = Vector2.new(0.5,0.5)
    avisoBox.Position = UDim2.new(0.5,0,0.5,0)
    avisoBox.Size = UDim2.new(0, 420, 0, 180)
    avisoBox.BackgroundColor3 = Color3.fromRGB(38, 139, 210)
    avisoBox.BackgroundTransparency = 0.03
    avisoBox.BorderSizePixel = 0
    avisoBox.Parent = fundo

    local avisoText = Instance.new("TextLabel")
    avisoText.Position = UDim2.new(0.08,0,0.18,0)
    avisoText.Size = UDim2.new(0.84,0,0.4,0)
    avisoText.BackgroundTransparency = 1
    avisoText.Text = [[Os Furrys só usam esse script
e se você nao é furry 
você é um teste e ainda pode testar!]]
    avisoText.TextColor3 = Color3.fromRGB(255,255,255)
    avisoText.Font = Enum.Font.GothamBold
    avisoText.TextSize = 24
    avisoText.TextWrapped = true
    avisoText.Parent = avisoBox

    local okBtn = Instance.new("TextButton")
    okBtn.Text = "Ok"
    okBtn.AnchorPoint = Vector2.new(0.5,0.5)
    okBtn.Position = UDim2.new(0.5, 0, 0.82, 0)
    okBtn.Size = UDim2.new(0.28,0,0.2,0)
    okBtn.BackgroundColor3 = Color3.fromRGB(36, 46, 81)
    okBtn.BorderSizePixel = 0
    okBtn.TextColor3 = Color3.fromRGB(255,255,255)
    okBtn.Font = Enum.Font.GothamSemibold
    okBtn.TextSize = 20
    okBtn.Parent = avisoBox

    okBtn.MouseButton1Click:Connect(function()
        if avisoGui then avisoGui:Destroy() end
        removerBlur()
        if callback then callback() end
    end)
end

-- Iniciar tela de aviso assim que executa
mostrarAviso(function()
    -- UI Rayfield só aparece depois que clicar em OK
    local janela = Rayfield:CreateWindow({
        Name = "Poder do Farejador (V1)",
        LoadingTitle = "Poder do Farejador",
        LoadingSubtitle = "by ShadowStriker",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "FarejadorConfig",
            FileName = "Config"
        },
        Discord = {
            Enabled = false,
            Invite = "",
            RememberJoins = false
        }
    })

    local abaPlayer = janela:CreateTab({
        Name = "Player",
        Icon = "rbxassetid://0",
        PremiumOnly = false
    })

    -- Alternar Modo Farejador
    abaPlayer:CreateToggle({
        Name = "Modo Farejador",
        CurrentValue = false,
        Flag = "ModoFarejador",
        Callback = function(state)
            if state then
                ativarModoFarejador()
            else
                desativarModoFarejador()
            end
        end
    })

    -- Reset botão
    abaPlayer:CreateButton({
        Name = "Reset Pegadas",
        Callback = function()
            resetPegadas()
        end
    })
end)




