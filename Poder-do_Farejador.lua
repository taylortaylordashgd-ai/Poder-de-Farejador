--[[
Poder do Furry - Redz Hub by ShadowStriker
]]

-- Inicialização do UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = PlayerService.LocalPlayer

local FarejadorAtivo = false
local pegadasCriadas = {} -- Armazena todas as pegadas criadas

-- Janela principal
local Janela = Rayfield:CreateWindow({
    Name = "Poder do Furry",
    LoadingTitle = "Poder do Furry",
    LoadingSubtitle = "by ShadowStriker",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "PoderDoFurryConfig"
    }
})

-- Aba Furry
local FurryTab = Janela:CreateTab({
    Name = "Furry",
    Icon = "rbxassetid://14851149216",
    PremiumOnly = false
})

-- Função para criar pegada
local function criarPegada(posicao)
    local pegada = Instance.new("Part")
    pegada.Size = Vector3.new(0.8, 0.2, 1.2)
    pegada.Anchored = true
    pegada.CanCollide = false
    pegada.Material = Enum.Material.SmoothPlastic
    pegada.BrickColor = BrickColor.new("Medium stone grey")
    pegada.Transparency = 0.2
    pegada.CFrame = CFrame.new(posicao) * CFrame.Angles(math.pi/2,0,0)
    pegada.Parent = Workspace
    -- Opcional: decal/mesh para formato mais visual
    table.insert(pegadasCriadas, pegada)
end

-- Função para remover todas pegadas criadas
local function limparPegadas()
    for _, pegada in ipairs(pegadasCriadas) do
        if pegada and pegada.Parent then
            pegada:Destroy()
        end
    end
    pegadasCriadas = {}
end

-- Pegadas por player
local ultimoPasso = {}

-- Loop do Farejador
local farejadorConexao = nil

local function ativarFarejador()
    if farejadorConexao then return end
    farejadorConexao = RunService.Heartbeat:Connect(function()
        for _, player in ipairs(PlayerService:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local ultimaPos = ultimoPasso[player]
                if not ultimaPos or (hrp.Position - ultimaPos).magnitude > 2 then -- nova posição? (cada 2 studs)
                    criarPegada(hrp.Position - Vector3.new(0, hrp.Size.Y/2 + 0.1, 0))
                    ultimoPasso[player] = hrp.Position
                end
            end
        end
    end)
end

local function desativarFarejador()
    if farejadorConexao then
        farejadorConexao:Disconnect()
        farejadorConexao = nil
    end
    ultimoPasso = {}
    limparPegadas()
end

-- Toggle na UI
FurryTab:CreateToggle({
    Name = "Farejador",
    CurrentValue = false,
    Flag = "FarejadorToggle",
    Callback = function(value)
        FarejadorAtivo = value
        if FarejadorAtivo then
            ativarFarejador()
        else
            desativarFarejador()
        end
    end,
    Info = "Ativa ou desativa o poder de farejar: veja as pegadas dos jogadores por onde eles passaram."
})
