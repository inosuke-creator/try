-- NEZUKO HUB GUI FRAMEWORK (Pure Framework - No Components Included)
local NezukoHub = {}

-- ⚙️ Global Services
local Player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")

-- 🎨 THEME: Yellow and Black
local Theme = {
    -- Black/Dark Gray Base
    Background = Color3.fromRGB(15, 15, 15), 
    Header = Color3.fromRGB(25, 25, 25),
    Tab = Color3.fromRGB(30, 30, 30),
    ComponentBg = Color3.fromRGB(40, 40, 40), -- Base for future components
    
    -- Primary Accent: Nezuko Yellow
    Accent = Color3.fromRGB(255, 225, 0), 
    Text = Color3.fromRGB(255, 255, 255)
}

-- ------------------------------------------------------------------
--- 1. WINDOW CREATION
-- ------------------------------------------------------------------

function NezukoHub:CreateWindow()
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
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Theme.Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 8)
    HeaderCorner.Parent = Header
    
    local Title = Instance.new("TextLabel")
    Title.Text = "🌸 NEZUKO HUB"
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Theme.Accent -- Use Accent color
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0, 30, 0, 25)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -12)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.TextColor3 = Theme.Text
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    CloseButton.Parent = Header

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Minimize Button
    local MinButton = Instance.new("TextButton")
    MinButton.Text = "-"
    MinButton.Size = UDim2.new(0, 30, 0, 25)
    MinButton.Position = UDim2.new(1, -70, 0.5, -12)
    MinButton.BackgroundColor3 = Theme.Accent
    MinButton.TextColor3 = Theme.Background -- Dark text on yellow background
    MinButton.Font = Enum.Font.GothamBold
    MinButton.TextSize = 18
    MinButton.Parent = Header
    
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, -10, 1, -45)
    TabFrame.Position = UDim2.new(0, 5, 0, 40)
    TabFrame.BackgroundColor3 = Theme.Tab
    TabFrame.BorderSizePixel = 0
    TabFrame.Parent = MainFrame
    
    local minimized = false
    MinButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        TabFrame.Visible = not minimized
        MainFrame.Size = minimized and UDim2.new(0, 520, 0, 35) or UDim2.new(0, 520, 0, 330)
    end)

    -- Tab Bar Setup
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
                -- Highlight active tab button with Accent color
                button.BackgroundColor3 = (name == activeTab) and Theme.Accent or Theme.Header
                button.TextColor3 = (name == activeTab) and Theme.Background or Color3.fromRGB(180, 180, 180)
            end
        end
    end
    
-- ------------------------------------------------------------------
--- 2. TAB CREATION
-- ------------------------------------------------------------------

    function Tabs:CreateTab(tabName)
        tabCount = tabCount + 1
        local Components = {}
        local yOffset = 10 -- Starting Y position for the next component
        
        -- Content Frame for this specific tab
        local ContentFrame = Instance.new("Frame")
        ContentFrame.Name = tabName .. "Content"
        ContentFrame.Size = UDim2.new(1, 0, 1, -30)
        ContentFrame.Position = UDim2.new(0, 0, 0, 30)
        ContentFrame.BackgroundColor3 = Theme.Tab
        ContentFrame.BorderSizePixel = 0
        ContentFrame.Parent = TabFrame
        ContentFrame.Visible = false
        
        TabContent[tabName] = ContentFrame

        -- Section Title (e.g., "📁 HOME")
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Text = "📁 " .. tabName
        SectionTitle.Size = UDim2.new(1, 0, 0, 25)
        SectionTitle.Position = UDim2.new(0, 0, 0, yOffset)
        SectionTitle.TextColor3 = Theme.Accent 
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.TextSize = 16
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Parent = ContentFrame

        yOffset = yOffset + 30
        
        -- Create/Recalculate Tab Buttons
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
            currentX = currentX + newSizeX
        end
        
        -- !!! COMPONENTS RETURNED HERE ARE CURRENTLY EMPTY !!!
        -- This is where you will add your functions like Components:CreateToggle, etc.
        -- For now, it only has the yOffset so you know where the next item goes.
        Components.yOffset = yOffset
        Components.ContentFrame = ContentFrame
        
        return Components
    end

    -- Export necessary functions for external use
    NezukoHub.updateTabs = updateTabs
    return Tabs
end

-- ------------------------------------------------------------------
--- 3. EXAMPLE USAGE
-- ------------------------------------------------------------------

local Window = NezukoHub:CreateWindow()

-- Create your tabs
local HomeTab = Window:CreateTab("🏠 HOME")
local SettingsTab = Window:CreateTab("⚙️ SETTINGS")

-- Set the first tab active
NezukoHub.updateTabs("🏠 HOME")
