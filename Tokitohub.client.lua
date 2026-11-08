
--========================================--
--              TOKITO HUB
--          AIM SYSTEM VERSION 2
--========================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local Settings = {
    AimAssist = false,
    AutoAimNPC = false,
    Smoothness = 0.15,
    MaxDistance = 150
}

local CurrentTarget = nil

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "TokitoHub"
GUI.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(310, 390)
Main.Position = UDim2.new(0.5, -155, 0.5, -195)
Main.BackgroundColor3 = Color3.fromRGB(18, 12, 30)
Main.Parent = GUI

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(145, 70, 230)
Stroke.Thickness = 2
Stroke.Parent = Main

-- TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 55)
Title.BackgroundColor3 = Color3.fromRGB(40, 20, 65)
Title.Text = "TOKITO HUB"
Title.TextColor3 = Color3.fromRGB(210, 160, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 23
Title.Parent = Main

-- BUTTON CREATOR
local function createButton(name, y, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.85, 0, 0, 42)
    Button.Position = UDim2.new(0.075, 0, 0, y)
    Button.BackgroundColor3 = Color3.fromRGB(80, 40, 125)
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Text = name
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 13
    Button.Parent = Main

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Button

    Button.Activated:Connect(function()
        callback(Button)
    end)

    return Button
end

local function updateButton(button, title, enabled)
    button.Text = title .. (enabled and " : ON" or " : OFF")
    button.BackgroundColor3 = enabled
        and Color3.fromRGB(130, 65, 200)
        or Color3.fromRGB(80, 40, 125)
end

-- AIM ASSIST
local AimButton = createButton(
    "AIM ASSIST : OFF", 75,
    function(button)
        Settings.AimAssist = not Settings.AimAssist
        updateButton(button, "AIM ASSIST", Settings.AimAssist)
    end
)

-- AUTO AIM NPC
local AutoButton = createButton(
    "AUTO AIM NPC : OFF", 125,
    function(button)
        Settings.AutoAimNPC = not Settings.AutoAimNPC
        updateButton(button, "AUTO AIM NPC", Settings.AutoAimNPC)
    end
)

-- NPC COUNTER
local Counter = Instance.new("TextLabel")
Counter.Size = UDim2.new(1, -20, 0, 30)
Counter.Position = UDim2.new(0, 10, 0, 185)
Counter.BackgroundTransparency = 1
Counter.TextColor3 = Color3.fromRGB(200, 170, 230)
Counter.Text = "NPC: 0"
Counter.Font = Enum.Font.GothamBold
Counter.TextSize = 13
Counter.Parent = Main

-- STATUS
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.new(0, 10, 0, 215)
Status.BackgroundTransparency = 1
Status.Text = "TOKITO HUB READY"
Status.TextColor3 = Color3.fromRGB(190, 150, 230)
Status.TextSize = 12
Status.Font = Enum.Font.GothamBold
Status.Parent = Main

-- NPC LIST
local function getNPCs()
    local Folder = workspace:FindFirstChild("NPCs")
    local List = {}

    if not Folder then
        return List
    end

    for _, NPC in ipairs(Folder:GetChildren()) do
        local Humanoid = NPC:FindFirstChildOfClass("Humanoid")
        local Root = NPC:FindFirstChild("HumanoidRootPart")

        if Humanoid and Root and Humanoid.Health > 0 then
            table.insert(List, NPC)
        end
    end

    return List
end

-- NEAREST NPC
local function getNearestNPC()
    local Character = Player.Character
    if not Character then return nil end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return nil end

    local Nearest = nil
    local Shortest = Settings.MaxDistance

    for _, NPC in ipairs(getNPCs()) do
        local NPCRoot = NPC:FindFirstChild("HumanoidRootPart")

        if NPCRoot then
            local Distance =
                (Root.Position - NPCRoot.Position).Magnitude

            if Distance < Shortest then
                Shortest = Distance
                Nearest = NPC
            end
        end
    end

    return Nearest
end

-- AIM LOOP
RunService:BindToRenderStep(
    "TokitoAim",
    Enum.RenderPriority.Camera.Value + 1,
    function()
        local NPCs = getNPCs()
        Counter.Text = "NPC TERDETEKSI: " .. #NPCs

        if not Settings.AimAssist and not Settings.AutoAimNPC then
            CurrentTarget = nil
            Status.Text = "STATUS: DISABLED"
            return
        end

        CurrentTarget = getNearestNPC()

        if CurrentTarget then
            Status.Text = "TARGET: " .. CurrentTarget.Name
        else
            Status.Text = "TARGET: NOT FOUND"
        end
    end
)

-- CLOSE
createButton("CLOSE HUB", 290, function()
    RunService:UnbindFromRenderStep("TokitoAim")
    GUI:Destroy()
end)

GUI.Parent = Player:WaitForChild("PlayerGui")

print("TOKITO HUB V2 LOADED")
