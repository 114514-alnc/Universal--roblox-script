local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LP = game:GetService("Players").LocalPlayer

-- [配置区]
local CURRENT_VERSION = "1.0.0"
local VERSION_URL = "https://raw.githubusercontent.com/114514-alnc/Universal--roblox-script/refs/heads/main/OptimizationUniversalVersion.txt"
local SCRIPT_BASE_URL = "https://raw.githubusercontent.com/114514-alnc/Universal--roblox-script/refs/heads/main/OptimizationUniversalScript"
local LOG_BASE_URL = "https://raw.githubusercontent.com/114514-alnc/Universal--roblox-script/refs/heads/main/Updatelog/Chinese/OptimizationUniversal"

-- UI 容器
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Zen_V5_1_Pro"
ScreenGui.Parent = LP:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- [函数] 检测 Http 功能是否开启
local function IsHttpEnabled()
	local success, _ = pcall(function()
		-- 尝试发送一个无效请求来测试权限
		HttpService:GetAsync("http://google.com")
	end)
	-- 如果报错信息包含 "Http requests are not enabled"，则返回 false
	return success or not string.find(_, "Http requests are not enabled")
end

-- [更新提示 UI 逻辑]
local function CreateUpdateWindow(remoteVer, logs, scriptUrl)
	local UpdateFrame = Instance.new("Frame")
	UpdateFrame.Size = UDim2.new(0, 320, 0, 220)
	UpdateFrame.Position = UDim2.new(0.5, -160, -0.5, 0)
	UpdateFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	UpdateFrame.Parent = ScreenGui
	Instance.new("UICorner", UpdateFrame)

	local T = Instance.new("TextLabel")
	T.Size = UDim2.new(1, 0, 0, 40)
	T.Text = "🚀 发现新版本: " .. remoteVer
	T.TextColor3 = Color3.new(1, 1, 1)
	T.BackgroundTransparency = 1
	T.Parent = UpdateFrame

	local L = Instance.new("TextLabel")
	L.Size = UDim2.new(0.9, 0, 0, 100)
	L.Position = UDim2.new(0.05, 0, 0.2, 0)
	L.Text = "更新日志:\n" .. logs
	L.TextColor3 = Color3.fromRGB(180, 180, 180)
	L.TextWrapped = true
	L.TextYAlignment = Enum.TextYAlignment.Top
	L.BackgroundTransparency = 1
	L.Parent = UpdateFrame

	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(0.9, 0, 0, 40)
	Btn.Position = UDim2.new(0.05, 0, 0.75, 0)
	Btn.Text = "立即更新并重启脚本"
	Btn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
	Btn.TextColor3 = Color3.new(1, 1, 1)
	Btn.Parent = UpdateFrame
	Instance.new("UICorner", Btn)

	UpdateFrame:TweenPosition(UDim2.new(0.5, -160, 0.3, 0), "Out", "Back", 0.5)

	Btn.MouseButton1Click:Connect(function()
		local s, code = pcall(function() return HttpService:GetAsync(scriptUrl) end)
		if s then
			UpdateFrame:Destroy()
			loadstring(code)()
		end
	end)
end

-- [主运行逻辑]
task.spawn(function()
	print("Zen Optimizer 正在启动...")
	
	-- 核心检查：如果 Http 未开启，静默跳过更新
	if IsHttpEnabled() then
		print("Http 已开启，正在检查更新...")
		local s, remoteVer = pcall(function() return HttpService:GetAsync(VERSION_URL) end)
		remoteVer = remoteVer and remoteVer:gsub("%s+", "")
		
		if s and remoteVer and remoteVer ~= CURRENT_VERSION then
			local _, logs = pcall(function() return HttpService:GetAsync(LOG_BASE_URL .. remoteVer .. ".txt") end)
			CreateUpdateWindow(remoteVer, logs or "暂无日志", SCRIPT_BASE_URL .. remoteVer .. ".lua")
		end
	else
		warn("Http 未开启，已跳过版本检测。")
	end
end)

--- [此处放置你之前所有的 V4 功能面板代码] ---
-- 注意：确保你的主面板逻辑不依赖于更新检测，这样即使用户离线也能使用基本优化功能
print("Zen V5.1 核心功能已加载。当前版本: " .. CURRENT_VERSION)
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

-- UI 核心容器
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Zen_V4_Super"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

-- [移动端专用] 强制恢复按钮
local RecoveryBtn = Instance.new("TextButton")
RecoveryBtn.Size = UDim2.new(0, 120, 0, 45)
RecoveryBtn.Position = UDim2.new(0.5, -60, 0.05, 0)
RecoveryBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
RecoveryBtn.Text = "恢复3D画面"
RecoveryBtn.ZIndex = 100
RecoveryBtn.Visible = false
RecoveryBtn.Parent = ScreenGui
Instance.new("UICorner", RecoveryBtn)

-- 主面板
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 450)
Main.Position = UDim2.new(0.5, -140, 1.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BackgroundTransparency = 0.1
Main.Parent = ScreenGui
local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 15)

-- 标题与状态栏
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Zen Optimizer"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Parent = Main

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, 0, 0, 20)
StatsLabel.Position = UDim2.new(0, 0, 0, 40)
StatsLabel.Text = "FPS: -- | Ping: --"
StatsLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatsLabel.TextSize = 12
StatsLabel.BackgroundTransparency = 1
StatsLabel.Parent = Main

-- 滚动区域
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -80)
Scroll.Position = UDim2.new(0, 10, 0, 70)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 3, 0) -- 增加长度容纳更多功能
Scroll.ScrollBarThickness = 0
Scroll.Parent = Main
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 6)

-- 快速创建功能函数
local function AddFunc(name, desc, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 50)
    Btn.BackgroundColor3 = color
    Btn.BackgroundTransparency = 0.8
    Btn.Text = "<b>" .. name .. "</b>\n<font size='10'>" .. desc .. "</font>"
    Btn.RichText = true
    Btn.Font = Enum.Font.Gotham
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Parent = Scroll
    Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(callback)
end

--- 🔥 终极功能合集 ---

-- [1. 挂机系列]
AddFunc("挂机: 禁用3D渲染", "关闭画面, 手机极速降温", Color3.fromRGB(255, 60, 60), function()
    RunService:Set3dRenderingEnabled(false)
    RecoveryBtn.Visible = true
end)

RecoveryBtn.MouseButton1Click:Connect(function()
    RunService:Set3dRenderingEnabled(true)
    RecoveryBtn.Visible = false
end)

-- [2. 极致性能系列]
AddFunc("性能: 极致FPS增强", "移除阴影/材质/粒子/后期效果", Color3.fromRGB(60, 255, 60), function()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") then v:Destroy() end
    end
end)

AddFunc("物理: 冻结远端计算", "让远处的零件停止物理刷新", Color3.fromRGB(60, 200, 255), function()
    workspace.InterpolationThrottling = Enum.InterpolationThrottlingMode.Enabled
    settings().Physics.PhysicsEnvironmentalThrottle = 1
end)

-- [3. 内存与清理系列]
AddFunc("清理: 移除所有建筑", "【慎用】删除地图建筑, 只留地板", Color3.fromRGB(255, 150, 0), function()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and not Players:GetPlayerFromCharacter(v) then v:Destroy() end
    end
end)

AddFunc("清理: 深度内存回收", "强制Lua垃圾回收, 防止闪退", Color3.fromRGB(200, 60, 255), function()
    collectgarbage("collect")
end)

-- [4. 视觉与辅助系列]
AddFunc("辅助: 性能版透视 (ESP)", "显示玩家位置框, 减少找人负担", Color3.fromRGB(255, 255, 60), function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and not p.Character:FindFirstChild("ESPHighlight") then
            local hl = Instance.new("Highlight")
            hl.Name = "ESPHighlight"
            hl.FillColor = Color3.new(1, 0, 0)
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.Parent = p.Character
        end
    end
end)

AddFunc("视觉: 强制昼夜(12PM)", "固定光照时间, 减少光影变化卡顿", Color3.fromRGB(255, 255, 255), function()
    Lighting.ClockTime = 12
end)

-- [5. 交互系列]
AddFunc("界面: 纯净挂机模式", "隐藏游戏所有UI, 专注性能", Color3.fromRGB(100, 100, 100), function()
    for _, v in pairs(LP.PlayerGui:GetChildren()) do
        if v:IsA("ScreenGui") and v ~= ScreenGui then v.Enabled = false end
    end
end)

-- 面板控制
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(1, -55, 0.8, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
ToggleBtn.Text = "ZEN"
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local isOpen = false
local function Toggle()
    isOpen = not isOpen
    local targetPos = isOpen and UDim2.new(0.5, -140, 0.5, -225) or UDim2.new(0.5, -140, 1.2, 0)
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
end

ToggleBtn.MouseButton1Click:Connect(Toggle)
UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.L then Toggle() end end)

-- 实时监测数据更新
task.spawn(function()
    while true do
        local fps = math.floor(1/RunService.RenderStepped:Wait())
        local ping = "N/A"
        pcall(function() ping = LP:GetNetworkPing() * 1000 end)
        StatsLabel.Text = string.format("FPS: %d | Ping: %d ms", fps, math.floor(ping))
        task.wait(1)
    end
end)

