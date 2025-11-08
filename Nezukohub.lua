local NezukoHub = {}

-- 🖌️ Theme
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Header = Color3.fromRGB(35, 35, 35),
    Tab = Color3.fromRGB(40, 40, 40),
    ComponentBg = Color3.fromRGB(50, 50, 50),
    Button = Color3.fromRGB(255, 225, 0),
    Text = Color3.fromRGB(255, 255, 255)
}

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

-- Global References for Character
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local initialWalkSpeed = Humanoid.WalkSpeed 

-- 🗺️ Global Teleport Destinations
local TELEPORT_DESTINATIONS = {
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

-- 🚀 Teleport Core Function (unchanged)
local function executeTeleport(destinationName, position)
    isSelling = true 
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    HumanoidRootPart.CFrame = CFrame.new(position)

    game.StarterGui:SetCore("SendNotification", {
        Title = "Nezuko Hub",
        Text = "Teleported to " .. destinationName .. "!",
        Duration = 2
    })
    
    isSelling = false
end

-- Remote/Bindable References (unchanged)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net") 

-- Fishing Remotes
local EquipTool = netFolder:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local StartMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local FishingDone = netFolder:WaitForChild("RE/FishingCompleted")
-- Sell RemoteFunction
local SELL_REMOTE = netFolder:WaitForChild("RF/SellAllItems")

-- 🎣 Auto Fishing Core Function (unchanged)
local function runAutoFishing()
    while task.wait(FISHING_CYCLE_DELAY) do
        if isSelling then
            task.wait(1)
            continue
        end
        
        EquipTool:FireServer(1)
        task.wait(FISHING_CYCLE_DELAY)

        local success, result = pcall(function()
            return ChargeRod:InvokeServer()
        end)

        task.wait(0.5)

        local args = {
            -1.233184814453125,
            0.35881824928797157,
            1762227624.855859
        }
        success, result = pcall(function()
            return StartMinigame:InvokeServer(unpack(args))
        end)

        task.wait(3)

        FishingDone:FireServer()

        task.wait(FISHING_CYCLE_DELAY)
    end
end
------------------------------------------------------------------

-- 🚶 Auto Sell Single Run Function (Movement and Sell - unchanged)
local function executeSellAction()
    isSelling = true 
    
    local Player = game:GetService("Players").LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local Humanoid = Character:WaitForChild("Humanoid")
    
    Humanoid.PlatformStand = false
    task.wait(0.1)

    -- 0. Teleport to the starting zone
    HumanoidRootPart.CFrame = CFrame.new(START_ZONE_POS)
    game.StarterGui:SetCore("SendNotification", {Title = "Nezuko Hub", Text = "Teleporting to Start Zone...", Duration = 1})
    task.wait(1)

    -- --- STAGE 1: Walk to Middle Staging Point ---
    Humanoid:MoveTo(MIDDLE_STAGING_POS)
    game.StarterGui:SetCore("SendNotification", {Title = "Nezuko Hub", Text = "Walking to Middle Staging Area...", Duration = 1})
    local movedToMiddle = Humanoid.MoveToFinished:Wait(10)
    if not movedToMiddle then isSelling = false; return end

    -- --- STAGE 2: Walk to Final Sell Point ---
    Humanoid:MoveTo(TARGET_SELL_POS)
    game.StarterGui:SetCore("SendNotification", {Title = "Nezuko Hub", Text = "Walking to Final Sell Point...", Duration = 1})
    local movedToSell = Humanoid.MoveToFinished:Wait(5)

    if movedToSell then
        game.StarterGui:SetCore("SendNotification", {Title = "Nezuko Hub", Text = "Executing Sell Action...", Duration = 1})
        
        -- --- STAGE 3: EXECUTE SELL REMOTE FUNCTION ---
        pcall(function()
            SELL_REMOTE:InvokeServer()
        end)

        task.wait(0.5)
        
        -- **FINAL FIX**: Teleport back and look at the target water position
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
------------------------------------------------------------------

-- 🎛️ Create Window (UI Framework - MODIFIED FOR TABS)
function NezukoHub:CreateWindow(settings)
    local Player = game:GetService("Players").LocalPlayer
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

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Theme.Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = "🌸 Nezuko Hub"
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- ❌ Close button & ➖ Minimize button (unchanged logic)

    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0, 30, 0, 25)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -12)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.TextColor3 = Theme.Text
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    CloseButton.Parent = Header

    local MinButton = Instance.new("TextButton")
    MinButton.Text = "-"
    MinButton.Size = UDim2.new(0, 30, 0, 25)
    MinButton.Position = UDim2.new(1, -70, 0.5, -12)
    MinButton.BackgroundColor3 = Theme.Button
    MinButton.TextColor3 = Theme.Background
    MinButton.Font = Enum.Font.GothamBold
    MinButton.TextSize = 18
    MinButton.Parent = Header

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, -10, 1, -45)
    TabFrame.Position = UDim2.new(0, 5, 0, 40)
    TabFrame.BackgroundColor3 = Theme.Tab
    TabFrame.BorderSizePixel = 0
    TabFrame.Parent = MainFrame

    -- Toggle visibility for minimize (unchanged)
    local minimized = false
    MinButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        TabFrame.Visible = not minimized
        MainFrame.Size = minimized and UDim2.new(0, 520, 0, 35) or UDim2.new(0, 520, 0, 330)
    end)

    -- Close button (unchanged)
    CloseButton.MouseButton1Click:Connect(function()
        if autoFishThread then task.cancel(autoFishThread) end
        if autoSellThread then task.cancel(autoSellThread) end
        ScreenGui:Destroy()
    end)

    -- NEW: Tab Button Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 0, 30)
    TabContainer.Position = UDim2.new(0, 0, 0, 0)
    TabContainer.BackgroundColor3 = Theme.Header
    TabContainer.Parent = TabFrame
    
    local TabContent = {} -- Stores the actual content frames

    local function updateTabs(activeTab)
        for name, frame in pairs(TabContent) do
            local button = TabContainer:FindFirstChild(name .. "Button")
            
            frame.Visible = (name == activeTab)
            
            -- Visually highlight the active button
            if button then
                button.BackgroundColor3 = (name == activeTab) and Theme.Tab or Theme.Header
                button.TextColor3 = (name == activeTab) and Theme.Text or Color3.fromRGB(180, 180, 180) -- Dim inactive
            end
        end
    end

-- 🧩 Tabs & Components (MODIFIED)
local Tabs = {}
local tabCount = 0

function Tabs:CreateTab(tabName)
    tabCount = tabCount + 1
    local Components = {}
    local yOffset = 10
    
    -- NEW: Create a dedicated content frame for this tab
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = tabName .. "Content"
    ContentFrame.Size = UDim2.new(1, 0, 1, -30) -- Adjust height to account for the tab buttons
    ContentFrame.Position = UDim2.new(0, 0, 0, 30)
    ContentFrame.BackgroundColor3 = Theme.Tab
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = TabFrame
    ContentFrame.Visible = false -- Start hidden
    
    TabContent[tabName] = ContentFrame

    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Text = "📁 " .. tabName
    SectionTitle.Size = UDim2.new(1, 0, 0, 25)
    SectionTitle.Position = UDim2.new(0, 0, 0, yOffset)
    SectionTitle.TextColor3 = Theme.Button
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextSize = 16
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Parent = ContentFrame

    yOffset = yOffset + 30
    
    -- NEW: Create the clickable button in the TabContainer
    local totalWidth = TabContainer.AbsoluteSize.X or 500 
    local buttonWidth = totalWidth / tabCount
    
    -- Recalculate size and position for ALL existing buttons and the new one
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
        
        -- Apply new size and position
        local newSizeX = 1 / tabCount 
        button.Size = UDim2.new(newSizeX, 0, 1, 0)
        button.Position = UDim2.new(currentX / totalWidth, 0, 0, 0)
        currentX = currentX + buttonWidth
    end
    

    -- Component: CreateToggle (Modified parent to ContentFrame)
    function Components:CreateToggle(info)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(0, 480, 0, 30)
        ToggleFrame.Position = UDim2.new(0, 20, 0, yOffset)
        ToggleFrame.BackgroundColor3 = Theme.ComponentBg
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = ContentFrame 
        
        -- Toggle UI creation logic... 
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
        Track.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        Track.BorderSizePixel = 0
        Track.ClipsDescendants = true
        Track.Parent = ToggleFrame
        
        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.new(0, 16, 0, 16)
        Knob.Position = UDim2.new(0, 2, 0, 2)
        Knob.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        Knob.BorderSizePixel = 0
        Knob.Parent = Track
        
        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = Knob

        local active = info.Default or false

        local function updateToggle(state)
            active = state
            
            if active then
                Track.BackgroundColor3 = Theme.Button
                Knob:TweenPosition(UDim2.new(1, -18, 0, 2), "Out", "Quad", 0.15, true)
            else
                Track.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                Knob:TweenPosition(UDim2.new(0, 2, 0, 2), "Out", "Quad", 0.15, true)
            end
        end

        updateToggle(active)

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
    
    -- Component: CreateTeleportList (CORRECTED FOR SCROLLING)
    function Components:CreateTeleportList(destinations)
        
        -- Create the ScrollingFrame to hold all the buttons
        local ScrollFrame = Instance.new("ScrollingFrame")
        -- Position it to fill the remaining space in the tab
        ScrollFrame.Size = UDim2.new(1, -20, 1, -yOffset - 10) 
        ScrollFrame.Position = UDim2.new(0, 10, 0, yOffset)
        ScrollFrame.BackgroundColor3 = Theme.ComponentBg -- Background of the scroll area
        ScrollFrame.BorderSizePixel = 0
        ScrollFrame.Parent = ContentFrame
        ScrollFrame.ScrollBarImageColor3 = Theme.Button -- Make scrollbar match theme
        ScrollFrame.ScrollBarThickness = 6
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Start at 0, we will calculate this

        -- Reset yOffset for *inside* the scrolling frame
        local internalYOffset = 10

        -- Create the label *inside* the ScrollingFrame
        local Label = Instance.new("TextLabel")
        Label.Text = "Click a destination to teleport instantly:"
        Label.Size = UDim2.new(1, -20, 0, 20) -- 10px padding
        Label.Position = UDim2.new(0, 10, 0, internalYOffset)
        Label.TextColor3 = Theme.Text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ScrollFrame -- Parent to ScrollFrame
        internalYOffset = internalYOffset + 30 -- Update internal offset

        local currentColumn = 1 
        
        -- Button configuration
        local buttonWidth = 226
        local xPos1 = 10
        local xPos2 = xPos1 + buttonWidth + 10 -- 246
        local buttonHeight = 30
        local padding = 10
        
        for i, data in ipairs(destinations) do
            local name = data[1]
            local position = data[2]
            
            local xPos
            
            -- This determines the Y position based on the number of completed rows (i-1/2)
            -- We only increment the Y offset when we are placing the first button in a new row (odd index)
            local row = math.floor((i - 1) / 2)
            local ButtonYPos = (row * (buttonHeight + padding)) + internalYOffset

            if (i % 2) == 1 then -- Odd index (Column 1)
                xPos = xPos1
            else -- Even index (Column 2)
                xPos = xPos2
            end
            
            local TeleButton = Instance.new("TextButton")
            TeleButton.Size = UDim2.new(0, buttonWidth, 0, buttonHeight) 
            
            -- *** CRITICAL FIX: Ensure UDim2.new is used for Position ***
            TeleButton.Position = UDim2.new(0, xPos, 0, ButtonYPos)
            
            TeleButton.BackgroundColor3 = Theme.ComponentBg 
            TeleButton.TextColor3 = Theme.Text
            TeleButton.Font = Enum.Font.Gotham
            TeleButton.TextSize = 12
            TeleButton.Text = name
            TeleButton.Parent = ScrollFrame -- Parent to ScrollFrame

            TeleButton.MouseButton1Click:Connect(function()
                task.spawn(function()
                    executeTeleport(name, position)
                end)
            end)
        end
        
        -- Final CanvasSize Calculation
        local totalButtons = #destinations
        local numRows = math.ceil(totalButtons / 2)
        -- Calculation: Initial offset + (Number of rows * (button height + padding)) + extra padding
        local totalCanvasHeight = internalYOffset + (numRows * (buttonHeight + padding)) + 10
        
        -- *** CRITICAL FIX: Set the CanvasSize based on the final height ***
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalCanvasHeight)
    end

    return Components
end

    -- ✅ *** Expose the updateTabs function and MainFrame ***
    Tabs.MainFrame = MainFrame
    Tabs.updateTabs = updateTabs

    return Tabs

end

-- 🌸 Example Usage (Final Implementation)
local Window = NezukoHub:CreateWindow({
    Name = "Game Script"
})

-- Create the tabs
local HomeTab = Window:CreateTab("🏠 Home")
local TeleportTab = Window:CreateTab("🚀 Teleports")

-- --- Home Tab Components ---
-- 1. Auto Fishing Toggle
HomeTab:CreateToggle({
    Name = "Auto Fishing (Toggle)",
    Callback = function(is_on)
        if is_on then
            if not autoFishThread then
                autoFishThread = task.spawn(runAutoFishing)
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Nezuko Hub",
                    Text = "Auto Fishing Activated! (Delay: " .. FISHING_CYCLE_DELAY .. "s)",
                    Duration = 3
                })
            end
        else
            if autoFishThread then
                task.cancel(autoFishThread)
                autoFishThread = nil
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Nezuko Hub",
                    Text = "Auto Fishing Disabled!",
                    Duration = 3
                })
            end
        end
    end
})

-- 2. Auto Sell Loop Toggle
HomeTab:CreateToggle({
    Name = "Auto Sell (Toggle)",
    Callback = function(is_on)
        if is_on then
            if not autoSellThread then
                task.spawn(executeSellAction)
                autoSellThread = task.spawn(runAutoSellingLoop)
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Nezuko Hub",
                    Text = "Auto Sell Activated! (Interval: 5 minutes)",
                    Duration = 3
                })
            end
        else
            if autoSellThread then
                task.cancel(autoSellThread)
                autoSellThread = nil
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Nezuko Hub",
                    Text = "Auto Sell Disabled!",
                    Duration = 3
                })
            end
        end
    end
})

-- --- Teleport Tab Components ---
TeleportTab:CreateTeleportList(TELEPORT_DESTINATIONS)

-- ✅ *** Initial call to set the first tab active immediately ***
Window.updateTabs("🏠 Home")
