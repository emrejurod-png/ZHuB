-- ============================================================
--  ZHuB Professional System | Final Build
-- ============================================================

if getgenv().ZHuB_Active then
    warn("[ZHuB] Instance already active.")
    return
end
getgenv().ZHuB_Active = true

-- ══ SERVICES ════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UIS              = game:GetService("UserInputService")
local TS               = game:GetService("TweenService")
local VIM              = game:GetService("VirtualInputManager")
local Lighting         = game:GetService("Lighting")
local Debris           = game:GetService("Debris")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")
local LP               = Players.LocalPlayer

-- ══ GLOBAL STATE ════════════════════════════════════════════
local customFriends    = {}
local isActive         = true
local connections      = {}
local isBlocking       = false
local isFlying         = false
local isLockAiming     = false
local isKillAuraActive = false
local isAutoBlocking   = false
local isRightFiring    = false
local currentTarget    = nil
local bVel, bGyro
local espLabels        = {}
local origMinZoom, origMaxZoom
local origCamOffset
local lastCamCF        = nil  -- For no-recoil compensation
local isFiring         = false

-- Lighting backup
local origOutdoor    = Lighting.OutdoorAmbient
local origAmbient    = Lighting.Ambient
local origColorShift = Lighting.ColorShift_Top

-- ══ CONFIG ══════════════════════════════════════════════════
local CFG = {
    aimbot=false, silentAim=false, lockAim=false, teamCheck=false,
    showFov=false, fovRadius=150, aimSmooth=0.15, aimPart="Head",
    wallCheck=true, aimHold=false,
    
    autoBlock=false, hitbox=false, hitboxSize=12,
    m1Magnet=false, killAura=false, antiStun=false,
    reach=false, reachDist=15, noRecoil=false, antiKick=true,
    
    speedhack=false, walkSpeed=70, fly=false, flySpeed=70,
    clickTp=false, noclip=false, infiniteJump=false, antiVoid=false,
    
    esp=false, espNames=true, espDistance=true, espHealth=true,
    espTracers=false, chams=false, handGlow=false,
    fovChanger=false, fovValue=120, thirdPerson=false, thirdDist=15,
    rainbowSky=false, watermark=true,
    
    menuKey=Enum.KeyCode.Insert, theme="Purple",
}

local THEMES = {
    Purple = {Color3.fromRGB(160, 110, 255), Color3.fromRGB(80, 55, 128)},
    Red    = {Color3.fromRGB(255, 80, 80),   Color3.fromRGB(128, 40, 40)},
    Blue   = {Color3.fromRGB(80, 160, 255),  Color3.fromRGB(40, 80, 128)},
    Green  = {Color3.fromRGB(80, 255, 160),  Color3.fromRGB(40, 128, 80)},
    White  = {Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 150, 150)},
}
local function A() return THEMES[CFG.theme][1] end
local function D() return THEMES[CFG.theme][2] end

-- ══ HELPERS ═════════════════════════════════════════════════
local function AddConn(c) table.insert(connections, c) end
local function Tw(obj, props, t, sty, dir)
    if not obj then return nil end
    if not obj:IsA("Sound") and not obj.Parent then return nil end
    local ok, tween = pcall(function()
        return TS:Create(obj, TweenInfo.new(t or 0.2, sty or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    end)
    if ok and tween then tween:Play(); return tween end
    return nil
end

local function IsFriend(pl)
    if customFriends[pl.Name] then return true end
    if CFG.teamCheck then
        local mt, tt = LP.Team, pl.Team
        if mt ~= nil and tt ~= nil and mt == tt then return true end
    end
    return false
end

local function GetPart(char, pref)
    if not char then return nil end
    local order = pref == "Head" and {"Head","UpperTorso","HumanoidRootPart"}
               or pref == "UpperTorso" and {"UpperTorso","HumanoidRootPart","Head"}
               or {"HumanoidRootPart","UpperTorso","Head"}
    for _, n in ipairs(order) do
        local p = char:FindFirstChild(n)
        if p then return p end
    end
    return char:FindFirstChildWhichIsA("BasePart")
end

local function GetCamera()
    local cam = workspace.CurrentCamera
    if not cam then cam = workspace:FindFirstChildOfClass("Camera") end
    return cam
end

local function IsVis(part, char)
    local ok, r = pcall(function()
        local cam = GetCamera()
        if not cam then return false end
        local ori = cam.CFrame.Position
        local dir = part.Position - ori
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.IgnoreWater = true
        rp.FilterDescendantsInstances = {LP.Character or workspace}
        local res = workspace:Raycast(ori, dir, rp)
        if not res then return true end
        if res.Instance:IsDescendantOf(char) then return true end
        return false
    end)
    return ok and r or false
end

local function IsShiftLocked() return LP.CameraMode == Enum.CameraMode.LockFirstPerson end

-- ══ CONFIG I/O ══════════════════════════════════════════════
local function SaveCFG()
    pcall(function() if writefile then writefile("ZHuB_V3.json", HttpService:JSONEncode(CFG)) end end)
end
local function LoadCFG()
    pcall(function()
        if readfile and isfile and isfile("ZHuB_V3.json") then
            local data = HttpService:JSONDecode(readfile("ZHuB_V3.json"))
            for k, v in pairs(data) do if CFG[k] ~= nil then CFG[k] = v end end
        end
    end)
end
LoadCFG()

-- ══ GUI SETUP ═══════════════════════════════════════════════
local guiParent
local s, r = pcall(function() return gethui() end)
if s and r then guiParent = r else
    local s2, r2 = pcall(function() return CoreGui end)
    if s2 and r2 then guiParent = r2 else guiParent = LP:WaitForChild("PlayerGui") end
end

for _, v in ipairs(guiParent:GetChildren()) do
    if string.find(v.Name, "ZHuB_") then v:Destroy() end
end

local SG = Instance.new("ScreenGui")
SG.Name = "ZHuB_V2"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = guiParent

-- ══ LOAD SCREEN ══════════════════════════════════════════════
local LS = Instance.new("Frame")
LS.Size = UDim2.new(1,0,1,0)
LS.BackgroundColor3 = Color3.fromRGB(2,2,6)
LS.ZIndex = 200
LS.Parent = SG

-- Yıldızlar
for _ = 1, 70 do
    local st = Instance.new("Frame")
    local sz = math.random(1,3)
    st.Size = UDim2.new(0,sz,0,sz)
    st.Position = UDim2.new(math.random()*1.2-0.1,0,math.random()*1.2-0.1,0)
    st.BackgroundColor3 = Color3.new(1,1,1)
    st.BackgroundTransparency = math.random(30,85)/100
    st.ZIndex = 201; st.Parent = LS
    Instance.new("UICorner",st).CornerRadius = UDim.new(1,0)
end

local bhA = Instance.new("ImageLabel")
bhA.Size = UDim2.new(0,200,0,200)
bhA.Position = UDim2.new(0.5,-100,0.38,-100)
bhA.BackgroundTransparency = 1
bhA.Image = "rbxassetid://72996506762269"
bhA.ImageColor3 = A()
bhA.ImageTransparency = 0.4
bhA.ZIndex = 202; bhA.Parent = LS

local bhM = Instance.new("ImageLabel")
bhM.Size = UDim2.new(0,150,0,150)
bhM.Position = UDim2.new(0.5,-75,0.5,-75)
bhM.BackgroundTransparency = 1
bhM.Image = "rbxassetid://72996506762269"
bhM.ZIndex = 203; bhM.Parent = bhA

local ldTit = Instance.new("TextLabel")
ldTit.Size = UDim2.new(0,300,0,34)
ldTit.Position = UDim2.new(0.5,-150,0.38,88)
ldTit.BackgroundTransparency = 1
ldTit.TextColor3 = A()
ldTit.Text = "Z H u B"; ldTit.Font = Enum.Font.GothamBold
ldTit.TextSize = 26; ldTit.ZIndex = 202; ldTit.Parent = LS

local ldSub = Instance.new("TextLabel")
ldSub.Size = UDim2.new(0,300,0,20)
ldSub.Position = UDim2.new(0.5,-150,0.38,122)
ldSub.BackgroundTransparency = 1
ldSub.TextColor3 = D()
ldSub.Text = "Universal V2.0"; ldSub.Font = Enum.Font.Gotham
ldSub.TextSize = 12; ldSub.ZIndex = 202; ldSub.Parent = LS

local ldStat = Instance.new("TextLabel")
ldStat.Size = UDim2.new(0,400,0,18)
ldStat.Position = UDim2.new(0.5,-200,0.38,152)
ldStat.BackgroundTransparency = 1
ldStat.TextColor3 = Color3.fromRGB(80,65,110)
ldStat.Text = ""; ldStat.Font = Enum.Font.Gotham
ldStat.TextSize = 10; ldStat.ZIndex = 202; ldStat.Parent = LS

local pgBg = Instance.new("Frame")
pgBg.Size = UDim2.new(0,240,0,4)
pgBg.Position = UDim2.new(0.5,-120,0.38,176)
pgBg.BackgroundColor3 = Color3.fromRGB(22,12,40)
pgBg.ZIndex = 202; pgBg.Parent = LS
Instance.new("UICorner",pgBg).CornerRadius = UDim.new(1,0)

local pgFill = Instance.new("Frame")
pgFill.Size = UDim2.new(0,0,1,0)
pgFill.BackgroundColor3 = A()
pgFill.ZIndex = 203; pgFill.Parent = pgBg
Instance.new("UICorner",pgFill).CornerRadius = UDim.new(1,0)

-- Load animasyon
local isLoadScreenDone = false
task.spawn(function()
    local ang = 0
    while LS and LS.Parent do
        ang = ang - 0.6
        bhM.Rotation = ang; bhA.Rotation = ang*0.4
        local p = 0.5 + 0.12*math.sin(tick()*2.5)
        local sz = 200 + p*28
        bhA.Size = UDim2.new(0,sz,0,sz)
        bhA.Position = UDim2.new(0.5,-sz/2,0.38,-sz/2)
        task.wait(0.016)
    end
end)

-- Meteor
local metF = Instance.new("Folder"); metF.Parent = LS
task.spawn(function()
    while LS and LS.Parent and not isLoadScreenDone do
        if math.random() > 0.5 then
            local hd = Instance.new("Frame")
            hd.Size = UDim2.new(0,3,0,3)
            hd.BackgroundColor3 = Color3.new(1,1,1)
            hd.ZIndex = 204; hd.Parent = metF
            Instance.new("UICorner",hd).CornerRadius = UDim.new(1,0)
            local sx = math.random()>0.5 and -0.05 or 1.05
            local ex = sx < 0 and 1.05 or -0.05
            local sy = math.random()*0.5-0.05
            local ey = sy + math.random()*0.5+0.2
            local dur = math.random(18,32)/10
            local st = tick()
            local amp = math.random(30,120)/1000
            local fr = math.random(2,5)
            local cn; cn = RunService.RenderStepped:Connect(function()
                local el = tick()-st
                if el > dur or not (LS and LS.Parent) then
                    cn:Disconnect(); pcall(function() hd:Destroy() end); return
                end
                local al = el/dur
                local cx = sx+(ex-sx)*al
                local cy = sy+(ey-sy)*al
                local off = math.sin(al*math.pi*fr)*amp
                hd.Position = UDim2.new(cx,0,cy+off,0)
                if math.random()>0.25 then
                    local p2 = Instance.new("Frame")
                    p2.Size = UDim2.new(0,2,0,2)
                    p2.Position = hd.Position
                    p2.BackgroundColor3 = Color3.fromRGB(200,200,255)
                    p2.ZIndex = 203; p2.Parent = metF
                    Instance.new("UICorner",p2).CornerRadius = UDim.new(1,0)
                    Tw(p2,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1},0.6,Enum.EasingStyle.Quad):Play()
                    Debris:AddItem(p2,0.65)
                end
            end)
        end
        task.wait(math.random(3,8)/10)
    end
end)

-- Ambient ses
local ambS = Instance.new("Sound")
ambS.SoundId = "rbxassetid://140170255989706"
ambS.Volume = 0.8; ambS.Looped = true; ambS.Parent = LS
pcall(function() ambS:Play() end)

-- Sesleri sustur
local iInj = true
local oVol = {}
local function silSnd(obj)
    if obj:IsA("Sound") and obj ~= ambS then
        if not oVol[obj] then oVol[obj] = obj.Volume end
        obj.Volume = 0
        if obj.IsPlaying then pcall(function() obj:Stop() end) end
    end
end
for _, obj in ipairs(game:GetDescendants()) do pcall(silSnd,obj) end
local dConn = game.DescendantAdded:Connect(function(obj)
    if iInj then pcall(silSnd,obj) end
end)

local function SetSt(txt, prog)
    ldStat.Text = txt
    Tw(pgFill,{Size=UDim2.new(prog,0,1,0)},0.4)
end

SetSt("Connecting to secure servers...", 0.2)
task.wait(4)
SetSt("Bypassing game security...", 0.5)
task.wait(5)
SetSt("Loading core modules...", 0.75)
task.wait(4)
SetSt("Initializing UI...", 0.9)
task.wait(1)

-- ══ MAIN UI WINDOW ══════════════════════════════════════════
local mFrm = Instance.new("Frame")
mFrm.Size = UDim2.new(0,0,0,0)
mFrm.Position = UDim2.new(0.5,-330,0.5,-230)
mFrm.BackgroundColor3 = Color3.fromRGB(12,12,16)
mFrm.BackgroundTransparency = 1
mFrm.BorderSizePixel = 0
mFrm.Active = true; mFrm.Draggable = true
mFrm.ClipsDescendants = true
mFrm.Parent = SG
Instance.new("UICorner",mFrm).CornerRadius = UDim.new(0,14)
Tw(mFrm,{Size=UDim2.new(0,660,0,460),BackgroundTransparency=0},0.8,Enum.EasingStyle.Exponential)

local mStr = Instance.new("UIStroke",mFrm)
mStr.Color = A(); mStr.Thickness = 1.5; mStr.Transparency = 0.4

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0,150,1,0)
sidebar.BackgroundColor3 = Color3.fromRGB(16,16,20)
sidebar.BorderSizePixel = 0; sidebar.Parent = mFrm
Instance.new("UICorner",sidebar).CornerRadius = UDim.new(0,14)
local sbCover = Instance.new("Frame")
sbCover.Size = UDim2.new(0,14,1,0); sbCover.Position = UDim2.new(1,-14,0,0)
sbCover.BackgroundColor3 = Color3.fromRGB(16,16,20); sbCover.BorderSizePixel = 0
sbCover.Parent = sidebar

-- Sidebar accent line
local sbLine = Instance.new("Frame")
sbLine.Size = UDim2.new(0,1,1,-20); sbLine.Position = UDim2.new(1,0,0,10)
sbLine.BackgroundColor3 = Color3.fromRGB(40,40,50); sbLine.Parent = sidebar

-- Sidebar branding
local sbLogo = Instance.new("TextLabel")
sbLogo.Size = UDim2.new(1,0,0,50); sbLogo.Position = UDim2.new(0,0,0,8)
sbLogo.BackgroundTransparency = 1
sbLogo.TextColor3 = A()
sbLogo.Text = "ZHuB"; sbLogo.Font = Enum.Font.GothamBlack; sbLogo.TextSize = 22
sbLogo.Parent = sidebar
local sbSub = Instance.new("TextLabel")
sbSub.Size = UDim2.new(1,0,0,16); sbSub.Position = UDim2.new(0,0,0,48)
sbSub.BackgroundTransparency = 1
sbSub.TextColor3 = Color3.fromRGB(80,80,95)
sbSub.Text = "Professional v2.0"; sbSub.Font = Enum.Font.Gotham; sbSub.TextSize = 9
sbSub.Parent = sidebar

-- Sidebar divider
local sbDiv = Instance.new("Frame")
sbDiv.Size = UDim2.new(1,-20,0,1); sbDiv.Position = UDim2.new(0,10,0,70)
sbDiv.BackgroundColor3 = Color3.fromRGB(35,35,45); sbDiv.Parent = sidebar

-- Top right buttons
local function MkTBtn(ico, xOf, clr)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,30,0,30)
    b.Position = UDim2.new(1,xOf,0,10)
    b.BackgroundColor3 = Color3.fromRGB(25,25,30)
    b.Text = ico; b.TextColor3 = clr
    b.TextSize = 14; b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false; b.Parent = mFrm
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
    b.MouseEnter:Connect(function() Tw(b,{BackgroundColor3=Color3.fromRGB(45,40,55)},0.15) end)
    b.MouseLeave:Connect(function() Tw(b,{BackgroundColor3=Color3.fromRGB(25,25,30)},0.15) end)
    return b
end
local minBtn   = MkTBtn("-", -78, Color3.fromRGB(200,200,210))
local closeBtn = MkTBtn("X", -42, Color3.fromRGB(255,90,90))

-- Mini Toggle Button (when minimized)
local tBtn = Instance.new("TextButton")
tBtn.Size = UDim2.new(0,44,0,44)
tBtn.Position = UDim2.new(0,15,0.5,-22)
tBtn.BackgroundColor3 = Color3.fromRGB(16,16,20)
tBtn.BackgroundTransparency = 0.05
tBtn.Text = "Z"; tBtn.Font = Enum.Font.GothamBlack
tBtn.TextSize = 20; tBtn.TextColor3 = A()
tBtn.Visible = false; tBtn.Active = true; tBtn.Draggable = true
tBtn.Parent = SG
Instance.new("UICorner",tBtn).CornerRadius = UDim.new(0,12)
local tBStr = Instance.new("UIStroke",tBtn)
tBStr.Color = A(); tBStr.Thickness = 1.5; tBStr.Transparency = 0.3
tBtn.MouseEnter:Connect(function() Tw(tBtn,{BackgroundTransparency=0},0.15); Tw(tBStr,{Transparency=0},0.15) end)
tBtn.MouseLeave:Connect(function() Tw(tBtn,{BackgroundTransparency=0.05},0.15); Tw(tBStr,{Transparency=0.3},0.15) end)

closeBtn.MouseButton1Click:Connect(function()
    isActive = false
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    SG:Destroy(); getgenv().ZHuB_Active = false
end)
minBtn.MouseButton1Click:Connect(function() mFrm.Visible=false; tBtn.Visible=true end)
tBtn.MouseButton1Click:Connect(function() mFrm.Visible=true; tBtn.Visible=false end)

-- ── TAB BUTTONS (sidebar) ───────────────────────────────────
local tabBtnContainer = Instance.new("Frame")
tabBtnContainer.Size = UDim2.new(1,-10,1,-85); tabBtnContainer.Position = UDim2.new(0,5,0,78)
tabBtnContainer.BackgroundTransparency = 1; tabBtnContainer.Parent = sidebar
local tabBtnLayout = Instance.new("UIListLayout",tabBtnContainer)
tabBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder; tabBtnLayout.Padding = UDim.new(0,4)

local pCon = Instance.new("Frame")
pCon.Size = UDim2.new(1,-165,1,-15); pCon.Position = UDim2.new(0,158,0,8)
pCon.BackgroundTransparency = 1; pCon.Parent = mFrm

local tabsList = {}
local function MkTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,36)
    btn.BackgroundColor3 = Color3.fromRGB(16,16,20)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(120,120,135)
    btn.Text = "  " .. icon .. "  " .. name
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false; btn.Parent = tabBtnContainer
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
    btn.MouseEnter:Connect(function()
        if not btn:GetAttribute("Active") then Tw(btn,{BackgroundTransparency=0.5},0.1) end
    end)
    btn.MouseLeave:Connect(function()
        if not btn:GetAttribute("Active") then Tw(btn,{BackgroundTransparency=1},0.1) end
    end)
    
    -- Active indicator
    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0,3,0,20); ind.Position = UDim2.new(0,-1,0.5,-10)
    ind.BackgroundColor3 = A(); ind.BackgroundTransparency = 1; ind.Parent = btn
    Instance.new("UICorner",ind).CornerRadius = UDim.new(0,2)
    
    local pg = Instance.new("ScrollingFrame")
    pg.Name = name; pg.Size = UDim2.new(1,0,1,0)
    pg.BackgroundTransparency = 1; pg.BorderSizePixel = 0
    pg.ScrollBarThickness = 3; pg.ScrollBarImageColor3 = D()
    pg.Visible = false; pg.Parent = pCon
    local grid = Instance.new("UIGridLayout",pg)
    grid.CellSize = UDim2.new(0,235,0,44)
    grid.CellPadding = UDim2.new(0,10,0,8)
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
    
    table.insert(tabsList,{b=btn,p=pg,ind=ind})
    return btn, pg
end

-- ══ UI COMPONENTS ═══════════════════════════════════════════
local function MkToggle(lbl, page, key, cb)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(22,22,26)
    btn.TextColor3 = Color3.fromRGB(220,220,230)
    btn.Text = "   "..lbl; btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12; btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false; btn.Parent = page
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
    
    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0,34,0,18); pill.Position = UDim2.new(1,-44,0.5,-9)
    pill.BackgroundColor3 = Color3.fromRGB(40,40,45); pill.Parent = btn
    Instance.new("UICorner",pill).CornerRadius = UDim.new(1,0)
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,14,0,14); dot.Position = UDim2.new(0,2,0.5,-7)
    dot.BackgroundColor3 = Color3.fromRGB(100,100,110); dot.Parent = pill
    Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)
    
    local function Ref()
        local on = CFG[key]
        Tw(pill,{BackgroundColor3=on and D() or Color3.fromRGB(40,40,45)})
        Tw(dot,{BackgroundColor3=on and A() or Color3.fromRGB(100,100,110),
                Position=on and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)})
        Tw(btn,{BackgroundColor3=on and Color3.fromRGB(28,26,35) or Color3.fromRGB(22,22,26)})
    end
    
    btn.MouseButton1Click:Connect(function()
        CFG[key] = not CFG[key]; Ref()
        if cb then cb(CFG[key]) end
    end)
    Ref()
    return btn, Ref
end

local function MkSlider(lbl, page, key, mn, mx, fmt, cb)
    local fr = Instance.new("Frame")
    fr.BackgroundColor3 = Color3.fromRGB(22,22,26); fr.Parent = page
    Instance.new("UICorner",fr).CornerRadius = UDim.new(0,8)
    
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1,-10,0,22); tl.Position = UDim2.new(0,10,0,4)
    tl.BackgroundTransparency = 1; tl.TextColor3 = Color3.fromRGB(220,220,230)
    tl.Font = Enum.Font.GothamSemibold; tl.TextSize = 11
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Text = lbl; tl.Parent = fr
    
    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0,70,0,22); vl.Position = UDim2.new(1,-80,0,4)
    vl.BackgroundTransparency = 1; vl.TextColor3 = A()
    vl.Font = Enum.Font.GothamBold; vl.TextSize = 11
    vl.TextXAlignment = Enum.TextXAlignment.Right; vl.Parent = fr
    
    local trBg = Instance.new("Frame")
    trBg.Size = UDim2.new(1,-20,0,6); trBg.Position = UDim2.new(0,10,1,-14)
    trBg.BackgroundColor3 = Color3.fromRGB(40,40,45); trBg.Parent = fr
    Instance.new("UICorner",trBg).CornerRadius = UDim.new(1,0)
    
    local trFl = Instance.new("Frame")
    trFl.Size = UDim2.new(0,0,1,0); trFl.BackgroundColor3 = A(); trFl.Parent = trBg
    Instance.new("UICorner",trFl).CornerRadius = UDim.new(1,0)
    
    local hnd = Instance.new("Frame")
    hnd.Size = UDim2.new(0,14,0,14); hnd.Position = UDim2.new(0,-7,0.5,-7)
    hnd.BackgroundColor3 = Color3.new(1,1,1); hnd.ZIndex = 2; hnd.Parent = trFl
    Instance.new("UICorner",hnd).CornerRadius = UDim.new(1,0)
    
    local function SetV(v)
        if mx <= 1 then v = math.clamp(math.floor(v*100+0.5)/100, mn, mx)
        else v = math.clamp(math.floor(v+0.5), mn, mx) end
        CFG[key] = v
        trFl.Size = UDim2.new((v-mn)/(mx-mn),0,1,0)
        vl.Text = fmt and string.format(fmt,v) or tostring(v)
        if cb then cb(v) end
    end
    
    local drag = false
    trBg.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true end
    end)
    AddConn(UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end))
    AddConn(UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local ab = trBg.AbsolutePosition; local sz = trBg.AbsoluteSize
            local rel = math.clamp((i.Position.X-ab.X)/sz.X,0,1)
            SetV(mn+(mx-mn)*rel)
        end
    end))
    SetV(CFG[key])
    return fr, SetV
end

local function MkDrop(lbl, page, opts, key, cb)
    local fr = Instance.new("Frame")
    fr.BackgroundColor3 = Color3.fromRGB(22,22,26); fr.Parent = page
    Instance.new("UICorner",fr).CornerRadius = UDim.new(0,8)
    
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(0.5,0,1,0); tl.Position = UDim2.new(0,10,0,0)
    tl.BackgroundTransparency = 1; tl.TextColor3 = Color3.fromRGB(220,220,230)
    tl.Font = Enum.Font.GothamSemibold; tl.TextSize = 11
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Text = lbl; tl.Parent = fr
    
    local vb = Instance.new("TextButton")
    vb.Size = UDim2.new(0.45,0,0,30); vb.Position = UDim2.new(0.5,0,0.5,-15)
    vb.BackgroundColor3 = Color3.fromRGB(35,35,40); vb.TextColor3 = A()
    vb.Font = Enum.Font.GothamBold; vb.TextSize = 11
    vb.Text = tostring(CFG[key]); vb.AutoButtonColor = false; vb.Parent = fr
    Instance.new("UICorner",vb).CornerRadius = UDim.new(0,6)
    
    local ddP = Instance.new("Frame")
    ddP.ZIndex = 500; ddP.BackgroundColor3 = Color3.fromRGB(25,25,30)
    ddP.ClipsDescendants = true; ddP.Visible = false; ddP.Parent = SG
    local ddS = Instance.new("UIStroke",ddP)
    ddS.Color = A(); ddS.Thickness = 1.5; ddS.Transparency = 0.3
    Instance.new("UICorner",ddP).CornerRadius = UDim.new(0,8)
    Instance.new("UIListLayout",ddP).SortOrder = Enum.SortOrder.LayoutOrder
    
    local ddOpen = false
    local function CloseDD()
        ddOpen = false
        Tw(ddP,{Size=UDim2.new(0,ddP.AbsoluteSize.X,0,0)},0.2)
        task.delay(0.2,function() ddP.Visible=false end)
    end
    
    for _, opt in ipairs(opts) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1,0,0,32)
        ob.BackgroundColor3 = Color3.fromRGB(25,25,30)
        ob.TextColor3 = tostring(opt)==tostring(CFG[key]) and A() or Color3.fromRGB(180,180,190)
        ob.Font = Enum.Font.GothamSemibold; ob.TextSize = 11
        ob.Text = tostring(opt); ob.ZIndex = 501; ob.AutoButtonColor = false; ob.Parent = ddP
        ob.MouseEnter:Connect(function() Tw(ob,{BackgroundColor3=Color3.fromRGB(40,40,45)}) end)
        ob.MouseLeave:Connect(function() Tw(ob,{BackgroundColor3=Color3.fromRGB(25,25,30)}) end)
        ob.MouseButton1Click:Connect(function()
            CFG[key] = opt; vb.Text = tostring(opt)
            if cb then cb(opt) end; CloseDD()
        end)
    end
    
    vb.MouseButton1Click:Connect(function()
        if ddOpen then CloseDD(); return end
        ddOpen = true
        local abs = vb.AbsolutePosition; local sz2 = vb.AbsoluteSize
        local h = #opts*32
        ddP.Position = UDim2.new(0,abs.X,0,abs.Y+sz2.Y+5)
        ddP.Size = UDim2.new(0,sz2.X,0,0); ddP.Visible = true
        Tw(ddP,{Size=UDim2.new(0,sz2.X,0,h)},0.25,Enum.EasingStyle.Back)
    end)
    AddConn(UIS.InputBegan:Connect(function(i)
        if ddOpen and i.UserInputType==Enum.UserInputType.MouseButton1 then task.delay(0.1, CloseDD) end
    end))
    return fr
end

local function MkBtn(lbl, page, cb)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    btn.TextColor3 = A(); btn.Text = lbl
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    btn.AutoButtonColor = false; btn.Parent = page
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
    local st = Instance.new("UIStroke",btn)
    st.Color = A(); st.Thickness = 1.5; st.Transparency = 0.5
    btn.MouseEnter:Connect(function() Tw(btn,{BackgroundColor3=Color3.fromRGB(45,40,55)}) end)
    btn.MouseLeave:Connect(function() Tw(btn,{BackgroundColor3=Color3.fromRGB(30,30,35)}) end)
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)
    return btn
end

-- ══ NOTIFICATIONS ═══════════════════════════════════════════
local notifStack = {}
local function Notif(txt, dur)
    dur = dur or 3
    local n = Instance.new("Frame")
    n.Size = UDim2.new(0,0,0,36); n.AnchorPoint = Vector2.new(1,1)
    n.Position = UDim2.new(1,-15,0.95,0)
    n.BackgroundColor3 = Color3.fromRGB(20,20,25)
    n.BackgroundTransparency = 0.05; n.ZIndex = 800; n.Parent = SG
    Instance.new("UICorner",n).CornerRadius = UDim.new(0,8)
    local ns = Instance.new("UIStroke",n)
    ns.Color = A(); ns.Thickness = 2; ns.Transparency = 0.2
    local nl = Instance.new("TextLabel",n)
    nl.Size = UDim2.new(1,-20,1,0); nl.Position = UDim2.new(0,10,0,0)
    nl.BackgroundTransparency = 1; nl.TextColor3 = Color3.fromRGB(245,245,250)
    nl.Font = Enum.Font.GothamBold; nl.TextSize = 12
    nl.TextXAlignment = Enum.TextXAlignment.Left; nl.Text = txt; nl.ZIndex = 801
    
    table.insert(notifStack,n)
    local w = math.clamp(#txt*7.5+40, 180, 350)
    Tw(n,{Size=UDim2.new(0,w,0,36)},0.4,Enum.EasingStyle.Back)
    
    for i, nn in ipairs(notifStack) do
        Tw(nn,{Position=UDim2.new(1,-15,0.95-(i-1)*0.065,0)},0.25)
    end
    
    task.delay(dur,function()
        Tw(n,{BackgroundTransparency=1,Size=UDim2.new(0,0,0,36)},0.3)
        Tw(nl,{TextTransparency=1},0.2)
        task.delay(0.35,function()
            local idx = table.find(notifStack,n)
            if idx then table.remove(notifStack,idx) end
            pcall(function() n:Destroy() end)
        end)
    end)
end

-- ══ FOV CIRCLE ══════════════════════════════════════════════
local FOV_Circle
local useDrawing = false
pcall(function()
    if Drawing then
        FOV_Circle = Drawing.new("Circle")
        FOV_Circle.Visible = CFG.showFov
        FOV_Circle.Thickness = 1.5
        FOV_Circle.Color = A()
        FOV_Circle.Filled = false
        FOV_Circle.NumSides = 64
        useDrawing = true
    end
end)

if not useDrawing then
    FOV_Circle = Instance.new("Frame")
    FOV_Circle.BackgroundTransparency = 1
    FOV_Circle.Visible = CFG.showFov
    FOV_Circle.ZIndex = 999
    FOV_Circle.Parent = SG
    Instance.new("UICorner",FOV_Circle).CornerRadius = UDim.new(1,0)
    local fStr = Instance.new("UIStroke",FOV_Circle)
    fStr.Color = A(); fStr.Thickness = 1.5
end

local function UpdateFOVCircle()
    pcall(function()
        local r = CFG.fovRadius
        if useDrawing then
            FOV_Circle.Radius = r
            FOV_Circle.Color = A()
            FOV_Circle.Visible = CFG.showFov
            FOV_Circle.Position = UIS:GetMouseLocation()
        else
            FOV_Circle.Size = UDim2.new(0, r*2, 0, r*2)
            FOV_Circle.Visible = CFG.showFov
            local fStr = FOV_Circle:FindFirstChildOfClass("UIStroke")
            if fStr then fStr.Color = A() end
            local mLoc = UIS:GetMouseLocation()
            FOV_Circle.Position = UDim2.new(0, mLoc.X-r, 0, mLoc.Y-r)
        end
    end)
end

-- ══ TABS ════════════════════════════════════════════════════
local _, pgAim    = MkTab("AIMBOT",   "0")
local _, pgCombat = MkTab("COMBAT",   "+")
local _, pgMove   = MkTab("MOVEMENT", "~")
local _, pgVis    = MkTab("VISUALS",  "*")
local _, pgSet    = MkTab("SETTINGS", "=")

local function SelTab(target)
    for _, td in ipairs(tabsList) do
        local on = td.p == target
        td.p.Visible = on
        td.b:SetAttribute("Active", on)
        Tw(td.b,{
            BackgroundTransparency = on and 0 or 1,
            BackgroundColor3 = on and Color3.fromRGB(25,22,35) or Color3.fromRGB(16,16,20),
            TextColor3 = on and Color3.fromRGB(240,240,250) or Color3.fromRGB(120,120,135),
        })
        Tw(td.ind,{BackgroundTransparency = on and 0 or 1})
    end
end
for _, td in ipairs(tabsList) do
    td.b.MouseButton1Click:Connect(function() SelTab(td.p) end)
end
SelTab(pgAim)

-- ══ FRIEND LIST ═════════════════════════════════════════════
local fFrm = Instance.new("Frame")
fFrm.Size = UDim2.new(0,0,0,0); fFrm.Position = UDim2.new(1,-10,1,-10)
fFrm.AnchorPoint = Vector2.new(1,1)
fFrm.BackgroundColor3 = Color3.fromRGB(18,18,22)
fFrm.BackgroundTransparency = 0.05
fFrm.BorderSizePixel = 0; fFrm.Visible = false; fFrm.Parent = mFrm
Instance.new("UICorner",fFrm).CornerRadius = UDim.new(0,10)
local fStr = Instance.new("UIStroke",fFrm)
fStr.Color = A(); fStr.Thickness = 1; fStr.Transparency = 0.6

local fTit = Instance.new("TextLabel")
fTit.Size = UDim2.new(1,0,0,40); fTit.BackgroundTransparency = 1
fTit.TextColor3 = Color3.fromRGB(220,220,230); fTit.Text = "Players"
fTit.Font = Enum.Font.GothamBold; fTit.TextSize = 12; fTit.Parent = fFrm
local fLine = Instance.new("Frame",fFrm)
fLine.Size = UDim2.new(1,-20,0,1); fLine.Position = UDim2.new(0,10,0,36)
fLine.BackgroundColor3 = Color3.fromRGB(40,40,45)

local fScr = Instance.new("ScrollingFrame")
fScr.Size = UDim2.new(1,-10,1,-45); fScr.Position = UDim2.new(0,5,0,40)
fScr.BackgroundTransparency = 1; fScr.ScrollBarThickness = 3
fScr.ScrollBarImageColor3 = D(); fScr.Parent = fFrm
local fLL = Instance.new("UIListLayout",fScr)
fLL.Padding = UDim.new(0,6)

local function RefFriends()
    pcall(function()
        for _, v in ipairs(fScr:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then
                local fb = Instance.new("TextButton")
                fb.Size = UDim2.new(1,0,0,32); fb.Font = Enum.Font.GothamMedium
                fb.TextSize = 12; fb.AutoButtonColor = false
                local isFr = customFriends[pl.Name]
                fb.BackgroundColor3 = isFr and Color3.fromRGB(30,60,40) or Color3.fromRGB(25,25,30)
                fb.TextColor3 = isFr and Color3.fromRGB(100,255,150) or Color3.fromRGB(150,150,160)
                fb.Text = pl.Name
                fb.Parent = fScr
                fb.MouseButton1Click:Connect(function()
                    customFriends[pl.Name] = not customFriends[pl.Name]
                    RefFriends()
                end)
            end
        end
        fScr.CanvasSize = UDim2.new(0,0,0,fLL.AbsoluteContentSize.Y)
    end)
end
AddConn(Players.PlayerAdded:Connect(RefFriends))
AddConn(Players.PlayerRemoving:Connect(function(pl)
    customFriends[pl.Name] = nil; RefFriends()
end))
RefFriends()

-- ══ UI CONTENT ══════════════════════════════════════════════
-- AIMBOT
MkToggle("Aimbot",pgAim,"aimbot",function(v) if v then CFG.lockAim=false end end)
MkToggle("Silent Aim",pgAim,"silentAim",nil)
MkToggle("Lock Aim",pgAim,"lockAim",function(v) if v then CFG.aimbot=false end end)
MkToggle("Team Check",pgAim,"teamCheck",nil)
MkToggle("Show FOV",pgAim,"showFov",function() UpdateFOVCircle() end)
MkToggle("Wall Check",pgAim,"wallCheck",nil)
MkToggle("Hold to Aim",pgAim,"aimHold",nil)
MkSlider("FOV Radius",pgAim,"fovRadius",30,800,"%d",function() UpdateFOVCircle() end)
MkSlider("Aim Smoothness",pgAim,"aimSmooth",0,0.9,"%.2f",nil)
MkDrop("Aim Part",pgAim,{"Head","UpperTorso","HumanoidRootPart"},"aimPart",nil)

-- COMBAT
MkToggle("Auto Block",pgCombat,"autoBlock",nil)
MkToggle("Hitbox",pgCombat,"hitbox",nil)
MkSlider("Hitbox Size",pgCombat,"hitboxSize",5,60,"%d",nil)
MkToggle("M1 Magnet",pgCombat,"m1Magnet",function(v) if v then CFG.killAura=false end end)
MkToggle("Kill Aura",pgCombat,"killAura",function(v) if v then CFG.m1Magnet=false end end)
MkToggle("No Recoil",pgCombat,"noRecoil",nil)
MkToggle("Anti-Stun",pgCombat,"antiStun",nil)
MkToggle("Reach",pgCombat,"reach",nil)
MkSlider("Reach Distance",pgCombat,"reachDist",5,50,"%d",nil)
MkToggle("Anti-Kick",pgCombat,"antiKick",nil)

-- MOVEMENT
MkToggle("Speedhack",pgMove,"speedhack",function(v)
    if not v then
        pcall(function()
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed=16 end
        end)
    end
end)
MkSlider("Walk Speed",pgMove,"walkSpeed",16,500,"%d",nil)
MkToggle("Fly",pgMove,"fly",nil)
MkSlider("Fly Speed",pgMove,"flySpeed",10,300,"%d",nil)
MkToggle("Noclip",pgMove,"noclip",nil)
MkToggle("Infinite Jump",pgMove,"infiniteJump",nil)
MkToggle("Anti-Void",pgMove,"antiVoid",nil)
MkToggle("Click Teleport",pgMove,"clickTp",nil)

-- VISUALS
MkToggle("ESP",pgVis,"esp",function(v)
    if not v then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Character then
                local hl = pl.Character:FindFirstChild("ZHubESP")
                if hl then hl:Destroy() end
            end
        end
    end
end)
MkToggle("ESP Names",pgVis,"espNames",nil)
MkToggle("ESP Distance",pgVis,"espDistance",nil)
MkToggle("ESP Health",pgVis,"espHealth",nil)
MkToggle("Chams",pgVis,"chams",function(v)
    if not v then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Character then
                local hl = pl.Character:FindFirstChild("ZHubChams")
                if hl then hl:Destroy() end
            end
        end
    end
end)
MkToggle("FOV Changer",pgVis,"fovChanger",function(v)
    if not v then pcall(function() GetCamera().FieldOfView=70 end) end
end)
MkSlider("FOV Value",pgVis,"fovValue",50,160,"%d",nil)
MkToggle("Third Person",pgVis,"thirdPerson",function(v)
    pcall(function()
        if v then
            -- Save originals
            origMinZoom = origMinZoom or LP.CameraMinZoomDistance
            origMaxZoom = origMaxZoom or LP.CameraMaxZoomDistance
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then origCamOffset = origCamOffset or hum.CameraOffset end
        else
            -- Restore native camera
            if origMinZoom then LP.CameraMinZoomDistance = origMinZoom end
            if origMaxZoom then LP.CameraMaxZoomDistance = origMaxZoom end
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.CameraOffset = origCamOffset or Vector3.new(0,0,0)
            end
            local cam = GetCamera()
            if cam then cam.CameraType = Enum.CameraType.Custom end
            -- Restore viewmodel
            pcall(function()
                for _, v2 in ipairs(cam:GetDescendants()) do
                    if v2:IsA("BasePart") or v2:IsA("MeshPart") then
                        v2.LocalTransparencyModifier = 0
                    end
                end
            end)
        end
    end)
end)
MkToggle("Hand Glow",pgVis,"handGlow",function(v)
    if not v then
        pcall(function()
            local char = LP.Character
            if char then
                local hl = char:FindFirstChild("ZHuB_HandGlow")
                if hl then hl:Destroy() end
            end
        end)
    end
end)
MkSlider("3rd Person Dist",pgVis,"thirdDist",3,50,"%d",nil)
MkToggle("Rainbow Sky",pgVis,"rainbowSky",function(v)
    if not v then
        pcall(function()
            Lighting.OutdoorAmbient = origOutdoor
            Lighting.Ambient        = origAmbient
            Lighting.ColorShift_Top = origColorShift
        end)
    end
end)

-- SETTINGS
MkDrop("Theme",pgSet,{"Purple","Red","Blue","Green","White"},"theme",function(v)
    mStr.Color = A(); fStr.Color = A(); tBStr.Color = A(); tBtn.TextColor3 = A(); tDot.BackgroundColor3 = A()
    UpdateFOVCircle()
    local wmS = SG:FindFirstChild("ZHuB_WM")
    if wmS then wmS:FindFirstChildOfClass("UIStroke").Color = A() end
end)
MkToggle("Watermark",pgSet,"watermark",function(v)
    local wmS = SG:FindFirstChild("ZHuB_WM")
    if wmS then wmS.Visible = v end
end)
MkBtn("Save Config",pgSet,function() SaveCFG(); Notif("Configuration Saved.", 2) end)
MkBtn("Load Config",pgSet,function() LoadCFG(); Notif("Configuration Loaded.", 2) end)

-- ══ WATERMARK ═══════════════════════════════════════════════
local wmFr = Instance.new("Frame")
wmFr.Name = "ZHuB_WM"
wmFr.Size = UDim2.new(0,250,0,32); wmFr.Position = UDim2.new(0,10,0,10)
wmFr.BackgroundColor3 = Color3.fromRGB(15,15,18)
wmFr.BackgroundTransparency = 0.2; wmFr.ZIndex = 850
wmFr.Visible = CFG.watermark; wmFr.Parent = SG
Instance.new("UICorner",wmFr).CornerRadius = UDim.new(0,8)
local wmStr = Instance.new("UIStroke",wmFr)
wmStr.Color = A(); wmStr.Thickness = 2; wmStr.Transparency = 0.3
local wmLbl = Instance.new("TextLabel")
wmLbl.Size = UDim2.new(1,-10,1,0); wmLbl.Position = UDim2.new(0,10,0,0)
wmLbl.BackgroundTransparency = 1; wmLbl.TextColor3 = Color3.fromRGB(240,240,245)
wmLbl.Font = Enum.Font.GothamBold; wmLbl.TextSize = 12
wmLbl.TextXAlignment = Enum.TextXAlignment.Left
wmLbl.ZIndex = 851; wmLbl.Text = "ZHuB Professional"; wmLbl.Parent = wmFr

local lastFPS = 0; local fpsTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not isActive then return end
    fpsTimer = fpsTimer + dt
    if fpsTimer >= 0.5 then
        fpsTimer = 0
        lastFPS = math.round(1/dt)
        if CFG.watermark then
            local ping = 0
            pcall(function() ping = math.round(LP:GetNetworkPing()*1000) end)
            wmLbl.Text = string.format("ZHuB Professional | %d FPS | %dms", lastFPS, ping)
        end
    end
end)

-- ══ POWERFUL HOOKS (No Recoil, Silent Aim, AC Bypass) ═══════
local oldIndex, oldNewIndex, oldNamecall

local function FindSilentTarget()
    local best, bestD = nil, CFG.fovRadius
    local mLoc = UIS:GetMouseLocation()
    local cam = GetCamera()
    if not cam then return nil end
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and not IsFriend(pl) and pl.Character then
            local ph = pl.Character:FindFirstChildOfClass("Humanoid")
            if ph and ph.Health > 0 then
                local pt = GetPart(pl.Character, CFG.aimPart)
                if pt then
                    local ps, iv = cam:WorldToViewportPoint(pt.Position)
                    if iv then
                        local d = (Vector2.new(ps.X,ps.Y)-mLoc).Magnitude
                        local wok = not CFG.wallCheck or IsVis(pt, pl.Character)
                        if d < bestD and wok then bestD = d; best = pt end
                    end
                end
            end
        end
    end
    return best
end

if hookmetamethod then
    pcall(function()
        -- 1. __index: FOV spoof + Mouse.Hit/Target/UnitRay redirect for Silent Aim
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            if not checkcaller() then
                -- FOV spoof: game reads cam.FieldOfView and gets default 70
                if self == workspace.CurrentCamera and key == "FieldOfView" and CFG.fovChanger then
                    return 70
                end
                -- Silent Aim: redirect Mouse.Hit, Mouse.Target, Mouse.UnitRay
                if CFG.silentAim then
                    local cn = ""
                    pcall(function() cn = self.ClassName end)
                    if cn == "PlayerMouse" or cn == "Mouse" then
                        local best = FindSilentTarget()
                        if best then
                            if key == "Hit" then
                                return CFrame.new(best.Position)
                            elseif key == "Target" then
                                return best
                            elseif key == "UnitRay" then
                                local cam = GetCamera()
                                if cam then
                                    local ori = cam.CFrame.Position
                                    return Ray.new(ori, (best.Position - ori).Unit)
                                end
                            elseif key == "X" or key == "Y" then
                                local cam = GetCamera()
                                if cam then
                                    local ps = cam:WorldToViewportPoint(best.Position)
                                    return key == "X" and ps.X or ps.Y
                                end
                            end
                        end
                    end
                end
            end
            return oldIndex(self, key)
        end)
        
        -- 2. __newindex: FOV block + recoil CFrame block
        oldNewIndex = hookmetamethod(game, "__newindex", function(self, key, value)
            if not checkcaller() then
                if self == workspace.CurrentCamera and key == "FieldOfView" and CFG.fovChanger then return end
                -- Block ALL game-side camera CFrame changes while firing with No Recoil
                if self == workspace.CurrentCamera and key == "CFrame" and CFG.noRecoil then
                    local m1 = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                    if m1 then return end
                end
            end
            return oldNewIndex(self, key, value)
        end)

        -- 3. __namecall: Anti-Kick + Silent Aim + No Recoil bullet redirect
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            -- Anti-Kick / Anti-Ban / Anti-Crash logic
            if CFG.antiKick then
                -- Block local Player:Kick()
                if method == "Kick" and typeof(self) == "Instance" and self:IsA("Player") then
                    pcall(function() Notif("Anti-Kick: Blocked local kick attempt :)", 4) end)
                    return -- Block
                end
                
                -- Block RemoteEvent/RemoteFunction server kicks
                if typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                    local name = string.lower(self.Name)
                    if name:match("kick") or name:match("ban") or name:match("crash") or name:match("punish") then
                        if method == "FireServer" or method == "InvokeServer" then
                            pcall(function() Notif("Anti-Kick: Blocked remote kick (" .. self.Name .. ")", 4) end)
                            return -- Block
                        end
                    end
                end
            end

            if not checkcaller() then
                local cam = GetCamera()
                
                -- No Recoil: force bullet raycast to camera center (removes spread)
                if CFG.noRecoil and not CFG.silentAim then
                    local m1 = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                    if m1 and cam then
                        -- Redirect workspace Raycasts to camera center
                        if self == workspace and (method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") then
                            local origin, dir
                            if method == "Raycast" then
                                origin, dir = args[1], args[2]
                            else
                                local ray = args[1]
                                if ray and typeof(ray) == "Ray" then origin, dir = ray.Origin, ray.Direction end
                            end
                            if origin and dir then
                                local centerDir = cam.CFrame.LookVector * dir.Magnitude
                                if method == "Raycast" then
                                    args[2] = centerDir
                                else
                                    args[1] = Ray.new(origin, centerDir)
                                end
                                return oldNamecall(self, unpack(args))
                            end
                        end
                        -- Redirect ViewportPointToRay / ScreenPointToRay to screen center
                        if cam and self == cam and (method == "ViewportPointToRay" or method == "ScreenPointToRay") then
                            local vs = cam.ViewportSize
                            args[1] = vs.X / 2
                            args[2] = vs.Y / 2
                            return oldNamecall(self, unpack(args))
                        end
                    end
                end
                
                -- Silent Aim (overrides No Recoil redirect when both are on)
                if CFG.silentAim then
                    -- Raycast-based interception
                    if self == workspace and (method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") then
                        local origin, dir
                        if method == "Raycast" then
                            origin, dir = args[1], args[2]
                        else
                            local ray = args[1]
                            if ray and typeof(ray) == "Ray" then origin, dir = ray.Origin, ray.Direction end
                        end
                        if origin and dir then
                            local best = FindSilentTarget()
                            if best then
                                local newDir = (best.Position - origin).Unit * dir.Magnitude
                                if method == "Raycast" then
                                    args[2] = newDir
                                else
                                    args[1] = Ray.new(origin, newDir)
                                end
                                return oldNamecall(self, unpack(args))
                            elseif CFG.noRecoil then
                                -- No target found but noRecoil on: force to center
                                local m1 = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                                if m1 and cam then
                                    local centerDir = cam.CFrame.LookVector * dir.Magnitude
                                    if method == "Raycast" then args[2] = centerDir
                                    else args[1] = Ray.new(origin, centerDir) end
                                    return oldNamecall(self, unpack(args))
                                end
                            end
                        end
                    end
                    
                    -- ViewportPointToRay / ScreenPointToRay → redirect to target screen pos
                    if cam and self == cam and (method == "ViewportPointToRay" or method == "ScreenPointToRay") then
                        local best = FindSilentTarget()
                        if best then
                            local ps = cam:WorldToViewportPoint(best.Position)
                            args[1] = ps.X
                            args[2] = ps.Y
                            return oldNamecall(self, unpack(args))
                        end
                    end

                    -- RemoteEvent / RemoteFunction arg scanning
                    if typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                        if method == "FireServer" or method == "InvokeServer" then
                            local best = FindSilentTarget()
                            if best then
                                local modified = false
                                for i, arg in ipairs(args) do
                                    if typeof(arg) == "CFrame" then
                                        args[i] = CFrame.new(best.Position)
                                        modified = true
                                    elseif typeof(arg) == "Vector3" then
                                        local cam2 = GetCamera()
                                        if cam2 then
                                            local camPos = cam2.CFrame.Position
                                            local dist = (arg - camPos).Magnitude
                                            if dist > 5 then
                                                args[i] = best.Position
                                                modified = true
                                            end
                                        end
                                    elseif typeof(arg) == "Ray" then
                                        local ori = arg.Origin
                                        args[i] = Ray.new(ori, (best.Position - ori).Unit * arg.Direction.Magnitude)
                                        modified = true
                                    end
                                end
                                if modified then
                                    return oldNamecall(self, unpack(args))
                                end
                            end
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
end

-- 3. Universal No Recoil (Neutralize math.random & math.noise)
local oldRandom, oldNoise
if hookfunction then
    pcall(function()
        oldRandom = hookfunction(math.random, function(...)
            if CFG.noRecoil and not checkcaller() then
                local args = {...}
                if #args == 0 then return 0.5 end
                if #args == 1 then return math.floor(args[1]/2) end
                if #args == 2 then return math.floor((args[1]+args[2])/2) end
            end
            return oldRandom(...)
        end)
        oldNoise = hookfunction(math.noise, function(...)
            if CFG.noRecoil and not checkcaller() then return 0 end
            return oldNoise(...)
        end)
    end)
end

-- ══ ESP & VISUALS LOOP ══════════════════════════════════════
task.spawn(function()
    while isActive do
        task.wait(0.5)
        pcall(function()
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP and pl.Character then
                    local char = pl.Character
                    local hum  = char:FindFirstChildOfClass("Humanoid")
                    local hrp  = char:FindFirstChild("HumanoidRootPart")
                    local fr   = IsFriend(pl)

                    if CFG.esp then
                        local hl = char:FindFirstChild("ZHubESP")
                        if not hl then
                            hl = Instance.new("Highlight"); hl.Name="ZHubESP"
                            hl.FillTransparency=0.6; hl.OutlineTransparency=0.1
                            hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent = char
                        end
                        hl.FillColor    = fr and Color3.fromRGB(50,255,100) or Color3.fromRGB(255,50,50)
                        hl.OutlineColor = fr and Color3.fromRGB(150,255,180) or Color3.fromRGB(255,150,150)
                        
                        if hrp and (CFG.espNames or CFG.espDistance or CFG.espHealth) then
                            if not espLabels[pl] then
                                local bg = Instance.new("BillboardGui")
                                bg.Name = "ZHuB_EL"; bg.Size = UDim2.new(0,200,0,50)
                                bg.StudsOffset = Vector3.new(0,3.5,0); bg.AlwaysOnTop = true
                                local tl2 = Instance.new("TextLabel",bg)
                                tl2.Size = UDim2.new(1,0,1,0); tl2.BackgroundTransparency=1
                                tl2.Font = Enum.Font.GothamBold; tl2.TextSize = 12
                                tl2.TextStrokeTransparency=0.3; tl2.TextStrokeColor3=Color3.new(0,0,0)
                                tl2.Name="L"; espLabels[pl] = {g=bg,t=tl2}
                            end
                            local eD = espLabels[pl]
                            eD.g.Adornee = hrp
                            if eD.g.Parent ~= char then eD.g.Parent = char end
                            local parts = {}
                            if CFG.espNames then table.insert(parts, pl.Name) end
                            if CFG.espHealth and hum then
                                table.insert(parts, string.format("HP: %.0f/%.0f", hum.Health, hum.MaxHealth))
                            end
                            if CFG.espDistance then
                                local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                                if myHrp then
                                    table.insert(parts, string.format("[%d m]", (hrp.Position-myHrp.Position).Magnitude))
                                end
                            end
                            eD.t.Text = table.concat(parts,"\n")
                            eD.t.TextColor3 = fr and Color3.fromRGB(100,255,150) or Color3.fromRGB(255,100,100)
                        end
                    else
                        local hl = char:FindFirstChild("ZHubESP")
                        if hl then hl:Destroy() end
                        if espLabels[pl] then pcall(function() espLabels[pl].g.Parent=nil end) end
                    end

                    if CFG.chams then
                        local hl = char:FindFirstChild("ZHubChams")
                        if not hl then
                            hl = Instance.new("Highlight"); hl.Name="ZHubChams"
                            hl.FillColor=fr and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,0,0)
                            hl.FillTransparency=0.3; hl.OutlineTransparency=1
                            hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent=char
                        end
                    else
                        local hl = char:FindFirstChild("ZHubChams")
                        if hl then hl:Destroy() end
                    end

                    if hrp then
                        if CFG.hitbox then
                            hrp.Size = Vector3.new(CFG.hitboxSize,CFG.hitboxSize,CFG.hitboxSize)
                            hrp.Transparency=0.8; hrp.CanCollide=false; hrp.Massless=true
                        elseif hrp.Size.X > 5 then
                            hrp.Size=Vector3.new(2,2,1)
                            hrp.Transparency=1; hrp.CanCollide=true; hrp.Massless=false
                        end
                    end
                end
            end
        end)
    end
end)

-- ══ COMBAT ACTIONS LOOP ═════════════════════════════════════
task.spawn(function()
    while isActive do
        task.wait(0.03)
        pcall(function()
            local mLoc = UIS:GetMouseLocation()
            local shouldFire = (CFG.lockAim and isLockAiming) or (CFG.killAura and isKillAuraActive)
            if shouldFire then
                if not isRightFiring then
                    isRightFiring = true
                    pcall(function() VIM:SendMouseButtonEvent(mLoc.X,mLoc.Y,0,true,game,1) end)
                end
            else
                if isRightFiring then
                    isRightFiring = false
                    pcall(function() VIM:SendMouseButtonEvent(mLoc.X,mLoc.Y,0,false,game,1) end)
                end
            end
            if CFG.autoBlock and isAutoBlocking then
                if not isBlocking then
                    pcall(function() VIM:SendKeyEvent(true,Enum.KeyCode.F,false,game) end)
                    isBlocking = true
                end
            else
                if isBlocking then
                    pcall(function() VIM:SendKeyEvent(false,Enum.KeyCode.F,false,game) end)
                    isBlocking = false
                end
            end
            
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            -- Lock Aim: spin + snap to nearest enemy for guaranteed hits
            if CFG.lockAim and hrp and hum then
                hum.AutoRotate = false
                -- Add spin
                local sf = hrp:FindFirstChild("ZHuB_Spin")
                if not sf then
                    sf = Instance.new("BodyAngularVelocity"); sf.Name="ZHuB_Spin"
                    sf.MaxTorque=Vector3.new(0,math.huge,0)
                    sf.AngularVelocity=Vector3.new(0,40,0); sf.Parent=hrp
                end
                -- Find nearest enemy and face them directly with HRP
                local cam = GetCamera()
                if cam then
                    local best, bestD = nil, 999
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl~=LP and not IsFriend(pl) then
                            local pc = pl.Character; local ph = pc and pc:FindFirstChildOfClass("Humanoid")
                            if pc and ph and ph.Health>0 then
                                local pt = GetPart(pc,CFG.aimPart)
                                if pt then
                                    local d = (pt.Position - hrp.Position).Magnitude
                                    if d < bestD then bestD=d; best=pt end
                                end
                            end
                        end
                    end
                    if best then
                        -- Snap HRP to face enemy (Y-axis only)
                        local targetFlat = Vector3.new(best.Position.X, hrp.Position.Y, best.Position.Z)
                        hrp.CFrame = CFrame.lookAt(hrp.Position, targetFlat)
                        isLockAiming = true
                    else
                        isLockAiming = false
                    end
                end
            else
                if hrp then
                    local sf = hrp:FindFirstChild("ZHuB_Spin")
                    if sf then sf:Destroy() end
                    if hum then hum.AutoRotate=true end
                end
                isLockAiming = false
            end
        end)
    end
end)

-- ══ CAMERA OVERRIDE LOOP ════════════════════════════════════
RunService:BindToRenderStep("ZHuB_CameraBypass", Enum.RenderPriority.Camera.Value + 99, function()
    if not isActive then return end
    
    pcall(function()
        local cam = GetCamera()
        if not cam then return end

        if CFG.fovChanger then
            cam.FieldOfView = CFG.fovValue
        end

        local char = LP.Character; if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local mLoc = UIS:GetMouseLocation()

        if CFG.showFov then UpdateFOVCircle() end

        if CFG.rainbowSky then
            local hue = (tick()%6)/6
            local c = Color3.fromHSV(hue,0.7,1)
            Lighting.OutdoorAmbient=c; Lighting.Ambient=c; Lighting.ColorShift_Top=c
        end

        if hum then
            if CFG.speedhack then hum.WalkSpeed = CFG.walkSpeed end
            if CFG.antiStun then
                if not CFG.speedhack and hum.WalkSpeed<16 then hum.WalkSpeed=16 end
                if hum.JumpPower<50 then hum.JumpPower=50 end
                if not CFG.fly then hum.PlatformStand=false end
                hum.Sit=false
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
                local hs = hum:GetState()
                if hs==Enum.HumanoidStateType.FallingDown or hs==Enum.HumanoidStateType.Ragdoll
                or hs==Enum.HumanoidStateType.Physics then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
                pcall(function()
                    if char:GetAttribute("Stunned") then char:SetAttribute("Stunned",false) end
                    if char:GetAttribute("Stun")    then char:SetAttribute("Stun",false)    end
                end)
            end
        end

        if CFG.antiVoid and hrp and hrp.Position.Y < -200 then
            hrp.CFrame = CFrame.new(0,100,0)
        end

        if CFG.noclip then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end

        if CFG.thirdPerson and hrp and hum then
            pcall(function()
                -- Force Roblox native zoom every single frame
                LP.CameraMinZoomDistance = CFG.thirdDist
                LP.CameraMaxZoomDistance = CFG.thirdDist + 0.5
                
                -- Shoulder offset
                hum.CameraOffset = Vector3.new(2, 1, 0)
                
                -- Ensure custom camera mode
                if cam.CameraType ~= Enum.CameraType.Custom then
                    cam.CameraType = Enum.CameraType.Custom
                    cam.CameraSubject = hum
                end
                
                -- Make character body visible
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") or v:IsA("Decal") then
                        v.LocalTransparencyModifier = 0
                    end
                end
                
                -- Hide FPS viewmodel (arms/gun attached to camera)
                for _, v in ipairs(cam:GetDescendants()) do
                    if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Decal") or v:IsA("Texture") then
                        v.LocalTransparencyModifier = 1
                    end
                end
            end)
        end

        -- No Recoil: frame-based camera compensation
        if CFG.noRecoil then
            local m1 = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            if m1 then
                if not isFiring then
                    -- First frame of firing: save current camera rotation
                    isFiring = true
                    lastCamCF = cam.CFrame
                else
                    -- Subsequent frames: snap camera rotation back, keep position
                    if lastCamCF then
                        local pos = cam.CFrame.Position
                        local savedLook = lastCamCF.LookVector
                        local currentLook = cam.CFrame.LookVector
                        
                        -- Only compensate vertical (Y) recoil, allow horizontal mouse movement
                        local yDiff = math.asin(currentLook.Y) - math.asin(savedLook.Y)
                        if math.abs(yDiff) > 0.001 then
                            -- Rotate the camera back down by the recoil amount
                            local compensation = CFrame.Angles(-yDiff * 0.85, 0, 0)
                            cam.CFrame = CFrame.new(pos) * (cam.CFrame - pos) * compensation
                        end
                        -- Update saved CFrame for next frame (with compensated rotation)
                        lastCamCF = cam.CFrame
                    end
                end
            else
                isFiring = false
                lastCamCF = nil
            end
        end

        -- Hand Glow (character glow with pulsing effect)
        if CFG.handGlow then
            pcall(function()
                if char then
                    local hl = char:FindFirstChild("ZHuB_HandGlow")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "ZHuB_HandGlow"
                        hl.FillColor = A()
                        hl.OutlineColor = A()
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = char
                    end
                    -- Breathing pulse
                    local pulse = 0.4 + math.sin(tick() * 2.5) * 0.2
                    hl.FillTransparency = pulse
                    hl.FillColor = A()
                    hl.OutlineColor = A()
                end
            end)
        else
            pcall(function()
                if char then
                    local hl = char:FindFirstChild("ZHuB_HandGlow")
                    if hl then hl:Destroy() end
                end
            end)
        end

        if CFG.aimbot then
            local aimOk = true
            if CFG.aimHold then aimOk = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
            
            if aimOk then
                if currentTarget then
                    local tHum = currentTarget.Parent and currentTarget.Parent:FindFirstChildOfClass("Humanoid")
                    if not tHum or tHum.Health<=0 then currentTarget=nil
                    else
                        local ps, iv = cam:WorldToViewportPoint(currentTarget.Position)
                        if not iv then currentTarget=nil
                        elseif (Vector2.new(ps.X,ps.Y)-mLoc).Magnitude > CFG.fovRadius then currentTarget=nil
                        elseif CFG.wallCheck and not IsVis(currentTarget,currentTarget.Parent) then currentTarget=nil
                        end
                    end
                end
                if not currentTarget then
                    local best = CFG.fovRadius
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl~=LP and not IsFriend(pl) then
                            local pc = pl.Character
                            local ph = pc and pc:FindFirstChildOfClass("Humanoid")
                            if pc and ph and ph.Health>0 then
                                local pt = GetPart(pc,CFG.aimPart)
                                if pt then
                                    local ps, iv = cam:WorldToViewportPoint(pt.Position)
                                    if iv then
                                        local d2 = (Vector2.new(ps.X,ps.Y)-mLoc).Magnitude
                                        local wok = not CFG.wallCheck or IsVis(pt,pc)
                                        if d2<best and wok then best=d2; currentTarget=pt end
                                    end
                                end
                            end
                        end
                    end
                end
                if currentTarget then
                    local d = (currentTarget.Position-cam.CFrame.Position).Magnitude
                    if d>1 and not CFG.thirdPerson then
                        local goal = CFrame.lookAt(cam.CFrame.Position,currentTarget.Position)
                        local sm = math.clamp(CFG.aimSmooth, 0, 0.95)
                        if sm < 0.05 then cam.CFrame = goal
                        else cam.CFrame = cam.CFrame:Lerp(goal, 1-sm) end
                    end
                end
            else
                currentTarget=nil
            end
        end

        if CFG.lockAim and hrp then
            -- Camera snap to nearest enemy (instant, no smoothing)
            local best, bestD = nil, 999
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl~=LP and not IsFriend(pl) then
                    local pc = pl.Character; local ph = pc and pc:FindFirstChildOfClass("Humanoid")
                    if pc and ph and ph.Health>0 then
                        local pt = GetPart(pc,CFG.aimPart)
                        if pt then
                            local d = (pt.Position - hrp.Position).Magnitude
                            if d<bestD then bestD=d; best=pt end
                        end
                    end
                end
            end
            if best then
                -- Direct camera snap to target
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, best.Position)
                isLockAiming=true
            else isLockAiming=false end
        else isLockAiming=false end

        if CFG.killAura and hrp then
            local best, bestD = nil, 120
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl~=LP and not IsFriend(pl) then
                    local pc = pl.Character; local ph = pc and pc:FindFirstChildOfClass("Humanoid")
                    if pc and ph and ph.Health>0 then
                        local ph2 = pc:FindFirstChild("HumanoidRootPart")
                        if ph2 then
                            local d=(ph2.Position-hrp.Position).Magnitude
                            if d<bestD then bestD=d; best=ph2 end
                        end
                    end
                end
            end
            if best then
                hrp.CFrame=best.CFrame*CFrame.new(0,0,3.5)
                if not CFG.thirdPerson then
                    cam.CFrame=CFrame.lookAt(cam.CFrame.Position,best.Position)
                end
                isKillAuraActive=true
            else isKillAuraActive=false end
        else isKillAuraActive=false end

        if CFG.autoBlock and hrp then
            local should = false
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl~=LP and not IsFriend(pl) then
                    local ec = pl.Character
                    local eh = ec and ec:FindFirstChild("HumanoidRootPart")
                    local ehu= ec and ec:FindFirstChildOfClass("Humanoid")
                    if eh and ehu and ehu.Health>0 then
                        if (eh.Position-hrp.Position).Magnitude<25 then
                            local anim = ehu:FindFirstChildOfClass("Animator") or ehu
                            for _, tr in ipairs(anim:GetPlayingAnimationTracks()) do
                                if tr.Priority==Enum.AnimationPriority.Action
                                or tr.Priority==Enum.AnimationPriority.Action2
                                or tr.Priority==Enum.AnimationPriority.Action3
                                or tr.Priority==Enum.AnimationPriority.Action4 then
                                    should=true
                                    hrp.CFrame=CFrame.lookAt(hrp.Position, Vector3.new(eh.Position.X,hrp.Position.Y,eh.Position.Z))
                                    break
                                end
                            end
                        end
                    end
                end
            end
            isAutoBlocking=should
        else isAutoBlocking=false end

    end)
end)

-- ══ FLY LOOP ════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not isActive then return end
    pcall(function()
        local char = LP.Character; if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local cam  = GetCamera()

        if CFG.fly and hrp and hum then
            if not isFlying then
                isFlying = true; hum.PlatformStand=true
                local asc = char:FindFirstChild("Animate")
                if asc then asc.Disabled=true end
                for _, tr in ipairs(hum:GetPlayingAnimationTracks()) do pcall(function() tr:Stop() end) end
                if not bVel or bVel.Parent~=hrp then
                    bVel=Instance.new("BodyVelocity")
                    bVel.MaxForce=Vector3.new(math.huge,math.huge,math.huge); bVel.Parent=hrp
                end
                if not bGyro or bGyro.Parent~=hrp then
                    bGyro=Instance.new("BodyGyro")
                    bGyro.MaxTorque=Vector3.new(math.huge,math.huge,math.huge)
                    bGyro.P=10000; bGyro.Parent=hrp
                end
            end
            local md = Vector3.new(0,0,0)
            local at = "idle"
            if UIS:IsKeyDown(Enum.KeyCode.W) then md=md+cam.CFrame.LookVector;  at="forward" end
            if UIS:IsKeyDown(Enum.KeyCode.S) then md=md-cam.CFrame.LookVector;  at="back"    end
            if UIS:IsKeyDown(Enum.KeyCode.A) then md=md-cam.CFrame.RightVector; if at=="idle" then at="left"  end end
            if UIS:IsKeyDown(Enum.KeyCode.D) then md=md+cam.CFrame.RightVector; if at=="idle" then at="right" end end
            if UIS:IsKeyDown(Enum.KeyCode.Space)     then md=md+Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then md=md-Vector3.new(0,1,0) end
            if md.Magnitude>0 then md=md.Unit end
            bVel.Velocity=md*CFG.flySpeed; bGyro.CFrame=cam.CFrame
        elseif not CFG.fly and isFlying then
            isFlying=false
            if hum then
                hum.PlatformStand=false
                local asc=char:FindFirstChild("Animate")
                if asc then asc.Disabled=false end
            end
            if bVel  then bVel:Destroy();  bVel=nil  end
            if bGyro then bGyro:Destroy(); bGyro=nil end
        end
    end)
end)

-- ══ INPUT EVENTS ════════════════════════════════════════════
AddConn(UIS.InputBegan:Connect(function(input, gpe)
    if not isActive then return end
    
    if input.KeyCode == CFG.menuKey then
        mFrm.Visible = not mFrm.Visible
        tBtn.Visible = not mFrm.Visible
    end
    
    if CFG.infiniteJump and input.KeyCode==Enum.KeyCode.Space and not gpe then
        local ch = LP.Character
        local hm = ch and ch:FindFirstChildOfClass("Humanoid")
        if hm then hm:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
    
    if not gpe then
        if input.KeyCode==Enum.KeyCode.R and CFG.clickTp then
            local char = LP.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local mouse= LP:GetMouse()
            if hrp and mouse.Target then
                hrp.CFrame = CFrame.new(mouse.Hit.Position+Vector3.new(0,3,0)) * (hrp.CFrame-hrp.Position)
            end
        end
        
        if input.UserInputType==Enum.UserInputType.MouseButton1 and not CFG.lockAim and not CFG.killAura then
            pcall(function()
                local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if not myHrp then return end
                local best, bestD = nil, CFG.reach and CFG.reachDist or 30
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl~=LP and not IsFriend(pl) then
                        local ph = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
                        if ph then
                            local d=(ph.Position-myHrp.Position).Magnitude
                            if d<bestD then bestD=d; best=ph end
                        end
                    end
                end
                if best then
                    local snapPos = best.Position+(myHrp.Position-best.Position).Unit*3.5
                    local snapCF  = CFrame.lookAt(snapPos,best.Position)
                    if CFG.m1Magnet then
                        Tw(myHrp,{CFrame=snapCF},0.12,Enum.EasingStyle.Sine)
                    elseif CFG.reach then
                        myHrp.CFrame = snapCF
                    end
                end
            end)
        end
    end
end))

-- ══ INIT FINISH ═════════════════════════════════════════════
isLoadScreenDone = true
SetSt("Ready!",1)
task.wait(0.5)

-- Fade out ambient sound first
if ambS then pcall(function() Tw(ambS,{Volume=0},0.8) end) end

-- Fade out all loading screen elements
Tw(LS,{BackgroundTransparency=1},1.0)
for _,c in ipairs(LS:GetDescendants())do 
    pcall(function()
        if c:IsA("TextLabel") then 
            Tw(c,{TextTransparency=1,TextStrokeTransparency=1},0.5)
        elseif c:IsA("ImageLabel") then 
            Tw(c,{ImageTransparency=1},0.5)
        elseif c:IsA("Frame") then 
            Tw(c,{BackgroundTransparency=1},0.5)
        elseif c:IsA("UIStroke") then
            Tw(c,{Transparency=1},0.5)
        elseif c:IsA("Sound") then
            Tw(c,{Volume=0},0.5)
        end
    end)
end

task.delay(1.5,function()
    -- Stop and destroy ambient sound
    pcall(function() if ambS then ambS:Stop(); ambS:Destroy(); ambS = nil end end)
    -- Disconnect the sound muter listener
    pcall(function() if dConn then dConn:Disconnect(); dConn = nil end end)
    -- Destroy loading screen
    pcall(function() LS:Destroy() end)
    -- Restore game sounds
    iInj = false
    for obj, v in pairs(oVol) do
        pcall(function() obj.Volume = v end)
    end
    oVol = {}
end)

Notif("System Initialized.", 3)
print("[ZHuB Professional] Loaded successfully.")
