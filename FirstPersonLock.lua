local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local isFirstPersonLocked = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FirstPersonLockGui"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local toggleButton = Instance.new("TextButton")
local buttonPixelSize = 40
toggleButton.Size = UDim2.new(0, buttonPixelSize, 0, buttonPixelSize)
toggleButton.Position = UDim2.new(0.5, 0, 0.1, 0)
toggleButton.Text = "Lock"
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
local textScaleFactor = 0.3
toggleButton.TextSize = math.clamp(buttonPixelSize * textScaleFactor, 12, 24)
toggleButton.TextScaled = true
toggleButton.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = toggleButton

local uiStroke = Instance.new("UIStroke")
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Color = Color3.fromRGB(0, 0, 0)
uiStroke.LineJoinMode = Enum.LineJoinMode.Round
uiStroke.Thickness = 3.5
uiStroke.Transparency = 0
uiStroke.Parent = toggleButton

local buttonTextStroke = Instance.new("UIStroke")
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
uiStroke.Color = Color3.fromRGB(0, 0, 0)
uiStroke.LineJoinMode = Enum.LineJoinMode.Round
uiStroke.Thickness = 1.25
uiStroke.Name = "TextStroke"
uiStroke.Parent = toggleButton

local isDragging = false
local lastInputPosition = Vector2.new(0, 0)

local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end
	--print("Input began on button:", input.UserInputType.Name)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = true
		lastInputPosition = input.Position
	end
end

local function onInputChanged(input, gameProcessed)
	if gameProcessed then return end
	if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - lastInputPosition
		local currentPos = toggleButton.Position
		toggleButton.Position = UDim2.new(
			currentPos.X.Scale, currentPos.X.Offset + delta.X,
			currentPos.Y.Scale, currentPos.Y.Offset + delta.Y
		)
		lastInputPosition = input.Position
	end
end

local function onInputEnded(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = false
		--print("Input ended:", input.UserInputType.Name, "Dragging:", isDragging)
	end
end

toggleButton.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)
UserInputService.InputEnded:Connect(onInputEnded)

local function toggleFirstPersonLock()
	isFirstPersonLocked = not isFirstPersonLocked
	toggleButton.Text = isFirstPersonLocked and "Unlock" or "Lock"
	--print("Toggled first-person lock:", isFirstPersonLocked)
	if isFirstPersonLocked then
		camera.CameraType = Enum.CameraType.Scriptable
		if player.Character and player.Character:FindFirstChild("Head") or player.Character:WaitForChild("Head") then
			player.Character.Head.Transparency = 1
		end
	else
		camera.CameraType = Enum.CameraType.Custom
		if player.Character and player.Character:FindFirstChild("Head") or player.Character:WaitForChild("Head") then
			player.Character.Head.Transparency = 0
		end
	end
end

toggleButton.MouseButton1Click:Connect(toggleFirstPersonLock)

local function updateCamera()
	if isFirstPersonLocked and player.Character:FindFirstChild("Head") then
		local head = player.Character:WaitForChild("Head") or player.Character:FindFirstChild("Head")
		local eyeOffset = CFrame.new(0, 0, 0) -- just a small offset to avoid clipping into head because it's fuckin' weird lookin' ahh (Default values: "0, 0, -0.3", "0, 0.3, -0.6")
		camera.CFrame = head.CFrame * eyeOffset
	elseif isFirstPersonLocked then
		print("Player Head not found; waiting for character to fully load.")
	end
end

RunService.RenderStepped:Connect(updateCamera)

local function onCharacterAppearanceLoaded(character)
    if not isFirstPersonLocked then
        camera.CameraType = Enum.CameraType.Custom
        if player.Character:WaitForChild("Head") or player.Character:FindFirstChild("Head") then
            character.Head.Transparency = 0
        end
    else
        if player.Character:WaitForChild("Head") or player.Character:FindFirstChild("Head") then
            character.Head.Transparency = 1
        end
    end
end

player.CharacterAdded:Connect(function(character)
    if not isFirstPersonLocked then
        camera.CameraType = Enum.CameraType.Custom
        if player.Character:WaitForChild("Head") or player.Character:FindFirstChild("Head") then
            character.Head.Transparency = 
        end
    else
        if player.Character:WaitForChild("Head") or player.Character:FindFirstChild("Head") then
            character.Head.Transparency = 1
        end
    end
    player.CharacterAppearanceLoaded:Connect(onCharacterAppearanceLoaded)
end)

if player.Character then
    player.CharacterAppearanceLoaded:Connect(onCharacterAppearanceLoaded)
    if player.Character:WaitForChild("Head") or player.Character:FindFirstChild("Head") then
        player.Character.Head.Transparency = isFirstPersonLocked and 1 or 0
    end
end
