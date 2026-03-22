local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🐾 Poder do Furry (V1)",
   LoadingTitle = "Despertando Instintos...",
   LoadingSubtitle = "by ShadowStriker",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "PoderFurryV1",
      FileName = "ShadowStriker_Config"
   }
})

-- // Variáveis de Controle // --
local FarejamentoAtivo = false
local PegadasFolder = workspace:FindFirstChild("Rastros_Furry") or Instance.new("Folder", workspace)
PegadasFolder.Name = "Rastros_Furry"

-- // Função para Gerar Pegadas // --
local function CriarPegada(player, position)
    if not FarejamentoAtivo or not player.Character then return end
    
    local pegada = Instance.new("Part")
    pegada.Name = player.Name -- Guarda o nome do dono na peça
    pegada.Size = Vector3.new(1.2, 0.2, 1.2)
    pegada.Position = position - Vector3.new(0, 2.8, 0) -- Ajusta para o nível do chão
    pegada.Anchored = true
    pegada.CanCollide = false
    pegada.Transparency = 0.6
    pegada.Color = Color3.fromRGB(150, 50, 255) -- Cor roxa neon para o instinto
    pegada.Material = Enum.Material.Neon
    pegada.Parent = PegadasFolder
    
    -- Deixa a pegada redonda
    local mesh = Instance.new("CylinderMesh", pegada)
    
    -- Detector de Clique para identificar o dono
    local click = Instance.new("ClickDetector", pegada)
    click.MouseClick:Connect(function()
        Rayfield:Notify({
            Title = "🐾 Rastro Identificado",
            Content = "Este rastro pertence ao jogador: " .. player.Name,
            Duration = 3,
            Image = 4483362458,
        })
    end)
end

-- // Loop de Detecção (Roda em Segundo Plano) // --
task.spawn(function()
    while true do
        if FarejamentoAtivo then
            for _, player in pairs(game.Players:GetPlayers()) do
                -- Não rastrear a si mesmo, apenas os outros
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    -- Só cria pegada se o jogador estiver se movendo
                    if hrp.AssemblyLinearVelocity.Magnitude > 2 then
                        CriarPegada(player, hrp.Position)
                    end
                end
            end
        end
        task.wait(0.6) -- Otimização para não pesar o jogo
    end
end)

-- // Interface de Usuário // --
local Tab = Window:CreateTab("Instintos", 4483362458)

Tab:CreateSection("Capacidades Sensoriais")

Tab:CreateToggle({
   Name = "Farejar",
   CurrentValue = false,
   Flag = "FarejarToggle",
   Callback = function(Value)
      FarejamentoAtivo = Value
      if not Value then
          PegadasFolder:ClearAllChildren() -- Limpa tudo ao desativar
          Rayfield:Notify({
             Title = "Sentidos Ocultos",
             Content = "As pegadas sumiram da sua visão.",
             Duration = 2,
          })
      else
          Rayfield:Notify({
             Title = "Olfato Aguçado",
             Content = "Você começou a farejar rastros próximos!",
             Duration = 2,
          })
      end
   end,
})

Tab:CreateButton({
   Name = "Resetar o farejamento",
   Callback = function()
      PegadasFolder:ClearAllChildren()
      Rayfield:Notify({
         Title = "Limpeza Concluída",
         Content = "Todos os rastros foram deletados e o farejamento reiniciado.",
         Duration = 2,
      })
   end,
})

Rayfield:LoadConfiguration()
