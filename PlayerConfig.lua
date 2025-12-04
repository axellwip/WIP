local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "AxeeHUB  | Unpublished",
    Icon = "door-open",
    Author = ".gg/acellzxzz",
})

local MainTab = Window:Tab({
    Title = "Player Settings",
    Icon = "users",
    Locked = false,
})

------ PLAYER CONFIGURATION --------
  
-- === REQUIRED SERVICES ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Player reference
local player = Players.LocalPlayer

-- Helper: get fresh humanoid
local function GetHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

-- === INFINITE JUMP CORE === --

local InfiniteJumpEnabled = false
local JumpConnection = nil

local function EnableInfiniteJump()
    if JumpConnection then JumpConnection:Disconnect() end
    
    JumpConnection = UserInputService.JumpRequest:Connect(function()
        if InfiniteJumpEnabled then
            local humanoid = GetHumanoid()
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function DisableInfiniteJump()
    InfiniteJumpEnabled = false
    if JumpConnection then
        JumpConnection:Disconnect()
        JumpConnection = nil
    end
end


-- === UI TOGGLE ===
local InfToggle = MainTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Let's Jumping Bro!",
    Icon = "equal-not",
    Type = "Toggle",
    Value = false,
    Callback = function(state)
        InfiniteJumpEnabled = state

        if state then
            EnableInfiniteJump()
        else
            DisableInfiniteJump()
        end
    end
})

-- === WALKSPEED CORE === --
local WalkSpeedSlider = MainTab:Slider({
    Title = "WalkSpeed",
    Desc = "Adjust Player Movement Speed",
    Step = 1,
    Value = {
        Min = 16,
        Max = 200,
        Default = 16,
    },
    Callback = function(value)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

-- Auto reapply after respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = WalkSpeedSlider.Value.Default
    end
end)

-- === JUMP POWER CORE === --

-- JumpPower Slider
local JumpPowerSlider = MainTab:Slider({
    Title = "Jump Power",
    Desc = "Adjust Player Jump Strength",
    Step = 1,
    Value = {
        Min = 50,
        Max = 200,
        Default = 50,
    },
    Callback = function(value)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = value
        end
    end
})

-- Reapply after respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = JumpPowerSlider.Value.Default
    end
end)

-- === FLY CORE === --

local flying = false
local FlySpeed = 50
local BV, BG

local function StartFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if not root then return end

    BV = Instance.new("BodyVelocity")
    BV.Velocity = Vector3.zero
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BV.Parent = root

    BG = Instance.new("BodyGyro")
    BG.P = 9e4
    BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.Parent = root

    flying = true

    task.spawn(function()
        while flying do
            local cam = workspace.CurrentCamera.CFrame
            BG.CFrame = cam
            
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

            BV.Velocity = move * FlySpeed
            task.wait()
        end
    end)
end

local function StopFly()
    flying = false
    if BV then BV:Destroy() end
    if BG then BG:Destroy() end
end

local FlyToggle = MainTab:Toggle({
    Title = "Fly",
    Desc = "Toggle Fly Mode",
    Icon = "bird",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            StartFly()
        else
            StopFly()
        end
    end
})