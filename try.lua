-- NEZUKO GUI FRAMEWORK
-- Note: Requires the Core Logic script above to be saved as a ModuleScript named 'NezukoHubCoreLogic' 
-- in the same location as this LocalScript, OR adjust the require path.

-- 1. Get the Core Logic Script
local NezukoHub = require(script.Parent:WaitForChild("NezukoHubCoreLogic")) 

-- 2. Theme & Services
local Theme = {
    -- Black/Dark Gray Base
    Background = Color3.fromRGB(15, 15, 15), 
    Header = Color3.fromRGB(25, 25, 25),
    Tab = Color3.fromRGB(30, 30, 30),
    ComponentBg = Color3.fromRGB(40, 40, 40),
    
    -- Primary Accent: Nezuko Yellow
    Accent = Color3.fromRGB(255, 225, 0), 
    Text = Color3.fromRGB(255, 255, 255)
}
local Player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local UI = {} -- Renaming the library from Rayfield to UI

-- 3. Core Framework Functions

function UI:CreateWindow()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NezukoHubUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 330)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -165)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Corner for MainFrame
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Theme.Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    -- Corner for Header (to blend with MainFrame)
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header
    
    local Title = Instance.new("TextLabel")
    Title.Text = "🌸 NEZUKO HUB"
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Theme.Accent -- Use Accent color for title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- Close/Minimize Logic (Standard)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0, 30, 0, 25)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -12)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red for close
    CloseButton.TextColor3 = Theme.Text
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    CloseButton.Parent = Header

    CloseButton.MouseButton1Click:Connect(function()
        NezukoHub.ToggleAutoFish(false)
        NezukoHub.ToggleAutoSell(false)
        ScreenGui:Destroy()
    end)
    
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, -10, 1, -45)
    TabFrame.Position = UDim2.new(0, 5, 0, 40)
    TabFrame.BackgroundColor3 = Theme.Tab
    TabFrame.BorderSizePixel = 0
    TabFrame.Parent = MainFrame
    
    -- Tab Frame Container and Content Setup
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 0, 30)
    TabContainer.Position = UDim2.new(0, 0, 0, 0)
    TabContainer.BackgroundColor3 = Theme.Header
    TabContainer.Parent = TabFrame
    
    local TabContent = {} 
    local Tabs = {}
    local tabCount = 0

    local function updateTabs(activeTab)
        for name, frame in pairs(TabContent) do
            local button = TabContainer:FindFirstChild(name .. "Button")
            
            frame.Visible = (name == activeTab)
            
            if button then
                -- Highlight active tab with Accent color
                button.BackgroundColor3 = (name == activeTab) and Theme.Accent or Theme.Header
                button.TextColor3 = (name == activeTab) and Theme.Background or Color3.fromRGB(180, 180, 180) -- Text is black/dark on yellow
            end
        end
    end

    function Tabs:CreateTab(tabName)
        tabCount = tabCount + 1
        local Components = {}
        local yOffset = 10
        
        local ContentFrame = Instance.new("Frame")
        ContentFrame.Name = tabName .. "Content"
        ContentFrame.Size = UDim2.new(1, 0, 1, -30)
        ContentFrame.Position = UDim2.new(0, 0, 0, 30)
        ContentFrame.BackgroundColor3 = Theme.Tab
        ContentFrame.BorderSizePixel = 0
        ContentFrame.Parent = TabFrame
        ContentFrame.Visible = false
        
        TabContent[tabName] = ContentFrame

        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Text = "📁 " .. tabName
        SectionTitle.Size = UDim2.new(1, 0, 0, 25)
        SectionTitle.Position = UDim2.new(0, 0, 0, yOffset)
        SectionTitle.TextColor3 = Theme.Accent -- Use Accent color for section header
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.TextSize = 16
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Parent = ContentFrame

        yOffset = yOffset + 30
        
        -- Create/Recalculate Tab Buttons
        local totalWidth = TabContainer.AbsoluteSize.X or 500
        local currentX = 0
        for name, frame in pairs(TabContent) do
            local button = TabContainer:FindFirstChild(name .. "Button")
            if not button then
                button = Instance.new("TextButton")
                button.Name = name .. "Button"
                button.Font = Enum.Font.GothamBold
                button.TextSize = 14
                button.TextColor3 = Color3.fromRGB(180, 180, 180)
                button.Parent = TabContainer
                button.Text = name
                
                button.MouseButton1Click:Connect(function()
                    updateTabs(name)
                end)
            end
            
            local newSizeX = 1 / tabCount 
            button.Size = UDim2.new(newSizeX, 0, 1, 0)
            button.Position = UDim2.new(currentX, 0, 0, 0)
            currentX = currentX + newSizeX -- Use UDim for smooth resizing
        end
        

        -- Component: CreateToggle (WITH ANIMATION)
        function Components:CreateToggle(info)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(0, 480, 0, 30)
            ToggleFrame.Position = UDim2.new(0, 20, 0, yOffset)
            ToggleFrame.BackgroundColor3 = Theme.ComponentBg
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = ContentFrame
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 4)
            Corner.Parent = ToggleFrame
            
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Text = info.Name or "Toggle"
            NameLabel.Size = UDim2.new(0.8, 0, 1, 0)
            NameLabel.Position = UDim2.new(0, 10, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.TextColor3 = Theme.Text
            NameLabel.Font = Enum.Font.Gotham
            NameLabel.TextSize = 14
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = ToggleFrame
            
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(0, 40, 0, 20)
            Track.Position = UDim2.new(1, -50, 0, 5)
            Track.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Off Gray
            Track.BorderSizePixel = 0
            Track.ClipsDescendants = true
            Track.Parent = ToggleFrame
            
            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = Track

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 16, 0, 16)
            Knob.Position = UDim2.new(0, 2, 0, 2)
            Knob.BackgroundColor3 = Theme.Text -- White knob
            Knob.BorderSizePixel = 0
            Knob.Parent = Track
            
            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = Knob

            local active = info.Default or false
            local info_tween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            local function updateToggle(state)
                active = state
                
                if active then
                    TweenService:Create(Track, info_tween, {BackgroundColor3 = Theme.Accent}):Play()
                    TweenService:Create(Knob, info_tween, {Position = UDim2.new(1, -18, 0, 2)}):Play()
                else
                    TweenService:Create(Track, info_tween, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
                    TweenService:Create(Knob, info_tween, {Position = UDim2.new(0, 2, 0, 2)}):Play()
                end
            end

            updateToggle(active) -- Initial state

            local ClickableButton = Instance.new("TextButton")
            ClickableButton.Size = UDim2.new(1, 0, 1, 0)
            ClickableButton.BackgroundTransparency = 1
            ClickableButton.Text = ""
            ClickableButton.Parent = ToggleFrame

            ClickableButton.MouseButton1Click:Connect(function()
                updateToggle(not active)
                if info.Callback then
                    pcall(info.Callback, active)
                end
            end)
            
            yOffset = yOffset + 40
        end
        
        -- Component: CreateTeleportList (unchanged logic)
        function Components:CreateTeleportList(destinations)
            local ScrollFrame = Instance.new("ScrollingFrame")
            ScrollFrame.Size = UDim2.new(1, -20, 1, -yOffset - 10) 
            ScrollFrame.Position = UDim2.new(0, 10, 0, yOffset)
            ScrollFrame.BackgroundColor3 = Theme.ComponentBg
            ScrollFrame.BorderSizePixel = 0
            ScrollFrame.Parent = ContentFrame
            ScrollFrame.ScrollBarImageColor3 = Theme.Accent
            ScrollFrame.ScrollBarThickness = 6
            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 

            local internalYOffset = 10
            local buttonWidth = 226
            local xPos1 = 10
            local xPos2 = xPos1 + buttonWidth + 10
            local buttonHeight = 30
            local padding = 10
            
            -- ... Label and Button creation ...
            local Label = Instance.new("TextLabel")
            Label.Text = "Click a destination to teleport instantly:"
            Label.Size = UDim2.new(1, -20, 0, 20) 
            Label.Position = UDim2.new(0, 10, 0, internalYOffset)
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.BackgroundTransparency = 1
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ScrollFrame
            internalYOffset = internalYOffset + 30
            
            for i, data in ipairs(destinations) do
                local name = data[1]
                local position = data[2]
                
                local row = math.floor((i - 1) / 2)
                local ButtonYPos = (row * (buttonHeight + padding)) + internalYOffset

                local xPos = (i % 2) == 1 and xPos1 or xPos2
                
                local TeleButton = Instance.new("TextButton")
                TeleButton.Size = UDim2.new(0, buttonWidth, 0, buttonHeight) 
                TeleButton.Position = UDim2.new(0, xPos, 0, ButtonYPos)
                TeleButton.BackgroundColor3 = Theme.ComponentBg 
                TeleButton.TextColor3 = Theme.Accent -- Use Accent for button text
                TeleButton.Font = Enum.Font.GothamBold
                TeleButton.TextSize = 12
                TeleButton.Text = name
                TeleButton.Parent = ScrollFrame

                TeleButton.MouseButton1Click:Connect(function()
                    task.spawn(function()
                        NezukoHub:ExecuteTeleport(name, position) 
                    end)
                end)
            end
            
            local totalButtons = #destinations
            local numRows = math.ceil(totalButtons / 2)
            local totalCanvasHeight = internalYOffset + (numRows * (buttonHeight + padding)) + 10
            
            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalCanvasHeight)
        end

        return Components
    end

    -- Export necessary functions for external use
    UI.updateTabs = updateTabs
    return Tabs

end

-- 4. Final Usage (The Glue)

local Window = UI:CreateWindow()

-- Create the tabs
local HomeTab = Window:CreateTab("🏠 HOME")
local TeleportTab = Window:CreateTab("🚀 WARP")

-- --- Home Tab Components ---
HomeTab:CreateToggle({
    Name = "Auto Fishing",
    Callback = NezukoHub.ToggleAutoFish 
})

HomeTab:CreateToggle({
    Name = "Auto Sell (Every 5 Mins)",
    Callback = NezukoHub.ToggleAutoSell 
})

-- --- Teleport Tab Components ---
TeleportTab:CreateTeleportList(NezukoHub.TELEPORT_DESTINATIONS)

-- ✅ Set the first tab active
UI.updateTabs("🏠 HOME")

-- CORE GAME SCRIPT LOGIC (Nezuko Hub)
local NezukoHub = {}

-- Global Variables for Auto Fish & Sell
local autoFishThread = nil
local autoSellThread = nil
local FISHING_CYCLE_DELAY = 1
local SELL_LOOP_DELAY = 300 -- 5 minutes (5 * 60 = 300 seconds)
local isSelling = false -- 🛑 ESSENTIAL SAFETY FLAG

-- Global Coordinates (CHECK THESE IF MOVEMENT FAILS)
local START_ZONE_POS = Vector3.new(86, 10, 2742)
local MIDDLE_STAGING_POS = Vector3.new(98, 17, 2844)
local TARGET_SELL_POS = Vector3.new(48, 17, 2869)
local TARGET_WATER_POS = Vector3.new(80.7, 10, 2742.85)

-- Global References for Roblox Services
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- 🗺️ Global Teleport Destinations
NezukoHub.TELEPORT_DESTINATIONS = {
    {"Tropical Grove", Vector3.new(-2062, 53, 3751)},
    {"Coral Reefs", Vector3.new(-2847, 47, 2010)},
    {"Weather Machine", Vector3.new(-1523, 6, 1899)},
    {"Kohana Volcano", Vector3.new(-711, 56, 181)},
    {"Kohana", Vector3.new(-639, 16, 618)},
    {"Ancient Jungle", Vector3.new(1275, 8, -193)},
    {"Esoteric Depths", Vector3.new(2100, -28, 1358)},
    {"Mount Hallow", Vector3.new(1854, 23, 3085)},
    {"Crater Island", Vector3.new(979, 30, 4955)},
    {"Fisherman Island", Vector3.new(33, 17, 2847)},
    {"Lost Isle", Vector3.new(-3676, 5, -1055)},
}

-- Remote/Bindable References
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net") 

-- Fishing Remotes (Ensure these paths are correct for your game!)
local EquipTool = netFolder:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local StartMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local FishingDone = netFolder:WaitForChild("RE/FishingCompleted")
local SELL_REMOTE = netFolder:WaitForChild("RF/SellAllItems")

-- 🚀 Teleport Core Function
function NezukoHub:ExecuteTeleport(destinationName, position)
    isSelling = true 
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    HumanoidRootPart.CFrame = CFrame.new(position)
    game.StarterGui:SetCore("SendNotification", {Title = "Nezuko Hub", Text = "Teleported to " .. destinationName .. "!", Duration = 2})
    isSelling = false
end

-- 🎣 Auto Fishing Core Function (unchanged)
local function runAutoFishing()
    while task.wait(FISHING_CYCLE_DELAY) do
        if isSelling then task.wait(1); continue end
        EquipTool:FireServer(1)
        task.wait(FISHING_CYCLE_DELAY)
        pcall(ChargeRod:InvokeServer)
        task.wait(0.5)
        local args = {-1.233184814453125, 0.35881824928797157, 1762227624.855859}
        pcall(StartMinigame:InvokeServer, unpack(args))
        task.wait(3)
        FishingDone:FireServer()
        task.wait(FISHING_CYCLE_DELAY)
    end
end

-- 🚶 Auto Sell Single Run Function (Movement and Sell - unchanged)
local function executeSellAction()
    isSelling = true 
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local Humanoid = Character:WaitForChild("Humanoid")
    Humanoid.PlatformStand = false
    task.wait(0.1)

    HumanoidRootPart.CFrame = CFrame.new(START_ZONE_POS)
    task.wait(1)

    Humanoid:MoveTo(MIDDLE_STAGING_POS)
    local movedToMiddle = Humanoid.MoveToFinished:Wait(10)
    if not movedToMiddle then isSelling = false; return end

    Humanoid:MoveTo(TARGET_SELL_POS)
    local movedToSell = Humanoid.MoveToFinished:Wait(5)

    if movedToSell then
        pcall(SELL_REMOTE:InvokeServer)
        task.wait(0.5)
        HumanoidRootPart.CFrame = CFrame.lookAt(START_ZONE_POS, TARGET_WATER_POS)
        game.StarterGui:SetCore("SendNotification", {Title = "Nezuko Hub", Text = "Sell Complete. Returning to Fishing Position.", Duration = 1})
    end

    isSelling = false 
end

-- 🔄 Auto Sell Continuous Loop (unchanged)
local function runAutoSellingLoop()
    while task.wait(SELL_LOOP_DELAY) do
        executeSellAction()
    end
end

-- 📦 Public Functions for the GUI (Connects GUI to game logic)
NezukoHub.ToggleAutoFish = function(is_on)
    if is_on then
        if not autoFishThread then
            autoFishThread = task.spawn(runAutoFishing)
            game.StarterGui:SetCore("SendNotification", {Title = "Nezuko Hub", Text = "Auto Fishing Activated!", Duration = 3})
        end
    else
        if autoFishThread then
            task.cancel(autoFishThread)
            autoFishThread = nil
            game.StarterGui:SetCore("SendNotification", {Title = "Nezuko Hub", Text = "Auto Fishing Disabled!", Duration = 3})
        end
    end
end

NezukoHub.ToggleAutoSell = function(is_on)
    if is_on then
        if not autoSellThread then
            task.spawn(executeSellAction) -- Run immediately
            autoSellThread = task.spawn(runAutoSellingLoop) -- Start the loop
            game.StarterGui:SetCore("SendNotification", {Title = "Nezuko Hub", Text = "Auto Sell Activated! (Interval: 5m)", Duration = 3})
        end
    else
        if autoSellThread then
            task.cancel(autoSellThread)
            autoSellThread = nil
            game.StarterGui:SetCore("SendNotification", {Title = "Nezuko Hub", Text = "Auto Sell Disabled!", Duration = 3})
        end
    end
end

return NezukoHub
