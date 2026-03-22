--[[ 
Script Name: Poder de Farejar (V1)
Criador: ShdowStriker

Este script cria uma janela RayField, tela embaçada com aviso especial,
Adiciona aba Player, função de "Modo: Farejador" (mostrar pegadas dos jogadores ao andar), 
botão para resetar pegadas, e clicar nas pegadas mostra nome do jogador.
]]

-- Função para mostrar aviso inicial com tela embaçada
local function ShowBlurAndWarning(onOk)
    local player = game.Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "FarejarAviso"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false

    -- Blur Effect
    local blur = Instance.new("BlurEffect")
    blur.Size = 24
    blur.Parent = game.Lighting

    -- Cover Background
    local bg = Instance.new("Frame")
    bg.BackgroundColor3 = Color3.fromRGB(30,30,30)
    bg.BackgroundTransparency = 0.3
    bg.Size = UDim2.new(1,0,1,0)
    bg.Parent = gui

    -- Central Aviso
    local aviso = Instance.new("TextLabel")
    aviso.Text = "Os Furrys podem Usar esse script e se você é um humano você é um teste que vai testar esse script"
    aviso.TextWrapped = true
    aviso.TextColor3 = Color3.fromRGB(255,255,255)
    aviso.BackgroundTransparency = 1
    aviso.Font = Enum.Font.FredokaOne or Enum.Font.SourceSansBold
    aviso.TextScaled = true
    aviso.Size = UDim2.new(0.7,0,0.23,0)
    aviso.Position = UDim2.new(0.15,0,0.35,0)
    aviso.Parent = gui

    -- Ok Button
    local okButton = Instance.new("TextButton")
    okButton.Text = "Ok"
    okButton.Size = UDim2.new(0.15,0,0.08,0)
    okButton.Position = UDim2.new(0.425,0,0.61,0)
    okButton.BackgroundColor3 = Color3.fromRGB(80,170,255)
    okButton.TextColor3 = Color3.new(1,1,1)
    okButton.Font = Enum.Font.FredokaOne or Enum.Font.SourceSansBold
    okButton.TextScaled = true
    okButton.Parent = gui

    gui.Parent = player:WaitForChild("PlayerGui")

    okButton.MouseButton1Click:Connect(function()
        gui:Destroy()
        blur:Destroy()
        if onOk then onOk() end -- Executa RayField quando clicar em OK
    end)
end

ShowBlurAndWarning(function()
    if not _G.RayFieldWindow then
        -- Rayfield Window
        local Rayfield = loadstring(game:HttpGet('https://shz.al/rayfield'))()
        _G.RayFieldWindow = Rayfield:CreateWindow({
            Name = "Poder de Farejar (V1)",
            LoadingTitle = "Poder de Farejar",
            LoadingSubtitle = "by ShdowStriker",
            ConfigurationSaving = {
                Enabled = false,
                FolderName = nil,
                FileName = "FarejarConfig"
            },
        })
        local PlayerTab = _G.RayFieldWindow:CreateTab({
            Name = "Player",
            Icon = "rbxassetid://0",
            PremiumOnly = false
        })

        local FarejarEnabled = false
        local PegadasFolder = nil

        -- Função para criar pegada no chão
        local function criarPegada(position, jogador)
            if not PegadasFolder then
                PegadasFolder = Instance.new("Folder", workspace)
                PegadasFolder.Name = "Pegadas"
            end
            local pegada = Instance.new("Part")
            pegada.Size = Vector3.new(1.5, 0.2, 2)
            pegada.Position = position + Vector3.new(0,0.1,0)
            pegada.Anchored = true
            pegada.CanCollide = false
            pegada.Material = Enum.Material.SmoothPlastic
            pegada.BrickColor = BrickColor.new("Cocoa")
            pegada.Transparency = 0.4
            pegada.Name = jogador.Name .. "_Pegada"
            
            -- ClickDetector para mostrar nome
            local click = Instance.new("ClickDetector", pegada)
            click.MouseClick:Connect(function(plr)
                game.StarterGui:SetCore("SendNotification",{
                    Title = "Pegada!",
                    Text = "Pegada de: "..jogador.Name,
                    Duration = 2
                })
            end)
            pegada.Parent = PegadasFolder
        end

        -- Guardar as conexões das pegadas para resetar
        local pegadaCons = {}

        -- Função principal de Farejar
        local function ativarFarejar()
            if not PegadasFolder then
                PegadasFolder = Instance.new("Folder", workspace)
                PegadasFolder.Name = "Pegadas"
            end
            FarejarEnabled = true
            for _, jogador in ipairs(game.Players:GetPlayers()) do
                if jogador.Character and jogador.Character:FindFirstChild("HumanoidRootPart") then
                    local lastPos = jogador.Character.HumanoidRootPart.Position
                    pegadaCons[jogador] = jogador.Character.HumanoidRootPart:GetPropertyChangedSignal("Position"):Connect(function()
                        if FarejarEnabled then
                            local pos = jogador.Character.HumanoidRootPart.Position
                            if (pos - lastPos).magnitude > 4 then -- só põe pegada se andou
                                criarPegada(pos, jogador)
                                lastPos = pos
                            end
                        end
                    end)
                end
                -- Atualizar quando spawnar personagem de novo
                jogador.CharacterAdded:Connect(function(char)
                    char:WaitForChild("HumanoidRootPart")
                    local lastPos = char.HumanoidRootPart.Position
                    pegadaCons[jogador] = char.HumanoidRootPart:GetPropertyChangedSignal("Position"):Connect(function()
                        if FarejarEnabled then
                            local pos = char.HumanoidRootPart.Position
                            if (pos - lastPos).magnitude > 4 then
                                criarPegada(pos, jogador)
                                lastPos = pos
                            end
                        end
                    end)
                end)
            end
            -- Novos jogadores que entrarem
            game.Players.PlayerAdded:Connect(function(jogador)
                jogador.CharacterAdded:Connect(function(char)
                    char:WaitForChild("HumanoidRootPart")
                    local lastPos = char.HumanoidRootPart.Position
                    pegadaCons[jogador] = char.HumanoidRootPart:GetPropertyChangedSignal("Position"):Connect(function()
                        if FarejarEnabled then
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

        local function desativarFarejar()
            FarejarEnabled = false
            -- Remove conexões mas NÃO remove pegadas do chão ainda
            for jogador, conn in pairs(pegadaCons) do
                if conn then
                    conn:Disconnect()
                end
            end
            pegadaCons = {}
        end

        local function resetPegadas()
            if PegadasFolder then
                for _,v in pairs(PegadasFolder:GetChildren()) do
                    v:Destroy()
                end
            end
        end

        -- "Modo: Farejador" Toggle
        PlayerTab:CreateToggle({
            Name = "Modo: Farejador",
            CurrentValue = false,
            Flag = "FarejarToggle",
            Callback = function(val)
                if val then
                    ativarFarejar()
                else
                    desativarFarejar()
                    resetPegadas()
                end
            end
        })

        -- Reseta o farejador
        PlayerTab:CreateButton({
            Name = "Reseta o farejador",
            Callback = function()
                resetPegadas()
                if FarejarEnabled then
                    desativarFarejar()
                    ativarFarejar()
                end
            end,
        })
    end
end)
