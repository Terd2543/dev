local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SilentAimEnabled = true
local FOV = 150
local CurrentTarget
local targetRoot, aimPos

local GunNames = {
    "P226","MP5","M24","Draco","Glock","Sawnoff","Uzi","G3","C9",
    "Hunting Rifle","Anaconda","AK47","Remington","Double Barrel"
}
local GunLookup = {}
for _, name in pairs(GunNames) do GunLookup[name] = true end

local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.new(1,1,1)
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Radius = FOV
fovCircle.Filled = false
fovCircle.Visible = true

--// Prediction Settings
local PREDICTION_FACTOR = 0.165

local function GetClosestTarget()
    local closest
    local shortest = math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < FOV and dist < shortest then
                    shortest = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

--// Prediction สำหรับ HumanoidRootPart (รองรับ เดิน วิ่ง กระโดด รถ)
local function PredictPosition(rootPart)
    if not rootPart then return Vector3.new(0,0,0) end
    
    local velocity = rootPart.Velocity
    local prediction = rootPart.Position + (velocity * PREDICTION_FACTOR)
    
    -- รองรับรถ
    local seat = rootPart:FindFirstChildWhichIsA("WeldConstraint") or rootPart:FindFirstChildWhichIsA("Weld")
    if seat and seat.Part0 then
        prediction = rootPart.Position + (seat.Part0.Velocity * PREDICTION_FACTOR * 1.2)
    end
    
    return prediction
end

local function IsHoldingAllowedGun(args)
    local ok, weapon = pcall(function() return args[3] end)
    if not ok then return false end
    if typeof(weapon) == "Instance" and GunLookup[weapon.Name] then
        return true
    end
    for _, child in pairs(LocalPlayer.Character:GetChildren()) do
        if (child:IsA("Tool") or child:IsA("Model")) and GunLookup[child.Name] then
            return true
        end
    end
    return false
end

local send = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Send")
local oldFire
oldFire = hookfunction(send.FireServer, function(self, ...)
    local args = {...}
    if SilentAimEnabled and IsHoldingAllowedGun(args) then
        CurrentTarget = GetClosestTarget()
        if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
            targetRoot = CurrentTarget.Character.HumanoidRootPart
            aimPos = PredictPosition(targetRoot)  -- ยิง Hamanoi + Prediction
            
            -- ส่งไปที่ Hamanoi แทน Head
            args[4] = CFrame.new(1/0,1/0,1/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0,0/0)
            args[5] = {[1]={[1]={["Instance"]=targetRoot, ["Position"]=aimPos}}}
        end
    end
    return oldFire(self, unpack(args))
end)

-- Tracer ชี้ Hamanoi เหมือนกัน
local tracerLine = Drawing.new("Line")
tracerLine.Color = Color3.new(1,0,0)
tracerLine.Thickness = 2
tracerLine.Visible = false

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Radius = FOV
    
    local target = GetClosestTarget()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local predictedPos = PredictPosition(target.Character.HumanoidRootPart)
        local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
        
        if onScreen then
            local ourHeadPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character.Head.Position
            if ourHeadPos then
                local screenStart, _ = Camera:WorldToViewportPoint(ourHeadPos)
                tracerLine.From = Vector2.new(screenStart.X, screenStart.Y)
                tracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
                tracerLine.Visible = true
            end
        else
            tracerLine.Visible = false
        end
    else
        tracerLine.Visible = false
    end
end)