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


-- === UI TOGGLE === --
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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CurrentSpeed = 16 -- default

local function SetWalkSpeed(value)
    CurrentSpeed = value

    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = value
        end
    end)
end

-- Apply again if player respawns
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    SetWalkSpeed(CurrentSpeed)
end)

-- === UI TOGGLE === --
local Slider = Tab:Slider({
    Title = "Slider",
    Desc = "Slider Description",
    Step = 1,
    Value = {
        Min = 16,
        Max = 150,
        Default = CurrentSpeed,
    },
    Callback = function(value)
        SetWalkSpeed(value)
    end
})

-- Apply default on start
SetWalkSpeed(CurrentSpeed)