local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

-- — Configuration Start —
local framePath = playerGui:WaitForChild("ScreenGui") -- Replace with your ScreenGui's name and path
local frameLabel = "nil" -- Set this to the ImageLabel's name without the number
local numFrames = 10 -- Set the number of frames
local fps = 24 -- Frames per second
local frameDuration = 1 / (fps or 30) -- Duration per frame
-- — Configuration End —

local frameNames = {}
if frameLabel ~= "nil" or "none" or nil then
	for i = 1, numFrames do
		table.insert(frameNames, frameLabel..i)
	end
else
	local labels = {}
	for _, child in ipairs(framePath:GetChildren()) do
		if child:IsA("ImageLabel") then
			table.insert(labels, child.Name)
		end
	end
	local function isNumeric(str)
		return tonumber(str) ~= nil
	end
	local function isAlphabetic(str)
		return str:match("^%a+$") ~= nil
	end
	local numericNames = {}
	local alphabeticNames = {}
	local mixedNames = {}
	for _, name in ipairs(labels) do
		if isNumeric(name) then
			table.insert(numericNames, name)
		elseif isAlphabetic(name) then
			table.insert(alphabeticNames, name)
		else
			table.insert(mixedNames, name)
		end
	end
	table.sort(numericNames, function(a, b)
		return tonumber(a) < tonumber(b)
	end)
	table.sort(alphabeticNames)
	table.sort(mixedNames)
	for _, name in ipairs(numericNames) do
		table.insert(frameNames, name)
	end
	for _, name in ipairs(alphabeticNames) do
		table.insert(frameNames, name)
	end
	for _, name in ipairs(mixedNames) do
		table.insert(frameNames, name)
	end
	while #frameNames > numFrames do
		table.remove(frameNames)
	end
end

local function playImpactFrames()
	for _, frameName in ipairs(frameNames) do
		local frame = framePath:FindFirstChild(frameName)
		if frame and frame:IsA("ImageLabel") then
			frame.ImageTransparency = 1
			frame.Visible = false
		end
	end
	for _, frameName in ipairs(frameNames) do
		local frame = framePath:FindFirstChild(frameName)
		if frame and frame:IsA("ImageLabel") then
			frame.ImageTransparency = 0
			frame.Visible = true
			wait(frameDuration)
			frame.ImageTransparency = 1
			frame.Visible = false
		end
	end
end

local buttonGui = Instance.new("ScreenGui")
buttonGui.Name = "ImpactFrameButtonGui"
buttonGui.Parent = CoreGui
buttonGui.ResetOnSpawn = false
buttonGui.IgnoreGuiInset = true

local toggleButton = Instance.new("TextButton")
local buttonPixelSize = 40
toggleButton.Name = "PlayButton"
toggleButton.Size = UDim2.new(0, buttonPixelSize, 0, buttonPixelSize)
toggleButton.Position = UDim2.new(0.5, 0, 0.1, 0)
toggleButton.Text = framePath -- "Play Impact Frame(s)"
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
local textScaleFactor = 0.3
toggleButton.TextSize = math.clamp(buttonPixelSize * textScaleFactor, 12, 24)
toggleButton.TextScaled = true
toggleButton.Parent = buttonGui

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
buttonTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
buttonTextStroke.Color = Color3.fromRGB(0, 0, 0)
buttonTextStroke.LineJoinMode = Enum.LineJoinMode.Round
buttonTextStroke.Thickness = 1.25
buttonTextStroke.Name = "TextStroke"
buttonTextStroke.Parent = toggleButton

local isDragging = false
local lastInputPosition = Vector2.new(0, 0)

local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end
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
		toggleButton.Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset + delta.X, currentPos.Y.Scale, currentPos.Y.Offset + delta.Y)
		lastInputPosition = input.Position
	end
end

local function onInputEnded(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = false
	end
end

toggleButton.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)
UserInputService.InputEnded:Connect(onInputEnded)

toggleButton.MouseButton1Click:Connect(playImpactFrames)