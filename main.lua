local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
WindUI:AddTheme({
    Name = "My Theme", -- theme name
    
    Accent = Color3.fromHex("#18181b"),
    Background = Color3.fromHex("#101010"), -- Accent
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Button = Color3.fromHex("#52525b"),
    Icon = Color3.fromHex("#a1a1aa"),
})
WindUI:SetTheme("My Theme")
local Window = WindUI:CreateWindow({
    Title = "INF HUB",
    Icon = "door-open", -- lucide icon
    Author = "by nattawatdev",
    Folder = "InfHub",
    
    -- ↓ This all is Optional. You can remove it.
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    
    -- ↓ Optional. You can remove it.
    --[[ You can set 'rbxassetid://' or video to Background.
        'rbxassetid://':
            Background = "rbxassetid://", -- rbxassetid
        Video:
            Background = "video:YOUR-RAW-LINK-TO-VIDEO.webm", -- video 
    --]]
    
    -- ↓ Optional. You can remove it.
  
    
    --       remove this all, 
    -- !  ↓  if you DON'T need the key system
    KeySystem = { 
       Note = "Key System. With platoboost.",              
        API = {                                                     
            { -- PlatoBoost
                Type = "platoboost",
                ServiceId = 1930, 
                Secret = "92633672-2f11-4637-87fe-6d825b425df7",
            },                                                      
        },                                                          
    },            
        SaveKey = false, -- automatically save and load the key.
        
    },
})