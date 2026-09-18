--=========================================================
--  MOPS HUB v9.4 | Chat + Config as separate windows
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
    box.BorderSizePixel = 0
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)
    local bS = Instance.new("UIStroke", box)
    bS.Color = THEME.Gold bS.Thickness = 2 bS.Transparency = 0.2

    local title = Instance.new("TextLabel", box)
    title.Size = UDim2.new(1, -40, 0, 34)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = "VHOD V OWNER"
    title.TextColor3 = THEME.Gold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Center

    local sub = Instance.new("TextLabel", box)
    sub.Size = UDim2.new(1, -40, 0, 30)
    sub.Position = UDim2.new(0, 20, 0, 54)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.Text = "Vvedi parol vladeltsa"
    sub.TextColor3 = THEME.TextDim
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Center

    local passBox = Instance.new("TextBox", box)
    passBox.Size = UDim2.new(1, -40, 0, 40)
    passBox.Position = UDim2.new(0, 20, 0, 92)
    passBox.BackgroundColor3 = THEME.Card
    passBox.BorderSizePixel = 0
    passBox.PlaceholderText = "Parol..."
    passBox.Text = ""
    passBox.TextColor3 = THEME.Text
    passBox.PlaceholderColor3 = THEME.TextDim
    passBox.Font = Enum.Font.Gotham
    passBox.TextSize = 14
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

    local confirmBtn = Instance.new("TextButton", box)
    confirmBtn.Size = UDim2.new(1, -40, 0, 38)
    confirmBtn.Position = UDim2.new(0, 20, 0, 162)
    confirmBtn.BackgroundColor3 = THEME.Gold
    confirmBtn.BorderSizePixel = 0
    confirmBtn.Text = "PODTVERDIT"
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 13
    confirmBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)

    local cancelBtn = Instance.new("TextButton", box)
    cancelBtn.Size = UDim2.new(0, 80, 0, 22)
    cancelBtn.Position = UDim2.new(0.5, -40, 1, -28)
    cancelBtn.BackgroundTransparency = 1
    cancelBtn.Text = "Otmena"
    cancelBtn.Font = Enum.Font.Gotham
    cancelBtn.TextSize = 11
    cancelBtn.TextColor3 = THEME.TextFaint

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
    box.BorderSizePixel = 0
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)
    local bS = Instance.new("UIStroke", box)
    bS.Color = THEME.Accent bS.Thickness = 1.5 bS.Transparency = 0.3

    local title = Instance.new("TextLabel", box)
    title.Size = UDim2.new(1, -40, 0, 36)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = "VYBERI SVOYU ROL"
    title.TextColor3 = THEME.Text
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Center

    local sub = Instance.new("TextLabel", box)
    sub.Size = UDim2.new(1, -40, 0, 24)
    sub.Position = UDim2.new(0, 20, 0, 58)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.Text = "Znachok otobrazhaetsya v chate MOPS HUB"
    sub.TextColor3 = THEME.TextDim
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Center

    local function makeRoleBtn(y, role, desc, color, icon, needsPass)
        local btn = Instance.new("TextButton", box)
        btn.Size = UDim2.new(1, -40, 0, 66)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = THEME.Card
        btn.BackgroundTransparency = 0.2
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        local bs = Instance.new("UIStroke", btn)
        bs.Color = color bs.Thickness = 1.5 bs.Transparency = 0.5

        local ic = Instance.new("TextLabel", btn)
        ic.Size = UDim2.new(0, 70, 1, 0)
        ic.Position = UDim2.new(0, 10, 0, 0)
        ic.BackgroundTransparency = 1
        ic.Font = Enum.Font.GothamBold
        ic.Text = icon
        ic.TextColor3 = color
        ic.TextSize = 14

        local nm = Instance.new("TextLabel", btn)
        nm.Size = UDim2.new(1, -160, 0, 26)
        nm.Position = UDim2.new(0, 90, 0, 10)
        nm.BackgroundTransparency = 1
        nm.Font = Enum.Font.GothamBold
        nm.Text = role
        nm.TextColor3 = color
        nm.TextSize = 17
        nm.TextXAlignment = Enum.TextXAlignment.Left

        local ds = Instance.new("TextLabel", btn)
        ds.Size = UDim2.new(1, -160, 0, 20)
        ds.Position = UDim2.new(0, 90, 0, 36)
        ds.BackgroundTransparency = 1
        ds.Font = Enum.Font.Gotham
        ds.Text = desc
        ds.TextColor3 = THEME.TextDim
        ds.TextSize = 11
        ds.TextXAlignment = Enum.TextXAlignment.Left

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
        if openBtn then openBtn.Visible = true end
        if hud then hud.Visible = true end
    end
end

local function isBlocked()
    if STATE.Maintenance then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "MOPS HUB", Text = "TEH RABOTY", Duration = 2,
            })
        end)
        return true
    end
    return false
end

task.spawn(function()
    while true do
        pcall(function()
            local ok, response = pcall(function()
                return game:HttpGet(PASTEBIN_RAW .. "?t=" .. tick())
            end)
            if ok and response then
                local text = tostring(response):lower():gsub("%s", "")
                local isOn = text:find("^on") ~= nil
                local isOff = text:find("^off") ~= nil
                local newState = isOn and not isOff
                if newState ~= STATE.Maintenance then
                    applyMaintenance(newState)
                end
            end
        end)
        task.wait(CHECK_INTERVAL)
    end
end)

--==================== IGROVYE FUNKCII ====================
local function fling(targetChar)
    if isBlocked() then return false end
    if not targetChar then return false end
    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local hum = targetChar:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        local part = Instance.new("Part")
        part.Size = Vector3.new(2, 2, 2)
        part.Transparency = 1
        part.CanCollide = false
        part.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
        part.Parent = workspace
        local weld = Instance.new("Weld")
        weld.Part0 = hrp weld.Part1 = part
        weld.C0 = CFrame.new(0, 3, 0)
        weld.Parent = part
        local rv = Instance.new("BodyAngularVelocity")
        rv.AngularVelocity = Vector3.new(999999, 999999, 999999)
        rv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        rv.P = 999999 rv.Parent = part
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, 999999, 0)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = part
        task.delay(0.8, function() pcall(function()
            rv:Destroy() bv:Destroy() weld:Destroy() part:Destroy()
        end) end)
    end)
    return true
end

local function getBotContainers()
    local list, seen = {}, {}
    for _, n in ipairs({"NPCs","Enemies","Mobs","Monsters","Bots","Dummies","Targets","Units","Characters","Creatures","Zombies"}) do
        local c = workspace:FindFirstChild(n)
        if c and not seen[c] then seen[c] = true table.insert(list, c) end
    end
    if not seen[workspace] then table.insert(list, workspace) end
    return list
end

local function isBot(model)
    if not model or not model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    return true
end

local function findNearestBot(range)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local nearest, minDist = nil, range
    for _, cont in ipairs(getBotContainers()) do
        if cont and cont.Parent then
            for _, child in ipairs(cont:GetChildren()) do
                if isBot(child) then
                    local root = child:FindFirstChild("HumanoidRootPart")
                    if root then
                        local d = (root.Position - myRoot.Position).Magnitude
                        if d <= minDist then
                            nearest = {model = child, humanoid = child:FindFirstChildOfClass("Humanoid"), root = root, dist = d}
                            minDist = d
                        end
                    end
                end
            end
        end
    end
    return nearest
end

local function startKillAura()
    if isBlocked() then return end
    if conns.ka then conns.ka:Disconnect() end
    local lastHit = 0
    conns.ka = RunService.Heartbeat:Connect(function()
        if STATE.Maintenance then return end
        if tick() - lastHit < CONFIG.KillDelay then return end
        local target = findNearestBot(CONFIG.KillRange)
        if not target then return end
        if not CONFIG.KillAuraNoDmg then
            pcall(function() target.humanoid:TakeDamage(CONFIG.KillDamage) end)
            pcall(function() target.humanoid.Health = target.humanoid.Health - CONFIG.KillDamage end)
        end
        lastHit = tick()
    end)
    track(conns.ka)
end
local function stopKillAura() if conns.ka then conns.ka:Disconnect() conns.ka = nil end end

local function startAutoFarm()
    if isBlocked() then return end
    if conns.farm then conns.farm:Disconnect() end
    conns.farm = RunService.Heartbeat:Connect(function()
        if STATE.Maintenance then return end
        if not CONFIG.AutoFarm then return end
        local char = LocalPlayer.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not myRoot or not hum then return end
        local target = findNearestBot(CONFIG.FarmRange)
        if not target then hum:Move(Vector3.zero, false) return end
        local dist = (target.root.Position - myRoot.Position).Magnitude
        if CONFIG.FarmMode == "Teleport" then
            local offset = (myRoot.Position - target.root.Position)
            local newPos = target.root.Position + offset.Unit * 3
            pcall(function() myRoot.CFrame = CFrame.new(newPos, target.root.Position) end)
        else
            if dist > 4 then
                local dir = (target.root.Position - myRoot.Position)
                dir = Vector3.new(dir.X, 0, dir.Z).Unit
                hum:Move(dir, false)
            else
                hum:Move(Vector3.zero, false)
            end
        end
        if dist <= 10 then
            pcall(function() target.humanoid:TakeDamage(CONFIG.KillDamage) end)
            pcall(function() target.humanoid.Health = target.humanoid.Health - CONFIG.KillDamage end)
        end
    end)
    track(conns.farm)
end
local function stopAutoFarm() if conns.farm then conns.farm:Disconnect() conns.farm = nil end end

local function startAutoRebirth()
    if isBlocked() then return end
    if conns.rebirth then pcall(function() task.cancel(conns.rebirth) end) end
    conns.rebirth = task.spawn(function()
        while CONFIG.AutoRebirth do
            if not STATE.Maintenance then
                pcall(function()
                    for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            local n = obj.Name:lower()
                            if n:find("rebirth") or n:find("prestige") then
                                if obj:IsA("RemoteEvent") then obj:FireServer() else obj:InvokeServer() end
                            end
                        end
                    end
                end)
            end
            task.wait(CONFIG.RebirthDelay)
        end
    end)
end
local function stopAutoRebirth() if conns.rebirth then pcall(function() task.cancel(conns.rebirth) end) conns.rebirth = nil end end

local function startFlingLoop()
    if isBlocked() then return end
    if conns.fling then conns.fling:Disconnect() end
    conns.fling = RunService.Heartbeat:Connect(function()
        if STATE.Maintenance then return end
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                if r and (r.Position - myRoot.Position).Magnitude < 30 then fling(p.Character) end
            end
        end
    end)
    track(conns.fling)
end
local function stopFlingLoop() if conns.fling then conns.fling:Disconnect() conns.fling = nil end end

local function startFlingAll()
    if isBlocked() then return end
    if conns.flingAll then conns.flingAll:Disconnect() end
    conns.flingAll = RunService.Heartbeat:Connect(function()
        if STATE.Maintenance then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then fling(p.Character) end
        end
    end)
    track(conns.flingAll)
end
local function stopFlingAll() if conns.flingAll then conns.flingAll:Disconnect() conns.flingAll = nil end end

local function startAntiFling()
    if isBlocked() then return end
    if conns.anti then conns.anti:Disconnect() end
    conns.anti = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BodyAngularVelocity") or obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then
                if not obj:GetAttribute("MopsFly") then pcall(function() obj:Destroy() end) end
            end
        end
    end)
    track(conns.anti)
end
local function stopAntiFling() if conns.anti then conns.anti:Disconnect() conns.anti = nil end end

local function applySpeed(state)
    if conns.speed then conns.speed:Disconnect() conns.speed = nil end
    if not state or STATE.Maintenance then return end
    conns.speed = RunService.Heartbeat:Connect(function()
        if STATE.Maintenance then return end
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid.WalkSpeed = CONFIG.WalkSpeed
        end
    end)
end

local function applyNoclip(state)
    if conns.noclip then conns.noclip:Disconnect() conns.noclip = nil end
    if not state or STATE.Maintenance then return end
    conns.noclip = RunService.Stepped:Connect(function()
        if STATE.Maintenance then return end
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end

local function applyInfJump(state)
    if conns.infJump then conns.infJump:Disconnect() conns.infJump = nil end
    if not state or STATE.Maintenance then return end
    conns.infJump = UserInputService.JumpRequest:Connect(function()
        if STATE.Maintenance then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

local function startFly()
    if isBlocked() then return end
    if conns.fly then conns.fly:Disconnect() end
    if conns.flyBV then conns.flyBV:Destroy() end
    if conns.flyBG then conns.flyBG:Destroy() end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bv:SetAttribute("MopsFly", true)
    bv.Parent = hrp
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 1000
    bg:SetAttribute("MopsFly", true)
    bg.Parent = hrp
    conns.flyBV = bv
    conns.flyBG = bg
    conns.fly = RunService.RenderStepped:Connect(function()
        if STATE.Maintenance then return end
        local cam = workspace.CurrentCamera
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        if move.Magnitude > 0 then move = move.Unit end
        bv.Velocity = move * CONFIG.FlySpeed
        bg.CFrame = cam.CFrame
    end)
    track(conns.fly)
end
local function stopFly()
    if conns.fly then conns.fly:Disconnect() conns.fly = nil end
    if conns.flyBV then conns.flyBV:Destroy() conns.flyBV = nil end
    if conns.flyBG then conns.flyBG:Destroy() conns.flyBG = nil end
end

local bhopSpeed = 16
local function startBhop()
    if isBlocked() then return end
    if conns.bhop then conns.bhop:Disconnect() end
    bhopSpeed = 16
    conns.bhop = RunService.Heartbeat:Connect(function()
        if STATE.Maintenance then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local moving = false
        for _, k in ipairs({Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}) do
            if UserInputService:IsKeyDown(k) then moving = true break end
        end
        if moving then
            hum.Jump = true
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
                bhopSpeed = math.min(bhopSpeed + CONFIG.BhopGain * 0.1, CONFIG.BhopMax)
                hum.WalkSpeed = bhopSpeed
            end
        end
    end)
end
local function stopBhop()
    if conns.bhop then conns.bhop:Disconnect() conns.bhop = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16 end
end

local function startSpin()
    if isBlocked() then return end
    if conns.spin then conns.spin:Disconnect() end
    conns.spin = RunService.Heartbeat:Connect(function()
        if STATE.Maintenance then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(CONFIG.SpinSpeed), 0)
    end)
end
local function stopSpin() if conns.spin then conns.spin:Disconnect() conns.spin = nil end end

local auraParts = {}
local function startAura()
    if isBlocked() then return end
    if conns.aura then conns.aura:Disconnect() end
    conns.aura = RunService.Heartbeat:Connect(function()
        if STATE.Maintenance then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and not auraParts[p] then
                local h = Instance.new("Highlight")
                h.Adornee = p
                h.FillColor = THEME.Accent
                h.FillTransparency = 0.6
                h.OutlineColor = THEME.Accent
                h.Parent = p
                auraParts[p] = h
            end
        end
    end)
end
local function stopAura()
    if conns.aura then conns.aura:Disconnect() conns.aura = nil end
    for p, h in pairs(auraParts) do if h then h:Destroy() end end
    auraParts = {}
end

local espObjects = {}
local function createESP(p)
    if p == LocalPlayer or espObjects[p] then return end
    local char = p.Character
    if not char then return end
    local bb = Instance.new("BillboardGui")
    bb.Adornee = char
    bb.Size = UDim2.new(0, 200, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = screenGui
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(1, 0, 1, 0)
    n.BackgroundTransparency = 1
    n.Font = Enum.Font.GothamBold
    n.Text = p.Name
    n.TextColor3 = Color3.fromRGB(170, 140, 255)
    n.TextStrokeTransparency = 0
    n.TextSize = 14
    n.Parent = bb
    espObjects[p] = bb
end
local function startESP()
    if isBlocked() then return end
    for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
    if conns.espAdd then conns.espAdd:Disconnect() end
    conns.espAdd = Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function() task.wait(0.5) createESP(p) end)
    end)
    track(conns.espAdd)
end
local function stopESP()
    if conns.espAdd then conns.espAdd:Disconnect() conns.espAdd = nil end
    for _, bb in pairs(espObjects) do if bb then bb:Destroy() end end
    espObjects = {}
end

local function applyFullbright(state)
    if state then
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(180,180,180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
        Lighting.ClockTime = 14
    else
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(0,0,0)
        Lighting.OutdoorAmbient = Color3.fromRGB(0,0,0)
    end
end
local function applyNoFog(state)
    if state then
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
    else
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    end
end

local function applyAntiAfk(state)
    if conns.afk then conns.afk:Disconnect() conns.afk = nil end
    if not state or STATE.Maintenance then return end
    conns.afk = LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

local function applyAllFromConfig()
    if CONFIG.KillAura then startKillAura() else stopKillAura() end
    if CONFIG.AutoFarm then startAutoFarm() else stopAutoFarm() end
    if CONFIG.AutoRebirth then startAutoRebirth() else stopAutoRebirth() end
    if CONFIG.Fling then startFlingLoop() else stopFlingLoop() end
    if CONFIG.FlingAll then startFlingAll() else stopFlingAll() end
    if CONFIG.AntiFling then startAntiFling() else stopAntiFling() end
    applySpeed(CONFIG.Speed)
    applyNoclip(CONFIG.Noclip)
    applyInfJump(CONFIG.InfiniteJump)
    if CONFIG.Fly then startFly() else stopFly() end
    if CONFIG.Bhop then startBhop() else stopBhop() end
    if CONFIG.Spin then startSpin() else stopSpin() end
    if CONFIG.Aura then startAura() else stopAura() end
    if CONFIG.ESP then startESP() else stopESP() end
    applyFullbright(CONFIG.Fullbright)
    applyNoFog(CONFIG.NoFog)
    applyAntiAfk(CONFIG.AntiAfk)
end

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
local hudStroke = Instance.new("UIStroke", hud) hudStroke.Color = THEME.BorderLight hudStroke.Thickness = 1 hudStroke.Transparency = 0.3

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
hudVer.Text = "v9.4"
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
main.BackgroundTransparency = 0.15
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
header.BackgroundTransparency = 0.2
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
verLbl.Text = "v9.4 | chat + config + owner + roles"
verLbl.TextColor3 = THEME.TextDim
verLbl.TextSize = 9
verLbl.TextXAlignment = Enum.TextXAlignment.Left

-- СНАЧАЛА кнопки справа (X, Chat, Config)
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
chatBtn.Text = "CH"
chatBtn.Font = Enum.Font.GothamBold
chatBtn.TextSize = 11
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

--==================== CHAT WINDOW ====================
chatWindow = Instance.new("Frame")
chatWindow.Name = "ChatWindow"
chatWindow.Size = UDim2.new(0, 380, 0, 460)
chatWindow.Position = UDim2.new(0, 260, 0.5, -230)
chatWindow.BackgroundColor3 = THEME.Background
chatWindow.BackgroundTransparency = 0.1
chatWindow.BorderSizePixel = 0
chatWindow.Active = true
chatWindow.Draggable = true
chatWindow.Visible = false
chatWindow.ZIndex = 30
chatWindow.Parent = screenGui
Instance.new("UICorner", chatWindow).CornerRadius = UDim.new(0, 12)
local cwStroke = Instance.new("UIStroke", chatWindow)
cwStroke.Color = THEME.Accent cwStroke.Thickness = 1.5 cwStroke.Transparency = 0.3

local cwHeader = Instance.new("Frame", chatWindow)
cwHeader.Size = UDim2.new(1, 0, 0, 40)
cwHeader.BackgroundColor3 = THEME.Sidebar
cwHeader.BackgroundTransparency = 0.2
cwHeader.BorderSizePixel = 0
cwHeader.ZIndex = 31
Instance.new("UICorner", cwHeader).CornerRadius = UDim.new(0, 12)

local cwTitle = Instance.new("TextLabel", cwHeader)
cwTitle.Size = UDim2.new(1, -60, 1, 0)
cwTitle.Position = UDim2.new(0, 15, 0, 0)
cwTitle.BackgroundTransparency = 1
cwTitle.Font = Enum.Font.GothamBold
cwTitle.Text = "CHAT"
cwTitle.TextColor3 = THEME.Accent
cwTitle.TextSize = 13
cwTitle.TextXAlignment = Enum.TextXAlignment.Left
cwTitle.ZIndex = 32

local cwClose = Instance.new("TextButton", cwHeader)
cwClose.Size = UDim2.new(0, 26, 0, 26)
cwClose.Position = UDim2.new(1, -34, 0.5, -13)
cwClose.BackgroundColor3 = THEME.Danger
cwClose.Text = "X"
cwClose.Font = Enum.Font.GothamBold
cwClose.TextSize = 12
cwClose.TextColor3 = Color3.new(1,1,1)
cwClose.BorderSizePixel = 0
cwClose.ZIndex = 32
Instance.new("UICorner", cwClose).CornerRadius = UDim.new(1, 0)

local cwContent = Instance.new("Frame", chatWindow)
cwContent.Size = UDim2.new(1, -16, 1, -56)
cwContent.Position = UDim2.new(0, 8, 0, 48)
cwContent.BackgroundTransparency = 1
cwContent.ZIndex = 31
local cwLayout = Instance.new("UIListLayout", cwContent)
cwLayout.Padding = UDim.new(0, 6)
cwLayout.SortOrder = Enum.SortOrder.LayoutOrder

--==================== CONFIG WINDOW ====================
configWindow = Instance.new("Frame")
configWindow.Name = "ConfigWindow"
configWindow.Size = UDim2.new(0, 700, 0, 560)
configWindow.Position = UDim2.new(0, 120, 0.5, -280)
configWindow.BackgroundColor3 = THEME.Background
configWindow.BackgroundTransparency = 0.1
configWindow.BorderSizePixel = 0
configWindow.Active = true
configWindow.Draggable = true
configWindow.Visible = false
configWindow.ZIndex = 30
configWindow.Parent = screenGui
Instance.new("UICorner", configWindow).CornerRadius = UDim.new(0, 12)
local cfgStroke = Instance.new("UIStroke", configWindow)
cfgStroke.Color = THEME.Accent cfgStroke.Thickness = 1.5 cfgStroke.Transparency = 0.3

local cfgHeader = Instance.new("Frame", configWindow)
cfgHeader.Size = UDim2.new(1, 0, 0, 40)
cfgHeader.BackgroundColor3 = THEME.Sidebar
cfgHeader.BackgroundTransparency = 0.2
cfgHeader.BorderSizePixel = 0
cfgHeader.ZIndex = 31
Instance.new("UICorner", cfgHeader).CornerRadius = UDim.new(0, 12)

local cfgTitle = Instance.new("TextLabel", cfgHeader)
cfgTitle.Size = UDim2.new(1, -60, 1, 0)
cfgTitle.Position = UDim2.new(0, 15, 0, 0)
cfgTitle.BackgroundTransparency = 1
cfgTitle.Font = Enum.Font.GothamBold
cfgTitle.Text = "CONFIG MANAGER"
cfgTitle.TextColor3 = THEME.Accent
cfgTitle.TextSize = 13
cfgTitle.TextXAlignment = Enum.TextXAlignment.Left
cfgTitle.ZIndex = 32

local cfgClose = Instance.new("TextButton", cfgHeader)
cfgClose.Size = UDim2.new(0, 26, 0, 26)
cfgClose.Position = UDim2.new(1, -34, 0.5, -13)
cfgClose.BackgroundColor3 = THEME.Danger
cfgClose.Text = "X"
cfgClose.Font = Enum.Font.GothamBold
cfgClose.TextSize = 12
cfgClose.TextColor3 = Color3.new(1,1,1)
cfgClose.BorderSizePixel = 0
cfgClose.ZIndex = 32
Instance.new("UICorner", cfgClose).CornerRadius = UDim.new(1, 0)

local cfgContent = Instance.new("Frame", configWindow)
cfgContent.Size = UDim2.new(1, -16, 1, -56)
cfgContent.Position = UDim2.new(0, 8, 0, 48)
cfgContent.BackgroundTransparency = 1
cfgContent.ZIndex = 31

--==================== CHAT LOGIC ====================
local chatMessages = {}
local chatScroll, chatInput, chatSendBtn

function loadChatMessages()
    local record = _fetchBin()
    if not record or type(record.messages) ~= "table" then
        chatMessages = {}
        return
    end
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

function renderChatMessages()
    if not chatScroll or not chatScroll.Parent then return end
    for _, c in ipairs(chatScroll:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    if #chatMessages == 0 then
        local empty = Instance.new("TextLabel", chatScroll)
        empty.Size = UDim2.new(1, -10, 0, 30)
        empty.BackgroundTransparency = 1
        empty.Font = Enum.Font.Gotham
        empty.Text = "- pusto -"
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
        local icon = ROLE_EMOJI[msg.role] or "[USER]"
        lbl.Text = icon .. " " .. msg.name .. ": " .. msg.text
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
        local record = _fetchBin()
        if not record then
            record = {messages = {}}
        end
        record.messages = record.messages or {}
        table.insert(record.messages, entry)
        while #record.messages > 100 do table.remove(record.messages, 1) end
        _pushBin(record)
        task.wait(0.4)
        loadChatMessages()
        renderChatMessages()
    end)
end

local chatBuilt = false
local function buildChatWindow()
    if chatBuilt then return end
    chatBuilt = true

    local roleHdr = Instance.new("TextLabel", cwContent)
    roleHdr.Size = UDim2.new(1, 0, 0, 18)
    roleHdr.BackgroundTransparency = 1
    roleHdr.Font = Enum.Font.GothamBold
    roleHdr.Text = "Tvoya rol: " .. myRole
    roleHdr.TextColor3 = ROLE_COLORS[myRole] or ROLE_COLORS.User
    roleHdr.TextSize = 11
    roleHdr.TextXAlignment = Enum.TextXAlignment.Left
    roleHdr.LayoutOrder = 1

    local chatFrame = Instance.new("Frame", cwContent)
    chatFrame.Size = UDim2.new(1, 0, 1, -80)
    chatFrame.BackgroundColor3 = THEME.Background
    chatFrame.BackgroundTransparency = 0.3
    chatFrame.BorderSizePixel = 0
    chatFrame.LayoutOrder = 2
    Instance.new("UICorner", chatFrame).CornerRadius = UDim.new(0, 8)
    local cfS = Instance.new("UIStroke", chatFrame)
    cfS.Color = THEME.Border cfS.Thickness = 1 cfS.Transparency = 0.4

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
    chatInput.BackgroundColor3 = THEME.Background
    chatInput.BackgroundTransparency = 0.4
    chatInput.Font = Enum.Font.Gotham
    chatInput.PlaceholderText = "Soobshenie..."
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
    chatSendBtn.Text = "SEND"
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

--==================== CONFIG LOGIC ====================
local configBuilt = false
local function buildConfigWindow()
    if configBuilt then return end
    configBuilt = true

    local nameBox = Instance.new("TextBox", cfgContent)
    nameBox.Size = UDim2.new(1, -28, 0, 34)
    nameBox.Position = UDim2.new(0, 14, 0, 10)
    nameBox.BackgroundColor3 = THEME.Background
    nameBox.BackgroundTransparency = 0.4
    nameBox.Font = Enum.Font.Gotham
    nameBox.PlaceholderText = "Imya novogo konfiga..."
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
    saveBtn.Text = "SOHRANIT"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 11
    saveBtn.TextColor3 = Color3.new(1,1,1)
    saveBtn.BorderSizePixel = 0
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)

    local keyBtn = Instance.new("TextButton", cfgContent)
    keyBtn.Size = UDim2.new(0, 200, 0, 36)
    keyBtn.Position = UDim2.new(0, 224, 0, 54)
    keyBtn.BackgroundColor3 = Color3.fromRGB(90, 200, 130)
    keyBtn.Text = "SOZDAT KLYUCH"
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
    actHdr.Text = "AKTIVACIYA KLYUCHA"
    actHdr.TextColor3 = THEME.TextFaint
    actHdr.TextSize = 10
    actHdr.TextXAlignment = Enum.TextXAlignment.Left

    local keyInput = Instance.new("TextBox", cfgContent)
    keyInput.Size = UDim2.new(1, -240, 0, 34)
    keyInput.Position = UDim2.new(0, 14, 0, 150)
    keyInput.BackgroundColor3 = THEME.Background
    keyInput.BackgroundTransparency = 0.4
    keyInput.Font = Enum.Font.Gotham
    keyInput.PlaceholderText = "Vstav klyuch (MOPS-...)"
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
    activateBtn.Text = "AKTIVIROVAT"
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
    savedHdr.Text = "SOHRANENNYE KONFIGI"
    savedHdr.TextColor3 = THEME.TextFaint
    savedHdr.TextSize = 10
    savedHdr.TextXAlignment = Enum.TextXAlignment.Left

    local listFrame = Instance.new("Frame", cfgContent)
    listFrame.Size = UDim2.new(1, -28, 1, -240)
    listFrame.Position = UDim2.new(0, 14, 0, 220)
    listFrame.BackgroundColor3 = THEME.Background
    listFrame.BackgroundTransparency = 0.5
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
            empty.Text = hasFileAPI() and "- net konfigov -" or "Executor bez failov"
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
            rLoad.Text = "LOAD"
            rLoad.Font = Enum.Font.GothamBold
            rLoad.TextSize = 10
            rLoad.TextColor3 = Color3.new(1,1,1)
            rLoad.BorderSizePixel = 0
            Instance.new("UICorner", rLoad).CornerRadius = UDim.new(0, 6)

            local rKey = Instance.new("TextButton", row)
            rKey.Size = UDim2.new(0, 40, 0, 24)
            rKey.Position = UDim2.new(1, -180, 0.5, -12)
            rKey.BackgroundColor3 = Color3.fromRGB(90, 200, 130)
            rKey.Text = "KEY"
            rKey.Font = Enum.Font.GothamBold
            rKey.TextSize = 10
            rKey.TextColor3 = Color3.new(1,1,1)
            rKey.BorderSizePixel = 0
            Instance.new("UICorner", rKey).CornerRadius = UDim.new(0, 6)

            local rRename = Instance.new("TextButton", row)
            rRename.Size = UDim2.new(0, 40, 0, 24)
            rRename.Position = UDim2.new(1, -135, 0.5, -12)
            rRename.BackgroundColor3 = Color3.fromRGB(80, 130, 200)
            rRename.Text = "RNM"
            rRename.Font = Enum.Font.GothamBold
            rRename.TextSize = 10
            rRename.TextColor3 = Color3.new(1,1,1)
            rRename.BorderSizePixel = 0
            Instance.new("UICorner", rRename).CornerRadius = UDim.new(0, 6)

            local rDelete = Instance.new("TextButton", row)
            rDelete.Size = UDim2.new(0, 40, 0, 24)
            rDelete.Position = UDim2.new(1, -90, 0.5, -12)
            rDelete.BackgroundColor3 = THEME.Danger
            rDelete.BackgroundTransparency = 0.3
            rDelete.Text = "DEL"
            rDelete.Font = Enum.Font.GothamBold
            rDelete.TextSize = 10
            rDelete.TextColor3 = Color3.new(1,1,1)
            rDelete.BorderSizePixel = 0
            Instance.new("UICorner", rDelete).CornerRadius = UDim.new(0, 6)

            rLoad.MouseButton1Click:Connect(function()
                local ok, err = loadLocalConfig(name)
                if ok then
                    applyAllFromConfig()
                    statusLbl.Text = "Zagruzhen: " .. name
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
                statusLbl.Text = copied and ("Klyuch skopirovan (" .. #key .. ")") or "Klyuch sgenerirovan"
                statusLbl.TextColor3 = THEME.Success
            end)

            rRename.MouseButton1Click:Connect(function()
                nameBox.Text = name
                nameBox:CaptureFocus()
            end)

            rDelete.MouseButton1Click:Connect(function()
                deleteLocalConfig(name)
                statusLbl.Text = "Udalen: " .. name
                statusLbl.TextColor3 = THEME.Danger
                refreshList()
            end)
        end
    end

    saveBtn.MouseButton1Click:Connect(function()
        local name = nameBox.Text
        if name == "" then
            statusLbl.Text = "Vvedi imya konfiga"
            statusLbl.TextColor3 = THEME.Danger
            return
        end
        local ok, err = saveLocalConfig(name)
        if ok then
            statusLbl.Text = "Sohranen: " .. name
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
        statusLbl.Text = copied and ("Klyuch skopirovan! (" .. #key .. ")") or "Klyuch sgenerirovan"
        statusLbl.TextColor3 = THEME.Success
    end)

    activateBtn.MouseButton1Click:Connect(function()
        local key = keyInput.Text
        if key == "" then
            statusLbl.Text = "Vstav klyuch"
            statusLbl.TextColor3 = THEME.Danger
            return
        end
        local ok, result = activateKey(key)
        if ok then
            applyAllFromConfig()
            statusLbl.Text = "Aktivirovan! Nastroek: " .. tostring(result)
            statusLbl.TextColor3 = THEME.Success
        else
            statusLbl.Text = tostring(result)
            statusLbl.TextColor3 = THEME.Danger
        end
    end)

    refreshList()
end

--==================== TOGGLE ====================
chatBtn.MouseButton1Click:Connect(function()
    chatWindow.Visible = not chatWindow.Visible
    if chatWindow.Visible then
        buildChatWindow()
        chatWindow.ZIndex = 50
    end
end)

configBtn.MouseButton1Click:Connect(function()
    configWindow.Visible = not configWindow.Visible
    if configWindow.Visible then
        buildConfigWindow()
        configWindow.ZIndex = 50
    end
end)

cwClose.MouseButton1Click:Connect(function() chatWindow.Visible = false end)
cfgClose.MouseButton1Click:Connect(function() configWindow.Visible = false end)

--==================== SIDEBAR ====================
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

--==================== UI ELEMENTS ====================
local function makeCard(title, order)
    local card = Instance.new("Frame", contentScroll)
    card.Size = UDim2.new(0, 330, 0, 210)
    card.BackgroundColor3 = THEME.Card
    card.BackgroundTransparency = 0.25
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

--==================== SIDEBAR BUTTONS ====================
local sidebarButtons = {}
local currentTab = "combat"
local addOwnerTab

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

--==================== REBUILD ====================
function rebuildContent()
    allCards = {}
    for _, c in ipairs(contentScroll:GetChildren()) do
        if c:IsA("Frame") and c:GetAttribute("isCard") then c:Destroy() end
    end

    if currentTab == "combat" then
        local c1 = makeCard("Kill Aura", 1)
        addToggle(c1, 56, "Enabled", CONFIG.KillAura, function(s)
            CONFIG.KillAura = s
            if s then startKillAura() else stopKillAura() end
        end)
        addToggle(c1, 90, "No Damage", CONFIG.KillAuraNoDmg, function(s) CONFIG.KillAuraNoDmg = s end)
        addSlider(c1, 124, "Range", 5, 300, CONFIG.KillRange, function(v) CONFIG.KillRange = v end)
        addSlider(c1, 164, "Damage", 1, 999, CONFIG.KillDamage, function(v) CONFIG.KillDamage = v end)

        local c2 = makeCard("Auto Farm", 2)
        addToggle(c2, 56, "Enabled", CONFIG.AutoFarm, function(s)
            CONFIG.AutoFarm = s
            if s then startAutoFarm() else stopAutoFarm() end
        end)
        addSlider(c2, 90, "Range", 20, 1000, CONFIG.FarmRange, function(v) CONFIG.FarmRange = v end)
        addDropdown(c2, 130, "Mode", {"Walk", "Teleport"}, CONFIG.FarmMode, function(v) CONFIG.FarmMode = v end)

        local c3 = makeCard("Auto Rebirth", 3)
        addToggle(c3, 56, "Enabled", CONFIG.AutoRebirth, function(s)
            CONFIG.AutoRebirth = s
            if s then startAutoRebirth() else stopAutoRebirth() end
        end)
        addSlider(c3, 90, "Delay", 1, 10, CONFIG.RebirthDelay, function(v) CONFIG.RebirthDelay = v end)

        local c4 = makeCard("Fling", 4)
        addToggle(c4, 56, "Fling", CONFIG.Fling, function(s)
            CONFIG.Fling = s
            if s then startFlingLoop() else stopFlingLoop() end
        end)
        addToggle(c4, 90, "Fling ALL", CONFIG.FlingAll, function(s)
            CONFIG.FlingAll = s
            if s then startFlingAll() else stopFlingAll() end
        end)

        local c5 = makeCard("Anti-Fling", 5)
        addToggle(c5, 56, "Enabled", CONFIG.AntiFling, function(s)
            CONFIG.AntiFling = s
            if s then startAntiFling() else stopAntiFling() end
        end)

    elseif currentTab == "movement" then
        local c1 = makeCard("Speed / Jump", 1)
        addToggle(c1, 56, "Speed", CONFIG.Speed, function(s) CONFIG.Speed = s applySpeed(s) end)
        addToggle(c1, 90, "Noclip", CONFIG.Noclip, function(s) CONFIG.Noclip = s applyNoclip(s) end)
        addToggle(c1, 124, "Infinite Jump", CONFIG.InfiniteJump, function(s) CONFIG.InfiniteJump = s applyInfJump(s) end)
        addSlider(c1, 160, "Walk Speed", 16, 300, CONFIG.WalkSpeed, function(v) CONFIG.WalkSpeed = v end)

        local c2 = makeCard("Fly", 2)
        addToggle(c2, 56, "Fly", CONFIG.Fly, function(s)
            CONFIG.Fly = s
            if s then startFly() else stopFly() end
        end)
        addSlider(c2, 90, "Fly Speed", 10, 300, CONFIG.FlySpeed, function(v) CONFIG.FlySpeed = v end)

        local c3 = makeCard("Bhop", 3)
        addToggle(c3, 56, "Bhop", CONFIG.Bhop, function(s)
            CONFIG.Bhop = s
            if s then startBhop() else stopBhop() end
        end)
        addSlider(c3, 90, "Gain", 1, 20, CONFIG.BhopGain, function(v) CONFIG.BhopGain = v end)
        addSlider(c3, 130, "Max Speed", 50, 500, CONFIG.BhopMax, function(v) CONFIG.BhopMax = v end)

        local c4 = makeCard("Spin", 4)
        addToggle(c4, 56, "Spin", CONFIG.Spin, function(s)
            CONFIG.Spin = s
            if s then startSpin() else stopSpin() end
        end)
        addSlider(c4, 90, "Speed", 1, 100, CONFIG.SpinSpeed, function(v) CONFIG.SpinSpeed = v end)

    elseif currentTab == "render" then
        local c1 = makeCard("Aura", 1)
        addToggle(c1, 56, "Aura", CONFIG.Aura, function(s)
            CONFIG.Aura = s
            if s then startAura() else stopAura() end
        end)

        local c2 = makeCard("ESP", 2)
        addToggle(c2, 56, "ESP", CONFIG.ESP, function(s)
            CONFIG.ESP = s
            if s then startESP() else stopESP() end
        end)

        local c3 = makeCard("Lighting", 3)
        addToggle(c3, 56, "Fullbright", CONFIG.Fullbright, function(s) CONFIG.Fullbright = s applyFullbright(s) end)
        addToggle(c3, 90, "No Fog", CONFIG.NoFog, function(s) CONFIG.NoFog = s applyNoFog(s) end)

    elseif currentTab == "misc" then
        if not isOwner and myRole ~= "Mops" then
            local cOwner = makeCard("OWNER DOSTUP", 0)
            local btnOwner = Instance.new("TextButton", cOwner)
            btnOwner.Size = UDim2.new(1, -28, 0, 36)
            btnOwner.Position = UDim2.new(0, 14, 0, 56)
            btnOwner.BackgroundColor3 = THEME.Gold
            btnOwner.BorderSizePixel = 0
            btnOwner.Text = "Vvesti parol Owner"
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
        addToggle(c2, 90, "Show FPS", true, function(s) hudFps.Visible = s end)

        local c3 = makeCard("SMENIT ROL", 3)

        local curRoleLbl = Instance.new("TextLabel", c3)
        curRoleLbl.Size = UDim2.new(1, -28, 0, 20)
        curRoleLbl.Position = UDim2.new(0, 14, 0, 56)
        curRoleLbl.BackgroundTransparency = 1
        curRoleLbl.Font = Enum.Font.Gotham
        curRoleLbl.Text = "Tekushaya rol: " .. myRole
        curRoleLbl.TextColor3 = ROLE_COLORS[myRole] or THEME.Text
        curRoleLbl.TextSize = 11
        curRoleLbl.TextXAlignment = Enum.TextXAlignment.Left

        local changeRoleBtn = Instance.new("TextButton", c3)
        changeRoleBtn.Size = UDim2.new(1, -28, 0, 40)
        changeRoleBtn.Position = UDim2.new(0, 14, 0, 84)
        changeRoleBtn.BackgroundColor3 = THEME.AccentDim
        changeRoleBtn.BorderSizePixel = 0
        changeRoleBtn.Text = "SMENIT ROL"
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
                    if currentTab == "owner" then
                        currentTab = "combat"
                    end
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
        resetRoleBtn.Text = "Sbrosit rol (Free)"
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
            if currentTab == "owner" then
                currentTab = "combat"
            end
            rebuildContent()
        end)

    elseif currentTab == "owner" then
        if not isOwner and myRole ~= "Mops" then
            local c = makeCard("Net dostupa", 1)
            local lbl = Instance.new("TextLabel", c)
            lbl.Size = UDim2.new(1, -28, 0, 60)
            lbl.Position = UDim2.new(0, 14, 0, 56)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.Gotham
            lbl.Text = "Tolko Owner i Mops vidyat etu vkladku"
            lbl.TextColor3 = THEME.Danger
            lbl.TextSize = 12
            lbl.TextWrapped = true
            return
        end

        local c1 = makeCard("Vydat roli", 1)
        c1.Size = UDim2.new(0, 330, 0, 340)

        local playersScroll = Instance.new("ScrollingFrame", c1)
        playersScroll.Size = UDim2.new(1, -20, 0, 260)
        playersScroll.Position = UDim2.new(0, 10, 0, 50)
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
                    row.Size = UDim2.new(1, -8, 0, 60)
                    row.BackgroundColor3 = THEME.Card
                    row.BackgroundTransparency = 0.3
                    row.BorderSizePixel = 0
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

                    local nL = Instance.new("TextLabel", row)
                    nL.Size = UDim2.new(1, -16, 0, 22)
                    nL.Position = UDim2.new(0, 10, 0, 4)
                    nL.BackgroundTransparency = 1
                    nL.Font = Enum.Font.GothamMedium
                    nL.Text = plr.Name .. (plr == LocalPlayer and " (ty)" or "")
                    nL.TextColor3 = THEME.Text
                    nL.TextSize = 11
                    nL.TextXAlignment = Enum.TextXAlignment.Left

                    local currentRole = grantedCache[plr.Name] or "Free"

                    local rLbl = Instance.new("TextLabel", row)
                    rLbl.Size = UDim2.new(0, 120, 0, 14)
                    rLbl.Position = UDim2.new(0, 10, 0, 26)
                    rLbl.BackgroundTransparency = 1
                    rLbl.Font = Enum.Font.Gotham
                    rLbl.Text = "Rol: " .. currentRole
                    rLbl.TextColor3 = ROLE_COLORS[currentRole] or THEME.TextDim
                    rLbl.TextSize = 9
                    rLbl.TextXAlignment = Enum.TextXAlignment.Left

                    local btnP = Instance.new("TextButton", row)
                    btnP.Size = UDim2.new(0, 70, 0, 22)
                    btnP.Position = UDim2.new(1, -160, 0.5, -11)
                    btnP.BorderSizePixel = 0
                    btnP.Font = Enum.Font.GothamBold
                    btnP.TextSize = 9
                    btnP.Text = "+Premium"
                    btnP.BackgroundColor3 = Color3.fromRGB(140, 90, 220)
                    btnP.TextColor3 = Color3.new(1, 1, 1)
                    Instance.new("UICorner", btnP).CornerRadius = UDim.new(0, 5)

                    local btnM = Instance.new("TextButton", row)
                    btnM.Size = UDim2.new(0, 70, 0, 22)
                    btnM.Position = UDim2.new(1, -85, 0.5, -11)
                    btnM.BorderSizePixel = 0
                    btnM.Font = Enum.Font.GothamBold
                    btnM.TextSize = 9
                    btnM.Text = "+Mops"
                    btnM.BackgroundColor3 = Color3.fromRGB(220, 100, 180)
                    btnM.TextColor3 = Color3.new(1, 1, 1)
                    Instance.new("UICorner", btnM).CornerRadius = UDim.new(0, 5)

                    btnP.MouseButton1Click:Connect(function()
                        if grantRoleCloud(plr.Name, "Premium") then
                            rLbl.Text = "Rol: Premium"
                            rLbl.TextColor3 = ROLE_COLORS.Premium
                        end
                    end)

                    btnM.MouseButton1Click:Connect(function()
                        if grantRoleCloud(plr.Name, "Mops") then
                            rLbl.Text = "Rol: Mops"
                            rLbl.TextColor3 = ROLE_COLORS.Mops
                        end
                    end)
                end
            end)
        end

        refreshPlayers()
        Players.PlayerAdded:Connect(function() task.wait(0.5) refreshPlayers() end)
        Players.PlayerRemoving:Connect(function() task.wait(0.5) refreshPlayers() end)

        local c2 = makeCard("Igrayut so skriptom", 2)
        c2.Size = UDim2.new(0, 330, 0, 340)

        local activeScroll = Instance.new("ScrollingFrame", c2)
        activeScroll.Size = UDim2.new(1, -20, 0, 260)
        activeScroll.Position = UDim2.new(0, 10, 0, 50)
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
                    local icon = ROLE_EMOJI[rl] or "[USER]"

                    local lbl = Instance.new("TextLabel", row)
                    lbl.Size = UDim2.new(1, -10, 1, 0)
                    lbl.Position = UDim2.new(0, 10, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.GothamMedium
                    lbl.Text = icon .. " " .. name
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
        local c1 = makeCard("Informaciya", 1)
        local info = Instance.new("TextLabel", c1)
        info.Size = UDim2.new(1, -28, 0, 140)
        info.Position = UDim2.new(0, 14, 0, 56)
        info.BackgroundTransparency = 1
        info.Font = Enum.Font.Gotham
        info.Text = "Mops Hub v9.4\nMonkey Evolution Client\n\nRIGHT SHIFT - otkryt menu\nM - knopka sleva\nCH - chat\nCFG - config\n\nRoli: FREE | PREMIUM | MOPS | OWNER"
        info.TextColor3 = THEME.TextDim
        info.TextSize = 11
        info.TextWrapped = true
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.TextYAlignment = Enum.TextYAlignment.Top
    end
end

--==================== CREATE TABS ====================
makeTab("main", "M", "Main")
makeTab("combat", "C", "Combat")
makeTab("movement", "MV", "Movement")
makeTab("render", "R", "Render")
makeTab("misc", "MI", "Misc")

addOwnerTab = function()
    if not isOwner and myRole ~= "Mops" then return end
    if sidebarButtons["owner"] then return end
    makeTab("owner", "AD", "Admin")
    print("[MopsHub] Vkladka Admin dobavlena")
end

sidebarButtons["combat"].button.BackgroundColor3 = THEME.AccentDim
sidebarButtons["combat"].button.BackgroundTransparency = 0.1
sidebarButtons["combat"].icon.TextColor3 = Color3.new(1,1,1)
sidebarButtons["combat"].label.TextColor3 = Color3.new(1,1,1)
rebuildContent()

--==================== INIT ====================
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

    task.spawn(function()
        local used = checkCloudOwnerFlag()
        if used and not isOwner then
            ownerPasswordUsed = true
        end
    end)

    sendHeartbeat()

    -- Автообновление чата
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

--==================== RIGHT SHIFT ====================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setMenuVisible(not main.Visible)
    end
end)

print("[Mops Hub v9.4] Zagruzhen. RIGHT SHIFT - otkryt.")
