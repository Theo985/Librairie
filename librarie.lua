-- X2ZU UI Library
local X2ZU_Lib = {}
X2ZU_Lib.__index = X2ZU_Lib

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Configuration
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Couleurs
X2ZU_Lib.Colors = {
    Background = Color3.fromRGB(25, 25, 25),
    Secondary = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(200, 200, 200),
    Success = Color3.fromRGB(85, 255, 85),
    Error = Color3.fromRGB(255, 85, 85)
}

-- Fonction pour créer des coins arrondis
local function CreateCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    return corner
end

-- Fonction pour créer des strokes
local function CreateStroke(color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    return stroke
end

-- Création de la fenêtre principale
function X2ZU_Lib:CreateWindow(name, icon)
    local self = setmetatable({}, X2ZU_Lib)
    
    -- ScreenGui principal
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "X2ZU_UI"
    self.ScreenGui.Parent = player.PlayerGui
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Container principal
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 500, 0, 550)
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -275)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundColor3 = self.Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.ZIndex = 1

    -- Stroke et corner
    CreateCorner(12).Parent = self.MainFrame
    CreateStroke(Color3.fromRGB(60, 60, 60), 2).Parent = self.MainFrame

    -- Barre de titre
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 45)
    self.TitleBar.Position = UDim2.new(0, 0, 0, 0)
    self.TitleBar.BackgroundColor3 = self.Colors.Secondary
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.ZIndex = 2
    self.TitleBar.Parent = self.MainFrame

    CreateCorner(12).Parent = self.TitleBar

    -- Icône du titre
    if icon then
        self.TitleIcon = Instance.new("ImageLabel")
        self.TitleIcon.Name = "TitleIcon"
        self.TitleIcon.Size = UDim2.new(0, 25, 0, 25)
        self.TitleIcon.Position = UDim2.new(0, 15, 0.5, -12.5)
        self.TitleIcon.BackgroundTransparency = 1
        self.TitleIcon.Image = icon
        self.TitleIcon.ZIndex = 3
        self.TitleIcon.Parent = self.TitleBar
    end

    -- Titre
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "TitleLabel"
    self.TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, icon and 50 or 15, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = name or "X2ZU UI"
    self.TitleLabel.TextColor3 = self.Colors.Text
    self.TitleLabel.TextSize = 18
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.ZIndex = 3
    self.TitleLabel.Parent = self.TitleBar

    -- Boutons de contrôle
    self.MinimizeButton = self:CreateControlButton("−", UDim2.new(1, -70, 0.5, -10), self.Colors.Accent)
    self.MinimizeButton.ZIndex = 3
    self.MinimizeButton.Parent = self.TitleBar

    self.CloseButton = self:CreateControlButton("×", UDim2.new(1, -35, 0.5, -10), self.Colors.Error)
    self.CloseButton.ZIndex = 3
    self.CloseButton.Parent = self.TitleBar

    -- Container des onglets
    self.TabsContainer = Instance.new("Frame")
    self.TabsContainer.Name = "TabsContainer"
    self.TabsContainer.Size = UDim2.new(1, -20, 0, 40)
    self.TabsContainer.Position = UDim2.new(0, 10, 0, 55)
    self.TabsContainer.BackgroundTransparency = 1
    self.TabsContainer.ZIndex = 2
    self.TabsContainer.Parent = self.MainFrame

    -- Container du contenu
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -20, 1, -110)
    self.ContentContainer.Position = UDim2.new(0, 10, 0, 105)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.ClipsDescendants = true
    self.ContentContainer.ZIndex = 1
    self.ContentContainer.Parent = self.MainFrame

    -- État
    self.Tabs = {}
    self.CurrentTab = nil
    self.IsMinimized = false

    -- Setup des événements
    self:SetupDrag()
    self:SetupButtons()

    return self
end

-- Bouton de contrôle
function X2ZU_Lib:CreateControlButton(text, position, color)
    local button = Instance.new("TextButton")
    button.Name = text .. "Button"
    button.Size = UDim2.new(0, 25, 0, 25)
    button.Position = position
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = self.Colors.Text
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false

    CreateCorner(6).Parent = button

    -- Animations hover
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)

    return button
end

-- Drag system
function X2ZU_Lib:SetupDrag()
    local dragging = false
    local dragInput, dragStart, startPos

    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Boutons de contrôle
function X2ZU_Lib:SetupButtons()
    self.CloseButton.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)

    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
end

-- Minimiser la fenêtre
function X2ZU_Lib:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    if self.IsMinimized then
        TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 500, 0, 45)}):Play()
        self.MinimizeButton.Text = "+"
    else
        TweenService:Create(self.MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 500, 0, 550)}):Play()
        self.MinimizeButton.Text = "−"
    end
end

-- Créer un onglet
function X2ZU_Lib:CreateTab(name)
    local tab = {}
    
    -- Bouton de l'onglet
    tab.Button = Instance.new("TextButton")
    tab.Button.Name = name .. "Tab"
    tab.Button.Size = UDim2.new(0, 100, 1, 0)
    tab.Button.Position = UDim2.new(0, (#self.Tabs * 105), 0, 0)
    tab.Button.BackgroundColor3 = self.Colors.Secondary
    tab.Button.BorderSizePixel = 0
    tab.Button.Text = name
    tab.Button.TextColor3 = self.Colors.TextSecondary
    tab.Button.TextSize = 14
    tab.Button.Font = Enum.Font.Gotham
    tab.Button.ZIndex = 3
    tab.Button.Parent = self.TabsContainer

    CreateCorner(6).Parent = tab.Button

    -- Contenu de l'onglet
    tab.Content = Instance.new("ScrollingFrame")
    tab.Content.Name = name .. "Content"
    tab.Content.Size = UDim2.new(1, 0, 1, 0)
    tab.Content.Position = UDim2.new(0, 0, 0, 0)
    tab.Content.BackgroundTransparency = 1
    tab.Content.BorderSizePixel = 0
    tab.Content.ScrollBarThickness = 3
    tab.Content.ScrollBarImageColor3 = self.Colors.Secondary
    tab.Content.Visible = false
    tab.Content.ZIndex = 1
    tab.Content.Parent = self.ContentContainer

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = tab.Content

    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingTop = UDim.new(0, 10)
    uiPadding.PaddingLeft = UDim.new(0, 10)
    uiPadding.PaddingRight = UDim.new(0, 10)
    uiPadding.Parent = tab.Content

    -- Événement de clic
    tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)

    -- Premier onglet actif
    if #self.Tabs == 0 then
        self:SwitchTab(tab)
    end

    table.insert(self.Tabs, tab)
    return tab
end

-- Changer d'onglet
function X2ZU_Lib:SwitchTab(targetTab)
    for _, tab in pairs(self.Tabs) do
        tab.Content.Visible = false
        tab.Button.BackgroundColor3 = self.Colors.Secondary
        tab.Button.TextColor3 = self.Colors.TextSecondary
    end
    
    targetTab.Content.Visible = true
    targetTab.Button.BackgroundColor3 = self.Colors.Accent
    targetTab.Button.TextColor3 = self.Colors.Text
    self.CurrentTab = targetTab
end

-- Section
function X2ZU_Lib:CreateSection(tab, name)
    local section = {}
    
    section.Frame = Instance.new("Frame")
    section.Frame.Name = name .. "Section"
    section.Frame.Size = UDim2.new(1, -20, 0, 40)
    section.Frame.BackgroundTransparency = 1
    section.Frame.LayoutOrder = #tab.Content:GetChildren()
    section.Frame.Parent = tab.Content

    section.Label = Instance.new("TextLabel")
    section.Label.Name = "SectionLabel"
    section.Label.Size = UDim2.new(1, 0, 1, 0)
    section.Label.Position = UDim2.new(0, 0, 0, 0)
    section.Label.BackgroundTransparency = 1
    section.Label.Text = name
    section.Label.TextColor3 = self.Colors.Text
    section.Label.TextSize = 16
    section.Label.Font = Enum.Font.GothamBold
    section.Label.TextXAlignment = Enum.TextXAlignment.Left
    section.Label.Parent = section.Frame

    section.Line = Instance.new("Frame")
    section.Line.Name = "SectionLine"
    section.Line.Size = UDim2.new(1, 0, 0, 1)
    section.Line.Position = UDim2.new(0, 0, 1, -5)
    section.Line.BackgroundColor3 = self.Colors.Secondary
    section.Line.BorderSizePixel = 0
    section.Line.Parent = section.Frame

    return section
end

-- Bouton
function X2ZU_Lib:CreateButton(tab, name, callback)
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Size = UDim2.new(1, -20, 0, 40)
    button.BackgroundColor3 = self.Colors.Secondary
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = self.Colors.Text
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.LayoutOrder = #tab.Content:GetChildren()
    button.Parent = tab.Content

    CreateCorner(8).Parent = button

    -- Animations
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = self.Colors.Accent}):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = self.Colors.Secondary}):Play()
    end)

    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    return button
end

-- Toggle
function X2ZU_Lib:CreateToggle(tab, name, callback)
    local toggle = {}
    
    toggle.Frame = Instance.new("Frame")
    toggle.Frame.Name = name .. "Toggle"
    toggle.Frame.Size = UDim2.new(1, -20, 0, 30)
    toggle.Frame.BackgroundTransparency = 1
    toggle.Frame.LayoutOrder = #tab.Content:GetChildren()
    toggle.Frame.Parent = tab.Content

    toggle.Label = Instance.new("TextLabel")
    toggle.Label.Name = "ToggleLabel"
    toggle.Label.Size = UDim2.new(0.7, 0, 1, 0)
    toggle.Label.Position = UDim2.new(0, 0, 0, 0)
    toggle.Label.BackgroundTransparency = 1
    toggle.Label.Text = name
    toggle.Label.TextColor3 = self.Colors.Text
    toggle.Label.TextSize = 14
    toggle.Label.Font = Enum.Font.Gotham
    toggle.Label.TextXAlignment = Enum.TextXAlignment.Left
    toggle.Label.Parent = toggle.Frame

    toggle.Button = Instance.new("TextButton")
    toggle.Button.Name = "ToggleButton"
    toggle.Button.Size = UDim2.new(0, 50, 0, 25)
    toggle.Button.Position = UDim2.new(1, -50, 0.5, -12.5)
    toggle.Button.BackgroundColor3 = self.Colors.Secondary
    toggle.Button.BorderSizePixel = 0
    toggle.Button.Text = ""
    toggle.Button.AutoButtonColor = false
    toggle.Button.Parent = toggle.Frame

    CreateCorner(12).Parent = toggle.Button

    toggle.Dot = Instance.new("Frame")
    toggle.Dot.Name = "ToggleDot"
    toggle.Dot.Size = UDim2.new(0, 15, 0, 15)
    toggle.Dot.Position = UDim2.new(0, 5, 0.5, -7.5)
    toggle.Dot.BackgroundColor3 = self.Colors.Text
    toggle.Dot.BorderSizePixel = 0
    toggle.Dot.Parent = toggle.Button

    CreateCorner(7).Parent = toggle.Dot

    toggle.State = false

    local function updateToggle()
        if toggle.State then
            TweenService:Create(toggle.Button, TweenInfo.new(0.2), {BackgroundColor3 = self.Colors.Success}):Play()
            TweenService:Create(toggle.Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -7.5)}):Play()
        else
            TweenService:Create(toggle.Button, TweenInfo.new(0.2), {BackgroundColor3 = self.Colors.Secondary}):Play()
            TweenService:Create(toggle.Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 5, 0.5, -7.5)}):Play()
        end
    end

    toggle.Button.MouseButton1Click:Connect(function()
        toggle.State = not toggle.State
        updateToggle()
        if callback then
            callback(toggle.State)
        end
    end)

    return toggle
end

-- Slider
function X2ZU_Lib:CreateSlider(tab, name, min, max, callback)
    local slider = {}
    
    slider.Frame = Instance.new("Frame")
    slider.Frame.Name = name .. "Slider"
    slider.Frame.Size = UDim2.new(1, -20, 0, 60)
    slider.Frame.BackgroundTransparency = 1
    slider.Frame.LayoutOrder = #tab.Content:GetChildren()
    slider.Frame.Parent = tab.Content

    slider.Label = Instance.new("TextLabel")
    slider.Label.Name = "SliderLabel"
    slider.Label.Size = UDim2.new(1, 0, 0, 20)
    slider.Label.Position = UDim2.new(0, 0, 0, 0)
    slider.Label.BackgroundTransparency = 1
    slider.Label.Text = name .. ": " .. tostring(min)
    slider.Label.TextColor3 = self.Colors.Text
    slider.Label.TextSize = 14
    slider.Label.Font = Enum.Font.Gotham
    slider.Label.TextXAlignment = Enum.TextXAlignment.Left
    slider.Label.Parent = slider.Frame

    slider.Track = Instance.new("Frame")
    slider.Track.Name = "SliderTrack"
    slider.Track.Size = UDim2.new(1, 0, 0, 5)
    slider.Track.Position = UDim2.new(0, 0, 0, 35)
    slider.Track.BackgroundColor3 = self.Colors.Secondary
    slider.Track.BorderSizePixel = 0
    slider.Track.Parent = slider.Frame

    CreateCorner(3).Parent = slider.Track

    slider.Fill = Instance.new("Frame")
    slider.Fill.Name = "SliderFill"
    slider.Fill.Size = UDim2.new(0, 0, 1, 0)
    slider.Fill.BackgroundColor3 = self.Colors.Accent
    slider.Fill.BorderSizePixel = 0
    slider.Fill.Parent = slider.Track

    CreateCorner(3).Parent = slider.Fill

    slider.Thumb = Instance.new("TextButton")
    slider.Thumb.Name = "SliderThumb"
    slider.Thumb.Size = UDim2.new(0, 15, 0, 15)
    slider.Thumb.Position = UDim2.new(0, -7.5, 0.5, -7.5)
    slider.Thumb.BackgroundColor3 = self.Colors.Text
    slider.Thumb.BorderSizePixel = 0
    slider.Thumb.Text = ""
    slider.Thumb.AutoButtonColor = false
    slider.Thumb.Parent = slider.Track

    CreateCorner(7).Parent = slider.Thumb

    slider.Value = min
    slider.Dragging = false

    local function updateSlider(mouseX)
        local relativeX = math.clamp(mouseX - slider.Track.AbsolutePosition.X, 0, slider.Track.AbsoluteSize.X)
        local percentage = relativeX / slider.Track.AbsoluteSize.X
        slider.Value = math.floor(min + (max - min) * percentage)
        
        slider.Fill.Size = UDim2.new(percentage, 0, 1, 0)
        slider.Thumb.Position = UDim2.new(percentage, -7.5, 0.5, -7.5)
        slider.Label.Text = name .. ": " .. tostring(slider.Value)
        
        if callback then
            callback(slider.Value)
        end
    end

    slider.Thumb.MouseButton1Down:Connect(function()
        slider.Dragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slider.Dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if slider.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)

    slider.Track.MouseButton1Down:Connect(function(x, y)
        updateSlider(x)
    end)

    return slider
end

-- Label
function X2ZU_Lib:CreateLabel(tab, text)
    local label = Instance.new("TextLabel")
    label.Name = text .. "Label"
    label.Size = UDim2.new(1, -20, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Colors.Text
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = #tab.Content:GetChildren()
    label.Parent = tab.Content

    return label
end

return X2ZU_Lib
