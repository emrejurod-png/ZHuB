-- ============================================================
-- ZHuB Black Hole Panel (Base UI)
-- ============================================================

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
-- ══ CLEANUP ═════════════════════════════════════════════════
local oldGui = CoreGui:FindFirstChild("ZHuB_BlackHolePanel")
if oldGui then oldGui:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name = "ZHuB_BlackHolePanel"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent = CoreGui end)
if not SG.Parent then SG.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

-- ══ MAIN PANEL ══════════════════════════════════════════════
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 650, 0, 420)
Main.Position = UDim2.new(0.5, -325, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Main.BackgroundTransparency = 0.15
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = SG

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(160, 110, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3

-- Drop Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.ZIndex = 0
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.4
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = Main

-- ══ 3D VIEWPORT ═════════════════════════════════════════════
local Viewport = Instance.new("ViewportFrame")
Viewport.Size = UDim2.new(1, 0, 1, 0)
Viewport.BackgroundTransparency = 1
Viewport.ZIndex = 0
Viewport.Parent = Main

local VCam = Instance.new("Camera")
VCam.CFrame = CFrame.new(0, 20, 45) * CFrame.Angles(math.rad(-25), 0, 0)
Viewport.CurrentCamera = VCam
VCam.Parent = Viewport

local Mouse = Players.LocalPlayer:GetMouse()

local World = Instance.new("WorldModel")
World.Parent = Viewport

-- Singularity
local Singularity = Instance.new("Part")
Singularity.Shape = Enum.PartType.Ball
Singularity.Size = Vector3.new(10, 10, 10)
Singularity.Position = Vector3.new(0, 0, 0)
Singularity.Color = Color3.fromRGB(0, 0, 0)
Singularity.Material = Enum.Material.Neon
Singularity.Anchored = true
Singularity.CanCollide = false
Singularity.Parent = World

-- Photon Sphere
local PhotonSphere = Instance.new("Part")
PhotonSphere.Shape = Enum.PartType.Ball
PhotonSphere.Size = Vector3.new(11.5, 11.5, 11.5)
PhotonSphere.Position = Vector3.new(0, 0, 0)
PhotonSphere.Color = Color3.fromRGB(200, 150, 255)
PhotonSphere.Material = Enum.Material.ForceField
PhotonSphere.Anchored = true
PhotonSphere.CanCollide = false
PhotonSphere.Parent = World

-- Inner Glow
local InnerGlow = Instance.new("Part")
InnerGlow.Shape = Enum.PartType.Ball
InnerGlow.Size = Vector3.new(10.5, 10.5, 10.5)
InnerGlow.Position = Vector3.new(0, 0, 0)
InnerGlow.Color = Color3.fromRGB(255, 255, 255)
InnerGlow.Material = Enum.Material.Neon
InnerGlow.Transparency = 0.5
InnerGlow.Anchored = true
InnerGlow.CanCollide = false
InnerGlow.Parent = World

-- Relativistic Jets
local Jets = {}
for i = 1, 60 do
    local jet = Instance.new("Part")
    jet.Size = Vector3.new(0.2, math.random(5, 15), 0.2)
    jet.Color = Color3.fromRGB(150, 100, 255)
    jet.Material = Enum.Material.Neon
    jet.Anchored = true
    jet.CanCollide = false
    jet.Parent = World
    local isUp = math.random() > 0.5
    local dirY = isUp and 1 or -1
    local startY = dirY * math.random(5, 30)
    jet.Position = Vector3.new((math.random()-0.5)*2, startY, (math.random()-0.5)*2)
    table.insert(Jets, {part = jet, y = startY, spd = dirY * math.random(15, 30)})
end

-- Hawking Radiation
local HawkingParts = {}
for i = 1, 40 do
    local p = Instance.new("Part")
    p.Size = Vector3.new(0.1, 0.1, 0.1)
    p.Color = Color3.fromRGB(255, 255, 255)
    p.Material = Enum.Material.Neon
    p.Anchored = true
    p.CanCollide = false
    p.Parent = World
    table.insert(HawkingParts, {
        part = p, dist = 11.5,
        ang = math.random() * math.pi * 2,
        yAng = (math.random() - 0.5) * math.pi,
        spd = math.random(30, 80)
    })
end

-- Dust Clouds
local Clouds = {}
for i = 1, 6 do
    local cloud = Instance.new("Part")
    cloud.Shape = Enum.PartType.Ball
    cloud.Size = Vector3.new(40, 10, 40)
    cloud.Color = Color3.fromRGB(80, 0, 150)
    cloud.Material = Enum.Material.Neon
    cloud.Transparency = 0.95
    cloud.Anchored = true
    cloud.CanCollide = false
    cloud.Parent = World
    local cAng = (i / 6) * math.pi * 2
    cloud.Position = Vector3.new(math.cos(cAng) * 15, 0, math.sin(cAng) * 15)
    table.insert(Clouds, {part = cloud, ang = cAng})
end

-- Vortex (Spiral Arms)
local vortexBlocks = {}
local numArms = 3
for i = 1, 600 do
    local b = Instance.new("Part")
    local ratio = i / 600
    local distance = 6 + (ratio ^ 1.5) * 30
    local sz = math.clamp((1 - ratio) * 1.5 + math.random(1, 5) / 10, 0.1, 1.5)
    b.Size = Vector3.new(sz * 3, sz * 0.2, sz * 0.2)
    b.Material = Enum.Material.Neon
    b.Color = math.random() > 0.85 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 200, 255):Lerp(Color3.fromRGB(30, 0, 150), ratio)
    b.Anchored = true
    b.CanCollide = false
    b.Parent = World
    local armOffset = (i % numArms) * (math.pi * 2 / numArms)
    local angle = (distance * 0.3) + armOffset + (math.random(-20, 20) / 100)
    table.insert(vortexBlocks, {
        part = b, dist = distance, ang = angle,
        y = (math.random() - 0.5) * (distance / 4),
        spd = 50 / (distance ^ 1.3)
    })
end

-- Doomed Stars (Spaghettification)
local doomedStars = {}
for i = 1, 15 do
    local s = Instance.new("Part")
    s.Size = Vector3.new(0.5, 0.5, 0.5)
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Material = Enum.Material.Neon
    s.Anchored = true
    s.CanCollide = false
    s.Parent = World
    table.insert(doomedStars, {part = s, dist = math.random(25, 45), ang = math.random() * math.pi * 2})
end

-- Background Stars
local stars = {}
for i = 1, 150 do
    local s = Instance.new("Part")
    local sz = math.random(1, 4) / 20
    s.Size = Vector3.new(sz, sz, sz)
    s.Color = Color3.fromRGB(200, 150, 255)
    s.Material = Enum.Material.Neon
    s.Anchored = true
    s.CanCollide = false
    s.Parent = World
    local sx = (math.random() - 0.5) * 120
    local sy = (math.random() - 0.5) * 80
    local sz2 = math.random(-80, -20)
    s.Position = Vector3.new(sx, sy, sz2)
    table.insert(stars, {part = s, ox = sx, oy = sy, oz = sz2, spd = math.random(1, 5) / 200})
end

-- ══ ANIMATION LOOP ══════════════════════════════════════════
local timePassed = 0
local panelAlive = true

task.spawn(function()
    while panelAlive do
        local dt = RunService.RenderStepped:Wait()
        timePassed = timePassed + dt

        local pulseScale = 11.5 + math.sin(timePassed * 8) * 0.3
        PhotonSphere.Size = Vector3.new(pulseScale, pulseScale, pulseScale)
        InnerGlow.Transparency = 0.4 + math.sin(timePassed * 12) * 0.2

        VCam.FieldOfView = 70 + math.sin(timePassed * 0.5) * 5

        for _, c in ipairs(Clouds) do
            c.ang = c.ang + dt * 0.2
            c.part.CFrame = CFrame.new(math.cos(c.ang) * 15, math.sin(timePassed + c.ang) * 2, math.sin(c.ang) * 15)
            c.part.Transparency = 0.9 + math.sin(timePassed * 2 + c.ang) * 0.08
        end

        for _, j in ipairs(Jets) do
            j.part.CFrame = CFrame.new(j.part.Position.X, j.y + (timePassed * j.spd), j.part.Position.Z)
            local dist = math.abs(j.part.Position.Y)
            local flash = (math.sin(timePassed * 15 + j.y) > 0.8) and 0 or math.clamp((dist - 10) / 30, 0, 1)
            j.part.Transparency = flash
            if dist > 40 then j.y = j.part.Position.Y - (timePassed * j.spd) end
        end

        for _, hr in ipairs(HawkingParts) do
            hr.dist = hr.dist + (hr.spd * dt)
            hr.part.CFrame = CFrame.new(
                math.cos(hr.ang) * math.cos(hr.yAng) * hr.dist,
                math.sin(hr.yAng) * hr.dist,
                math.sin(hr.ang) * math.cos(hr.yAng) * hr.dist
            )
            hr.part.Transparency = math.clamp((hr.dist - 11.5) / 15, 0, 1)
            if hr.dist > 30 then
                hr.dist = 11.5
                hr.ang = math.random() * math.pi * 2
                hr.yAng = (math.random() - 0.5) * math.pi
            end
        end

        -- Mouse Parallax Camera
        local vpSize = Viewport.AbsoluteSize
        local resX = math.max(1, vpSize.X)
        local resY = math.max(1, vpSize.Y)
        local mouseX = (Mouse.X - (resX / 2)) / resX
        local mouseY = (Mouse.Y - (resY / 2)) / resY
        local camX = math.sin(timePassed * 0.15) * 6 + (mouseX * 12)
        local camY = 22 + math.cos(timePassed * 0.1) * 4 - (mouseY * 12)
        local camZ = 45 - (math.abs(mouseX) * 5)
        VCam.CFrame = VCam.CFrame:Lerp(
            CFrame.new(camX, camY, camZ) * CFrame.Angles(math.rad(-25) - (mouseY * 0.2), -(mouseX * 0.2), 0),
            0.08
        )

        for _, v in ipairs(vortexBlocks) do
            v.ang = v.ang + (v.spd * dt)
            local cd = v.dist + math.sin(timePassed * 0.5 + v.ang) * 0.5
            local x = math.cos(v.ang) * cd
            local z = math.sin(v.ang) * cd
            local wave = math.sin(v.ang * 3 + timePassed * 2) * (cd / 8)
            local pos = Vector3.new(x, v.y + wave, z)
            local tangent = Vector3.new(-math.sin(v.ang), 0, math.cos(v.ang))
            v.part.CFrame = CFrame.lookAt(pos, pos + tangent)
        end

        for _, ds in ipairs(doomedStars) do
            ds.ang = ds.ang + (50 / (ds.dist ^ 1.2)) * dt
            ds.dist = ds.dist - (dt * 4)
            local stretch = math.clamp(20 / ds.dist, 0.5, 8)
            ds.part.Size = Vector3.new(0.2, 0.2, stretch)
            local x = math.cos(ds.ang) * ds.dist
            local z = math.sin(ds.ang) * ds.dist
            local pos = Vector3.new(x, 0, z)
            local tangent = Vector3.new(-math.sin(ds.ang), -0.5, math.cos(ds.ang))
            ds.part.CFrame = CFrame.lookAt(pos, pos + tangent)
            if ds.dist < 6 then
                ds.dist = math.random(35, 50)
                ds.ang = math.random() * math.pi * 2
                InnerGlow.Transparency = 0.1
            end
        end

        for _, s in ipairs(stars) do
            s.part.CFrame = CFrame.new(s.ox, s.oy + math.sin(timePassed * s.spd * 5) * 4, s.oz) * CFrame.Angles(timePassed, timePassed, 0)
            s.part.Transparency = 0.3 + math.sin(timePassed * 4 + s.ox) * 0.7
        end
    end
end)

-- ══ TOPBAR ══════════════════════════════════════════════════
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 40)
Topbar.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
Topbar.BackgroundTransparency = 0.3
Topbar.BorderSizePixel = 0
Topbar.ZIndex = 10
Topbar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ZHuB I TA Turkish Armed Forces"
Title.TextColor3 = Color3.fromRGB(240, 240, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 11
Title.Parent = Topbar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 150, 255))
})
TitleGradient.Parent = Title

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.ZIndex = 11
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Topbar

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 190)}):Play()
end)

-- ══ MOBILE TOGGLE ═══════════════════════════════════════════
local MobileToggle = Instance.new("TextButton")
MobileToggle.Size = UDim2.new(0, 50, 0, 50)
MobileToggle.Position = UDim2.new(0.5, -25, 0, 20)
MobileToggle.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
MobileToggle.Text = "Z"
MobileToggle.TextColor3 = Color3.fromRGB(200, 150, 255)
MobileToggle.Font = Enum.Font.GothamBlack
MobileToggle.TextSize = 24
MobileToggle.Visible = false
MobileToggle.ZIndex = 50
MobileToggle.Parent = SG
Instance.new("UICorner", MobileToggle).CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", MobileToggle)
ToggleStroke.Color = Color3.fromRGB(160, 110, 255)
ToggleStroke.Thickness = 1.5

local mtDragStart, mtStartPos, mtDidDrag = nil, nil, false

MobileToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mtDidDrag = false
        mtDragStart = input.Position
        mtStartPos = MobileToggle.Position
    end
end)

MobileToggle.InputChanged:Connect(function(input)
    if mtDragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - mtDragStart
        if delta.Magnitude > 5 then mtDidDrag = true end
        MobileToggle.Position = UDim2.new(mtStartPos.X.Scale, mtStartPos.X.Offset + delta.X, mtStartPos.Y.Scale, mtStartPos.Y.Offset + delta.Y)
    end
end)

MobileToggle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mtDragStart = nil
    end
end)

MobileToggle.MouseButton1Click:Connect(function()
    if mtDidDrag then return end
    MobileToggle.Visible = false
    Main.Visible = true
    Main.Size = UDim2.new(0, 650, 0, 0)
    Main.Position = UDim2.new(0.5, -325, 0.5, 0)
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 650, 0, 420),
        Position = UDim2.new(0.5, -325, 0.5, -210)
    }):Play()
end)

-- Close Button
CloseBtn.MouseButton1Click:Connect(function()
    _G.JackLoop = false
    local t = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 650, 0, 0),
        Position = UDim2.new(0.5, -325, 0.5, 0)
    })
    t:Play()
    t.Completed:Wait()
    Main.Visible = false
    MobileToggle.Visible = true
end)

-- ══ DRAGGING ════════════════════════════════════════════════
local dragging, dragStart, startPos = false, nil, nil

Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ══ ENTRANCE ANIMATION ═════════════════════════════════════
Main.Size = UDim2.new(0, 650, 0, 0)
Main.Position = UDim2.new(0.5, -325, 0.5, 0)
TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 650, 0, 420),
    Position = UDim2.new(0.5, -325, 0.5, -210)
}):Play()

-- ╔════════════════════════════════════════════════════════════╗
-- ║              UI LAYOUT: SIDEBAR + CONTENT                  ║
-- ╚════════════════════════════════════════════════════════════╝

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
Sidebar.BackgroundTransparency = 0.3
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = Main

-- Separator line (NOT inside UIListLayout)
local SepLine = Instance.new("Frame")
SepLine.Size = UDim2.new(0, 1, 1, 0)
SepLine.Position = UDim2.new(1, 0, 0, 0)
SepLine.BackgroundColor3 = Color3.fromRGB(160, 110, 255)
SepLine.BackgroundTransparency = 0.6
SepLine.BorderSizePixel = 0
SepLine.ZIndex = 4
SepLine.Parent = Sidebar

-- Sidebar inner container (for UIListLayout)
local SidebarInner = Instance.new("Frame")
SidebarInner.Size = UDim2.new(1, 0, 1, 0)
SidebarInner.BackgroundTransparency = 1
SidebarInner.ZIndex = 4
SidebarInner.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding", SidebarInner)
SidebarPad.PaddingTop = UDim.new(0, 10)
SidebarPad.PaddingLeft = UDim.new(0, 5)
SidebarPad.PaddingRight = UDim.new(0, 5)

local SidebarList = Instance.new("UIListLayout", SidebarInner)
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 4)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -150, 1, -40)
ContentArea.Position = UDim2.new(0, 150, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 3
ContentArea.Parent = Main

-- ══ TAB SYSTEM ══════════════════════════════════════════════
local AllTabs = {}
local AllTabBtns = {}

local function SwitchTab(name)
    for n, tab in pairs(AllTabs) do
        tab.Visible = (n == name)
    end
    for n, btn in pairs(AllTabBtns) do
        if n == name then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.85, TextColor3 = Color3.fromRGB(200, 160, 255)}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(140, 140, 160)}):Play()
        end
    end
end

local function MakeTabBtn(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(140, 140, 160)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.ZIndex = 5
    btn.AutoButtonColor = false
    btn.Parent = SidebarInner
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if AllTabs[name] and not AllTabs[name].Visible then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)

    AllTabBtns[name] = btn
    return btn
end

local function MakeTabContent(name)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.ZIndex = 3
    f.Parent = ContentArea
    AllTabs[name] = f
    return f
end

-- Button factory for inside tabs
local function MakeActionBtn(parent, text, glowColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.ZIndex = 5
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(60, 50, 80)
    stroke.Thickness = 1

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundTransparency = 0.05}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.25), {Color = glowColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.25), {BackgroundTransparency = 0.3}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(60, 50, 80)}):Play()
    end)
    return btn
end

-- ╔════════════════════════════════════════════════════════════╗
-- ║                    TAB 1: JACKS                            ║
-- ╚════════════════════════════════════════════════════════════╝
MakeTabBtn("Jacks")
local JacksTab = MakeTabContent("Jacks")

local JacksInner = Instance.new("Frame")
JacksInner.Size = UDim2.new(1, 0, 1, 0)
JacksInner.BackgroundTransparency = 1
JacksInner.ZIndex = 4
JacksInner.Parent = JacksTab

local JacksPad = Instance.new("UIPadding", JacksInner)
JacksPad.PaddingTop = UDim.new(0, 30)

local JacksList = Instance.new("UIListLayout", JacksInner)
JacksList.SortOrder = Enum.SortOrder.LayoutOrder
JacksList.Padding = UDim.new(0, 14)
JacksList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(0, 260, 0, 42)
AmountBox.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
AmountBox.BackgroundTransparency = 0.3
AmountBox.TextColor3 = Color3.fromRGB(255, 255, 255)
AmountBox.PlaceholderColor3 = Color3.fromRGB(100, 90, 120)
AmountBox.Font = Enum.Font.Gotham
AmountBox.TextSize = 14
AmountBox.PlaceholderText = "Amount (e.g. 100)"
AmountBox.Text = ""
AmountBox.ZIndex = 5
AmountBox.Parent = JacksInner
Instance.new("UICorner", AmountBox).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", AmountBox).Color = Color3.fromRGB(100, 70, 160)

local JumpBtn = MakeActionBtn(JacksInner, "Jump Jack", Color3.fromRGB(160, 110, 255))
local GrammarBtn = MakeActionBtn(JacksInner, "Grammar Jack", Color3.fromRGB(110, 160, 255))
local HellBtn = MakeActionBtn(JacksInner, "Hell Jeck", Color3.fromRGB(255, 100, 100))
local StopBtn = MakeActionBtn(JacksInner, "Stop", Color3.fromRGB(200, 200, 200))

-- ══ JACKS LOGIC ═════════════════════════════════════════════
_G.JackLoop = false

local function SayMsg(msg)
    pcall(function()
        local TCS = game:GetService("TextChatService")
        if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
            TCS.TextChannels.RBXGeneral:SendAsync(msg)
        else
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
        end
    end)
end

local function Jump()
    local char = Players.LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Jump = true
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function NumberToText(num)
    if num == 0 then return "SIFIR" end
    local ones = {"", "BİR", "İKİ", "ÜÇ", "DÖRT", "BEŞ", "ALTI", "YEDİ", "SEKİZ", "DOKUZ"}
    local tens = {"", "ON", "YİRMİ", "OTUZ", "KIRK", "ELLİ", "ALTMIŞ", "YETMİŞ", "SEKSEN", "DOKSAN"}
    local function getH(n)
        local s = ""
        local h = math.floor(n / 100)
        local t = math.floor((n % 100) / 10)
        local o = n % 10
        if h > 0 then s = s .. (h == 1 and "YÜZ " or ones[h+1] .. " YÜZ ") end
        if t > 0 then s = s .. tens[t+1] .. " " end
        if o > 0 then s = s .. ones[o+1] .. " " end
        return s
    end
    local th = math.floor(num / 1000)
    local rem = num % 1000
    local r = ""
    if th > 0 then r = r .. (th == 1 and "BİN " or getH(th) .. "BİN ") end
    if rem > 0 then r = r .. getH(rem) end
    return r:gsub("%s+$", "")
end

local trLower = {["İ"]="i", ["I"]="ı", ["Ç"]="ç", ["Ş"]="ş", ["Ğ"]="ğ", ["Ü"]="ü", ["Ö"]="ö"}
local function ToGrammar(text)
    local low = text
    for u, l in pairs(trLower) do low = low:gsub(u, l) end
    low = low:lower()
    local fb = string.byte(text, 1)
    if fb >= 194 then
        return text:sub(1, 2) .. low:sub(3) .. "."
    else
        return low:sub(1, 1):upper() .. low:sub(2) .. "."
    end
end

local function RunJack(mode)
    local amt = tonumber(AmountBox.Text)
    if not amt or amt <= 0 then return end
    _G.JackLoop = true
    task.spawn(function()
        for i = 1, amt do
            if not _G.JackLoop then break end
            local numStr = NumberToText(i)
            if mode == "Jump" then
                SayMsg(numStr)
                Jump()
                task.wait(1.5)
            elseif mode == "Grammar" then
                SayMsg(ToGrammar(numStr))
                Jump()
                task.wait(1.5)
            elseif mode == "Hell" then
                local chars = {}
                for c in numStr:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
                    if c ~= " " then table.insert(chars, c) end
                end
                for _, c in ipairs(chars) do
                    if not _G.JackLoop then break end
                    SayMsg(c)
                    Jump()
                    task.wait(1.2)
                end
                if not _G.JackLoop then break end
                SayMsg(numStr)
                Jump()
                task.wait(1.5)
            end
        end
        _G.JackLoop = false
    end)
end

JumpBtn.MouseButton1Click:Connect(function() RunJack("Jump") end)
GrammarBtn.MouseButton1Click:Connect(function() RunJack("Grammar") end)
HellBtn.MouseButton1Click:Connect(function() RunJack("Hell") end)
StopBtn.MouseButton1Click:Connect(function() _G.JackLoop = false end)

-- ╔════════════════════════════════════════════════════════════╗
-- ║                    TAB 2: TURN                             ║
-- ╚════════════════════════════════════════════════════════════╝
MakeTabBtn("Turn")
local TurnTab = MakeTabContent("Turn")

local TurnInner = Instance.new("Frame")
TurnInner.Size = UDim2.new(1, 0, 1, 0)
TurnInner.BackgroundTransparency = 1
TurnInner.ZIndex = 4
TurnInner.Parent = TurnTab

local TurnPad = Instance.new("UIPadding", TurnInner)
TurnPad.PaddingTop = UDim.new(0, 30)

local TurnList = Instance.new("UIListLayout", TurnInner)
TurnList.SortOrder = Enum.SortOrder.LayoutOrder
TurnList.Padding = UDim.new(0, 14)
TurnList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TurnStatus = Instance.new("TextLabel")
TurnStatus.Size = UDim2.new(0, 260, 0, 30)
TurnStatus.BackgroundTransparency = 1
TurnStatus.Text = "90° Snap Turn: OFF"
TurnStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
TurnStatus.Font = Enum.Font.GothamSemibold
TurnStatus.TextSize = 14
TurnStatus.ZIndex = 5
TurnStatus.Parent = TurnInner

local TurnInfo = Instance.new("TextLabel")
TurnInfo.Size = UDim2.new(0, 260, 0, 55)
TurnInfo.BackgroundTransparency = 1
TurnInfo.Text = "A = Turn Left 90°\nD = Turn Right 90°\nAlways snaps to cardinal axes"
TurnInfo.TextColor3 = Color3.fromRGB(130, 120, 150)
TurnInfo.Font = Enum.Font.Gotham
TurnInfo.TextSize = 12
TurnInfo.ZIndex = 5
TurnInfo.TextWrapped = true
TurnInfo.Parent = TurnInner

local TurnToggleBtn = MakeActionBtn(TurnInner, "Enable", Color3.fromRGB(100, 255, 150))

-- Turn Logic: Cardinal-Snapped 90° Rotation
local turnEnabled = false
local turnBusy = false
local turnConnection = nil
local turnLerpConn = nil
local turnTargetCF = nil

local function GetCardinalY(hrp)
    -- Extract Y rotation from the look vector
    local look = hrp.CFrame.LookVector
    local yAngle = math.atan2(-look.X, -look.Z) -- radians
    -- Snap to nearest 90° (cardinal: 0, pi/2, pi, -pi/2)
    local snapped = math.round(yAngle / (math.pi / 2)) * (math.pi / 2)
    return snapped
end

local function TurnChar(direction)
    -- direction: 1 = left (A), -1 = right (D)
    if turnBusy then return end
    local char = Players.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    turnBusy = true

    -- Get current Y snapped to nearest cardinal, then add 90° in direction
    local currentCardinal = GetCardinalY(hrp)
    local targetY = currentCardinal + (direction * math.pi / 2)

    -- Build target CFrame: keep current position, set exact Y rotation, no X/Z tilt
    turnTargetCF = CFrame.new(hrp.Position) * CFrame.Angles(0, targetY, 0)

    -- Smooth lerp via RenderStepped (more reliable than TweenService on HRP)
    local elapsed = 0
    local duration = 0.2
    local startCF = hrp.CFrame

    if turnLerpConn then turnLerpConn:Disconnect() end

    turnLerpConn = RunService.RenderStepped:Connect(function(dt)
        local char2 = Players.LocalPlayer.Character
        if not char2 then
            turnLerpConn:Disconnect()
            turnBusy = false
            return
        end
        local hrp2 = char2:FindFirstChild("HumanoidRootPart")
        if not hrp2 then
            turnLerpConn:Disconnect()
            turnBusy = false
            return
        end

        elapsed = elapsed + dt
        local alpha = math.min(elapsed / duration, 1)
        -- Smooth ease-out
        local eased = 1 - (1 - alpha) ^ 3

        -- Keep latest position (character might be moving), only lerp rotation
        local currentPos = hrp2.Position
        local startRot = startCF - startCF.Position
        local targetRot = turnTargetCF - turnTargetCF.Position
        local lerpedRot = startRot:Lerp(targetRot, eased)

        hrp2.CFrame = CFrame.new(currentPos) * lerpedRot

        if alpha >= 1 then
            turnLerpConn:Disconnect()
            turnLerpConn = nil
            turnBusy = false
        end
    end)
end

TurnToggleBtn.MouseButton1Click:Connect(function()
    turnEnabled = not turnEnabled
    if turnEnabled then
        TurnToggleBtn.Text = "Disable"
        TurnStatus.Text = "90° Snap Turn: ON"
        TurnStatus.TextColor3 = Color3.fromRGB(100, 255, 150)

        turnConnection = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if not turnEnabled then return end
            if input.KeyCode == Enum.KeyCode.A then
                TurnChar(1)  -- Left
            elseif input.KeyCode == Enum.KeyCode.D then
                TurnChar(-1) -- Right
            end
        end)
    else
        TurnToggleBtn.Text = "Enable"
        TurnStatus.Text = "90° Snap Turn: OFF"
        TurnStatus.TextColor3 = Color3.fromRGB(255, 100, 100)

        if turnConnection then
            turnConnection:Disconnect()
            turnConnection = nil
        end
        if turnLerpConn then
            turnLerpConn:Disconnect()
            turnLerpConn = nil
        end
        turnBusy = false
    end
end)

-- ╔════════════════════════════════════════════════════════════╗
-- ║                    TAB 3: ANTI                             ║
-- ╚════════════════════════════════════════════════════════════╝
MakeTabBtn("Anti")
local AntiTab = MakeTabContent("Anti")

local AntiInner = Instance.new("Frame")
AntiInner.Size = UDim2.new(1, 0, 1, 0)
AntiInner.BackgroundTransparency = 1
AntiInner.ZIndex = 4
AntiInner.Parent = AntiTab

local AntiPad = Instance.new("UIPadding", AntiInner)
AntiPad.PaddingTop = UDim.new(0, 30)

local AntiList = Instance.new("UIListLayout", AntiInner)
AntiList.SortOrder = Enum.SortOrder.LayoutOrder
AntiList.Padding = UDim.new(0, 14)
AntiList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Anti-Detain Status
local ADStatus = Instance.new("TextLabel")
ADStatus.Size = UDim2.new(0, 260, 0, 30)
ADStatus.BackgroundTransparency = 1
ADStatus.Text = "Anti-Detain: OFF"
ADStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
ADStatus.Font = Enum.Font.GothamSemibold
ADStatus.TextSize = 14
ADStatus.ZIndex = 5
ADStatus.Parent = AntiInner

local ADInfo = Instance.new("TextLabel")
ADInfo.Size = UDim2.new(0, 260, 0, 55)
ADInfo.BackgroundTransparency = 1
ADInfo.Text = "Auto-dodges when a player with\na Detain tool gets close to you.\nEscapes BEFORE detain connects."
ADInfo.TextColor3 = Color3.fromRGB(130, 120, 150)
ADInfo.Font = Enum.Font.Gotham
ADInfo.TextSize = 12
ADInfo.ZIndex = 5
ADInfo.TextWrapped = true
ADInfo.Parent = AntiInner

-- Log label
local ADLog = Instance.new("TextLabel")
ADLog.Size = UDim2.new(0, 260, 0, 20)
ADLog.BackgroundTransparency = 1
ADLog.Text = ""
ADLog.TextColor3 = Color3.fromRGB(100, 255, 150)
ADLog.Font = Enum.Font.Gotham
ADLog.TextSize = 11
ADLog.ZIndex = 5
ADLog.Parent = AntiInner

local ADToggleBtn = MakeActionBtn(AntiInner, "Enable", Color3.fromRGB(100, 255, 150))

-- Anti-Detain Logic (Preemptive Dodge)
local adEnabled = false
local adLoopConn = nil
local adCharConn = nil
local adBusy = false

local TRIGGER_RANGE = 10
local FACING_THRESHOLD = 0.6
local COOLDOWN_TIME = 8
local INVIS_DURATION = 5

local function ADLog_Set(msg)
    ADLog.Text = msg
    task.delay(6, function()
        if ADLog.Text == msg then ADLog.Text = "" end
    end)
end

local function HasDetainTool(character)
    if not character then return false end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            local name = child.Name:lower()
            if name:find("detain") or name:find("cuff") or name:find("arrest")
                or name:find("handcuff") or name:find("restrain") then
                return true
            end
        end
    end
    return false
end

local function IsFacingUs(theirHRP, myPos)
    local dirToUs = (myPos - theirHRP.Position).Unit
    local dot = theirHRP.CFrame.LookVector:Dot(dirToUs)
    return dot > FACING_THRESHOLD
end

-- Save original transparencies so we can restore perfectly
local function SetCharInvisible(char, invisible)
    for _, desc in ipairs(char:GetDescendants()) do
        if desc:IsA("BasePart") then
            if invisible then
                if desc:GetAttribute("_adOrigTrans") == nil then
                    desc:SetAttribute("_adOrigTrans", desc.Transparency)
                end
                desc.Transparency = 1
            else
                local orig = desc:GetAttribute("_adOrigTrans")
                if orig ~= nil then
                    desc.Transparency = orig
                    desc:SetAttribute("_adOrigTrans", nil)
                end
            end
        elseif desc:IsA("Decal") or desc:IsA("Texture") then
            if invisible then
                if desc:GetAttribute("_adOrigTrans") == nil then
                    desc:SetAttribute("_adOrigTrans", desc.Transparency)
                end
                desc.Transparency = 1
            else
                local orig = desc:GetAttribute("_adOrigTrans")
                if orig ~= nil then
                    desc.Transparency = orig
                    desc:SetAttribute("_adOrigTrans", nil)
                end
            end
        -- Hide nametags and all BillboardGuis
        elseif desc:IsA("BillboardGui") then
            if invisible then
                if desc:GetAttribute("_adOrigEnabled") == nil then
                    desc:SetAttribute("_adOrigEnabled", desc.Enabled)
                end
                desc.Enabled = false
            else
                local orig = desc:GetAttribute("_adOrigEnabled")
                if orig ~= nil then
                    desc.Enabled = orig
                    desc:SetAttribute("_adOrigEnabled", nil)
                end
            end
        end
    end
end

local function EscapeAndHide(threatPos)
    if adBusy then return end
    local char = Players.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    adBusy = true

    -- Calculate escape direction: SIDEWAYS from threat (perpendicular), not forward
    local awayDir = (hrp.Position - threatPos)
    awayDir = Vector3.new(awayDir.X, 0, awayDir.Z)
    if awayDir.Magnitude < 0.1 then
        awayDir = hrp.CFrame.RightVector
    end
    awayDir = awayDir.Unit

    -- Rotate 60-120 degrees randomly so we don't go straight into/away from them
    local randomAngle = math.rad(math.random(60, 120) * (math.random() > 0.5 and 1 or -1))
    local cosA = math.cos(randomAngle)
    local sinA = math.sin(randomAngle)
    local escapeDir = Vector3.new(
        awayDir.X * cosA - awayDir.Z * sinA,
        0,
        awayDir.X * sinA + awayDir.Z * cosA
    ).Unit

    -- Go invisible FIRST (before teleport so the flash is minimal)
    SetCharInvisible(char, true)

    -- Multi-teleport: 3 rapid jumps to break any server CFrame lock
    task.spawn(function()
        for i = 1, 3 do
            local c = Players.LocalPlayer.Character
            if not c then break end
            local h = c:FindFirstChild("HumanoidRootPart")
            if not h then break end
            h.CFrame = h.CFrame + (escapeDir * 7)
            if i < 3 then task.wait(0.15) end
        end
    end)

    ADLog_Set("Escaped! Invisible for " .. INVIS_DURATION .. "s")

    -- Restore visibility after duration
    task.delay(INVIS_DURATION, function()
        local char2 = Players.LocalPlayer.Character
        if char2 then
            SetCharInvisible(char2, false)
        end
        ADLog_Set("Visible again")
        task.delay(COOLDOWN_TIME - INVIS_DURATION, function()
            adBusy = false
        end)
    end)
end

local function StartAntiDetain()
    if adLoopConn then adLoopConn:Disconnect() end

    adLoopConn = RunService.Heartbeat:Connect(function()
        if not adEnabled or adBusy then return end

        local char = Players.LocalPlayer.Character
        if not char then return end
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local myPos = myHRP.Position

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                local pChar = player.Character
                if pChar and HasDetainTool(pChar) then
                    local theirHRP = pChar:FindFirstChild("HumanoidRootPart")
                    if theirHRP then
                        local dist = (theirHRP.Position - myPos).Magnitude
                        if dist < TRIGGER_RANGE and IsFacingUs(theirHRP, myPos) then
                            EscapeAndHide(theirHRP.Position)
                            ADLog_Set("Dodged " .. player.Name)
                            break
                        end
                    end
                end
            end
        end
    end)
end

ADToggleBtn.MouseButton1Click:Connect(function()
    adEnabled = not adEnabled
    if adEnabled then
        ADToggleBtn.Text = "Disable"
        ADStatus.Text = "Anti-Detain: ON"
        ADStatus.TextColor3 = Color3.fromRGB(100, 255, 150)
        ADLog_Set("Active")

        StartAntiDetain()

        adCharConn = Players.LocalPlayer.CharacterAdded:Connect(function()
            adBusy = false
            task.wait(1)
            if adEnabled then StartAntiDetain() end
        end)
    else
        ADToggleBtn.Text = "Enable"
        ADStatus.Text = "Anti-Detain: OFF"
        ADStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        ADLog.Text = ""
        adBusy = false

        -- Restore visibility if currently invisible
        local char = Players.LocalPlayer.Character
        if char then SetCharInvisible(char, false) end

        if adLoopConn then adLoopConn:Disconnect() adLoopConn = nil end
        if adCharConn then adCharConn:Disconnect() adCharConn = nil end
    end
end)

-- ╔════════════════════════════════════════════════════════════╗
-- ║                    TAB 4: INVIS                            ║
-- ╚════════════════════════════════════════════════════════════╝
MakeTabBtn("Invis")
local InvisTab = MakeTabContent("Invis")

local InvisInner = Instance.new("Frame")
InvisInner.Size = UDim2.new(1, 0, 1, 0)
InvisInner.BackgroundTransparency = 1
InvisInner.ZIndex = 4
InvisInner.Parent = InvisTab

local InvisPad = Instance.new("UIPadding", InvisInner)
InvisPad.PaddingTop = UDim.new(0, 30)

local InvisList = Instance.new("UIListLayout", InvisInner)
InvisList.SortOrder = Enum.SortOrder.LayoutOrder
InvisList.Padding = UDim.new(0, 14)
InvisList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local InvisStatus = Instance.new("TextLabel")
InvisStatus.Size = UDim2.new(0, 260, 0, 30)
InvisStatus.BackgroundTransparency = 1
InvisStatus.Text = "Invisibility: OFF"
InvisStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
InvisStatus.Font = Enum.Font.GothamSemibold
InvisStatus.TextSize = 14
InvisStatus.ZIndex = 5
InvisStatus.Parent = InvisInner

local InvisInfo = Instance.new("TextLabel")
InvisInfo.Size = UDim2.new(0, 260, 0, 40)
InvisInfo.BackgroundTransparency = 1
InvisInfo.Text = "Makes your character fully invisible.\nHides nametag and all accessories."
InvisInfo.TextColor3 = Color3.fromRGB(130, 120, 150)
InvisInfo.Font = Enum.Font.Gotham
InvisInfo.TextSize = 12
InvisInfo.ZIndex = 5
InvisInfo.TextWrapped = true
InvisInfo.Parent = InvisInner

local InvisToggleBtn = MakeActionBtn(InvisInner, "Enable", Color3.fromRGB(100, 200, 255))

-- FE Invis Logic (Server-Side)
local invisEnabled = false
local fakeChar = nil
local realChar = nil
local invisCharConn = nil

local function EnableFEInvis()
    local player = Players.LocalPlayer
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    -- Clone the character
    char.Archivable = true
    fakeChar = char:Clone()
    fakeChar.Name = player.Name .. "_Fake"

    realChar = char
    local realHRP = realChar:FindFirstChild("HumanoidRootPart")
    
    -- Teleport real character far away and anchor it FIRST to prevent collision bumps
    realHRP.CFrame = CFrame.new(0, 99999, 0)
    realHRP.Anchored = true
    
    -- Now spawn the fake character
    fakeChar.Parent = workspace
    
    -- Hide nametag and character on our own screen safely
    for _, desc in ipairs(realChar:GetDescendants()) do
        if desc:IsA("BillboardGui") then
            if desc:GetAttribute("_invisOrigE") == nil then
                desc:SetAttribute("_invisOrigE", desc.Enabled)
            end
            desc.Enabled = false
        elseif desc:IsA("BasePart") or desc:IsA("Decal") or desc:IsA("Texture") then
            if desc:GetAttribute("_invisOrigTrans") == nil then
                desc:SetAttribute("_invisOrigTrans", desc.Transparency)
            end
            desc.Transparency = 1
        end
    end

    -- Make the fake character slightly transparent
    for _, desc in ipairs(fakeChar:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Name ~= "HumanoidRootPart" then
            -- if it was originally invisible, keep it invisible
            if desc.Transparency < 1 then
                desc.Transparency = 0.5
                desc.Material = Enum.Material.ForceField
            end
        elseif desc:IsA("BillboardGui") then
            desc.Enabled = false
        end
    end

    -- Switch control to fake character
    player.Character = fakeChar
    local fakeHum = fakeChar:FindFirstChildOfClass("Humanoid")
    workspace.CurrentCamera.CameraSubject = fakeHum

    -- Fix "falling while idle" bug: properly reset state and restart Animate
    if fakeHum then
        fakeHum:ChangeState(Enum.HumanoidStateType.Landed)
    end
    
    -- Restart animate script on fake char
    task.spawn(function()
        local animate = fakeChar:FindFirstChild("Animate")
        if animate then
            animate.Disabled = true
            task.wait()
            animate.Disabled = false
        end
    end)

    -- Fix "others seeing a frozen clone / getting stunned" issue
    -- Constantly update our fake position to the server so it doesn't desync
    if invisCharConn then invisCharConn:Disconnect() end
    invisCharConn = RunService.Heartbeat:Connect(function()
        if fakeChar and realChar then
            local fHRP = fakeChar:FindFirstChild("HumanoidRootPart")
            local rHRP = realChar:FindFirstChild("HumanoidRootPart")
            if fHRP and rHRP then
                -- Move the REAL hrp just slightly under the fake one so the server registers our presence at this location
                -- but we offset it just enough so we don't get hit by ground hitboxes
                rHRP.CFrame = fHRP.CFrame * CFrame.new(0, 5, 0)
                -- We must drop its velocity so we don't actually fly away
                rHRP.AssemblyLinearVelocity = Vector3.zero
                rHRP.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
end

local function DisableFEInvis()
    local player = Players.LocalPlayer
    if invisCharConn then
        invisCharConn:Disconnect()
        invisCharConn = nil
    end

    if realChar and realChar.Parent and fakeChar and fakeChar.Parent then
        local realHRP = realChar:FindFirstChild("HumanoidRootPart")
        local fakeHRP = fakeChar:FindFirstChild("HumanoidRootPart")
        local realHum = realChar:FindFirstChildOfClass("Humanoid")
        
        if realHRP and fakeHRP then
            realHRP.Anchored = false
            realHRP.AssemblyLinearVelocity = Vector3.zero
            realHRP.AssemblyAngularVelocity = Vector3.zero
            realHRP.CFrame = fakeHRP.CFrame
        end

        if realHum then
            realHum:ChangeState(Enum.HumanoidStateType.Landed)
        end

        -- Give control back first
        player.Character = realChar
        workspace.CurrentCamera.CameraSubject = realHum
        
        RunService.RenderStepped:Wait()

        -- Restore true original transparency
        for _, desc in ipairs(realChar:GetDescendants()) do
            if desc:IsA("BasePart") or desc:IsA("Decal") or desc:IsA("Texture") then
                local orig = desc:GetAttribute("_invisOrigTrans")
                if orig ~= nil then
                    desc.Transparency = orig
                    desc:SetAttribute("_invisOrigTrans", nil)
                end
            elseif desc:IsA("BillboardGui") then
                local orig = desc:GetAttribute("_invisOrigE")
                if orig ~= nil then
                    desc.Enabled = orig
                    desc:SetAttribute("_invisOrigE", nil)
                end
            end
        end
        
        -- Fix falling/elevation bug by stopping current falling animations directly 
        if realHum then
            local animator = realHum:FindFirstChildOfClass("Animator")
            local tracks = animator and animator:GetPlayingAnimationTracks() or realHum:GetPlayingAnimationTracks()
            for _, track in ipairs(tracks) do
                track:Stop(0) 
            end
        end
    end

    if fakeChar then
        fakeChar:Destroy()
        fakeChar = nil
    end
    realChar = nil
end

InvisToggleBtn.MouseButton1Click:Connect(function()
    invisEnabled = not invisEnabled
    if invisEnabled then
        InvisToggleBtn.Text = "Disable"
        InvisStatus.Text = "FE Invis: ON"
        InvisStatus.TextColor3 = Color3.fromRGB(100, 200, 255)

        EnableFEInvis()
    else
        InvisToggleBtn.Text = "Enable"
        InvisStatus.Text = "FE Invis: OFF"
        InvisStatus.TextColor3 = Color3.fromRGB(255, 100, 100)

        DisableFEInvis()
    end
end)

-- ╔════════════════════════════════════════════════════════════╗
-- ║                    TAB 5: TROLL                            ║
-- ╚════════════════════════════════════════════════════════════╝
MakeTabBtn("Troll")
local TrollTab = MakeTabContent("Troll")

local TrollInner = Instance.new("ScrollingFrame")
TrollInner.Size = UDim2.new(1, 0, 1, 0)
TrollInner.BackgroundTransparency = 1
TrollInner.ZIndex = 4
TrollInner.ScrollBarThickness = 4
TrollInner.ScrollBarImageColor3 = Color3.fromRGB(150, 100, 255)
TrollInner.CanvasSize = UDim2.new(0, 0, 0, 800) -- Plenty of room for Troll features
TrollInner.Parent = TrollTab

local TrollPad = Instance.new("UIPadding", TrollInner)
TrollPad.PaddingTop = UDim.new(0, 30)
TrollPad.PaddingBottom = UDim.new(0, 30) -- Add some padding to the bottom so last element isn't cut off

local TrollList = Instance.new("UIListLayout", TrollInner)
TrollList.SortOrder = Enum.SortOrder.LayoutOrder
TrollList.Padding = UDim.new(0, 14)
TrollList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 🌍 Chat Translator (TR -> AR)
local TransLabel = Instance.new("TextLabel")
TransLabel.Size = UDim2.new(0, 260, 0, 20)
TransLabel.BackgroundTransparency = 1
TransLabel.Text = "Chat Translator (TR -> AR)"
TransLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
TransLabel.Font = Enum.Font.GothamBold
TransLabel.TextSize = 14
TransLabel.ZIndex = 5
TransLabel.Parent = TrollInner

local TransInfo = Instance.new("TextLabel")
TransInfo.Size = UDim2.new(0, 260, 0, 30)
TransInfo.BackgroundTransparency = 1
TransInfo.Text = "Type in Turkish, it automatically translates and sends to game chat in Arabic!"
TransInfo.TextColor3 = Color3.fromRGB(130, 150, 130)
TransInfo.Font = Enum.Font.Gotham
TransInfo.TextSize = 12
TransInfo.ZIndex = 5
TransInfo.TextWrapped = true
TransInfo.Parent = TrollInner

local TransInputContainer = Instance.new("Frame")
TransInputContainer.Size = UDim2.new(0, 260, 0, 36)
TransInputContainer.BackgroundColor3 = Color3.fromRGB(15, 25, 15)
TransInputContainer.ZIndex = 4
TransInputContainer.Parent = TrollInner
local TransInputCorner = Instance.new("UICorner", TransInputContainer)
TransInputCorner.CornerRadius = UDim.new(0, 8)
local TransInputStroke = Instance.new("UIStroke", TransInputContainer)
TransInputStroke.Color = Color3.fromRGB(40, 90, 40)

local TransInput = Instance.new("TextBox")
TransInput.Size = UDim2.new(1, -20, 1, 0)
TransInput.Position = UDim2.new(0, 10, 0, 0)
TransInput.BackgroundTransparency = 1
TransInput.Text = "" 
TransInput.TextColor3 = Color3.fromRGB(200, 255, 200)
TransInput.PlaceholderText = "Type your message and press Enter..."
TransInput.Font = Enum.Font.Gotham
TransInput.TextSize = 12
TransInput.ZIndex = 5
TransInput.Parent = TransInputContainer

-- Logic
local httpReq = (syn and syn.request) or (http and http.request) or http_request or request

local function urlEncode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

local function SendChat(msg)
    local TextChatService = game:GetService("TextChatService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:SendAsync(msg) end
    else
        local sayMsg = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if sayMsg and sayMsg:FindFirstChild("SayMessageRequest") then
            sayMsg.SayMessageRequest:FireServer(msg, "All")
        end
    end
end

TransInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and TransInput.Text ~= "" then
        local msg = TransInput.Text
        TransInput.Text = "Translating..."
        task.spawn(function()
            if httpReq then
                local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=tr&tl=ar&dt=t&q=" .. urlEncode(msg)
                local response = httpReq({Url = url, Method = "GET"})
                if response and response.Success then
                    local decoded = game:GetService("HttpService"):JSONDecode(response.Body)
                    if decoded and decoded[1] and decoded[1][1] and decoded[1][1][1] then
                        SendChat(decoded[1][1][1])
                    else
                        SendChat(msg)
                    end
                else
                    SendChat(msg)
                end
            else
                SendChat("[ZHuB: request API not found] " .. msg)
            end
            TransInput.Text = ""
        end)
    end
end)

-- Fake Lag Section
local FakeLagLabel = Instance.new("TextLabel")
FakeLagLabel.Size = UDim2.new(0, 260, 0, 20)
FakeLagLabel.BackgroundTransparency = 1
FakeLagLabel.Text = "Fake Lag"
FakeLagLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
FakeLagLabel.Font = Enum.Font.GothamBold
FakeLagLabel.TextSize = 14
FakeLagLabel.ZIndex = 5
FakeLagLabel.Parent = TrollInner

local FakeLagInfo = Instance.new("TextLabel")
FakeLagInfo.Size = UDim2.new(0, 260, 0, 30)
FakeLagInfo.BackgroundTransparency = 1
FakeLagInfo.Text = "Simulates high ping. Others see you teleporting.\nYour camera remains smooth."
FakeLagInfo.TextColor3 = Color3.fromRGB(130, 120, 150)
FakeLagInfo.Font = Enum.Font.Gotham
FakeLagInfo.TextSize = 12
FakeLagInfo.ZIndex = 5
FakeLagInfo.TextWrapped = true
FakeLagInfo.Parent = TrollInner

-- Fake Lag FPS Input
local LagInputContainer = Instance.new("Frame")
LagInputContainer.Size = UDim2.new(0, 260, 0, 36)
LagInputContainer.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
LagInputContainer.ZIndex = 4
LagInputContainer.Parent = TrollInner
local LagInputCorner = Instance.new("UICorner", LagInputContainer)
LagInputCorner.CornerRadius = UDim.new(0, 8)
local LagInputStroke = Instance.new("UIStroke", LagInputContainer)
LagInputStroke.Color = Color3.fromRGB(60, 40, 90)

local FakeLagInput = Instance.new("TextBox")
FakeLagInput.Size = UDim2.new(1, -20, 1, 0)
FakeLagInput.Position = UDim2.new(0, 10, 0, 0)
FakeLagInput.BackgroundTransparency = 1
FakeLagInput.Text = "5" -- Default lag FPS
FakeLagInput.TextColor3 = Color3.fromRGB(200, 180, 255)
FakeLagInput.PlaceholderText = "Target FPS (e.g., 5)"
FakeLagInput.Font = Enum.Font.Gotham
FakeLagInput.TextSize = 14
FakeLagInput.ZIndex = 5
FakeLagInput.Parent = LagInputContainer

local FakeLagToggleBtn = MakeActionBtn(TrollInner, "Enable Fake Lag", Color3.fromRGB(255, 150, 50))

-- Fake Lag Logic
local fakeLagEnabled = false
local fakeLagConn = nil

local function StartFakeLag()
    if fakeLagConn then fakeLagConn:Disconnect() end
    
    local targetFPS = tonumber(FakeLagInput.Text) or 5
    -- Make sure it's sensible
    if targetFPS < 1 then targetFPS = 1 end
    if targetFPS > 30 then targetFPS = 30 end
    
    local waitTime = 1 / targetFPS
    local lastTick = tick()

    fakeLagConn = RunService.Heartbeat:Connect(function()
        if not fakeLagEnabled then return end
        
        local char = Players.LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Calculate if we should anchor or unanchor based on fake frame rate
        if tick() - lastTick >= waitTime then
            -- Let character move for 1 frame
            hrp.Anchored = false
            lastTick = tick()
        else
            -- Lock character in place (causes network position to stop updating)
            -- Camera is not attached to RootPart's physics, so camera stays smooth
            hrp.Anchored = true
        end
    end)
end

FakeLagToggleBtn.MouseButton1Click:Connect(function()
    fakeLagEnabled = not fakeLagEnabled
    if fakeLagEnabled then
        FakeLagToggleBtn.Text = "Disable Fake Lag"
        FakeLagLabel.TextColor3 = Color3.fromRGB(255, 150, 50)
        StartFakeLag()
    else
        FakeLagToggleBtn.Text = "Enable Fake Lag"
        FakeLagLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
        
        if fakeLagConn then 
            fakeLagConn:Disconnect() 
            fakeLagConn = nil 
        end
        
        -- Make sure we leave them unanchored
        local char = Players.LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored = false end
        end
    end
end)

FakeLagInput.FocusLost:Connect(function()
    if fakeLagEnabled then
        StartFakeLag() -- Restart with new FPS if currently enabled
    end
end)

local trollGhostActive = false

-- Astral Projection (AFK Decoy)
local AstralLabel = Instance.new("TextLabel")
AstralLabel.Size = UDim2.new(0, 260, 0, 20)
AstralLabel.BackgroundTransparency = 1
AstralLabel.Text = "Astral Projection [GHOST]"
AstralLabel.TextColor3 = Color3.fromRGB(150, 100, 255)
AstralLabel.Font = Enum.Font.GothamBold
AstralLabel.TextSize = 14
AstralLabel.ZIndex = 5
AstralLabel.Parent = TrollInner

local AstralInfo = Instance.new("TextLabel")
AstralInfo.Size = UDim2.new(0, 260, 0, 45)
AstralInfo.BackgroundTransparency = 1
AstralInfo.Text = "Leave your body behind as an AFK decoy. Fly around as a ghost for 15s. Zero Ban Risk!"
AstralInfo.TextColor3 = Color3.fromRGB(130, 120, 170)
AstralInfo.Font = Enum.Font.Gotham
AstralInfo.TextSize = 12
AstralInfo.ZIndex = 5
AstralInfo.TextWrapped = true
AstralInfo.Parent = TrollInner

local AstralToggleBtn = MakeActionBtn(TrollInner, "Project Soul", Color3.fromRGB(100, 50, 200))

-- Astral Logic
local astralEnabled = false
local astralFakeChar = nil
local astralRealChar = nil
local astralConn = nil
local astralTime = 15
local currentAstralTime = 0

-- UI for the Timer Bar
local AstralGui = Instance.new("ScreenGui")
AstralGui.Name = "ZHuB_AstralVFX"
AstralGui.Parent = game:GetService("CoreGui")

local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0, 300, 0, 24)
BarBG.Position = UDim2.new(0.5, -150, 0, -50) -- Offscreen initially
BarBG.BackgroundColor3 = Color3.fromRGB(20, 10, 30)
BarBG.BackgroundTransparency = 0.2
BarBG.BorderSizePixel = 0
BarBG.Parent = AstralGui
local BarCorner = Instance.new("UICorner", BarBG)
BarCorner.CornerRadius = UDim.new(0, 12)
local BarStroke = Instance.new("UIStroke", BarBG)
BarStroke.Color = Color3.fromRGB(100, 50, 200)
BarStroke.Thickness = 2

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(1, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(150, 80, 255)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBG
local BarFillCorner = Instance.new("UICorner", BarFill)
BarFillCorner.CornerRadius = UDim.new(0, 12)

local BarText = Instance.new("TextLabel")
BarText.Size = UDim2.new(1, 0, 1, 0)
BarText.BackgroundTransparency = 1
BarText.Text = "ASTRAL PROJECTION"
BarText.TextColor3 = Color3.fromRGB(255, 255, 255)
BarText.Font = Enum.Font.GothamBold
BarText.TextSize = 12
BarText.ZIndex = 2
BarText.Parent = BarBG

local origLighting = {}
local astralCC = nil

local function DisableAstral()
    if not astralEnabled then return end
    trollGhostActive = false
    astralEnabled = false
    AstralToggleBtn.Text = "Project Soul"
    AstralLabel.TextColor3 = Color3.fromRGB(150, 100, 255)

    if astralConn then astralConn:Disconnect() astralConn = nil end

    if astralRealChar and astralFakeChar then
        local rHRP = astralRealChar:FindFirstChild("HumanoidRootPart")
        if rHRP then rHRP.Anchored = false end
        
        Players.LocalPlayer.Character = astralRealChar
        workspace.CurrentCamera.CameraSubject = astralRealChar:FindFirstChildOfClass("Humanoid")
    end

    if astralFakeChar then astralFakeChar:Destroy() astralFakeChar = nil end
    astralRealChar = nil

    -- Tween Lighting back
    TweenService:Create(Lighting, TweenInfo.new(1.5), origLighting):Play()
    TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1), {FieldOfView = 70}):Play()

    -- Tween Bar away
    TweenService:Create(BarBG, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -150, 0, -50)}):Play()
    
    -- Cleanup VFX
    if astralCC then
        TweenService:Create(astralCC, TweenInfo.new(1), {Brightness = 0, Contrast = 0, Saturation = 0}):Play()
        task.delay(1, function() if astralCC then astralCC:Destroy() astralCC = nil end end)
    end
end

local function EnableAstral()
    if trollGhostActive then return end
    local player = Players.LocalPlayer
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    trollGhostActive = true
    astralEnabled = true
    AstralToggleBtn.Text = "Return to Body"
    AstralLabel.TextColor3 = Color3.fromRGB(200, 150, 255)

    char.Archivable = true
    astralFakeChar = char:Clone()
    astralFakeChar.Name = player.Name .. "_Astral"
    astralFakeChar.Parent = workspace

    astralRealChar = char
    local realHRP = astralRealChar:FindFirstChild("HumanoidRootPart")
    
    -- Decoy: Anchor real body in place
    if realHRP then realHRP.Anchored = true end

    -- Ghost Visuals (Aura & Glow)
    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(150, 50, 255)
    hl.OutlineColor = Color3.fromRGB(220, 180, 255)
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl.Parent = astralFakeChar

    for _, desc in ipairs(astralFakeChar:GetDescendants()) do
        if desc:IsA("BasePart") then
            -- 0.99 fixes the Roblox Highlight bug where fully transparent parts aren't highlighted!
            desc.Transparency = 0.99 
            desc.CanCollide = false
        elseif desc:IsA("BillboardGui") then
            desc.Enabled = false
        end
    end

    player.Character = astralFakeChar
    workspace.CurrentCamera.CameraSubject = astralFakeChar:FindFirstChildOfClass("Humanoid")

    local fakeHRP = astralFakeChar:FindFirstChild("HumanoidRootPart")
    if fakeHRP then fakeHRP.Anchored = true end

    -- Save Lighting
    origLighting = {
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Ambient = Lighting.Ambient,
        ColorShift_Top = Lighting.ColorShift_Top
    }

    -- Create VFX (Removed Blur)
    astralCC = Instance.new("ColorCorrectionEffect")
    astralCC.TintColor = Color3.fromRGB(220, 180, 255)
    astralCC.Saturation = -0.5
    astralCC.Contrast = 0.2
    astralCC.Parent = Lighting

    -- Tween Lighting & VFX
    TweenService:Create(Lighting, TweenInfo.new(2, Enum.EasingStyle.Sine), {
        OutdoorAmbient = Color3.fromRGB(50, 10, 100),
        Ambient = Color3.fromRGB(30, 0, 70),
        ColorShift_Top = Color3.fromRGB(120, 40, 255)
    }):Play()
    TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = 90}):Play()

    -- Show Bar (30 seconds)
    astralTime = 30
    currentAstralTime = astralTime
    BarFill.Size = UDim2.new(1, 0, 1, 0)
    TweenService:Create(BarBG, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -150, 0, 30)}):Play()

    -- Fly Loop & Timer
    local speed = 60 -- Ghost flight speed
    local uis = UserInputService
    
    astralConn = RunService.RenderStepped:Connect(function(dt)
        if not astralFakeChar or not fakeHRP then return DisableAstral() end
        
        -- Check if real body died to prevent respawn locks
        if astralRealChar then
            local rHum = astralRealChar:FindFirstChildOfClass("Humanoid")
            if not rHum or rHum.Health <= 0 then
                DisableAstral()
                return
            end
        end
        
        -- Update Timer
        currentAstralTime = currentAstralTime - dt
        local fillPct = math.clamp(currentAstralTime / astralTime, 0, 1)
        
        -- Make bar smoothly drain and pulsate
        BarFill.Size = UDim2.new(fillPct, 0, 1, 0)
        BarText.Text = string.format("ASTRAL PROJECTION - %.1fs", currentAstralTime)

        if currentAstralTime <= 0 then
            DisableAstral()
            return
        end

        -- Custom Flight Physics (Noclip)
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new()
        
        if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end

        -- 1000x Better Flight Animation: Dynamic Superman Tilt
        local targetPos = fakeHRP.Position + (moveDir * speed * dt)
        local lookAt = targetPos + cam.CFrame.LookVector * Vector3.new(1,0,1)
        
        if (lookAt - targetPos).Magnitude > 0.01 then
            local baseCFrame = CFrame.new(targetPos, lookAt)
            
            -- Calculate lean based on movement relative to camera
            local localVelocity = baseCFrame:VectorToObjectSpace(moveDir)
            local tiltX = math.rad(localVelocity.Z * 60) -- Lean forward/backward up to 60 degrees
            local tiltZ = math.rad(-localVelocity.X * 45) -- Lean left/right up to 45 degrees
            
            local targetRotation = (baseCFrame * CFrame.Angles(tiltX, 0, tiltZ)).Rotation
            local currentRotation = fakeHRP.CFrame.Rotation
            
            -- Instantly update position, but smoothly Lerp rotation
            fakeHRP.CFrame = CFrame.new(targetPos) * currentRotation:Lerp(targetRotation, 12 * dt)
        else
            fakeHRP.CFrame = CFrame.new(targetPos) * fakeHRP.CFrame.Rotation
        end
    end)
end

AstralToggleBtn.MouseButton1Click:Connect(function()
    if astralEnabled then DisableAstral() else EnableAstral() end
end)

-- King Crimson (Time Erase / Blink)
local KCLabel = Instance.new("TextLabel")
KCLabel.Size = UDim2.new(0, 260, 0, 20)
KCLabel.BackgroundTransparency = 1
KCLabel.Text = "King Crimson (Blink)"
KCLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
KCLabel.Font = Enum.Font.GothamBold
KCLabel.TextSize = 14
KCLabel.ZIndex = 5
KCLabel.Parent = TrollInner

local KCInfo = Instance.new("TextLabel")
KCInfo.Size = UDim2.new(0, 260, 0, 45)
KCInfo.BackgroundTransparency = 1
KCInfo.Text = "Press [V] to Erase Time! Fly behind your enemy as a ghost. When deactivated, your real body teleports instantly to your ghost."
KCInfo.TextColor3 = Color3.fromRGB(150, 80, 80)
KCInfo.Font = Enum.Font.Gotham
KCInfo.TextSize = 12
KCInfo.ZIndex = 5
KCInfo.TextWrapped = true
KCInfo.Parent = TrollInner

local KCToggleBtn = MakeActionBtn(TrollInner, "Activate (V)", Color3.fromRGB(200, 40, 40))

-- KC Logic
local kcEnabled = false
local kcFakeChar = nil
local kcRealChar = nil
local kcConn = nil
local kcTime = 5
local kcCurrentTime = 0
local kcOrigLighting = {}
local kcCC = nil
local kcBlur = nil

-- Timer UI setup
local KCGui = Instance.new("ScreenGui")
KCGui.Name = "ZHuB_KCVFX"
KCGui.Parent = game:GetService("CoreGui")

local KCBarBG = Instance.new("Frame")
KCBarBG.Size = UDim2.new(0, 300, 0, 24)
KCBarBG.Position = UDim2.new(0.5, -150, 0, -50)
KCBarBG.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
KCBarBG.BackgroundTransparency = 0.2
KCBarBG.BorderSizePixel = 0
KCBarBG.Parent = KCGui
local KCBarCorner = Instance.new("UICorner", KCBarBG)
KCBarCorner.CornerRadius = UDim.new(0, 12)
local KCBarStroke = Instance.new("UIStroke", KCBarBG)
KCBarStroke.Color = Color3.fromRGB(255, 0, 0)
KCBarStroke.Thickness = 2

local KCBarFill = Instance.new("Frame")
KCBarFill.Size = UDim2.new(1, 0, 1, 0)
KCBarFill.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
KCBarFill.BorderSizePixel = 0
KCBarFill.Parent = KCBarBG
local KCBarFillCorner = Instance.new("UICorner", KCBarFill)
KCBarFillCorner.CornerRadius = UDim.new(0, 12)

local KCBarText = Instance.new("TextLabel")
KCBarText.Size = UDim2.new(1, 0, 1, 0)
KCBarText.BackgroundTransparency = 1
KCBarText.Text = "TIME ERASED"
KCBarText.TextColor3 = Color3.fromRGB(255, 255, 255)
KCBarText.Font = Enum.Font.GothamBold
KCBarText.TextSize = 12
KCBarText.ZIndex = 2
KCBarText.Parent = KCBarBG

local function DisableKingCrimson()
    if not kcEnabled then return end
    trollGhostActive = false
    kcEnabled = false
    KCToggleBtn.Text = "Activate (V)"
    KCLabel.TextColor3 = Color3.fromRGB(255, 50, 50)

    if kcConn then kcConn:Disconnect() kcConn = nil end

    if kcRealChar and kcFakeChar then
        local rHRP = kcRealChar:FindFirstChild("HumanoidRootPart")
        local fHRP = kcFakeChar:FindFirstChild("HumanoidRootPart")
        
        -- THE STRIKE: Teleport real body to the ghost!
        if rHRP and fHRP then
            -- We make sure the real body is placed exactly where the ghost was, facing the camera direction
            rHRP.CFrame = fHRP.CFrame * CFrame.new(0, 0, 0)
            rHRP.Anchored = false
        end
        
        Players.LocalPlayer.Character = kcRealChar
        workspace.CurrentCamera.CameraSubject = kcRealChar:FindFirstChildOfClass("Humanoid")
        
        -- Camera Shake on Impact!
        task.spawn(function()
            local cam = workspace.CurrentCamera
            for i = 1, 10 do
                local rx = (math.random() - 0.5) * 2
                local ry = (math.random() - 0.5) * 2
                local rz = (math.random() - 0.5) * 2
                cam.CFrame = cam.CFrame * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz))
                task.wait()
            end
        end)
    end

    if kcFakeChar then kcFakeChar:Destroy() kcFakeChar = nil end
    kcRealChar = nil

    -- Tween Lighting back
    TweenService:Create(Lighting, TweenInfo.new(0.3), kcOrigLighting):Play()
    TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.3), {FieldOfView = 70}):Play()
    TweenService:Create(KCBarBG, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -150, 0, -50)}):Play()
    
    if kcCC then
        TweenService:Create(kcCC, TweenInfo.new(0.3), {Brightness = 0, Contrast = 0, Saturation = 0, TintColor = Color3.fromRGB(255,255,255)}):Play()
        task.delay(0.3, function() if kcCC then kcCC:Destroy() kcCC = nil end end)
    end
    if kcBlur then
        TweenService:Create(kcBlur, TweenInfo.new(0.3), {Size = 0}):Play()
        task.delay(0.3, function() if kcBlur then kcBlur:Destroy() kcBlur = nil end end)
    end
end

local function EnableKingCrimson()
    if trollGhostActive then return end
    local player = Players.LocalPlayer
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    trollGhostActive = true
    kcEnabled = true
    KCToggleBtn.Text = "Strike! (V)"
    KCLabel.TextColor3 = Color3.fromRGB(255, 150, 150)

    char.Archivable = true
    kcFakeChar = char:Clone()
    kcFakeChar.Name = player.Name .. "_KC"
    
    kcRealChar = char
    local realHRP = kcRealChar:FindFirstChild("HumanoidRootPart")
    
    -- Anchor real body
    if realHRP then realHRP.Anchored = true end

    kcFakeChar.Parent = workspace

    -- Ghost Visuals
    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor = Color3.fromRGB(255, 100, 100)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.Parent = kcFakeChar

    for _, desc in ipairs(kcFakeChar:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Transparency = 0.99
            desc.CanCollide = false
        elseif desc:IsA("BillboardGui") then
            desc.Enabled = false
        end
    end

    player.Character = kcFakeChar
    workspace.CurrentCamera.CameraSubject = kcFakeChar:FindFirstChildOfClass("Humanoid")

    local fakeHRP = kcFakeChar:FindFirstChild("HumanoidRootPart")
    if fakeHRP then fakeHRP.Anchored = true end

    -- Save Lighting
    kcOrigLighting = {
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Ambient = Lighting.Ambient,
        ColorShift_Top = Lighting.ColorShift_Top
    }

    -- Create Aggressive Red VFX
    kcCC = Instance.new("ColorCorrectionEffect")
    kcCC.TintColor = Color3.fromRGB(255, 50, 50)
    kcCC.Saturation = -0.5
    kcCC.Contrast = 0.5
    kcCC.Brightness = -0.1
    kcCC.Parent = Lighting

    kcBlur = Instance.new("BlurEffect")
    kcBlur.Size = 4
    kcBlur.Parent = Lighting

    -- Flash bang effect (Time Erase Start)
    kcCC.Brightness = 1
    TweenService:Create(kcCC, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {Brightness = -0.1}):Play()

    TweenService:Create(Lighting, TweenInfo.new(0.5), {
        OutdoorAmbient = Color3.fromRGB(100, 0, 0),
        Ambient = Color3.fromRGB(50, 0, 0),
        ColorShift_Top = Color3.fromRGB(255, 0, 0)
    }):Play()
    TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = 100}):Play()

    -- Show Bar (5 seconds)
    kcCurrentTime = kcTime
    KCBarFill.Size = UDim2.new(1, 0, 1, 0)
    TweenService:Create(KCBarBG, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -150, 0, 30)}):Play()

    -- Fly Loop
    local speed = 80 -- Extremely fast
    local uis = UserInputService
    
    kcConn = RunService.RenderStepped:Connect(function(dt)
        if not kcFakeChar or not fakeHRP then return DisableKingCrimson() end
        
        -- Check if real body died
        if kcRealChar then
            local rHum = kcRealChar:FindFirstChildOfClass("Humanoid")
            if not rHum or rHum.Health <= 0 then
                DisableKingCrimson()
                return
            end
        end
        
        kcCurrentTime = kcCurrentTime - dt
        local fillPct = math.clamp(kcCurrentTime / kcTime, 0, 1)
        KCBarFill.Size = UDim2.new(fillPct, 0, 1, 0)
        KCBarText.Text = string.format("TIME ERASED - %.1fs", kcCurrentTime)

        if kcCurrentTime <= 0 then
            DisableKingCrimson()
            return
        end

        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new()
        
        if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
        end

        local targetPos = fakeHRP.Position + (moveDir * speed * dt)
        local lookAt = targetPos + cam.CFrame.LookVector * Vector3.new(1,0,1)
        
        if (lookAt - targetPos).Magnitude > 0.01 then
            local baseCFrame = CFrame.new(targetPos, lookAt)
            local localVelocity = baseCFrame:VectorToObjectSpace(moveDir)
            local tiltX = math.rad(localVelocity.Z * 45)
            local tiltZ = math.rad(-localVelocity.X * 30)
            
            local targetRotation = (baseCFrame * CFrame.Angles(tiltX, 0, tiltZ)).Rotation
            local currentRotation = fakeHRP.CFrame.Rotation
            
            fakeHRP.CFrame = CFrame.new(targetPos) * currentRotation:Lerp(targetRotation, 15 * dt)
        else
            fakeHRP.CFrame = CFrame.new(targetPos) * fakeHRP.CFrame.Rotation
        end
    end)
end

KCToggleBtn.MouseButton1Click:Connect(function()
    if kcEnabled then DisableKingCrimson() else EnableKingCrimson() end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.V then
        if kcEnabled then DisableKingCrimson() else EnableKingCrimson() end
    end
end)

-- ══ DEFAULT TAB ═════════════════════════════════════════════
SwitchTab("Jacks")
