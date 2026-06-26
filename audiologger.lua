if not game:IsLoaded() then
    game.Loaded:Wait()
end

local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local aa = game:GetObjects("rbxassetid://01997056190")[1]
aa.Parent = game.CoreGui
task.wait(0.2)

local GUI = aa.PopupFrame.PopupFrame
local pos = 0
local writeaudio = {}
local running = false
local autoscan = false
local selectedaudio = nil

local ignore = {
    "rbxasset://sounds/action_get_up.mp3",
    "rbxasset://sounds/uuhhh.mp3",
    "rbxasset://sounds/action_falling.mp3",
    "rbxasset://sounds/action_falling.ogg",
    "rbxasset://sounds/action_jump.mp3",
    "rbxasset://sounds/action_jump_land.mp3",
    "rbxasset://sounds/impact_water.mp3",
    "rbxasset://sounds/action_swim.mp3",
    "rbxasset://sounds/action_footsteps_plastic.mp3"
}

local function findTable(tbl, name)
    for _, v in ipairs(tbl) do
        if v == name then return true end
    end
    return false
end

local function refreshlist()
    pos = 0
    GUI.Logs.CanvasSize = UDim2.new(0, 0, 0, 0)
    for _, v in ipairs(GUI.Logs:GetChildren()) do
        v.Position = UDim2.new(0, 0, 0, pos)
        GUI.Logs.CanvasSize = UDim2.new(0, 0, 0, pos + 20)
        pos = pos + 20
    end
end

local function saveLoggedAudios(onlySelected)
    if not writefile then
        StarterGui:SetCore('SendNotification', {
            Title = 'Audio Logger',
            Text = 'Your executor does not support writefile!',
            Duration = 5,
        })
        return
    end
    
    if running then return end
    running = true
    
    GUI.Load.Visible = true
    GUI.Load:TweenSize(UDim2.new(0, 360, 0, 20), "Out", "Quad", 0.5, true)
    task.wait(0.3)
    
    writeaudio = {}
    for _, child in ipairs(GUI.Logs:GetChildren()) do
        if child:FindFirstChild('ImageButton') then
            local bttn = child:FindFirstChild('ImageButton')
            if not onlySelected or (onlySelected and bttn.BackgroundTransparency == 0) then
                table.insert(writeaudio, {
                    name = child.NAME.Value,
                    id = child.ID.Value
                })
            end
        end
    end
    
    local success, jsonText = pcall(function()
        return HttpService:JSONEncode(writeaudio)
    end)
    
    if success then
        GUI.Store.Visible = true
        GUI.Store.Text = jsonText
        task.wait(0.2)
    
        local filename = 0
        local function getUnusedFilename()
            local fileExists = pcall(function() return readfile("Scraped_Audios_" .. filename .. ".json") end)
            if fileExists then
                filename = filename + 1
                getUnusedFilename()
            end
        end
        getUnusedFilename()
    
        writefile("Scraped_Audios_" .. filename .. ".json", jsonText)

        StarterGui:SetCore('SendNotification', {
            Title = 'Audio Logger',
            Text = 'Saved Logged Audios (Scraped_Audios_' .. filename .. '.json)',
            Icon = 'http://www.roblox.com/asset/?id=176572847',
            Duration = 5,
        })
    end
    
    for rep = 1, 10 do
        GUI.Load.BackgroundTransparency = GUI.Load.BackgroundTransparency + 0.1
        task.wait(0.05)
    end
    
    GUI.Load.Visible = false
    GUI.Load.BackgroundTransparency = 0
    GUI.Load.Size = UDim2.new(0, 0, 0, 20)
    GUI.Store.Visible = false
    GUI.Store.Text = ''
    running = false
end

GUI.SS.MouseButton1Click:Connect(function() saveLoggedAudios(true) end)
GUI.SA.MouseButton1Click:Connect(function() saveLoggedAudios(false) end)

local function processAudioElement(child)
    if not child:IsA("Sound") or GUI.Logs:FindFirstChild(child.SoundId) or findTable(ignore, child.SoundId) then 
        return 
    end
    
    local numericId = string.match(child.SoundId, "%d+")
    if not numericId then return end
    
    local newsound = GUI.Audio:Clone()
    if string.match(child.SoundId, "&%d*hash=") then
        newsound.ImageButton.Image = 'rbxassetid://1453863294'
    end
    
    newsound.Parent = GUI.Logs
    newsound.Name = child.SoundId
    newsound.Visible = true
    newsound.Position = UDim2.new(0, 0, 0, pos)
    
    local scrolldown = (GUI.Logs.CanvasPosition.Y == GUI.Logs.CanvasSize.Y.Offset - 230)
    GUI.Logs.CanvasSize = UDim2.new(0, 0, 0, pos + 20)
    pos = pos + 20
    
    local audioname = child.Name
    local success, assetInfo = pcall(function()
        return MarketplaceService:GetProductInfo(tonumber(numericId))
    end)
    if success and assetInfo and assetInfo.Name then
        audioname = assetInfo.Name
    end
    
    newsound.TextLabel.Text = audioname
    
    local data = Instance.new('StringValue', newsound)
    data.Name = 'ID'
    data.Value = child.SoundId
    
    local data2 = Instance.new('StringValue', newsound)
    data2.Name = 'NAME'
    data2.Value = audioname
    
    local soundselected = false
    newsound.ImageButton.MouseButton1Click:Connect(function()
        if not GUI.Info.Visible then
            soundselected = not soundselected
            newsound.ImageButton.BackgroundTransparency = soundselected and 0 or 1
        end
    end)
    
    newsound.Click.MouseButton1Click:Connect(function()
        if not GUI.Info.Visible then
            GUI.Info.TextLabel.Text = "Name: " .. audioname .. " | ID: " .. child.SoundId .. " | Path Name: " .. child.Name
            selectedaudio = child.SoundId
            GUI.Info.Visible = true
        end
    end)
    
    if scrolldown then
        GUI.Logs.CanvasPosition = Vector2.new(0, 999999)
    end
end

local function getaudio(folder)
    if running then return end
    running = true
    GUI.Load.Visible = true
    GUI.Load:TweenSize(UDim2.new(0, 360, 0, 20), "Out", "Quad", 0.5, true)
    task.wait(0.3)
    
    for _, child in ipairs(folder:GetDescendants()) do
        task.spawn(processAudioElement, child)
    end
    
    for rep = 1, 10 do
        GUI.Load.BackgroundTransparency = GUI.Load.BackgroundTransparency + 0.1
        task.wait(0.05)
    end
    GUI.Load.Visible = false
    GUI.Load.BackgroundTransparency = 0
    GUI.Load.Size = UDim2.new(0, 0, 0, 20)
    running = false
end

GUI.All.MouseButton1Click:Connect(function() getaudio(game) end)
GUI.Workspace.MouseButton1Click:Connect(function() getaudio(workspace) end)
GUI.Lighting.MouseButton1Click:Connect(function() getaudio(game:GetService('Lighting')) end)
GUI.SoundS.MouseButton1Click:Connect(function() getaudio(game:GetService('SoundService')) end)

GUI.Clr.MouseButton1Click:Connect(function()
    for _, child in ipairs(GUI.Logs:GetChildren()) do
        if child:FindFirstChild('ImageButton') and child.ImageButton.BackgroundTransparency == 1 then
            child:Destroy()
        end
    end
    refreshlist()
end)

GUI.ClrS.MouseButton1Click:Connect(function()
    for _, child in ipairs(GUI.Logs:GetChildren()) do
        if child:FindFirstChild('ImageButton') and child.ImageButton.BackgroundTransparency == 0 then
            child:Destroy()
        end
    end
    refreshlist()
end)

GUI.AutoScan.MouseButton1Click:Connect(function()
    autoscan = not autoscan
    GUI.AutoScan.BackgroundTransparency = autoscan and 0.5 or 0
    StarterGui:SetCore('SendNotification', {
        Title = 'Audio Logger',
        Text = 'Auto Scan ' .. (autoscan and "ENABLED" or "DISABLED"),
        Icon = 'http://www.roblox.com/asset/?id=176572847',
        Duration = 5,
    })
end)

local itemadded = game.DescendantAdded:Connect(function(added)
    if autoscan then
        task.spawn(processAudioElement, added)
    end
end)

GUI.Close.MouseButton1Click:Connect(function()
    GUI:TweenSize(UDim2.new(0, 360, 0, 0), "Out", "Quad", 0.5, true) task.wait(0.6)
    GUI.Parent:TweenSize(UDim2.new(0, 0, 0, 20), "Out", "Quad", 0.5, true) task.wait(0.6)
    itemadded:Disconnect()
    aa:Destroy()
end)

local min = false
GUI.Minimize.MouseButton1Click:Connect(function()
    min = not min
    GUI:TweenSize(UDim2.new(0, 360, 0, min and 20 or 260), "Out", "Quad", 0.5, true)
end)

GUI.Info.Copy.MouseButton1Click:Connect(function()
    local clip = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    if clip then
        clip(selectedaudio)
        StarterGui:SetCore('SendNotification', {
            Title = 'Audio Logger',
            Text = 'Copied to clipboard!',
            Icon = 'http://www.roblox.com/asset/?id=176572847',
            Duration = 5,
        })
    else
        StarterGui:SetCore('SendNotification', {
            Title = 'Audio Logger',
            Text = 'Your executor lacks clipboard access.',
            Duration = 5,
        })
    end
end)

GUI.Info.Close.MouseButton1Click:Connect(function()
    GUI.Info.Visible = false
    local sample = Players.LocalPlayer.PlayerGui:FindFirstChild('SampleSound')
    if sample then sample:Destroy() end
    GUI.Info.Listen.Text = 'Listen'
end)

GUI.Info.Listen.MouseButton1Click:Connect(function()
    local targetGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local existingSample = targetGui:FindFirstChild('SampleSound')
    
    if GUI.Info.Listen.Text == 'Listen' then
        if existingSample then existingSample:Destroy() end
        local samplesound = Instance.new('Sound')
        samplesound.Parent = targetGui
        samplesound.Looped = true 
        samplesound.SoundId = selectedaudio 
        samplesound.Name = 'SampleSound'
        samplesound.Volume = 5
        samplesound:Play()
        GUI.Info.Listen.Text = 'Stop'
    else
        if existingSample then existingSample:Destroy() end
        GUI.Info.Listen.Text = 'Listen'
    end
end)

local function drag(gui)
    task.spawn(function()
        local dragging, dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            gui:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y), "InOut", "Quart", 0.04, true, nil) 
        end
        gui.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = gui.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        gui.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end)
end
drag(aa.PopupFrame)
