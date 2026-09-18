--=========================================================
--  MOPS HUB v6.4 | Pastebin-админка + все функции
--  RIGHT SHIFT или 🐶 — открыть
--  Pastebin тех.работы: https://pastebin.com/Mj77ghwX
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

local PASTEBIN_RAW = "https://pastebin.com/raw/Mj77ghwX"
local CHECK_INTERVAL = 15

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
local listeningForBind = nil
local conns = {}
local screenGui, main, openBtn, bindsPanel, hud

--==================== КОНФИГИ ====================
local CONFIG_FOLDER = "MopsHub/Configs"
local KEY_PREFIX = "MOPS-"

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
    if not hasFileAPI() then return false, "Executor без файлов" end
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
    if not hasFileAPI() then return false, "Executor без файлов" end
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    if not isfile(path) then return false, "Не найден" end
    local ok, content = pcall(function() return readfile(path) end)
    if not ok then return false, "Ошибка чтения" end
    local decoded
    pcall(function() decoded = HttpService:JSONDecode(content) end)
    if type(decoded) ~= "table" then return false, "Ошибка формата" end
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
    if not key or #key < 8 then return false, "Ключ слишком короткий" end
    key = key:gsub("%s", "")
    if key:sub(1, #KEY_PREFIX) == KEY_PREFIX then key = key:sub(#KEY_PREFIX + 1) end
    local ok, json = pcall(function() return base64Decode(key) end)
    if not ok or not json or json == "" then return false, "Ошибка декодирования" end
    local data
    pcall(function() data = HttpService:JSONDecode(json) end)
    if type(data) ~= "table" then return false, "Неверный формат ключа" end
    local applied = 0
    for k, v in pairs(data) do
        if CONFIG[k] ~= nil then CONFIG[k] = v applied = applied + 1 end
    end
    if applied == 0 then return false, "В ключе нет настроек" end
    return true, applied
end

local function copyToClipboard(text)
    if setclipboard then pcall(function() setclipboard(text) end) return true end
    return false
end

--==================== ТЕХ РАБОТЫ ====================
local maintenanceBanner = nil
local function createMaintenanceBanner()
    if maintenanceBanner then return end
    local banner = Instance.new("Frame")
    banner.Size = UDim2.new(1, 0, 1, 0)
    banner.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
    banner.BackgroundTransparency = 0.3
    banner.BorderSizePixel = 0
    banner.ZIndex = 999
    banner.Parent = screenGui
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBlack
    lbl.Text = "ТЕХ РАБОТЫ"
    lbl.TextColor3 = Color3.fromRGB(255, 30, 30)
    lbl.TextSize = 120
    lbl.TextStrokeTransparency = 0
    lbl.ZIndex = 1000
    lbl.Parent = banner
    task.spawn(function()
        while banner.Parent do
            for i = 0, 1, 0.05 do
                if not banner.Parent then return end
                lbl.TextTransparency = 0.3 + math.abs(math.sin(i * math.pi)) * 0.5
                task.wait(0.03)
            end
        end
    end)
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 40)
    sub.Position = UDim2.new(0, 0, 0.5, 90)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.GothamBold
    sub.Text = "Скрипт временно недоступен. Заходи позже."
    sub.TextColor3 = Color3.fromRGB(255, 180, 180)
    sub.TextSize = 20
    sub.ZIndex = 1000
    sub.Parent = banner
    maintenanceBanner = banner
end

local function removeMaintenanceBanner()
    if maintenanceBanner then
        pcall(function() maintenanceBanner:Destroy() end)
        maintenanceBanner = nil
    end
end

local function applyMaintenance(state)
    STATE.Maintenance = state
    if state then
        if conns.ka then conns.ka:Disconnect() conns.ka = nil end
        if conns.farm then conns.farm:Disconnect() conns.farm = nil end
        if conns.rebirth then pcall(function() task.cancel(conns.rebirth) end) conns.rebirth = nil end
        if conns.fling then conns.fling:Disconnect() conns.fling = nil end
        if conns.flingAll then conns.flingAll:Disconnect() conns.flingAll = nil end
        if conns.anti then conns.anti:Disconnect() conns.anti = nil end
        if conns.speed then conns.speed:Disconnect() conns.speed = nil end
        if conns.noclip then conns.noclip:Disconnect() conns.noclip = nil end
        if conns.infJump then conns.infJump:Disconnect() conns.infJump = nil end
        if conns.fly then conns.fly:Disconnect() conns.fly = nil end
        if conns.flyBV then conns.flyBV:Destroy() conns.flyBV = nil end
        if conns.flyBG then conns.flyBG:Destroy() conns.flyBG = nil end
        if conns.bhop then conns.bhop:Disconnect() conns.bhop = nil end
        if conns.spin then conns.spin:Disconnect() conns.spin = nil end
        if conns.aura then conns.aura:Disconnect() conns.aura = nil end
        if conns.afk then conns.afk:Disconnect() conns.afk = nil end
        createMaintenanceBanner()
        if main then main.Visible = false end
        if openBtn then openBtn.Visible = false end
        if bindsPanel then bindsPanel.Visible = false end
        if hud then hud.Visible = false end
    else
        removeMaintenanceBanner()
        if openBtn then openBtn.Visible = true end
        if hud then hud.Visible = true end
        if bindsPanel then bindsPanel.Visible = true end
    end
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

--==================== ФУНКЦИИ ====================
local function checkBlocked() return STATE.Maintenance end

local function fling(targetChar)
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
    if conns.ka then conns.ka:Disconnect() end
    local lastHit = 0
    conns.ka = RunService.Heartbeat:Connect(function()
        if checkBlocked() then return end
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
    if conns.farm then conns.farm:Disconnect() end
    conns.farm = RunService.Heartbeat:Connect(function()
        if checkBlocked() or not CONFIG.AutoFarm then return end
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
local function stopAutoFarm()
    if conns.farm then conns.farm:Disconnect() conns.farm = nil end
end

local function startAutoRebirth()
    if conns.rebirth then pcall(function() task.cancel(conns.rebirth) end) end
    conns.rebirth = task.spawn(function()
        while CONFIG.AutoRebirth do
            if not checkBlocked() then
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
local function stopAutoRebirth()
    if conns.rebirth then pcall(function() task.cancel(conns.rebirth) end) conns.rebirth = nil end
end

local function startFlingLoop()
    if conns.fling then conns.fling:Disconnect() end
    conns.fling = RunService.Heartbeat:Connect(function()
        if checkBlocked() then return end
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
    if conns.flingAll then conns.flingAll:Disconnect() end
    conns.flingAll = RunService.Heartbeat:Connect(function()
        if checkBlocked() then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then fling(p.Character) end
        end
    end)
    track(conns.flingAll)
end
local function stopFlingAll() if conns.flingAll then conns.flingAll:Disconnect() conns.flingAll = nil end end

local function startAntiFling()
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
    if not state then return end
    conns.speed = RunService.Heartbeat:Connect(function()
        if checkBlocked() then return end
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid.WalkSpeed = CONFIG.WalkSpeed
        end
    end)
end

local function applyNoclip(state)
    if conns.noclip then conns.noclip:Disconnect() conns.noclip = nil end
    if not state then return end
    conns.noclip = RunService.Stepped:Connect(function()
        if checkBlocked() then return end
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
    if not state then return end
    conns.infJump = UserInputService.JumpRequest:Connect(function()
        if checkBlocked() then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

local function startFly()
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
        if checkBlocked() then return end
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
end
local function stopFly()
    if conns.fly then conns.fly:Disconnect() conns.fly = nil end
    if conns.flyBV then conns.flyBV:Destroy() conns.flyBV = nil end
    if conns.flyBG then conns.flyBG:Destroy() conns.flyBG = nil end
end

local bhopSpeed = 16
local function startBhop()
    if conns.bhop then conns.bhop:Disconnect() end
    bhopSpeed = 16
    conns.bhop = RunService.Heartbeat:Connect(function()
        if checkBlocked() then return end
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
    if conns.spin then conns.spin:Disconnect() end
    conns.spin = RunService.Heartbeat:Connect(function()
        if checkBlocked() then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(CONFIG.SpinSpeed), 0)
    end)
end
local function stopSpin() if conns.spin then conns.spin:Disconnect() conns.spin = nil end end

local auraParts = {}
local function startAura()
    if conns.aura then conns.aura:Disconnect() end
    conns.aura = RunService.Heartbeat:Connect(function()
        if checkBlocked() then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and not auraParts[p] then
                local h = Instance.new("Highlight")
                h.Adornee = p
                h.FillColor = Color3.fromRGB(140, 110, 255)
                h.FillTransparency = 0.6
                h.OutlineColor = Color3.fromRGB(140, 110, 255)
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

local function applyFullbright(state)
    if state then
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(180,180,180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
    else
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(0,0,0)
        Lighting.OutdoorAmbient = Color3.fromRGB(0,0,0)
    end
end
local function applyNoFog(state)
    if state then Lighting.FogEnd = 9e9 Lighting.FogStart = 9e9
    else Lighting.FogEnd = 100000 Lighting.FogStart = 0 end
end

local function applyAntiAfk(state)
    if conns.afk then conns.afk:Disconnect() conns.afk = nil end
    if not state then return end
    conns.afk = LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

--==================== GUI ====================
screenGui = Instance.new("ScreenGui")
screenGui.Name = "MopsHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = game:GetService("CoreGui")

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
hudVer.Text = "v6.4"
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
openBtn.Text = "🐶"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 28
openBtn.TextColor3 = Color3.new(1, 1, 1)
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
logoLbl.Size = UDim2.new(1, -200, 0, 30)
logoLbl.Position = UDim2.new(0, 24, 0, 12)
logoLbl.BackgroundTransparency = 1
logoLbl.Font = Enum.Font.GothamBlack
logoLbl.Text = "MOPS HUB"
logoLbl.TextColor3 = THEME.Text
logoLbl.TextSize = 20
logoLbl.TextXAlignment = Enum.TextXAlignment.Left

local verLbl = Instance.new("TextLabel", header)
verLbl.Size = UDim2.new(1, -200, 0, 14)
verLbl.Position = UDim2.new(0, 24, 0, 36)
verLbl.BackgroundTransparency = 1
verLbl.Font = Enum.Font.Gotham
verLbl.Text = "v6.4 | admin panel"
verLbl.TextColor3 = THEME.TextDim
verLbl.TextSize = 9
verLbl.TextXAlignment = Enum.TextXAlignment.Left

local shutdownBtn = Instance.new("TextButton", header)
shutdownBtn.Size = UDim2.new(0, 30, 0, 30)
shutdownBtn.Position = UDim2.new(1, -110, 0.5, -15)
shutdownBtn.BackgroundColor3 = THEME.Danger
shutdownBtn.Text = "⏻"
shutdownBtn.Font = Enum.Font.GothamBold
shutdownBtn.TextSize = 14
shutdownBtn.TextColor3 = Color3.new(1,1,1)
shutdownBtn.BorderSizePixel = 0
Instance.new("UICorner", shutdownBtn).CornerRadius = UDim.new(1, 0)

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(30, 30, 40)
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(0, 180, 1, -72)
tabBar.Position = UDim2.new(0, 14, 0, 66)
tabBar.BackgroundColor3 = THEME.Sidebar
tabBar.BackgroundTransparency = 0.2
tabBar.BorderSizePixel = 0
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 10)

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.Padding = UDim.new(0, 4)
local tabPad = Instance.new("UIPadding", tabBar)
tabPad.PaddingTop = UDim.new(0, 8) tabPad.PaddingLeft = UDim.new(0, 8) tabPad.PaddingRight = UDim.new(0, 8)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -215, 1, -72)
content.Position = UDim2.new(0, 200, 0, 66)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0

local contentScroll = Instance.new("ScrollingFrame", content)
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
    if state then
        openBtn.Visible = false
        main.Visible = true
        main.Size = UDim2.new(0, 0, 0, 0)
        main.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 880, 0, 560), Position = UDim2.new(0.5, -440, 0.5, -280)
        }):Play()
        TweenService:Create(blur, TweenInfo.new(0.3), {Size = 12}):Play()
    else
        local tw = TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)
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
    check.Text = "✓"
    check.TextColor3 = Color3.new(1,1,1)
    check.TextSize = 12
    check.Visible = false

    local state = default or false
    if state then box.BackgroundColor3 = THEME.Accent check.Visible = true end

    row.MouseButton1Click:Connect(function()
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
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos + 0.5)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -6, 0.5, -6)
        valueLbl.Text = tostring(value)
        cb(value)
    end

    bar.InputBegan:Connect(function(input)
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
        idx = idx % #options + 1
        dropBtn.Text = options[idx]
        cb(options[idx])
    end)
end

local currentTab = "combat"

local function rebuildContent()
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

        local c2 = makeCard("Lighting", 2)
        addToggle(c2, 56, "Fullbright", CONFIG.Fullbright, function(s) CONFIG.Fullbright = s applyFullbright(s) end)
        addToggle(c2, 90, "No Fog", CONFIG.NoFog, function(s) CONFIG.NoFog = s applyNoFog(s) end)

    elseif currentTab == "misc" then
        local c1 = makeCard("Anti-AFK", 1)
        addToggle(c1, 56, "Anti-AFK", CONFIG.AntiAfk, function(s) CONFIG.AntiAfk = s applyAntiAfk(s) end)

        local c2 = makeCard("HUD", 2)
        addToggle(c2, 56, "Watermark", true, function(s) hud.Visible = s end)
        addToggle(c2, 90, "Show FPS", true, function(s) hudFps.Visible = s end)

        local c3 = makeCard("Script", 3)
        local shutdownBig = Instance.new("TextButton", c3)
        shutdownBig.Size = UDim2.new(1, -28, 0, 40)
        shutdownBig.Position = UDim2.new(0, 14, 0, 56)
        shutdownBig.BackgroundColor3 = THEME.Danger
        shutdownBig.Text = "⏻  ВЫКЛЮЧИТЬ СКРИПТ"
        shutdownBig.Font = Enum.Font.GothamBold
        shutdownBig.TextSize = 12
        shutdownBig.TextColor3 = Color3.new(1,1,1)
        shutdownBig.BorderSizePixel = 0
        Instance.new("UICorner", shutdownBig).CornerRadius = UDim.new(0, 8)
        shutdownBig.MouseButton1Click:Connect(function()
            for _, conn in pairs(conns) do pcall(function() conn:Disconnect() end) end
            for _, conn in ipairs(ALL_CONNECTIONS) do pcall(function() conn:Disconnect() end) end
            pcall(function() screenGui:Destroy() end)
            pcall(function() blur:Destroy() end)
            print("[Mops Hub] Скрипт выключен.")
        end)
    end
end

local sidebarButtons = {}
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
    iL.Size = UDim2.new(0, 20, 1, 0)
    iL.Position = UDim2.new(0, 14, 0, 0)
    iL.BackgroundTransparency = 1
    iL.Font = Enum.Font.GothamBold
    iL.Text = icon
    iL.TextColor3 = THEME.TextDim
    iL.TextSize = 13

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

makeTab("combat", "⚔", "Combat")
makeTab("movement", "🏃", "Movement")
makeTab("render", "🎨", "Render")
makeTab("misc", "🎲", "Misc")

sidebarButtons["combat"].button.BackgroundColor3 = THEME.AccentDim
sidebarButtons["combat"].button.BackgroundTransparency = 0.1
sidebarButtons["combat"].icon.TextColor3 = Color3.new(1,1,1)
sidebarButtons["combat"].label.TextColor3 = Color3.new(1,1,1)
rebuildContent()

shutdownBtn.MouseButton1Click:Connect(function()
    for _, conn in pairs(conns) do pcall(function() conn:Disconnect() end) end
    for _, conn in ipairs(ALL_CONNECTIONS) do pcall(function() conn:Disconnect() end) end
    pcall(function() screenGui:Destroy() end)
    pcall(function() blur:Destroy() end)
    print("[Mops Hub] Скрипт выключен.")
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setMenuVisible(not main.Visible)
    end
end)

print("[Mops Hub v6.4] Загружен. RIGHT SHIFT — открыть.")