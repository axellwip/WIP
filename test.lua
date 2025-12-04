local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "AxeeHUB  | Unpublished",
    Icon = "door-open", -- lucide icon. optional
    Author = ".gg/acellzxzz", -- optional
})

local MainTab = Window:Tab({
    Title = "Player Setting",
    Icon = "users", -- optional
    Locked = false,
})

--// Smart Checkpoint Auto Mount Map Runner
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local AutoRunEnabled = false

-- ======= CHECKPOINTS (from your list) =======
local Checkpoints = {
    Vector3.new(-1220, 58.99, -2289),        -- CP0 BASE
    Vector3.new(-892.464844, 158.28302, -812.572815), -- CP1
    Vector3.new(-892.464844, 158.28302, -812.572815), -- CP2
    Vector3.new(-900.464844, 270.292969, 1456.42725), -- CP3
    Vector3.new(-724.958313, 598.292969, 2396.07544), -- CP4
    Vector3.new(321.535156, 598.292969, 3111.42725),  -- CP5
    Vector3.new(1367, 598.292969, 4408),               -- CP6
    Vector3.new(1428.53516, 586.267578, 5427.42725),  -- CP7
    Vector3.new(418.197601, 638.292969, 5973.42725),  -- CP8
    Vector3.new(-188.464844, 638.267578, 7086.42725), -- CP9
    Vector3.new(-518.464844, 682.218567, 8365.42773), -- CP10
    Vector3.new(-392.464844, 594.292969, 10043.4277), -- CP11
    Vector3.new(1164.53516, 594.292969, 10064.4277),  -- CP12
    Vector3.new(1156.03418, 610.292969, 11704.9287),  -- CP13
    Vector3.new(1140.57349, 610.292969, 12819.7637),  -- CP14
    Vector3.new(1110.77124, 594.292969, 14978.4355),  -- CP15
    Vector3.new(1122.77124, 614.879089, 16906.4355),  -- CP16
    Vector3.new(1122.77124, 614.879089, 18728.4355),  -- CP17
    Vector3.new(1289.77124, 614.879089, 20622.4355),  -- CP18
    Vector3.new(2682.77124, 614.879089, 20616.4355),  -- CP19
    Vector3.new(5082.77148, 614.879089, 20437.4355),  -- CP20
    Vector3.new(5077.77148, 614.879089, 18665.4355),  -- CP21
    Vector3.new(4970.77148, 614.879089, 16140.4355),  -- CP22
    Vector3.new(3580.28638, 614.292969, 14776.9863),  -- CP23
    Vector3.new(3581.56641, 906.292969, 13676.2305),  -- CP24
    Vector3.new(3679.29541, 1270.29297, 12388.0117),  -- CP25
    Vector3.new(4706.30029, 1278.29297, 11691.0098),  -- CP26
    Vector3.new(3852.73438, 1693.01013, 10565.2842),  -- SUMMIT
}

local CurrentCheckpoint = 1
local Humanoid, Root, Mount = nil, nil, nil

-- Update character/mount references
local function UpdateCharacter()
    local char = LocalPlayer.Character
    if char then
        Humanoid = char:FindFirstChildOfClass("Humanoid")
        Root = char:FindFirstChild("HumanoidRootPart")
        Mount = char:FindFirstChildWhichIsA("VehicleSeat") or char:FindFirstChild("MountSeat")
    end
end

-- Detect obstacles in path
local function DetectObstacle(distance)
    if not Root then return false end
    local origin = Root.Position + Vector3.new(0,2,0)
    local dir = (Checkpoints[CurrentCheckpoint] - Root.Position).Unit * distance
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local hit = workspace:Raycast(origin, dir, params)
    return hit
end

-- Detect gap in path
local function DetectGap(distance)
    if not Root then return false end
    local origin = Root.Position + (Checkpoints[CurrentCheckpoint] - Root.Position).Unit * distance
    local dir = Vector3.new(0,-6,0)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local hit = workspace:Raycast(origin, dir, params)
    return not hit
end

-- Move to checkpoint safely
local function MoveToCheckpoint(target)
    if not Root then return end
    local direction = (target - Root.Position)
    local distance = direction.Magnitude
    direction = direction.Unit

    local obstacle = DetectObstacle(4)
    local gap = DetectGap(4)

    if Mount and Mount:IsA("VehicleSeat") then
        if not gap then
            Mount.Throttle = 1
            if obstacle and Mount:FindFirstChild("Jump") then
                Mount.Jump = true
            end
        else
            Mount.Throttle = 0
        end
    elseif Humanoid then
        if not gap then
            Humanoid:Move(direction, true)
            if obstacle and Humanoid.FloorMaterial ~= Enum.Material.Air then
                Humanoid.Jump = true
            end
        else
            Humanoid.WalkSpeed = 0
        end
    end

    if distance < 3 then
        CurrentCheckpoint = CurrentCheckpoint + 1
        if CurrentCheckpoint > #Checkpoints then
            CurrentCheckpoint = #Checkpoints
            AutoRunEnabled = false
        end
    end
end

-- Auto-run loop
RunService.RenderStepped:Connect(function()
    if not AutoRunEnabled then return end
    UpdateCharacter()
    if Root then
        MoveToCheckpoint(Checkpoints[CurrentCheckpoint])
    end
end)

-- UI toggle
local Toggle = MainTab:Toggle({
    Title = "Auto Run Mount",
    Desc = "Automatically run mount map using smart checkpoints",
    Icon = "run",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoRunEnabled = state
        if state then CurrentCheckpoint = 1 end
    end
})