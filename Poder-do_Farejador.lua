--[[
Script: Poder do Furs0n0 V1
Criador: ShadowStriker

- Aba: Furry
- Opção: "Farejar" (toggle)
    - Ativa/desativa esferas aparecendo onde jogadores caminham.
    - Esferas pequenas embaixo dos jogadores e vão ficando no chão conforme andam.
    - Se clicar na esfera, aparece o nome do jogador que criou.
- Opção: "Resetar o farejar"
    - Deleta todas as esferas.
--]]

-- Carregar Rayfield GUI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Poder do Furs0n0 V1",
    LoadingTitle = "Poder do Furs0n0",
    LoadingSubtitle = "by ShadowStriker",
    ConfigurationSaving = {
       Enabled = false,
       FolderName = nil,
       FileName = "PoderDoFurryConfig"
    },
})

local FurryTab = Window:CreateTab({
    Name = "Furry",
    Icon = "rbxassetid://0",
    PremiumOnly = false
})

-- Controle principal
local FarejarAtivo = false
local EsferasFolder = Instance.new("Folder")
EsferasFolder.Name = "EsferasFarejar"
EsferasFolder.Parent = workspace

local connections = {}

local function criarEsfera(pos, nomeJogador)
    local esfera = Instance.new("Part")
    esfera.Shape = Enum.PartType.Ball
    esfera.Size = Vector3.new(0.8, 0.8, 0.8)
    esfera.Position = Vector3.new(pos.X, pos.Y + 0.3, pos.Z)
    esfera.Anchored = true
    esfera.CanCollide = false
    esfera.Material = Enum.Material.Neon
    esfera.Color = Color3.fromRGB(170, 85, 255)
    esfera.Transparency = 0.3
    esfera.Parent = EsferasFolder
    esfera.Name = "FarejarEsfera_"..(nomeJogador or "Desconhecido")
    -- Click detector para mostrar nome do jogador
    local click = Instance.new("ClickDetector")
    click.Parent = esfera
    click.MouseClick:Connect(function(plr)
        game.StarterGui:SetCore("SendNotification", {
            Title = "Farejador",
            Text = "Pegada de: "..tostring(nomeJogador),
            Duration = 2
        })
    end)
end

local function conectarFarejar(player)
    -- Ignorar se não tem personagem ainda
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    -- Última posição marcada de esfera (para não spammar demais)
    local lastPos = player.Character.HumanoidRootPart.Position

    local function onMove()
        if not FarejarAtivo then return end
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local pos = hrp.Position
        if (pos - lastPos).magnitude >= 2 then -- espaçamento mínimo entre esferas
            criarEsfera(Vector3.new(pos.X, workspace.FallenPartsDestroyHeight + 3, pos.Z), player.Name) -- manter sempre no chão
            lastPos = pos
        end
    end

    -- Põe imediatamente uma esfera ao ativar
    local hrp = player.Character.HumanoidRootPart
    criarEsfera(Vector3.new(hrp.Position.X, workspace.FallenPartsDestroyHeight + 3, hrp.Position.Z), player.Name)

    -- Conexão para as próximas esferas quando andar
    connections[player] = hrp:GetPropertyChangedSignal("Position"):Connect(onMove)
end

local function conectarTodosJogadores()
    for _, plr in pairs(game.Players:GetPlayers()) do
        if connections[plr] then
            connections[plr]:Disconnect()
            connections[plr] = nil
        end
        conectarFarejar(plr)
        -- Se morrer ou respawnar personagem
        if not connections[plr.."_char"] then
            connections[plr.."_char"] = plr.CharacterAdded:Connect(function()
                wait(0.1)
                conectarFarejar(plr)
            end)
        end
    end
end

local function desconectarFarejar()
    for plr,conn in pairs(connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    connections = {}
end

local function resetarEsferas()
    for _, esfera in pairs(EsferasFolder:GetChildren()) do
        if esfera:IsA("Part") then
            esfera:Destroy()
        end
    end
end

-- Farejar Toggle
FurryTab:CreateToggle({
    Name = "Farejar",
    CurrentValue = false,
    Flag = "FurryFarejar_Toggle",
    Callback = function(Value)
        FarejarAtivo = Value
        if FarejarAtivo then
            conectarTodosJogadores()
            -- Conectar para novos jogadores
            if not connections["playerAdded"] then
                connections["playerAdded"] = game.Players.PlayerAdded:Connect(function(plr)
                    conectarFarejar(plr)
                    if not connections[plr.."_char"] then
                        connections[plr.."_char"] = plr.CharacterAdded:Connect(function()
                            wait(0.1)
                            conectarFarejar(plr)
                        end)
                    end
                end)
            end
        else
            desconectarFarejar()
        end
    end
})

-- Botão de resetar
FurryTab:CreateButton({
    Name = "Resetar o farejar",
    Callback = function()
        resetarEsferas()
    end
})

