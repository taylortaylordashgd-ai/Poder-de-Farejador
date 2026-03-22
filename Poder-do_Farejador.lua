-- Carregue o Rayfield UI Library (se não estiver carregado, adicione a linha abaixo no início do seu executor principal)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local PegadasFolder = Instance.new("Folder")
PegadasFolder.Name = "PegadasFeitas"
PegadasFolder.Parent = workspace

local farejadorAtivo = false
local connections = {}
local pegadasPorJogador = {}
local controleUltimaPos = {}
local pegadaRefs = {}

-- Função para criar a pegada
local function criarPegada(jogador)
    if not jogador or not jogador.Character or not jogador.Character:FindFirstChild("HumanoidRootPart") then return end
    local pos = jogador.Character.HumanoidRootPart.Position

    local pegada = Instance.new("Part")
    pegada.Shape = Enum.PartType.Ball
    pegada.Name = "Pegada_"..jogador.Name
    pegada.Size = Vector3.new(0.9, 0.3, 1.5)
    pegada.CanCollide = false
    pegada.Anchored = true
    pegada.Material = Enum.Material.SmoothPlastic
    pegada.Color = Color3.fromRGB(140, 180, 255)
    pegada.Transparency = 0.6
    pegada.Position = Vector3.new(pos.X, pos.Y - 2.3, pos.Z)
    pegada.Parent = PegadasFolder

    -- Achatada (escala esfera)
    local mesh = Instance.new("SpecialMesh", pegada)
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Scale = Vector3.new(1.25, 0.28, 2.1)

    -- Clique para mostrar nome
    local click = Instance.new("ClickDetector", pegada)
    click.MaxActivationDistance = 15
    click.MouseClick:Connect(function(plr)
        if plr == LocalPlayer then
            local gui = Instance.new("BillboardGui")
            gui.Size = UDim2.new(0, 167, 0, 36)
            gui.Adornee = pegada
            gui.Parent = pegada
            gui.StudsOffset = Vector3.new(0, 0.8, 0)
            gui.AlwaysOnTop = true

            local txt = Instance.new("TextLabel", gui)
            txt.BackgroundTransparency = 1
            txt.Size = UDim2.new(1,0,1,0)
            txt.Text = "Jogador: "..jogador.Name
            txt.TextStrokeTransparency = 0.08
            txt.TextColor3 = Color3.fromRGB(255,255,255)
            txt.Font = Enum.Font.FredokaOne
            txt.TextScaled = true

            delay(1.1, function() if gui then gui:Destroy() end end)
        end
    end)

    -- Guardar referência para facilitar reset
    table.insert(pegadaRefs, pegada)
    pegadasPorJogador[jogador] = pegadasPorJogador[jogador] or {}
    table.insert(pegadasPorJogador[jogador], pegada)
end

local function desconectarMovimento()
    for k, v in pairs(connections) do
        if typeof(v) == "RBXScriptConnection" and v.Connected then
            v:Disconnect()
        end
    end
    connections = {}
    controleUltimaPos = {}
end

-- Gera pegada a cada X studs de distância
local passo = 2.7
local function ativarModoFarejador()
    farejadorAtivo = true

    desconectarMovimento()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            connections[player] = RunService.Heartbeat:Connect(function()
                if not farejadorAtivo then return end
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = player.Character.HumanoidRootPart.Position
                    local ultimaPos = controleUltimaPos[player]
                    if not ultimaPos or (pos - ultimaPos).Magnitude > passo then
                        criarPegada(player)
                        controleUltimaPos[player] = pos
                    end
                end
            end)
        end
    end

    connections["_newPlayer"] = Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            connections[player] = RunService.Heartbeat:Connect(function()
                if not farejadorAtivo then return end
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = player.Character.HumanoidRootPart.Position
                    local ultimaPos = controleUltimaPos[player]
                    if not ultimaPos or (pos - ultimaPos).Magnitude > passo then
                        criarPegada(player)
                        controleUltimaPos[player] = pos
                    end
                end
            end)
        end
    end)
end

local function desativarModoFarejador()
    farejadorAtivo = false
    desconectarMovimento()
end

local function resetPegadas()
    for _, peg in ipairs(pegadaRefs) do
        if peg and peg.Parent then
            peg:Destroy()
        end
    end
    pegadasPorJogador = {}
    pegadaRefs = {}
    controleUltimaPos = {}
    -- Reinicia rastreamento automático se estiver ativado
    if farejadorAtivo then
        desativarModoFarejador()
        ativarModoFarejador()
    end
end

-- Embaçado/tela de aviso
local blur
local avisoGui

local function iniciarBlur()
    if not Lighting:FindFirstChild("RayField_BlurEffect") then
        blur = Instance.new("BlurEffect")
        blur.Name = "RayField_BlurEffect"
        blur.Size = 10
        blur.Parent = Lighting
    end
end

local function removerBlur()
    if Lighting:FindFirstChild("RayField_BlurEffect") then
        Lighting:FindFirstChild("RayField_BlurEffect"):Destroy()
    end
end

local function mostrarAviso(callback)
    iniciarBlur()
    if avisoGui then avisoGui:Destroy() end

    avisoGui = Instance.new("ScreenGui")
    avisoGui.Name = "AvisoFarejador"
    avisoGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    avisoGui.IgnoreGuiInset = true
    if syn and syn.protect_gui then pcall(function() syn.protect_gui(avisoGui) end) end
    avisoGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

    local fundo = Instance.new("Frame")
    fundo.BackgroundColor3 = Color3.fromRGB(36, 31, 46)
    fundo.BackgroundTransparency = 0.15
    fundo.BorderSizePixel = 0
    fundo.Size = UDim2.new(1,0,1,0)
    fundo.Position = UDim2.new(0,0,0,0)
    fundo.Parent = avisoGui

    local avisoBox = Instance.new("Frame")
    avisoBox.AnchorPoint = Vector2.new(0.5,0.5)
    avisoBox.Position = UDim2.new(0.5,0,0.5,0)
    avisoBox.Size = UDim2.new(0, 420, 0, 180)
    avisoBox.BackgroundColor3 = Color3.fromRGB(38, 119, 210)
    avisoBox.BackgroundTransparency = 0.00
    avisoBox.BorderSizePixel = 0
    avisoBox.Parent = fundo

    local avisoText = Instance.new("TextLabel")
    avisoText.Position = UDim2.new(0.095,0,0.179,0)
    avisoText.Size = UDim2.new(0.81,0,0.45,0)
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
    okBtn.Size = UDim2.new(0.28,0,0.20,0)
    okBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 81)
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

-- Executa aviso, depois interface principal
mostrarAviso(function()
    -- Crie janela Rayfield
    local janela = Rayfield:CreateWindow({
        Name = "Poder do Farejador (V1)",
        LoadingTitle = "Poder do Farejador",
        LoadingSubtitle = "by ShadowStriker",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = nil,
            FileName = "PoderDoFarejadorConfig"
        },
        Discord = {
            Enabled = false,
            Invite = "",
            RememberJoins = false
        }
    })

    -- Aba Player
    local playerTab = janela:CreateTab({
        Name = "Player",
        Icon = "rbxassetid://0", -- pode trocar depois se desejar
        PremiumOnly = false
    })

    -- Toggle modo farejador
    playerTab:CreateToggle({
        Name = "Modo Farejador",
        CurrentValue = false,
        Flag = "ModoFarejador",
        Callback = function(ativar)
            if ativar then
                ativarModoFarejador()
            else
                desativarModoFarejador()
            end
        end
    })

    -- Botão de reset
    playerTab:CreateButton({
        Name = "Reset Pegadas",
        Callback = function()
            resetPegadas()
        end
    })
end)
