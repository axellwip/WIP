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


--// Fully Working CFrame Checkpoint Mount Runner
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local AutoRunEnabled = false
local Speed = 70 -- studs per second, adjust as needed
local CurrentCheckpoint = 1

-- ====== Checkpoints (your CP0 → CP26 + SUMMIT) ======
local Checkpoints = {
    Vector3.new(-1220, 58.99, -2289),
    Vector3.new(-892.464844, 158.28302, -812.572815),
    Vector3.new(-892.464844, 158.28302, -812.572815),
    Vector3.new(-900.464844, 270.292969, 1456.42725),
    Vector3.new(-724.958313, 598.292969, 2396.07544),
    Vector3.new(321.535156, 598.292969, 3111.42725),
    Vector3.new(1367, 598.292969, 4408),
    Vector3.new(1428.53516, 586.267578, 5427.42725),
    Vector3.new(418.197601, 638.292969, 5973.42725),
    Vector3.new(-188.464844, 638.267578, 7086.42725),
    Vector3.new(-518.464844, 682.218567, 8365.42773),
    Vector3.new(-392.464844, 594.292969, 10043.4277),
    Vector3.new(1164.53516, 594.292969, 10064.4277),
    Vector3.new(1156.03418, 610.292969, 11704.9287),
    Vector3.new(1140.57349, 610.292969, 12819.7637),
    Vector3.new(1110.77124, 594.292969, 14978.4355),
    Vector3.new(1122.77124, 614.879089, 16906.4355),
    Vector3.new(1122.77124, 614.879089, 18728.4355),
    Vector3.new(1289.77124, 614.879089, 20622.4355),
    Vector3.new(2682.77124, 614.879089, 20616.4355),
    Vector3.new(5082.77148, 614.879089, 20437.4355),
    Vector3.new(5077.77148, 614.879089, 18665.4355),
    Vector3.new(4970.77148, 614.879089, 16140.4355),
    Vector3.new(3580.28638, 614.292969, 14776.9863),
    Vector3.new(3581.56641, 906.292969, 13676.2305),
    Vector3.new(3679.29541, 1270.29297, 12388.0117),
    Vector3.new(4706.30029, 1278.29297, 11691.0098),
    Vector3.new(3852.73438, 1693.01013, 10565.2842),
}

-- Update character/mount references
local function UpdateCharacter()
    local char = LocalPlayer.Character
    if char then
        Humanoid = char:FindFirstChildOfClass("Humanoid")
        Root = char:FindFirstChild("HumanoidRootPart")
        Mount = char:FindFirstChildWhichIsA("VehicleSeat") or char:FindFirstChild("MountSeat")
    end
end

-- Detect obstacles using forward raycast
local function DetectObstacle()
    if not Root then return false end
    local origin = Root.Position + Vector3.new(0,2,0)
    local dir = (Checkpoints[CurrentCheckpoint] - Root.Position).Unit * 6
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local hit = workspace:Raycast(origin, dir, params)
    return hit
end

-- Detect gap using downward raycast
local function DetectGap()
    if not Root then return false end
    local origin = Root.Position + (Checkpoints[CurrentCheckpoint] - Root.Position).Unit * 2
    local dir = Vector3.new(0,-6,0)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local hit = workspace:Raycast(origin, dir, params)
    return not hit
end

-- Move toward checkpoint using CFrame lerp
local function MoveToCheckpoint()
    if not Root then return end
    local target = Checkpoints[CurrentCheckpoint]
    if not target then return end

    local obstacle = DetectObstacle()
    local gap = DetectGap()

    -- Jump if obstacle detected
    if Humanoid and obstacle and Humanoid.FloorMaterial ~= Enum.Material.Air then
        Humanoid.Jump = true
    elseif Mount and Mount:FindFirstChild("Jump") and obstacle then
        Mount.Jump = true
    end

    -- Stop if gap detected
    if gap then return end

    -- Move via CFrame lerp
    local direction = (target - Root.Position)
    local distance = direction.Magnitude
    if distance > 2 then
        local step = direction.Unit * Speed * RunService.RenderStepped:Wait()
        Root.CFrame = Root.CFrame + step
    else
        CurrentCheckpoint = CurrentCheckpoint + 1
        if CurrentCheckpoint > #Checkpoints then
            AutoRunEnabled = false -- stop at summit
        end
    end
end

-- Run loop
RunService.RenderStepped:Connect(function()
    if AutoRunEnabled then
        UpdateCharacter()
        if Root then
            MoveToCheckpoint()
        end
    end
end)

-- UI toggle
local Toggle = MainTab:Toggle({
    Title = "Auto Run Mount",
    Desc = "CFrame-based smart checkpoint runner",
    Icon = "run",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        AutoRunEnabled = state
        if state then CurrentCheckpoint = 1 end
    end
})