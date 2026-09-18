--=========================================================
--  MOPS HUB v9.5 | Chat + Config as separate windows (fixed)
--  RIGHT SHIFT ili [M] - otkryt
--=========================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local VirtualUser      = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")
local LocalPlayer      = Players.LocalPlayer

--==================== KONFIG ====================
local CHAT_BIN_ID  = "6aad8f9eac6210605add8f0e"
local CHAT_API_KEY = "$2a$10$vZdDG8nnlVaB49BU4pgVXuewjJqoiwTtYyjdE5tZ6tKh.HyOFKXAK"
local CHAT_READ_INTERVAL = 6
local PASTEBIN_RAW = "https://pastebin.com/raw/Mj77ghwX"
local CHECK_INTERVAL = 15
local CHAT_URL = "https://api.jsonbin.io/v3/b/" .. CHAT_BIN_ID
local OWNER_FLAG_FILE = "MopsHub_Owner.txt"
local ROLE_FILE = "MopsHub_Role.txt"
local CONFIG_FOLDER = "MopsHub/Configs"
local KEY_PREFIX = "MOPS-"

--==================== SHIFROVKA PAROLYA ====================
local _ENCODED_PASS = "S2lzaXNrMjM0"

local function _b64decode(data)
    local b64table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    data = string.gsub(data, '[^' .. b64table .. '=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b64table:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end
        return string.char(c)
    end))
end

local function _decodePass()
    return _b64decode(_ENCODED_PASS)
end

local function checkPassword(input)
    if not input or input == "" then return false end
    return input == _decodePass()
end

--==================== TEMA ====================
local THEME = {
    Background  = Color3.fromRGB(22, 22, 30),
    Sidebar     = Color3.fromRGB(16, 16, 24),
    Card        = Color3.fromRGB(30, 30, 42),
    Accent      = Color3.fromRGB(140, 110, 255),
    AccentLight = Color3.fromRGB(170, 140, 255),
    AccentDim   = Color3.fromRGB(85, 65, 190),
    Text        = Color3.fromRGB(240, 240, 250),
    TextDim     = Color3.fromRGB(150, 150, 170),
    TextFaint   = Color3.fromRGB(95, 95, 115),
    Border      = Color3.fromRGB(50, 50, 68),
    BorderLight = Color3.fromRGB(70, 70, 95),
    Danger      = Color3.fromRGB(230, 70, 90),
    Success     = Color3.fromRGB(90, 220, 130),
    Gold        = Color3.fromRGB(255, 200, 40),
    Mops        = Color3.fromRGB(255, 100, 200),
    Premium     = Color3.fromRGB(180, 100, 255),
}

local ROLE_COLORS = {
    Owner     = Color3.fromRGB(255, 200, 40),
    Mops      = Color3.fromRGB(255, 100, 200),
    Premium   = Color3.fromRGB(180, 100, 255),
    Moderator = Color3.fromRGB(230, 70, 90),
    VIP       = Color3.fromRGB(180, 100, 255),
    Free      = Color3.fromRGB(180, 180, 200),
    User      = Color3.fromRGB(200, 200, 220),
}
local ROLE_ICONS = {
    Owner = "OWN", Mops = "MOPS", Premium = "PRM",
    Moderator = "MOD", VIP = "VIP", Free = "FREE", User = "USER",
}
local ROLE_EMOJI = {
    Owner = "[OWNER]", Mops = "[MOPS]", Premium = "[PREMIUM]",
    Moderator = "[MOD]", VIP = "[VIP]", Free = "[FREE]", User = "[USER]",
}

local ALL_CONNECTIONS = {}
local function track(conn) table.insert(ALL_CONNECTIONS, conn) return conn end
local STATE = { Maintenance = false }

local CONFIG = {
    KillAura = false, KillAuraNoDmg = false, KillRange = 50, KillDamage = 999, KillDelay = 0.1,
    AutoFarm = false, FarmRange = 300, FarmMode = "Walk",
    AutoRebirth = false, RebirthDelay = 2,
    Fling = false, FlingAll = false, AntiFling = false,
    Speed = false, WalkSpeed = 50,
    Noclip = false, InfiniteJump = false,
    Fly = false, FlySpeed = 50,
    Bhop = false, BhopGain = 2, BhopMax = 150,
    Spin = false, SpinSpeed = 20,
    Aura = false, ESP = false,
    Fullbright = false, NoFog = false,
    AntiAfk = false,
}
local BINDS = {}
local conns = {}
local screenGui, main, openBtn, hud, contentScroll, hudRole
local chatWindow, configWindow
local allCards = {}

--==================== ROL ====================
local myRole = "Free"
local isOwner = false
local ownerPasswordUsed = false
local grantedRolesCache = {}

local function loadSavedRole()
    if not (isfile and readfile) then return nil end
    if not isfile(ROLE_FILE) then return nil end
    local ok, data = pcall(function() return readfile(ROLE_FILE) end)
    if ok and data then
        local clean = data:gsub("%s", "")
        if ROLE_ICONS[clean] then return clean end
    end
    return nil
end

local function saveRole(role)
    if not (writefile and isfile) then return end
    pcall(function() writefile(ROLE_FILE, role) end)
end

--==================== HTTP ====================
local function httpGet(url, headers)
    if syn and syn.request then
        local r = syn.request({Url = url, Method = "GET", Headers = headers})
        return r and r.Body
    elseif http and http.request then
        local r = http.request({Url = url, Method = "GET", Headers = headers})
        return r and r.Body
    elseif request then
        local r = request({Url = url, Method = "GET", Headers = headers})
        return r and r.Body
    end
end

local function httpPut(url, body, headers)
    if syn and syn.request then
        local r = syn.request({Url = url, Method = "PUT", Body = body, Headers = headers})
        return r and r.Body
    elseif http and http.request then
        local r = http.request({Url = url, Method = "PUT", Body = body, Headers = headers})
        return r and r.Body
    elseif request then
        local r = request({Url = url, Method = "PUT", Body = body, Headers = headers})
        return r and r.Body
    end
end

--==================== OBLAKO ====================
local function _fetchBin()
    local raw = httpGet(CHAT_URL .. "/latest", {["X-Master-Key"] = CHAT_API_KEY})
    if not raw then return nil end
    local decoded
    pcall(function() decoded = HttpService:JSONDecode(raw) end)
    if not decoded or not decoded.record then return nil end
    if type(decoded.record) ~= "table" then return nil end
    return decoded.record
end

local function _pushBin(record)
    if not record or type(record) ~= "table" then return end
    record.messages = record.messages or {}
    httpPut(CHAT_URL, HttpService:JSONEncode(record), {
        ["Content-Type"] = "application/json",
        ["X-Master-Key"] = CHAT_API_KEY,
    })
end

local function checkCloudOwnerFlag()
    local record = _fetchBin()
    if not record then return false end
    return record.ownerTaken == true
end

local function setCloudOwnerFlag(ownerName)
    local record = _fetchBin()
    if not record then return end
    record.ownerTaken = true
    record.ownerName = ownerName
    _pushBin(record)
end

local function grantRoleCloud(targetName, role)
    local record = _fetchBin()
    if not record then return false end
    record.grantedRoles = record.grantedRoles or {}
    if role == "Free" or role == nil then
        record.grantedRoles[targetName] = nil
    else
        record.grantedRoles[targetName] = role
    end
    _pushBin(record)
    grantedRolesCache[targetName] = role
    return true
end

local function getGrantedRoles()
    local record = _fetchBin()
    if not record then return {} end
    return record.grantedRoles or {}
end

local function sendHeartbeat()
    task.spawn(function()
        task.wait(3)
        while true do
            pcall(function()
                local record = _fetchBin()
                if record then
                    record.activeUsers = record.activeUsers or {}
                    record.activeUsers[LocalPlayer.Name] = {
                        role = myRole,
                        time = os.time(),
                    }
                    for n, info in pairs(record.activeUsers) do
                        if type(info) == "table" and os.time() - (info.time or 0) > 60 then
                            record.activeUsers[n] = nil
                        end
                    end
                    _pushBin(record)
                end
            end)
            task.wait(20)
        end
    end)
end

--==================== KONFIGI ====================
local function hasFileAPI()
    return writefile and readfile and isfile and listfiles and delfile and makefolder
end

local function ensureFolder()
    if not hasFileAPI() then return false end
    pcall(function()
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
    end)
    return true
end

local function saveLocalConfig(name)
    if not hasFileAPI() then return false, "Executor bez failov" end
    ensureFolder()
    local data = {}
    for k, v in pairs(CONFIG) do
        if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
            data[k] = v
        end
    end
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    local ok, err = pcall(function() writefile(path, HttpService:JSONEncode(data)) end)
    return ok, ok and path or err
end

local function loadLocalConfig(name)
    if not hasFileAPI() then return false, "Executor bez failov" end
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    if not isfile(path) then return false, "Ne najden" end
    local ok, content = pcall(function() return readfile(path) end)
    if not ok then return false, "Oshibka chteniya" end
    local decoded
    pcall(function() decoded = HttpService:JSONDecode(content) end)
    if type(decoded) ~= "table" then return false, "Oshibka formata" end
    for k, v in pairs(decoded) do
        if CONFIG[k] ~= nil then CONFIG[k] = v end
    end
    return true
end

local function deleteLocalConfig(name)
    if not hasFileAPI() then return false end
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    if isfile(path) then pcall(function() delfile(path) end) end
    return true
end

local function listLocalConfigs()
    if not hasFileAPI() then return {} end
    ensureFolder()
    local configs = {}
    local ok, files = pcall(function() return listfiles(CONFIG_FOLDER) end)
    if ok and files then
        for _, f in ipairs(files) do
            local name = f:match("([^/\\]+)%.json$")
            if name then table.insert(configs, name) end
        end
    end
    table.sort(configs)
    return configs
end

--==================== BASE64 ====================
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function base64Encode(data)
    return ((data:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
        return b64chars:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

local function base64Decode(data)
    data = string.gsub(data, '[^' .. b64chars .. '=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r, f = '', (b64chars:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end
        return string.char(c)
    end))
end

local function generateKey()
    local data = {}
    for k, v in pairs(CONFIG) do
        if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
            data[k] = v
        end
    end
    return KEY_PREFIX .. base64Encode(HttpService:JSONEncode(data))
end

local function activateKey(key)
    if not key or #key < 8 then return false, "Klyuch slishkom korotkij" end
    key = key:gsub("%s", "")
    if key:sub(1, #KEY_PREFIX) == KEY_PREFIX then
        key = key:sub(#KEY_PREFIX + 1)
    end
    local ok, json = pcall(function() return base64Decode(key) end)
    if not ok or not json or json == "" then return false, "Oshibka dekodirovaniya" end
    local data
    pcall(function() data = HttpService:JSONDecode(json) end)
    if type(data) ~= "table" then return false, "Nevernyj format klyucha" end
    local applied = 0
    for k, v in pairs(data) do
        if CONFIG[k] ~= nil then
            CONFIG[k] = v
            applied = applied + 1
        end
    end
    if applied == 0 then return false, "V klyuche net izvestnyh nastroek" end
    return true, applied
end

local function copyToClipboard(text)
    if setclipboard then
        pcall(function() setclipboard(text) end)
        return true
    end
    return false
end

--==================== PROMPT OWNER ====================
function showOwnerPasswordPrompt(onComplete)
    if isOwner then
        if onComplete then onComplete(true) end
        return
    end

    local promptGui = Instance.new("ScreenGui")
    promptGui.Name = "MopsOwnerPrompt"
    promptGui.ResetOnSpawn = false
    pcall(function() promptGui.Parent = game:GetService("CoreGui") end)
    if not promptGui.Parent then
        promptGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local bg = Instance.new("Frame", promptGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.BorderSizePixel = 0

    local box = Instance.new("Frame", promptGui)
    box.Size = UDim2.new(0, 420, 0, 240)
    box.Position = UDim2.new(0.5, -210, 0.5, -120)
    box.BackgroundColor3 = THEME.Background
    box.BackgroundTransparency = 0
    box.BorderSizePixel = 0
    box.ZIndex = 200
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)
    local bS = Instance.new("UIStroke", box)
    bS.Color = THEME.Gold bS.Thickness = 2 bS.Transparency = 0

    local title = Instance.new("TextLabel", box)
    title.Size = UDim2.new(1, -40, 0, 34)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = "VHOD V OWNER"
    title.TextColor3 = THEME.Gold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 201

    local sub = Instance.new("TextLabel", box)
    sub.Size = UDim2.new(1, -40, 0, 30)
    sub.Position = UDim2.new(0, 20, 0, 54)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.Text = "Vvedi parol vladeltsa"
    sub.TextColor3 = THEME.TextDim
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Center
    sub.ZIndex = 201

    local passBox = Instance.new("TextBox", box)
    passBox.Size = UDim2.new(1, -40, 0, 40)
    passBox.Position = UDim2.new(0, 20, 0, 92)
    passBox.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    passBox.BackgroundTransparency = 0
    passBox.BorderSizePixel = 0
    passBox.PlaceholderText = "Parol..."
    passBox.Text = ""
    passBox.TextColor3 = THEME.Text
    passBox.PlaceholderColor3 = THEME.TextDim
    passBox.Font = Enum.Font.Gotham
    passBox.TextSize = 14
    passBox.ZIndex = 201
    Instance.new("UICorner", passBox).CornerRadius = UDim.new(0, 8)

    local statusLbl = Instance.new("TextLabel", box)
    statusLbl.Size = UDim2.new(1, -40, 0, 20)
    statusLbl.Position = UDim2.new(0, 20, 0, 138)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.Text = ""
    statusLbl.TextColor3 = THEME.Danger
    statusLbl.TextSize = 11
    statusLbl.TextXAlignment = Enum.TextXAlignment.Center
    statusLbl.ZIndex = 201

    local confirmBtn = Instance.new("TextButton", box)
    confirmBtn.Size = UDim2.new(1, -40, 0, 38)
    confirmBtn.Position = UDim2.new(0, 20, 0, 162)
    confirmBtn.BackgroundColor3 = THEME.Gold
    confirmBtn.BorderSizePixel = 0
    confirmBtn.Text = "PODTVERDIT"
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 13
    confirmBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
    confirmBtn.ZIndex = 201
    Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)

    local cancelBtn = Instance.new("TextButton", box)
    cancelBtn.Size = UDim2.new(0, 80, 0, 22)
    cancelBtn.Position = UDim2.new(0.5, -40, 1, -28)
    cancelBtn.BackgroundTransparency = 1
    cancelBtn.Text = "Otmena"
    cancelBtn.Font = Enum.Font.Gotham
    cancelBtn.TextSize = 11
    cancelBtn.TextColor3 = THEME.TextFaint
    cancelBtn.ZIndex = 201

    local submitted = false

    local function trySubmit()
        if submitted then return end
        if checkPassword(passBox.Text) then
            submitted = true
            isOwner = true
            ownerPasswordUsed = true
            myRole = "Owner"

            if writefile and isfile then
                pcall(function() writefile(OWNER_FLAG_FILE, "used") end)
            end
            saveRole("Owner")

            task.spawn(function() setCloudOwnerFlag(LocalPlayer.Name) end)

            statusLbl.TextColor3 = THEME.Success
            statusLbl.Text = "Uspehno!"
            task.wait(0.6)
            promptGui:Destroy()
            if onComplete then onComplete(true) end
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "MOPS HUB", Text = "Owner aktivirovan!", Duration = 4,
                })
            end)
        else
            statusLbl.TextColor3 = THEME.Danger
            statusLbl.Text = "Nevernyj parol"
            passBox.Text = ""
        end
    end

    confirmBtn.MouseButton1Click:Connect(trySubmit)
    passBox.FocusLost:Connect(function(enter)
        if enter then trySubmit() end
    end)
    cancelBtn.MouseButton1Click:Connect(function()
        promptGui:Destroy()
        if onComplete then onComplete(false) end
    end)
end

--==================== VYBOR ROLI ====================
local function showRoleSelection(onDone)
    local selGui = Instance.new("ScreenGui")
    selGui.Name = "MopsRoleSelect"
    selGui.ResetOnSpawn = false
    selGui.IgnoreGuiInset = true
    pcall(function() selGui.Parent = game:GetService("CoreGui") end)
    if not selGui.Parent then
        selGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local bg = Instance.new("Frame", selGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.4
    bg.BorderSizePixel = 0

    local box = Instance.new("Frame", selGui)
    box.Size = UDim2.new(0, 520, 0, 480)
    box.Position = UDim2.new(0.5, -260, 0.5, -240)
    box.BackgroundColor3 = THEME.Background
    box.BackgroundTransparency = 0
    box.BorderSizePixel = 0
    box.ZIndex = 200
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)
    local bS = Instance.new("UIStroke", box)
    bS.Color = THEME.Accent bS.Thickness = 1.5 bS.Transparency = 0

    local title = Instance.new("TextLabel", box)
    title.Size = UDim2.new(1, -40, 0, 36)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = "VYBERI SVOYU ROL"
    title.TextColor3 = THEME.Text
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 201

    local sub = Instance.new("TextLabel", box)
    sub.Size = UDim2.new(1, -40, 0, 24)
    sub.Position = UDim2.new(0, 20, 0, 58)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.Text = "Znachok otobrazhaetsya v chate MOPS HUB"
    sub.TextColor3 = THEME.TextDim
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Center
    sub.ZIndex = 201

    local function makeRoleBtn(y, role, desc, color, icon, needsPass)
        local btn = Instance.new("TextButton", box)
        btn.Size = UDim2.new(1, -40, 0, 66)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = THEME.Card
        btn.BackgroundTransparency = 0
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 201
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        local bs = Instance.new("UIStroke", btn)
        bs.Color = color bs.Thickness = 1.5 bs.Transparency = 0.2

        local ic = Instance.new("TextLabel", btn)
        ic.Size = UDim2.new(0, 70, 1, 0)
        ic.Position = UDim2.new(0, 10, 0, 0)
        ic.BackgroundTransparency = 1
        ic.Font = Enum.Font.GothamBold
        ic.Text = icon
        ic.TextColor3 = color
        ic.TextSize = 14
        ic.ZIndex = 202

        local nm = Instance.new("TextLabel", btn)
        nm.Size = UDim2.new(1, -160, 0, 26)
        nm.Position = UDim2.new(0, 90, 0, 10)
        nm.BackgroundTransparency = 1
        nm.Font = Enum.Font.GothamBold
        nm.Text = role
        nm.TextColor3 = color
        nm.TextSize = 17
        nm.TextXAlignment = Enum.TextXAlignment.Left
        nm.ZIndex = 202

        local ds = Instance.new("TextLabel", btn)
        ds.Size = UDim2.new(1, -160, 0, 20)
        ds.Position = UDim2.new(0, 90, 0, 36)
        ds.BackgroundTransparency = 1
        ds.Font = Enum.Font.Gotham
        ds.Text = desc
        ds.TextColor3 = THEME.TextDim
        ds.TextSize = 11
        ds.TextXAlignment = Enum.TextXAlignment.Left
        ds.ZIndex = 202

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
            TweenService:Create(bs, TweenInfo.new(0.15), {Transparency = 0}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
            TweenService:Create(bs, TweenInfo.new(0.15), {Transparency = 0.5}):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            if needsPass then
                if isOwner then
                    myRole = "Owner"
                    saveRole("Owner")
                    selGui:Destroy()
                    if onDone then onDone("Owner") end
                    return
                end
                showOwnerPasswordPrompt(function(success)
                    if success then
                        selGui:Destroy()
                        if onDone then onDone("Owner") end
                    end
                end)
            else
                myRole = role
                saveRole(role)
                TweenService:Create(box, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                }):Play()
                task.wait(0.35)
                selGui:Destroy()
                if onDone then onDone(role) end
                pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "MOPS HUB",
                        Text = "Rol: " .. role,
                        Duration = 3,
                    })
                end)
            end
        end)
    end

    makeRoleBtn(90,  "Free",    "Bazovyj dostup",           ROLE_COLORS.Free,    "FREE",    false)
    makeRoleBtn(166, "Premium", "Znachok PREMIUM v chate",  ROLE_COLORS.Premium, "PREMIUM", false)
    makeRoleBtn(242, "Mops",    "Znachok MOPS v chate",     ROLE_COLORS.Mops,    "MOPS",    false)
    makeRoleBtn(318, "Owner",   "Trebuyetsya parol",        ROLE_COLORS.Owner,   "OWNER",   true)

    local warn = Instance.new("TextLabel", box)
    warn.Size = UDim2.new(1, -40, 0, 20)
    warn.Position = UDim2.new(0, 20, 1, -30)
    warn.BackgroundTransparency = 1
    warn.Font = Enum.Font.Gotham
    warn.Text = "Rol sohranyaetsya na ustrojstve"
    warn.TextColor3 = THEME.TextFaint
    warn.TextSize = 10
    warn.TextXAlignment = Enum.TextXAlignment.Center
    warn.ZIndex = 201
end

--==================== TEH RABOTY ====================
local maintenanceBanner = nil
local function createMaintenanceBanner()
    if maintenanceBanner then return end
    if not screenGui then return end
    local banner = Instance.new("Frame")
    banner.Size = UDim2.new(1, 0, 1, 0)
    banner.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
    banner.BackgroundTransparency = 0.3
    banner.BorderSizePixel = 0
    banner.ZIndex = 999
    banner.Parent = screenGui
    local lbl = Instance.new("TextLabel", banner)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBlack
    lbl.Text = "TEH RABOTY"
    lbl.TextColor3 = Color3.fromRGB(255, 30, 30)
    lbl.TextSize = 120
    lbl.TextStrokeTransparency = 0
    lbl.ZIndex = 1000
    task.spawn(function()
        while banner.Parent do
            for i = 0, 1, 0.05 do
                if not banner.Parent then return end
                lbl.TextTransparency = 0.3 + math.abs(math.sin(i * math.pi)) * 0.5
                task.wait(0.03)
            end
        end
    end)
    local sub = Instance.new("TextLabel", banner)
    sub.Size = UDim2.new(1, 0, 0, 40)
    sub.Position = UDim2.new(0, 0, 0.5, 90)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.GothamBold
    sub.Text = "Skript vremenno nedostupen."
    sub.TextColor3 = Color3.fromRGB(255, 180, 180)
    sub.TextSize = 20
    sub.ZIndex = 1000
    maintenanceBanner = banner
end

local function removeMaintenanceBanner()
    if maintenanceBanner then
        pcall(function() maintenanceBanner:Destroy() end)
        maintenanceBanner = nil
    end
end

local function stopAllFunctions()
    for k, v in pairs(conns) do
        if type(v) == "table" and v.Disconnect then pcall(function() v:Disconnect() end) end
    end
    conns = {}
    for k in pairs(CONFIG) do
        if type(CONFIG[k]) == "boolean" then CONFIG[k] = false end
    end
end

local function applyMaintenance(state)
    STATE.Maintenance = state
    if state then
        stopAllFunctions()
        createMaintenanceBanner()
        if main then main.Visible = false end
        if openBtn then openBtn.Visible = false end
        if hud then hud.Visible = false end
        if chatWindow then chatWindow.Visible = false end
        if configWindow then configWindow.Visible = false end
    else
        removeMaintenanceBanner()
        if openBtn then openBtn
