-- Services and variables
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- State variables for the fly script
local isFlying = false
local flySpeed = 50
local originalWalkSpeed = Humanoid.WalkSpeed
local isUIShown = true

-- UI Building Function
local function BuildFlyGUI()
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "JoviFlyper"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "FlyperFrame"
    MainFrame.Size = UDim2.new(0, 200, 0, 150)
    MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Text = "Jovi Flyper"
    Title.Font = Enum.Font.SourceSansBold
    Title.TextScaled = true
    Title.TextColor3 = Color3.fromRGB(0, 255, 255)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Title.BackgroundTransparency = 1
    Title.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextScaled = true
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    local FlyButton = Instance.new("TextButton")
    FlyButton.Name = "FlyButton"
    FlyButton.Size = UDim2.new(1, -20, 0, 40)
    FlyButton.Position = UDim2.new(0, 10, 0, 40)
    FlyButton.Text = "Enable Fly (E)"
    FlyButton.Font = Enum.Font.SourceSansBold
    FlyButton.TextScaled = true
    FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    FlyButton.Parent = MainFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, -20, 0, 20)
    StatusLabel.Position = UDim2.new(0, 10, 0, 85)
    StatusLabel.Text = "Fly Status: Disabled"
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    StatusLabel.Parent = MainFrame
    
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Name = "SpeedLabel"
    SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
    SpeedLabel.Position = UDim2.new(0, 10, 0, 110)
    SpeedLabel.Text = "Fly Speed: " .. flySpeed
    SpeedLabel.Font = Enum.Font.SourceSans
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SpeedLabel.Parent = MainFrame
    
    local SpeedSlider = Instance.new("Frame")
    SpeedSlider.Name = "SpeedSlider"
    SpeedSlider.Size = UDim2.new(1, -20, 0, 10)
    SpeedSlider.Position = UDim2.new(0, 10, 0, 130)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SpeedSlider.Parent = MainFrame

    local SliderHandle = Instance.new("Frame")
    SliderHandle.Name = "Handle"
    SliderHandle.Size = UDim2.new(0, 10, 1, 0)
    SliderHandle.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    SliderHandle.Parent = SpeedSlider
    SliderHandle.Active = true
    SliderHandle.Draggable = true
    
    -- Function to update the slider position and speed
    local function updateSlider(input)
        local frame = SpeedSlider
        local handle = SliderHandle
        local relativeX = math.clamp(input.Position.X - frame.AbsolutePosition.X, 0, frame.AbsoluteSize.X)
        local newScale = relativeX / frame.AbsoluteSize.X
        handle.Position = UDim2.new(newScale, 0, 0, 0)
        
        local newSpeed = 20 + newScale * 280
        flySpeed = newSpeed
        SpeedLabel.Text = "Fly Speed: " .. math.floor(flySpeed)
    end
    
    SliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
        end
    end)
    SliderHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and SliderHandle.Active then
            updateSlider(input)
        end
    end)
    
    return FlyButton, StatusLabel
end

-- Core fly logic
local function ToggleFly()
    isFlying = not isFlying
    
    if isFlying then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        Humanoid.WalkSpeed = 0
        HumanoidRootPart.Anchored = true
        task.spawn(function()
            while isFlying do
                local cameraDirection = UserInputService:GetMouseLocation().Unit
                local horizontalMove = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or (UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0)
                local strafeMove = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or (UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0)
                local verticalMove = UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -1 or 0)
                
                local CFrame = CFrame.new(HumanoidRootPart.Position)
                local forwardVector = CFrame.lookVector * horizontalMove
                local rightVector = CFrame.rightVector * strafeMove
                local upVector = Vector3.new(0, 1, 0) * verticalMove
                
                local movement = (forwardVector + rightVector + upVector).unit * flySpeed
                HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + movement * task.wait()
            end
        end)
    else
        HumanoidRootPart.Anchored = false
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        Humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- Main script logic
local FlyButton, StatusLabel = BuildFlyGUI()

FlyButton.MouseButton1Click:Connect(function()
    ToggleFly()
    if isFlying then
        StatusLabel.Text = "Fly Status: Enabled"
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    else
        StatusLabel.Text = "Fly Status: Disabled"
        FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.E then
        ToggleFly()
        if isFlying then
            StatusLabel.Text = "Fly Status: Enabled"
            FlyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        else
            StatusLabel.Text = "Fly Status: Disabled"
            FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end
end)
