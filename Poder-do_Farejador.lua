local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Poder do Fursono",
   LoadingTitle = "Iniciando Instinto Animal...",
   LoadingSubtitle = "by ShadowStriker",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "FursonoScript",
      FileName = "ShadowStriker_Hub"
   }
})

-- Variáveis de Controle
local FarejamentoAtivo = false
local PegadasFolder = Instance.new("Folder", workspace)
PegadasFolder.Name = "Rastros_Fursono"

-- Função para Criar Pegada
local function CriarPegada(player, position)
    if not FarejamentoAtivo then return end
    
    local pegada = Instance.new("Part")
    pegada.Name = "Pegada_" .. player.Name
    pegada.Size = Vector3.new(1, 0.2, 1)
    pegada.Position = position - Vector3.new(0, 2.5, 0) -- Ajusta para o chão
    pegada.Anchored = true
    pegada.CanCollide = false
    pegada.Transparency = 0.5
    pegada.Color = Color3.fromRGB(255, 100, 0) -- Cor de rastro
    pegada.Parent = PegadasFolder
    
    -- Efeito visual de pegada (pode ser um círculo)
    local mesh = Instance.new("CylinderMesh", pegada)
    
    -- ClickDetector para ver o nome
    local click = Instance.new("ClickDetector", pegada)
    click.MouseClick:Connect(function()
        Rayfield:Notify({
            Title = "Alvo Identificado",
            Content = "Este rastro pertence a: " .. player.Name,
            Duration = 3,
            Image = 4483362458,
        })
    end)
end

-- Loop de Farejamento
task.spawn(function()
    while true do
        if FarejamentoAtivo then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = player.Character.HumanoidRootPart.Position
                    CriarPegada(player, pos)
                end
            end
        end
        task.wait(0.5) -- Intervalo para não lagar o jogo
    end
end)

-- Interface
local Tab = Window:CreateTab("Principal", 4483362458)

Tab:CreateToggle({
   Name = "Farejar",
   CurrentValue = false,
   Flag = "FarejarToggle",
   Callback = function(Value)
      FarejamentoAtivo = Value
      if not Value then
          PegadasFolder:ClearAllChildren()
          Rayfield:Notify({
             Title = "Instinto Desativado",
             Content = "As pegadas sumiram.",
             Duration = 2,
          })
      else
          Rayfield:Notify({
             Title = "Instinto Ativado",
             Content = "Você agora sente o cheiro dos outros jogadores!",
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
         Title = "Resetado",
         Content = "Todos os rastros antigos foram limpos.",
         Duration = 2,
      })
   end,
})

Rayfield:LoadConfiguration()
