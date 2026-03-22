local Rayfield = loadstring(game:HttpGet('https://shz.al/rayfield'))()

local window = Rayfield:CreateWindow({
    Name = "Poder do Furry",
    LoadingTitle = "Poder do Furry",
    LoadingSubtitle = "by ShadowStriker",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "FurryConfig"
    }
})

local furryTab = window:CreateTab({
    Name = "Furry",
    Icon = "rbxassetid://0", -- Substitua se quiser um ícone
    PremiumOnly = false
})

local FarejadorAtivo = false
local PegadasFolder = nil
local PegadaCons = {}

local function criarPegada(pos, jogador)
    if not PegadasFolder then
        PegadasFolder = Instance.new("Folder", workspace)
        PegadasFolder.Name = "FurryPegadas"
    end
    local pegada = Instance.new("Part")
    pegada.Size = Vector3.new(1.5,0.2,2)
    pegada.Position = pos + Vector3.new(0,0.1,0)
    pegada.Anchored = true
    pegada.CanCollide = false
    pegada.Material = Enum.Material.SmoothPlastic
    pegada.BrickColor = BrickColor.new("Bright violet")
    pegada.Transparency = 0.4
    pegada.Name = jogador.Name .. "_FurryPegada"
    -- Opcional: clique mostra quem deixou a pegada
    local click = Instance.new("ClickDetector", pegada)
    click.MouseClick:Connect(function(plr)
        game.StarterGui:SetCore("SendNotification", {
            Title = "Pegada de Furry!",
            Text = "Pegada de: " .. jogador.Name,
            Duration = 2
        })
    end)
    pegada.Parent = PegadasFolder
end

local function ativarFarejador()
    if not PegadasFolder then
        PegadasFolder = Instance.new("Folder", workspace)
        PegadasFolder.Name = "FurryPegadas"
    end
    FarejadorAtivo = true
    for _, jogador in ipairs(game.Players:GetPlayers()) do
        if jogador.Character and jogador.Character:FindFirstChild("HumanoidRootPart") then
            local lastPos = jogador.Character.HumanoidRootPart.Position
            PegadaCons[jogador] = jogador.Character.HumanoidRootPart:GetPropertyChangedSignal("Position"):Connect(function()
                if FarejadorAtivo then
                    local pos = jogador.Character.HumanoidRootPart.Position
                    if (pos - lastPos).magnitude > 4 then -- só põe se andou
                        criarPegada(pos, jogador)
                        lastPos = pos
                    end
                end
            end)
        end
        -- Garante pegar se personagem respawnar
        jogador.CharacterAdded:Connect(function(char)
            char:WaitForChild("HumanoidRootPart")
            local lastPos = char.HumanoidRootPart.Position
            PegadaCons[jogador] = char.HumanoidRootPart:GetPropertyChangedSignal("Position"):Connect(function()
                if FarejadorAtivo then
                    local pos = char.HumanoidRootPart.Position
                    if (pos - lastPos).magnitude > 4 then
                        criarPegada(pos, jogador)
                        lastPos = pos
                    end
                end
            end)
        end)
    end
    -- Pega jogadores que entrarem depois
    game.Players.PlayerAdded:Connect(function(jogador)
        jogador.CharacterAdded:Connect(function(char)
            char:WaitForChild("HumanoidRootPart")
            local lastPos = char.HumanoidRootPart.Position
            PegadaCons[jogador] = char.HumanoidRootPart:GetPropertyChangedSignal("Position"):Connect(function()
                if FarejadorAtivo then
                    local pos = char.HumanoidRootPart.Position
                    if (pos - lastPos).magnitude > 4 then
                        criarPegada(pos, jogador)
                        lastPos = pos
                    end
                end
            end)
        end)
    end)
end

local function desativarFarejador()
    FarejadorAtivo = false
    -- Apenas desconecta sinais, as pegadas permanecem no chão como solicitado
    for jogador,conn in pairs(PegadaCons) do
        if conn then
            conn:Disconnect()
        end
    end
    PegadaCons = {}
end

furryTab:CreateToggle({
    Name = "Farejador",
    CurrentValue = false,
    Flag = "FurryFarejador",
    Callback = function(ativo)
        if ativo then
            ativarFarejador()
        else
            desativarFarejador()
        end
    end
})
