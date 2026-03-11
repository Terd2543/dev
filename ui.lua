local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// คอนฟิกหลัก
local Config = {
    Enabled = false,
    FOV = 150,
    MaxDistance = 1500,
    Prediction = 0.165
}

--// Drawing Setup (แก้วง FOV ให้เป็นแค่เส้นขอบ)
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Filled = false -- บังคับให้ไม่เป็นวงทึบ
fovCircle.Transparency = 1
fovCircle.Visible = false

--// ฟังก์ชันหาเป้าหมาย
local function GetClosestTarget()
    local closest = nil
    local shortest = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local distFromMe = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
            
            if distFromMe <= Config.MaxDistance then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist <= Config.FOV and dist < shortest then
                        shortest = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

--// UI Setup
local Window = WindUI:CreateWindow({
    Title = "INF HUB",
    Icon = "crosshair",
    Author = "by nattawatdev",
    Folder = "InfHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    
    --// แก้ไขส่วน Key System ให้ไม่ Save และเด้งทุกรอบ
    KeySystem = true,
    KeySettings = {
        Title = "Key System",
        Note = "Get key from Platoboost (No Save)",
        SaveKey = false, -- ปิดการจำคีย์ บังคับใส่ทุกครั้งที่รัน
        API = {
            {
                
            }
        },
        OnFinished = function()
            --// ระบบแฮกจะเริ่มทำงานเมื่อผ่าน Key
            local send = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Send")
            local oldFire
            oldFire = hookfunction(send.FireServer, function(self, ...)
                local args = {...}
                if Config.Enabled then
                    local target = GetClosestTarget()
                    if target and target.Character then
                        local tr = target.Character:FindFirstChild("HumanoidRootPart")
                        if tr then
                            local aimPos = tr.Position + (tr.Velocity * Config.Prediction)
                            args[4] = CFrame.new(1/0, 1/0, 1/0, 0/0, 0/0, 0/0, 0/0, 0/0, 0/0, 0/0, 0/0, 0/0)
                            args[5] = {[1] = {[1] = {["Instance"] = tr, ["Position"] = aimPos}}}
                        end
                    end
                end
                return oldFire(self, unpack(args))
            end)
        end
    }
})

--// สร้าง Tabs
local MainTab = Window:Tab({ Title = "Combat", Icon = "target" })
MainTab:Section({ Title = "Silent Aim Settings" })

MainTab:Toggle({
    Title = "Enable Silent Aim",
    Default = false,
    Callback = function(v)
        Config.Enabled = v
        fovCircle.Visible = v
    end
})

MainTab:Input({
    Title = "FOV Size",
    Placeholder = "Current: " .. tostring(Config.FOV),
    Callback = function(v)
        local n = tonumber(v)
        if n then 
            Config.FOV = n 
            fovCircle.Radius = n
        end
    end
})

MainTab:Input({
    Title = "Max Distance",
    Placeholder = "Current: " .. tostring(Config.MaxDistance),
    Callback = function(v)
        local n = tonumber(v)
        if n then Config.MaxDistance = n end
    end
})

--// Loop อัปเดตวงกลม (ป้องกันวงทึบขาวบังจอ)
RunService.RenderStepped:Connect(function()
    if Config.Enabled then
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Radius = Config.FOV
        -- ย้ำอีกรอบใน Loop ว่าห้ามทึบ
        fovCircle.Filled = false
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end)