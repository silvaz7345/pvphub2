--// SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// CONFIG
local AimlockEnabled = false
local ESPEnabled = false
local AimPart = "Head"
local AimRadius = 250

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "PvPHub"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 220)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35,35,35)
Title.Text = "PvP Hub (Privado)"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- Botão Fechar
local CloseBtn = Instance.new("TextButton", Title)
CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)

-- Botão Ocultar
local HideBtn = Instance.new("TextButton", Title)
HideBtn.Size = UDim2.new(0, 35, 1, 0)
HideBtn.Position = UDim2.new(1, -70, 0, 0)
HideBtn.Text = "-"
HideBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)

-- Container
local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 0, 0, 35)
Content.Size = UDim2.new(1, 0, 1, -35)
Content.BackgroundTransparency = 1

-- Função botão toggle
local function CreateToggle(text, posY, callback)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.new(1,1,1)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

-- Toggles
CreateToggle("Aimlock", 10, function(v)
    AimlockEnabled = v
end)

CreateToggle("ESP", 55, function(v)
    ESPEnabled = v
end)

--// FUNÇÕES

-- Aimlock simples
local function GetClosestPlayer()
    local closest, dist = nil, AimRadius
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(AimPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character[AimPart].Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < dist then
                    dist = mag
                    closest = plr
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if AimlockEnabled then
        local target = GetClosestPlayer()
        if target and target.Character then
            Camera.CFrame = CFrame.new(
                Camera.CFrame.Position,
                target.Character[AimPart].Position
            )
        end
    end
end)

-- ESP usando Highlight
local Highlights = {}

local function UpdateESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if ESPEnabled and not Highlights[plr] then
                local hl = Instance.new("Highlight", plr.Character)
                hl.FillColor = Color3.fromRGB(255,0,0)
                hl.OutlineColor = Color3.new(1,1,1)
                Highlights[plr] = hl
            elseif not ESPEnabled and Highlights[plr] then
                Highlights[plr]:Destroy()
                Highlights[plr] = nil
            end
        end
    end
end

RunService.Heartbeat:Connect(UpdateESP)

--// BOTÕES
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

HideBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
end)
