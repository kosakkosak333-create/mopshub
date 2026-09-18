--==================== GUI ====================
screenGui = Instance.new("ScreenGui")
screenGui.Name = "MopsHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
if not screenGui.Parent then
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

hud = Instance.new("Frame")
hud.AnchorPoint = Vector2.new(0.5, 0)
hud.Position = UDim2.new(0.5, 0, 0, 12)
hud.Size = UDim2.new(0, 420, 0, 30)
hud.BackgroundColor3 = THEME.Background
hud.BackgroundTransparency = 0.25
hud.BorderSizePixel = 0
hud.ZIndex = 10
hud.Parent = screenGui
Instance.new("UICorner", hud).CornerRadius = UDim.new(0, 8)

local hudDot = Instance.new("Frame", hud)
hudDot.Size = UDim2.new(0, 6, 0, 6)
hudDot.Position = UDim2.new(0, 14, 0.5, -3)
hudDot.BackgroundColor3 = THEME.Accent
hudDot.BorderSizePixel = 0
Instance.new("UICorner", hudDot).CornerRadius = UDim.new(1, 0)

local hudTitle = Instance.new("TextLabel", hud)
hudTitle.Size = UDim2.new(0, 80, 1, 0)
hudTitle.Position = UDim2.new(0, 28, 0, 0)
hudTitle.BackgroundTransparency = 1
hudTitle.Font = Enum.Font.GothamBold
hudTitle.Text = "MopsHub"
hudTitle.TextColor3 = THEME.Text
hudTitle.TextSize = 12
hudTitle.TextXAlignment = Enum.TextXAlignment.Left

local hudVer = Instance.new("TextLabel", hud)
hudVer.Size = UDim2.new(0, 40, 1, 0)
hudVer.Position = UDim2.new(0, 92, 0, 0)
hudVer.BackgroundTransparency = 1
hudVer.Font = Enum.Font.Gotham
hudVer.Text = "v10.4"
hudVer.TextColor3 = THEME.TextDim
hudVer.TextSize = 10
hudVer.TextXAlignment = Enum.TextXAlignment.Left

local hudFps = Instance.new("TextLabel", hud)
hudFps.Size = UDim2.new(0, 60, 1, 0)
hudFps.Position = UDim2.new(0, 145, 0, 0)
hudFps.BackgroundTransparency = 1
hudFps.Font = Enum.Font.GothamMedium
hudFps.Text = "60 FPS"
hudFps.TextColor3 = THEME.Text
hudFps.TextSize = 12
hudFps.TextXAlignment = Enum.TextXAlignment.Left

local hudPlayer = Instance.new("TextLabel", hud)
hudPlayer.Size = UDim2.new(0, 100, 1, 0)
hudPlayer.Position = UDim2.new(0, 215, 0, 0)
hudPlayer.BackgroundTransparency = 1
hudPlayer.Font = Enum.Font.GothamMedium
hudPlayer.Text = LocalPlayer.DisplayName ~= "" and LocalPlayer.DisplayName or LocalPlayer.Name
hudPlayer.TextColor3 = THEME.Text
hudPlayer.TextSize = 12
hudPlayer.TextXAlignment = Enum.TextXAlignment.Left

hudRole = Instance.new("TextLabel", hud)
hudRole.Size = UDim2.new(0, 100, 1, 0)
hudRole.Position = UDim2.new(1, -110, 0, 0)
hudRole.BackgroundTransparency = 1
hudRole.Font = Enum.Font.GothamBold
hudRole.Text = myRole
hudRole.TextColor3 = ROLE_COLORS[myRole] or THEME.Text
hudRole.TextSize = 11
hudRole.TextXAlignment = Enum.TextXAlignment.Right

local fpsFrames, fpsLastTime = 0, tick()
track(RunService.RenderStepped:Connect(function()
    fpsFrames = fpsFrames + 1
    local now = tick()
    if now - fpsLastTime >= 0.5 then
        hudFps.Text = math.floor(fpsFrames / (now - fpsLastTime)) .. " FPS"
        fpsFrames, fpsLastTime = 0, now
    end
end))

openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 58, 0, 58)
openBtn.Position = UDim2.new(0, 20, 0.5, -29)
openBtn.BackgroundColor3 = THEME.AccentDim
openBtn.BackgroundTransparency = 0.15
openBtn.Text = "M"
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 24
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.BorderSizePixel = 0
openBtn.Active = true
openBtn.Draggable = true
openBtn.AutoButtonColor = false
openBtn.Parent = screenGui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
local obStroke = Instance.new("UIStroke", openBtn) obStroke.Color = THEME.Accent obStroke.Thickness = 2

main = Instance.new("Frame")
main.Size = UDim2.new(0, 880, 0, 560)
main.Position = UDim2.new(0.5, -440, 0.5, -280)
main.BackgroundColor3 = THEME.Background
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = false
main.ClipsDescendants = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", main) mainStroke.Color = THEME.BorderLight mainStroke.Thickness = 1 mainStroke.Transparency = 0.3

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 56)
header.BackgroundColor3 = THEME.Sidebar
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0

local logoLbl = Instance.new("TextLabel", header)
logoLbl.Size = UDim2.new(1, -260, 0, 30)
logoLbl.Position = UDim2.new(0, 24, 0, 12)
logoLbl.BackgroundTransparency = 1
logoLbl.Font = Enum.Font.GothamBlack
logoLbl.Text = "MOPS HUB"
logoLbl.TextColor3 = THEME.Text
logoLbl.TextSize = 20
logoLbl.TextXAlignment = Enum.TextXAlignment.Left

local verLbl = Instance.new("TextLabel", header)
verLbl.Size = UDim2.new(1, -260, 0, 14)
verLbl.Position = UDim2.new(0, 24, 0, 36)
verLbl.BackgroundTransparency = 1
verLbl.Font = Enum.Font.Gotham
verLbl.Text = "v10.4 | Чат + Конфиг + Бинды"
verLbl.TextColor3 = THEME.TextDim
verLbl.TextSize = 9
verLbl.TextXAlignment = Enum.TextXAlignment.Left

local configBtn = Instance.new("TextButton", header)
configBtn.Size = UDim2.new(0, 30, 0, 30)
configBtn.Position = UDim2.new(1, -190, 0.5, -15)
configBtn.BackgroundColor3 = THEME.AccentDim
configBtn.Text = "CFG"
configBtn.Font = Enum.Font.GothamBold
configBtn.TextSize = 10
configBtn.TextColor3 = Color3.new(1,1,1)
configBtn.BorderSizePixel = 0
Instance.new("UICorner", configBtn).CornerRadius = UDim.new(1, 0)

local chatBtn = Instance.new("TextButton", header)
chatBtn.Size = UDim2.new(0, 30, 0, 30)
chatBtn.Position = UDim2.new(1, -150, 0.5, -15)
chatBtn.BackgroundColor3 = THEME.AccentDim
chatBtn.Text = "ЧАТ"
chatBtn.Font = Enum.Font.GothamBold
chatBtn.TextSize = 9
chatBtn.TextColor3 = Color3.new(1,1,1)
chatBtn.BorderSizePixel = 0
Instance.new("UICorner", chatBtn).CornerRadius = UDim.new(1, 0)

local shutdownBtn = Instance.new("TextButton", header)
shutdownBtn.Size = UDim2.new(0, 30, 0, 30)
shutdownBtn.Position = UDim2.new(1, -110, 0.5, -15)
shutdownBtn.BackgroundColor3 = THEME.Danger
shutdownBtn.Text = "X"
shutdownBtn.Font = Enum.Font.GothamBold
shutdownBtn.TextSize = 13
shutdownBtn.TextColor3 = Color3.new(1,1,1)
shutdownBtn.BorderSizePixel = 0
Instance.new("UICorner", shutdownBtn).CornerRadius = UDim.new(1, 0)
shutdownBtn.MouseButton1Click:Connect(function()
    for _, conn in pairs(conns) do pcall(function() conn:Disconnect() end) end
    for _, conn in ipairs(ALL_CONNECTIONS) do pcall(function() conn:Disconnect() end) end
    pcall(function() screenGui:Destroy() end)
    pcall(function() blur:Destroy() end)
end)

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.TextColor3 = Color3.fromRGB(30, 30, 40)
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- ЧАТ ОКНО
chatWindow = Instance.new("Frame")
chatWindow.Size = UDim2.new(0, 380, 0, 460)
chatWindow.Position = UDim2.new(0, 260, 0.5, -230)
chatWindow.BackgroundColor3 = THEME.Solid
chatWindow.BackgroundTransparency = 0
chatWindow.BorderSizePixel = 0
chatWindow.Active = true
chatWindow.Draggable = true
chatWindow.Visible = false
chatWindow.ZIndex = 100
chatWindow.Parent = screenGui
Instance.new("UICorner", chatWindow).CornerRadius = UDim.new(0, 12)
local cwStroke = Instance.new("UIStroke", chatWindow)
cwStroke.Color = THEME.Accent cwStroke.Thickness = 2

local cwHeader = Instance.new("Frame", chatWindow)
cwHeader.Size = UDim2.new(1, 0, 0, 40)
cwHeader.BackgroundColor3 = THEME.SolidDark
cwHeader.BackgroundTransparency = 0
cwHeader.BorderSizePixel = 0
cwHeader.ZIndex = 101
Instance.new("UICorner", cwHeader).CornerRadius = UDim.new(0, 12)

local cwTitle = Instance.new("TextLabel", cwHeader)
cwTitle.Size = UDim2.new(1, -60, 1, 0)
cwTitle.Position = UDim2.new(0, 15, 0, 0)
cwTitle.BackgroundTransparency = 1
cwTitle.Font = Enum.Font.GothamBold
cwTitle.Text = "ЧАТ"
cwTitle.TextColor3 = THEME.Accent
cwTitle.TextSize = 13
cwTitle.TextXAlignment = Enum.TextXAlignment.Left
cwTitle.ZIndex = 102

local cwClose = Instance.new("TextButton", cwHeader)
cwClose.Size = UDim2.new(0, 26, 0, 26)
cwClose.Position = UDim2.new(1, -34, 0.5, -13)
cwClose.BackgroundColor3 = THEME.Danger
cwClose.Text = "X"
cwClose.Font = Enum.Font.GothamBold
cwClose.TextSize = 12
cwClose.TextColor3 = Color3.new(1,1,1)
cwClose.BorderSizePixel = 0
cwClose.ZIndex = 102
Instance.new("UICorner", cwClose).CornerRadius = UDim.new(1, 0)

cwContent = Instance.new("Frame", chatWindow)
cwContent.Size = UDim2.new(1, -16, 1, -56)
cwContent.Position = UDim2.new(0, 8, 0, 48)
cwContent.BackgroundTransparency = 1
cwContent.ZIndex = 101
local cwLayout = Instance.new("UIListLayout", cwContent)
cwLayout.Padding = UDim.new(0, 6)
cwLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- КОНФИГ ОКНО
configWindow = Instance.new("Frame")
configWindow.Size = UDim2.new(0, 700, 0, 560)
configWindow.Position = UDim2.new(0, 120, 0.5, -280)
configWindow.BackgroundColor3 = THEME.Solid
configWindow.BackgroundTransparency = 0
configWindow.BorderSizePixel = 0
configWindow.Active = true
configWindow.Draggable = true
configWindow.Visible = false
configWindow.ZIndex = 100
configWindow.Parent = screenGui
Instance.new("UICorner", configWindow).CornerRadius = UDim.new(0, 12)
local cfgStroke = Instance.new("UIStroke", configWindow)
cfgStroke.Color = THEME.Accent cfgStroke.Thickness = 2

local cfgHeader = Instance.new("Frame", configWindow)
cfgHeader.Size = UDim2.new(1, 0, 0, 40)
cfgHeader.BackgroundColor3 = THEME.SolidDark
cfgHeader.BackgroundTransparency = 0
cfgHeader.BorderSizePixel = 0
cfgHeader.ZIndex = 101
Instance.new("UICorner", cfgHeader).CornerRadius = UDim.new(0, 12)

local cfgTitle = Instance.new("TextLabel", cfgHeader)
cfgTitle.Size = UDim2.new(1, -60, 1, 0)
cfgTitle.Position = UDim2.new(0, 15, 0, 0)
cfgTitle.BackgroundTransparency = 1
cfgTitle.Font = Enum.Font.GothamBold
cfgTitle.Text = "УПРАВЛЕНИЕ КОНФИГАМИ"
cfgTitle.TextColor3 = THEME.Accent
cfgTitle.TextSize = 13
cfgTitle.TextXAlignment = Enum.TextXAlignment.Left
cfgTitle.ZIndex = 102

local cfgClose = Instance.new("TextButton", cfgHeader)
cfgClose.Size = UDim2.new(0, 26, 0, 26)
cfgClose.Position = UDim2.new(1, -34, 0.5, -13)
cfgClose.BackgroundColor3 = THEME.Danger
cfgClose.Text = "X"
cfgClose.Font = Enum.Font.GothamBold
cfgClose.TextSize = 12
cfgClose.TextColor3 = Color3.new(1,1,1)
cfgClose.BorderSizePixel = 0
cfgClose.ZIndex = 102
Instance.new("UICorner", cfgClose).CornerRadius = UDim.new(1, 0)

cfgContent = Instance.new("Frame", configWindow)
cfgContent.Size = UDim2.new(1, -16, 1, -56)
cfgContent.Position = UDim2.new(0, 8, 0, 48)
cfgContent.BackgroundTransparency = 1
cfgContent.ZIndex = 101

-- ЧАТ ЛОГИКА
local chatMessages = {}
local chatScroll, chatInput, chatSendBtn

local function loadChatMessages()
    local record = _fetchBin()
    if not record or type(record.messages) ~= "table" then chatMessages = {} return end
    chatMessages = {}
    for _, v in ipairs(record.messages) do
        if type(v) == "string" then
            local name, role, text, time = v:match("([^|]+)|([^|]+)|([^|]+)|(%d+)")
            if name and role and text then
                table.insert(chatMessages, {name = name, role = role, text = text, time = tonumber(time) or 0})
            end
        end
    end
    table.sort(chatMessages, function(a,b) return a.time < b.time end)
end

local function renderChatMessages()
    if not chatScroll or not chatScroll.Parent then return end
    for _, c in ipairs(chatScroll:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    if #chatMessages == 0 then
        local empty = Instance.new("TextLabel", chatScroll)
        empty.Size = UDim2.new(1, -10, 0, 30)
        empty.BackgroundTransparency = 1
        empty.Font = Enum.Font.Gotham
        empty.Text = "— пусто —"
        empty.TextColor3 = THEME.TextFaint
        empty.TextSize = 11
        empty.TextXAlignment = Enum.TextXAlignment.Center
        return
    end
    for _, msg in ipairs(chatMessages) do
        local lbl = Instance.new("TextLabel", chatScroll)
        lbl.Size = UDim2.new(1, -10, 0, 0)
        lbl.AutomaticSize = Enum.AutomaticSize.Y
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.Text = "[" .. msg.role .. "] " .. msg.name .. ": " .. msg.text
        lbl.TextColor3 = ROLE_COLORS[msg.role] or ROLE_COLORS.User
        lbl.TextSize = 11
        lbl.TextWrapped = true
        lbl.TextXAlignment = Enum.TextXAlignment.Left
    end
    task.wait()
    chatScroll.CanvasPosition = Vector2.new(0, chatScroll.AbsoluteCanvasSize.Y)
end

local function sendChatMessage(text)
    if STATE.Maintenance then return end
    if text == "" or #text > 200 then return end
    local clean = text:gsub("|", "/"):gsub("\n", " ")
    local entry = string.format("%s|%s|%s|%d", LocalPlayer.Name, myRole, clean, os.time())
    task.spawn(function()
        local record = _fetchBin() or {messages = {}}
        record.messages = record.messages or {}
        table.insert(record.messages, entry)
        while #record.messages > 100 do table.remove(record.messages, 1) end
        _pushBin(record)
        task.wait(0.4)
        loadChatMessages()
        renderChatMessages()
    end)
end

local function buildChatWindow()
    if chatBuilt then return end
    chatBuilt = true
    local roleHdr = Instance.new("TextLabel", cwContent)
    roleHdr.Size = UDim2.new(1, 0, 0, 18)
    roleHdr.BackgroundTransparency = 1
    roleHdr.Font = Enum.Font.GothamBold
    roleHdr.Text = "Твоя роль: " .. myRole
    roleHdr.TextColor3 = ROLE_COLORS[myRole] or ROLE_COLORS.User
    roleHdr.TextSize = 11
    roleHdr.TextXAlignment = Enum.TextXAlignment.Left
    roleHdr.LayoutOrder = 1
    local chatFrame = Instance.new("Frame", cwContent)
    chatFrame.Size = UDim2.new(1, 0, 1, -80)
    chatFrame.BackgroundColor3 = THEME.SolidInner
    chatFrame.BackgroundTransparency = 0
    chatFrame.BorderSizePixel = 0
    chatFrame.LayoutOrder = 2
    Instance.new("UICorner", chatFrame).CornerRadius = UDim.new(0, 8)
    chatScroll = Instance.new("ScrollingFrame", chatFrame)
    chatScroll.Size = UDim2.new(1, -8, 1, -8)
    chatScroll.Position = UDim2.new(0, 4, 0, 4)
    chatScroll.BackgroundTransparency = 1
    chatScroll.BorderSizePixel = 0
    chatScroll.ScrollBarThickness = 3
    chatScroll.ScrollBarImageColor3 = THEME.Accent
    chatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    local cLayout = Instance.new("UIListLayout", chatScroll)
    cLayout.Padding = UDim.new(0, 6)
    cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        chatScroll.CanvasSize = UDim2.new(0, 0, 0, cLayout.AbsoluteContentSize.Y + 10)
    end)
    chatInput = Instance.new("TextBox", cwContent)
    chatInput.Size = UDim2.new(1, -100, 0, 34)
    chatInput.BackgroundColor3 = THEME.SolidField
    chatInput.BackgroundTransparency = 0
    chatInput.Font = Enum.Font.Gotham
    chatInput.PlaceholderText = "Сообщение..."
    chatInput.PlaceholderColor3 = THEME.TextDim
    chatInput.Text = ""
    chatInput.TextColor3 = THEME.Text
    chatInput.TextSize = 12
    chatInput.TextXAlignment = Enum.TextXAlignment.Left
    chatInput.ClearTextOnFocus = false
    chatInput.LayoutOrder = 3
    Instance.new("UICorner", chatInput).CornerRadius = UDim.new(0, 8)
    local ciP = Instance.new("UIPadding", chatInput) ciP.PaddingLeft = UDim.new(0, 10)
    chatSendBtn = Instance.new("TextButton", cwContent)
    chatSendBtn.Size = UDim2.new(0, 90, 0, 34)
    chatSendBtn.BackgroundColor3 = THEME.AccentDim
    chatSendBtn.Text = "ОТПР"
    chatSendBtn.Font = Enum.Font.GothamBold
    chatSendBtn.TextSize = 12
    chatSendBtn.TextColor3 = Color3.new(1,1,1)
    chatSendBtn.BorderSizePixel = 0
    chatSendBtn.LayoutOrder = 4
    Instance.new("UICorner", chatSendBtn).CornerRadius = UDim.new(0, 8)
    chatSendBtn.MouseButton1Click:Connect(function()
        if chatInput.Text ~= "" then
            local txt = chatInput.Text
            chatInput.Text = ""
            sendChatMessage(txt)
        end
    end)
    chatInput.FocusLost:Connect(function(enter)
        if enter and chatInput.Text ~= "" then
            local txt = chatInput.Text
            chatInput.Text = ""
            sendChatMessage(txt)
        end
    end)
    task.spawn(function()
        loadChatMessages()
        renderChatMessages()
    end)
end

local function buildConfigWindow()
    if configBuilt then return end
    configBuilt = true
    local nameBox = Instance.new("TextBox", cfgContent)
    nameBox.Size = UDim2.new(1, -28, 0, 34)
    nameBox.Position = UDim2.new(0, 14, 0, 10)
    nameBox.BackgroundColor3 = THEME.SolidField
    nameBox.BackgroundTransparency = 0
    nameBox.Font = Enum.Font.Gotham
    nameBox.PlaceholderText = "Имя нового конфига..."
    nameBox.PlaceholderColor3 = THEME.TextDim
    nameBox.Text = ""
    nameBox.TextColor3 = THEME.Text
    nameBox.TextSize = 12
    nameBox.TextXAlignment = Enum.TextXAlignment.Left
    nameBox.ClearTextOnFocus = false
    Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 8)
    local nbP = Instance.new("UIPadding", nameBox) nbP.PaddingLeft = UDim.new(0, 12) nbP.Parent = nameBox
    local saveBtn = Instance.new("TextButton", cfgContent)
    saveBtn.Size = UDim2.new(0, 200, 0, 36)
    saveBtn.Position = UDim2.new(0, 14, 0, 54)
    saveBtn.BackgroundColor3 = THEME.AccentDim
    saveBtn.Text = "СОХРАНИТЬ"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 11
    saveBtn.TextColor3 = Color3.new(1,1,1)
    saveBtn.BorderSizePixel = 0
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
    local keyBtn = Instance.new("TextButton", cfgContent)
    keyBtn.Size = UDim2.new(0, 200, 0, 36)
    keyBtn.Position = UDim2.new(0, 224, 0, 54)
    keyBtn.BackgroundColor3 = Color3.fromRGB(90, 200, 130)
    keyBtn.Text = "СОЗДАТЬ КЛЮЧ"
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 11
    keyBtn.TextColor3 = Color3.new(1,1,1)
    keyBtn.BorderSizePixel = 0
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 8)
    local statusLbl = Instance.new("TextLabel", cfgContent)
    statusLbl.Size = UDim2.new(1, -28, 0, 20)
    statusLbl.Position = UDim2.new(0, 14, 0, 98)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.Text = ""
    statusLbl.TextColor3 = THEME.AccentLight
    statusLbl.TextSize = 11
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    local actHdr = Instance.new("TextLabel", cfgContent)
    actHdr.Size = UDim2.new(1, -28, 0, 20)
    actHdr.Position = UDim2.new(0, 14, 0, 126)
    actHdr.BackgroundTransparency = 1
    actHdr.Font = Enum.Font.GothamBold
    actHdr.Text = "АКТИВАЦИЯ КЛЮЧА"
    actHdr.TextColor3 = THEME.TextFaint
    actHdr.TextSize = 10
    actHdr.TextXAlignment = Enum.TextXAlignment.Left
    local keyInput = Instance.new("TextBox", cfgContent)
    keyInput.Size = UDim2.new(1, -240, 0, 34)
    keyInput.Position = UDim2.new(0, 14, 0, 150)
    keyInput.BackgroundColor3 = THEME.SolidField
    keyInput.BackgroundTransparency = 0
    keyInput.Font = Enum.Font.Gotham
    keyInput.PlaceholderText = "Вставь ключ (MOPS-...)"
    keyInput.PlaceholderColor3 = THEME.TextDim
    keyInput.Text = ""
    keyInput.TextColor3 = THEME.Text
    keyInput.TextSize = 11
    keyInput.TextXAlignment = Enum.TextXAlignment.Left
    keyInput.ClearTextOnFocus = false
    Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 8)
    local kiP = Instance.new("UIPadding", keyInput) kiP.PaddingLeft = UDim.new(0, 10) kiP.Parent = keyInput
    local activateBtn = Instance.new("TextButton", cfgContent)
    activateBtn.Size = UDim2.new(0, 200, 0, 34)
    activateBtn.Position = UDim2.new(1, -214, 0, 150)
    activateBtn.BackgroundColor3 = Color3.fromRGB(90, 200, 130)
    activateBtn.Text = "АКТИВИРОВАТЬ"
    activateBtn.Font = Enum.Font.GothamBold
    activateBtn.TextSize = 11
    activateBtn.TextColor3 = Color3.new(1,1,1)
    activateBtn.BorderSizePixel = 0
    Instance.new("UICorner", activateBtn).CornerRadius = UDim.new(0, 8)
    local savedHdr = Instance.new("TextLabel", cfgContent)
    savedHdr.Size = UDim2.new(1, -28, 0, 20)
    savedHdr.Position = UDim2.new(0, 14, 0, 196)
    savedHdr.BackgroundTransparency = 1
    savedHdr.Font = Enum.Font.GothamBold
    savedHdr.Text = "СОХРАНЁННЫЕ КОНФИГИ"
    savedHdr.TextColor3 = THEME.TextFaint
    savedHdr.TextSize = 10
    savedHdr.TextXAlignment = Enum.TextXAlignment.Left
    local listFrame = Instance.new("Frame", cfgContent)
    listFrame.Size = UDim2.new(1, -28, 1, -240)
    listFrame.Position = UDim2.new(0, 14, 0, 220)
    listFrame.BackgroundColor3 = THEME.SolidInner
    listFrame.BackgroundTransparency = 0
    listFrame.BorderSizePixel = 0
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)
    local listScroll = Instance.new("ScrollingFrame", listFrame)
    listScroll.Size = UDim2.new(1, -8, 1, -8)
    listScroll.Position = UDim2.new(0, 4, 0, 4)
    listScroll.BackgroundTransparency = 1
    listScroll.BorderSizePixel = 0
    listScroll.ScrollBarThickness = 3
    listScroll.ScrollBarImageColor3 = THEME.Accent
    listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    local listLayout = Instance.new("UIListLayout", listScroll)
    listLayout.Padding = UDim.new(0, 4)
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
    end)
    local function refreshList()
        for _, c in ipairs(listScroll:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local configs = listLocalConfigs()
        if #configs == 0 then
            local empty = Instance.new("TextLabel", listScroll)
            empty.Size = UDim2.new(1, 0, 0, 40)
            empty.BackgroundTransparency = 1
            empty.Font = Enum.Font.Gotham
            empty.Text = hasFileAPI() and "— нет конфигов —" or "Executor без файлов"
            empty.TextColor3 = THEME.TextFaint
            empty.TextSize = 11
            return
        end
        for _, name in ipairs(configs) do
            local row = Instance.new("Frame", listScroll)
            row.Size = UDim2.new(1, 0, 0, 32)
            row.BackgroundColor3 = THEME.Card
            row.BackgroundTransparency = 0.3
            row.BorderSizePixel = 0
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
            local nameLbl = Instance.new("TextLabel", row)
            nameLbl.Size = UDim2.new(1, -260, 1, 0)
            nameLbl.Position = UDim2.new(0, 12, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Font = Enum.Font.GothamMedium
            nameLbl.Text = name
            nameLbl.TextColor3 = THEME.Text
            nameLbl.TextSize = 12
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            local rLoad = Instance.new("TextButton", row)
            rLoad.Size = UDim2.new(0, 40, 0, 24)
            rLoad.Position = UDim2.new(1, -225, 0.5, -12)
            rLoad.BackgroundColor3 = THEME.AccentDim
            rLoad.Text = "ЗАГР"
            rLoad.Font = Enum.Font.GothamBold
            rLoad.TextSize = 9
            rLoad.TextColor3 = Color3.new(1,1,1)
            rLoad.BorderSizePixel = 0
            Instance.new("UICorner", rLoad).CornerRadius = UDim.new(0, 6)
            local rKey = Instance.new("TextButton", row)
            rKey.Size = UDim2.new(0, 40, 0, 24)
            rKey.Position = UDim2.new(1, -180, 0.5, -12)
            rKey.BackgroundColor3 = Color3.fromRGB(90, 200, 130)
            rKey.Text = "КЛЮЧ"
            rKey.Font = Enum.Font.GothamBold
            rKey.TextSize = 9
            rKey.TextColor3 = Color3.new(1,1,1)
            rKey.BorderSizePixel = 0
            Instance.new("UICorner", rKey).CornerRadius = UDim.new(0, 6)
            local rRename = Instance.new("TextButton", row)
            rRename.Size = UDim2.new(0, 40, 0, 24)
            rRename.Position = UDim2.new(1, -135, 0.5, -12)
            rRename.BackgroundColor3 = Color3.fromRGB(80, 130, 200)
            rRename.Text = "ИМЯ"
            rRename.Font = Enum.Font.GothamBold
            rRename.TextSize = 9
            rRename.TextColor3 = Color3.new(1,1,1)
            rRename.BorderSizePixel = 0
            Instance.new("UICorner", rRename).CornerRadius = UDim.new(0, 6)
            local rDelete = Instance.new("TextButton", row)
            rDelete.Size = UDim2.new(0, 40, 0, 24)
            rDelete.Position = UDim2.new(1, -90, 0.5, -12)
            rDelete.BackgroundColor3 = THEME.Danger
            rDelete.BackgroundTransparency = 0.3
            rDelete.Text = "УДАЛ"
            rDelete.Font = Enum.Font.GothamBold
            rDelete.TextSize = 9
            rDelete.TextColor3 = Color3.new(1,1,1)
            rDelete.BorderSizePixel = 0
            Instance.new("UICorner", rDelete).CornerRadius = UDim.new(0, 6)
            rLoad.MouseButton1Click:Connect(function()
                local ok, err = loadLocalConfig(name)
                if ok then
                    applyAllFromConfig()
                    statusLbl.Text = "Загружен: " .. name
                    statusLbl.TextColor3 = THEME.Success
                else
                    statusLbl.Text = tostring(err)
                    statusLbl.TextColor3 = THEME.Danger
                end
            end)
            rKey.MouseButton1Click:Connect(function()
                local ok, err = loadLocalConfig(name)
                if not ok then
                    statusLbl.Text = tostring(err)
                    statusLbl.TextColor3 = THEME.Danger
                    return
                end
                local key = generateKey()
                keyInput.Text = key
                local copied = copyToClipboard(key)
                statusLbl.Text = copied and ("Ключ скопирован (" .. #key .. ")") or "Ключ сгенерирован"
                statusLbl.TextColor3 = THEME.Success
            end)
            rRename.MouseButton1Click:Connect(function()
                nameBox.Text = name
                nameBox:CaptureFocus()
            end)
            rDelete.MouseButton1Click:Connect(function()
                deleteLocalConfig(name)
                statusLbl.Text = "Удалён: " .. name
                statusLbl.TextColor3 = THEME.Danger
                refreshList()
            end)
        end
    end
    saveBtn.MouseButton1Click:Connect(function()
        local name = nameBox.Text
        if name == "" then
            statusLbl.Text = "Введи имя конфига"
            statusLbl.TextColor3 = THEME.Danger
            return
        end
        local ok, err = saveLocalConfig(name)
        if ok then
            statusLbl.Text = "Сохранён: " .. name
            statusLbl.TextColor3 = THEME.Success
            refreshList()
        else
            statusLbl.Text = tostring(err)
            statusLbl.TextColor3 = THEME.Danger
        end
    end)
    keyBtn.MouseButton1Click:Connect(function()
        local key = generateKey()
        keyInput.Text = key
        local copied = copyToClipboard(key)
        statusLbl.Text = copied and ("Ключ скопирован! (" .. #key .. ")") or "Ключ сгенерирован"
        statusLbl.TextColor3 = THEME.Success
    end)
    activateBtn.MouseButton1Click:Connect(function()
        local key = keyInput.Text
        if key == "" then
            statusLbl.Text = "Вставь ключ"
            statusLbl.TextColor3 = THEME.Danger
            return
        end
        local ok, result = activateKey(key)
        if ok then
            applyAllFromConfig()
            statusLbl.Text = "Активирован! Настроек: " .. tostring(result)
            statusLbl.TextColor3 = THEME.Success
        else
            statusLbl.Text = tostring(result)
            statusLbl.TextColor3 = THEME.Danger
        end
    end)
    refreshList()
end

chatBtn.MouseButton1Click:Connect(function()
    if not chatBuilt then buildChatWindow() end
    chatWindow.Visible = not chatWindow.Visible
    if chatWindow.Visible then chatWindow.ZIndex = 150 end
end)

configBtn.MouseButton1Click:Connect(function()
    if not configBuilt then buildConfigWindow() end
    configWindow.Visible = not configWindow.Visible
    if configWindow.Visible then configWindow.ZIndex = 150 end
end)

cwClose.MouseButton1Click:Connect(function() chatWindow.Visible = false end)
cfgClose.MouseButton1Click:Connect(function() configWindow.Visible = false end)

-- SIDEBAR
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(0, 180, 1, -72)
tabBar.Position = UDim2.new(0, 14, 0, 66)
tabBar.BackgroundColor3 = THEME.Sidebar
tabBar.BackgroundTransparency = 0.2
tabBar.BorderSizePixel = 0
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 10)

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.Padding = UDim.new(0, 4)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
local tabPad = Instance.new("UIPadding", tabBar)
tabPad.PaddingTop = UDim.new(0, 8)
tabPad.PaddingLeft = UDim.new(0, 8)
tabPad.PaddingRight = UDim.new(0, 8)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -215, 1, -72)
content.Position = UDim2.new(0, 200, 0, 66)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0

contentScroll = Instance.new("ScrollingFrame", content)
contentScroll.Size = UDim2.new(1, 0, 1, 0)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 3
contentScroll.ScrollBarImageColor3 = THEME.Accent
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local scrollLayout = Instance.new("UIGridLayout", contentScroll)
scrollLayout.CellSize = UDim2.new(0, 330, 0, 210)
scrollLayout.CellPadding = UDim2.new(0, 14, 0, 14)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentScroll.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 30)
end)

local function setMenuVisible(state)
    if STATE.Maintenance then return end
    if state then
        openBtn.Visible = false
        main.Visible = true
        main.Size = UDim2.new(0, 0, 0, 0)
        main.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 880, 0, 560),
            Position = UDim2.new(0.5, -440, 0.5, -280)
        }):Play()
        TweenService:Create(blur, TweenInfo.new(0.3), {Size = 12}):Play()
    else
        local tw = TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        tw:Play()
        TweenService:Create(blur, TweenInfo.new(0.25), {Size = 0}):Play()
        tw.Completed:Connect(function()
            main.Visible = false
            main.Size = UDim2.new(0, 880, 0, 560)
            main.Position = UDim2.new(0.5, -440, 0.5, -280)
            openBtn.Visible = true
        end)
    end
end

openBtn.MouseButton1Click:Connect(function() setMenuVisible(true) end)
closeBtn.MouseButton1Click:Connect(function() setMenuVisible(false) end)

local function makeCard(title, order)
    local card = Instance.new("Frame", contentScroll)
    card.Size = UDim2.new(0, 330, 0, 210)
    card.BackgroundColor3 = THEME.Card
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel = 0
    card.LayoutOrder = order or 0
    card:SetAttribute("isCard", true)
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
    local cs = Instance.new("UIStroke", card) cs.Color = THEME.BorderLight cs.Thickness = 1 cs.Transparency = 0.4
    local h = Instance.new("TextLabel", card)
    h.Size = UDim2.new(1, -24, 0, 24)
    h.Position = UDim2.new(0, 16, 0, 14)
    h.BackgroundTransparency = 1
    h.Font = Enum.Font.GothamBold
    h.Text = title
    h.TextColor3 = THEME.Text
    h.TextSize = 13
    h.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(allCards, card)
    return card
end

local function addToggle(card, y, label, default, cb)
    local row = Instance.new("TextButton", card)
    row.Size = UDim2.new(1, -28, 0, 30)
    row.Position = UDim2.new(0, 14, 0, y)
    row.BackgroundTransparency = 1
    row.Text = ""
    row.AutoButtonColor = false
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = label
    lbl.TextColor3 = THEME.Text
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local box = Instance.new("Frame", row)
    box.Size = UDim2.new(0, 18, 0, 18)
    box.Position = UDim2.new(1, -18, 0.5, -9)
    box.BackgroundColor3 = Color3.fromRGB(48, 48, 62)
    box.BorderSizePixel = 0
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
    local check = Instance.new("TextLabel", box)
    check.Size = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Font = Enum.Font.GothamBold
    check.Text = "V"
    check.TextColor3 = Color3.new(1,1,1)
    check.TextSize = 12
    check.Visible = false
    local state = default or false
    if state then
        box.BackgroundColor3 = THEME.Accent
        check.Visible = true
    end
    row.MouseButton1Click:Connect(function()
        if STATE.Maintenance then return end
        state = not state
        box.BackgroundColor3 = state and THEME.Accent or Color3.fromRGB(48, 48, 62)
        check.Visible = state
        pcall(cb, state)
    end)
end

local function addSlider(card, y, label, min, max, default, cb)
    local holder = Instance.new("Frame", card)
    holder.Size = UDim2.new(1, -28, 0, 38)
    holder.Position = UDim2.new(0, 14, 0, y)
    holder.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, -60, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = label
    lbl.TextColor3 = THEME.Text
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local valueLbl = Instance.new("TextLabel", holder)
    valueLbl.Size = UDim2.new(0, 60, 0, 14)
    valueLbl.Position = UDim2.new(1, -60, 0, 0)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Font = Enum.Font.GothamBold
    valueLbl.Text = tostring(default)
    valueLbl.TextColor3 = THEME.AccentLight
    valueLbl.TextSize = 11
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    local bar = Instance.new("Frame", holder)
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.Position = UDim2.new(0, 0, 0, 22)
    bar.BackgroundColor3 = Color3.fromRGB(48, 48, 62)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = THEME.Accent
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local dragging = false
    local function update(input)
        if STATE.Maintenance then return end
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos + 0.5)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -6, 0.5, -6)
        valueLbl.Text = tostring(value)
        cb(value)
    end
    bar.InputBegan:Connect(function(input)
        if STATE.Maintenance then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

local function addDropdown(card, y, label, options, default, cb)
    local row = Instance.new("Frame", card)
    row.Size = UDim2.new(1, -28, 0, 30)
    row.Position = UDim2.new(0, 14, 0, y)
    row.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0, 80, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = label
    lbl.TextColor3 = THEME.Text
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local dropBtn = Instance.new("TextButton", row)
    dropBtn.Size = UDim2.new(1, -90, 0, 26)
    dropBtn.Position = UDim2.new(0, 90, 0.5, -13)
    dropBtn.BackgroundColor3 = THEME.Background
    dropBtn.BackgroundTransparency = 0.4
    dropBtn.Text = default or options[1]
    dropBtn.Font = Enum.Font.Gotham
    dropBtn.TextSize = 11
    dropBtn.TextColor3 = THEME.Text
    dropBtn.BorderSizePixel = 0
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 6)
    local idx = 1
    for i, o in ipairs(options) do if o == default then idx = i break end end
    dropBtn.MouseButton1Click:Connect(function()
        if STATE.Maintenance then return end
        idx = idx % #options + 1
        dropBtn.Text = options[idx]
        cb(options[idx])
    end)
end

local sidebarButtons = {}
local currentTab = "combat"

local function makeTab(id, icon, label)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = THEME.Sidebar
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local iL = Instance.new("TextLabel", btn)
    iL.Size = UDim2.new(0, 26, 1, 0)
    iL.Position = UDim2.new(0, 10, 0, 0)
    iL.BackgroundTransparency = 1
    iL.Font = Enum.Font.GothamBold
    iL.Text = icon
    iL.TextColor3 = THEME.TextDim
    iL.TextSize = 11
    local nL = Instance.new("TextLabel", btn)
    nL.Size = UDim2.new(1, -44, 1, 0)
    nL.Position = UDim2.new(0, 40, 0, 0)
    nL.BackgroundTransparency = 1
    nL.Font = Enum.Font.GothamMedium
    nL.Text = label
    nL.TextColor3 = THEME.TextDim
    nL.TextSize = 12
    nL.TextXAlignment = Enum.TextXAlignment.Left
    sidebarButtons[id] = { button = btn, icon = iL, label = nL }
    btn.MouseButton1Click:Connect(function()
        if STATE.Maintenance then return end
        currentTab = id
        for tid, d in pairs(sidebarButtons) do
            if tid == id then
                d.button.BackgroundColor3 = THEME.AccentDim
                d.button.BackgroundTransparency = 0.1
                d.icon.TextColor3 = Color3.new(1,1,1)
                d.label.TextColor3 = Color3.new(1,1,1)
            else
                d.button.BackgroundColor3 = THEME.Sidebar
                d.button.BackgroundTransparency = 1
                d.icon.TextColor3 = THEME.TextDim
                d.label.TextColor3 = THEME.TextDim
            end
        end
        rebuildContent()
    end)
end

function rebuildContent()
    allCards = {}
    for _, c in ipairs(contentScroll:GetChildren()) do
        if c:IsA("Frame") and c:GetAttribute("isCard") then c:Destroy() end
    end

    if currentTab == "combat" then
        local c1 = makeCard("Kill Aura", 1)
        addToggle(c1, 56, "Включить", CONFIG.KillAura, function(s) CONFIG.KillAura = s if s then startKillAura() else stopKillAura() end end)
        addToggle(c1, 90, "Без урона", CONFIG.KillAuraNoDmg, function(s) CONFIG.KillAuraNoDmg = s end)
        addSlider(c1, 124, "Радиус", 5, 300, CONFIG.KillRange, function(v) CONFIG.KillRange = v end)
        addSlider(c1, 164, "Урон", 1, 999, CONFIG.KillDamage, function(v) CONFIG.KillDamage = v end)
        local c2 = makeCard("Авто-фарм", 2)
        addToggle(c2, 56, "Включить", CONFIG.AutoFarm, function(s) CONFIG.AutoFarm = s if s then startAutoFarm() else stopAutoFarm() end end)
        addSlider(c2, 90, "Радиус", 20, 1000, CONFIG.FarmRange, function(v) CONFIG.FarmRange = v end)
        addDropdown(c2, 130, "Режим", {"Walk", "Teleport"}, CONFIG.FarmMode, function(v) CONFIG.FarmMode = v end)
        local c3 = makeCard("Авто-ребёрн", 3)
        addToggle(c3, 56, "Включить", CONFIG.AutoRebirth, function(s) CONFIG.AutoRebirth = s if s then startAutoRebirth() else stopAutoRebirth() end end)
        addSlider(c3, 90, "Задержка", 1, 10, CONFIG.RebirthDelay, function(v) CONFIG.RebirthDelay = v end)
        local c4 = makeCard("Fling", 4)
        addToggle(c4, 56, "Fling (рядом)", CONFIG.Fling, function(s) CONFIG.Fling = s if s then startFlingLoop() else stopFlingLoop() end end)
        addToggle(c4, 90, "Fling ВСЕХ", CONFIG.FlingAll, function(s) CONFIG.FlingAll = s if s then startFlingAll() else stopFlingAll() end end)
        local c5 = makeCard("Anti-Fling", 5)
        addToggle(c5, 56, "Включить", CONFIG.AntiFling, function(s) CONFIG.AntiFling = s if s then startAntiFling() else stopAntiFling() end end)

    elseif currentTab == "movement" then
        local c1 = makeCard("Скорость / Прыжок", 1)
        addToggle(c1, 56, "Speed", CONFIG.Speed, function(s) CONFIG.Speed = s applySpeed(s) end)
        addToggle(c1, 90, "Noclip", CONFIG.Noclip, function(s) CONFIG.Noclip = s applyNoclip(s) end)
        addToggle(c1, 124, "Беск. прыжок", CONFIG.InfiniteJump, function(s) CONFIG.InfiniteJump = s applyInfJump(s) end)
        addSlider(c1, 160, "Скорость ходьбы", 16, 300, CONFIG.WalkSpeed, function(v) CONFIG.WalkSpeed = v end)
        local c2 = makeCard("Полёт", 2)
        addToggle(c2, 56, "Fly", CONFIG.Fly, function(s) CONFIG.Fly = s if s then startFly() else stopFly() end end)
        addSlider(c2, 90, "Скорость полёта", 10, 300, CONFIG.FlySpeed, function(v) CONFIG.FlySpeed = v end)
        local c3 = makeCard("Bhop", 3)
        addToggle(c3, 56, "Bhop", CONFIG.Bhop, function(s) CONFIG.Bhop = s if s then startBhop() else stopBhop() end end)
        addSlider(c3, 90, "Ускорение", 1, 20, CONFIG.BhopGain, function(v) CONFIG.BhopGain = v end)
        addSlider(c3, 130, "Макс. скорость", 50, 500, CONFIG.BhopMax, function(v) CONFIG.BhopMax = v end)
        local c4 = makeCard("Вращение", 4)
        addToggle(c4, 56, "Spin", CONFIG.Spin, function(s) CONFIG.Spin = s if s then startSpin() else stopSpin() end end)
        addSlider(c4, 90, "Скорость", 1, 100, CONFIG.SpinSpeed, function(v) CONFIG.SpinSpeed = v end)

    elseif currentTab == "render" then
        local c1 = makeCard("Aura", 1)
        addToggle(c1, 56, "Aura", CONFIG.Aura, function(s) CONFIG.Aura = s if s then startAura() else stopAura() end end)
        local c2 = makeCard("ESP", 2)
        addToggle(c2, 56, "ESP", CONFIG.ESP, function(s) CONFIG.ESP = s if s then startESP() else stopESP() end end)
        local c3 = makeCard("Освещение", 3)
        addToggle(c3, 56, "Fullbright", CONFIG.Fullbright, function(s) CONFIG.Fullbright = s applyFullbright(s) end)
        addToggle(c3, 90, "Убрать туман", CONFIG.NoFog, function(s) CONFIG.NoFog = s applyNoFog(s) end)

    elseif currentTab == "misc" then
        if not isOwner and myRole ~= "Mops" then
            local cOwner = makeCard("ДОСТУП OWNER", 0)
            local btnOwner = Instance.new("TextButton", cOwner)
            btnOwner.Size = UDim2.new(1, -28, 0, 36)
            btnOwner.Position = UDim2.new(0, 14, 0, 56)
            btnOwner.BackgroundColor3 = THEME.Gold
            btnOwner.BorderSizePixel = 0
            btnOwner.Text = "Ввести пароль Owner"
            btnOwner.Font = Enum.Font.GothamBold
            btnOwner.TextSize = 13
            btnOwner.TextColor3 = Color3.fromRGB(20, 20, 20)
            Instance.new("UICorner", btnOwner).CornerRadius = UDim.new(0, 8)
            btnOwner.MouseButton1Click:Connect(function()
                showOwnerPasswordPrompt(function(success)
                    if success then
                        if addOwnerTab then addOwnerTab() end
                        if hudRole then
                            hudRole.Text = myRole
                            hudRole.TextColor3 = ROLE_COLORS[myRole] or THEME.Text
                        end
                        rebuildContent()
                    end
                end)
            end)
        end
        local c1 = makeCard("Anti-AFK", 1)
        addToggle(c1, 56, "Anti-AFK", CONFIG.AntiAfk, function(s) CONFIG.AntiAfk = s applyAntiAfk(s) end)
        local c2 = makeCard("HUD", 2)
        addToggle(c2, 56, "Watermark", true, function(s) hud.Visible = s end)
        addToggle(c2, 90, "Показывать FPS", true, function(s) hudFps.Visible = s end)
        local c3 = makeCard("СМЕНИТЬ РОЛЬ", 3)
        local curRoleLbl = Instance.new("TextLabel", c3)
        curRoleLbl.Size = UDim2.new(1, -28, 0, 20)
        curRoleLbl.Position = UDim2.new(0, 14, 0, 56)
        curRoleLbl.BackgroundTransparency = 1
        curRoleLbl.Font = Enum.Font.Gotham
        curRoleLbl.Text = "Текущая роль: " .. myRole
        curRoleLbl.TextColor3 = ROLE_COLORS[myRole] or THEME.Text
        curRoleLbl.TextSize = 11
        curRoleLbl.TextXAlignment = Enum.TextXAlignment.Left
        local changeRoleBtn = Instance.new("TextButton", c3)
        changeRoleBtn.Size = UDim2.new(1, -28, 0, 40)
        changeRoleBtn.Position = UDim2.new(0, 14, 0, 84)
        changeRoleBtn.BackgroundColor3 = THEME.AccentDim
        changeRoleBtn.BorderSizePixel = 0
        changeRoleBtn.Text = "СМЕНИТЬ РОЛЬ"
        changeRoleBtn.Font = Enum.Font.GothamBold
        changeRoleBtn.TextSize = 13
        changeRoleBtn.TextColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", changeRoleBtn).CornerRadius = UDim.new(0, 8)
        changeRoleBtn.MouseButton1Click:Connect(function()
            showRoleSelection(function(newRole)
                myRole = newRole
                saveRole(newRole)
                if hudRole then
                    hudRole.Text = myRole
                    hudRole.TextColor3 = ROLE_COLORS[myRole] or THEME.Text
                end
                if newRole == "Owner" then
                    isOwner = true
                    ownerPasswordUsed = true
                    if addOwnerTab then addOwnerTab() end
                elseif newRole == "Mops" then
                    if addOwnerTab then addOwnerTab() end
                else
                    if sidebarButtons["owner"] then
                        sidebarButtons["owner"].button:Destroy()
                        sidebarButtons["owner"] = nil
                    end
                    if currentTab == "owner" then currentTab = "combat" end
                end
                rebuildContent()
            end)
        end)
        local resetRoleBtn = Instance.new("TextButton", c3)
        resetRoleBtn.Size = UDim2.new(1, -28, 0, 32)
        resetRoleBtn.Position = UDim2.new(0, 14, 0, 132)
        resetRoleBtn.BackgroundColor3 = THEME.Danger
        resetRoleBtn.BackgroundTransparency = 0.3
        resetRoleBtn.BorderSizePixel = 0
        resetRoleBtn.Text = "Сбросить роль (Free)"
        resetRoleBtn.Font = Enum.Font.GothamBold
        resetRoleBtn.TextSize = 11
        resetRoleBtn.TextColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", resetRoleBtn).CornerRadius = UDim.new(0, 8)
        resetRoleBtn.MouseButton1Click:Connect(function()
            myRole = "Free"
            saveRole("Free")
            if hudRole then
                hudRole.Text = myRole
                hudRole.TextColor3 = ROLE_COLORS.Free
            end
            if sidebarButtons["owner"] then
                sidebarButtons["owner"].button:Destroy()
                sidebarButtons["owner"] = nil
            end
            if currentTab == "owner" then currentTab = "combat" end
            rebuildContent()
        end)

    elseif currentTab == "binds" then
        local c1 = makeCard("БИНДЫ", 1)
        c1.Size = UDim2.new(0, 690, 0, 600)
        local hint = Instance.new("TextLabel", c1)
        hint.Size = UDim2.new(1, -28, 0, 20)
        hint.Position = UDim2.new(0, 14, 0, 50)
        hint.BackgroundTransparency = 1
        hint.Font = Enum.Font.Gotham
        hint.Text = "Нажми на кнопку и зажми клавишу, чтобы назначить бинд"
        hint.TextColor3 = THEME.TextDim
        hint.TextSize = 10
        hint.TextXAlignment = Enum.TextXAlignment.Left
        local bindScroll = Instance.new("ScrollingFrame", c1)
        bindScroll.Size = UDim2.new(1, -28, 1, -80)
        bindScroll.Position = UDim2.new(0, 14, 0, 74)
        bindScroll.BackgroundColor3 = THEME.SolidInner
        bindScroll.BackgroundTransparency = 0
        bindScroll.BorderSizePixel = 0
        bindScroll.ScrollBarThickness = 3
        bindScroll.ScrollBarImageColor3 = THEME.Accent
        bindScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        Instance.new("UICorner", bindScroll).CornerRadius = UDim.new(0, 6)
        local bindLayout = Instance.new("UIListLayout", bindScroll)
        bindLayout.Padding = UDim.new(0, 4)
        bindLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            bindScroll.CanvasSize = UDim2.new(0, 0, 0, bindLayout.AbsoluteContentSize.Y + 8)
        end)
        for _, func in ipairs(BIND_FUNCS) do
            local row = Instance.new("Frame", bindScroll)
            row.Size = UDim2.new(1, -8, 0, 34)
            row.BackgroundColor3 = THEME.Card
            row.BackgroundTransparency = 0.3
            row.BorderSizePixel = 0
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
            local nameLbl = Instance.new("TextLabel", row)
            nameLbl.Size = UDim2.new(1, -220, 1, 0)
            nameLbl.Position = UDim2.new(0, 12, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Font = Enum.Font.GothamMedium
            nameLbl.Text = func.name
            nameLbl.TextColor3 = THEME.Text
            nameLbl.TextSize = 11
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            local bindBtn = Instance.new("TextButton", row)
            bindBtn.Size = UDim2.new(0, 90, 0, 24)
            bindBtn.Position = UDim2.new(1, -140, 0.5, -12)
            bindBtn.BackgroundColor3 = THEME.AccentDim
            bindBtn.Text = BINDS[func.id] and BINDS[func.id].Name or "Назначить"
            bindBtn.Font = Enum.Font.GothamBold
            bindBtn.TextSize = 10
            bindBtn.TextColor3 = Color3.new(1,1,1)
            bindBtn.BorderSizePixel = 0
            Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 6)
            local clearBtn = Instance.new("TextButton", row)
            clearBtn.Size = UDim2.new(0, 40, 0, 24)
            clearBtn.Position = UDim2.new(1, -45, 0.5, -12)
            clearBtn.BackgroundColor3 = THEME.Danger
            clearBtn.BackgroundTransparency = 0.3
            clearBtn.Text = "X"
            clearBtn.Font = Enum.Font.GothamBold
            clearBtn.TextSize = 11
            clearBtn.TextColor3 = Color3.new(1,1,1)
            clearBtn.BorderSizePixel = 0
            Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)
            bindBtn.MouseButton1Click:Connect(function()
                if listeningForBind == func.id then
                    listeningForBind = nil
                    bindBtn.Text = BINDS[func.id] and BINDS[func.id].Name or "Назначить"
                else
                    listeningForBind = func.id
                    bindBtn.Text = "ЖМИ КЛАВИШУ..."
                end
            end)
            clearBtn.MouseButton1Click:Connect(function()
                BINDS[func.id] = nil
                bindBtn.Text = "Назначить"
            end)
        end

    elseif currentTab == "owner" then
        if not isOwner and myRole ~= "Mops" then
            local c = makeCard("Нет доступа", 1)
            local lbl = Instance.new("TextLabel", c)
            lbl.Size = UDim2.new(1, -28, 0, 60)
            lbl.Position = UDim2.new(0, 14, 0, 56)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.Gotham
            lbl.Text = "Только Owner и Mops видят эту вкладку"
            lbl.TextColor3 = THEME.Danger
            lbl.TextSize = 12
            lbl.TextWrapped = true
            return
        end
        local c1 = makeCard("ВЫДАТЬ РОЛИ", 1)
        c1.Size = UDim2.new(0, 330, 0, 380)
        local playersScroll = Instance.new("ScrollingFrame", c1)
        playersScroll.Size = UDim2.new(1, -20, 0, 290)
        playersScroll.Position = UDim2.new(0, 10, 0, 60)
        playersScroll.BackgroundColor3 = THEME.Background
        playersScroll.BackgroundTransparency = 0.4
        playersScroll.BorderSizePixel = 0
        playersScroll.ScrollBarThickness = 3
        playersScroll.ScrollBarImageColor3 = THEME.Accent
        playersScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        Instance.new("UICorner", playersScroll).CornerRadius = UDim.new(0, 6)
        local listL = Instance.new("UIListLayout", playersScroll)
        listL.Padding = UDim.new(0, 4)
        listL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            playersScroll.CanvasSize = UDim2.new(0, 0, 0, listL.AbsoluteContentSize.Y + 8)
        end)
        local function refreshPlayers()
            for _, ch in ipairs(playersScroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            task.spawn(function()
                local grantedCache = getGrantedRoles() or {}
                for _, plr in ipairs(Players:GetPlayers()) do
                    local row = Instance.new("Frame", playersScroll)
                    row.Size = UDim2.new(1, -8, 0, 56)
                    row.BackgroundColor3 = THEME.Card
                    row.BackgroundTransparency = 0.3
                    row.BorderSizePixel = 0
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
                    local nL = Instance.new("TextLabel", row)
                    nL.Size = UDim2.new(1, -16, 0, 22)
                    nL.Position = UDim2.new(0, 10, 0, 4)
                    nL.BackgroundTransparency = 1
                    nL.Font = Enum.Font.GothamMedium
                    nL.Text = plr.Name .. (plr == LocalPlayer and " (ты)" or "")
                    nL.TextColor3 = THEME.Text
                    nL.TextSize = 11
                    nL.TextXAlignment = Enum.TextXAlignment.Left
                    local currentRole = grantedCache[plr.Name] or "Free"
                    local rLbl = Instance.new("TextLabel", row)
                    rLbl.Size = UDim2.new(0, 120, 0, 14)
                    rLbl.Position = UDim2.new(0, 10, 0, 26)
                    rLbl.BackgroundTransparency = 1
                    rLbl.Font = Enum.Font.Gotham
                    rLbl.Text = "Роль: " .. currentRole
                    rLbl.TextColor3 = ROLE_COLORS[currentRole] or THEME.TextDim
                    rLbl.TextSize = 9
                    rLbl.TextXAlignment = Enum.TextXAlignment.Left
                    local btnP = Instance.new("TextButton", row)
                    btnP.Size = UDim2.new(0, 70, 0, 22)
                    btnP.Position = UDim2.new(1, -160, 0, 30)
                    btnP.BorderSizePixel = 0
                    btnP.Font = Enum.Font.GothamBold
                    btnP.TextSize = 9
                    btnP.Text = "+Premium"
                    btnP.BackgroundColor3 = Color3.fromRGB(140, 90, 220)
                    btnP.TextColor3 = Color3.new(1, 1, 1)
                    Instance.new("UICorner", btnP).CornerRadius = UDim.new(0, 5)
                    local btnM = Instance.new("TextButton", row)
                    btnM.Size = UDim2.new(0, 70, 0, 22)
                    btnM.Position = UDim2.new(1, -85, 0, 30)
                    btnM.BorderSizePixel = 0
                    btnM.Font = Enum.Font.GothamBold
                    btnM.TextSize = 9
                    btnM.Text = "+Mops"
                    btnM.BackgroundColor3 = Color3.fromRGB(220, 100, 180)
                    btnM.TextColor3 = Color3.new(1, 1, 1)
                    Instance.new("UICorner", btnM).CornerRadius = UDim.new(0, 5)
                    btnP.MouseButton1Click:Connect(function()
                        if grantRoleCloud(plr.Name, "Premium") then
                            rLbl.Text = "Роль: Premium"
                            rLbl.TextColor3 = ROLE_COLORS.Premium
                        end
                    end)
                    btnM.MouseButton1Click:Connect(function()
                        if grantRoleCloud(plr.Name, "Mops") then
                            rLbl.Text = "Роль: Mops"
                            rLbl.TextColor3 = ROLE_COLORS.Mops
                        end
                    end)
                end
            end)
        end
        refreshPlayers()
        Players.PlayerAdded:Connect(function() task.wait(0.5) refreshPlayers() end)
        Players.PlayerRemoving:Connect(function() task.wait(0.5) refreshPlayers() end)

        local c2 = makeCard("ИГРАЮТ СО СКРИПТОМ", 2)
        c2.Size = UDim2.new(0, 330, 0, 380)
        local activeScroll = Instance.new("ScrollingFrame", c2)
        activeScroll.Size = UDim2.new(1, -20, 0, 290)
        activeScroll.Position = UDim2.new(0, 10, 0, 60)
        activeScroll.BackgroundColor3 = THEME.Background
        activeScroll.BackgroundTransparency = 0.4
        activeScroll.BorderSizePixel = 0
        activeScroll.ScrollBarThickness = 3
        activeScroll.ScrollBarImageColor3 = THEME.Accent
        activeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        Instance.new("UICorner", activeScroll).CornerRadius = UDim.new(0, 6)
        local aL = Instance.new("UIListLayout", activeScroll)
        aL.Padding = UDim.new(0, 4)
        aL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            activeScroll.CanvasSize = UDim2.new(0, 0, 0, aL.AbsoluteContentSize.Y + 8)
        end)
        local function refreshActive()
            for _, ch in ipairs(activeScroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            task.spawn(function()
                local record = _fetchBin()
                if not record or type(record.activeUsers) ~= "table" then return end
                for name, info in pairs(record.activeUsers) do
                    local row = Instance.new("Frame", activeScroll)
                    row.Size = UDim2.new(1, -8, 0, 30)
                    row.BackgroundColor3 = THEME.Card
                    row.BackgroundTransparency = 0.3
                    row.BorderSizePixel = 0
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
                    local rl = type(info) == "table" and info.role or "User"
                    local lbl = Instance.new("TextLabel", row)
                    lbl.Size = UDim2.new(1, -10, 1, 0)
                    lbl.Position = UDim2.new(0, 10, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.GothamMedium
                    lbl.Text = "[" .. rl .. "] " .. name
                    lbl.TextColor3 = ROLE_COLORS[rl] or THEME.Text
                    lbl.TextSize = 11
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                end
            end)
        end
        refreshActive()
        task.spawn(function()
            while activeScroll.Parent do
                task.wait(15)
                refreshActive()
            end
        end)

    elseif currentTab == "main" then
        local c1 = makeCard("Информация", 1)
        local info = Instance.new("TextLabel", c1)
        info.Size = UDim2.new(1, -28, 0, 140)
        info.Position = UDim2.new(0, 14, 0, 56)
        info.BackgroundTransparency = 1
        info.Font = Enum.Font.Gotham
        info.Text = "Mops Hub v10.4\n\nRIGHT SHIFT — меню\nM — кнопка\nЧАТ и CFG — сверху\n\nOwner: Kikisk234"
        info.TextColor3 = THEME.TextDim
        info.TextSize = 11
        info.TextWrapped = true
        info.TextXAlignment = Enum.TextXAlignment.Left
    end
end

makeTab("main", "M", "Главная")
makeTab("combat", "C", "Бой")
makeTab("movement", "MV", "Движение")
makeTab("render", "R", "Графика")
makeTab("misc", "MI", "Разное")
makeTab("binds", "B", "Бинды")

addOwnerTab = function()
    if not isOwner and myRole ~= "Mops" then return end
    if sidebarButtons["owner"] then return end
    makeTab("owner", "AD", "Админ")
    -- автоматически открываем вкладку
    currentTab = "owner"
    for tid, d in pairs(sidebarButtons) do
        if tid == "owner" then
            d.button.BackgroundColor3 = THEME.AccentDim
            d.button.BackgroundTransparency = 0.1
            d.icon.TextColor3 = Color3.new(1,1,1)
            d.label.TextColor3 = Color3.new(1,1,1)
        else
            d.button.BackgroundColor3 = THEME.Sidebar
            d.button.BackgroundTransparency = 1
            d.icon.TextColor3 = THEME.TextDim
            d.label.TextColor3 = THEME.TextDim
        end
    end
    rebuildContent()
    print("[MopsHub] Вкладка Админ добавлена")
end

sidebarButtons["combat"].button.BackgroundColor3 = THEME.AccentDim
sidebarButtons["combat"].button.BackgroundTransparency = 0.1
sidebarButtons["combat"].icon.TextColor3 = Color3.new(1,1,1)
sidebarButtons["combat"].label.TextColor3 = Color3.new(1,1,1)
rebuildContent()

-- ИНИЦИАЛИЗАЦИЯ
task.spawn(function()
    task.wait(0.5)
    local savedRole = loadSavedRole()
    if savedRole == "Owner" then
        isOwner = true
        ownerPasswordUsed = true
        myRole = "Owner"
        addOwnerTab()
        if hudRole then
            hudRole.Text = myRole
            hudRole.TextColor3 = ROLE_COLORS[myRole]
        end
    elseif savedRole == "Mops" then
        myRole = "Mops"
        addOwnerTab()
        if hudRole then
            hudRole.Text = myRole
            hudRole.TextColor3 = ROLE_COLORS.Mops
        end
    elseif savedRole then
        myRole = savedRole
        if hudRole then
            hudRole.Text = myRole
            hudRole.TextColor3 = ROLE_COLORS[myRole] or THEME.Text
        end
    else
        showRoleSelection(function(chosenRole)
            myRole = chosenRole
            if chosenRole == "Owner" then
                isOwner = true
                ownerPasswordUsed = true
                addOwnerTab()
            elseif chosenRole == "Mops" then
                addOwnerTab()
            end
            if hudRole then
                hudRole.Text = myRole
                hudRole.TextColor3 = ROLE_COLORS[myRole] or THEME.Text
            end
        end)
    end

    -- ВАЖНО: применяем выданные роли из облака при старте
    task.spawn(function()
        task.wait(2)
        local record = _fetchBin()
        if record and record.grantedRoles and record.grantedRoles[LocalPlayer.Name] then
            local cloudRole = record.grantedRoles[LocalPlayer.Name]
            if cloudRole ~= myRole then
                myRole = cloudRole
                saveRole(cloudRole)
                if hudRole then
                    hudRole.Text = myRole
                    hudRole.TextColor3 = ROLE_COLORS[myRole] or THEME.Text
                end
                if cloudRole == "Owner" then
                    isOwner = true
                    ownerPasswordUsed = true
                    addOwnerTab()
                elseif cloudRole == "Mops" then
                    addOwnerTab()
                end
            end
        end
        local used = checkCloudOwnerFlag()
        if used and not isOwner then ownerPasswordUsed = true end
    end)

    sendHeartbeat()

    task.spawn(function()
        while true do
            task.wait(CHAT_READ_INTERVAL)
            if chatWindow and chatWindow.Visible and chatBuilt then
                loadChatMessages()
                renderChatMessages()
            end
        end
    end)
end)

-- ОБРАБОТКА КЛАВИШ
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if listeningForBind then
        if input.KeyCode == Enum.KeyCode.Escape then
            listeningForBind = nil
            rebuildContent()
            return
        end
        local funcId = listeningForBind
        listeningForBind = nil
        for otherId, data in pairs(BINDS) do
            if data.KeyCode == input.KeyCode then BINDS[otherId] = nil end
        end
        BINDS[funcId] = { KeyCode = input.KeyCode, Name = input.KeyCode.Name }
        rebuildContent()
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "MOPS HUB",
                Text = "Бинд: " .. input.KeyCode.Name,
                Duration = 2,
            })
        end)
        return
    end

    if input.KeyCode == Enum.KeyCode.RightShift then
        setMenuVisible(not main.Visible)
        return
    end

    for funcId, data in pairs(BINDS) do
        if data.KeyCode == input.KeyCode then
            executeBind(funcId)
        end
    end
end)

print("[Mops Hub v10.4] Загружен. RIGHT SHIFT — открыть.")
