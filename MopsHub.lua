--=========================================================
--  MOPS HUB v7.3 | Owner + Premium System
--  RIGHT SHIFT или 🐶 — открыть
--  Пароль Owner: Kikisk234
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

--==================== ЧАТ (jsonbin.io) ====================
local CHAT_BIN_ID  = "6aad8f9eac6210605add8f0e"
local CHAT_API_KEY = "$2a$10$vZdDG8nnlVaB49BU4pgVXuewjJqoiwTtYyjdE5tZ6tKh.HyOFKXAK"
local CHAT_READ_INTERVAL = 6
local PASTEBIN_RAW = "https://pastebin.com/raw/Mj77ghwX"
local CHECK_INTERVAL = 15
local OWNER_PASSWORD = "Kikisk234"
local OWNER_FLAG_FILE = "MopsHub_Owner.txt"
local CHAT_URL = "https://api.jsonbin.io/v3/b/" .. CHAT_BIN_ID

--==================== ТЕМА ====================
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
    Premium     = Color3.fromRGB(180, 100, 255),
}

local ROLE_COLORS = {
    Owner     = Color3.fromRGB(255, 200, 40),
    Premium   = Color3.fromRGB(180, 100, 255),
    Moderator = Color3.fromRGB(230, 70, 90),
    VIP       = Color3.fromRGB(180, 100, 255),
    User      = Color3.fromRGB(200, 200, 220),
}
local ROLE_ICONS = {
    Owner = "👑", Premium = "💎", Moderator = "🛡", VIP = "⭐", User = "👤",
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
    Aura = false, Fullbright = false, NoFog = false,
    AntiAfk = false,
}
local conns = {}
local screenGui, main, openBtn, hud, contentScroll
local allCards = {}

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

--==================== OWNER SYSTEM ====================
local myRole = "User"
local isOwner = false
local ownerPasswordUsed = false
local grantedRolesCache = {}

-- Загрузить сохранённую роль
local function loadSavedRole()
    if not (isfile and readfile) then return nil end
    if not isfile(OWNER_FLAG_FILE) then return nil end
    local ok, data = pcall(function() return readfile(OWNER_FLAG_FILE) end)
    if ok and data then
        local clean = data:gsub("%s", "")
        if clean == "used" then return "used" end
        if clean == "Owner" then return "Owner" end
    end
    return nil
end

local function setLocalOwnerFlag()
    if not (writefile and isfile) then return end
    pcall(function() writefile(OWNER_FLAG_FILE, "used") end)
end

-- Проверка облачного флага
local function checkCloudOwnerFlag()
    local raw = httpGet(CHAT_URL .. "/latest", {["X-Master-Key"] = CHAT_API_KEY})
    if not raw then return false end
    local decoded
    pcall(function() decoded = HttpService:JSONDecode(raw) end)
    if not decoded or not decoded.record then return false end
    return decoded.record.ownerTaken == true
end

-- Установка облачного флага
local function setCloudOwnerFlag(ownerName)
    local raw = httpGet(CHAT_URL .. "/latest", {["X-Master-Key"] = CHAT_API_KEY})
    if not raw then return end
    local decoded
    pcall(function() decoded = HttpService:JSONDecode(raw) end)
    if not decoded or not decoded.record then return end
    local data = decoded.record
    data.ownerTaken = true
    data.ownerName = ownerName
    data.messages = data.messages or {}
    httpPut(CHAT_URL, HttpService:JSONEncode(data), {
        ["Content-Type"] = "application/json",
        ["X-Master-Key"] = CHAT_API_KEY,
    })
end

-- Выдать роль в облако
local function grantRoleCloud(targetName, role)
    local raw = httpGet(CHAT_URL .. "/latest", {["X-Master-Key"] = CHAT_API_KEY})
    if not raw then return false end
    local decoded
    pcall(function() decoded = HttpService:JSONDecode(raw) end)
    if not decoded or not decoded.record then return false end
    local data = decoded.record
    data.grantedRoles = data.grantedRoles or {}
    data.grantedRoles[targetName] = role
    httpPut(CHAT_URL, HttpService:JSONEncode(data), {
        ["Content-Type"] = "application/json",
        ["X-Master-Key"] = CHAT_API_KEY,
    })
    grantedRolesCache[targetName] = role
    return true
end

-- Получить выданные роли
local function getGrantedRoles()
    local raw = httpGet(CHAT_URL .. "/latest", {["X-Master-Key"] = CHAT_API_KEY})
    if not raw then return {} end
    local decoded
    pcall(function() decoded = HttpService:JSONDecode(raw) end)
    if not decoded or not decoded.record then return {} end
    return decoded.record.grantedRoles or {}
end

-- Heartbeat — кто играет со скриптом
local function sendHeartbeat()
    task.spawn(function()
        while true do
            pcall(function()
                local raw = httpGet(CHAT_URL .. "/latest", {["X-Master-Key"] = CHAT_API_KEY})
                if raw then
                    local decoded
                    pcall(function() decoded = HttpService:JSONDecode(raw) end)
                    if decoded and decoded.record then
                        local data = decoded.record
                        data.activeUsers = data.activeUsers or {}
                        data.activeUsers[LocalPlayer.Name] = {
                            role = myRole,
                            time = os.time(),
                        }
                        for n, info in pairs(data.activeUsers) do
                            if type(info) == "table" and os.time() - (info.time or 0) > 60 then
                                data.activeUsers[n] = nil
                            end
                        end
                        data.messages = data.messages or {}
                        httpPut(CHAT_URL, HttpService:JSONEncode(data), {
                            ["Content-Type"] = "application/json",
                            ["X-Master-Key"] = CHAT_API_KEY,
                        })
                    end
                end
            end)
            task.wait(20)
        end
    end)
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
    local lbl = Instance.new("TextLabel", banner)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBlack
    lbl.Text = "ТЕХ РАБОТЫ"
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
    sub.Text = "Скрипт временно недоступен. Заходи позже."
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
                Title = "МОПС ХАБ", Text = "ТЕХ.РАБОТЫ — функции отключены", Duration = 2,
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

--==================== ФУНКЦИИ ====================
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

--==================== ЧАТ ====================
local chatMessages = {}
local chatScroll, chatInput, chatSendBtn

local function sendChatMessage(text)
    if STATE.Maintenance then return end
    if text == "" or #text > 200 then return end
    local clean = text:gsub("|", "/"):gsub("\n", " ")
    local entry = string.format("%s|%s|%s|%d", LocalPlayer.Name, myRole, clean, os.time())
    task.spawn(function()
        local raw = httpGet(CHAT_URL .. "/latest", {["X-Master-Key"] = CHAT_API_KEY})
        if not raw then return end
        local decoded
        pcall(function() decoded = HttpService:JSONDecode(raw) end)
        if not decoded or not decoded.record then return end
        local data = decoded.record
        local messages = data.messages or {}
        table.insert(messages, entry)
        while #messages > 100 do table.remove(messages, 1) end
        data.messages = messages
        httpPut(CHAT_URL, HttpService:JSONEncode(data), {
            ["Content-Type"] = "application/json",
            ["X-Master-Key"] = CHAT_API_KEY,
        })
        task.wait(0.3)
        loadChatMessages()
        renderChatMessages()
    end)
end

function loadChatMessages()
    local raw = httpGet(CHAT_URL .. "/latest", {["X-Master-Key"] = CHAT_API_KEY})
    if not raw then return end
    local decoded
    pcall(function() decoded = HttpService:JSONDecode(raw) end)
    if not decoded or not decoded.record or not decoded.record.messages then return end
    chatMessages = {}
    for _, v in ipairs(decoded.record.messages) do
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

function createChatUI(parent)
    local hdr = Instance.new("TextLabel", parent)
    hdr.Size = UDim2.new(1, 0, 0, 24)
    hdr.BackgroundTransparency = 1
    hdr.Font = Enum.Font.GothamBold
    hdr.Text = "ГЛОБАЛЬНЫЙ ЧАТ"
    hdr.TextColor3 = THEME.Accent
    hdr.TextSize = 12
    hdr.TextXAlignment = Enum.TextXAlignment.Left
    hdr.LayoutOrder = 1

    local roleHdr = Instance.new("TextLabel", parent)
    roleHdr.Size = UDim2.new(1, 0, 0, 20)
    roleHdr.BackgroundTransparency = 1
    roleHdr.Font = Enum.Font.GothamBold
    roleHdr.Text = "Ваша роль: " .. myRole
    roleHdr.TextColor3 = ROLE_COLORS[myRole] or ROLE_COLORS.User
    roleHdr.TextSize = 12
    roleHdr.TextXAlignment = Enum.TextXAlignment.Left
    roleHdr.LayoutOrder = 2

    local chatFrame = Instance.new("Frame", parent)
    chatFrame.Size = UDim2.new(1, 0, 0, 320)
    chatFrame.BackgroundColor3 = THEME.Background
    chatFrame.BackgroundTransparency = 0.3
    chatFrame.BorderSizePixel = 0
    chatFrame.LayoutOrder = 3
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
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        chatScroll.CanvasSize = UDim2.new(0, 0, 0, cLayout.AbsoluteContentSize.Y + 10)
    end)

    chatInput = Instance.new("TextBox", parent)
    chatInput.Size = UDim2.new(1, -100, 0, 38)
    chatInput.BackgroundColor3 = THEME.Background
    chatInput.BackgroundTransparency = 0.4
    chatInput.Font = Enum.Font.Gotham
    chatInput.PlaceholderText = "Сообщение... (Enter)"
    chatInput.PlaceholderColor3 = THEME.TextDim
    chatInput.Text = ""
    chatInput.TextColor3 = THEME.Text
    chatInput.TextSize = 12
    chatInput.TextXAlignment = Enum.TextXAlignment.Left
    chatInput.ClearTextOnFocus = false
    chatInput.LayoutOrder = 4
    Instance.new("UICorner", chatInput).CornerRadius = UDim.new(0, 8)
    local ciP = Instance.new("UIPadding", chatInput) ciP.PaddingLeft = UDim.new(0, 10)

    chatSendBtn = Instance.new("TextButton", parent)
    chatSendBtn.Size = UDim2.new(0, 90, 0, 38)
    chatSendBtn.BackgroundColor3 = THEME.AccentDim
    chatSendBtn.Text = "SEND"
    chatSendBtn.Font = Enum.Font.GothamBold
    chatSendBtn.TextSize = 12
    chatSendBtn.TextColor3 = Color3.new(1,1,1)
    chatSendBtn.BorderSizePixel = 0
    chatSendBtn.LayoutOrder = 5
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

task.spawn(function()
    while true do
        task.wait(CHAT_READ_INTERVAL)
        if chatScroll and chatScroll.Parent then
            loadChatMessages()
            renderChatMessages()
        end
    end
end)

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
hudVer.Text = "v7.3"
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

local hudRole = Instance.new("TextLabel", hud)
hudRole.Size = UDim2.new(0, 100, 1, 0)
hudRole.Position = UDim2.new(1, -110, 0, 0)
hudRole.BackgroundTransparency = 1
hudRole.Font = Enum.Font.GothamBold
hudRole.Text = ROLE_ICONS[myRole] .. " " .. myRole
hudRole.TextColor3 = ROLE_COLORS[myRole]
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
openBtn.Text = "🐶"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 28
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
verLbl.Text = "v7.3 | owner + premium + chat"
verLbl.TextColor3 = THEME.TextDim
verLbl.TextSize = 9
verLbl.TextXAlignment = Enum.TextXAlignment.Left

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
    card:SetAttribute("cardTitle", title)
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

--==================== OWNER PASSWORD PROMPT ====================
local function showOwnerPasswordPrompt()
    if ownerPasswordUsed then return end
    if isOwner then return end
    
    local promptGui = Instance.new("ScreenGui")
    promptGui.Name = "MopsOwnerPrompt"
    promptGui.ResetOnSpawn = false
    promptGui.Parent = game:GetService("CoreGui")
    
    local bg = Instance.new("Frame", promptGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.BorderSizePixel = 0
    
    local box = Instance.new("Frame", promptGui)
    box.Size = UDim2.new(0, 420, 0, 260)
    box.Position = UDim2.new(0.5, -210, 0.5, -130)
    box.BackgroundColor3 = THEME.Background
    box.BorderSizePixel = 0
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)
    local bS = Instance.new("UIStroke", box)
    bS.Color = THEME.Gold
    bS.Thickness = 2
    bS.Transparency = 0.2
    
    local title = Instance.new("TextLabel", box)
    title.Size = UDim2.new(1, -40, 0, 34)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = "👑 СТАТЬ OWNER"
    title.TextColor3 = THEME.Gold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Center
    
    local sub = Instance.new("TextLabel", box)
    sub.Size = UDim2.new(1, -40, 0, 40)
    sub.Position = UDim2.new(0, 20, 0, 56)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.Text = "Введи пароль владельца.\n⚠️ После активации пароль исчезнет навсегда."
    sub.TextColor3 = THEME.TextDim
    sub.TextSize = 12
    sub.TextWrapped = true
    sub.TextXAlignment = Enum.TextXAlignment.Center
    
    local passBox = Instance.new("TextBox", box)
    passBox.Size = UDim2.new(1, -40, 0, 40)
    passBox.Position = UDim2.new(0, 20, 0, 110)
    passBox.BackgroundColor3 = THEME.Card
    passBox.BorderSizePixel = 0
    passBox.PlaceholderText = "Пароль..."
    passBox.Text = ""
    passBox.TextColor3 = THEME.Text
    passBox.PlaceholderColor3 = THEME.TextDim
    passBox.Font = Enum.Font.Gotham
    passBox.TextSize = 14
    Instance.new("UICorner", passBox).CornerRadius = UDim.new(0, 8)
    
    local statusLbl = Instance.new("TextLabel", box)
    statusLbl.Size = UDim2.new(1, -40, 0, 20)
    statusLbl.Position = UDim2.new(0, 20, 0, 156)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.Text = ""
    statusLbl.TextColor3 = THEME.Danger
    statusLbl.TextSize = 11
    statusLbl.TextXAlignment = Enum.TextXAlignment.Center
    
    local confirmBtn = Instance.new("TextButton", box)
    confirmBtn.Size = UDim2.new(1, -40, 0, 40)
    confirmBtn.Position = UDim2.new(0, 20, 0, 180)
    confirmBtn.BackgroundColor3 = THEME.Gold
    confirmBtn.BorderSizePixel = 0
    confirmBtn.Text = "🔓 АКТИВИРОВАТЬ"
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 14
    confirmBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)
    
    local skipBtn = Instance.new("TextButton", box)
    skipBtn.Size = UDim2.new(0, 100, 0, 24)
    skipBtn.Position = UDim2.new(0.5, -50, 1, -30)
    skipBtn.BackgroundTransparency = 1
    skipBtn.Text = "Позже"
    skipBtn.Font = Enum.Font.Gotham
    skipBtn.TextSize = 11
    skipBtn.TextColor3 = THEME.TextFaint
    
    confirmBtn.MouseButton1Click:Connect(function()
        if passBox.Text == OWNER_PASSWORD then
            isOwner = true
            myRole = "Owner"
            ownerPasswordUsed = true
            setLocalOwnerFlag()
            setCloudOwnerFlag(LocalPlayer.Name)
            hudRole.Text = ROLE_ICONS[myRole] .. " " .. myRole
            hudRole.TextColor3 = ROLE_COLORS[myRole]
            
            statusLbl.TextColor3 = THEME.Success
            statusLbl.Text = "✅ Успешно! Ты теперь Owner."
            
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "MOPS HUB",
                    Text = "👑 Owner активирован!",
                    Duration = 4,
                })
            end)
            
            task.wait(1)
            promptGui:Destroy()
            
            if addOwnerTab then addOwnerTab() end
            if currentTab == "misc" or currentTab == "main" then rebuildContent() end
        else
            statusLbl.TextColor3 = THEME.Danger
            statusLbl.Text = "❌ Неверный пароль"
            passBox.Text = ""
        end
    end)
    
    skipBtn.MouseButton1Click:Connect(function()
        promptGui:Destroy()
    end)
end

--==================== РЕБИЛД ====================
local currentTab = "combat"
local function rebuildContent()
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

        local c2 = makeCard("Lighting", 2)
        addToggle(c2, 56, "Fullbright", CONFIG.Fullbright, function(s) CONFIG.Fullbright = s applyFullbright(s) end)
        addToggle(c2, 90, "No Fog", CONFIG.NoFog, function(s) CONFIG.NoFog = s applyNoFog(s) end)

    elseif currentTab == "misc" then
        if not isOwner and not ownerPasswordUsed then
            local cOwner = makeCard("👑 Owner доступ", 0)
            local btnOwner = Instance.new("TextButton", cOwner)
            btnOwner.Size = UDim2.new(1, -28, 0, 36)
            btnOwner.Position = UDim2.new(0, 14, 0, 56)
            btnOwner.BackgroundColor3 = THEME.Gold
            btnOwner.BorderSizePixel = 0
            btnOwner.Text = "🔓 Ввести пароль Owner"
            btnOwner.Font = Enum.Font.GothamBold
            btnOwner.TextSize = 13
            btnOwner.TextColor3 = Color3.fromRGB(20, 20, 20)
            Instance.new("UICorner", btnOwner).CornerRadius = UDim.new(0, 8)
            btnOwner.MouseButton1Click:Connect(function()
                showOwnerPasswordPrompt()
            end)
        end
        
        local c1 = makeCard("Anti-AFK", 1)
        addToggle(c1, 56, "Anti-AFK", CONFIG.AntiAfk, function(s) CONFIG.AntiAfk = s applyAntiAfk(s) end)

        local c2 = makeCard("HUD", 2)
        addToggle(c2, 56, "Watermark", true, function(s) hud.Visible = s end)
        addToggle(c2, 90, "Show FPS", true, function(s) hudFps.Visible = s end)

    elseif currentTab == "chat" then
        createChatUI(contentScroll)

    elseif currentTab == "owner" then
        if not isOwner then return end
        
        -- Карточка: Выдать Premium
        local c1 = makeCard("👑 Выдать Premium", 1)
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
        
        local grantedCache = getGrantedRoles()
        
        local function refreshPlayers()
            for _, ch in ipairs(playersScroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            for _, plr in ipairs(Players:GetPlayers()) do
                local row = Instance.new("Frame", playersScroll)
                row.Size = UDim2.new(1, -8, 0, 34)
                row.BackgroundColor3 = THEME.Card
                row.BackgroundTransparency = 0.3
                row.BorderSizePixel = 0
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
                
                local nL = Instance.new("TextLabel", row)
                nL.Size = UDim2.new(0.55, 0, 1, 0)
                nL.Position = UDim2.new(0, 10, 0, 0)
                nL.BackgroundTransparency = 1
                nL.Font = Enum.Font.GothamMedium
                nL.Text = plr.Name .. (plr == LocalPlayer and " (ты)" or "")
                nL.TextColor3 = THEME.Text
                nL.TextSize = 11
                nL.TextXAlignment = Enum.TextXAlignment.Left
                
                local currentRole = grantedCache[plr.Name]
                local btn = Instance.new("TextButton", row)
                btn.Size = UDim2.new(0.4, -10, 0, 24)
                btn.Position = UDim2.new(0.6, 0, 0.5, -12)
                btn.BorderSizePixel = 0
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 10
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
                
                if currentRole == "Premium" then
                    btn.Text = "💎 Уже Premium"
                    btn.BackgroundColor3 = Color3.fromRGB(80, 50, 130)
                    btn.TextColor3 = Color3.fromRGB(220, 200, 255)
                elseif currentRole == "Owner" then
                    btn.Text = "👑 Owner"
                    btn.BackgroundColor3 = Color3.fromRGB(130, 100, 20)
                    btn.TextColor3 = Color3.fromRGB(255, 220, 100)
                else
                    btn.Text = "🎁 Выдать 💎"
                    btn.BackgroundColor3 = THEME.Success
                    btn.TextColor3 = Color3.fromRGB(20, 20, 20)
                    btn.MouseButton1Click:Connect(function()
                        local ok = grantRoleCloud(plr.Name, "Premium")
                        if ok then
                            btn.Text = "💎 Уже Premium"
                            btn.BackgroundColor3 = Color3.fromRGB(80, 50, 130)
                            btn.TextColor3 = Color3.fromRGB(220, 200, 255)
                            pcall(function()
                                game:GetService("StarterGui"):SetCore("SendNotification", {
                                    Title = "MOPS HUB",
                                    Text = "💎 Premium выдан: " .. plr.Name,
                                    Duration = 3,
                                })
                            end)
                        end
                    end)
                end
            end
        end
        
        refreshPlayers()
        Players.PlayerAdded:Connect(function() task.wait(0.5) refreshPlayers() end)
        Players.PlayerRemoving:Connect(function() task.wait(0.5) refreshPlayers() end)
        
        -- Карточка: Кто играет со скриптом
        local c2 = makeCard("👥 Играют со скриптом", 2)
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
                local raw = httpGet(CHAT_URL .. "/latest", {["X-Master-Key"] = CHAT_API_KEY})
                if not raw then return end
                local decoded
                pcall(function() decoded = HttpService:JSONDecode(raw) end)
                if not decoded or not decoded.record then return end
                local users = decoded.record.activeUsers or {}
                for name, info in pairs(users) do
                    local row = Instance.new("Frame", activeScroll)
                    row.Size = UDim2.new(1, -8, 0, 30)
                    row.BackgroundColor3 = THEME.Card
                    row.BackgroundTransparency = 0.3
                    row.BorderSizePixel = 0
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
                    
                    local rl = type(info) == "table" and info.role or "User"
                    local icon = ROLE_ICONS[rl] or "👤"
                    
                    local lbl = Instance.new("TextLabel", row)
                    lbl.Size = UDim2.new(1, -10, 1, 0)
                    lbl.Position = UDim2.new(0, 10, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.GothamMedium
                    lbl.Text = icon .. " " .. name .. "  [" .. rl .. "]"
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
        info.Size = UDim2.new(1, -28, 0, 100)
        info.Position = UDim2.new(0, 14, 0, 56)
        info.BackgroundTransparency = 1
        info.Font = Enum.Font.Gotham
        info.Text = "Mops Hub v7.3\nMonkey Evolution Client\n\nRIGHT SHIFT — открыть меню\n🐶 — кнопка слева\n\n👑 Owner пароль: Kikisk234"
        info.TextColor3 = THEME.TextDim
        info.TextSize = 11
        info.TextWrapped = true
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.TextYAlignment = Enum.TextYAlignment.Top
    end
end

--==================== SIDEBAR ====================
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

makeTab("main", "M", "Main")
makeTab("combat", "C", "Combat")
makeTab("movement", "M", "Movement")
makeTab("render", "R", "Render")
makeTab("misc", "M", "Misc")
makeTab("chat", "💬", "Chat")

-- Функция добавления вкладки Owner
function addOwnerTab()
    if not isOwner then return end
    if sidebarButtons["owner"] then return end
    makeTab("owner", "👑", "Owner")
    print("[MopsHub] Вкладка Owner добавлена")
end

-- Активация подсветки первой вкладки
sidebarButtons["combat"].button.BackgroundColor3 = THEME.AccentDim
sidebarButtons["combat"].button.BackgroundTransparency = 0.1
sidebarButtons["combat"].icon.TextColor3 = Color3.new(1,1,1)
sidebarButtons["combat"].label.TextColor3 = Color3.new(1,1,1)
rebuildContent()

--==================== ИНИЦИАЛИЗАЦИЯ OWNER ====================
task.spawn(function()
    task.wait(1)
    
    -- Проверяем локальный флаг
    local saved = loadSavedRole()
    if saved == "used" or saved == "Owner" then
        ownerPasswordUsed = true
    end
    
    -- Проверяем облако
    local cloudUsed = checkCloudOwnerFlag()
    if cloudUsed then
        ownerPasswordUsed = true
        setLocalOwnerFlag()
    end
    
    -- Запускаем heartbeat
    sendHeartbeat()
    
    -- Если пароль не использован — показываем окно через 3 сек
    if not ownerPasswordUsed then
        task.wait(3)
        showOwnerPasswordPrompt()
    else
        -- Если пароль уже использован кем-то другим — просто уведомление
        print("[MopsHub] Пароль Owner уже активирован кем-то.")
    end
end)

--==================== RIGHT SHIFT ====================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setMenuVisible(not main.Visible)
    end
end)

print("[Mops Hub v7.3] Загружен. RIGHT SHIFT — открыть. Пароль Owner: Kikisk234")
