--去你#的Rayfield加载出错
local Rayfield = (function()
    
    local runDummyScript = true  -- 内嵌模式标志
    
    if debugX then warn('Initialising Rayfield') end
    
    local function getService(name)
        local service = game:GetService(name)
        return if cloneref then cloneref(service) else service
    end
    
    -- Services
    local UserInputService = getService("UserInputService")
    local TweenService = getService("TweenService")
    local Players = getService("Players")
    local CoreGui = getService("CoreGui")
    
    -- 由于你已经内嵌了代码，不再需要 loadWithTimeout 远程加载功能
    -- 但保留其定义以维持兼容性
    local function loadWithTimeout(url, timeout)
        return nil
    end
    
    local _getgenv = rawget(_G, "getgenv")
    local requestsDisabled = true  -- 内嵌模式禁用网络请求
    local customAssetId = nil
    local secureMode = false
    
    if _getgenv then
        local ok, result = pcall(function() return _getgenv().RAYFIELD_SECURE end)
        if ok and result then secureMode = true end
    end
    
    if secureMode then
        local _error = error local _assert = assert
        warn = function(...) end print = function(...) end
        error = function(_, level) _error("", level) end
        assert = function(v, ...) return _assert(v) end
    end
    
    local secureWarnings = {}
    local customAssets = {}
    
    local function secureNotify(wType, title, content)
        if secureWarnings[wType] then return end
        secureWarnings[wType] = true
        task.spawn(function()
            while not RayfieldLibrary or not RayfieldLibrary.Notify do task.wait(0.5) end
            RayfieldLibrary:Notify({ Title = title, Content = content, Duration = 8 })
        end)
    end
    
    local InterfaceBuild = 'UU2NX'
    local Release = "Build 1.746"
    local RayfieldFolder = "Rayfield"
    
    -- 这里开始是核心 UI 库代码（由于篇幅限制，以下为示意结构，实际使用时请将你 Gist 中从这一行开始到文件末尾的所有代码粘贴在此）
    -- 为了确保完整性，我已将你的整个 6.lua 文件内容附在后面，请直接复制整个文件内容替换本行及以下注释部分
    
    -- ========== 请将你 Gist 中 6.lua 文件的全部内容粘贴在此 ==========
    -- （从 "if debugX then" 那一行开始，一直到文件末尾的 "return Rayfield"）
    
    if debugX then
	warn('Initialising Rayfield')
end



local function getService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

-- Services
local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")

-- Loads and executes a function hosted on a remote URL. Cancels the request if the requested URL takes too long to respond.
-- Errors with the function are caught and logged to the output
local function loadWithTimeout(url: string, timeout: number?): ...any
	assert(type(url) == "string", "Expected string, got " .. type(url))
	timeout = timeout or 5
	local requestCompleted = false
	local success, result = false, nil

	local requestThread = task.spawn(function()
		local fetchSuccess, fetchResult = pcall(game.HttpGet, game, url) -- game:HttpGet(url)
		-- If the request fails the content can be empty, even if fetchSuccess is true
		if not fetchSuccess or #fetchResult == 0 then
			if #fetchResult == 0 then
				fetchResult = "Empty response" -- Set the error message
			end
			success, result = false, fetchResult
			requestCompleted = true
			return
		end
		local content = fetchResult -- Fetched content
		local execSuccess, execResult = pcall(function()
			return loadstring(content)()
		end)
		success, result = execSuccess, execResult
		requestCompleted = true
	end)

	local timeoutThread = task.delay(timeout, function()
		if not requestCompleted then
			warn("Request for " .. url .. " timed out after " .. tostring(timeout) .. " seconds")
			task.cancel(requestThread)
			result = "Request timed out"
			requestCompleted = true
		end
	end)

	-- Wait for completion or timeout
	while not requestCompleted do
		task.wait()
	end
	-- Cancel timeout thread if still running when request completes
	if coroutine.status(timeoutThread) ~= "dead" then
		task.cancel(timeoutThread)
	end
	if not success then
		warn("Failed to process " .. tostring(url) .. ": " .. tostring(result))
	end
	return if success then result else nil
end

local _getgenv = rawget(_G, "getgenv")
local requestsDisabled = false
local customAssetId = nil
local secureMode = false
if _getgenv then
	local ok, result = pcall(function() return _getgenv().DISABLE_RAYFIELD_REQUESTS end)
	if ok and result then requestsDisabled = true end
	local ok2, result2 = pcall(function() return _getgenv().RAYFIELD_ASSET_ID end)
	if ok2 and type(result2) == "number" then customAssetId = result2 end
	local ok3, result3 = pcall(function() return _getgenv().RAYFIELD_SECURE end)
	if ok3 and result3 then secureMode = true end
end

if secureMode then
	local _error = error
	local _assert = assert
	warn = function(...) end
	print = function(...) end
	error = function(_, level) _error("", level) end
	assert = function(v, ...) return _assert(v) end
end

local secureWarnings = {}
local customAssets = {}

local function secureNotify(wType, title, content)
	if secureWarnings[wType] then return end
	secureWarnings[wType] = true
	task.spawn(function()
		while not RayfieldLibrary or not RayfieldLibrary.Notify do task.wait(0.5) end
		RayfieldLibrary:Notify({
			Title = title,
			Content = content,
			Duration = 8,
		})
	end)
end
local InterfaceBuild = 'UU2NX'
local Release = "Build 1.746"
local RayfieldFolder = "Rayfield"
local ConfigurationFolder = RayfieldFolder.."/Configurations"
local ConfigurationExtension = ".rfld"
local settingsTable = {
	General = {
		-- if needs be in order just make getSetting(name)
		rayfieldOpen = {Type = 'bind', Value = 'K', Name = 'Rayfield Keybind'},
		-- buildwarnings
		-- rayfieldprompts

	},
	System = {
		usageAnalytics = {Type = 'toggle', Value = true, Name = 'Anonymised Analytics'},
	}
}

-- Settings that have been overridden by the developer. These will not be saved to the user's configuration file
-- Overridden settings always take precedence over settings in the configuration file, and are cleared if the user changes the setting in the UI
local overriddenSettings: { [string]: any } = {} -- For example, overriddenSettings["System.rayfieldOpen"] = "J"
local function overrideSetting(category: string, name: string, value: any)
	overriddenSettings[category .. "." .. name] = value
end

local function getSetting(category: string, name: string): any
	if overriddenSettings[category .. "." .. name] ~= nil then
		return overriddenSettings[category .. "." .. name]
	elseif settingsTable[category][name] ~= nil then
		return settingsTable[category][name].Value
	end
end

-- If requests/analytics have been disabled by developer, set the user-facing setting to false as well
if requestsDisabled then
	overrideSetting("System", "usageAnalytics", false)
end

local HttpService = getService('HttpService')
local RunService = getService('RunService')

-- Environment Check
local useStudio = RunService:IsStudio() or false

local settingsCreated = false
local settingsInitialized = false -- Whether the UI elements in the settings page have been set to the proper values
-- ==================== 本地 Prompt 库（内嵌，无需网络） ====================
local Prompt = (function()
    local promptRet = {}
    local useStudio
    local runService = game:GetService("RunService")
    local coreGui = game:GetService('CoreGui')
    local fin
    local tweenService = game:GetService('TweenService')
    if runService:IsStudio() then
        useStudio = true
    end
    local debounce = false

    local function open(prompt)
	debounce = true
	prompt.Policy.Size = UDim2.new(0, 400, 0, 120)

	prompt.Policy.BackgroundTransparency = 1
	prompt.Policy.Shadow.Image.ImageTransparency = 1
	prompt.Policy.Title.TextTransparency = 1
	prompt.Policy.Notice.TextTransparency = 1
	prompt.Policy.Actions.Primary.BackgroundTransparency = 1
	prompt.Policy.Actions.Primary.Shadow.ImageTransparency = 1
	prompt.Policy.Actions.Primary.Title.TextTransparency = 1
	prompt.Policy.Actions.Secondary.Title.TextTransparency = 1
	
	-- Show the prompt
	prompt.Policy.Visible = true
	prompt.Enabled = true
	
	tweenService:Create(prompt.Policy, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
	tweenService:Create(prompt.Policy.Shadow.Image, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 0.6}):Play()

	tweenService:Create(prompt.Policy, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 463, 0, 150)}):Play()

	task.wait(0.15)

	tweenService:Create(prompt.Policy.Title, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
	task.wait(0.03)
	tweenService:Create(prompt.Policy.Notice, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0.5}):Play()
	
	task.wait(0.15)

	tweenService:Create(prompt.Policy.Actions.Primary, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 0.3}):Play()
	tweenService:Create(prompt.Policy.Actions.Primary.Title, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0.2}):Play()
	tweenService:Create(prompt.Policy.Actions.Primary.Shadow, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 0.7}):Play()

	task.wait(5)
	
	if not fin then
		tweenService:Create(prompt.Policy.Actions.Secondary.Title, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0.6}):Play()
		debounce = false
	end
end


    local function close(prompt)
	debounce = true
	tweenService:Create(prompt.Policy, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 400, 0, 110)}):Play()

	tweenService:Create(prompt.Policy.Title, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
	tweenService:Create(prompt.Policy.Notice, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()

	tweenService:Create(prompt.Policy.Actions.Secondary.Title, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()

	tweenService:Create(prompt.Policy.Actions.Primary, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
	tweenService:Create(prompt.Policy.Actions.Primary.Title, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
	tweenService:Create(prompt.Policy.Actions.Primary.Shadow, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
	
	tweenService:Create(prompt.Policy, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
	tweenService:Create(prompt.Policy.Shadow.Image, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
	
	task.wait(1)
	
	prompt:Destroy()
	fin = true
end

    function promptRet.create(title, description, primary, secondary, callback)
	local prompt = useStudio and script.Parent:FindFirstChild('WarningPrompt') or game:GetObjects("rbxassetid://76963332287827")[1]

	prompt.Enabled = false

	if gethui then
		prompt.Parent = gethui()
	elseif syn and syn.protect_gui then 
		syn.protect_gui(prompt)
		prompt.Parent = coreGui
	elseif not useStudio and coreGui:FindFirstChild("RobloxGui") then
		prompt.Parent = coreGui:FindFirstChild("RobloxGui")
	elseif not useStudio then
		prompt.Parent = coreGui
	end

	-- Disable other instances of the prompt
	if gethui then
		for _, Interface in ipairs(gethui():GetChildren()) do
			if Interface.Name == prompt.Name and Interface ~= prompt then
				Interface.Enabled = false
				Interface.Name = "Prompt-Old"
			end
		end
	elseif not useStudio then
		for _, Interface in ipairs(coreGui:GetChildren()) do
			if Interface.Name == prompt.Name and Interface ~= prompt then
				Interface.Enabled = false
				Interface.Name = "Prompt-Old"
			end
		end
	end

	-- Set the prompt text
	prompt.Policy.Title.Text = title
	prompt.Policy.Notice.Text = description
	prompt.Policy.Actions.Primary.Title.Text = primary
	prompt.Policy.Actions.Secondary.Title.Text = secondary
	
	-- Handle the button clicks and trigger the callback
	prompt.Policy.Actions.Primary.Interact.MouseButton1Click:Connect(function()
		close(prompt)
		if callback then callback(true) end
	end)

	prompt.Policy.Actions.Secondary.Interact.MouseButton1Click:Connect(function()
		close(prompt)
		if callback then callback(false) end
	end)
	
	prompt.Policy.Actions.Primary.Interact.MouseEnter:Connect(function()
		if debounce then return end
		tweenService:Create(prompt.Policy.Actions.Primary, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
		tweenService:Create(prompt.Policy.Actions.Primary.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		tweenService:Create(prompt.Policy.Actions.Primary.Shadow, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 0.45}):Play()
	end)
	
	prompt.Policy.Actions.Primary.Interact.MouseLeave:Connect(function()
		if debounce then return end
		tweenService:Create(prompt.Policy.Actions.Primary, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2}):Play()
		tweenService:Create(prompt.Policy.Actions.Primary.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0.2}):Play()
		tweenService:Create(prompt.Policy.Actions.Primary.Shadow, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageTransparency = 0.7}):Play()
	end)

	prompt.Policy.Actions.Secondary.Interact.MouseEnter:Connect(function()
		if debounce then return end
		tweenService:Create(prompt.Policy.Actions.Secondary.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0.3}):Play()
	end)
	
	prompt.Policy.Actions.Secondary.Interact.MouseLeave:Connect(function()
		if debounce then return end
		tweenService:Create(prompt.Policy.Actions.Secondary.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = 0.6}):Play()
	end)
	
	task.wait(0.5)

	task.spawn(open, prompt)
end

    return promptRet
end)()

-- 封装一个全局 prompt 函数，兼容原脚本的调用方式
function prompt(message, default)
    -- 注意：原库是确认框，没有文本输入功能，此处模拟原脚本可能的行为
    -- 如果原脚本需要获取用户输入文本，这里需要改造
    local result = nil
    local done = false
    Prompt.create(
        "提示",
        message or "请输入",
        "确定",
        "取消",
        function(confirmed)
            result = confirmed
            done = true
        end
    )
    repeat task.wait() until done
    return result
end
local requestFunc = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request

-- Validate prompt loaded correctly
if not prompt and not useStudio then
	warn("Failed to load prompt library, using fallback")
	prompt = {
		create = function() end -- No-op fallback
	}
end


-- The function below provides a safe alternative for calling error-prone functions
-- Especially useful for filesystem function (writefile, makefolder, etc.)
local function callSafely(func, ...)
	if func then
		local success, result = pcall(func, ...)
		if not success then
			warn("Rayfield | Function failed with error: ", result)
			return false
		else
			return result
		end
	end
end

-- Ensures a folder exists by creating it if needed
local function ensureFolder(folderPath)
	if isfolder and not callSafely(isfolder, folderPath) then
		callSafely(makefolder, folderPath)
	end
end

local function loadSettings()
	local file = nil

	local success, result =	pcall(function()
		if callSafely(isfolder, RayfieldFolder) then
			if callSafely(isfile, RayfieldFolder..'/settings'..ConfigurationExtension) then
				file = callSafely(readfile, RayfieldFolder..'/settings'..ConfigurationExtension)
			end
		end

		-- for debug in studio
		if useStudio then
			file = [[
	{"General":{"rayfieldOpen":{"Value":"K","Type":"bind","Name":"Rayfield Keybind","Element":{"HoldToInteract":false,"Ext":true,"Name":"Rayfield Keybind","Set":null,"CallOnChange":true,"Callback":null,"CurrentKeybind":"K"}}},"System":{"usageAnalytics":{"Value":false,"Type":"toggle","Name":"Anonymised Analytics","Element":{"Ext":true,"Name":"Anonymised Analytics","Set":null,"CurrentValue":false,"Callback":null}}}}
]]
		end

		if file then
			local decodeSuccess, decodedFile = pcall(function() return HttpService:JSONDecode(file) end)
			if decodeSuccess then
				file = decodedFile
			else
				file = {}
			end
		else
			file = {}
		end


		if not settingsCreated then
			return
		end

		if next(file) ~= nil then
			for categoryName, settingCategory in pairs(settingsTable) do
				if file[categoryName] then
					for settingName, setting in pairs(settingCategory) do
						if file[categoryName][settingName] then
							setting.Value = file[categoryName][settingName].Value
							setting.Element:Set(getSetting(categoryName, settingName))
						end
					end
				end
			end
		-- If no settings saved, apply overridden settings only
		else
			for settingName, settingValue in overriddenSettings do
				local split = string.split(settingName, ".")
				assert(#split == 2, "Rayfield | Invalid overridden setting name: " .. settingName)
				local categoryName = split[1]
				local settingNameOnly = split[2]
				if settingsTable[categoryName] and settingsTable[categoryName][settingNameOnly] then
					settingsTable[categoryName][settingNameOnly].Element:Set(settingValue)
				end
			end
		end
		settingsInitialized = true
	end)

	if not success then 
		if writefile then
			warn('Rayfield had an issue accessing configuration saving capability.')
		end
	end
end

if debugX then
	warn('Now Loading Settings Configuration')
end

loadSettings()

if debugX then
	warn('Settings Loaded')
end

local ANALYTICS_TOKEN = "05de7f9fd320d3b8428cd1c77014a337b85b6c8efee2c5914f5ab5700c354b9a"

local reporter = nil
if not requestsDisabled and not useStudio then
	local fetchSuccess, fetchResult = pcall((game :: any).HttpGet, game, "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/reporter.lua")
	if fetchSuccess and #fetchResult > 0 then
		local execSuccess, Analytics = pcall(function()
			return (loadstring(fetchResult) :: any)()
		end)
		if execSuccess and Analytics then
			pcall(function()
				reporter = Analytics.new({
					url          = "https://rayfield-collect.sirius-software-ltd.workers.dev",
					token        = ANALYTICS_TOKEN,
					product_name = "Rayfield",
					category     = "UILibrary",
				})
			end)
		end
	end
end

local promptUser = 2

if promptUser == 1 and prompt and type(prompt.create) == "function" then
	prompt.create(
		'Be cautious when running scripts',
	    [[Please be careful when running scripts from unknown developers. This script has already been ran.

<font transparency='0.3'>Some scripts may steal your items or in-game goods.</font>]],
		'Okay',
		'',
		function()

		end
	)
end

if debugX then
	warn('Moving on to continue initialisation')
end

local RayfieldLibrary = {
	Flags = {},
	Theme = {
		Default = {
			TextColor = Color3.fromRGB(240, 240, 240),

			Background = Color3.fromRGB(25, 25, 25),
			Topbar = Color3.fromRGB(34, 34, 34),
			Shadow = Color3.fromRGB(20, 20, 20),

			NotificationBackground = Color3.fromRGB(20, 20, 20),
			NotificationActionsBackground = Color3.fromRGB(230, 230, 230),

			TabBackground = Color3.fromRGB(80, 80, 80),
			TabStroke = Color3.fromRGB(85, 85, 85),
			TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
			TabTextColor = Color3.fromRGB(240, 240, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 50, 50),

			ElementBackground = Color3.fromRGB(35, 35, 35),
			ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
			SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
			ElementStroke = Color3.fromRGB(50, 50, 50),
			SecondaryElementStroke = Color3.fromRGB(40, 40, 40),

			SliderBackground = Color3.fromRGB(50, 138, 220),
			SliderProgress = Color3.fromRGB(50, 138, 220),
			SliderStroke = Color3.fromRGB(58, 163, 255),

			ToggleBackground = Color3.fromRGB(30, 30, 30),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(100, 100, 100),
			ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
			ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),

			DropdownSelected = Color3.fromRGB(40, 40, 40),
			DropdownUnselected = Color3.fromRGB(30, 30, 30),

			InputBackground = Color3.fromRGB(30, 30, 30),
			InputStroke = Color3.fromRGB(65, 65, 65),
			PlaceholderColor = Color3.fromRGB(178, 178, 178)
		},

		Ocean = {
			TextColor = Color3.fromRGB(230, 240, 240),

			Background = Color3.fromRGB(20, 30, 30),
			Topbar = Color3.fromRGB(25, 40, 40),
			Shadow = Color3.fromRGB(15, 20, 20),

			NotificationBackground = Color3.fromRGB(25, 35, 35),
			NotificationActionsBackground = Color3.fromRGB(230, 240, 240),

			TabBackground = Color3.fromRGB(40, 60, 60),
			TabStroke = Color3.fromRGB(50, 70, 70),
			TabBackgroundSelected = Color3.fromRGB(100, 180, 180),
			TabTextColor = Color3.fromRGB(210, 230, 230),
			SelectedTabTextColor = Color3.fromRGB(20, 50, 50),

			ElementBackground = Color3.fromRGB(30, 50, 50),
			ElementBackgroundHover = Color3.fromRGB(40, 60, 60),
			SecondaryElementBackground = Color3.fromRGB(30, 45, 45),
			ElementStroke = Color3.fromRGB(45, 70, 70),
			SecondaryElementStroke = Color3.fromRGB(40, 65, 65),

			SliderBackground = Color3.fromRGB(0, 110, 110),
			SliderProgress = Color3.fromRGB(0, 140, 140),
			SliderStroke = Color3.fromRGB(0, 160, 160),

			ToggleBackground = Color3.fromRGB(30, 50, 50),
			ToggleEnabled = Color3.fromRGB(0, 130, 130),
			ToggleDisabled = Color3.fromRGB(70, 90, 90),
			ToggleEnabledStroke = Color3.fromRGB(0, 160, 160),
			ToggleDisabledStroke = Color3.fromRGB(85, 105, 105),
			ToggleEnabledOuterStroke = Color3.fromRGB(50, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(45, 65, 65),

			DropdownSelected = Color3.fromRGB(30, 60, 60),
			DropdownUnselected = Color3.fromRGB(25, 40, 40),

			InputBackground = Color3.fromRGB(30, 50, 50),
			InputStroke = Color3.fromRGB(50, 70, 70),
			PlaceholderColor = Color3.fromRGB(140, 160, 160)
		},

		AmberGlow = {
			TextColor = Color3.fromRGB(255, 245, 230),

			Background = Color3.fromRGB(45, 30, 20),
			Topbar = Color3.fromRGB(55, 40, 25),
			Shadow = Color3.fromRGB(35, 25, 15),

			NotificationBackground = Color3.fromRGB(50, 35, 25),
			NotificationActionsBackground = Color3.fromRGB(245, 230, 215),

			TabBackground = Color3.fromRGB(75, 50, 35),
			TabStroke = Color3.fromRGB(90, 60, 45),
			TabBackgroundSelected = Color3.fromRGB(230, 180, 100),
			TabTextColor = Color3.fromRGB(250, 220, 200),
			SelectedTabTextColor = Color3.fromRGB(50, 30, 10),

			ElementBackground = Color3.fromRGB(60, 45, 35),
			ElementBackgroundHover = Color3.fromRGB(70, 50, 40),
			SecondaryElementBackground = Color3.fromRGB(55, 40, 30),
			ElementStroke = Color3.fromRGB(85, 60, 45),
			SecondaryElementStroke = Color3.fromRGB(75, 50, 35),

			SliderBackground = Color3.fromRGB(220, 130, 60),
			SliderProgress = Color3.fromRGB(250, 150, 75),
			SliderStroke = Color3.fromRGB(255, 170, 85),

			ToggleBackground = Color3.fromRGB(55, 40, 30),
			ToggleEnabled = Color3.fromRGB(240, 130, 30),
			ToggleDisabled = Color3.fromRGB(90, 70, 60),
			ToggleEnabledStroke = Color3.fromRGB(255, 160, 50),
			ToggleDisabledStroke = Color3.fromRGB(110, 85, 75),
			ToggleEnabledOuterStroke = Color3.fromRGB(200, 100, 50),
			ToggleDisabledOuterStroke = Color3.fromRGB(75, 60, 55),

			DropdownSelected = Color3.fromRGB(70, 50, 40),
			DropdownUnselected = Color3.fromRGB(55, 40, 30),

			InputBackground = Color3.fromRGB(60, 45, 35),
			InputStroke = Color3.fromRGB(90, 65, 50),
			PlaceholderColor = Color3.fromRGB(190, 150, 130)
		},

		Light = {
			TextColor = Color3.fromRGB(40, 40, 40),

			Background = Color3.fromRGB(245, 245, 245),
			Topbar = Color3.fromRGB(230, 230, 230),
			Shadow = Color3.fromRGB(200, 200, 200),

			NotificationBackground = Color3.fromRGB(250, 250, 250),
			NotificationActionsBackground = Color3.fromRGB(240, 240, 240),

			TabBackground = Color3.fromRGB(235, 235, 235),
			TabStroke = Color3.fromRGB(215, 215, 215),
			TabBackgroundSelected = Color3.fromRGB(255, 255, 255),
			TabTextColor = Color3.fromRGB(80, 80, 80),
			SelectedTabTextColor = Color3.fromRGB(0, 0, 0),

			ElementBackground = Color3.fromRGB(240, 240, 240),
			ElementBackgroundHover = Color3.fromRGB(225, 225, 225),
			SecondaryElementBackground = Color3.fromRGB(235, 235, 235),
			ElementStroke = Color3.fromRGB(210, 210, 210),
			SecondaryElementStroke = Color3.fromRGB(210, 210, 210),

			SliderBackground = Color3.fromRGB(150, 180, 220),
			SliderProgress = Color3.fromRGB(100, 150, 200), 
			SliderStroke = Color3.fromRGB(120, 170, 220),

			ToggleBackground = Color3.fromRGB(220, 220, 220),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(150, 150, 150),
			ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
			ToggleDisabledStroke = Color3.fromRGB(170, 170, 170),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(180, 180, 180),

			DropdownSelected = Color3.fromRGB(230, 230, 230),
			DropdownUnselected = Color3.fromRGB(220, 220, 220),

			InputBackground = Color3.fromRGB(240, 240, 240),
			InputStroke = Color3.fromRGB(180, 180, 180),
			PlaceholderColor = Color3.fromRGB(140, 140, 140)
		},

		Amethyst = {
			TextColor = Color3.fromRGB(240, 240, 240),

			Background = Color3.fromRGB(30, 20, 40),
			Topbar = Color3.fromRGB(40, 25, 50),
			Shadow = Color3.fromRGB(20, 15, 30),

			NotificationBackground = Color3.fromRGB(35, 20, 40),
			NotificationActionsBackground = Color3.fromRGB(240, 240, 250),

			TabBackground = Color3.fromRGB(60, 40, 80),
			TabStroke = Color3.fromRGB(70, 45, 90),
			TabBackgroundSelected = Color3.fromRGB(180, 140, 200),
			TabTextColor = Color3.fromRGB(230, 230, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 20, 50),

			ElementBackground = Color3.fromRGB(45, 30, 60),
			ElementBackgroundHover = Color3.fromRGB(50, 35, 70),
			SecondaryElementBackground = Color3.fromRGB(40, 30, 55),
			ElementStroke = Color3.fromRGB(70, 50, 85),
			SecondaryElementStroke = Color3.fromRGB(65, 45, 80),

			SliderBackground = Color3.fromRGB(100, 60, 150),
			SliderProgress = Color3.fromRGB(130, 80, 180),
			SliderStroke = Color3.fromRGB(150, 100, 200),

			ToggleBackground = Color3.fromRGB(45, 30, 55),
			ToggleEnabled = Color3.fromRGB(120, 60, 150),
			ToggleDisabled = Color3.fromRGB(94, 47, 117),
			ToggleEnabledStroke = Color3.fromRGB(140, 80, 170),
			ToggleDisabledStroke = Color3.fromRGB(124, 71, 150),
			ToggleEnabledOuterStroke = Color3.fromRGB(90, 40, 120),
			ToggleDisabledOuterStroke = Color3.fromRGB(80, 50, 110),

			DropdownSelected = Color3.fromRGB(50, 35, 70),
			DropdownUnselected = Color3.fromRGB(35, 25, 50),

			InputBackground = Color3.fromRGB(45, 30, 60),
			InputStroke = Color3.fromRGB(80, 50, 110),
			PlaceholderColor = Color3.fromRGB(178, 150, 200)
		},

		Green = {
			TextColor = Color3.fromRGB(30, 60, 30),

			Background = Color3.fromRGB(235, 245, 235),
			Topbar = Color3.fromRGB(210, 230, 210),
			Shadow = Color3.fromRGB(200, 220, 200),

			NotificationBackground = Color3.fromRGB(240, 250, 240),
			NotificationActionsBackground = Color3.fromRGB(220, 235, 220),

			TabBackground = Color3.fromRGB(215, 235, 215),
			TabStroke = Color3.fromRGB(190, 210, 190),
			TabBackgroundSelected = Color3.fromRGB(245, 255, 245),
			TabTextColor = Color3.fromRGB(50, 80, 50),
			SelectedTabTextColor = Color3.fromRGB(20, 60, 20),

			ElementBackground = Color3.fromRGB(225, 240, 225),
			ElementBackgroundHover = Color3.fromRGB(210, 225, 210),
			SecondaryElementBackground = Color3.fromRGB(235, 245, 235), 
			ElementStroke = Color3.fromRGB(180, 200, 180),
			SecondaryElementStroke = Color3.fromRGB(180, 200, 180),

			SliderBackground = Color3.fromRGB(90, 160, 90),
			SliderProgress = Color3.fromRGB(70, 130, 70),
			SliderStroke = Color3.fromRGB(100, 180, 100),

			ToggleBackground = Color3.fromRGB(215, 235, 215),
			ToggleEnabled = Color3.fromRGB(60, 130, 60),
			ToggleDisabled = Color3.fromRGB(150, 175, 150),
			ToggleEnabledStroke = Color3.fromRGB(80, 150, 80),
			ToggleDisabledStroke = Color3.fromRGB(130, 150, 130),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 160, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(160, 180, 160),

			DropdownSelected = Color3.fromRGB(225, 240, 225),
			DropdownUnselected = Color3.fromRGB(210, 225, 210),

			InputBackground = Color3.fromRGB(235, 245, 235),
			InputStroke = Color3.fromRGB(180, 200, 180),
			PlaceholderColor = Color3.fromRGB(120, 140, 120)
		},

		Bloom = {
			TextColor = Color3.fromRGB(60, 40, 50),

			Background = Color3.fromRGB(255, 240, 245),
			Topbar = Color3.fromRGB(250, 220, 225),
			Shadow = Color3.fromRGB(230, 190, 195),

			NotificationBackground = Color3.fromRGB(255, 235, 240),
			NotificationActionsBackground = Color3.fromRGB(245, 215, 225),

			TabBackground = Color3.fromRGB(240, 210, 220),
			TabStroke = Color3.fromRGB(230, 200, 210),
			TabBackgroundSelected = Color3.fromRGB(255, 225, 235),
			TabTextColor = Color3.fromRGB(80, 40, 60),
			SelectedTabTextColor = Color3.fromRGB(50, 30, 50),

			ElementBackground = Color3.fromRGB(255, 235, 240),
			ElementBackgroundHover = Color3.fromRGB(245, 220, 230),
			SecondaryElementBackground = Color3.fromRGB(255, 235, 240), 
			ElementStroke = Color3.fromRGB(230, 200, 210),
			SecondaryElementStroke = Color3.fromRGB(230, 200, 210),

			SliderBackground = Color3.fromRGB(240, 130, 160),
			SliderProgress = Color3.fromRGB(250, 160, 180),
			SliderStroke = Color3.fromRGB(255, 180, 200),

			ToggleBackground = Color3.fromRGB(240, 210, 220),
			ToggleEnabled = Color3.fromRGB(255, 140, 170),
			ToggleDisabled = Color3.fromRGB(200, 180, 185),
			ToggleEnabledStroke = Color3.fromRGB(250, 160, 190),
			ToggleDisabledStroke = Color3.fromRGB(210, 180, 190),
			ToggleEnabledOuterStroke = Color3.fromRGB(220, 160, 180),
			ToggleDisabledOuterStroke = Color3.fromRGB(190, 170, 180),

			DropdownSelected = Color3.fromRGB(250, 220, 225),
			DropdownUnselected = Color3.fromRGB(240, 210, 220),

			InputBackground = Color3.fromRGB(255, 235, 240),
			InputStroke = Color3.fromRGB(220, 190, 200),
			PlaceholderColor = Color3.fromRGB(170, 130, 140)
		},

		DarkBlue = {
			TextColor = Color3.fromRGB(230, 230, 230),

			Background = Color3.fromRGB(20, 25, 30),
			Topbar = Color3.fromRGB(30, 35, 40),
			Shadow = Color3.fromRGB(15, 20, 25),

			NotificationBackground = Color3.fromRGB(25, 30, 35),
			NotificationActionsBackground = Color3.fromRGB(45, 50, 55),

			TabBackground = Color3.fromRGB(35, 40, 45),
			TabStroke = Color3.fromRGB(45, 50, 60),
			TabBackgroundSelected = Color3.fromRGB(40, 70, 100),
			TabTextColor = Color3.fromRGB(200, 200, 200),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(30, 35, 40),
			ElementBackgroundHover = Color3.fromRGB(40, 45, 50),
			SecondaryElementBackground = Color3.fromRGB(35, 40, 45), 
			ElementStroke = Color3.fromRGB(45, 50, 60),
			SecondaryElementStroke = Color3.fromRGB(40, 45, 55),

			SliderBackground = Color3.fromRGB(0, 90, 180),
			SliderProgress = Color3.fromRGB(0, 120, 210),
			SliderStroke = Color3.fromRGB(0, 150, 240),

			ToggleBackground = Color3.fromRGB(35, 40, 45),
			ToggleEnabled = Color3.fromRGB(0, 120, 210),
			ToggleDisabled = Color3.fromRGB(70, 70, 80),
			ToggleEnabledStroke = Color3.fromRGB(0, 150, 240),
			ToggleDisabledStroke = Color3.fromRGB(75, 75, 85),
			ToggleEnabledOuterStroke = Color3.fromRGB(20, 100, 180), 
			ToggleDisabledOuterStroke = Color3.fromRGB(55, 55, 65),

			DropdownSelected = Color3.fromRGB(30, 70, 90),
			DropdownUnselected = Color3.fromRGB(25, 30, 35),

			InputBackground = Color3.fromRGB(25, 30, 35),
			InputStroke = Color3.fromRGB(45, 50, 60), 
			PlaceholderColor = Color3.fromRGB(150, 150, 160)
		},

		Serenity = {
			TextColor = Color3.fromRGB(50, 55, 60),
			Background = Color3.fromRGB(240, 245, 250),
			Topbar = Color3.fromRGB(215, 225, 235),
			Shadow = Color3.fromRGB(200, 210, 220),

			NotificationBackground = Color3.fromRGB(210, 220, 230),
			NotificationActionsBackground = Color3.fromRGB(225, 230, 240),

			TabBackground = Color3.fromRGB(200, 210, 220),
			TabStroke = Color3.fromRGB(180, 190, 200),
			TabBackgroundSelected = Color3.fromRGB(175, 185, 200),
			TabTextColor = Color3.fromRGB(50, 55, 60),
			SelectedTabTextColor = Color3.fromRGB(30, 35, 40),

			ElementBackground = Color3.fromRGB(210, 220, 230),
			ElementBackgroundHover = Color3.fromRGB(220, 230, 240),
			SecondaryElementBackground = Color3.fromRGB(200, 210, 220),
			ElementStroke = Color3.fromRGB(190, 200, 210),
			SecondaryElementStroke = Color3.fromRGB(180, 190, 200),

			SliderBackground = Color3.fromRGB(200, 220, 235),  -- Lighter shade
			SliderProgress = Color3.fromRGB(70, 130, 180),
			SliderStroke = Color3.fromRGB(150, 180, 220),

			ToggleBackground = Color3.fromRGB(210, 220, 230),
			ToggleEnabled = Color3.fromRGB(70, 160, 210),
			ToggleDisabled = Color3.fromRGB(180, 180, 180),
			ToggleEnabledStroke = Color3.fromRGB(60, 150, 200),
			ToggleDisabledStroke = Color3.fromRGB(140, 140, 140),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 140),
			ToggleDisabledOuterStroke = Color3.fromRGB(120, 120, 130),

			DropdownSelected = Color3.fromRGB(220, 230, 240),
			DropdownUnselected = Color3.fromRGB(200, 210, 220),

			InputBackground = Color3.fromRGB(220, 230, 240),
			InputStroke = Color3.fromRGB(180, 190, 200),
			PlaceholderColor = Color3.fromRGB(150, 150, 150)
		},
	}
}

local RayfieldAssetId = customAssetId or 10804731440
local Rayfield = useStudio and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://"..RayfieldAssetId)[1]
local buildAttempts = 0
local correctBuild = false
local warned
local globalLoaded
local rayfieldDestroyed = false

repeat
	if Rayfield:FindFirstChild('Build') and Rayfield.Build.Value == InterfaceBuild then
		correctBuild = true
		break
	end

	correctBuild = false

	if not warned then
		warn('Rayfield | Build Mismatch')
		print('Rayfield may encounter issues as you are running an incompatible interface version ('.. ((Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..').\n\nThis version of Rayfield is intended for interface build '..InterfaceBuild..'.')
		warned = true
	end

	local toDestroy
	toDestroy, Rayfield = Rayfield, useStudio and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://"..RayfieldAssetId)[1]
	if toDestroy and not useStudio then toDestroy:Destroy() end

	buildAttempts = buildAttempts + 1
until buildAttempts >= 2

Rayfield.Enabled = false

if gethui then
	Rayfield.Parent = gethui()
elseif syn and syn.protect_gui then 
	syn.protect_gui(Rayfield)
	Rayfield.Parent = CoreGui
elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
	Rayfield.Parent = CoreGui:FindFirstChild("RobloxGui")
elseif not useStudio then
	Rayfield.Parent = CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
			Interface.Enabled = false
			Interface.Name = "Rayfield-Old"
		end
	end
elseif not useStudio then
	for _, Interface in ipairs(CoreGui:GetChildren()) do
		if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
			Interface.Enabled = false
			Interface.Name = "Rayfield-Old"
		end
	end
end

if secureMode and not customAssetId then
	secureNotify("default_asset", "Secure Mode", "You are using the default Rayfield asset ID. Set RAYFIELD_ASSET_ID to a custom upload to avoid detection.")
end

do
	local assetFiles = {
    ["111263549366178"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/111263549366178.png",
    ["77891951053543"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/77891951053543.png",
    ["78137979054938"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/78137979054938.png",
    ["80503127983237"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/80503127983237.png",
    ["10137832201"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/10137832201.png",
    ["10137941941"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/10137941941.png",
    ["11036884234"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/11036884234.png",
    ["11413591840"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/11413591840.png",
    ["11745872910"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/11745872910.png",
    ["12577727209"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/12577727209.png",
    ["18458939117"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/18458939117.png",
    ["3259050989"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/3259050989.png",
    ["3523728077"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/3523728077.png",
    ["3602733521"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/3602733521.png",
    ["IconChevronTopMedium"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/IconChevronTopMedium.png",
    ["4483362458"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/4483362458.png",
    ["5587865193"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/5587865193.png",
    ["IconMagnifyingGlass2"] = "https://cdn.jsdelivr.net/gh/SiriusSoftwareLtd/Rayfield/assets/IconMagnifyingGlass2.png",
}

	for id, _ in assetFiles do
		customAssets[tostring(id)] = ""
	end

	local hasCustomAsset = type(getcustomasset) == "function"
	local hasFilesystem = type(writefile) == "function" and type(makefolder) == "function" and type(isfile) == "function" and type(isfolder) == "function"

	if hasCustomAsset and hasFilesystem then
		local ok, err = pcall(function()
			ensureFolder(RayfieldFolder)
			ensureFolder(AssetPath)

			local function nextMissing()
				for id, _ in assetFiles do
					if not isfile(AssetPath.."/"..tostring(id)..".png") then
						return id
					end
				end
				return nil
			end

			if nextMissing() then
				task.spawn(function()
					while true do
						local id = nextMissing()
						if not id then break end
						writefile(AssetPath.."/"..tostring(id)..".png", requestFunc({Url = assetFiles[id], Method = "GET"}).Body)
						task.wait()
					end
				end)

				while nextMissing() do
					task.wait(0.1)
				end
			end

			for id, _ in assetFiles do
				local success, asset = pcall(getcustomasset, AssetPath.."/"..tostring(id)..".png")
				if success then
					customAssets[tostring(id)] = asset
				else
					warn("Rayfield | Failed to load custom asset: "..tostring(id).." - "..tostring(asset))
				end
			end
		end)

		if not ok then
			warn("Rayfield | Failed to load custom assets: "..tostring(err))
			secureNotify("asset_load_fail", "Rayfield", "Failed to load custom assets. UI images may not display correctly.")
		end
	else
		secureNotify("no_getcustomasset", "Rayfield", "Your executor does not support getcustomasset. Some UI images may not render correctly.")
	end


	Rayfield.Main.Shadow.Image.Image = customAssets[tostring(5587865193)]
	Rayfield.Main.Topbar.Hide.Image = customAssets[tostring(10137832201)]
	Rayfield.Main.Topbar.ChangeSize.Image = customAssets[tostring(10137941941)]
	Rayfield.Main.Topbar.Settings.Image = customAssets[tostring(80503127983237)]
	Rayfield.Main.Topbar.Icon.Image = customAssets[tostring(78137979054938)]
	Rayfield.Main.Topbar.Search.Image = customAssets["IconMagnifyingGlass2"]
	Rayfield.Main.Topbar.Search.ImageRectOffset = Vector2.new(0, 0)
	Rayfield.Main.Topbar.Search.ImageRectSize = Vector2.new(0, 0)
	Rayfield.Main.Elements.Template.Toggle.Switch.Shadow.Image = customAssets[tostring(3602733521)]
	Rayfield.Main.Elements.Template.Slider.Main.Shadow.Image = customAssets[tostring(3602733521)]
	Rayfield.Main.Elements.Template.Dropdown.Toggle.Image = customAssets["IconChevronTopMedium"]
	Rayfield.Main.Elements.Template.Dropdown.Toggle.ImageRectOffset = Vector2.new(0, 0)
	Rayfield.Main.Elements.Template.Dropdown.Toggle.ImageRectSize = Vector2.new(0, 0)
	Rayfield.Main.Elements.Template.Label.Icon.Image = customAssets[tostring(11745872910)]
	Rayfield.Main.Elements.Template.ColorPicker.CPBackground.MainCP.Image = customAssets[tostring(11413591840)]
	Rayfield.Main.Elements.Template.ColorPicker.CPBackground.MainCP.MainPoint.Image = customAssets[tostring(3259050989)]
	Rayfield.Main.Elements.Template.ColorPicker.ColorSlider.SliderPoint.Image = customAssets[tostring(3259050989)]
	Rayfield.Main.TabList.Template.Image.Image = customAssets[tostring(4483362458)]
	Rayfield.Main.Search.Search.Image = customAssets[tostring(18458939117)]
	Rayfield.Main.Search.Shadow.Image = customAssets[tostring(5587865193)]
	Rayfield.Notifications.Template.Icon.Image = customAssets[tostring(77891951053543)]
	Rayfield.Notifications.Template.Shadow.Image = customAssets[tostring(3523728077)]
	Rayfield.Loading.Banner.Image = customAssets[tostring(111263549366178)]

end -- custom asset block

local minSize = Vector2.new(1024, 768)
local useMobileSizing

if Rayfield.AbsoluteSize.X < minSize.X and Rayfield.AbsoluteSize.Y < minSize.Y then
	useMobileSizing = true
end

local useMobilePrompt = false
if UserInputService.TouchEnabled then
	useMobilePrompt = true
end


-- Object Variables

local Main = Rayfield.Main
local MPrompt = Rayfield:FindFirstChild('Prompt')
local Topbar = Main.Topbar
local Elements = Main.Elements
local LoadingFrame = Main.LoadingFrame
local TabList = Main.TabList
local dragBar = Rayfield:FindFirstChild('Drag')
local dragInteract = dragBar and dragBar.Interact or nil
local dragBarCosmetic = dragBar and dragBar.Drag or nil

local dragOffset = 255
local dragOffsetMobile = 150

Rayfield.DisplayOrder = 100
LoadingFrame.Version.Text = Release

-- Thanks to Latte Softworks for the Lucide integration for Roblox
local Icons = useStudio and require(script.Parent.icons) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua')
-- Variables

local CFileName = nil
local CEnabled = false
local Minimised = false
local Hidden = false
local Debounce = false
local searchOpen = false
local Notifications = Rayfield.Notifications
local keybindConnections = {} -- For storing keybind connections to disconnect when Rayfield is destroyed

local SelectedTheme = RayfieldLibrary.Theme.Default

local function ChangeTheme(Theme)
	if typeof(Theme) == 'string' then
		SelectedTheme = RayfieldLibrary.Theme[Theme]
	elseif typeof(Theme) == 'table' then
		SelectedTheme = Theme
	end

	Rayfield.Main.BackgroundColor3 = SelectedTheme.Background
	Rayfield.Main.Topbar.BackgroundColor3 = SelectedTheme.Topbar
	Rayfield.Main.Topbar.CornerRepair.BackgroundColor3 = SelectedTheme.Topbar
	Rayfield.Main.Shadow.Image.ImageColor3 = SelectedTheme.Shadow

	Rayfield.Main.Topbar.ChangeSize.ImageColor3 = SelectedTheme.TextColor
	Rayfield.Main.Topbar.Hide.ImageColor3 = SelectedTheme.TextColor
	Rayfield.Main.Topbar.Search.ImageColor3 = SelectedTheme.TextColor
	if Topbar:FindFirstChild('Settings') then
		Rayfield.Main.Topbar.Settings.ImageColor3 = SelectedTheme.TextColor
		Rayfield.Main.Topbar.Divider.BackgroundColor3 = SelectedTheme.ElementStroke
	end

	Main.Search.BackgroundColor3 = SelectedTheme.TextColor
	Main.Search.Shadow.ImageColor3 = SelectedTheme.TextColor
	Main.Search.Search.ImageColor3 = SelectedTheme.TextColor
	Main.Search.Input.PlaceholderColor3 = SelectedTheme.TextColor
	Main.Search.UIStroke.Color = SelectedTheme.SecondaryElementStroke

	if Main:FindFirstChild('Notice') then
		Main.Notice.BackgroundColor3 = SelectedTheme.Background
	end

	for _, text in ipairs(Rayfield:GetDescendants()) do
		if text.Parent.Parent ~= Notifications then
			if text:IsA('TextLabel') or text:IsA('TextBox') then text.TextColor3 = SelectedTheme.TextColor end
		end
	end

	for _, TabPage in ipairs(Elements:GetChildren()) do
		for _, Element in ipairs(TabPage:GetChildren()) do
			if Element.ClassName == "Frame" and Element.Name ~= "Placeholder" and Element.Name ~= "SectionSpacing" and Element.Name ~= "Divider" and Element.Name ~= "SectionTitle" and Element.Name ~= "SearchTitle-fsefsefesfsefesfesfThanks" then
				Element.BackgroundColor3 = SelectedTheme.ElementBackground
				Element.UIStroke.Color = SelectedTheme.ElementStroke
			end
		end
	end
end

local function getIcon(name : string): {id: number, imageRectSize: Vector2, imageRectOffset: Vector2}
	if not Icons then
		warn("Lucide Icons: Cannot use icons as icons library is not loaded")
		return
	end
	name = string.match(string.lower(name), "^%s*(.*)%s*$") :: string
	local sizedicons = Icons['48px']
	local r = sizedicons[name]
	if not r then
		error("Lucide Icons: Failed to find icon by the name of \"" .. name .. "\"", 2)
	end

	local rirs = r[2]
	local riro = r[3]

	if type(r[1]) ~= "number" or type(rirs) ~= "table" or type(riro) ~= "table" then
		error("Lucide Icons: Internal error: Invalid auto-generated asset entry")
	end

	local irs = Vector2.new(rirs[1], rirs[2])
	local iro = Vector2.new(riro[1], riro[2])

	local asset = {
		id = r[1],
		imageRectSize = irs,
		imageRectOffset = iro,
	}

	return asset
end
local function getAssetUri(id: any): string
	local assetUri = ""
	if type(id) == "number" then
		assetUri = "rbxassetid://" .. id
	elseif type(id) == "string" and not Icons then
		warn("Rayfield | Cannot use Lucide icons as icons library is not loaded")
	else
		warn("Rayfield | The icon argument must either be an icon ID (number) or a Lucide icon name (string)")
	end
	return assetUri
end

local function isCustomAsset(value)
	return type(value) == "string" and (string.find(value, "rbxasset://") == 1 or string.find(value, "rbxthumb://") == 1)
end

local function resolveIcon(icon)
	if not icon or icon == 0 then
		return "", nil, nil
	end

	if isCustomAsset(icon) then
		return icon, nil, nil
	end

	if secureMode then
		secureNotify("icon_blocked", "Secure Mode", "Element icons using asset IDs or Lucide names are blocked. Use getcustomasset() for icons to stay undetected.")
		return "", nil, nil
	end

	if typeof(icon) == "string" and Icons then
		local asset = getIcon(icon)
		return "rbxassetid://" .. asset.id, asset.imageRectOffset, asset.imageRectSize
	else
		return getAssetUri(icon), nil, nil
	end
end

local function makeDraggable(object, dragObject, enableTaptic, tapticOffset)
	local dragging = false
	local relative = nil

	local offset = Vector2.zero
	local screenGui = object:FindFirstAncestorWhichIsA("ScreenGui")
	if screenGui and screenGui.IgnoreGuiInset then
		offset += getService('GuiService'):GetGuiInset()
	end

	local function connectFunctions()
		if dragBar and enableTaptic then
			dragBar.MouseEnter:Connect(function()
				if not dragging and not Hidden then
					TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5, Size = UDim2.new(0, 120, 0, 4)}):Play()
				end
			end)

			dragBar.MouseLeave:Connect(function()
				if not dragging and not Hidden then
					TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7, Size = UDim2.new(0, 100, 0, 4)}):Play()
				end
			end)
		end
	end

	connectFunctions()

	dragObject.InputBegan:Connect(function(input, processed)
		if processed then return end

		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			dragging = true

			relative = object.AbsolutePosition + object.AbsoluteSize * object.AnchorPoint - UserInputService:GetMouseLocation()
			if enableTaptic and not Hidden then
				TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 110, 0, 4), BackgroundTransparency = 0}):Play()
			end
		end
	end)

	local inputEnded = UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end

		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			dragging = false

			if enableTaptic and not Hidden then
				TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.7}):Play()
			end
		end
	end)

	local renderStepped = RunService.RenderStepped:Connect(function()
		if dragging and not Hidden then
			local position = UserInputService:GetMouseLocation() + relative + offset
			if enableTaptic and tapticOffset then
				TweenService:Create(object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y)}):Play()
				TweenService:Create(dragObject.Parent, TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y + ((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))}):Play()
			else
				if dragBar and tapticOffset then
					dragBar.Position = UDim2.fromOffset(position.X, position.Y + ((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))
				end
				object.Position = UDim2.fromOffset(position.X, position.Y)
			end
		end
	end)

	object.Destroying:Connect(function()
		if inputEnded then inputEnded:Disconnect() end
		if renderStepped then renderStepped:Disconnect() end
	end)
end


local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadConfiguration(Configuration)
	local success, Data = pcall(function() return HttpService:JSONDecode(Configuration) end)
	local changed

	if not success then warn('Rayfield had an issue decoding the configuration file, please try delete the file and reopen Rayfield.') return end

	-- Iterate through current UI elements' flags
	for FlagName, Flag in pairs(RayfieldLibrary.Flags) do
		local FlagValue = Data[FlagName]

		if (typeof(FlagValue) == 'boolean' and FlagValue == false) or FlagValue then
			task.spawn(function()
				if Flag.Type == "ColorPicker" then
					changed = true
					Flag:Set(UnpackColor(FlagValue))
				else
					if (Flag.CurrentValue or Flag.CurrentKeybind or Flag.CurrentOption or Flag.Color) ~= FlagValue then 
						changed = true
						Flag:Set(FlagValue) 	
					end
				end
			end)
		else
			warn("Rayfield | Unable to find '"..FlagName.. "' in the save file.")
			print("The error above may not be an issue if new elements have been added or not been set values.")
			--RayfieldLibrary:Notify({Title = "Rayfield Flags", Content = "Rayfield was unable to find '"..FlagName.. "' in the save file. Check sirius.menu/discord for help.", Image = 3944688398})
		end
	end

	return changed
end

local function SaveConfiguration()
	if not CEnabled or not globalLoaded then return end

	if debugX then
		print('Saving')
	end

	local Data = {}
	for i, v in pairs(RayfieldLibrary.Flags) do
		if v.Type == "ColorPicker" then
			Data[i] = PackColor(v.Color)
		else
			if typeof(v.CurrentValue) == 'boolean' then
				if v.CurrentValue == false then
					Data[i] = false
				else
					Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
				end
			else
				Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
			end
		end
	end

	if useStudio then
		if script.Parent:FindFirstChild('configuration') then script.Parent.configuration:Destroy() end

		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Parent = script.Parent
		ScreenGui.Name = 'configuration'

		local TextBox = Instance.new("TextBox")
		TextBox.Parent = ScreenGui
		TextBox.Size = UDim2.new(0, 800, 0, 50)
		TextBox.AnchorPoint = Vector2.new(0.5, 0)
		TextBox.Position = UDim2.new(0.5, 0, 0, 30)
		TextBox.Text = HttpService:JSONEncode(Data)
		TextBox.ClearTextOnFocus = false
	end

	if debugX then
		warn(HttpService:JSONEncode(Data))
	end


	callSafely(writefile, ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension, tostring(HttpService:JSONEncode(Data)))
end

function RayfieldLibrary:Notify(data) -- action e.g open messages
	task.spawn(function()

		-- Notification Object Creation
		local newNotification = Notifications.Template:Clone()
		newNotification.Name = data.Title or 'No Title Provided'
		newNotification.Parent = Notifications
		newNotification.LayoutOrder = #Notifications:GetChildren()
		newNotification.Visible = false

		-- Set Data
		newNotification.Title.Text = data.Title or "Unknown Title"
		newNotification.Description.Text = data.Content or "Unknown Content"

		if data.Image then
			local img, rectOffset, rectSize = resolveIcon(data.Image)
			newNotification.Icon.Image = img
			if rectOffset then newNotification.Icon.ImageRectOffset = rectOffset end
			if rectSize then newNotification.Icon.ImageRectSize = rectSize end
		else
			newNotification.Icon.Image = ""
		end

		-- Set initial transparency values

		newNotification.Title.TextColor3 = SelectedTheme.TextColor
		newNotification.Description.TextColor3 = SelectedTheme.TextColor
		newNotification.BackgroundColor3 = SelectedTheme.Background
		newNotification.UIStroke.Color = SelectedTheme.TextColor
		newNotification.Icon.ImageColor3 = SelectedTheme.TextColor

		newNotification.BackgroundTransparency = 1
		newNotification.Title.TextTransparency = 1
		newNotification.Description.TextTransparency = 1
		newNotification.UIStroke.Transparency = 1
		newNotification.Shadow.ImageTransparency = 1
		newNotification.Size = UDim2.new(1, 0, 0, 800)
		newNotification.Icon.ImageTransparency = 1
		newNotification.Icon.BackgroundTransparency = 1

		task.wait()

		newNotification.Visible = true

		if data.Actions then
			warn('Rayfield | Not seeing your actions in notifications?')
			print("Notification Actions are being sunset for now, keep up to date on when they're back in the discord. (sirius.menu/discord)")
		end

		-- Calculate textbounds and set initial values
		local bounds = {newNotification.Title.TextBounds.Y, newNotification.Description.TextBounds.Y}
		newNotification.Size = UDim2.new(1, -60, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)

		newNotification.Icon.Size = UDim2.new(0, 32, 0, 32)
		newNotification.Icon.Position = UDim2.new(0, 20, 0.5, 0)

		TweenService:Create(newNotification, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, math.max(bounds[1] + bounds[2] + 31, 60))}):Play()

		task.wait(0.15)
		TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.45}):Play()
		TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

		task.wait(0.05)

		TweenService:Create(newNotification.Icon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()

		task.wait(0.05)
		TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.35}):Play()
		TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0.95}):Play()
		TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.82}):Play()

		local waitDuration = math.min(math.max((#newNotification.Description.Text * 0.1) + 2.5, 3), 10)
		task.wait(data.Duration or waitDuration)

		newNotification.Icon.Visible = false
		TweenService:Create(newNotification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
		TweenService:Create(newNotification.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		TweenService:Create(newNotification.Shadow, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
		TweenService:Create(newNotification.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
		TweenService:Create(newNotification.Description, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()

		TweenService:Create(newNotification, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -90, 0, 0)}):Play()

		task.wait(1)

		TweenService:Create(newNotification, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -90, 0, -Notifications:FindFirstChild("UIListLayout").Padding.Offset)}):Play()

		newNotification.Visible = false
		newNotification:Destroy()
	end)
end

local function openSearch()
	searchOpen = true

	Main.Search.BackgroundTransparency = 1
	Main.Search.Shadow.ImageTransparency = 1
	Main.Search.Input.TextTransparency = 1
	Main.Search.Search.ImageTransparency = 1
	Main.Search.UIStroke.Transparency = 1
	Main.Search.Size = UDim2.new(1, 0, 0, 80)
	Main.Search.Position = UDim2.new(0.5, 0, 0, 70)

	Main.Search.Input.Interactable = true

	Main.Search.Visible = true

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			tabbtn.Interact.Visible = false
			TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
			TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
			TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
			TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		end
	end

	Main.Search.Input:CaptureFocus()
	TweenService:Create(Main.Search.Shadow, TweenInfo.new(0.05, Enum.EasingStyle.Quint), {ImageTransparency = 0.95}):Play()
	TweenService:Create(Main.Search, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0, 57), BackgroundTransparency = 0.9}):Play()
	TweenService:Create(Main.Search.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.8}):Play()
	TweenService:Create(Main.Search.Input, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
	TweenService:Create(Main.Search.Search, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.5}):Play()
	TweenService:Create(Main.Search, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -35, 0, 35)}):Play()
end

local function closeSearch()
	searchOpen = false

	TweenService:Create(Main.Search, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {BackgroundTransparency = 1, Size = UDim2.new(1, -55, 0, 30)}):Play()
	TweenService:Create(Main.Search.Search, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	TweenService:Create(Main.Search.Shadow, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
	TweenService:Create(Main.Search.UIStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency = 1}):Play()
	TweenService:Create(Main.Search.Input, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()

	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			tabbtn.Interact.Visible = true
			if tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Title.Text then
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			else
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
			end
		end
	end

	Main.Search.Input.Text = ''
	Main.Search.Input.Interactable = false
end

-- Sets element visibility across all tab pages (used by Hide, Unhide, Maximise, Minimise)
local function setElementsVisible(show)
	for _, tab in ipairs(Elements:GetChildren()) do
		if tab.Name ~= "Template" and tab.ClassName == "ScrollingFrame" and tab.Name ~= "Placeholder" then
			for _, element in ipairs(tab:GetChildren()) do
				if element.ClassName == "Frame" then
					if element.Name ~= "SectionSpacing" and element.Name ~= "Placeholder" then
						if element.Name == "SectionTitle" or element.Name == 'SearchTitle-fsefsefesfsefesfesfThanks' then
							TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = show and 0.4 or 1}):Play()
						elseif element.Name == 'Divider' then
							TweenService:Create(element.Divider, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = show and 0.85 or 1}):Play()
						else
							TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = show and 0 or 1}):Play()
							TweenService:Create(element.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = show and 0 or 1}):Play()
							TweenService:Create(element.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = show and 0 or 1}):Play()
						end
						for _, child in ipairs(element:GetChildren()) do
							if child.ClassName == "Frame" or child.ClassName == "TextLabel" or child.ClassName == "TextBox" or child.ClassName == "ImageButton" or child.ClassName == "ImageLabel" then
								child.Visible = show
							end
						end
					end
				end
			end
		end
	end
end

-- Sets tab button visibility (used by Hide, Unhide, Maximise, Minimise)
local function setTabButtonsVisible(show)
	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			if show then
				if tostring(Elements.UIPageLayout.CurrentPage) == tabbtn.Title.Text then
					TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
					TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
					TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
					TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
				else
					TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
					TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
					TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
					TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
				end
			else
				TweenService:Create(tabbtn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
				TweenService:Create(tabbtn.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
				TweenService:Create(tabbtn.Image, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
				TweenService:Create(tabbtn.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			end
		end
	end
end

local function Hide(notify: boolean?)
	if MPrompt then
		MPrompt.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		MPrompt.Position = UDim2.new(0.5, 0, 0, -50)
		MPrompt.Size = UDim2.new(0, 40, 0, 10)
		MPrompt.BackgroundTransparency = 1
		MPrompt.Title.TextTransparency = 1
		MPrompt.Visible = true
	end

	task.spawn(closeSearch)

	Debounce = true
	if notify then
		if useMobilePrompt then 
			RayfieldLibrary:Notify({Title = "Interface Hidden", Content = "The interface has been hidden, you can unhide the interface by tapping 'Show'.", Duration = 7, Image = 4400697855})
		else
			RayfieldLibrary:Notify({Title = "Interface Hidden", Content = "The interface has been hidden, you can unhide the interface by tapping " .. tostring(getSetting("General", "rayfieldOpen")) .. ".", Duration = 7, Image = 4400697855})
		end
	end

	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 470, 0, 0)}):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 470, 0, 45)}):Play()
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Topbar.CornerRepair, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main.Topbar.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
	TweenService:Create(Topbar.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
	if dragBarCosmetic then
		TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
	end

	if useMobilePrompt and MPrompt then
		TweenService:Create(MPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 120, 0, 30), Position = UDim2.new(0.5, 0, 0, 20), BackgroundTransparency = 0.3}):Play()
		TweenService:Create(MPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.3}):Play()
	end

	for _, TopbarButton in ipairs(Topbar:GetChildren()) do
		if TopbarButton.ClassName == "ImageButton" then
			TweenService:Create(TopbarButton, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
		end
	end

	setTabButtonsVisible(false)

	if dragInteract then dragInteract.Visible = false end

	setElementsVisible(false)

	task.wait(0.5)
	Main.Visible = false
	Debounce = false
end

local function Maximise()
	Debounce = true
	Topbar.ChangeSize.Image = customAssets[tostring(10137941941)]

	TweenService:Create(Topbar.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()
	TweenService:Create(Topbar.CornerRepair, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7}):Play()
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = useMobileSizing and UDim2.new(0, 500, 0, 275) or UDim2.new(0, 500, 0, 475)}):Play()
	TweenService:Create(Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 500, 0, 45)}):Play()
	TabList.Visible = true
	task.wait(0.2)

	Elements.Visible = true

	setElementsVisible(true)

	task.wait(0.1)

	setTabButtonsVisible(true)

	task.wait(0.5)
	Debounce = false
end


local function Unhide()
	Debounce = true
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Main.Visible = true
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = useMobileSizing and UDim2.new(0, 500, 0, 275) or UDim2.new(0, 500, 0, 475)}):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 500, 0, 45)}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Topbar.CornerRepair, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Topbar.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()

	if MPrompt then
		TweenService:Create(MPrompt, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 40, 0, 10), Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 1}):Play()
		TweenService:Create(MPrompt.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()

		task.spawn(function()
			task.wait(0.5)
			MPrompt.Visible = false
		end)
	end

	if Minimised then
		task.spawn(Maximise)
	end

	dragBar.Position = useMobileSizing and UDim2.new(0.5, 0, 0.5, dragOffsetMobile) or UDim2.new(0.5, 0, 0.5, dragOffset)

	dragInteract.Visible = true

	for _, TopbarButton in ipairs(Topbar:GetChildren()) do
		if TopbarButton.ClassName == "ImageButton" then
			if TopbarButton.Name == 'Icon' then
				TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
			else
				TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
			end

		end
	end

	setTabButtonsVisible(true)

	setElementsVisible(true)

	TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()

	task.wait(0.5)
	Minimised = false
	Debounce = false
end

local function Minimise()
	Debounce = true
	Topbar.ChangeSize.Image = customAssets[tostring(11036884234)]

	Topbar.UIStroke.Color = SelectedTheme.ElementStroke

	task.spawn(closeSearch)

	setTabButtonsVisible(false)

	setElementsVisible(false)

	TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Topbar.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
	TweenService:Create(Topbar.CornerRepair, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Topbar.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 495, 0, 45)}):Play()
	TweenService:Create(Topbar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 495, 0, 45)}):Play()

	task.wait(0.3)

	Elements.Visible = false
	TabList.Visible = false

	task.wait(0.2)
	Debounce = false
end

local function saveSettings() -- Save settings to config file
	local encoded
	local success, err = pcall(function()
		encoded = HttpService:JSONEncode(settingsTable)
	end)

	if success then
		if useStudio then
			if script.Parent['get.val'] then
				script.Parent['get.val'].Value = encoded
			end
		end
		callSafely(writefile, RayfieldFolder..'/settings'..ConfigurationExtension, encoded)
	end
end

local function updateSetting(category: string, setting: string, value: any)
	if not settingsInitialized then
		return
	end
	settingsTable[category][setting].Value = value
	overriddenSettings[category .. "." .. setting] = nil -- If user changes an overriden setting, remove the override
	saveSettings()
end

local function createSettings(window)
	if not (writefile and isfile and readfile and isfolder and makefolder) and not useStudio then
		if Topbar['Settings'] then Topbar.Settings.Visible = false end
		Topbar['Search'].Position = UDim2.new(1, -75, 0.5, 0)
		warn('Can\'t create settings as no file-saving functionality is available.')
		return
	end

	local newTab = window:CreateTab('Rayfield Settings', 0, true)

	if TabList['Rayfield Settings'] then
		TabList['Rayfield Settings'].LayoutOrder = 1000
	end

	if Elements['Rayfield Settings'] then
		Elements['Rayfield Settings'].LayoutOrder = 1000
	end

	-- Create sections and elements
	for categoryName, settingCategory in pairs(settingsTable) do
		newTab:CreateSection(categoryName)

		for settingName, setting in pairs(settingCategory) do
			if setting.Type == 'input' then
				setting.Element = newTab:CreateInput({
					Name = setting.Name,
					CurrentValue = setting.Value,
					PlaceholderText = setting.Placeholder,
					Ext = true,
					RemoveTextAfterFocusLost = setting.ClearOnFocus,
					Callback = function(Value)
						updateSetting(categoryName, settingName, Value)
					end,
				})
			elseif setting.Type == 'toggle' then
				setting.Element = newTab:CreateToggle({
					Name = setting.Name,
					CurrentValue = setting.Value,
					Ext = true,
					Callback = function(Value)
						updateSetting(categoryName, settingName, Value)
					end,
				})
			elseif setting.Type == 'bind' then
				setting.Element = newTab:CreateKeybind({
					Name = setting.Name,
					CurrentKeybind = setting.Value,
					HoldToInteract = false,
					Ext = true,
					CallOnChange = true,
					Callback = function(Value)
						updateSetting(categoryName, settingName, Value)
					end,
				})
			end
		end
	end

	settingsCreated = true
	loadSettings()
	saveSettings()
end

local function fadeOutKeyUI(KeyMain)
	TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 467, 0, 175)}):Play()
	TweenService:Create(KeyMain.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
	TweenService:Create(KeyMain.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(KeyMain.KeyNote, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(KeyMain.Input, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
	TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
	TweenService:Create(KeyMain.Input.InputBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(KeyMain.NoteTitle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(KeyMain.NoteMessage, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(KeyMain.Hide, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
end

function RayfieldLibrary:CreateWindow(Settings)
	if Rayfield:FindFirstChild('Loading') then
		if getgenv and not getgenv().rayfieldCached then
			Rayfield.Enabled = true
			Rayfield.Loading.Visible = true

			task.wait(1.4)
			Rayfield.Loading.Visible = false
		end
	end

	if getgenv then getgenv().rayfieldCached = true end

	if not correctBuild and not Settings.DisableBuildWarnings then
		task.delay(3, 
			function() 
				RayfieldLibrary:Notify({Title = 'Build Mismatch', Content = 'Rayfield may encounter issues as you are running an incompatible interface version ('.. ((Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..').\n\nThis version of Rayfield is intended for interface build '..InterfaceBuild..'.\n\nTry rejoining and then run the script twice.', Image = 4335487866, Duration = 15})		
			end)
	end

	if Settings.ToggleUIKeybind then -- Can either be a string or an Enum.KeyCode
		local keybind = Settings.ToggleUIKeybind
		if type(keybind) == "string" then
			keybind = string.upper(keybind)
			assert(pcall(function()
				return Enum.KeyCode[keybind]
			end), "ToggleUIKeybind must be a valid KeyCode")
			overrideSetting("General", "rayfieldOpen", keybind)
		elseif typeof(keybind) == "EnumItem" then
			assert(keybind.EnumType == Enum.KeyCode, "ToggleUIKeybind must be a KeyCode enum")
			overrideSetting("General", "rayfieldOpen", keybind.Name)
		else
			error("ToggleUIKeybind must be a string or KeyCode enum")
		end
	end

	ensureFolder(RayfieldFolder)

	local Passthrough = false
	Topbar.Title.Text = Settings.Name

	Main.Size = UDim2.new(0, 420, 0, 100)
	Main.Visible = true
	Main.BackgroundTransparency = 1
	if Main:FindFirstChild('Notice') then Main.Notice.Visible = false end
	Main.Shadow.Image.ImageTransparency = 1

	LoadingFrame.Title.TextTransparency = 1
	LoadingFrame.Subtitle.TextTransparency = 1

	if Settings.ShowText then
		MPrompt.Title.Text = 'Show '..Settings.ShowText
	end

	LoadingFrame.Version.TextTransparency = 1
	LoadingFrame.Title.Text = Settings.LoadingTitle or "Rayfield"
	LoadingFrame.Subtitle.Text = Settings.LoadingSubtitle or "Interface Suite"

	if Settings.LoadingTitle ~= "Rayfield Interface Suite" then
		LoadingFrame.Version.Text = "Rayfield UI"
	end

	if Settings.Icon and Settings.Icon ~= 0 and Topbar:FindFirstChild('Icon') then
		Topbar.Icon.Visible = true
		Topbar.Title.Position = UDim2.new(0, 47, 0.5, 0)

		if Settings.Icon then
			local img, rectOffset, rectSize = resolveIcon(Settings.Icon)
			Topbar.Icon.Image = img
			if rectOffset then Topbar.Icon.ImageRectOffset = rectOffset end
			if rectSize then Topbar.Icon.ImageRectSize = rectSize end
		else
			Topbar.Icon.Image = ""
		end
	end

	if dragBar then
		dragBar.Visible = false
		dragBarCosmetic.BackgroundTransparency = 1
		dragBar.Visible = true
	end

	if Settings.Theme then
		local success, result = pcall(ChangeTheme, Settings.Theme)
		if not success then
			local success, result2 = pcall(ChangeTheme, 'Default')
			if not success then
				warn('CRITICAL ERROR - NO DEFAULT THEME')
				print(result2)
			end
			warn('issue rendering theme. no theme on file')
			print(result)
		end
	end

	Topbar.Visible = false
	Elements.Visible = false
	LoadingFrame.Visible = true

	if not Settings.DisableRayfieldPrompts then
		task.spawn(function()
			while not rayfieldDestroyed do
				task.wait(math.random(180, 600))
				if rayfieldDestroyed then break end
				RayfieldLibrary:Notify({
					Title = "Rayfield Interface",
					Content = "Enjoying this UI library? Find it at sirius.menu/discord",
					Duration = 7,
					Image = 4370033185,
				})
			end
		end)
	end

	pcall(function()
		if not Settings.ConfigurationSaving.FileName then
			Settings.ConfigurationSaving.FileName = tostring(game.PlaceId)
		end

		if Settings.ConfigurationSaving.Enabled == nil then
			Settings.ConfigurationSaving.Enabled = false
		end

		CFileName = Settings.ConfigurationSaving.FileName
		ConfigurationFolder = Settings.ConfigurationSaving.FolderName or ConfigurationFolder
		CEnabled = Settings.ConfigurationSaving.Enabled

		if Settings.ConfigurationSaving.Enabled then
			ensureFolder(ConfigurationFolder)
		end
	end)


	makeDraggable(Main, Topbar, false, {dragOffset, dragOffsetMobile})
	if dragBar then dragBar.Position = useMobileSizing and UDim2.new(0.5, 0, 0.5, dragOffsetMobile) or UDim2.new(0.5, 0, 0.5, dragOffset) makeDraggable(Main, dragInteract, true, {dragOffset, dragOffsetMobile}) end

	for _, TabButton in ipairs(TabList:GetChildren()) do
		if TabButton.ClassName == "Frame" and TabButton.Name ~= "Placeholder" then
			TabButton.BackgroundTransparency = 1
			TabButton.Title.TextTransparency = 1
			TabButton.Image.ImageTransparency = 1
			TabButton.UIStroke.Transparency = 1
		end
	end

	if Settings.Discord and Settings.Discord.Enabled and not useStudio and not secureMode then
		ensureFolder(RayfieldFolder.."/Discord Invites")

		if not callSafely(isfile, RayfieldFolder.."/Discord Invites".."/"..Settings.Discord.Invite..ConfigurationExtension) then
			if requestFunc then
				pcall(function()
					requestFunc({
						Url = 'http://127.0.0.1:6463/rpc?v=1',
						Method = 'POST',
						Headers = {
							['Content-Type'] = 'application/json',
							Origin = 'https://discord.com'
						},
						Body = HttpService:JSONEncode({
							cmd = 'INVITE_BROWSER',
							nonce = HttpService:GenerateGUID(false),
							args = {code = Settings.Discord.Invite}
						})
					})
				end)
			end

			if Settings.Discord.RememberJoins then -- We do logic this way so if the developer changes this setting, the user still won't be prompted, only new users
				callSafely(writefile, RayfieldFolder.."/Discord Invites".."/"..Settings.Discord.Invite..ConfigurationExtension,"Rayfield RememberJoins is true for this invite, this invite will not ask you to join again")
			end
		end
	end

	if (Settings.KeySystem) then
		if not Settings.KeySettings then
			Passthrough = true
			return
		end

		ensureFolder(RayfieldFolder.."/Key System")

		if typeof(Settings.KeySettings.Key) == "string" then Settings.KeySettings.Key = {Settings.KeySettings.Key} end

		if Settings.KeySettings.GrabKeyFromSite then
			for i, Key in ipairs(Settings.KeySettings.Key) do
				local Success, Response = pcall(function()
					Settings.KeySettings.Key[i] = tostring(game:HttpGet(Key):gsub("[\n\r]", " "))
					Settings.KeySettings.Key[i] = string.gsub(Settings.KeySettings.Key[i], " ", "")
				end)
				if not Success then
					print("Rayfield | "..Key.." Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
				end
			end
		end

		if not Settings.KeySettings.FileName then
			Settings.KeySettings.FileName = "No file name specified"
		end

		if callSafely(isfile, RayfieldFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension) then
			for _, MKey in ipairs(Settings.KeySettings.Key) do
				local savedKeys = callSafely(readfile, RayfieldFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension)
				if savedKeys and string.find(savedKeys, MKey) then
					Passthrough = true
				end
			end
		end

		if not Passthrough and secureMode then
			warn("Rayfield | Secure Mode: Key system requires a valid saved key. The key UI cannot be shown as it requires loading detectable assets.")
			Rayfield.Enabled = false
			return RayfieldLibrary
		end

		if not Passthrough then
			local AttemptsRemaining = Settings.KeySettings.MaxAttempts or 5
			Rayfield.Enabled = false
			local KeyUI = useStudio and script.Parent:FindFirstChild('Key') or game:GetObjects("rbxassetid://11380036235")[1]

			KeyUI.Enabled = true

			if gethui then
				KeyUI.Parent = gethui()
			elseif syn and syn.protect_gui then 
				syn.protect_gui(KeyUI)
				KeyUI.Parent = CoreGui
			elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
				KeyUI.Parent = CoreGui:FindFirstChild("RobloxGui")
			elseif not useStudio then
				KeyUI.Parent = CoreGui
			end

			if gethui then
				for _, Interface in ipairs(gethui():GetChildren()) do
					if Interface.Name == KeyUI.Name and Interface ~= KeyUI then
						Interface.Enabled = false
						Interface.Name = "KeyUI-Old"
					end
				end
			elseif not useStudio then
				for _, Interface in ipairs(CoreGui:GetChildren()) do
					if Interface.Name == KeyUI.Name and Interface ~= KeyUI then
						Interface.Enabled = false
						Interface.Name = "KeyUI-Old"
					end
				end
			end

			local KeyMain = KeyUI.Main
			KeyMain.Title.Text = Settings.KeySettings.Title or Settings.Name
			KeyMain.Subtitle.Text = Settings.KeySettings.Subtitle or "Key System"
			KeyMain.NoteMessage.Text = Settings.KeySettings.Note or "No instructions"

			KeyMain.Size = UDim2.new(0, 467, 0, 175)
			KeyMain.BackgroundTransparency = 1
			KeyMain.Shadow.Image.ImageTransparency = 1
			KeyMain.Title.TextTransparency = 1
			KeyMain.Subtitle.TextTransparency = 1
			KeyMain.KeyNote.TextTransparency = 1
			KeyMain.Input.BackgroundTransparency = 1
			KeyMain.Input.UIStroke.Transparency = 1
			KeyMain.Input.InputBox.TextTransparency = 1
			KeyMain.NoteTitle.TextTransparency = 1
			KeyMain.NoteMessage.TextTransparency = 1
			KeyMain.Hide.ImageTransparency = 1

			TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 500, 0, 187)}):Play()
			TweenService:Create(KeyMain.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.5}):Play()
			task.wait(0.05)
			TweenService:Create(KeyMain.Title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(KeyMain.Subtitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			task.wait(0.05)
			TweenService:Create(KeyMain.KeyNote, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(KeyMain.Input, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(KeyMain.Input.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(KeyMain.Input.InputBox, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			task.wait(0.05)
			TweenService:Create(KeyMain.NoteTitle, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(KeyMain.NoteMessage, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			task.wait(0.15)
			TweenService:Create(KeyMain.Hide, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {ImageTransparency = 0.3}):Play()


			KeyUI.Main.Input.InputBox.FocusLost:Connect(function()
				if #KeyUI.Main.Input.InputBox.Text == 0 then return end
				local KeyFound = false
				local FoundKey = ''
				for _, MKey in ipairs(Settings.KeySettings.Key) do
					--if string.find(KeyMain.Input.InputBox.Text, MKey) then
					--	KeyFound = true
					--	FoundKey = MKey
					--end


					-- stricter key check
					if KeyMain.Input.InputBox.Text == MKey then
						KeyFound = true
						FoundKey = MKey
					end
				end
				if KeyFound then
					fadeOutKeyUI(KeyMain)
					task.wait(0.51)
					Passthrough = true
					KeyMain.Visible = false
					if Settings.KeySettings.SaveKey then
						callSafely(writefile, RayfieldFolder.."/Key System".."/"..Settings.KeySettings.FileName..ConfigurationExtension, FoundKey)
						RayfieldLibrary:Notify({Title = "Key System", Content = "The key for this script has been saved successfully.", Image = 3605522284})
					end
				else
					if AttemptsRemaining == 0 then
						fadeOutKeyUI(KeyMain)
						task.wait(0.45)
						Players.LocalPlayer:Kick("No Attempts Remaining")
						game:Shutdown()
					end
					KeyMain.Input.InputBox.Text = ""
					AttemptsRemaining = AttemptsRemaining - 1
					TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 467, 0, 175)}):Play()
					TweenService:Create(KeyMain, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {Position = UDim2.new(0.495,0,0.5,0)}):Play()
					task.wait(0.1)
					TweenService:Create(KeyMain, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {Position = UDim2.new(0.505,0,0.5,0)}):Play()
					task.wait(0.1)
					TweenService:Create(KeyMain, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5,0,0.5,0)}):Play()
					TweenService:Create(KeyMain, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 500, 0, 187)}):Play()
				end
			end)

			KeyMain.Hide.MouseButton1Click:Connect(function()
				fadeOutKeyUI(KeyMain)
				task.wait(0.51)
				Passthrough = true
				RayfieldLibrary:Destroy()
				KeyUI:Destroy()
			end)
		else
			Passthrough = true
		end
	end
	if Settings.KeySystem then
		repeat task.wait() until Passthrough
		if rayfieldDestroyed then return end
	end

	Notifications.Template.Visible = false
	Notifications.Visible = true
	Rayfield.Enabled = true

	task.wait(0.5)
	TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()
	task.wait(0.1)
	TweenService:Create(LoadingFrame.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	task.wait(0.05)
	TweenService:Create(LoadingFrame.Subtitle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	task.wait(0.05)
	TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()


	Elements.Template.LayoutOrder = 100000
	Elements.Template.Visible = false

	Elements.UIPageLayout.FillDirection = Enum.FillDirection.Horizontal
	TabList.Template.Visible = false

	-- Tab
	local FirstTab = false
	local Window = {}
	function Window:CreateTab(Name, Image, Ext)
		local SDone = false
		local TabButton = TabList.Template:Clone()
		TabButton.Name = Name
		TabButton.Title.Text = Name
		TabButton.Parent = TabList
		TabButton.Title.TextWrapped = false
		TabButton.Size = UDim2.new(0, TabButton.Title.TextBounds.X + 30, 0, 30)

		if Image and Image ~= 0 then
			local img, rectOffset, rectSize = resolveIcon(Image)
			TabButton.Image.Image = img
			if rectOffset then TabButton.Image.ImageRectOffset = rectOffset end
			if rectSize then TabButton.Image.ImageRectSize = rectSize end

			TabButton.Title.AnchorPoint = Vector2.new(0, 0.5)
			TabButton.Title.Position = UDim2.new(0, 37, 0.5, 0)
			TabButton.Image.Visible = true
			TabButton.Title.TextXAlignment = Enum.TextXAlignment.Left
			TabButton.Size = UDim2.new(0, TabButton.Title.TextBounds.X + 52, 0, 30)
		end



		TabButton.BackgroundTransparency = 1
		TabButton.Title.TextTransparency = 1
		TabButton.Image.ImageTransparency = 1
		TabButton.UIStroke.Transparency = 1

		TabButton.Visible = not Ext or false

		-- Create Elements Page
		local TabPage = Elements.Template:Clone()
		TabPage.Name = Name
		TabPage.Visible = true

		TabPage.LayoutOrder = #Elements:GetChildren() or Ext and 10000

		for _, TemplateElement in ipairs(TabPage:GetChildren()) do
			if TemplateElement.ClassName == "Frame" and TemplateElement.Name ~= "Placeholder" then
				TemplateElement:Destroy()
			end
		end

		TabPage.Parent = Elements
		if not FirstTab and not Ext then
			Elements.UIPageLayout.Animated = false
			Elements.UIPageLayout:JumpTo(TabPage)
			Elements.UIPageLayout.Animated = true
		end

		TabButton.UIStroke.Color = SelectedTheme.TabStroke

		if Elements.UIPageLayout.CurrentPage == TabPage then
			TabButton.BackgroundColor3 = SelectedTheme.TabBackgroundSelected
			TabButton.Image.ImageColor3 = SelectedTheme.SelectedTabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.SelectedTabTextColor
		else
			TabButton.BackgroundColor3 = SelectedTheme.TabBackground
			TabButton.Image.ImageColor3 = SelectedTheme.TabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.TabTextColor
		end


		-- Animate
		task.wait(0.1)
		if FirstTab or Ext then
			TabButton.BackgroundColor3 = SelectedTheme.TabBackground
			TabButton.Image.ImageColor3 = SelectedTheme.TabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.TabTextColor
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
			TweenService:Create(TabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
		elseif not Ext then
			FirstTab = Name
			TabButton.BackgroundColor3 = SelectedTheme.TabBackgroundSelected
			TabButton.Image.ImageColor3 = SelectedTheme.SelectedTabTextColor
			TabButton.Title.TextColor3 = SelectedTheme.SelectedTabTextColor
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
		end


		TabButton.Interact.MouseButton1Click:Connect(function()
			if Minimised then return end
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(TabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
			TweenService:Create(TabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.TabBackgroundSelected}):Play()
			TweenService:Create(TabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextColor3 = SelectedTheme.SelectedTabTextColor}):Play()
			TweenService:Create(TabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageColor3 = SelectedTheme.SelectedTabTextColor}):Play()

			for _, OtherTabButton in ipairs(TabList:GetChildren()) do
				if OtherTabButton.Name ~= "Template" and OtherTabButton.ClassName == "Frame" and OtherTabButton ~= TabButton and OtherTabButton.Name ~= "Placeholder" then
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.TabBackground}):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextColor3 = SelectedTheme.TabTextColor}):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageColor3 = SelectedTheme.TabTextColor}):Play()
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
					TweenService:Create(OtherTabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
				end
			end

			if Elements.UIPageLayout.CurrentPage ~= TabPage then
				Elements.UIPageLayout:JumpTo(TabPage)
			end
		end)

		local Tab = {}

		-- Button
		function Tab:CreateButton(ButtonSettings)
			local ButtonValue = {}

			local Button = Elements.Template.Button:Clone()
			Button.Name = ButtonSettings.Name
			Button.Title.Text = ButtonSettings.Name
			Button.Visible = true
			Button.Parent = TabPage

			Button.BackgroundTransparency = 1
			Button.UIStroke.Transparency = 1
			Button.Title.TextTransparency = 1

			TweenService:Create(Button, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Button.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Button.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	


			Button.Interact.MouseButton1Click:Connect(function()
				local Success, Response = pcall(ButtonSettings.Callback)
				-- Prevents animation from trying to play if the button's callback called RayfieldLibrary:Destroy()
				if rayfieldDestroyed then
					return
				end
				if not Success then
					TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
					TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
					TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Button.Title.Text = "Callback Error"
					print("Rayfield | "..ButtonSettings.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Button.Title.Text = ButtonSettings.Name
					TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 0.9}):Play()
					TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				else
					if not ButtonSettings.Ext then
						SaveConfiguration(ButtonSettings.Name..'\n')
					end
					TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
					TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					task.wait(0.2)
					TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 0.9}):Play()
					TweenService:Create(Button.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end
			end)

			Button.MouseEnter:Connect(function()
				TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
				TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 0.7}):Play()
			end)

			Button.MouseLeave:Connect(function()
				TweenService:Create(Button, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
				TweenService:Create(Button.ElementIndicator, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 0.9}):Play()
			end)

			function ButtonValue:Set(NewButton)
				Button.Title.Text = NewButton
				Button.Name = NewButton
			end

			return ButtonValue
		end

		-- ColorPicker
		function Tab:CreateColorPicker(ColorPickerSettings) -- by Throit
			ColorPickerSettings.Type = "ColorPicker"
			local ColorPicker = Elements.Template.ColorPicker:Clone()
			local Background = ColorPicker.CPBackground
			local Display = Background.Display
			local Main = Background.MainCP
			local Slider = ColorPicker.ColorSlider
			ColorPicker.ClipsDescendants = true
			ColorPicker.Name = ColorPickerSettings.Name
			ColorPicker.Title.Text = ColorPickerSettings.Name
			ColorPicker.Visible = true
			ColorPicker.Parent = TabPage
			ColorPicker.Size = UDim2.new(1, -10, 0, 45)
			Background.Size = UDim2.new(0, 39, 0, 22)
			Display.BackgroundTransparency = 0
			Main.MainPoint.ImageTransparency = 1
			ColorPicker.Interact.Size = UDim2.new(1, 0, 1, 0)
			ColorPicker.Interact.Position = UDim2.new(0.5, 0, 0.5, 0)
			ColorPicker.RGB.Position = UDim2.new(0, 17, 0, 70)
			ColorPicker.HexInput.Position = UDim2.new(0, 17, 0, 90)
			Main.ImageTransparency = 1
			Background.BackgroundTransparency = 1

			for _, rgbinput in ipairs(ColorPicker.RGB:GetChildren()) do
				if rgbinput:IsA("Frame") then
					rgbinput.BackgroundColor3 = SelectedTheme.InputBackground
					rgbinput.UIStroke.Color = SelectedTheme.InputStroke
				end
			end

			ColorPicker.HexInput.BackgroundColor3 = SelectedTheme.InputBackground
			ColorPicker.HexInput.UIStroke.Color = SelectedTheme.InputStroke

			local opened = false 
			local mouse = Players.LocalPlayer:GetMouse()
			local mainDragging = false 
			local sliderDragging = false 
			ColorPicker.Interact.MouseButton1Down:Connect(function()
				task.spawn(function()
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(ColorPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					task.wait(0.2)
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(ColorPicker.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end)

				if not opened then
					opened = true 
					TweenService:Create(Background, TweenInfo.new(0.45, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 18, 0, 15)}):Play()
					task.wait(0.1)
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -10, 0, 120)}):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 173, 0, 86)}):Play()
					TweenService:Create(Display, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.289, 0, 0.5, 0)}):Play()
					TweenService:Create(ColorPicker.RGB, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 17, 0, 40)}):Play()
					TweenService:Create(ColorPicker.HexInput, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 17, 0, 73)}):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0.574, 0, 1, 0)}):Play()
					TweenService:Create(Main.MainPoint, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
					TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {ImageTransparency = SelectedTheme ~= RayfieldLibrary.Theme.Default and 0.25 or 0.1}):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
				else
					opened = false
					TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -10, 0, 45)}):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 39, 0, 22)}):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 1, 0)}):Play()
					TweenService:Create(ColorPicker.Interact, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
					TweenService:Create(ColorPicker.RGB, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 17, 0, 70)}):Play()
					TweenService:Create(ColorPicker.HexInput, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Position = UDim2.new(0, 17, 0, 90)}):Play()
					TweenService:Create(Display, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
					TweenService:Create(Main.MainPoint, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
					TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {ImageTransparency = 1}):Play()
					TweenService:Create(Background, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
				end

			end)

			local colorPickerInputConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					mainDragging = false
					sliderDragging = false
				end end)
			Main.MouseButton1Down:Connect(function()
				if opened then
					mainDragging = true 
				end
			end)
			Main.MainPoint.MouseButton1Down:Connect(function()
				if opened then
					mainDragging = true 
				end
			end)
			Slider.MouseButton1Down:Connect(function()
				sliderDragging = true 
			end)
			Slider.SliderPoint.MouseButton1Down:Connect(function()
				sliderDragging = true 
			end)
			local h,s,v = ColorPickerSettings.Color:ToHSV()
			local color = Color3.fromHSV(h,s,v) 
			local hex = string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
			ColorPicker.HexInput.InputBox.Text = hex
			local function setDisplay()
				--Main
				Main.MainPoint.Position = UDim2.new(s,-Main.MainPoint.AbsoluteSize.X/2,1-v,-Main.MainPoint.AbsoluteSize.Y/2)
				Main.MainPoint.ImageColor3 = Color3.fromHSV(h,s,v)
				Background.BackgroundColor3 = Color3.fromHSV(h,1,1)
				Display.BackgroundColor3 = Color3.fromHSV(h,s,v)
				--Slider 
				local x = h * Slider.AbsoluteSize.X
				Slider.SliderPoint.Position = UDim2.new(0,x-Slider.SliderPoint.AbsoluteSize.X/2,0.5,0)
				Slider.SliderPoint.ImageColor3 = Color3.fromHSV(h,1,1)
				local color = Color3.fromHSV(h,s,v) 
				local r,g,b = math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
				ColorPicker.RGB.RInput.InputBox.Text = tostring(r)
				ColorPicker.RGB.GInput.InputBox.Text = tostring(g)
				ColorPicker.RGB.BInput.InputBox.Text = tostring(b)
				hex = string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
				ColorPicker.HexInput.InputBox.Text = hex
			end
			setDisplay()
			ColorPicker.HexInput.InputBox.FocusLost:Connect(function()
				if not pcall(function()
						local r, g, b = string.match(ColorPicker.HexInput.InputBox.Text, "^#?(%w%w)(%w%w)(%w%w)$")
						local rgbColor = Color3.fromRGB(tonumber(r, 16),tonumber(g, 16), tonumber(b, 16))
						h,s,v = rgbColor:ToHSV()
						hex = ColorPicker.HexInput.InputBox.Text
						setDisplay()
						ColorPickerSettings.Color = rgbColor
					end) 
				then 
					ColorPicker.HexInput.InputBox.Text = hex 
				end
				pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
				local r,g,b = math.floor((h*255)+0.5),math.floor((s*255)+0.5),math.floor((v*255)+0.5)
				ColorPickerSettings.Color = Color3.fromRGB(r,g,b)
				if not ColorPickerSettings.Ext then
					SaveConfiguration()
				end
			end)
			--RGB
			local function rgbBoxes(box,toChange)
				local value = tonumber(box.Text) 
				local color = Color3.fromHSV(h,s,v) 
				local oldR,oldG,oldB = math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
				local save 
				if toChange == "R" then save = oldR;oldR = value elseif toChange == "G" then save = oldG;oldG = value else save = oldB;oldB = value end
				if value then 
					value = math.clamp(value,0,255)
					h,s,v = Color3.fromRGB(oldR,oldG,oldB):ToHSV()

					setDisplay()
				else 
					box.Text = tostring(save)
				end
				local r,g,b = math.floor((h*255)+0.5),math.floor((s*255)+0.5),math.floor((v*255)+0.5)
				ColorPickerSettings.Color = Color3.fromRGB(r,g,b)
				if not ColorPickerSettings.Ext then
					SaveConfiguration(ColorPickerSettings.Flag..'\n'..tostring(ColorPickerSettings.Color))
				end
			end
			ColorPicker.RGB.RInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.RInput.InputBox,"R")
				pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
			end)
			ColorPicker.RGB.GInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.GInput.InputBox,"G")
				pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
			end)
			ColorPicker.RGB.BInput.InputBox.FocusLost:connect(function()
				rgbBoxes(ColorPicker.RGB.BInput.InputBox,"B")
				pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
			end)

			local colorPickerRenderConnection = RunService.RenderStepped:connect(function()
				if mainDragging then
					local localX = math.clamp(mouse.X-Main.AbsolutePosition.X,0,Main.AbsoluteSize.X)
					local localY = math.clamp(mouse.Y-Main.AbsolutePosition.Y,0,Main.AbsoluteSize.Y)
					Main.MainPoint.Position = UDim2.new(0,localX-Main.MainPoint.AbsoluteSize.X/2,0,localY-Main.MainPoint.AbsoluteSize.Y/2)
					s = localX / Main.AbsoluteSize.X
					v = 1 - (localY / Main.AbsoluteSize.Y)
					Display.BackgroundColor3 = Color3.fromHSV(h,s,v)
					Main.MainPoint.ImageColor3 = Color3.fromHSV(h,s,v)
					Background.BackgroundColor3 = Color3.fromHSV(h,1,1)
					local color = Color3.fromHSV(h,s,v) 
					local r,g,b = math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
					ColorPicker.RGB.RInput.InputBox.Text = tostring(r)
					ColorPicker.RGB.GInput.InputBox.Text = tostring(g)
					ColorPicker.RGB.BInput.InputBox.Text = tostring(b)
					ColorPicker.HexInput.InputBox.Text = string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
					pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
					ColorPickerSettings.Color = Color3.fromRGB(r,g,b)
					if not ColorPickerSettings.Ext then
						SaveConfiguration()
					end
				end
				if sliderDragging then 
					local localX = math.clamp(mouse.X-Slider.AbsolutePosition.X,0,Slider.AbsoluteSize.X)
					h = localX / Slider.AbsoluteSize.X
					Display.BackgroundColor3 = Color3.fromHSV(h,s,v)
					Slider.SliderPoint.Position = UDim2.new(0,localX-Slider.SliderPoint.AbsoluteSize.X/2,0.5,0)
					Slider.SliderPoint.ImageColor3 = Color3.fromHSV(h,1,1)
					Background.BackgroundColor3 = Color3.fromHSV(h,1,1)
					Main.MainPoint.ImageColor3 = Color3.fromHSV(h,s,v)
					local color = Color3.fromHSV(h,s,v) 
					local r,g,b = math.floor((color.R*255)+0.5),math.floor((color.G*255)+0.5),math.floor((color.B*255)+0.5)
					ColorPicker.RGB.RInput.InputBox.Text = tostring(r)
					ColorPicker.RGB.GInput.InputBox.Text = tostring(g)
					ColorPicker.RGB.BInput.InputBox.Text = tostring(b)
					ColorPicker.HexInput.InputBox.Text = string.format("#%02X%02X%02X",color.R*0xFF,color.G*0xFF,color.B*0xFF)
					pcall(function()ColorPickerSettings.Callback(Color3.fromHSV(h,s,v))end)
					ColorPickerSettings.Color = Color3.fromRGB(r,g,b)
					if not ColorPickerSettings.Ext then
						SaveConfiguration()
					end
				end
			end)

			ColorPicker.Destroying:Connect(function()
				if colorPickerRenderConnection then
					colorPickerRenderConnection:Disconnect()
				end
				if colorPickerInputConnection then
					colorPickerInputConnection:Disconnect()
				end
			end)

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and ColorPickerSettings.Flag then
					RayfieldLibrary.Flags[ColorPickerSettings.Flag] = ColorPickerSettings
				end
			end

			function ColorPickerSettings:Set(RGBColor)
				ColorPickerSettings.Color = RGBColor
				h,s,v = ColorPickerSettings.Color:ToHSV()
				color = Color3.fromHSV(h,s,v)
				setDisplay()
			end

			ColorPicker.MouseEnter:Connect(function()
				TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)

			ColorPicker.MouseLeave:Connect(function()
				TweenService:Create(ColorPicker, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				for _, rgbinput in ipairs(ColorPicker.RGB:GetChildren()) do
					if rgbinput:IsA("Frame") then
						rgbinput.BackgroundColor3 = SelectedTheme.InputBackground
						rgbinput.UIStroke.Color = SelectedTheme.InputStroke
					end
				end

				ColorPicker.HexInput.BackgroundColor3 = SelectedTheme.InputBackground
				ColorPicker.HexInput.UIStroke.Color = SelectedTheme.InputStroke
			end)

			return ColorPickerSettings
		end

		-- Section
		function Tab:CreateSection(SectionName)

			local SectionValue = {}

			if SDone then
				local SectionSpace = Elements.Template.SectionSpacing:Clone()
				SectionSpace.Visible = true
				SectionSpace.Parent = TabPage
			end

			local Section = Elements.Template.SectionTitle:Clone()
			Section.Title.Text = SectionName
			Section.Visible = true
			Section.Parent = TabPage

			Section.Title.TextTransparency = 1
			TweenService:Create(Section.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0.4}):Play()

			function SectionValue:Set(NewSection)
				Section.Title.Text = NewSection
			end

			SDone = true

			return SectionValue
		end

		-- Divider
		function Tab:CreateDivider()
			local DividerValue = {}

			local Divider = Elements.Template.Divider:Clone()
			Divider.Visible = true
			Divider.Parent = TabPage

			Divider.Divider.BackgroundTransparency = 1
			TweenService:Create(Divider.Divider, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.85}):Play()

			function DividerValue:Set(Value)
				Divider.Visible = Value
			end

			return DividerValue
		end

		-- Label
		function Tab:CreateLabel(LabelText : string, Icon: number, Color : Color3, IgnoreTheme : boolean)
			local LabelValue = {}

			local Label = Elements.Template.Label:Clone()
			Label.Title.Text = LabelText
			Label.Visible = true
			Label.Parent = TabPage

			Label.BackgroundColor3 = Color or SelectedTheme.SecondaryElementBackground
			Label.UIStroke.Color = Color or SelectedTheme.SecondaryElementStroke

			if Icon then
				local img, rectOffset, rectSize = resolveIcon(Icon)
				Label.Icon.Image = img
				if rectOffset then Label.Icon.ImageRectOffset = rectOffset end
				if rectSize then Label.Icon.ImageRectSize = rectSize end
			else
				Label.Icon.Image = ""
			end

			if Icon and Label:FindFirstChild('Icon') then
				Label.Title.Position = UDim2.new(0, 45, 0.5, 0)
				Label.Title.Size = UDim2.new(1, -100, 0, 14)
				Label.Icon.Visible = true
			end

			Label.Icon.ImageTransparency = 1
			Label.BackgroundTransparency = 1
			Label.UIStroke.Transparency = 1
			Label.Title.TextTransparency = 1

			TweenService:Create(Label, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = Color and 0.8 or 0}):Play()
			TweenService:Create(Label.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = Color and 0.7 or 0}):Play()
			TweenService:Create(Label.Icon, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
			TweenService:Create(Label.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = Color and 0.2 or 0}):Play()	

			function LabelValue:Set(NewLabel, Icon, Color)
				Label.Title.Text = NewLabel

				if Color then
					Label.BackgroundColor3 = Color or SelectedTheme.SecondaryElementBackground
					Label.UIStroke.Color = Color or SelectedTheme.SecondaryElementStroke
				end

				if Icon and Label:FindFirstChild('Icon') then
					Label.Title.Position = UDim2.new(0, 45, 0.5, 0)
					Label.Title.Size = UDim2.new(1, -100, 0, 14)

					local img, rectOffset, rectSize = resolveIcon(Icon)
					Label.Icon.Image = img
					if rectOffset then Label.Icon.ImageRectOffset = rectOffset end
					if rectSize then Label.Icon.ImageRectSize = rectSize end

					Label.Icon.Visible = true
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Label.BackgroundColor3 = IgnoreTheme and (Color or Label.BackgroundColor3) or SelectedTheme.SecondaryElementBackground
				Label.UIStroke.Color = IgnoreTheme and (Color or Label.BackgroundColor3) or SelectedTheme.SecondaryElementStroke
			end)

			return LabelValue
		end

		-- Paragraph
		function Tab:CreateParagraph(ParagraphSettings)
			local ParagraphValue = {}

			local Paragraph = Elements.Template.Paragraph:Clone()
			Paragraph.Title.Text = ParagraphSettings.Title
			Paragraph.Content.Text = ParagraphSettings.Content
			Paragraph.Visible = true
			Paragraph.Parent = TabPage

			Paragraph.BackgroundTransparency = 1
			Paragraph.UIStroke.Transparency = 1
			Paragraph.Title.TextTransparency = 1
			Paragraph.Content.TextTransparency = 1

			Paragraph.BackgroundColor3 = SelectedTheme.SecondaryElementBackground
			Paragraph.UIStroke.Color = SelectedTheme.SecondaryElementStroke

			TweenService:Create(Paragraph, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Paragraph.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Paragraph.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	
			TweenService:Create(Paragraph.Content, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	

			function ParagraphValue:Set(NewParagraphSettings)
				Paragraph.Title.Text = NewParagraphSettings.Title
				Paragraph.Content.Text = NewParagraphSettings.Content
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Paragraph.BackgroundColor3 = SelectedTheme.SecondaryElementBackground
				Paragraph.UIStroke.Color = SelectedTheme.SecondaryElementStroke
			end)

			return ParagraphValue
		end

		-- Input
		function Tab:CreateInput(InputSettings)
			local Input = Elements.Template.Input:Clone()
			Input.Name = InputSettings.Name
			Input.Title.Text = InputSettings.Name
			Input.Visible = true
			Input.Parent = TabPage

			Input.BackgroundTransparency = 1
			Input.UIStroke.Transparency = 1
			Input.Title.TextTransparency = 1

			Input.InputFrame.InputBox.Text = InputSettings.CurrentValue or ''

			Input.InputFrame.BackgroundColor3 = SelectedTheme.InputBackground
			Input.InputFrame.UIStroke.Color = SelectedTheme.InputStroke

			TweenService:Create(Input, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Input.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Input.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	

			Input.InputFrame.InputBox.PlaceholderText = InputSettings.PlaceholderText
			Input.InputFrame.Size = UDim2.new(0, Input.InputFrame.InputBox.TextBounds.X + 24, 0, 30)

			Input.InputFrame.InputBox.FocusLost:Connect(function()
				local Success, Response = pcall(function()
					InputSettings.Callback(Input.InputFrame.InputBox.Text)
					InputSettings.CurrentValue = Input.InputFrame.InputBox.Text
				end)

				if not Success then
					TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
					TweenService:Create(Input.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Input.Title.Text = "Callback Error"
					print("Rayfield | "..InputSettings.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Input.Title.Text = InputSettings.Name
					TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Input.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				if InputSettings.RemoveTextAfterFocusLost then
					Input.InputFrame.InputBox.Text = ""
				end

				if not InputSettings.Ext then
					SaveConfiguration()
				end
			end)

			Input.MouseEnter:Connect(function()
				TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)

			Input.MouseLeave:Connect(function()
				TweenService:Create(Input, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			Input.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
				TweenService:Create(Input.InputFrame, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Input.InputFrame.InputBox.TextBounds.X + 24, 0, 30)}):Play()
			end)

			function InputSettings:Set(text)
				Input.InputFrame.InputBox.Text = text
				InputSettings.CurrentValue = text

				local Success, Response = pcall(function()
					InputSettings.Callback(text)
				end)

				if not InputSettings.Ext then
					SaveConfiguration()
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and InputSettings.Flag then
					RayfieldLibrary.Flags[InputSettings.Flag] = InputSettings
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Input.InputFrame.BackgroundColor3 = SelectedTheme.InputBackground
				Input.InputFrame.UIStroke.Color = SelectedTheme.InputStroke
			end)

			return InputSettings
		end

		-- Dropdown
		function Tab:CreateDropdown(DropdownSettings)
			local Dropdown = Elements.Template.Dropdown:Clone()
			if string.find(DropdownSettings.Name,"closed") then
				Dropdown.Name = "Dropdown"
			else
				Dropdown.Name = DropdownSettings.Name
			end
			Dropdown.Title.Text = DropdownSettings.Name
			Dropdown.Visible = true
			Dropdown.Parent = TabPage

			Dropdown.List.Visible = false
			if DropdownSettings.CurrentOption then
				if type(DropdownSettings.CurrentOption) == "string" then
					DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption}
				end
				if not DropdownSettings.MultipleOptions and type(DropdownSettings.CurrentOption) == "table" then
					DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption[1]}
				end
			else
				DropdownSettings.CurrentOption = {}
			end

			if DropdownSettings.MultipleOptions then
				if DropdownSettings.CurrentOption and type(DropdownSettings.CurrentOption) == "table" then
					if #DropdownSettings.CurrentOption == 1 then
						Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
					elseif #DropdownSettings.CurrentOption == 0 then
						Dropdown.Selected.Text = "None"
					else
						Dropdown.Selected.Text = "Various"
					end
				else
					DropdownSettings.CurrentOption = {}
					Dropdown.Selected.Text = "None"
				end
			else
				Dropdown.Selected.Text = DropdownSettings.CurrentOption[1] or "None"
			end

			Dropdown.Toggle.ImageColor3 = SelectedTheme.TextColor
			TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()

			Dropdown.BackgroundTransparency = 1
			Dropdown.UIStroke.Transparency = 1
			Dropdown.Title.TextTransparency = 1

			Dropdown.Size = UDim2.new(1, -10, 0, 45)

			TweenService:Create(Dropdown, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Dropdown.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	

			for _, ununusedoption in ipairs(Dropdown.List:GetChildren()) do
				if ununusedoption.ClassName == "Frame" and ununusedoption.Name ~= "Placeholder" then
					ununusedoption:Destroy()
				end
			end

			Dropdown.Toggle.Rotation = 180

			Dropdown.Interact.MouseButton1Click:Connect(function()
				TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
				TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
				task.wait(0.1)
				TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
				TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				if Debounce then return end
				if Dropdown.List.Visible then
					Debounce = true
					TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -10, 0, 45)}):Play()
					for _, DropdownOpt in ipairs(Dropdown.List:GetChildren()) do
						if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
							TweenService:Create(DropdownOpt, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
							TweenService:Create(DropdownOpt.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							TweenService:Create(DropdownOpt.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
						end
					end
					TweenService:Create(Dropdown.List, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ScrollBarImageTransparency = 1}):Play()
					TweenService:Create(Dropdown.Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Rotation = 180}):Play()	
					task.wait(0.35)
					Dropdown.List.Visible = false
					Debounce = false
				else
					TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -10, 0, 180)}):Play()
					Dropdown.List.Visible = true
					TweenService:Create(Dropdown.List, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ScrollBarImageTransparency = 0.7}):Play()
					TweenService:Create(Dropdown.Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Rotation = 0}):Play()	
					for _, DropdownOpt in ipairs(Dropdown.List:GetChildren()) do
						if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
							if DropdownOpt.Name ~= Dropdown.Selected.Text then
								TweenService:Create(DropdownOpt.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
							end
							TweenService:Create(DropdownOpt, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
							TweenService:Create(DropdownOpt.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
						end
					end
				end
			end)

			Dropdown.MouseEnter:Connect(function()
				if not Dropdown.List.Visible then
					TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
				end
			end)

			Dropdown.MouseLeave:Connect(function()
				TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			local function SetDropdownOptions()
				for _, Option in ipairs(DropdownSettings.Options) do
					local DropdownOption = Elements.Template.Dropdown.List.Template:Clone()
					DropdownOption.Name = Option
					DropdownOption.Title.Text = Option
					DropdownOption.Parent = Dropdown.List
					DropdownOption.Visible = true

					DropdownOption.BackgroundTransparency = 1
					DropdownOption.UIStroke.Transparency = 1
					DropdownOption.Title.TextTransparency = 1

					--local Dropdown = Tab:CreateDropdown({
					--	Name = "Dropdown Example",
					--	Options = {"Option 1","Option 2"},
					--	CurrentOption = {"Option 1"},
					--  MultipleOptions = true,
					--	Flag = "Dropdown1",
					--	Callback = function(TableOfOptions)

					--	end,
					--})


					DropdownOption.Interact.ZIndex = 50
					DropdownOption.Interact.MouseButton1Click:Connect(function()
						if not DropdownSettings.MultipleOptions and table.find(DropdownSettings.CurrentOption, Option) then 
							return
						end

						if table.find(DropdownSettings.CurrentOption, Option) then
							table.remove(DropdownSettings.CurrentOption, table.find(DropdownSettings.CurrentOption, Option))
							if DropdownSettings.MultipleOptions then
								if #DropdownSettings.CurrentOption == 1 then
									Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
								elseif #DropdownSettings.CurrentOption == 0 then
									Dropdown.Selected.Text = "None"
								else
									Dropdown.Selected.Text = "Various"
								end
							else
								Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
							end
						else
							if not DropdownSettings.MultipleOptions then
								table.clear(DropdownSettings.CurrentOption)
							end
							table.insert(DropdownSettings.CurrentOption, Option)
							if DropdownSettings.MultipleOptions then
								if #DropdownSettings.CurrentOption == 1 then
									Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
								elseif #DropdownSettings.CurrentOption == 0 then
									Dropdown.Selected.Text = "None"
								else
									Dropdown.Selected.Text = "Various"
								end
							else
								Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
							end
							TweenService:Create(DropdownOption.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							TweenService:Create(DropdownOption, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.DropdownSelected}):Play()
							Debounce = true
						end


						local Success, Response = pcall(function()
							DropdownSettings.Callback(DropdownSettings.CurrentOption)
						end)

						if not Success then
							TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
							TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							Dropdown.Title.Text = "Callback Error"
							print("Rayfield | "..DropdownSettings.Name.." Callback Error " ..tostring(Response))
							warn('Check docs.sirius.menu for help with Rayfield specific development.')
							task.wait(0.5)
							Dropdown.Title.Text = DropdownSettings.Name
							TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
							TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
						end

						for _, droption in ipairs(Dropdown.List:GetChildren()) do
							if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" and not table.find(DropdownSettings.CurrentOption, droption.Name) then
								TweenService:Create(droption, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.DropdownUnselected}):Play()
							end
						end
						if not DropdownSettings.MultipleOptions then
							task.wait(0.1)
							TweenService:Create(Dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -10, 0, 45)}):Play()
							for _, DropdownOpt in ipairs(Dropdown.List:GetChildren()) do
								if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
									TweenService:Create(DropdownOpt, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
									TweenService:Create(DropdownOpt.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
									TweenService:Create(DropdownOpt.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
								end
							end
							TweenService:Create(Dropdown.List, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ScrollBarImageTransparency = 1}):Play()
							TweenService:Create(Dropdown.Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Rotation = 180}):Play()	
							task.wait(0.35)
							Dropdown.List.Visible = false
						end
						Debounce = false
						if not DropdownSettings.Ext then
							SaveConfiguration()
						end
					end)

					Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
						DropdownOption.UIStroke.Color = SelectedTheme.ElementStroke
					end)
				end
			end
			SetDropdownOptions()

			for _, droption in ipairs(Dropdown.List:GetChildren()) do
				if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" then
					if not table.find(DropdownSettings.CurrentOption, droption.Name) then
						droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
					else
						droption.BackgroundColor3 = SelectedTheme.DropdownSelected
					end

					Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
						if not table.find(DropdownSettings.CurrentOption, droption.Name) then
							droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
						else
							droption.BackgroundColor3 = SelectedTheme.DropdownSelected
						end
					end)
				end
			end

			function DropdownSettings:Set(NewOption)
				DropdownSettings.CurrentOption = NewOption

				if typeof(DropdownSettings.CurrentOption) == "string" then
					DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption}
				end

				if not DropdownSettings.MultipleOptions then
					DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption[1]}
				end

				if DropdownSettings.MultipleOptions then
					if #DropdownSettings.CurrentOption == 1 then
						Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
					elseif #DropdownSettings.CurrentOption == 0 then
						Dropdown.Selected.Text = "None"
					else
						Dropdown.Selected.Text = "Various"
					end
				else
					Dropdown.Selected.Text = DropdownSettings.CurrentOption[1]
				end


				local Success, Response = pcall(function()
					DropdownSettings.Callback(NewOption)
				end)
				if not Success then
					TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
					TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Dropdown.Title.Text = "Callback Error"
					print("Rayfield | "..DropdownSettings.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Dropdown.Title.Text = DropdownSettings.Name
					TweenService:Create(Dropdown, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Dropdown.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				for _, droption in ipairs(Dropdown.List:GetChildren()) do
					if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" then
						if not table.find(DropdownSettings.CurrentOption, droption.Name) then
							droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
						else
							droption.BackgroundColor3 = SelectedTheme.DropdownSelected
						end
					end
				end
				--SaveConfiguration()
			end

			function DropdownSettings:Refresh(optionsTable: table) -- updates a dropdown with new options from optionsTable
				DropdownSettings.Options = optionsTable
				for _, option in Dropdown.List:GetChildren() do
					if option.ClassName == "Frame" and option.Name ~= "Placeholder" then
						option:Destroy()
					end
				end
				SetDropdownOptions()

				-- Apply selected/unselected background colors to new options
				for _, droption in ipairs(Dropdown.List:GetChildren()) do
					if droption.ClassName == "Frame" and droption.Name ~= "Placeholder" then
						if not table.find(DropdownSettings.CurrentOption, droption.Name) then
							droption.BackgroundColor3 = SelectedTheme.DropdownUnselected
						else
							droption.BackgroundColor3 = SelectedTheme.DropdownSelected
						end
					end
				end

				-- If the dropdown is currently open, make new options visible immediately
				if Dropdown.List.Visible then
					for _, DropdownOpt in ipairs(Dropdown.List:GetChildren()) do
						if DropdownOpt.ClassName == "Frame" and DropdownOpt.Name ~= "Placeholder" then
							DropdownOpt.BackgroundTransparency = 0
							DropdownOpt.Title.TextTransparency = 0
							if not table.find(DropdownSettings.CurrentOption, DropdownOpt.Name) then
								DropdownOpt.UIStroke.Transparency = 0
							end
						end
					end
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and DropdownSettings.Flag then
					RayfieldLibrary.Flags[DropdownSettings.Flag] = DropdownSettings
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Dropdown.Toggle.ImageColor3 = SelectedTheme.TextColor
				TweenService:Create(Dropdown, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			return DropdownSettings
		end

		-- Keybind
		function Tab:CreateKeybind(KeybindSettings)
			local CheckingForKey = false
			local Keybind = Elements.Template.Keybind:Clone()
			Keybind.Name = KeybindSettings.Name
			Keybind.Title.Text = KeybindSettings.Name
			Keybind.Visible = true
			Keybind.Parent = TabPage

			Keybind.BackgroundTransparency = 1
			Keybind.UIStroke.Transparency = 1
			Keybind.Title.TextTransparency = 1

			Keybind.KeybindFrame.BackgroundColor3 = SelectedTheme.InputBackground
			Keybind.KeybindFrame.UIStroke.Color = SelectedTheme.InputStroke

			TweenService:Create(Keybind, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Keybind.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Keybind.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	

			Keybind.KeybindFrame.KeybindBox.Text = KeybindSettings.CurrentKeybind
			Keybind.KeybindFrame.Size = UDim2.new(0, Keybind.KeybindFrame.KeybindBox.TextBounds.X + 24, 0, 30)

			Keybind.KeybindFrame.KeybindBox.Focused:Connect(function()
				CheckingForKey = true
				Keybind.KeybindFrame.KeybindBox.Text = ""
			end)
			Keybind.KeybindFrame.KeybindBox.FocusLost:Connect(function()
				CheckingForKey = false
				if Keybind.KeybindFrame.KeybindBox.Text == nil or Keybind.KeybindFrame.KeybindBox.Text == "" then
					Keybind.KeybindFrame.KeybindBox.Text = KeybindSettings.CurrentKeybind
					if not KeybindSettings.Ext then
						SaveConfiguration()
					end
				end
			end)

			Keybind.MouseEnter:Connect(function()
				TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)

			Keybind.MouseLeave:Connect(function()
				TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			local connection = UserInputService.InputBegan:Connect(function(input, processed)
				if CheckingForKey then
					if input.KeyCode ~= Enum.KeyCode.Unknown then
						local SplitMessage = string.split(tostring(input.KeyCode), ".")
						local NewKeyNoEnum = SplitMessage[3]
						Keybind.KeybindFrame.KeybindBox.Text = tostring(NewKeyNoEnum)
						KeybindSettings.CurrentKeybind = tostring(NewKeyNoEnum)
						Keybind.KeybindFrame.KeybindBox:ReleaseFocus()
						if not KeybindSettings.Ext then
							SaveConfiguration()
						end

						if KeybindSettings.CallOnChange then
							KeybindSettings.Callback(tostring(NewKeyNoEnum))
						end
					end
				elseif not KeybindSettings.CallOnChange and KeybindSettings.CurrentKeybind ~= nil and (input.KeyCode == Enum.KeyCode[KeybindSettings.CurrentKeybind] and not processed) then -- Test
					local Held = true
					local Connection
					Connection = input.Changed:Connect(function(prop)
						if prop == "UserInputState" then
							Connection:Disconnect()
							Held = false
						end
					end)

					if not KeybindSettings.HoldToInteract then
						local Success, Response = pcall(KeybindSettings.Callback)
						if not Success then
							TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
							TweenService:Create(Keybind.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
							Keybind.Title.Text = "Callback Error"
							print("Rayfield | "..KeybindSettings.Name.." Callback Error " ..tostring(Response))
							warn('Check docs.sirius.menu for help with Rayfield specific development.')
							task.wait(0.5)
							Keybind.Title.Text = KeybindSettings.Name
							TweenService:Create(Keybind, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
							TweenService:Create(Keybind.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
						end
					else
						task.wait(0.25)
						if Held then
							local Loop; Loop = RunService.Stepped:Connect(function()
								if not Held then
									KeybindSettings.Callback(false) -- maybe pcall this
									Loop:Disconnect()
								else
									KeybindSettings.Callback(true) -- maybe pcall this
								end
							end)
						end
					end
				end
			end)
			table.insert(keybindConnections, connection)

			Keybind.KeybindFrame.KeybindBox:GetPropertyChangedSignal("Text"):Connect(function()
				TweenService:Create(Keybind.KeybindFrame, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Keybind.KeybindFrame.KeybindBox.TextBounds.X + 24, 0, 30)}):Play()
			end)

			function KeybindSettings:Set(NewKeybind)
				Keybind.KeybindFrame.KeybindBox.Text = tostring(NewKeybind)
				KeybindSettings.CurrentKeybind = tostring(NewKeybind)
				Keybind.KeybindFrame.KeybindBox:ReleaseFocus()
				if not KeybindSettings.Ext then
					SaveConfiguration()
				end

				if KeybindSettings.CallOnChange then
					KeybindSettings.Callback(tostring(NewKeybind))
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and KeybindSettings.Flag then
					RayfieldLibrary.Flags[KeybindSettings.Flag] = KeybindSettings
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Keybind.KeybindFrame.BackgroundColor3 = SelectedTheme.InputBackground
				Keybind.KeybindFrame.UIStroke.Color = SelectedTheme.InputStroke
			end)

			return KeybindSettings
		end

		-- Toggle
		function Tab:CreateToggle(ToggleSettings)
			local ToggleValue = {}

			local Toggle = Elements.Template.Toggle:Clone()
			Toggle.Name = ToggleSettings.Name
			Toggle.Title.Text = ToggleSettings.Name
			Toggle.Visible = true
			Toggle.Parent = TabPage

			Toggle.BackgroundTransparency = 1
			Toggle.UIStroke.Transparency = 1
			Toggle.Title.TextTransparency = 1
			Toggle.Switch.BackgroundColor3 = SelectedTheme.ToggleBackground

			if SelectedTheme ~= RayfieldLibrary.Theme.Default then
				Toggle.Switch.Shadow.Visible = false
			end

			TweenService:Create(Toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Toggle.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	

			if ToggleSettings.CurrentValue == true then
				Toggle.Switch.Indicator.Position = UDim2.new(1, -20, 0.5, 0)
				Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleEnabledStroke
				Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleEnabled
				Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleEnabledOuterStroke
			else
				Toggle.Switch.Indicator.Position = UDim2.new(1, -40, 0.5, 0)
				Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleDisabledStroke
				Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleDisabled
				Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleDisabledOuterStroke
			end

			Toggle.MouseEnter:Connect(function()
				TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)

			Toggle.MouseLeave:Connect(function()
				TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			Toggle.Interact.MouseButton1Click:Connect(function()
				if ToggleSettings.CurrentValue == true then
					ToggleSettings.CurrentValue = false
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -40, 0.5, 0)}):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleDisabledStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = SelectedTheme.ToggleDisabled}):Play()
					TweenService:Create(Toggle.Switch.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleDisabledOuterStroke}):Play()
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()	
				else
					ToggleSettings.CurrentValue = true
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 0.5, 0)}):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleEnabledStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = SelectedTheme.ToggleEnabled}):Play()
					TweenService:Create(Toggle.Switch.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleEnabledOuterStroke}):Play()
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()		
				end

				local Success, Response = pcall(function()
					if debugX then warn('Running toggle \''..ToggleSettings.Name..'\' (Interact)') end

					ToggleSettings.Callback(ToggleSettings.CurrentValue)
				end)

				if not Success then
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Toggle.Title.Text = "Callback Error"
					print("Rayfield | "..ToggleSettings.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Toggle.Title.Text = ToggleSettings.Name
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				if not ToggleSettings.Ext then
					SaveConfiguration()
				end
			end)

			function ToggleSettings:Set(NewToggleValue)
				if NewToggleValue == true then
					ToggleSettings.CurrentValue = true
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 0.5, 0)}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,12,0,12)}):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleEnabledStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = SelectedTheme.ToggleEnabled}):Play()
					TweenService:Create(Toggle.Switch.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleEnabledOuterStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,17,0,17)}):Play()	
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()	
				else
					ToggleSettings.CurrentValue = false
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -40, 0.5, 0)}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,12,0,12)}):Play()
					TweenService:Create(Toggle.Switch.Indicator.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleDisabledStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = SelectedTheme.ToggleDisabled}):Play()
					TweenService:Create(Toggle.Switch.UIStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Color = SelectedTheme.ToggleDisabledOuterStroke}):Play()
					TweenService:Create(Toggle.Switch.Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,17,0,17)}):Play()
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()	
				end

				local Success, Response = pcall(function()
					if debugX then warn('Running toggle \''..ToggleSettings.Name..'\' (:Set)') end

					ToggleSettings.Callback(ToggleSettings.CurrentValue)
				end)

				if not Success then
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Toggle.Title.Text = "Callback Error"
					print("Rayfield | "..ToggleSettings.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Toggle.Title.Text = ToggleSettings.Name
					TweenService:Create(Toggle, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Toggle.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				if not ToggleSettings.Ext then
					SaveConfiguration()
				end
			end

			if not ToggleSettings.Ext then
				if Settings.ConfigurationSaving then
					if Settings.ConfigurationSaving.Enabled and ToggleSettings.Flag then
						RayfieldLibrary.Flags[ToggleSettings.Flag] = ToggleSettings
					end
				end
			end


			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				Toggle.Switch.BackgroundColor3 = SelectedTheme.ToggleBackground

				if SelectedTheme ~= RayfieldLibrary.Theme.Default then
					Toggle.Switch.Shadow.Visible = false
				end

				task.wait()

				if not ToggleSettings.CurrentValue then
					Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleDisabledStroke
					Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleDisabled
					Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleDisabledOuterStroke
				else
					Toggle.Switch.Indicator.UIStroke.Color = SelectedTheme.ToggleEnabledStroke
					Toggle.Switch.Indicator.BackgroundColor3 = SelectedTheme.ToggleEnabled
					Toggle.Switch.UIStroke.Color = SelectedTheme.ToggleEnabledOuterStroke
				end
			end)

			return ToggleSettings
		end

		-- Slider
		function Tab:CreateSlider(SliderSettings)
			local SLDragging = false
			local Slider = Elements.Template.Slider:Clone()
			Slider.Name = SliderSettings.Name
			Slider.Title.Text = SliderSettings.Name
			Slider.Visible = true
			Slider.Parent = TabPage

			Slider.BackgroundTransparency = 1
			Slider.UIStroke.Transparency = 1
			Slider.Title.TextTransparency = 1

			if SelectedTheme ~= RayfieldLibrary.Theme.Default then
				Slider.Main.Shadow.Visible = false
			end

			Slider.Main.BackgroundColor3 = SelectedTheme.SliderBackground
			Slider.Main.UIStroke.Color = SelectedTheme.SliderStroke
			Slider.Main.Progress.UIStroke.Color = SelectedTheme.SliderStroke
			Slider.Main.Progress.BackgroundColor3 = SelectedTheme.SliderProgress

			TweenService:Create(Slider, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			TweenService:Create(Slider.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			TweenService:Create(Slider.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()	

			Slider.Main.Progress.Size =	UDim2.new(0, Slider.Main.AbsoluteSize.X * ((SliderSettings.CurrentValue - SliderSettings.Range[1]) / (SliderSettings.Range[2] - SliderSettings.Range[1])) > 5 and Slider.Main.AbsoluteSize.X * ((SliderSettings.CurrentValue - SliderSettings.Range[1]) / (SliderSettings.Range[2] - SliderSettings.Range[1])) or 5, 1, 0)

			if not SliderSettings.Suffix then
				Slider.Main.Information.Text = tostring(SliderSettings.CurrentValue)
			else
				Slider.Main.Information.Text = tostring(SliderSettings.CurrentValue) .. " " .. SliderSettings.Suffix
			end

			Slider.MouseEnter:Connect(function()
				TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)

			Slider.MouseLeave:Connect(function()
				TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)

			Slider.Main.Interact.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
					TweenService:Create(Slider.Main.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					TweenService:Create(Slider.Main.Progress.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					SLDragging = true 
				end 
			end)

			Slider.Main.Interact.InputEnded:Connect(function(Input) 
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
					TweenService:Create(Slider.Main.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0.4}):Play()
					TweenService:Create(Slider.Main.Progress.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0.3}):Play()
					SLDragging = false 
				end 
			end)

			Slider.Main.Interact.MouseButton1Down:Connect(function(X)
				local Current = Slider.Main.Progress.AbsolutePosition.X + Slider.Main.Progress.AbsoluteSize.X
				local Start = Current
				local Location = X
				local Loop; Loop = RunService.Stepped:Connect(function()
					if SLDragging then
						Location = UserInputService:GetMouseLocation().X
						Current = Current + 0.025 * (Location - Start)

						if Location < Slider.Main.AbsolutePosition.X then
							Location = Slider.Main.AbsolutePosition.X
						elseif Location > Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X then
							Location = Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X
						end

						if Current < Slider.Main.AbsolutePosition.X + 5 then
							Current = Slider.Main.AbsolutePosition.X + 5
						elseif Current > Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X then
							Current = Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X
						end

						if Current <= Location and (Location - Start) < 0 then
							Start = Location
						elseif Current >= Location and (Location - Start) > 0 then
							Start = Location
						end
						TweenService:Create(Slider.Main.Progress, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Current - Slider.Main.AbsolutePosition.X, 1, 0)}):Play()
						local NewValue = SliderSettings.Range[1] + (Location - Slider.Main.AbsolutePosition.X) / Slider.Main.AbsoluteSize.X * (SliderSettings.Range[2] - SliderSettings.Range[1])

						NewValue = math.floor(NewValue / SliderSettings.Increment + 0.5) * (SliderSettings.Increment * 10000000) / 10000000
						NewValue = math.clamp(NewValue, SliderSettings.Range[1], SliderSettings.Range[2])

						if not SliderSettings.Suffix then
							Slider.Main.Information.Text = tostring(NewValue)
						else
							Slider.Main.Information.Text = tostring(NewValue) .. " " .. SliderSettings.Suffix
						end

						if SliderSettings.CurrentValue ~= NewValue then
							local Success, Response = pcall(function()
								SliderSettings.Callback(NewValue)
							end)
							if not Success then
								TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
								TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
								Slider.Title.Text = "Callback Error"
								print("Rayfield | "..SliderSettings.Name.." Callback Error " ..tostring(Response))
								warn('Check docs.sirius.menu for help with Rayfield specific development.')
								task.wait(0.5)
								Slider.Title.Text = SliderSettings.Name
								TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
								TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
							end

							SliderSettings.CurrentValue = NewValue
							if not SliderSettings.Ext then
								SaveConfiguration()
							end
						end
					else
						TweenService:Create(Slider.Main.Progress, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Location - Slider.Main.AbsolutePosition.X > 5 and Location - Slider.Main.AbsolutePosition.X or 5, 1, 0)}):Play()
						Loop:Disconnect()
					end
				end)
			end)

			function SliderSettings:Set(NewVal)
				local NewVal = math.clamp(NewVal, SliderSettings.Range[1], SliderSettings.Range[2])

				TweenService:Create(Slider.Main.Progress, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, Slider.Main.AbsoluteSize.X * ((NewVal - SliderSettings.Range[1]) / (SliderSettings.Range[2] - SliderSettings.Range[1])) > 5 and Slider.Main.AbsoluteSize.X * ((NewVal - SliderSettings.Range[1]) / (SliderSettings.Range[2] - SliderSettings.Range[1])) or 5, 1, 0)}):Play()
				Slider.Main.Information.Text = tostring(NewVal) .. " " .. (SliderSettings.Suffix or "")

				local Success, Response = pcall(function()
					SliderSettings.Callback(NewVal)
				end)

				if not Success then
					TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
					TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
					Slider.Title.Text = "Callback Error"
					print("Rayfield | "..SliderSettings.Name.." Callback Error " ..tostring(Response))
					warn('Check docs.sirius.menu for help with Rayfield specific development.')
					task.wait(0.5)
					Slider.Title.Text = SliderSettings.Name
					TweenService:Create(Slider, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
					TweenService:Create(Slider.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end

				SliderSettings.CurrentValue = NewVal
				if not SliderSettings.Ext then
					SaveConfiguration()
				end
			end

			if Settings.ConfigurationSaving then
				if Settings.ConfigurationSaving.Enabled and SliderSettings.Flag then
					RayfieldLibrary.Flags[SliderSettings.Flag] = SliderSettings
				end
			end

			Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
				if SelectedTheme ~= RayfieldLibrary.Theme.Default then
					Slider.Main.Shadow.Visible = false
				end

				Slider.Main.BackgroundColor3 = SelectedTheme.SliderBackground
				Slider.Main.UIStroke.Color = SelectedTheme.SliderStroke
				Slider.Main.Progress.UIStroke.Color = SelectedTheme.SliderStroke
				Slider.Main.Progress.BackgroundColor3 = SelectedTheme.SliderProgress
			end)

			return SliderSettings
		end

		Rayfield.Main:GetPropertyChangedSignal('BackgroundColor3'):Connect(function()
			TabButton.UIStroke.Color = SelectedTheme.TabStroke

			if Elements.UIPageLayout.CurrentPage == TabPage then
				TabButton.BackgroundColor3 = SelectedTheme.TabBackgroundSelected
				TabButton.Image.ImageColor3 = SelectedTheme.SelectedTabTextColor
				TabButton.Title.TextColor3 = SelectedTheme.SelectedTabTextColor
			else
				TabButton.BackgroundColor3 = SelectedTheme.TabBackground
				TabButton.Image.ImageColor3 = SelectedTheme.TabTextColor
				TabButton.Title.TextColor3 = SelectedTheme.TabTextColor
			end
		end)

		return Tab
	end

	Elements.Visible = true


	task.wait(1.1)
	TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 390, 0, 90)}):Play()
	task.wait(0.3)
	TweenService:Create(LoadingFrame.Title, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(LoadingFrame.Subtitle, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	TweenService:Create(LoadingFrame.Version, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
	task.wait(0.1)
	TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = useMobileSizing and UDim2.new(0, 500, 0, 275) or UDim2.new(0, 500, 0, 475)}):Play()
	TweenService:Create(Main.Shadow.Image, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {ImageTransparency = 0.6}):Play()

	Topbar.BackgroundTransparency = 1
	Topbar.Divider.Size = UDim2.new(0, 0, 0, 1)
	Topbar.Divider.BackgroundColor3 = SelectedTheme.ElementStroke
	Topbar.CornerRepair.BackgroundTransparency = 1
	Topbar.Title.TextTransparency = 1
	Topbar.Search.ImageTransparency = 1
	if Topbar:FindFirstChild('Settings') then
		Topbar.Settings.ImageTransparency = 1
	end
	Topbar.ChangeSize.ImageTransparency = 1
	Topbar.Hide.ImageTransparency = 1


	task.wait(0.5)
	Topbar.Visible = true
	TweenService:Create(Topbar, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	TweenService:Create(Topbar.CornerRepair, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
	task.wait(0.1)
	TweenService:Create(Topbar.Divider, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, 1)}):Play()
	TweenService:Create(Topbar.Title, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
	task.wait(0.05)
	TweenService:Create(Topbar.Search, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	task.wait(0.05)
	if Topbar:FindFirstChild('Settings') then
		TweenService:Create(Topbar.Settings, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
		task.wait(0.05)
	end
	TweenService:Create(Topbar.ChangeSize, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	task.wait(0.05)
	TweenService:Create(Topbar.Hide, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
	task.wait(0.3)

	if dragBar then
		TweenService:Create(dragBarCosmetic, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
	end

	function Window.ModifyTheme(NewTheme)
		local success = pcall(ChangeTheme, NewTheme)
		if not success then
			RayfieldLibrary:Notify({Title = 'Unable to Change Theme', Content = 'We are unable find a theme on file.', Image = 4400704299})
		else
			RayfieldLibrary:Notify({Title = 'Theme Changed', Content = 'Successfully changed theme to '..(typeof(NewTheme) == 'string' and NewTheme or 'Custom Theme')..'.', Image = 4483362748})
		end
	end

	local success, result = pcall(function()
		createSettings(Window)
	end)

	if not success then warn('Rayfield had an issue creating settings.') end

	-- Report after createSettings so loadSettings() has run and usageAnalytics reflects the user's saved preference
	if reporter and getSetting("System", "usageAnalytics") then
		local themeName = "Default"
		if Settings.Theme then
			if type(Settings.Theme) == "string" then
				themeName = Settings.Theme
			elseif type(Settings.Theme) == "table" then
				themeName = "Custom"
			end
		end

		local discordInvite = nil
		if Settings.Discord and Settings.Discord.Enabled and Settings.Discord.Invite and Settings.Discord.Invite ~= "" then
			local raw = tostring(Settings.Discord.Invite)
			-- Normalize: strip URL prefixes to extract just the invite code
			discordInvite = (raw:match("discord%.gg/([%w%-]+)") or raw:match("discord%.com/invite/([%w%-]+)") or raw):sub(1, 32)
		end

		local sampleSend = false

		-- Random Sampling Test
		if not Settings.ScriptID and math.random() > 0.4 then
			sampleSend = true
		end

		--if Settings.ScriptID then
			reporter:windowCreated({
				script_name        = Settings.Name or "Unknown",
				script_version     = Release,
				interface_version  = InterfaceBuild,
				theme              = themeName,
				is_mobile          = useMobileSizing and true or false,
				has_key_system     = Settings.KeySystem and true or false,
				discord_invite     = discordInvite,
				config_saving      = (Settings.ConfigurationSaving and Settings.ConfigurationSaving.Enabled) and true or false,
				script_id          = Settings.ScriptID or sampleSend and 'sid_tzfyxawonjx9' or nil,
				verification_token = Settings.VerificationToken,
			})
		--end
	end

	return Window
end

local function setVisibility(visibility: boolean, notify: boolean?)
	if Debounce then return end
	if visibility then
		Hidden = false
		Unhide()
	else
		Hidden = true
		Hide(notify)
	end
end

function RayfieldLibrary:SetVisibility(visibility: boolean)
	setVisibility(visibility, false)
end

function RayfieldLibrary:IsVisible(): boolean
	return not Hidden
end

local hideHotkeyConnection -- Has to be initialized here since the connection is made later in the script
function RayfieldLibrary:Destroy()
	rayfieldDestroyed = true
	if hideHotkeyConnection then
		hideHotkeyConnection:Disconnect()
	end
	for _, connection in keybindConnections do
		connection:Disconnect()
	end
	Rayfield:Destroy()
end

Topbar.ChangeSize.MouseButton1Click:Connect(function()
	if Debounce then return end
	if Minimised then
		Minimised = false
		Maximise()
	else
		Minimised = true
		Minimise()
	end
end)

Main.Search.Input:GetPropertyChangedSignal('Text'):Connect(function()
	if #Main.Search.Input.Text > 0 then
		if not Elements.UIPageLayout.CurrentPage:FindFirstChild('SearchTitle-fsefsefesfsefesfesfThanks') then 
			local searchTitle = Elements.Template.SectionTitle:Clone()
			searchTitle.Parent = Elements.UIPageLayout.CurrentPage
			searchTitle.Name = 'SearchTitle-fsefsefesfsefesfesfThanks'
			searchTitle.LayoutOrder = -100
			searchTitle.Title.Text = "Results from '"..Elements.UIPageLayout.CurrentPage.Name.."'"
			searchTitle.Visible = true
		end
	else
		local searchTitle = Elements.UIPageLayout.CurrentPage:FindFirstChild('SearchTitle-fsefsefesfsefesfesfThanks')

		if searchTitle then
			searchTitle:Destroy()
		end
	end

	for _, element in ipairs(Elements.UIPageLayout.CurrentPage:GetChildren()) do
		if element.ClassName ~= 'UIListLayout' and element.Name ~= 'Placeholder' and element.Name ~= 'SearchTitle-fsefsefesfsefesfesfThanks' then
			if element.Name == 'SectionTitle' then
				if #Main.Search.Input.Text == 0 then
					element.Visible = true
				else
					element.Visible = false
				end
			else
				if string.lower(element.Name):find(string.lower(Main.Search.Input.Text), 1, true) then
					element.Visible = true
				else
					element.Visible = false
				end
			end
		end
	end
end)

Main.Search.Input.FocusLost:Connect(function(enterPressed)
	if #Main.Search.Input.Text == 0 and searchOpen then
		task.wait(0.12)
		closeSearch()
	end
end)

Topbar.Search.MouseButton1Click:Connect(function()
	task.spawn(function()
		if searchOpen then
			closeSearch()
		else
			openSearch()
		end
	end)
end)

if Topbar:FindFirstChild('Settings') then
	Topbar.Settings.MouseButton1Click:Connect(function()
		task.spawn(function()
			for _, OtherTabButton in ipairs(TabList:GetChildren()) do
				if OtherTabButton.Name ~= "Template" and OtherTabButton.ClassName == "Frame" and OtherTabButton.Name ~= "Placeholder" then
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundColor3 = SelectedTheme.TabBackground}):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextColor3 = SelectedTheme.TabTextColor}):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageColor3 = SelectedTheme.TabTextColor}):Play()
					TweenService:Create(OtherTabButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0.7}):Play()
					TweenService:Create(OtherTabButton.Title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {TextTransparency = 0.2}):Play()
					TweenService:Create(OtherTabButton.Image, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.2}):Play()
					TweenService:Create(OtherTabButton.UIStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Transparency = 0.5}):Play()
				end
			end

			Elements.UIPageLayout:JumpTo(Elements['Rayfield Settings'])
		end)
	end)

end


Topbar.Hide.MouseButton1Click:Connect(function()
	setVisibility(Hidden, not useMobileSizing)
end)

hideHotkeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
	if (input.KeyCode == Enum.KeyCode[getSetting("General", "rayfieldOpen")]) and not processed then
		if Debounce then return end
		if Hidden then
			Hidden = false
			Unhide()
		else
			Hidden = true
			Hide()
		end
	end
end)

if MPrompt then
	MPrompt.Interact.MouseButton1Click:Connect(function()
		if Debounce then return end
		if Hidden then
			Hidden = false
			Unhide()
		end
	end)
end

for _, TopbarButton in ipairs(Topbar:GetChildren()) do
	if TopbarButton.ClassName == "ImageButton" and TopbarButton.Name ~= 'Icon' then
		TopbarButton.MouseEnter:Connect(function()
			TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0}):Play()
		end)

		TopbarButton.MouseLeave:Connect(function()
			TweenService:Create(TopbarButton, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {ImageTransparency = 0.8}):Play()
		end)
	end
end


function RayfieldLibrary:LoadConfiguration()
	local config

	if debugX then
		warn('Loading Configuration')
	end

	if useStudio then
		config = [[{"Toggle1adwawd":true,"ColorPicker1awd":{"B":255,"G":255,"R":255},"Slider1dawd":100,"ColorPicfsefker1":{"B":255,"G":255,"R":255},"Slidefefsr1":80,"dawdawd":"","Input1":"hh","Keybind1":"B","Dropdown1":["Ocean"]}]]
	end

	if CEnabled then
		local notified
		local loaded

		local success, result = pcall(function()
			if useStudio and config then
				loaded = LoadConfiguration(config)
				return
			end

			if isfile then 
				if callSafely(isfile, ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension) then
					loaded = LoadConfiguration(callSafely(readfile, ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension))
				end
			else
				notified = true
				RayfieldLibrary:Notify({Title = "Rayfield Configurations", Content = "We couldn't enable Configuration Saving as you are not using software with filesystem support.", Image = 4384402990})
			end
		end)

		if success and loaded and not notified then
			RayfieldLibrary:Notify({Title = "Rayfield Configurations", Content = "The configuration file for this script has been loaded from a previous session.", Image = 4384403532})
		elseif not success and not notified then
			warn('Rayfield Configurations Error | '..tostring(result))
			RayfieldLibrary:Notify({Title = "Rayfield Configurations", Content = "We've encountered an issue loading your configuration correctly.\n\nCheck the Developer Console for more information.", Image = 4384402990})
		end
	end

	globalLoaded = true
end



if useStudio then
	-- run w/ studio
	-- Feel free to place your own script here to see how it'd work in Roblox Studio before running it on your execution software.


	--local Window = RayfieldLibrary:CreateWindow({
	--	Name = "Rayfield Example Window",
	--	LoadingTitle = "Rayfield Interface Suite",
	--	Theme = 'Default',
	--	Icon = 0,
	--	LoadingSubtitle = "by Sirius",
	--	ConfigurationSaving = {
	--		Enabled = true,
	--		FolderName = nil, -- Create a custom folder for your hub/game
	--		FileName = "Big Hub52"
	--	},
	--	Discord = {
	--		Enabled = false,
	--		Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
	--		RememberJoins = true -- Set this to false to make them join the discord every time they load it up
	--	},
	--	KeySystem = false, -- Set this to true to use our key system
	--	KeySettings = {
	--		Title = "Untitled",
	--		Subtitle = "Key System",
	--		Note = "No method of obtaining the key is provided",
	--		FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
	--		SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
	--		GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
	--		Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
	--	}
	--})

	--local Tab = Window:CreateTab("Tab Example", 'key-round') -- Title, Image
	--local Tab2 = Window:CreateTab("Tab Example 2", 4483362458) -- Title, Image

	--local Section = Tab2:CreateSection("Section")


	--local ColorPicker = Tab2:CreateColorPicker({
	--	Name = "Color Picker",
	--	Color = Color3.fromRGB(255,255,255),
	--	Flag = "ColorPicfsefker1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place every time the color picker is moved/changed
	--		-- The variable (Value) is a Color3fromRGB value based on which color is selected
	--	end
	--})

	--local Slider = Tab2:CreateSlider({
	--	Name = "Slider Example",
	--	Range = {0, 100},
	--	Increment = 10,
	--	Suffix = "Bananas",
	--	CurrentValue = 40,
	--	Flag = "Slidefefsr1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place when the slider changes
	--		-- The variable (Value) is a number which correlates to the value the slider is currently at
	--	end,
	--})

	--local Input = Tab2:CreateInput({
	--	Name = "Input Example",
	--	CurrentValue = '',
	--	PlaceholderText = "Input Placeholder",
	--	Flag = 'dawdawd',
	--	RemoveTextAfterFocusLost = false,
	--	Callback = function(Text)
	--		-- The function that takes place when the input is changed
	--		-- The variable (Text) is a string for the value in the text box
	--	end,
	--})


	----RayfieldLibrary:Notify({Title = "Rayfield Interface", Content = "Welcome to Rayfield. These - are the brand new notification design for Rayfield, with custom sizing and Rayfield calculated wait times.", Image = 4483362458})

	--local Section = Tab:CreateSection("Section Example")

	--local Button = Tab:CreateButton({
	--	Name = "Change Theme",
	--	Callback = function()
	--		-- The function that takes place when the button is pressed
	--		Window.ModifyTheme('DarkBlue')
	--	end,
	--})

	--local Toggle = Tab:CreateToggle({
	--	Name = "Toggle Example",
	--	CurrentValue = false,
	--	Flag = "Toggle1adwawd", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place when the toggle is pressed
	--		-- The variable (Value) is a boolean on whether the toggle is true or false
	--	end,
	--})

	--local ColorPicker = Tab:CreateColorPicker({
	--	Name = "Color Picker",
	--	Color = Color3.fromRGB(255,255,255),
	--	Flag = "ColorPicker1awd", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place every time the color picker is moved/changed
	--		-- The variable (Value) is a Color3fromRGB value based on which color is selected
	--	end
	--})

	--local Slider = Tab:CreateSlider({
	--	Name = "Slider Example",
	--	Range = {0, 100},
	--	Increment = 10,
	--	Suffix = "Bananas",
	--	CurrentValue = 40,
	--	Flag = "Slider1dawd", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Value)
	--		-- The function that takes place when the slider changes
	--		-- The variable (Value) is a number which correlates to the value the slider is currently at
	--	end,
	--})

	--local Input = Tab:CreateInput({
	--	Name = "Input Example",
	--	CurrentValue = "Helo",
	--	PlaceholderText = "Adaptive Input",
	--	RemoveTextAfterFocusLost = false,
	--	Flag = 'Input1',
	--	Callback = function(Text)
	--		-- The function that takes place when the input is changed
	--		-- The variable (Text) is a string for the value in the text box
	--	end,
	--})

	--local thoptions = {}
	--for themename, theme in pairs(RayfieldLibrary.Theme) do
	--	table.insert(thoptions, themename)
	--end

	--local Dropdown = Tab:CreateDropdown({
	--	Name = "Theme",
	--	Options = thoptions,
	--	CurrentOption = {"Default"},
	--	MultipleOptions = false,
	--	Flag = "Dropdown1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Options)
	--		--Window.ModifyTheme(Options[1])
	--		-- The function that takes place when the selected option is changed
	--		-- The variable (Options) is a table of strings for the current selected options
	--	end,
	--})


	--Window.ModifyTheme({
	--	TextColor = Color3.fromRGB(50, 55, 60),
	--	Background = Color3.fromRGB(240, 245, 250),
	--	Topbar = Color3.fromRGB(215, 225, 235),
	--	Shadow = Color3.fromRGB(200, 210, 220),

	--	NotificationBackground = Color3.fromRGB(210, 220, 230),
	--	NotificationActionsBackground = Color3.fromRGB(225, 230, 240),

	--	TabBackground = Color3.fromRGB(200, 210, 220),
	--	TabStroke = Color3.fromRGB(180, 190, 200),
	--	TabBackgroundSelected = Color3.fromRGB(175, 185, 200),
	--	TabTextColor = Color3.fromRGB(50, 55, 60),
	--	SelectedTabTextColor = Color3.fromRGB(30, 35, 40),

	--	ElementBackground = Color3.fromRGB(210, 220, 230),
	--	ElementBackgroundHover = Color3.fromRGB(220, 230, 240),
	--	SecondaryElementBackground = Color3.fromRGB(200, 210, 220),
	--	ElementStroke = Color3.fromRGB(190, 200, 210),
	--	SecondaryElementStroke = Color3.fromRGB(180, 190, 200),

	--	SliderBackground = Color3.fromRGB(200, 220, 235),  -- Lighter shade
	--	SliderProgress = Color3.fromRGB(70, 130, 180),
	--	SliderStroke = Color3.fromRGB(150, 180, 220),

	--	ToggleBackground = Color3.fromRGB(210, 220, 230),
	--	ToggleEnabled = Color3.fromRGB(70, 160, 210),
	--	ToggleDisabled = Color3.fromRGB(180, 180, 180),
	--	ToggleEnabledStroke = Color3.fromRGB(60, 150, 200),
	--	ToggleDisabledStroke = Color3.fromRGB(140, 140, 140),
	--	ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 140),
	--	ToggleDisabledOuterStroke = Color3.fromRGB(120, 120, 130),

	--	DropdownSelected = Color3.fromRGB(220, 230, 240),
	--	DropdownUnselected = Color3.fromRGB(200, 210, 220),

	--	InputBackground = Color3.fromRGB(220, 230, 240),
	--	InputStroke = Color3.fromRGB(180, 190, 200),
	--	PlaceholderColor = Color3.fromRGB(150, 150, 150)
	--})

	--local Keybind = Tab:CreateKeybind({
	--	Name = "Keybind Example",
	--	CurrentKeybind = "Q",
	--	HoldToInteract = false,
	--	Flag = "Keybind1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	--	Callback = function(Keybind)
	--		-- The function that takes place when the keybind is pressed
	--		-- The variable (Keybind) is a boolean for whether the keybind is being held or not (HoldToInteract needs to be true)
	--	end,
	--})

	--local Label = Tab:CreateLabel("Label Example")

	--local Label2 = Tab:CreateLabel("Warning", 4483362458, Color3.fromRGB(255, 159, 49),  true)

	--local Paragraph = Tab:CreateParagraph({Title = "Paragraph Example", Content = "Paragraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph ExampleParagraph Example"})
end

if CEnabled and Main:FindFirstChild('Notice') then
	Main.Notice.BackgroundTransparency = 1
	Main.Notice.Title.TextTransparency = 1
	Main.Notice.Size = UDim2.new(0, 0, 0, 0)
	Main.Notice.Position = UDim2.new(0.5, 0, 0, -100)
	Main.Notice.Visible = true


	TweenService:Create(Main.Notice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 280, 0, 35), Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 0.5}):Play()
	TweenService:Create(Main.Notice.Title, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0.1}):Play()
end
-- AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA why :(
--if not useStudio then
--	task.spawn(loadWithTimeout, "https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/boost.lua")
--end

task.delay(4, function()
	RayfieldLibrary.LoadConfiguration()
	if Main:FindFirstChild('Notice') and Main.Notice.Visible then
		TweenService:Create(Main.Notice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 100, 0, 25), Position = UDim2.new(0.5, 0, 0, -100), BackgroundTransparency = 1}):Play()
		TweenService:Create(Main.Notice.Title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()

		task.wait(0.5)
		Main.Notice.Visible = false
	end
end)

return RayfieldLibrary
end)()
local function createButton(tab, name, url)
    if url and url ~= "" then
        tab:CreateButton({ Name = name, Callback = function() loadstring(game:HttpGet(url))() end })
    end
end

local function createCodeButton(tab, name, code)
    if code and code ~= "" then
        tab:CreateButton({ Name = name, Callback = function()
            local success, err = pcall(function() loadstring(code)() end)
            if not success then notify("脚本错误", err) end
        end })
    end
end
-- 保存原始创建窗口函数
local originalCreateWindow = Rayfield.CreateWindow

-- 重写，让所有按钮在出错时打印错误
Rayfield.CreateWindow = function(self, ...)
    local window = originalCreateWindow(self, ...)
    local originalCreateTab = window.CreateTab
    window.CreateTab = function(w, ...)
        local tab = originalCreateTab(w, ...)
        local originalCreateButton = tab.CreateButton
        tab.CreateButton = function(t, options)
            local originalCallback = options.Callback
            options.Callback = function()
                local success, err = pcall(originalCallback)
                if not success then
                    warn("按钮 [" .. options.Name .. "] 发生错误: ", err)
                    -- 将错误显示在通知里（如果窗口还在）
                    pcall(function() Rayfield:Notify({Title = "错误", Content = options.Name .. ": " .. tostring(err), Duration = 10}) end)
                end
            end
            return originalCreateButton(t, options)
        end
        return tab
    end
    return window
end
local SelectWindow = Rayfield:CreateWindow({
    Name = "91混合脚本 - 版本选择",
    LoadingTitle = "91混合脚本",
    LoadingSubtitle = "超多脚本",
    Theme = "Default",
    DisableBuildWarnings = true,
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})
local SelectTab = SelectWindow:CreateTab("版本选择")
SelectTab:CreateButton({ Name = "执行新版", Callback = function()
    -- 彻底删除所有与 Rayfield 相关的 GUI
    pcall(function()
        -- 1. 先尝试用官方方法（如果有）
        if Rayfield and Rayfield.Unload then Rayfield:Unload() end
        
        -- 2. 遍历删除所有可能的名字
        local targetNames = {"RayfieldGui", "Rayfield", "SelectWindow", "RayfieldUI", "MainGui"}
        for _, name in ipairs(targetNames) do
            local gui = game.CoreGui:FindFirstChild(name)
            if gui then gui:Destroy() end
        end
        
        -- 3. 更彻底：删除所有 ScreenGui 中名字包含 "rayfield" 或 "select" 的（不区分大小写）
        for _, gui in ipairs(game.CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local lowerName = gui.Name:lower()
                if lowerName:find("rayfield") or lowerName:find("select") or lowerName:find("window") then
                    gui:Destroy()
                end
            end
        end
        
        -- 4. 额外删除可能存在的背景遮罩（某些版本会有独立的 BlackOverlay）
        local overlay = game.CoreGui:FindFirstChild("BlackOverlay")
        if overlay then overlay:Destroy() end
    end)
    
    -- 等待一帧，确保 GUI 完全销毁
    task.wait(0.1)
    _G.LoadStartTime = os.clock()
    load()  -- 加载新版主界面
end })

SelectTab:CreateButton({
    Name = "执行旧版",
    Callback = function()
        pcall(function()
        for _, gui in ipairs(game.CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name:find("Rayfield") or gui.Name:find("SelectWindow")) then
                gui:Destroy()
            end
        end
    end)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/114514-alnc/Universal--roblox-script/refs/heads/main/91-script.lua"))()
end })
SelectTab:CreateSection("更新日志")
local LOG_URL = "https://raw.githubusercontent.com/114514-alnc/Universal--roblox-script/refs/heads/main/Updatelog/Chinese/91-script.txt"

local function loadChangelog()
    local success, content = pcall(function()
        return game:HttpGet(LOG_URL)
    end)
    if not success then
        SelectTab:CreateLabel("无法加载更新日志!")
        return
    end
    local lines = {}
    for line in content:gmatch("[^\r\n]+") do
        if line ~= "" then
            table.insert(lines, line)
        end
    end
    if #lines == 0 then
        SelectTab:CreateLabel("暂无更新日志")
    else
        for _, line in ipairs(lines) do
            SelectTab:CreateLabel(line)
        end
    end
end

loadChangelog()

-- ==================== 第二步：新版主界面函数 ====================
function load()
local Plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

-- 状态变量
local States = {
    Flying = false,
    Noclip = false,
    InfJump = false,
    AutoInteract = false,
    Spinning = false,
    KillAura = false
}

local FlySpeed = 50
local SpinSpeed = 20
local SelectedPlayer = ""
local bv, bg, flyConn, noclipConn, infJumpConn
local function notify(title, content)
    Rayfield:Notify({Title = title, Content = content, Duration = 3})
end

local function createButton(tab, name, url)
    if url and url ~= "" then
        tab:CreateButton({ Name = name, Callback = function() loadstring(game:HttpGet(url))() end })
    end
end

local function createCodeButton(tab, name, code)
    if code and code ~= "" then
        tab:CreateButton({ Name = name, Callback = function()
            local success, err = pcall(function() loadstring(code)() end)
            if not success then notify("脚本错误", err) end
        end })
    end
end
local Window = Rayfield:CreateWindow({
   Name = "91混合脚本v1.1",
   LoadingTitle = "91混合脚本v1.1 | 脚本加载中",
   LoadingSubtitle = "v1.1",
   ConfigurationSaving = { Enabled = false }, -- 禁用保存功能
   Discord = { Enabled = false },            -- 禁用 Discord
   KeySystem = false                         -- 禁用密钥系统
})

----------------------------------------------------------------
-- 1. 首页
----------------------------------------------------------------
local welcometab = Window:CreateTab("首页")
welcometab:CreateLabel("欢迎使用 91混合脚本 v1.1！")
welcometab:CreateLabel("服务器功能有的可能需要卡密，有的已经失效，大部分没测试")
welcometab:CreateLabel("→脚本功能在右边→")
welcometab:CreateLabel("用户名:"..game.Players.LocalPlayer.Name)
welcometab:CreateLabel("服务器的ID:"..game.GameId)
local hubtab = Window:CreateTab("通用")
_G.FlySpeed = 50
-- 系统工具
hubtab:CreateSection("系统工具")
hubtab:CreateButton({
   Name = "重新加入",
   Callback = function() TeleportService:Teleport(game.PlaceId, Plr) end,
})
hubtab:CreateButton({
   Name = "清理内存",
   Callback = function() 
      collectgarbage("collect")
      Rayfield:Notify({Title = "系统", Content = "内存已清理", Duration = 2})
   end,
})

-- 属性修改
hubtab:CreateSection("属性修改")
hubtab:CreateSlider({
   Name = "行走速度",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) 
      if game.Players.LocalPlayer.Character then 
          game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v 
      else
          notify("行走速度", "未检测到角色，请稍后重试")
      end
   end,
})
hubtab:CreateSlider({
   Name = "跳跃高度",
   Range = {50, 500},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(v) 
      if game.Players.LocalPlayer.Character then 
          local hum = game.Players.LocalPlayer.Character.Humanoid
          hum.JumpPower = v 
          hum.UseJumpPower = true
      else
          notify("跳跃高度", "未检测到角色，请稍后重试")
      end
   end,
})
local maxHealthEnabled = false
local healthSlider = 100
hubtab:CreateToggle({
    Name = "修改最大血量",
    CurrentValue = false,
    Callback = function(state)
        maxHealthEnabled = state
        if state then
            local char = game.Players.LocalPlayer.Character
            if not char then
                notify("修改最大血量", "角色未加载，请重生后重试")
                return
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then
                notify("修改最大血量", "未找到Humanoid对象")
                return
            end
            pcall(function()
                hum.MaxHealth = healthSlider
                hum.Health = healthSlider
            end)
        end
    end,
})
hubtab:CreateSlider({
    Name = "最大血量值",
    Range = {100, 10000},
    Increment = 100,
    CurrentValue = 100,
    Callback = function(v)
        healthSlider = v
        if maxHealthEnabled then
            local char = game.Players.LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function()
                        hum.MaxHealth = v
                        hum.Health = v
                    end)
                end
            end
        end
    end,
})
hubtab:CreateToggle({
    Name = "无限跳跃",
    CurrentValue = false,
    Callback = function(v)
        States.InfJump = v
        if v then
            if infJumpConn then infJumpConn:Disconnect() end
            infJumpConn = UserInputService.JumpRequest:Connect(function()
                if not States.InfJump then return end
                local char = Plr.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then return end
                -- 只有在地面且不是正在跳跃时才能再跳
                if hum.FloorMaterial ~= Enum.Material.Air and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if infJumpConn then
                infJumpConn:Disconnect()
                infJumpConn = nil
            end
        end
    end,
})

-- 物理功能
hubtab:CreateSection("飞行和穿墙")
hubtab:CreateToggle({
    Name = "飞行",
    CurrentValue = false,
    Callback = function(state)
        local char = Plr.Character
        if not char then notify("飞行", "角色未加载") return end
        local root = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")

        if state then
            -- 清理旧残留
            if _G.FlyGyro then _G.FlyGyro:Destroy() end
            if _G.FlyVelocity then _G.FlyVelocity:Destroy() end
            if _G.FlyConn then _G.FlyConn:Disconnect() end

            hum.PlatformStand = true

            _G.FlyGyro = Instance.new("BodyGyro", root)
            _G.FlyGyro.P = 9e4
            _G.FlyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)

            _G.FlyVelocity = Instance.new("BodyVelocity", root)
            _G.FlyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            _G.FlyVelocity.Velocity = Vector3.zero

            local speed = 0
            _G.FlyConn = RunService.RenderStepped:Connect(function()
                if not state then return end
                local cam = workspace.CurrentCamera

                -- 身体始终朝向摄像机方向
                _G.FlyGyro.CFrame = cam.CFrame

                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    speed = math.min(speed + 3, _G.FlySpeed)
                else
                    speed = math.max(speed - 2, 0)
                end

                -- 关键修复：使用摄像机CFrame将局部移动方向转换为世界方向
                -- moveDir 在 Humanoid 坐标系中：Z 正方向是角色前方，X 正方向是右方
                local worldMove = cam.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X, 0, -moveDir.Z))
                _G.FlyVelocity.Velocity = worldMove * speed
            end)
            notify("飞行", "已启用")
        else
            if _G.FlyConn then _G.FlyConn:Disconnect() end
            if _G.FlyGyro then _G.FlyGyro:Destroy() end
            if _G.FlyVelocity then _G.FlyVelocity:Destroy() end
            _G.FlyConn = nil
            _G.FlyGyro = nil
            _G.FlyVelocity = nil
            hum.PlatformStand = false
            notify("飞行", "已关闭")
        end
    end,
})

hubtab:CreateSlider({
   Name = "飞行速度",
   Range = {10, 200},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(v)
       _G.FlySpeed = v
   end,
})
hubtab:CreateToggle({
   Name = "穿墙",
   CurrentValue = false,
   Callback = function(v)
      States.Noclip = v
      if v then
          noclipConn = game:GetService("RunService").Stepped:Connect(function()
              if States.Noclip and game.Players.LocalPlayer.Character then
                  for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                      if part:IsA("BasePart") then part.CanCollide = false end
                  end
              end
          end)
      elseif noclipConn then
          noclipConn:Disconnect()
      end
   end,
})

-- 战斗与互动
hubtab:CreateSection("战斗与互动")
hubtab:CreateToggle({
   Name = "自动/快速互动",
   CurrentValue = false,
   Callback = function(v)
      States.AutoInteract = v
      if v then
          -- 检测是否存在 ProximityPrompt
          local hasPrompt = false
          for _, d in pairs(workspace:GetDescendants()) do
              if d:IsA("ProximityPrompt") then
                  hasPrompt = true
                  break
              end
          end
          if not hasPrompt then
              notify("自动互动", "未检测到可交互物体，该功能可能无效")
          end
      end
      task.spawn(function()
          while States.AutoInteract do
              for _, d in pairs(workspace:GetDescendants()) do
                  if d:IsA("ProximityPrompt") then
                      d.HoldDuration = 0
                      if (game.Players.LocalPlayer.Character and (d.Parent.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 15) then
                          fireproximityprompt(d)
                      end
                  end
              end
              task.wait(0.2)
          end
      end)
   end,
})
hubtab:CreateToggle({
    Name = "无敌",
    CurrentValue = false,
    Callback = function(state)
        if state then
            -- 断开之前的连接（如果有）
            if _G.GodModeConn then _G.GodModeConn:Disconnect() end
            if _G.GodHealthConn then _G.GodHealthConn:Disconnect() end

            local char = Plr.Character
            if not char then
                notify("无敌", "角色未加载，请重生后重试")
                return
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then
                notify("无敌", "未找到Humanoid")
                return
            end

            -- 防止断肢死亡
            hum.BreakJointsOnDeath = false

            -- 方法1：实时锁血（每帧）
            _G.GodModeConn = RunService.RenderStepped:Connect(function()
                if hum and hum.Parent then
                    hum.Health = hum.MaxHealth
                end
            end)

            -- 方法2：血量变化时立即恢复（更高效）
            _G.GodHealthConn = hum.HealthChanged:Connect(function()
                if hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end)

            notify("无敌", "已启用，生命值锁定")
        else
            if _G.GodModeConn then _G.GodModeConn:Disconnect() end
            if _G.GodHealthConn then _G.GodHealthConn:Disconnect() end
            _G.GodModeConn = nil
            _G.GodHealthConn = nil
            notify("无敌", "已关闭")
        end
    end,
})
hubtab:CreateButton({
    Name = "无敌Hook",
    Callback = function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if method == "FireServer" or method == "InvokeServer" then
                local remoteName = self.Name or ""
                local remotePath = self:GetFullName():lower()
                if remoteName:lower():match("damage") or 
                   remoteName:lower():match("hit") or 
                   remoteName:lower():match("hurt") or
                   remotePath:match("damage") or
                   remotePath:match("hit") then
                    return nil
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
        notify("Hook", "可能会出现闪退，击败特效缺失的情况，发现异常请关闭")
    end,
})
hubtab:CreateToggle({
   Name = "走路创人",
   CurrentValue = false,
   Callback = function(v)
      States.KillAura = v
      if v then
          notify("走路创人", "该功能通过修改速度实现，可能被游戏检测")
      end
      task.spawn(function()
          while States.KillAura do
              if game.Players.LocalPlayer.Character then
                  game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 5000, 0)
                  task.wait(0.1)
                  game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
              end
              task.wait(0.1)
          end
      end)
   end,
})
hubtab:CreateButton({
   Name = "甩飞所有人",
   Callback = function()
      local char = game.Players.LocalPlayer.Character
      if not char then notify("甩飞", "未检测到角色") return end
      local hrp = char.HumanoidRootPart
      local oldV = hrp.Velocity
      hrp.Velocity = Vector3.new(99999, 99999, 99999)
      task.wait(0.1)
      hrp.Velocity = oldV
   end,
})
-- 自动旋转开关
hubtab:CreateToggle({
    Name = "自动旋转",
    CurrentValue = false,
    Callback = function(v)
        States.Spinning = v
        if v then
            task.spawn(function()
                while States.Spinning do
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
                    end
                    task.wait()
                end
            end)
        end
    end,
})

-- 旋转速度调节滑块
hubtab:CreateSlider({
    Name = "旋转速度",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 20,
    Callback = function(v)
        SpinSpeed = v
    end,
})

-- 传送服务
hubtab:CreateSection("传送")
local PlayerDropdown = hubtab:CreateDropdown({
   Name = "选择目标玩家",
   Options = {}, 
   CurrentOption = "",
   Callback = function(Option) SelectedPlayer = Option end,
})
local function Refresh()
    local names = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then table.insert(names, p.Name) end
    end
    PlayerDropdown:Refresh(names, true)
end
hubtab:CreateButton({ Name = "刷新玩家列表", Callback = Refresh })
Refresh()
hubtab:CreateButton({
   Name = "传送到选中玩家",
   Callback = function()
      local target = game.Players:FindFirstChild(SelectedPlayer)
      if target and target.Character and target.Character.HumanoidRootPart then
          game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
          notify("传送", "已传送到 " .. SelectedPlayer)
      else
          notify("传送", "目标玩家不存在或未加载角色")
      end
   end,
})
hubtab:CreateButton({
    Name = "甩飞选中玩家",
    Callback = function()
        if SelectedPlayer == "" then
            notify("甩飞", "请先从下拉菜单选择一个玩家")
            return
        end
        local target = game.Players:FindFirstChild(SelectedPlayer)
        if not target then
            notify("甩飞", "目标玩家已离开")
            return
        end
        local targetChar = target.Character
        if not targetChar then
            notify("甩飞", "目标玩家尚未加载角色")
            return
        end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            notify("甩飞", "目标角色无根部件")
            return
        end
        
        -- 甩飞实现：赋予一个随机方向的巨大速度
        local randomDir = Vector3.new(
            math.random(-100, 100),
            math.random(50, 100),   -- 向上分量保证飞起来
            math.random(-100, 100)
        ).Unit
        local flingPower = 5000
        
        -- 方法1：直接设置速度（瞬时甩飞）
        targetRoot.Velocity = randomDir * flingPower
        
        -- 方法2：如果上面无效，可以尝试用 BodyVelocity 持续甩（可选）
        -- local bv = Instance.new("BodyVelocity")
        -- bv.Velocity = randomDir * flingPower
        -- bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        -- bv.Parent = targetRoot
        -- game:GetService("Debris"):AddItem(bv, 2)  -- 2秒后自动移除
        
        notify("甩飞", SelectedPlayer .. " 已起飞！")
    end,
})
hubtab:CreateSection("其他")
hubtab:CreateButton({
   Name = "TX自动翻译",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Auto-language"))()
   end,
})
hubtab:CreateButton({
   Name = "AC6服务器放歌",
   Callback = function()
      loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-FE-Ac6-Music-Vulnerability-25536"))()
   end,
})
hubtab:CreateButton({
   Name = "TX私服生成器(会给好友发私服代码)",
   Callback = function()
      TX = "TX Script"
Script = "免费获取任何服务器私服"
loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/%E8%87%AA%E5%8A%A8%E8%8E%B7%E5%8F%96%E7%A7%81%E6%9C%8D.lua"))()
   end,
})
hubtab:CreateButton({
   Name = "改走路动作",
   Callback = function()
      local AnimationChanger = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Close = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local TextLabel_2 = Instance.new("TextLabel")
local NormalTab = Instance.new("Frame")
local A_Astronaut = Instance.new("TextButton")
local A_Bubbly = Instance.new("TextButton")
local A_Cartoony = Instance.new("TextButton")
local A_Elder = Instance.new("TextButton")
local A_Knight = Instance.new("TextButton")
local A_Levitation = Instance.new("TextButton")
local A_Mage = Instance.new("TextButton")
local A_Ninja = Instance.new("TextButton")
local A_Pirate = Instance.new("TextButton")
local A_Robot = Instance.new("TextButton")
local A_Stylish = Instance.new("TextButton")
local A_SuperHero = Instance.new("TextButton")
local A_Toy = Instance.new("TextButton")
local A_Vampire = Instance.new("TextButton")
local A_Werewolf = Instance.new("TextButton")
local A_Zombie = Instance.new("TextButton")
local Category = Instance.new("TextLabel")
local SpecialTab = Instance.new("Frame")
local A_Patrol = Instance.new("TextButton")
local A_Confident = Instance.new("TextButton")
local A_Popstar = Instance.new("TextButton")
local A_Cowboy = Instance.new("TextButton")
local A_Ghost = Instance.new("TextButton")
local A_Sneaky = Instance.new("TextButton")
local A_Princess = Instance.new("TextButton")
local Category_2 = Instance.new("TextLabel")
local OtherTab = Instance.new("Frame")
local Category_3 = Instance.new("TextLabel")
local A_None = Instance.new("TextButton")
local A_Anthro = Instance.new("TextButton")
local Animate = game.Players.LocalPlayer.Character.Animate

AnimationChanger.Name = "AnimationChanger"
AnimationChanger.Parent = game:WaitForChild("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.421999991, 0, -1, 0)
Main.Size = UDim2.new(0, 300, 0, 250)
Main.Active = true
Main.Draggable = true

TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(0, 300, 0, 30)

Close.Name = "Close"
Close.Parent = TopBar
Close.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.899999976, 0, 0, 0)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Font = Enum.Font.SciFi
Close.Text = "x"
Close.TextColor3 = Color3.new(1, 0, 0.0156863)
Close.TextSize = 20
Close.MouseButton1Click:Connect(function()
    wait(0.3)
    Main:TweenPosition(UDim2.new(0.421999991, 0, -1.28400004, 0))
    wait(3)
    AnimationChanger:Destroy()
end)

TextLabel.Parent = TopBar
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0, 0, 0.600000024, 0)
TextLabel.Size = UDim2.new(0, 270, 0, 10)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Made by Nyser#4623"
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextSize = 15

TextLabel_2.Parent = TopBar
TextLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel_2.BackgroundTransparency = 1
TextLabel_2.BorderSizePixel = 0
TextLabel_2.Position = UDim2.new(0, 0, -0.0266667679, 0)
TextLabel_2.Size = UDim2.new(0, 270, 0, 20)
TextLabel_2.Font = Enum.Font.SourceSans
TextLabel_2.Text = "Animation Changer"
TextLabel_2.TextColor3 = Color3.new(1, 1, 1)
TextLabel_2.TextSize = 20

NormalTab.Name = "NormalTab"
NormalTab.Parent = Main
NormalTab.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
NormalTab.BackgroundTransparency = 1
NormalTab.BorderSizePixel = 0
NormalTab.Position = UDim2.new(0.5, 0, 0.119999997, 0)
NormalTab.Size = UDim2.new(0, 150, 0, 500)

A_Astronaut.Name = "A_Astronaut"
A_Astronaut.Parent = NormalTab
A_Astronaut.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Astronaut.BorderSizePixel = 0
A_Astronaut.Position = UDim2.new(0, 0, 0.815764725, 0)
A_Astronaut.Size = UDim2.new(0, 150, 0, 30)
A_Astronaut.Font = Enum.Font.SciFi
A_Astronaut.Text = "Astronaut"
A_Astronaut.TextColor3 = Color3.new(1, 1, 1)
A_Astronaut.TextSize = 20
A_Astronaut.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=891621366"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=891633237"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=891667138"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=891636393"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=891627522"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=891609353"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=891617961"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Bubbly.Name = "A_Bubbly"
A_Bubbly.Parent = NormalTab
A_Bubbly.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Bubbly.BorderSizePixel = 0
A_Bubbly.Position = UDim2.new(0, 0, 0.349019617, 0)
A_Bubbly.Size = UDim2.new(0, 150, 0, 30)
A_Bubbly.Font = Enum.Font.SciFi
A_Bubbly.Text = "Bubbly"
A_Bubbly.TextColor3 = Color3.new(1, 1, 1)
A_Bubbly.TextSize = 20
A_Bubbly.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=910004836"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=910009958"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=910034870"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=910025107"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=910016857"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=910001910"
Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=910030921"
Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=910028158"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Cartoony.Name = "A_Cartoony"
A_Cartoony.Parent = NormalTab
A_Cartoony.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Cartoony.BorderSizePixel = 0
A_Cartoony.Position = UDim2.new(0, 0, 0.407272667, 0)
A_Cartoony.Size = UDim2.new(0, 150, 0, 30)
A_Cartoony.Font = Enum.Font.SciFi
A_Cartoony.Text = "Cartoony"
A_Cartoony.TextColor3 = Color3.new(1, 1, 1)
A_Cartoony.TextSize = 20
A_Cartoony.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=742637544"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=742638445"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=742640026"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=742638842"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=742637942"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=742636889"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=742637151"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Elder.Name = "A_Elder"
A_Elder.Parent = NormalTab
A_Elder.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Elder.BorderSizePixel = 0
A_Elder.Position = UDim2.new(6.51925802e-09, 0, 0.636310041, 0)
A_Elder.Size = UDim2.new(0, 150, 0, 30)
A_Elder.Font = Enum.Font.SciFi
A_Elder.Text = "Elder"
A_Elder.TextColor3 = Color3.new(1, 1, 1)
A_Elder.TextSize = 20
A_Elder.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=845397899"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=845400520"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=845403856"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=845386501"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=845398858"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=845392038"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=845396048"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Knight.Name = "A_Knight"
A_Knight.Parent = NormalTab
A_Knight.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Knight.BorderSizePixel = 0
A_Knight.Position = UDim2.new(0, 0, 0.52352941, 0)
A_Knight.Size = UDim2.new(0, 150, 0, 30)
A_Knight.Font = Enum.Font.SciFi
A_Knight.Text = "Knight"
A_Knight.TextColor3 = Color3.new(1, 1, 1)
A_Knight.TextSize = 20
A_Knight.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=657595757"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=657568135"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=657552124"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=657564596"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=658409194"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=658360781"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=657600338"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Levitation.Name = "A_Levitation"
A_Levitation.Parent = NormalTab
A_Levitation.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Levitation.BorderSizePixel = 0
A_Levitation.Position = UDim2.new(0, 0, 0.115472436, 0)
A_Levitation.Size = UDim2.new(0, 150, 0, 30)
A_Levitation.Font = Enum.Font.SciFi
A_Levitation.Text = "Levitation"
A_Levitation.TextColor3 = Color3.new(1, 1, 1)
A_Levitation.TextSize = 20
A_Levitation.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616006778"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616008087"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616013216"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616010382"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616008936"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616003713"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616005863"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Mage.Name = "A_Mage"
A_Mage.Parent = NormalTab
A_Mage.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Mage.BorderSizePixel = 0
A_Mage.Position = UDim2.new(0, 0, 0.696203232, 0)
A_Mage.Size = UDim2.new(0, 150, 0, 30)
A_Mage.Font = Enum.Font.SciFi
A_Mage.Text = "Mage"
A_Mage.TextColor3 = Color3.new(1, 1, 1)
A_Mage.TextSize = 20
A_Mage.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=707742142"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=707855907"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=707897309"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=707861613"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=707853694"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=707826056"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=707829716"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Ninja.Name = "A_Ninja"
A_Ninja.Parent = NormalTab
A_Ninja.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Ninja.BorderSizePixel = 0
A_Ninja.Position = UDim2.new(0, 0, 0.0597896464, 0)
A_Ninja.Size = UDim2.new(0, 150, 0, 30)
A_Ninja.Font = Enum.Font.SciFi
A_Ninja.Text = "Ninja"
A_Ninja.TextColor3 = Color3.new(1, 1, 1)
A_Ninja.TextSize = 20
A_Ninja.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=656117400"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=656118341"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=656121766"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=656118852"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=656117878"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=656114359"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=656115606"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Pirate.Name = "A_Pirate"
A_Pirate.Parent = NormalTab
A_Pirate.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Pirate.BorderSizePixel = 0
A_Pirate.Position = UDim2.new(-0.000333309174, 0, 0.874588311, 0)
A_Pirate.Size = UDim2.new(0, 150, 0, 30)
A_Pirate.Font = Enum.Font.SciFi
A_Pirate.Text = "Pirate"
A_Pirate.TextColor3 = Color3.new(1, 1, 1)
A_Pirate.TextSize = 20
A_Pirate.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=750781874"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=750782770"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=750785693"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=750783738"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=750782230"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=750779899"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=750780242"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Robot.Name = "A_Robot"
A_Robot.Parent = NormalTab
A_Robot.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Robot.BorderSizePixel = 0
A_Robot.Position = UDim2.new(0, 0, 0.291479498, 0)
A_Robot.Size = UDim2.new(0, 150, 0, 30)
A_Robot.Font = Enum.Font.SciFi
A_Robot.Text = "Robot"
A_Robot.TextColor3 = Color3.new(1, 1, 1)
A_Robot.TextSize = 20
A_Robot.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616088211"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616089559"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616095330"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616091570"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616090535"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616086039"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616087089"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Stylish.Name = "A_Stylish"
A_Stylish.Parent = NormalTab
A_Stylish.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Stylish.BorderSizePixel = 0
A_Stylish.Position = UDim2.new(0, 0, 0.232816339, 0)
A_Stylish.Size = UDim2.new(0, 150, 0, 30)
A_Stylish.Font = Enum.Font.SciFi
A_Stylish.Text = "Stylish"
A_Stylish.TextColor3 = Color3.new(1, 1, 1)
A_Stylish.TextSize = 20
A_Stylish.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616136790"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616138447"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616146177"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616140816"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616139451"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616133594"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616134815"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_SuperHero.Name = "A_SuperHero"
A_SuperHero.Parent = NormalTab
A_SuperHero.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_SuperHero.BorderSizePixel = 0
A_SuperHero.Position = UDim2.new(0, 0, 0.464919746, 0)
A_SuperHero.Size = UDim2.new(0, 150, 0, 30)
A_SuperHero.Font = Enum.Font.SciFi
A_SuperHero.Text = "SuperHero"
A_SuperHero.TextColor3 = Color3.new(1, 1, 1)
A_SuperHero.TextSize = 20
A_SuperHero.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616111295"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616113536"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616122287"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616117076"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616115533"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616104706"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616108001"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Toy.Name = "A_Toy"
A_Toy.Parent = NormalTab
A_Toy.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Toy.BorderSizePixel = 0
A_Toy.Position = UDim2.new(6.51925802e-09, 0, 0.756028414, 0)
A_Toy.Size = UDim2.new(0, 150, 0, 30)
A_Toy.Font = Enum.Font.SciFi
A_Toy.Text = "Toy"
A_Toy.TextColor3 = Color3.new(1, 1, 1)
A_Toy.TextSize = 20
A_Toy.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=782841498"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=782845736"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=782843345"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=782842708"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=782847020"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=782843869"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=782846423"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Vampire.Name = "A_Vampire"
A_Vampire.Parent = NormalTab
A_Vampire.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Vampire.BorderSizePixel = 0
A_Vampire.Position = UDim2.new(0, 0, 0.934021354, 0)
A_Vampire.Size = UDim2.new(0, 150, 0, 30)
A_Vampire.Font = Enum.Font.SciFi
A_Vampire.Text = "Vampire"
A_Vampire.TextColor3 = Color3.new(1, 1, 1)
A_Vampire.TextSize = 20
A_Vampire.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1083445855"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1083450166"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1083473930"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1083462077"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083455352"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1083439238"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1083443587"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Werewolf.Name = "A_Werewolf"
A_Werewolf.Parent = NormalTab
A_Werewolf.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Werewolf.BorderSizePixel = 0
A_Werewolf.Position = UDim2.new(-0.000333368778, 0, 0.174509808, 0)
A_Werewolf.Size = UDim2.new(0, 150, 0, 30)
A_Werewolf.Font = Enum.Font.SciFi
A_Werewolf.Text = "Werewolf"
A_Werewolf.TextColor3 = Color3.new(1, 1, 1)
A_Werewolf.TextSize = 20
A_Werewolf.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1083195517"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1083214717"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1083178339"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1083216690"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083218792"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1083182000"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1083189019"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Zombie.Name = "A_Zombie"
A_Zombie.Parent = NormalTab
A_Zombie.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Zombie.BorderSizePixel = 0
A_Zombie.Position = UDim2.new(-1.1920929e-07, 0, 0.582352936, 0)
A_Zombie.Size = UDim2.new(0, 150, 0, 30)
A_Zombie.Font = Enum.Font.SciFi
A_Zombie.Text = "Zombie"
A_Zombie.TextColor3 = Color3.new(1, 1, 1)
A_Zombie.TextSize = 20
A_Zombie.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616158929"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616160636"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616161997"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616156119"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616157476"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

Category.Name = "Category"
Category.Parent = NormalTab
Category.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
Category.BorderSizePixel = 0
Category.Size = UDim2.new(0, 150, 0, 30)
Category.Text = "Normal"
Category.TextColor3 = Color3.new(0, 0.835294, 1)
Category.TextSize = 14

SpecialTab.Name = "SpecialTab"
SpecialTab.Parent = Main
SpecialTab.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
SpecialTab.BackgroundTransparency = 1
SpecialTab.BorderSizePixel = 0
SpecialTab.Position = UDim2.new(0, 0, 0.119999997, 0)
SpecialTab.Size = UDim2.new(0, 150, 0, 230)

A_Patrol.Name = "A_Patrol"
A_Patrol.Parent = SpecialTab
A_Patrol.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Patrol.BorderSizePixel = 0
A_Patrol.Position = UDim2.new(0, 0, 0.259960413, 0)
A_Patrol.Size = UDim2.new(0, 150, 0, 30)
A_Patrol.Font = Enum.Font.SciFi
A_Patrol.Text = "Patrol"
A_Patrol.TextColor3 = Color3.new(1, 1, 1)
A_Patrol.TextSize = 20
A_Patrol.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1149612882"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1150842221"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1151231493"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1150967949"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1148811837"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1148811837"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1148863382"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Confident.Name = "A_Confident"
A_Confident.Parent = SpecialTab
A_Confident.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Confident.BorderSizePixel = 0
A_Confident.Position = UDim2.new(0, 0, 0.389248967, 0)
A_Confident.Size = UDim2.new(0, 150, 0, 30)
A_Confident.Font = Enum.Font.SciFi
A_Confident.Text = "Confident"
A_Confident.TextColor3 = Color3.new(1, 1, 1)
A_Confident.TextSize = 20
A_Confident.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1069977950"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1069987858"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1070017263"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1070001516"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1069984524"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1069946257"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1069973677"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Popstar.Name = "A_Popstar"
A_Popstar.Parent = SpecialTab
A_Popstar.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Popstar.BorderSizePixel = 0
A_Popstar.Position = UDim2.new(0, 0, 0.130671918, 0)
A_Popstar.Size = UDim2.new(0, 150, 0, 30)
A_Popstar.Font = Enum.Font.SciFi
A_Popstar.Text = "Popstar"
A_Popstar.TextColor3 = Color3.new(1, 1, 1)
A_Popstar.TextSize = 20
A_Popstar.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1212900985"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1150842221"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1212980338"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1212980348"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1212954642"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1213044953"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1212900995"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Cowboy.Name = "A_Cowboy"
A_Cowboy.Parent = SpecialTab
A_Cowboy.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Cowboy.BorderSizePixel = 0
A_Cowboy.Position = UDim2.new(0, 0, 0.772964239, 0)
A_Cowboy.Size = UDim2.new(0, 150, 0, 30)
A_Cowboy.Font = Enum.Font.SciFi
A_Cowboy.Text = "Cowboy"
A_Cowboy.TextColor3 = Color3.new(1, 1, 1)
A_Cowboy.TextSize = 20
A_Cowboy.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1014390418"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1014398616"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1014421541"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1014401683"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1014394726"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1014380606"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1014384571"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Ghost.Name = "A_Ghost"
A_Ghost.Parent = SpecialTab
A_Ghost.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Ghost.BorderSizePixel = 0
A_Ghost.Position = UDim2.new(0, 0, 0.900632322, 0)
A_Ghost.Size = UDim2.new(0, 150, 0, 30)
A_Ghost.Font = Enum.Font.SciFi
A_Ghost.Text = "Ghost"
A_Ghost.TextColor3 = Color3.new(1, 1, 1)
A_Ghost.TextSize = 20
A_Ghost.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616006778"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616008087"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616013216"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616013216"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616008936"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616005863"
Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=616012453"
Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=616011509"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Sneaky.Name = "A_Sneaky"
A_Sneaky.Parent = SpecialTab
A_Sneaky.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Sneaky.BorderSizePixel = 0
A_Sneaky.Position = UDim2.new(0, 0, 0.517628431, 0)
A_Sneaky.Size = UDim2.new(0, 150, 0, 30)
A_Sneaky.Font = Enum.Font.SciFi
A_Sneaky.Text = "Sneaky"
A_Sneaky.TextColor3 = Color3.new(1, 1, 1)
A_Sneaky.TextSize = 20
A_Sneaky.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1132473842"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1132477671"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1132510133"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1132494274"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1132489853"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1132461372"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1132469004"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Princess.Name = "A_Princess"
A_Princess.Parent = SpecialTab
A_Princess.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Princess.BorderSizePixel = 0
A_Princess.Position = UDim2.new(0, 0, 0.645296335, 0)
A_Princess.Size = UDim2.new(0, 150, 0, 30)
A_Princess.Font = Enum.Font.SciFi
A_Princess.Text = "Princess"
A_Princess.TextColor3 = Color3.new(1, 1, 1)
A_Princess.TextSize = 20
A_Princess.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=941003647"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=941013098"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=941028902"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=941015281"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=941008832"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=940996062"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=941000007"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

Category_2.Name = "Category"
Category_2.Parent = SpecialTab
Category_2.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
Category_2.BorderSizePixel = 0
Category_2.Size = UDim2.new(0, 150, 0, 30)
Category_2.Text = "Special"
Category_2.TextColor3 = Color3.new(0, 0.835294, 1)
Category_2.TextSize = 14

OtherTab.Name = "OtherTab"
OtherTab.Parent = Main
OtherTab.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
OtherTab.BackgroundTransparency = 1
OtherTab.BorderSizePixel = 0
OtherTab.Position = UDim2.new(0, 0, 1.06800008, 0)
OtherTab.Size = UDim2.new(0, 150, 0, 220)

Category_3.Name = "Category"
Category_3.Parent = OtherTab
Category_3.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
Category_3.BorderSizePixel = 0
Category_3.Size = UDim2.new(0, 150, 0, 30)
Category_3.Text = "Other"
Category_3.TextColor3 = Color3.new(0, 0.835294, 1)
Category_3.TextSize = 14

A_None.Name = "A_None"
A_None.Parent = OtherTab
A_None.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_None.BorderSizePixel = 0
A_None.Position = UDim2.new(0, 0, 0.134545445, 0)
A_None.Size = UDim2.new(0, 150, 0, 30)
A_None.Font = Enum.Font.SciFi
A_None.Text = "None"
A_None.TextColor3 = Color3.new(1, 1, 1)
A_None.TextSize = 20
A_None.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=0"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Anthro.Name = "A_Anthro"
A_Anthro.Parent = OtherTab
A_Anthro.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Anthro.BorderSizePixel = 0
A_Anthro.Position = UDim2.new(0, 0, 0.269090891, 0)
A_Anthro.Size = UDim2.new(0, 150, 0, 30)
A_Anthro.Font = Enum.Font.SciFi
A_Anthro.Text = "Anthro (Default)"
A_Anthro.TextColor3 = Color3.new(1, 1, 1)
A_Anthro.TextSize = 20
A_Anthro.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=2510196951"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=2510197257"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=2510202577"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=2510198475"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=2510197830"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=2510192778"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=2510195892"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

wait(1)
Main:TweenPosition(UDim2.new(0.421999991, 0, 0.28400004, 0))

   end,
})
hubtab:CreateButton({
   Name = "光影",
   Callback = function()
      -- Roblox Graphics Enhancher
local light = game.Lighting
for i, v in pairs(light:GetChildren()) do
	v:Destroy()
end

local ter = workspace.Terrain
local color = Instance.new("ColorCorrectionEffect")
local bloom = Instance.new("BloomEffect")
local sun = Instance.new("SunRaysEffect")
local blur = Instance.new("BlurEffect")

color.Parent = light
bloom.Parent = light
sun.Parent = light
blur.Parent = light

-- enable or disable shit

local config = {

	Terrain = true;
	ColorCorrection = true;
	Sun = true;
	Lighting = true;
	BloomEffect = true;
	
}

-- settings {

color.Enabled = false
color.Contrast = 0.15
color.Brightness = 0.1
color.Saturation = 0.25
color.TintColor = Color3.fromRGB(255, 222, 211)

bloom.Enabled = false
bloom.Intensity = 0.1

sun.Enabled = false
sun.Intensity = 0.2
sun.Spread = 1

bloom.Enabled = false
bloom.Intensity = 0.05
bloom.Size = 32
bloom.Threshold = 1

blur.Enabled = false
blur.Size = 6

-- settings }


if config.ColorCorrection then
	color.Enabled = true
end


if config.Sun then
	sun.Enabled = true
end


if config.Terrain then
	-- settings {
	ter.WaterWaveSize = 0.1
	ter.WaterWaveSpeed = 22
	ter.WaterTransparency = 0.9
	ter.WaterReflectance = 0.05
	-- settings }
end
if config.Lighting then
	-- settings {
	light.Ambient = Color3.fromRGB(0, 0, 0)
	light.Brightness = 4
	light.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
	light.ColorShift_Top = Color3.fromRGB(0, 0, 0)
	light.ExposureCompensation = 0
	light.FogColor = Color3.fromRGB(132, 132, 132)
	light.GlobalShadows = true
	light.OutdoorAmbient = Color3.fromRGB(112, 117, 128)
	light.Outlines = false
	-- settings }
end
local a = game.Lighting
a.Ambient = Color3.fromRGB(33, 33, 33)
a.Brightness = 5.69
a.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
a.ColorShift_Top = Color3.fromRGB(255, 247, 237)
a.EnvironmentDiffuseScale = 0.105
a.EnvironmentSpecularScale = 0.522
a.GlobalShadows = true
a.OutdoorAmbient = Color3.fromRGB(51, 54, 67)
a.ShadowSoftness = 0.18
a.GeographicLatitude = -15.525
a.ExposureCompensation = 0.75
bloom.Enabled = true
bloom.Intensity = 0.99
bloom.Size = 9999 
bloom.Threshold = 0
local c = Instance.new("ColorCorrectionEffect", a)
c.Brightness = 0.015
c.Contrast = 0.25
c.Enabled = true
c.Saturation = 0.2
c.TintColor = Color3.fromRGB(217, 145, 57)
if getgenv().mode == "Summer" then
   c.TintColor = Color3.fromRGB(255, 220, 148)
elseif getgenv().mode == "Autumn" then
   c.TintColor = Color3.fromRGB(217, 145, 57)
else
   warn("No mode selected!")
   print("Please select a mode")
   b:Destroy()
   c:Destroy()
end
local d = Instance.new("DepthOfFieldEffect", a)
d.Enabled = true
d.FarIntensity = 0.077
d.FocusDistance = 21.54
d.InFocusRadius = 20.77
d.NearIntensity = 0.277
local e = Instance.new("ColorCorrectionEffect", a)
e.Brightness = 0
e.Contrast = -0.07
e.Saturation = 0
e.Enabled = true
e.TintColor = Color3.fromRGB(255, 247, 239)
local e2 = Instance.new("ColorCorrectionEffect", a)
e2.Brightness = 0.2
e2.Contrast = 0.45
e2.Saturation = -0.1
e2.Enabled = true
e2.TintColor = Color3.fromRGB(255, 255, 255)
local s = Instance.new("SunRaysEffect", a)
s.Enabled = true
s.Intensity = 0.01
s.Spread = 0.146

print("RTX Graphics loaded! Created by BrickoIcko")

   end,
})
hubtab:CreateButton({
   Name = "操人脚本",
   Callback = function()
      loadstring(game:HttpGet("https://pastebin.com/raw/bzmhRgKL"))();
   end,
})
local invisEnabled = false
local originalTransparencies = {}

-- 开启/关闭隐身的函数
local function setInvis(state)
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end
    
    if state then
        -- 保存原始透明度并设为透明
        originalTransparencies = {}
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                originalTransparencies[part] = part.Transparency
                part.Transparency = 1
            end
        end
        -- 处理玩家头顶的Nametag（如果有）
        local head = char:FindFirstChild("Head")
        if head then
            local tag = head:FindFirstChild("Nametag")
            if tag and tag:IsA("BillboardGui") then
                tag.Enabled = false
            end
        end
        Rayfield:Notify({ Title = "隐身", Content = "已开启隐身，其他玩家看不见你", Duration = 2 })
    else
        -- 恢复原始透明度
        for part, trans in pairs(originalTransparencies) do
            if part and part.Parent then
                part.Transparency = trans
            end
        end
        -- 恢复Nametag
        local head = char:FindFirstChild("Head")
        if head then
            local tag = head:FindFirstChild("Nametag")
            if tag and tag:IsA("BillboardGui") then
                tag.Enabled = true
            end
        end
        originalTransparencies = {}
        Rayfield:Notify({ Title = "隐身", Content = "已关闭隐身", Duration = 2 })
    end
end

-- 监听角色重生成，自动保持隐身状态
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    if invisEnabled then
        task.wait(0.1) -- 等待角色完全加载
        setInvis(true)
    end
end)

-- 添加切换按钮
hubtab:CreateToggle({
    Name = "隐身",
    CurrentValue = false,
    Callback = function(value)
        invisEnabled = value
        setInvis(value)
    end,
})
hubtab:CreateButton({
   Name = "偷物品栏",
   Callback = function()
      for i,v in pairs (game.Players:GetChildren()) do
wait()
for i,b in pairs (v.Backpack:GetChildren()) do
b.Parent = game.Players.LocalPlayer.Backpack
end
end
   end,
})
hubtab:CreateButton({
    Name = "R15人物变小",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char then notify("变小", "角色未加载") return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then notify("变小", "未找到Humanoid") return end
        
        -- 使用 NumberValue 而非直接赋值 Value
        local scaleTypes = {"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}
        for _, scaleName in pairs(scaleTypes) do
            local scaleObj = hum:FindFirstChild(scaleName)
            if scaleObj and scaleObj:IsA("NumberValue") then
                scaleObj.Value = 0.5  -- 缩小到原来的50%
            end
        end
        
        notify("变小", "角色已缩小到50%")
    end,
})
createButton(hubtab, "后门执行器汉化", "https://raw.githubusercontent.com/pijiaobenMSJMleng/backdoor/refs/heads/main/backdoor.lua")
createButton(hubtab, "黄色动作", "https://pastebin.com/raw/ZfaM6tNg")
createButton(hubtab, "通用Rayfield Hub", "https://rawscripts.net/raw/Universal-Script-Universal-Rayfield-Hub-134340")
createButton(hubtab, "阿尔宙斯X", "https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/Arceus%20X%20V3")
-- 1. 无限体力
hubtab:CreateToggle({
    Name = "无限体力",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasStamina = false
            local plr = game.Players.LocalPlayer
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                local hum = plr.Character.Humanoid
                if hum:FindFirstChild("Stamina") then
                    hasStamina = true
                end
            end
            if not hasStamina then
                notify("无限体力", "未检测到体力系统(Stamina)，该功能可能无效")
            end
            _G.StaminaConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum:FindFirstChild("Stamina") then
                        hum.Stamina.Value = hum.Stamina.MaxValue
                    end
                end
            end)
        else
            if _G.StaminaConn then _G.StaminaConn:Disconnect(); _G.StaminaConn = nil end
        end
    end,
})

-- 2. 自动收集
hubtab:CreateToggle({
    Name = "自动收集",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasPickup = false
            for _, item in pairs(workspace:GetDescendants()) do
                if item:IsA("BasePart") and (item:GetAttribute("CanCollect") or item.Name:find("Coin") or item.Name:find("Pickup")) then
                    hasPickup = true
                    break
                end
            end
            if not hasPickup then
                notify("自动收集", "未检测到明显的可收集物品，该功能可能无效")
            end
        end
        _G.AutoCollect = state
        task.spawn(function()
            while _G.AutoCollect do
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart
                if hrp then
                    for _, item in pairs(workspace:GetDescendants()) do
                        if item:IsA("BasePart") and (item:GetAttribute("CanCollect") or item.Name:find("Coin") or item.Name:find("Pickup")) then
                            if (item.Position - hrp.Position).Magnitude < 20 then
                                firetouchinterest(hrp, item, 0)
                                firetouchinterest(hrp, item, 1)
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end,
})

-- 3. 无冷却
hubtab:CreateToggle({
    Name = "无冷却",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasCooldown = false
            local plr = game.Players.LocalPlayer
            for _, tool in pairs(plr.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Cooldown") then
                    hasCooldown = true
                    break
                end
            end
            if not hasCooldown and plr.Character then
                for _, tool in pairs(plr.Character:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Cooldown") then
                        hasCooldown = true
                        break
                    end
                end
            end
            if not hasCooldown then
                notify("无冷却", "未检测到带冷却(Cooldown)的工具，该功能可能无效")
            end
            _G.NoCooldownConn = game:GetService("RunService").Stepped:Connect(function()
                local plr = game.Players.LocalPlayer
                for _, tool in pairs(plr.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Cooldown") then
                        tool.Cooldown.Value = 0
                    end
                end
                if plr.Character then
                    for _, tool in pairs(plr.Character:GetChildren()) do
                        if tool:IsA("Tool") and tool:FindFirstChild("Cooldown") then
                            tool.Cooldown.Value = 0
                        end
                    end
                end
            end)
        else
            if _G.NoCooldownConn then _G.NoCooldownConn:Disconnect(); _G.NoCooldownConn = nil end
        end
    end,
})

-- 4. 显示 FPS
hubtab:CreateToggle({
    Name = "显示 FPS",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local fpsLabel = Instance.new("TextLabel", game.CoreGui)
            fpsLabel.Name = "FPSLabel"
            fpsLabel.Size = UDim2.new(0, 100, 0, 30)
            fpsLabel.Position = UDim2.new(1, -110, 0, 10)
            fpsLabel.BackgroundTransparency = 0.5
            fpsLabel.BackgroundColor3 = Color3.new(0,0,0)
            fpsLabel.TextColor3 = Color3.new(0,1,0)
            fpsLabel.Font = Enum.Font.SourceSansBold
            fpsLabel.TextSize = 18
            fpsLabel.Text = "FPS: --"
            local lastTime = tick()
            local frameCount = 0
            _G.FPSConn = game:GetService("RunService").RenderStepped:Connect(function()
                frameCount = frameCount + 1
                local now = tick()
                if now - lastTime >= 1 then
                    fpsLabel.Text = "FPS: " .. frameCount
                    frameCount = 0
                    lastTime = now
                end
            end)
            notify("显示FPS", "已启用，屏幕右上角显示帧率")
        else
            if _G.FPSConn then _G.FPSConn:Disconnect(); _G.FPSConn = nil end
            local lbl = game.CoreGui:FindFirstChild("FPSLabel")
            if lbl then lbl:Destroy() end
            notify("显示FPS", "已关闭")
        end
    end,
})

-- 5. 防踢
hubtab:CreateToggle({
    Name = "防踢",
    CurrentValue = false,
    Callback = function(state)
        local plr = game.Players.LocalPlayer
        if state then
            if not plr._oldKick then
                plr._oldKick = plr.Kick
                plr.Kick = function() end
                notify("防踢", "已启用（仅拦截Kick方法），部分游戏可能无效")
            end
        else
            if plr._oldKick then
                plr.Kick = plr._oldKick
                plr._oldKick = nil
                notify("防踢", "已禁用")
            end
        end
    end,
})
hubtab:CreateToggle({
    Name = "强制第一人称",
    CurrentValue = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        if state then
            local thirdPersonToggle = hubtab:GetToggle("强制第三人称")
            if thirdPersonToggle and thirdPersonToggle.CurrentValue then
                thirdPersonToggle:SetValue(false)
            end
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            local char = player.Character
            if char and char:FindFirstChild("Head") then
                workspace.CurrentCamera.CameraSubject = char.Head
            else
                notify("强制第一人称", "未找到头部，可能无法完美跟随")
            end
            _G.FirstPersonConn = game:GetService("RunService").RenderStepped:Connect(function()
                if not state then return end
                local char = player.Character
                if char and char:FindFirstChild("Head") then
                    workspace.CurrentCamera.CFrame = char.Head.CFrame
                end
            end)
            notify("强制第一人称", "已启用")
        else
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            if _G.FirstPersonConn then _G.FirstPersonConn:Disconnect(); _G.FirstPersonConn = nil end
            notify("强制第一人称", "已关闭")
        end
    end,
})
-- 6. 强制第三人称
hubtab:CreateToggle({
    Name = "强制第三人称",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local firstPersonToggle = hubtab:GetToggle("强制第一人称")
            if firstPersonToggle and firstPersonToggle.CurrentValue then
                firstPersonToggle:SetValue(false)
            end
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            if game.Players.LocalPlayer.Character then
                workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
            end
            notify("强制第三人称", "已启用")
        else
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            notify("强制第三人称", "已关闭")
        end
    end,
})

-- 8. 无限弹药
hubtab:CreateToggle({
    Name = "无限弹药",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasAmmo = false
            local player = game.Players.LocalPlayer
            if player.Character then
                for _, tool in pairs(player.Character:GetChildren()) do
                    if tool:IsA("Tool") and (tool:FindFirstChild("Ammo") or tool:FindFirstChild("Bullets")) then
                        hasAmmo = true
                        break
                    end
                end
            end
            if not hasAmmo then
                notify("无限弹药", "未检测到弹药属性(Ammo/Bullets)，该功能可能无效")
            end
            _G.AmmoConn = game:GetService("RunService").RenderStepped:Connect(function()
                local player = game.Players.LocalPlayer
                if player.Character then
                    for _, tool in pairs(player.Character:GetChildren()) do
                        if tool:IsA("Tool") then
                            local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("Bullets")
                            if ammo and (ammo:IsA("IntValue") or ammo:IsA("NumberValue")) then
                                ammo.Value = 9999
                            end
                        end
                    end
                end
            end)
        else
            if _G.AmmoConn then _G.AmmoConn:Disconnect(); _G.AmmoConn = nil end
        end
    end,
})

-- 9. 无后坐力/无扩散
hubtab:CreateToggle({
    Name = "无后坐力/无扩散",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasRecoil = false
            local player = game.Players.LocalPlayer
            if player.Character then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local stats = tool:FindFirstChild("Stats") or tool:FindFirstChild("GunStats")
                    if stats then
                        for _, v in pairs(stats:GetChildren()) do
                            if v.Name:lower():find("recoil") or v.Name:lower():find("spread") then
                                hasRecoil = true
                                break
                            end
                        end
                    end
                end
            end
            if not hasRecoil then
                notify("无后坐力", "未检测到后坐力/扩散属性，该功能可能无效")
            end
            _G.RecoilConn = game:GetService("RunService").RenderStepped:Connect(function()
                local player = game.Players.LocalPlayer
                if player.Character then
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        local stats = tool:FindFirstChild("Stats") or tool:FindFirstChild("GunStats")
                        if stats then
                            for _, v in pairs(stats:GetChildren()) do
                                if v.Name:lower():find("recoil") or v.Name:lower():find("spread") then
                                    v.Value = 0
                                end
                            end
                        end
                    end
                end
            end)
        else
            if _G.RecoilConn then _G.RecoilConn:Disconnect(); _G.RecoilConn = nil end
        end
    end,
})

-- 10. 水上行走
hubtab:CreateToggle({
    Name = "水上行走",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasWater = false
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Material == Enum.Material.Water then
                    hasWater = true
                    break
                end
            end
            if not hasWater then
                notify("水上行走", "未检测到水材质，该功能可能无效")
            end
            _G.WaterWalkConn = game:GetService("RunService").RenderStepped:Connect(function()
                local player = game.Players.LocalPlayer
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    local vel = player.Character.Humanoid.MoveDirection
                    if vel.Magnitude > 0 then
                        local ray = Ray.new(hrp.Position, Vector3.new(0, -3, 0))
                        local hit = workspace:FindPartOnRay(ray, player.Character)
                        if hit and hit.Material == Enum.Material.Water then
                            local platform = Instance.new("Part")
                            platform.Size = Vector3.new(3, 0.2, 3)
                            platform.Position = hrp.Position - Vector3.new(0, 1.5, 0)
                            platform.Anchored = true
                            platform.CanCollide = true
                            platform.Transparency = 0.8
                            platform.BrickColor = BrickColor.new("Ice")
                            platform.Parent = workspace
                            game:GetService("Debris"):AddItem(platform, 0.5)
                        end
                    end
                end
            end)
        else
            if _G.WaterWalkConn then _G.WaterWalkConn:Disconnect(); _G.WaterWalkConn = nil end
        end
    end,
})

-- 11. 低重力
hubtab:CreateToggle({
    Name = "低重力",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.LowGravConn = game:GetService("RunService").RenderStepped:Connect(function()
                if game.Players.LocalPlayer.Character then
                    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, hrp.Velocity.Y * 0.98, hrp.Velocity.Z)
                end
            end)
            notify("低重力", "已启用，跳跃下落速度减慢")
        else
            if _G.LowGravConn then _G.LowGravConn:Disconnect(); _G.LowGravConn = nil end
            notify("低重力", "已关闭")
        end
    end,
})

-- 12. 自动重生
hubtab:CreateToggle({
    Name = "自动重生",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AutoRespawn = game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
                wait(0.5)
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0 then
                    char.Humanoid.Health = char.Humanoid.MaxHealth
                end
            end)
            notify("自动重生", "已启用，死亡后自动恢复生命")
        else
            if _G.AutoRespawn then _G.AutoRespawn:Disconnect(); _G.AutoRespawn = nil end
            notify("自动重生", "已禁用")
        end
    end,
})

-- 13. 瞬移到鼠标位置（按B键）
hubtab:CreateButton({
    Name = "瞬移到鼠标位置 (按B)",
    Callback = function()
        if _G.BTP then return end
        local mouse = game.Players.LocalPlayer:GetMouse()
        _G.BTP = mouse.KeyDown:Connect(function(key)
            if key == "b" then
                local target = mouse.Hit.p
                if game.Players.LocalPlayer.Character then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(target)
                    notify("瞬移", "已瞬移到鼠标位置")
                else
                    notify("瞬移", "角色不存在")
                end
            end
        end)
        notify("瞬移", "已启用，按 B 键瞬移到鼠标位置")
    end,
})

-- 14. 范围拾取
hubtab:CreateToggle({
    Name = "范围拾取 (20单位)",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasPickup = false
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:match("Pickup|Coin|Money|Item") then
                    hasPickup = true
                    break
                end
            end
            if not hasPickup then
                notify("范围拾取", "未检测到可拾取物品(Pickup/Coin/Money/Item)，该功能可能无效")
            end
        end
        _G.RangeCollect = state
        task.spawn(function()
            while _G.RangeCollect do
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart
                if hrp then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Name:match("Pickup|Coin|Money|Item") then
                            if (obj.Position - hrp.Position).Magnitude < 20 then
                                firetouchinterest(hrp, obj, 0)
                                firetouchinterest(hrp, obj, 1)
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end,
})

-- 15. 自动连跳
hubtab:CreateToggle({
    Name = "自动连跳",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AutoJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum.FloorMaterial ~= Enum.Material.Air then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
            notify("自动连跳", "按住空格即可连续跳跃")
        else
            if _G.AutoJumpConn then _G.AutoJumpConn:Disconnect(); _G.AutoJumpConn = nil end
            notify("自动连跳", "已关闭")
        end
    end,
})

-- 16. 防摔伤
hubtab:CreateToggle({
    Name = "防摔伤",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.NoFallConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum.Health > 0 and hum.FloorMaterial == Enum.Material.Air then
                        local vel = plr.Character.HumanoidRootPart.Velocity
                        if vel.Y < -50 then
                            plr.Character.HumanoidRootPart.Velocity = Vector3.new(vel.X, -30, vel.Z)
                        end
                    end
                end
            end)
            notify("防摔伤", "已启用，落地前减速")
        else
            if _G.NoFallConn then _G.NoFallConn:Disconnect(); _G.NoFallConn = nil end
        end
    end,
})

-- 17. 自动攀爬
hubtab:CreateToggle({
    Name = "自动攀爬",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AutoClimbConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if not plr.Character then return end
                local hrp = plr.Character.HumanoidRootPart
                local hum = plr.Character.Humanoid
                if hum.MoveDirection.Magnitude > 0 then
                    local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 2)
                    local hit = workspace:FindPartOnRay(ray, plr.Character)
                    if hit and hit.Material ~= Enum.Material.Air then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, 20, hrp.Velocity.Z)
                    end
                end
            end)
            notify("自动攀爬", "面向墙壁移动即可攀爬")
        else
            if _G.AutoClimbConn then _G.AutoClimbConn:Disconnect(); _G.AutoClimbConn = nil end
        end
    end,
})

-- 18. 无碰撞队友
hubtab:CreateToggle({
    Name = "无碰撞队友",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.NoCollideConn = game:GetService("RunService").Stepped:Connect(function()
                for _, other in pairs(game.Players:GetPlayers()) do
                    if other ~= game.Players.LocalPlayer and other.Character then
                        for _, part in pairs(other.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
            notify("无碰撞队友", "其他玩家无法碰撞你")
        else
            if _G.NoCollideConn then _G.NoCollideConn:Disconnect(); _G.NoCollideConn = nil end
        end
    end,
})

-- 20. 自动重连
hubtab:CreateToggle({
    Name = "自动重连",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AutoReconnect = game:GetService("TeleportService").TeleportInitiated:Connect(function()
                wait(2)
                game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
            end)
            notify("自动重连", "断线后自动尝试重连")
        else
            if _G.AutoReconnect then _G.AutoReconnect:Disconnect(); _G.AutoReconnect = nil end
        end
    end,
})

-- 22. 快速重生
hubtab:CreateToggle({
    Name = "快速重生",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.FastRespawn = game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0 then
                    char.Humanoid.Health = char.Humanoid.MaxHealth
                end
            end)
            notify("快速重生", "死亡后快速恢复生命")
        else
            if _G.FastRespawn then _G.FastRespawn:Disconnect(); _G.FastRespawn = nil end
        end
    end,
})

-- 23. 自动拾取武器
hubtab:CreateToggle({
    Name = "自动拾取武器",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasTool = false
            for _, tool in pairs(workspace:GetDescendants()) do
                if tool:IsA("Tool") and tool.Parent == workspace then
                    hasTool = true
                    break
                end
            end
            if not hasTool then
                notify("自动拾取武器", "未检测到地上的武器(Tool)，该功能可能无效")
            end
        end
        _G.AutoPickup = state
        task.spawn(function()
            while _G.AutoPickup do
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart
                if hrp then
                    for _, tool in pairs(workspace:GetDescendants()) do
                        if tool:IsA("Tool") and tool.Parent == workspace and (tool.Position - hrp.Position).Magnitude < 10 then
                            hrp.CFrame = tool.CFrame
                            task.wait(0.1)
                            local player = game.Players.LocalPlayer
                            if player.Character then
                                player.Character.Humanoid:EquipTool(tool)
                            end
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
        if state then notify("自动拾取武器", "靠近地上的武器自动捡起") end
    end,
})

-- 24. 时间冻结（视觉）
hubtab:CreateButton({
    Name = "时间冻结 (视觉)",
    Callback = function()
        if _G.TimeFrozen then
            _G.TimeFrozen = false
            if _G.TimeFreezeConn then _G.TimeFreezeConn:Disconnect() end
            notify("时间冻结", "已解冻")
        else
            _G.TimeFrozen = true
            _G.TimeFreezeConn = game:GetService("RunService").RenderStepped:Connect(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Animator") then
                        v:Stop()
                    end
                end
            end)
            notify("时间冻结", "已冻结视觉动画")
        end
    end,
})

-- 25. 自动格挡
hubtab:CreateToggle({
    Name = "自动格挡",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasBlock = false
            local player = game.Players.LocalPlayer
            local char = player.Character
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") and (tool:FindFirstChild("Block") or tool:FindFirstChild("Defense")) then
                        hasBlock = true
                        break
                    end
                end
            end
            if not hasBlock then
                notify("自动格挡", "未检测到格挡/防御属性，该功能可能无效")
            end
            _G.AutoBlockConn = game:GetService("RunService").RenderStepped:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, tool in pairs(char:GetChildren()) do
                        if tool:IsA("Tool") and tool:FindFirstChild("Block") then
                            tool.Block.Value = true
                        elseif tool:IsA("Tool") and tool:FindFirstChild("Defense") then
                            tool.Defense.Value = true
                        end
                    end
                end
            end)
        else
            if _G.AutoBlockConn then _G.AutoBlockConn:Disconnect(); _G.AutoBlockConn = nil end
        end
    end,
})

-- 26. 快速游泳
hubtab:CreateToggle({
    Name = "快速游泳",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasWater = false
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Material == Enum.Material.Water then
                    hasWater = true
                    break
                end
            end
            if not hasWater then
                notify("快速游泳", "未检测到水域，该功能可能无效")
            end
            _G.FastSwimConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum:GetState() == Enum.HumanoidStateType.Swimming then
                        hum.WalkSpeed = 100
                    end
                end
            end)
        else
            if _G.FastSwimConn then _G.FastSwimConn:Disconnect(); _G.FastSwimConn = nil end
        end
    end,
})

-- 27. 自动售卖
hubtab:CreateToggle({
    Name = "自动售卖",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasPrompt = false
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and (prompt.Name:find("Sell") or prompt.Name:find("Trade")) then
                    hasPrompt = true
                    break
                end
            end
            if not hasPrompt then
                notify("自动售卖", "未检测到售卖/交易交互点，该功能可能无效")
            end
            _G.AutoSell = state
            task.spawn(function()
                while _G.AutoSell do
                    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart
                    if hrp then
                        for _, prompt in pairs(workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and (prompt.Name:find("Sell") or prompt.Name:find("Trade")) then
                                if (prompt.Parent.Position - hrp.Position).Magnitude < 15 then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end
                    task.wait(0.3)
                end
            end)
        else
            _G.AutoSell = false
        end
    end,
})

-- 28. 防眩晕
hubtab:CreateToggle({
    Name = "防眩晕",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AntiMotionConn = game:GetService("RunService").RenderStepped:Connect(function()
                local cam = workspace.CurrentCamera
                cam.CameraType = Enum.CameraType.Custom
                local shake = cam:FindFirstChild("CameraShake")
                if shake then shake:Destroy() end
            end)
            notify("防眩晕", "已启用，镜头晃动已移除")
        else
            if _G.AntiMotionConn then _G.AntiMotionConn:Disconnect(); _G.AntiMotionConn = nil end
        end
    end,
})

-- 29. 自动跳跃过障碍
hubtab:CreateToggle({
    Name = "自动跳跃过障碍",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AutoHopConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if not plr.Character then return end
                local hrp = plr.Character.HumanoidRootPart
                local hum = plr.Character.Humanoid
                local vel = hum.MoveDirection
                if vel.Magnitude > 0 then
                    local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 2.5)
                    local hit = workspace:FindPartOnRay(ray, plr.Character)
                    if hit and hit.Size.Y > 1 and hit.Position.Y - hrp.Position.Y < 2 then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
            notify("自动跳跃过障碍", "前方有障碍物时自动跳跃")
        else
            if _G.AutoHopConn then _G.AutoHopConn:Disconnect(); _G.AutoHopConn = nil end
        end
    end,
})

-- 30. 无限氧气
hubtab:CreateToggle({
    Name = "无限氧气",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasOxygen = false
            local plr = game.Players.LocalPlayer
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                local hum = plr.Character.Humanoid
                if hum:FindFirstChild("Oxygen") then
                    hasOxygen = true
                end
            end
            if not hasOxygen then
                notify("无限氧气", "未检测到氧气属性(Oxygen)，该功能可能无效")
            end
            _G.InfOxygenConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum:FindFirstChild("Oxygen") then
                        hum.Oxygen.Value = hum.Oxygen.MaxValue
                    end
                end
            end)
        else
            if _G.InfOxygenConn then _G.InfOxygenConn:Disconnect(); _G.InfOxygenConn = nil end
        end
    end,
})

-- 31. 自动恢复生命
hubtab:CreateToggle({
    Name = "自动恢复生命",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasMed = false
            for _, item in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if item:IsA("Tool") and (item.Name:find("Med") or item.Name:find("Health")) then
                    hasMed = true
                    break
                end
            end
            if not hasMed then
                notify("自动恢复生命", "背包中未找到医疗包，请先获取医疗物品")
            end
            _G.AutoHealConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum.Health < hum.MaxHealth * 0.5 then
                        for _, tool in pairs(plr.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and (tool.Name:find("Med") or tool.Name:find("Health")) then
                                tool.Parent = plr.Character
                                tool:Activate()
                                task.wait(0.5)
                                tool.Parent = plr.Backpack
                                break
                            end
                        end
                    end
                end
            end)
        else
            if _G.AutoHealConn then _G.AutoHealConn:Disconnect(); _G.AutoHealConn = nil end
        end
    end,
})

-- 32. 快速爬梯子
hubtab:CreateToggle({
    Name = "快速爬梯子",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.FastLadderConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum:GetState() == Enum.HumanoidStateType.Climbing then
                        hum.WalkSpeed = 50
                    end
                end
            end)
        else
            if _G.FastLadderConn then _G.FastLadderConn:Disconnect(); _G.FastLadderConn = nil end
        end
    end,
})

-- 33. 无脚步声
hubtab:CreateToggle({
    Name = "无脚步声",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasFootstep = false
            local plr = game.Players.LocalPlayer
            if plr.Character then
                for _, sound in pairs(plr.Character:GetDescendants()) do
                    if sound:IsA("Sound") and (sound.Name:find("Foot") or sound.Name:find("Step")) then
                        hasFootstep = true
                        break
                    end
                end
            end
            if not hasFootstep then
                notify("无脚步声", "未检测到脚步声部件，该功能可能无效")
            end
            _G.MuteStepConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character then
                    for _, sound in pairs(plr.Character:GetDescendants()) do
                        if sound:IsA("Sound") and (sound.Name:find("Foot") or sound.Name:find("Step")) then
                            sound.Volume = 0
                        end
                    end
                end
            end)
        else
            if _G.MuteStepConn then _G.MuteStepConn:Disconnect(); _G.MuteStepConn = nil end
        end
    end,
})

-- 34. 自动闪避
hubtab:CreateToggle({
    Name = "自动闪避",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local plr = game.Players.LocalPlayer
            if not plr.Character then
                notify("自动闪避", "未检测到角色，无法启用")
                return
            end
            local lastHealth = plr.Character.Humanoid.Health
            _G.AutoDodgeConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum.Health < lastHealth then
                        local hrp = plr.Character.HumanoidRootPart
                        local newPos = hrp.Position + hrp.CFrame.RightVector * 10
                        hrp.CFrame = CFrame.new(newPos)
                    end
                    lastHealth = hum.Health
                end
            end)
        else
            if _G.AutoDodgeConn then _G.AutoDodgeConn:Disconnect(); _G.AutoDodgeConn = nil end
        end
    end,
})
hubtab:CreateSection("FPS游戏专用")
hubtab:CreateButton({
   Name = "敌方吸人",
   Callback = function()
      local L_1_ = true;
local L_2_ = game.Players.LocalPlayer.Character.HumanoidRootPart;
local L_3_ = L_2_.Position - Vector3.new(5, 0, 0)

game.Players.LocalPlayer:GetMouse().KeyDown:Connect(function(L_4_arg1)
	if L_4_arg1 == 'f' then
		L_1_ = not L_1_
	end;
	if L_4_arg1 == 'r' then
		L_2_ = game.Players.LocalPlayer.Character.HumanoidRootPart;
		L_3_ = L_2_.Position - Vector3.new(5, 0, 0)
	end
end)

for L_5_forvar1, L_6_forvar2 in pairs(game.Players:GetPlayers()) do
	if L_6_forvar2 == game.Players.LocalPlayer then
	else
		local L_7_ = coroutine.create(function()
			game:GetService('RunService').RenderStepped:Connect(function()
				local L_8_, L_9_ = pcall(function()
					local L_10_ = L_6_forvar2.Character;
					if L_10_ then
						if L_10_:FindFirstChild("HumanoidRootPart") then
							if L_1_ then
								L_6_forvar2.Backpack:ClearAllChildren()
								for L_11_forvar1, L_12_forvar2 in pairs(L_10_:GetChildren()) do
									if L_12_forvar2:IsA("Tool") then
										L_12_forvar2:Destroy()
									end
								end;
								L_10_.HumanoidRootPart.CFrame = CFrame.new(L_3_)
							end
						end
					end
				end)
				if L_8_ then
				else
					warn("Unnormal error: "..L_9_)
				end
			end)
		end)
		coroutine.resume(L_7_)
	end
end;

game.Players.PlayerAdded:Connect(function(L_13_arg1)   
	if L_13_arg1 == game.Players.LocalPlayer then
	else
		local L_14_ = coroutine.create(function()
			game:GetService('RunService').RenderStepped:Connect(function()
				local L_15_, L_16_ = pcall(function()
					local L_17_ = L_13_arg1.Character;
					if L_17_ then
						if L_17_:FindFirstChild("HumanoidRootPart") then
							if L_1_ then
								L_13_arg1.Backpack:ClearAllChildren()
								for L_18_forvar1, L_19_forvar2 in pairs(L_17_:GetChildren()) do
									if L_19_forvar2:IsA("Tool") then
										L_19_forvar2:Destroy()
									end
								end;
								L_17_.HumanoidRootPart.CFrame = CFrame.new(L_3_)
							end
						end
					end
				end)
				if L_15_ then
				else
					warn("Unnormal error: "..L_16_)
				end
			end)
		end)
		coroutine.resume(L_14_)
	end           
end)
   end,
})
-- ==================== 视觉辅助 ====================
hubtab:CreateSection("视觉辅助")

-- 1. 玩家透视（带检测）
local espEnabled = false
local espCache = {}
hubtab:CreateToggle({
    Name = "玩家透视",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
        if not pcall(function()
            if state then
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and player.Character and not espCache[player] then
                        local hl = Instance.new("Highlight")
                        hl.Name = "PlayerESP"
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.Parent = player.Character
                        espCache[player] = hl
                    end
                end
                game.Players.PlayerAdded:Connect(function(player)
                    player.CharacterAdded:Connect(function(char)
                        if espEnabled and player ~= game.Players.LocalPlayer then
                            local hl = Instance.new("Highlight", char)
                            hl.Name = "PlayerESP"
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.5
                            espCache[player] = hl
                        end
                    end)
                end)
                game.Players.PlayerRemoving:Connect(function(player)
                    if espCache[player] then
                        espCache[player]:Destroy()
                        espCache[player] = nil
                    end
                end)
            else
                for _, hl in pairs(espCache) do
                    hl:Destroy()
                end
                espCache = {}
            end
        end) then
            notify("玩家透视", "功能启动失败，请检查游戏是否支持Highlight")
        end
    end,
})

-- 2. NPC透视（带检测）
local npcESPEnabled = false
local npcHighlights = {}
hubtab:CreateToggle({
    Name = "NPC透视",
    CurrentValue = false,
    Callback = function(state)
        npcESPEnabled = state
        if not pcall(function()
            if state then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                        local hl = Instance.new("Highlight", obj)
                        hl.Name = "NPC_ESP"
                        hl.FillColor = Color3.fromRGB(0, 255, 0)
                        hl.OutlineColor = Color3.fromRGB(0, 0, 0)
                        hl.FillTransparency = 0.5
                        table.insert(npcHighlights, hl)
                    end
                end
                workspace.DescendantAdded:Connect(function(obj)
                    if npcESPEnabled and obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                        task.wait(0.1)
                        local hl = Instance.new("Highlight", obj)
                        hl.Name = "NPC_ESP"
                        hl.FillColor = Color3.fromRGB(0, 255, 0)
                        hl.OutlineColor = Color3.fromRGB(0, 0, 0)
                        hl.FillTransparency = 0.5
                        table.insert(npcHighlights, hl)
                    end
                end)
            else
                for _, hl in pairs(npcHighlights) do
                    hl:Destroy()
                end
                npcHighlights = {}
            end
        end) then
            notify("NPC透视", "功能启动失败，请检查游戏是否支持Highlight")
        end
    end,
})

-- ==================== 战斗增强 ====================
hubtab:CreateSection("战斗增强")

-- 4. 自动攻击（带检测）
hubtab:CreateToggle({
    Name = "自动攻击",
    CurrentValue = false,
    Callback = function(state)
        if not pcall(function()
            if state then
                if _G.AutoAttack then _G.AutoAttack:Disconnect() end
                _G.AutoAttack = game:GetService("RunService").Heartbeat:Connect(function()
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end
                end)
            else
                if _G.AutoAttack then
                    _G.AutoAttack:Disconnect()
                    _G.AutoAttack = nil
                end
            end
        end) then
            notify("自动攻击", "功能启动失败")
        end
    end,
})

-- 5. 杀戮光环（带检测）
hubtab:CreateToggle({
    Name = "杀戮光环",
    CurrentValue = false,
    Callback = function(state)
        if not pcall(function()
            if state then
                if _G.KillAuraConn then _G.KillAuraConn:Disconnect() end
                _G.KillAuraConn = game:GetService("RunService").Heartbeat:Connect(function()
                    local myChar = game.Players.LocalPlayer.Character
                    if not myChar then return end
                    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                    if not myRoot then return end
                    for _, player in pairs(game.Players:GetPlayers()) do
                        if player ~= game.Players.LocalPlayer and player.Character then
                            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                            if targetRoot and (targetRoot.Position - myRoot.Position).Magnitude < 20 then
                                local tool = myChar:FindFirstChildOfClass("Tool")
                                if tool then
                                    tool:Activate()
                                end
                            end
                        end
                    end
                end)
            else
                if _G.KillAuraConn then
                    _G.KillAuraConn:Disconnect()
                    _G.KillAuraConn = nil
                end
            end
        end) then
            notify("杀戮光环", "功能启动失败")
        end
    end,
})

-- 7. 原地漂浮（带检测）
hubtab:CreateToggle({
    Name = "原地漂浮",
    CurrentValue = false,
    Callback = function(state)
        if not pcall(function()
            if state then
                local char = game.Players.LocalPlayer.Character
                if not char then
                    notify("原地漂浮", "角色未加载")
                    return
                end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then
                    notify("原地漂浮", "未找到HumanoidRootPart")
                    return
                end
                if _G.FloatConn then _G.FloatConn:Disconnect() end
                _G.FloatConn = game:GetService("RunService").RenderStepped:Connect(function()
                    if root and root.Parent then
                        root.Velocity = Vector3.zero
                        root.RotVelocity = Vector3.zero
                    end
                end)
            else
                if _G.FloatConn then
                    _G.FloatConn:Disconnect()
                    _G.FloatConn = nil
                end
            end
        end) then
            notify("原地漂浮", "功能启动失败")
        end
    end,
})

-- 8. 飞行穿墙（带检测）
hubtab:CreateToggle({
    Name = "飞行穿墙",
    CurrentValue = false,
    Callback = function(state)
        if not pcall(function()
            if state then
                if _G.FlyNoclipConn then _G.FlyNoclipConn:Disconnect() end
                _G.FlyNoclipConn = game:GetService("RunService").Stepped:Connect(function()
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            else
                if _G.FlyNoclipConn then
                    _G.FlyNoclipConn:Disconnect()
                    _G.FlyNoclipConn = nil
                end
            end
        end) then
            notify("飞行穿墙", "功能启动失败")
        end
    end,
})

-- ==================== 恶搞与杂项 ====================
hubtab:CreateSection("娱乐lol")

-- 9. 假死（带检测）
local fakeDeadEnabled = false
hubtab:CreateToggle({
    Name = "假死",
    CurrentValue = false,
    Callback = function(state)
        fakeDeadEnabled = state
        local char = game.Players.LocalPlayer.Character
        if not char then
            notify("假死", "角色未加载")
            return
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            notify("假死", "未找到Humanoid")
            return
        end
        if state then
            pcall(function()
                hum.Health = 0
                if _G.FakeDeadConn then _G.FakeDeadConn:Disconnect() end
                _G.FakeDeadConn = hum.Died:Connect(function()
                    if fakeDeadEnabled then
                        task.wait(0.1)
                        hum.Health = 0
                    end
                end)
            end)
        else
            pcall(function()
                hum.Health = hum.MaxHealth
            end)
            if _G.FakeDeadConn then
                _G.FakeDeadConn:Disconnect()
                _G.FakeDeadConn = nil
            end
        end
    end,
})

-- 10. 定身所有玩家（带检测）
hubtab:CreateToggle({
    Name = "定身所有玩家",
    CurrentValue = false,
    Callback = function(state)
        if not pcall(function()
            if state then
                if _G.FreezeAllConn then _G.FreezeAllConn:Disconnect() end
                _G.FreezeAllConn = game:GetService("RunService").Heartbeat:Connect(function()
                    for _, player in pairs(game.Players:GetPlayers()) do
                        if player ~= game.Players.LocalPlayer and player.Character then
                            local root = player.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                root.Velocity = Vector3.zero
                                root.RotVelocity = Vector3.zero
                            end
                        end
                    end
                end)
            else
                if _G.FreezeAllConn then
                    _G.FreezeAllConn:Disconnect()
                    _G.FreezeAllConn = nil
                end
            end
        end) then
            notify("定身所有玩家", "功能启动失败，可能被服务器拒绝")
        end
    end,
})

hubtab:CreateToggle({ Name = "旋转其他玩家", CurrentValue = false, Callback = function(s)
    if not pcall(function()
        if s then
            _G.SpinOthers = RunService.Heartbeat:Connect(function()
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= Plr and p.Character and p.Character.PrimaryPart then
                        p.Character.PrimaryPart.CFrame = p.Character.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(10), 0)
                    end
                end
            end)
        else
            if _G.SpinOthers then _G.SpinOthers:Disconnect() end
        end
    end) then notify("旋转其他玩家", "启动失败，可能被服务器拒绝") end
end })

-- 26. 弹跳其他玩家
hubtab:CreateToggle({ Name = "弹跳其他玩家", CurrentValue = false, Callback = function(s)
    if not pcall(function()
        if s then
            _G.BounceOthers = RunService.Heartbeat:Connect(function()
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= Plr and p.Character and p.Character.PrimaryPart then
                        p.Character.PrimaryPart.Velocity = Vector3.new(0, 50, 0)
                    end
                end
            end)
        else
            if _G.BounceOthers then _G.BounceOthers:Disconnect() end
        end
    end) then notify("弹跳其他玩家", "启动失败，可能被服务器拒绝") end
end })


-- 11. 显示坐标（带检测）
local coordsLabel = nil
hubtab:CreateToggle({
    Name = "显示坐标",
    CurrentValue = false,
    Callback = function(state)
        if not pcall(function()
            if state then
                coordsLabel = Instance.new("TextLabel", game.CoreGui)
                coordsLabel.Size = UDim2.new(0, 200, 0, 30)
                coordsLabel.Position = UDim2.new(0, 10, 0, 50)
                coordsLabel.BackgroundTransparency = 0.5
                coordsLabel.BackgroundColor3 = Color3.new(0, 0, 0)
                coordsLabel.TextColor3 = Color3.new(1, 1, 1)
                coordsLabel.Font = Enum.Font.SourceSansBold
                coordsLabel.TextSize = 16
                if _G.CoordsConn then _G.CoordsConn:Disconnect() end
                _G.CoordsConn = game:GetService("RunService").RenderStepped:Connect(function()
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        local pos = char:GetPivot().Position
                        coordsLabel.Text = string.format("X: %.1f  Y: %.1f  Z: %.1f", pos.X, pos.Y, pos.Z)
                    else
                        coordsLabel.Text = "角色未加载"
                    end
                end)
            else
                if coordsLabel then
                    coordsLabel:Destroy()
                    coordsLabel = nil
                end
                if _G.CoordsConn then
                    _G.CoordsConn:Disconnect()
                    _G.CoordsConn = nil
                end
            end
        end) then
            notify("显示坐标", "功能启动失败")
        end
    end,
})

-- 12. 强制重置（带检测）
hubtab:CreateButton({
    Name = "强制重置",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if not char then
            notify("强制重置", "角色未加载")
            return
        end
        local success = pcall(function()
            char:BreakJoints()
        end)
        if not success then
            notify("强制重置", "重置失败，请手动重生")
        end
    end,
})

-- ==================== FE功能合集 ====================
hubtab:CreateSection("FE辅助功能")

createButton(hubtab, "cccccsnngbydxh f3x gui", "https://raw.githubusercontent.com/cccccsnngbydxh/my-gui/5ecdf34fd58c9db3f4a65a27f4c747cc88838392/gui.lua")

-- ==================== 一、自动化辅助（全新） ====================
hubtab:CreateSection("自动化辅助")

-- 1. 自动开门
hubtab:CreateToggle({ Name = "自动开门", CurrentValue = false, Callback = function(s)
    if not pcall(function()
        if s then
            _G.AutoDoor = RunService.Heartbeat:Connect(function()
                for _, d in pairs(workspace:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and string.find(d.Name:lower(), "door") then
                        fireproximityprompt(d)
                    end
                end
            end)
        else
            if _G.AutoDoor then _G.AutoDoor:Disconnect() end
        end
    end) then notify("自动开门", "启动失败，游戏可能没有可交互的门") end
end })

-- 2. 自动爬梯
hubtab:CreateToggle({ Name = "自动爬梯", CurrentValue = false, Callback = function(s)
    if not pcall(function()
        if s then
            _G.AutoLadder = RunService.RenderStepped:Connect(function()
                local hum = Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum:GetState() == Enum.HumanoidStateType.Climbing then
                    hum.WalkSpeed = 50
                end
            end)
        else
            if _G.AutoLadder then _G.AutoLadder:Disconnect() end
        end
    end) then notify("自动爬梯", "启动失败，游戏可能没有梯子") end
end })

-- 3. 自动按按钮
hubtab:CreateToggle({ Name = "自动按按钮", CurrentValue = false, Callback = function(s)
    if not pcall(function()
        if s then
            _G.AutoButton = RunService.Heartbeat:Connect(function()
                for _, b in pairs(workspace:GetDescendants()) do
                    if b:IsA("ProximityPrompt") and string.find(b.Name:lower(), "button") then
                        fireproximityprompt(b)
                    end
                end
            end)
        else
            if _G.AutoButton then _G.AutoButton:Disconnect() end
        end
    end) then notify("自动按按钮", "启动失败，游戏可能没有按钮") end
end })

-- 4. 自动购买
hubtab:CreateToggle({ Name = "自动购买", CurrentValue = false, Callback = function(s)
    if not pcall(function()
        if s then
            _G.AutoBuy = RunService.Heartbeat:Connect(function()
                for _, p in pairs(workspace:GetDescendants()) do
                    if p:IsA("ProximityPrompt") and string.find(p.Name:lower(), "buy") then
                        fireproximityprompt(p)
                    end
                end
            end)
        else
            if _G.AutoBuy then _G.AutoBuy:Disconnect() end
        end
    end) then notify("自动购买", "启动失败，游戏可能没有购买交互") end
end })

-- 5. 自动拾取掉落物（全新优化版）
hubtab:CreateToggle({ Name = "自动拾取物品", CurrentValue = false, Callback = function(s)
    if not pcall(function()
        if s then
            _G.AutoLoot = RunService.Heartbeat:Connect(function()
                local root = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                for _, item in pairs(workspace:GetDescendants()) do
                    if item:IsA("BasePart") and (item:GetAttribute("Pickup") or item.Name:lower():find("coin") or item.Name:lower():find("gem") or item.Name:lower():find("loot")) then
                        if (item.Position - root.Position).Magnitude < 20 then
                            firetouchinterest(root, item, 0)
                            firetouchinterest(root, item, 1)
                        end
                    end
                end
            end)
        else
            if _G.AutoLoot then _G.AutoLoot:Disconnect() end
        end
    end) then notify("自动拾取", "启动失败，游戏可能没有掉落物") end
end })

-- ==================== 二、视觉增强（全新） ====================
hubtab:CreateSection("视觉增强")

-- 6. 夜视模式
hubtab:CreateToggle({ Name = "夜视模式", CurrentValue = false, Callback = function(s)
    pcall(function()
        if s then
            game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            game.Lighting.Brightness = 5
        else
            game.Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            game.Lighting.Brightness = 2
        end
    end)
end })

-- 7. 去除阴影
hubtab:CreateToggle({ Name = "去除阴影", CurrentValue = false, Callback = function(s)
    pcall(function() game.Lighting.GlobalShadows = not s end)
end })

-- 8. 去除树叶
hubtab:CreateToggle({ Name = "去除树叶", CurrentValue = false, Callback = function(s)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and string.find(v.Name:lower(), "leaf") then
            v.Transparency = s and 1 or 0
        end
    end
end })

-- 9. 去除草丛
hubtab:CreateToggle({ Name = "去除草丛", CurrentValue = false, Callback = function(s)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and string.find(v.Name:lower(), "grass") then
            v.Transparency = s and 1 or 0
        end
    end
end })

-- 10. 人物发光
local glowEnabled = false
hubtab:CreateToggle({ Name = "人物发光", CurrentValue = false, Callback = function(s)
    glowEnabled = s
    if not s and _G.GlowPart then _G.GlowPart:Destroy() end
    if s then
        task.spawn(function()
            while glowEnabled do
                if Plr.Character and Plr.Character.PrimaryPart then
                    local glow = Instance.new("PointLight", Plr.Character.PrimaryPart)
                    glow.Range = 10
                    glow.Brightness = 2
                    glow.Color = Color3.fromRGB(255, 0, 0)
                    _G.GlowPart = glow
                    break
                end
                task.wait(0.5)
            end
        end)
    end
end })

-- 11. 全图亮光
hubtab:CreateToggle({ Name = "全图亮光", CurrentValue = false, Callback = function(s)
    pcall(function()
        if s then
            game.Lighting.Brightness = 10
            game.Lighting.FogEnd = 100000
            game.Lighting.GlobalShadows = false
            game.Lighting.ClockTime = 12
        else
            game.Lighting.Brightness = 2
            game.Lighting.FogEnd = 500
            game.Lighting.GlobalShadows = true
        end
    end)
end })

-- 12. 移除雾气
hubtab:CreateToggle({ Name = "移除雾气", CurrentValue = false, Callback = function(s)
    pcall(function()
        if s then
            game.Lighting.FogStart = 100000
            game.Lighting.FogEnd = 100000
        else
            game.Lighting.FogStart = 0
            game.Lighting.FogEnd = 500
        end
    end)
end })

-- ==================== 三、战斗辅助（全新） ====================
hubtab:CreateSection("战斗辅助")

-- 14. 子弹追踪
hubtab:CreateToggle({ Name = "子弹追踪", CurrentValue = false, Callback = function(s)
    if not pcall(function()
        if s then
            _G.BulletTrack = RunService.RenderStepped:Connect(function()
                local myChar = Plr.Character
                if not myChar then return end
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= Plr and p.Character and p.Character:FindFirstChild("Head") then
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") and string.find(v.Name:lower(), "bullet") then
                                v.Velocity = (p.Character.Head.Position - v.Position).Unit * 500
                            end
                        end
                    end
                end
            end)
        else
            if _G.BulletTrack then _G.BulletTrack:Disconnect() end
        end
    end) then notify("子弹追踪", "启动失败，游戏可能没有子弹") end
end })

-- 15. 无限技能
hubtab:CreateToggle({ Name = "无限技能", CurrentValue = false, Callback = function(s)
    if not pcall(function()
        if s then
            _G.InfSkill = RunService.Heartbeat:Connect(function()
                for _, v in pairs(Plr.Backpack:GetChildren()) do
                    if v:IsA("Tool") and v:FindFirstChild("Cooldown") then
                        v.Cooldown.Value = 0
                    end
                end
                if Plr.Character then
                    for _, v in pairs(Plr.Character:GetChildren()) do
                        if v:IsA("Tool") and v:FindFirstChild("Cooldown") then
                            v.Cooldown.Value = 0
                        end
                    end
                end
            end)
        else
            if _G.InfSkill then _G.InfSkill:Disconnect() end
        end
    end) then notify("无限技能", "启动失败，游戏可能没有技能冷却") end
end })

-- 16. 快速换弹
hubtab:CreateToggle({ Name = "快速换弹", CurrentValue = false, Callback = function(s)
    if not pcall(function()
        if s then
            _G.FastReload = RunService.RenderStepped:Connect(function()
                if Plr.Character then
                    local tool = Plr.Character:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Ammo") then
                        tool.Ammo.Value = 999
                    end
                end
            end)
        else
            if _G.FastReload then _G.FastReload:Disconnect() end
        end
    end) then notify("快速换弹", "启动失败，游戏可能没有弹药系统") end
end })

-- 17. 子弹穿墙
hubtab:CreateToggle({ Name = "子弹穿墙", CurrentValue = false, Callback = function(s)
    if not pcall(function()
        if s then
            _G.BulletWall = RunService.Heartbeat:Connect(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and string.find(v.Name:lower(), "bullet") then
                        v.CanCollide = false
                    end
                end
            end)
        else
            if _G.BulletWall then _G.BulletWall:Disconnect() end
        end
    end) then notify("子弹穿墙", "启动失败，游戏可能没有子弹") end
end })

-- ==================== 四、网络与服务器（全新） ====================
hubtab:CreateSection("网络与服务器")

-- 18. 显示延迟
local pingLabel = nil
hubtab:CreateToggle({ Name = "显示延迟", CurrentValue = false, Callback = function(s)
    if not pcall(function()
        if s then
            pingLabel = Instance.new("TextLabel", game.CoreGui)
            pingLabel.Size = UDim2.new(0, 100, 0, 30)
            pingLabel.Position = UDim2.new(1, -110, 0, 90)
            pingLabel.BackgroundTransparency = 0.5
            pingLabel.BackgroundColor3 = Color3.new(0, 0, 0)
            pingLabel.TextColor3 = Color3.new(1, 1, 1)
            pingLabel.Font = Enum.Font.SourceSansBold
            pingLabel.TextSize = 16
            _G.PingConn = RunService.RenderStepped:Connect(function()
                local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                pingLabel.Text = "Ping: " .. math.floor(ping) .. "ms"
            end)
        else
            if pingLabel then pingLabel:Destroy() end
            if _G.PingConn then _G.PingConn:Disconnect() end
        end
    end) then notify("显示延迟", "启动失败，无法获取网络状态") end
end })

-- 19. 反挂机
hubtab:CreateToggle({ Name = "反挂机", CurrentValue = false, Callback = function(s)
    if not pcall(function()
        if s then
            _G.AntiAFK = RunService.Heartbeat:Connect(function()
                local vUser = game:GetService("VirtualUser")
                vUser:CaptureController()
                vUser:ClickButton2(Vector2.new())
            end)
        else
            if _G.AntiAFK then _G.AntiAFK:Disconnect() end
        end
    end) then notify("反挂机", "启动失败，VirtualUser不可用") end
end })

-- 20. 复制服务器ID
hubtab:CreateButton({ Name = "复制服务器ID", Callback = function()
    pcall(function()
        setclipboard(game.JobId)
        notify("服务器", "JobId已复制到剪贴板")
    end)
end })

-- 21. 查看服务器信息
hubtab:CreateButton({ Name = "服务器信息", Callback = function()
    notify("服务器", "位置: " .. game.PlaceId .. " | 玩家: " .. #game.Players:GetPlayers())
end })

-- ==================== 五、位置与传送（全新） ====================
hubtab:CreateSection("位置与传送")

-- 22. 保存当前位置
local savedPos = nil
hubtab:CreateButton({ Name = "保存位置", Callback = function()
    if Plr.Character and Plr.Character.PrimaryPart then
        savedPos = Plr.Character.PrimaryPart.Position
        notify("保存", "位置已保存")
    else
        notify("保存", "角色未加载")
    end
end })

-- 23. 传送到保存位置
hubtab:CreateButton({ Name = "传送到保存位置", Callback = function()
    if savedPos and Plr.Character then
        Plr.Character:MoveTo(savedPos)
        notify("传送", "已传送到保存位置")
    else
        notify("传送", "没有保存的位置")
    end
end })

-- 24. 传送到随机玩家
hubtab:CreateButton({ Name = "传送到随机玩家", Callback = function()
    local others = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr then table.insert(others, p) end
    end
    if #others > 0 then
        local target = others[math.random(#others)]
        if target.Character then
            Plr.Character:MoveTo(target.Character.PrimaryPart.Position)
            notify("传送", "已传送到 " .. target.Name)
        end
    else
        notify("传送", "没有其他玩家")
    end
end })

-- ==================== 七、工具类（全新） ====================
hubtab:CreateSection("工具类")

-- 29. 随机昵称
hubtab:CreateButton({ Name = "生成随机昵称", Callback = function()
    local adj = {"超级", "隐形", "狂暴", "闪电", "暗影", "烈焰", "冰霜", "雷霆", "神秘", "传奇"}
    local noun = {"战士", "法师", "刺客", "猎人", "骑士", "盗贼", "游侠", "牧师", "术士", "龙"}
    local name = adj[math.random(#adj)] .. noun[math.random(#noun)] .. math.random(100, 999)
    notify("随机昵称", name)
end })

-- 30. 显示系统时间
local timeLabel = nil
hubtab:CreateToggle({ Name = "显示系统时间", CurrentValue = false, Callback = function(s)
    pcall(function()
        if s then
            timeLabel = Instance.new("TextLabel", game.CoreGui)
            timeLabel.Size = UDim2.new(0, 100, 0, 30)
            timeLabel.Position = UDim2.new(0, 10, 0, 130)
            timeLabel.BackgroundTransparency = 0.5
            timeLabel.BackgroundColor3 = Color3.new(0, 0, 0)
            timeLabel.TextColor3 = Color3.new(1, 1, 1)
            timeLabel.Font = Enum.Font.SourceSansBold
            timeLabel.TextSize = 16
            _G.TimeConn = RunService.RenderStepped:Connect(function()
                timeLabel.Text = os.date("%H:%M:%S")
            end)
        else
            if timeLabel then timeLabel:Destroy() end
            if _G.TimeConn then _G.TimeConn:Disconnect() end
        end
    end)
end })

-- 31. 隐藏自己名字
hubtab:CreateToggle({ Name = "隐藏自己名字", CurrentValue = false, Callback = function(s)
    if Plr.Character then
        local head = Plr.Character:FindFirstChild("Head")
        if head then
            local tag = head:FindFirstChildOfClass("BillboardGui")
            if tag then tag.Enabled = not s end
        end
    end
end })

-- 32. 第三人称距离
hubtab:CreateSlider({ Name = "第三人称距离", Range = {5, 30}, Increment = 1, CurrentValue = 12, Callback = function(v)
    pcall(function()
        Plr.CameraMaxZoomDistance = v
        Plr.CameraMinZoomDistance = v
    end)
end })

-- 33. 视野缩放
hubtab:CreateSlider({ Name = "视野 (FOV)", Range = {30, 120}, Increment = 5, CurrentValue = 70, Callback = function(v)
    workspace.CurrentCamera.FieldOfView = v
end })

-- 34. 环境音量
hubtab:CreateSlider({ Name = "环境音量", Range = {0, 10}, Increment = 1, CurrentValue = 5, Callback = function(v)
    for _, s in pairs(workspace:GetDescendants()) do
        if s:IsA("Sound") then s.Volume = v end
    end
end })

-- 35. 停止所有音效
hubtab:CreateButton({ Name = "停止所有音效", Callback = function()
    for _, s in pairs(workspace:GetDescendants()) do
        if s:IsA("Sound") then s:Stop() end
    end
end })

-- ==================== 更多通用功能（全新，无重复） ====================
hubtab:CreateSection("更多通用功能")

-- 1. 防传送拦截（阻止被其他脚本或游戏传送）
hubtab:CreateToggle({
    Name = "防传送拦截",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local oldPosition = Plr.Character and Plr.Character.HumanoidRootPart and Plr.Character.HumanoidRootPart.Position
            _G.AntiTeleport = RunService.RenderStepped:Connect(function()
                local char = Plr.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root and oldPosition then
                    if (root.Position - oldPosition).Magnitude > 200 then
                        root.CFrame = CFrame.new(oldPosition)
                        notify("防传送", "拦截了一次传送")
                    else
                        oldPosition = root.Position
                    end
                else
                    oldPosition = root and root.Position
                end
            end)
        else
            if _G.AntiTeleport then _G.AntiTeleport:Disconnect() end
        end
    end,
})

-- 2. 自动回复私聊（收到私聊自动回复）
local autoReplyMsg = "我现在忙，稍后回复。"
hubtab:CreateToggle({
    Name = "自动回复私聊",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local chatService = game:GetService("TextChatService")
            _G.AutoReplyConn = chatService.MessageReceived:Connect(function(msg)
                if msg.TextChannel and msg.TextChannel:IsA("TextChannel") and msg.TextChannel.Name == "Private" then
                    if msg.PrefixText ~= Plr.Name then
                        local channel = msg.TextChannel
                        task.wait(0.5)
                        channel:SendAsync("[自动回复] " .. autoReplyMsg)
                    end
                end
            end)
        else
            if _G.AutoReplyConn then _G.AutoReplyConn:Disconnect() end
        end
    end,
})
hubtab:CreateButton({
    Name = "设置自动回复内容",
    Callback = function()
        local input = prompt("输入自动回复内容", autoReplyMsg)
        if input then autoReplyMsg = input end
    end,
})

-- 3. 快速切换视角（一键切换第一/三人称）
hubtab:CreateButton({
    Name = "切换第一/三人称",
    Callback = function()
        local cam = workspace.CurrentCamera
        if cam.CameraType == Enum.CameraType.Custom then
            cam.CameraType = Enum.CameraType.Scriptable
            notify("视角", "已切换为第一人称")
        else
            cam.CameraType = Enum.CameraType.Custom
            notify("视角", "已切换为第三人称")
        end
    end,
})

-- 4. 显示内存占用（实时）
local memLabel = nil
hubtab:CreateToggle({
    Name = "显示内存占用",
    CurrentValue = false,
    Callback = function(state)
        pcall(function()
            if state then
                memLabel = Instance.new("TextLabel", game.CoreGui)
                memLabel.Size = UDim2.new(0, 150, 0, 30)
                memLabel.Position = UDim2.new(1, -160, 0, 250)
                memLabel.BackgroundTransparency = 0.5
                memLabel.BackgroundColor3 = Color3.new(0,0,0)
                memLabel.TextColor3 = Color3.new(1,0.5,0)
                memLabel.Font = Enum.Font.SourceSansBold
                memLabel.TextSize = 16
                _G.MemConn = RunService.RenderStepped:Connect(function()
                    local mem = collectgarbage("count")
                    memLabel.Text = string.format("内存: %.1f MB", mem / 1024)
                end)
            else
                if memLabel then memLabel:Destroy() end
                if _G.MemConn then _G.MemConn:Disconnect() end
            end
        end)
    end,
})

-- 5. 自动喝药水（血量低于阈值自动使用背包中的治疗物品）
local healthThreshold = 50
hubtab:CreateToggle({
    Name = "自动喝药水",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AutoPotion = RunService.Heartbeat:Connect(function()
                local char = Plr.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum and hum.Health < hum.MaxHealth * (healthThreshold / 100) then
                    for _, tool in ipairs(Plr.Backpack:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name:lower():find("potion") or tool.Name:lower():find("health")) then
                            tool.Parent = char
                            tool:Activate()
                            task.wait(0.5)
                            tool.Parent = Plr.Backpack
                            break
                        end
                    end
                end
            end)
        else
            if _G.AutoPotion then _G.AutoPotion:Disconnect() end
        end
    end,
})
hubtab:CreateSlider({
    Name = "喝药血量阈值(%)",
    Range = {10, 90},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) healthThreshold = v end,
})

-- 6. 自动接受队伍邀请
hubtab:CreateToggle({
    Name = "自动接受队伍邀请",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AutoAcceptTeam = game.Players.LocalPlayer.PlayerGui.DescendantAdded:Connect(function(gui)
                if gui:IsA("TextButton") and (gui.Text:lower():find("accept") or gui.Text:lower():find("join")) then
                    task.wait(0.3)
                    gui:Invoke()
                end
            end)
        else
            if _G.AutoAcceptTeam then _G.AutoAcceptTeam:Disconnect() end
        end
    end,
})

-- 7. 关闭屏幕震动（移除 CameraShake）
hubtab:CreateToggle({
    Name = "关闭屏幕震动",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.NoShakeConn = RunService.RenderStepped:Connect(function()
                local cam = workspace.CurrentCamera
                if cam:FindFirstChild("CameraShake") then
                    cam.CameraShake:Destroy()
                end
            end)
        else
            if _G.NoShakeConn then _G.NoShakeConn:Disconnect() end
        end
    end,
})

-- 8. 去除屏幕特效（模糊/色调/景深等）
hubtab:CreateToggle({
    Name = "去除屏幕特效",
    CurrentValue = false,
    Callback = function(state)
        pcall(function()
            if state then
                for _, effect in ipairs(game.Lighting:GetChildren()) do
                    if effect:IsA("PostEffect") then
                        effect.Enabled = false
                        _G.DisabledEffects = _G.DisabledEffects or {}
                        table.insert(_G.DisabledEffects, effect)
                    end
                end
            else
                if _G.DisabledEffects then
                    for _, effect in ipairs(_G.DisabledEffects) do
                        effect.Enabled = true
                    end
                    _G.DisabledEffects = nil
                end
            end
        end)
    end,
})

-- 9. 自动收集经验球（移动触碰到即收集）
hubtab:CreateToggle({
    Name = "自动收集经验球",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AutoExpOrb = RunService.Heartbeat:Connect(function()
                local root = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("exp") or obj.Name:lower():find("orb")) then
                        if (obj.Position - root.Position).Magnitude < 20 then
                            firetouchinterest(root, obj, 0)
                            firetouchinterest(root, obj, 1)
                        end
                    end
                end
            end)
        else
            if _G.AutoExpOrb then _G.AutoExpOrb:Disconnect() end
        end
    end,
})

-- 10. 显示玩家距离（实时显示最近玩家距离）
local distLabel = nil
hubtab:CreateToggle({
    Name = "显示最近玩家距离",
    CurrentValue = false,
    Callback = function(state)
        if state then
            distLabel = Instance.new("TextLabel", game.CoreGui)
            distLabel.Size = UDim2.new(0, 180, 0, 30)
            distLabel.Position = UDim2.new(1, -190, 0, 280)
            distLabel.BackgroundTransparency = 0.5
            distLabel.BackgroundColor3 = Color3.new(0,0,0)
            distLabel.TextColor3 = Color3.new(0.8,1,0.8)
            distLabel.Font = Enum.Font.SourceSansBold
            distLabel.TextSize = 16
            _G.DistConn = RunService.RenderStepped:Connect(function()
                local myRoot = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
                if not myRoot then
                    distLabel.Text = "角色未加载"
                    return
                end
                local closestDist = math.huge
                for _, p in ipairs(game.Players:GetPlayers()) do
                    if p ~= Plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (p.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                        if dist < closestDist then closestDist = dist end
                    end
                end
                if closestDist == math.huge then
                    distLabel.Text = "无其他玩家"
                else
                    distLabel.Text = string.format("最近玩家: %.1f 米", closestDist)
                end
            end)
        else
            if distLabel then distLabel:Destroy() end
            if _G.DistConn then _G.DistConn:Disconnect() end
        end
    end,
})

-- 11. 瞬移到准星位置（按 Q 键）
hubtab:CreateToggle({
    Name = "瞬移到准星 (按Q)",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local mouse = Plr:GetMouse()
            _G.QTeleport = mouse.KeyDown:Connect(function(key)
                if key == "q" then
                    local target = mouse.Hit.p
                    if Plr.Character then
                        Plr.Character.HumanoidRootPart.CFrame = CFrame.new(target)
                    end
                end
            end)
        else
            if _G.QTeleport then _G.QTeleport:Disconnect() end
        end
    end,
})

-- 12. 自动拾取最近物品（按下 E 键拾取 10 米内最近的可拾取物）
hubtab:CreateToggle({
    Name = "E键拾取最近物品",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local mouse = Plr:GetMouse()
            _G.EPickup = mouse.KeyDown:Connect(function(key)
                if key == "e" then
                    local root = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
                    if not root then return end
                    local nearest, minDist = nil, math.huge
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("Tool") and obj.Parent == workspace then
                            local dist = (obj.Position - root.Position).Magnitude
                            if dist < minDist and dist < 10 then
                                nearest = obj
                                minDist = dist
                            end
                        end
                    end
                    if nearest then
                        root.CFrame = nearest.CFrame
                        task.wait(0.1)
                        Plr.Character.Humanoid:EquipTool(nearest)
                    end
                end
            end)
        else
            if _G.EPickup then _G.EPickup:Disconnect() end
        end
    end,
})

-- 13. 死亡自动观战（死亡后自动观战击杀者或随机玩家）
hubtab:CreateToggle({
    Name = "死亡自动观战",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.DeathSpectate = Plr.CharacterAdded:Connect(function(char)
                local hum = char:WaitForChild("Humanoid")
                hum.Died:Connect(function()
                    task.wait(1)
                    local cam = workspace.CurrentCamera
                    local others = {}
                    for _, p in ipairs(game.Players:GetPlayers()) do
                        if p ~= Plr and p.Character then
                            table.insert(others, p)
                        end
                    end
                    if #others > 0 then
                        cam.CameraSubject = others[math.random(#others)].Character
                    end
                end)
            end)
        else
            if _G.DeathSpectate then _G.DeathSpectate:Disconnect() end
        end
    end,
})

-- 14. 无限放置物品（拖动物品栏物品不消耗）
hubtab:CreateToggle({
    Name = "无限放置物品",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.InfPlace = RunService.Heartbeat:Connect(function()
                for _, tool in ipairs(Plr.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Count") then
                        tool.Count.Value = 999
                    end
                end
                if Plr.Character then
                    for _, tool in ipairs(Plr.Character:GetChildren()) do
                        if tool:IsA("Tool") and tool:FindFirstChild("Count") then
                            tool.Count.Value = 999
                        end
                    end
                end
            end)
        else
            if _G.InfPlace then _G.InfPlace:Disconnect() end
        end
    end,
})
local centerTab = Window:CreateTab("脚本中心")

local function copyToClipboard(text, hubName)
    setclipboard(text)
    Rayfield:Notify({
        Title = hubName,
        Content = "此脚本需要解锁，请前往链接获取脚本，已自动复制至剪贴板",
        Duration = 2
    })
end

local hubs = {
    {Name = "XA Hub", Link = "https://raw.githubusercontent.com/XiaoYunUwU/XA/main/Loader.lua"},
    {Name = "XK Hub", Link = "https://github.com/DevSloPo/DVES/raw/main/XK%20Hub"},
    {Name = "SA脚本", Link = "https://raw.githubusercontent.com/Bebo-Mods/BeboScripts/main/StandAwekening.lua"},
    {Name = "ZeroHub", Link = "https://raw.githubusercontent.com/xerath-devx/ETFB/refs/heads/main/tokenmultiplier.lua"},
    {Name = "BHBUO脚本", Link = "https://raw.githubusercontent.com/jbu7666gvv/BHBUO/refs/heads/main/loader"},
    {Name = "BS脚本", Link = "https://gitee.com/BS_script/script/raw/master/BS_Script.Luau"},
    {Name = "Rb脚本中心", Link = "https://raw.githubusercontent.com/Yungengxin/roblox/main/RbHub-v_1.2.4"},
    {Name = "XT缝合脚本", Link = "https://raw.githubusercontent.com/wttdxt/xt/refs/heads/main/XT%E5%8D%A1%E5%AF%86%E7%B3%BB%E7%BB%9F%E5%8A%A0%E5%AF%86%E7%89%88.bak"},
    {Name = "TX V3", Link = "https://raw.githubusercontent.com/JsYb666/TX-Free/refs/heads/main/TX-V3.0"},
    {Name = "TX V2免费版", Link = "https://raw.githubusercontent.com/JsYb666/TX-Free-YYDS/refs/heads/main/TX-Pro-Free"},
    -- 新整合项目 11~30
    {Name = "安脚本中心", Link = "https://raw.githubusercontent.com/wucan114514/gegeyxjb/main/oww"},
    {Name = "大司马脚本中心V6", Link = "https://raw.githubusercontent.com/whenheer/dasimav6/refs/heads/main/dasimaV6.txt"},
    {Name = "德与中山脚本中心", Link = "https://raw.githubusercontent.com/dream77239/Deyu-Zhongshan/refs/heads/main/%E5%BE%B7%E4%B8%8E%E4%B8%AD%E5%B1%B1.txt"},
    {Name = "迪脚本新版", Link = "https://api.junkie-development.de/api/v1/luascripts/public/54464412341ef904e10fb8d7ea70e047969d47b06a488cac60fbf8484ff70b83/download"},
    {Name = "黑白脚本", Link = "https://raw.githubusercontent.com/tfcygvunbind/Apple/main/黑白脚本加载器"},
    {Name = "BSS脚本", Link = "https://api.junker-development.de/api/v1/lua/scripts/public/dd6ffea7a477a9832c/gamelinkbf07a5c1bcd919c1bbd8778cbb4b4c20ae/download"},
    {Name = "皮脚本", Link = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"},
    {Name = "叶脚本", Link = "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua"},
    {Name = "盗图脚本", Link = "https://raw.githubusercontent.com/twobt/famimaiwukollw/bw666/main/DOLL.lua"},
    {Name = "X脚本", Link = "https://raw.githubusercontent.com/hljmg/XSCRIPTP-HUB/Script/main/X-SCRIPTP/"},
    {Name = "本脚本", Link = "https://pastefy.app/N5P1BGT/raw"},
    {Name = "KG脚本", Link = "https://github.com/25-NIKGRAF/main/Zhang-Shuua.lua"},
    {Name = "XPro脚本", Link = "https://pastebin.com/raw/wr7n"},
    {Name = "夜宁脚本", Link = "https://raw.githubusercontent.com/6XWRNTWL/dingding123hh/mg/main/lllllllllllll.lua"},
    {Name = "提子中心脚本", Link = "https://raw.githubusercontent.com/6XWRNTWL/"},
    {Name = "沙脚本", Link = "https://raw.githubusercontent.com/Yb666TX-Free-YDYS/main/ShuHUB.lua"},
    {Name = "安颜脚本", Link = "https://raw.githubusercontent.com/wuancan1415/AnYanPN-Loading/安颜.lua"},
    {Name = "到关脚本", Link = "https://pastefy.app/wa3v2Vgm/raw"},
    {Name = "冷脚本", Link = "https://raw.githubusercontent.com/odhdshhe/lenglenglenglenglenglenglenglenglenglenglenglenglenglenglenglenglenglenglenglengscriptcoldLBT-H/refs/heads/main/LENG%20script%20cold%20LBT-H.txt"},
    {Name = "APEX HUB", Link = "https://api.luarmor.net/files/v3/loaders/b200427847354ec1a5931167334d8.lua"}
}

for _, hub in pairs(hubs) do
    centerTab:CreateButton({
        Name = hub.Name,
        Callback = function() loadstring(game:HttpGet(hub.Link))() end,
    })
end
centerTab:CreateSection("外网脚本")
-- 外网脚本中心分区

-- SpaceHub (支持150+游戏)
centerTab:CreateButton({
   Name = "SpaceHub",
   Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))() end,
})

-- Solvex Hub (自动检测游戏)
centerTab:CreateButton({
   Name = "Solvex Hub",
   Callback = function() loadstring(game:HttpGet("https://cdn.sourceb.in/bins/3UxaWKaCmm/0"))() end,
})

-- Avocat Hub (轻量级通用脚本)
centerTab:CreateButton({
   Name = "Avocat Hub",
   Callback = function() 
      -- 注意: 脚本内容较长，直接从ScriptBlox加载原始代码
      loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Avocat-HUB-142656"))()
   end,
})
createButton(centerTab, "GhostHub", "https://rawscripts.net/raw/Universal-Script-GhostHub-53688")
createButton(centerTab, "VoidX Hub V2", "https://rawscripts.net/raw/Universal-Script-VoidX-Hub-V2-1-0-98319")
-- Flow Script Hub (支持14+游戏)
centerTab:CreateButton({
   Name = "Flow Script Hub",
   Callback = function() loadstring(game:HttpGet('https://rawscripts.net/raw/Universal-Script-Flow-Script-Hub-140129'))() end,
})
centerTab:CreateButton({
   Name = "Midnight Hub",
   Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/yeahblxr/-Midnight-hub/refs/heads/main/Midnight%20Hub"))() end,
})
centerTab:CreateButton({
   Name = "Rakesa Hub",
   Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Nah-185149"))() end,
})
centerTab:CreateButton({
   Name = "Best op universal",
   Callback = function() loadstring(game:HttpGet("https://pastebin.com/raw/XfLES1W2"))() end,
})
-- Redz Hub (多功能脚本)
centerTab:CreateButton({
   Name = "Redz Hub",
   Callback = function() loadstring(game:HttpGet("https://pastefy.app/ACOX6D6h/raw"))() end,
})
-- ZO Vortex Hub (轻量快速)
centerTab:CreateButton({
   Name = "ZO Vortex Hub",
   Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-NeoZ-Hub-70445"))() end,
})

-- WhitzHub (开源脚本库)
centerTab:CreateButton({
   Name = "WhitzHub",
   Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Whitzhub-58566"))() end,
})
centerTab:CreateSection("外网需要卡密的脚本")
createButton(centerTab, "LummaHub (30+游戏)", "https://rawscripts.net/raw/Universal-Script-LummaHub-OP-KEYLESS-30-GAMES-100-FEATURES-99321")
centerTab:CreateButton({
   Name = "Galactic Scripts Hub",
   Callback = function() 
      copyToClipboard("https://discordhunt.com/en/servers/galactic-scripts-hub-1378778070009253898", "Galactic Scripts Hub")
   end,
})

centerTab:CreateButton({
   Name = "neox hub key system bypass",
   Callback = function() copyToClipboard("https://pastefy.app/d3HjRJdF/raw", "neox hub bypass") end,
})

centerTab:CreateButton({
   Name = "Lumin Hub",
   Callback = function() copyToClipboard("https://lumin-hub.lol/loader.lua", "Lumin Hub") end,
})

centerTab:CreateButton({
   Name = "EagleKey (Project E Hub)",
   Callback = function() copyToClipboard("https://www.mycompiler.io/view/EagleKey", "EagleKey") end,
})

centerTab:CreateButton({
   Name = "Kawatan Hub Premium Duel",
   Callback = function() copyToClipboard("https://pastebin.com/raw/GLjW4DuU", "Kawatan Hub") end,
})

centerTab:CreateButton({
   Name = "Freeze Hub (Freeze Trade)",
   Callback = function() copyToClipboard("https://pastebin.com/raw/6gH8Uv0k", "Freeze Hub") end,
})

centerTab:CreateButton({
   Name = "Moondiety Hub (待确认链接)",
   Callback = function() copyToClipboard("https://rawscripts.net/raw/Moondiety-Hub", "Moondiety Hub") end,
})
centerTab:CreateButton({
   Name = "NotHub",
   Callback = function() 
      copyToClipboard("https://top.gg/tr/discord/servers/773661099230834688", "NotHub")
   end,
})

-- 1. Nexus Hub（支持多游戏）
centerTab:CreateButton({
    Name = "Nexus Hub",
    Callback = function() copyToClipboard("https://raw.githubusercontent.com/NexusHub/Nexus/main/Loader.lua", "Nexus Hub") end,
})

-- 2. Eclipse Hub（知名通用脚本）
centerTab:CreateButton({
    Name = "Eclipse Hub",
    Callback = function() copyToClipboard("https://raw.githubusercontent.com/EclipseHub/Eclipse/main/Eclipse.lua", "Eclipse Hub") end,
})

-- 3. Synapse X Hub（需密钥，官方加载器）
centerTab:CreateButton({
    Name = "Synapse X Hub (Official)",
    Callback = function() copyToClipboard("https://synapsehub.xyz/loader.lua", "Synapse X Hub") end,
})

-- 4. Neverlose Hub（竞技游戏脚本）
centerTab:CreateButton({
    Name = "Neverlose Hub",
    Callback = function() copyToClipboard("https://neverlose.cc/market/item?id=123456", "Neverlose Hub") end, -- 示例链接，实际请替换
})

-- 5. Astro Hub（轻量级通用）
centerTab:CreateButton({
    Name = "Astro Hub",
    Callback = function() copyToClipboard("https://rawscripts.net/raw/Universal-Script-Astro-Hub-78901", "Astro Hub") end,
})

-- 6. Vynixius Hub（死轨/狱警等）
centerTab:CreateButton({
    Name = "Vynixius Hub",
    Callback = function() copyToClipboard("https://raw.githubusercontent.com/Vynixius/Hub/main/Loader.lua", "Vynixius Hub") end,
})

-- 7. Quantum Hub（功能全面）
centerTab:CreateButton({
    Name = "Quantum Hub",
    Callback = function() copyToClipboard("https://quantumhub.xyz/loader.lua", "Quantum Hub") end,
})

-- 8. Zypher Hub（自动更新）
centerTab:CreateButton({
    Name = "Zypher Hub",
    Callback = function() copyToClipboard("https://raw.githubusercontent.com/ZypherHub/Zypher/main/loader.lua", "Zypher Hub") end,
})

-- 9. Aegis Hub（反检测较强）
centerTab:CreateButton({
    Name = "Aegis Hub",
    Callback = function() copyToClipboard("https://aegishub.xyz/loader.lua", "Aegis Hub") end,
})

-- 10. Celestial Hub（多游戏支持）
centerTab:CreateButton({
    Name = "Celestial Hub",
    Callback = function() copyToClipboard("https://celestialhub.dev/loader.lua", "Celestial Hub") end,
})

-- 11. Vortex Hub（移动端友好）
centerTab:CreateButton({
    Name = "Vortex Hub (Mobile)",
    Callback = function() copyToClipboard("https://raw.githubusercontent.com/VortexHub/Mobile/main/loader.lua", "Vortex Hub") end,
})

-- 12. Prime Hub（付费脚本破解版链接，仅供研究）
centerTab:CreateButton({
    Name = "Prime Hub (Crack)",
    Callback = function() copyToClipboard("https://pastebin.com/raw/PrimeHubCrack", "Prime Hub") end,
})

-- 13. Edge Hub（边缘竞技）
centerTab:CreateButton({
    Name = "Edge Hub",
    Callback = function() copyToClipboard("https://edgehub.xyz/loader.lua", "Edge Hub") end,
})

-- 14. Xero Hub（新星脚本）
centerTab:CreateButton({
    Name = "Xero Hub",
    Callback = function() copyToClipboard("https://raw.githubusercontent.com/XeroHub/Xero/main/Xero.lua", "Xero Hub") end,
})

-- 15. Oxy Hub（暗黑风格UI）
centerTab:CreateButton({
    Name = "Oxy Hub",
    Callback = function() copyToClipboard("https://oxyhub.xyz/loader.lua", "Oxy Hub") end,
})
local toolsTab = Window:CreateTab("工具脚本")

local tools = {
    {Name = "汉化Spy", Link = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/spy%E6%B1%89%E5%8C%96%20(1).txt"},
    {Name = "改版rspy", Link = "https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"},
    {Name = "Infinite Yield", Link = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"},
    {Name = "汉化 Dex V3", Link = "https://raw.githubusercontent.com/Twbtx/tiamxiabuwu/main/han%20hua%20%20dex%20v3"},
    {Name = "CMD-X - 命令行工具脚本", Link = "https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source"},
    {Name = "Hydroxide - 反向工程和漏洞利用工具", Link = "https://raw.githubusercontent.com/iK4oS/backdoor.exe/v8/src/main.lua"},
    {Name = "SimpleAdmin - 简单的管理员面板", Link = "https://raw.githubusercontent.com/exxtremestuffs/SimpleAdmin/main/SimpleAdmin.lua"},
    {Name = "Remote Spy - 远程调用监控器", Link = "https://raw.githubusercontent.com/470n1/RemoteSpy/main/Main.lua"},
    {Name = "Script Dumper - 脚本转储工具", Link = "https://raw.githubusercontent.com/FilteringEnabled/ScriptDumper/main/ScriptDumper.lua"},
    {Name = "Elysian - 高级脚本管理器", Link = "https://raw.githubusercontent.com/ElysianManager/Elysian/main/Loader.lua"},
    {Name = "Unnamed ESP - 无名透视工具", Link = "https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua"},
}

for _, tool in pairs(tools) do
    toolsTab:CreateButton({
        Name = tool.Name,
        Callback = function() loadstring(game:HttpGet(tool.Link))() end,
    })
end

local lt2Tab = Window:CreateTab("伐木大亨2")
lt2Tab:CreateButton({
   Name = "粉车生成",
   Callback = function()
      -- loadstring(game:GetObjects("rbxassetid://5740257502")[.Source)()

local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Vehicle = Instance.new("TextLabel")
local CurColor = Instance.new("TextLabel")
local Execute = Instance.new("TextButton")
local ScrollingFrame = Instance.new("ScrollingFrame")
local TextLabel = Instance.new("TextLabel")
local Color_1 = Instance.new("TextButton")
local Color_15 = Instance.new("TextButton")
local Color_14 = Instance.new("TextButton")
local Color_13 = Instance.new("TextButton")
local Color_12 = Instance.new("TextButton")
local Color_11 = Instance.new("TextButton")
local Color_10 = Instance.new("TextButton")
local Color_9 = Instance.new("TextButton")
local Color_8 = Instance.new("TextButton")
local Color_7 = Instance.new("TextButton")
local Color_6 = Instance.new("TextButton")
local Color_5 = Instance.new("TextButton")
local Color_4 = Instance.new("TextButton")
local Color_3 = Instance.new("TextButton")
local Color_2 = Instance.new("TextButton")
 
ScreenGui.Parent = game.CoreGui

Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.new(1, 1, 1)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.372576177, -509, 0.0266900957, 334)
Main.Size = UDim2.new(0, 213, 0, 246)
Main.SizeConstraint = Enum.SizeConstraint.RelativeXX
Main.Visible = false

Vehicle.Name = "Vehicle"
Vehicle.Parent = Main
Vehicle.BackgroundColor3 = Color3.new(0, 0.866667, 1)
Vehicle.BorderSizePixel = 0
Vehicle.Position = UDim2.new(0, 0, 1.16666663, 0)
Vehicle.Size = UDim2.new(0, 214, 0, 30)
Vehicle.Font = Enum.Font.Garamond
Vehicle.Text = " Vehicle: Not Selected "
Vehicle.TextColor3 = Color3.new(1, 0, 0)
Vehicle.TextScaled = true
Vehicle.TextSize = 14
Vehicle.TextWrapped = true

CurColor.Name = "CurColor"
CurColor.Parent = Main
CurColor.BackgroundColor3 = Color3.new(0.854902, 0.854902, 0.854902)
CurColor.BackgroundTransparency = 1
CurColor.BorderSizePixel = 0
CurColor.Size = UDim2.new(0, 213, 0, 46)
CurColor.Font = Enum.Font.SourceSans
CurColor.Text = " Color: Not Selected "
CurColor.TextColor3 = Color3.new(0.0901961, 1, 0.972549)
CurColor.TextScaled = true
CurColor.TextSize = 14
CurColor.TextWrapped = true

Execute.Name = "Execute"
Execute.Parent = Main
Execute.BackgroundColor3 = Color3.new(0.529412, 0.054902, 1)
Execute.BackgroundTransparency = 0.0099999997764826
Execute.BorderSizePixel = 0
Execute.Position = UDim2.new(0, 0, 0.998856544, 0)
Execute.Size = UDim2.new(0, 213, 0, 42)
Execute.Font = Enum.Font.Cartoon
Execute.Text = "Execute"
Execute.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Execute.TextSize = 35
Execute.TextWrapped = true

ScrollingFrame.Parent = Main
ScrollingFrame.Active = true
ScrollingFrame.BackgroundColor3 = Color3.new(1, 1, 1)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 0, 0.182926834, 0)
ScrollingFrame.Size = UDim2.new(0, 213, 0, 201)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2.4000001, 0)

TextLabel.Parent = ScrollingFrame
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 0, 0.932706356, 0)
TextLabel.Size = UDim2.new(0, 199, 0, 39)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Hacker#8326"
TextLabel.TextColor3 = Color3.new(0, 1, 1)
TextLabel.TextScaled = true
TextLabel.TextSize = 14
TextLabel.TextWrapped = true

Color_1.Name = "Color_1"
Color_1.Parent = ScrollingFrame
Color_1.BackgroundColor3 = Color3.new(1, 1, 1)
Color_1.BackgroundTransparency = 1
Color_1.BorderSizePixel = 0
Color_1.Position = UDim2.new(0, 0, 0.000889120041, 0)
Color_1.Size = UDim2.new(0, 199, 0, 37)
Color_1.Font = Enum.Font.Cartoon
Color_1.Text = "Medium stone grey"
Color_1.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_1.TextSize = 35
Color_1.TextWrapped = true
Color_1.TextXAlignment = Enum.TextXAlignment.Left

Color_15.Name = "Color_15"
Color_15.Parent = ScrollingFrame
Color_15.BackgroundColor3 = Color3.new(1, 1, 1)
Color_15.BackgroundTransparency = 1
Color_15.BorderSizePixel = 0
Color_15.Position = UDim2.new(0, 0, 0.435725302, 0)
Color_15.Size = UDim2.new(0, 199, 0, 37)
Color_15.Font = Enum.Font.Cartoon
Color_15.Text = "Sand green"
Color_15.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_15.TextSize = 35
Color_15.TextWrapped = true
Color_15.TextXAlignment = Enum.TextXAlignment.Left

Color_14.Name = "Color_14"
Color_14.Parent = ScrollingFrame
Color_14.BackgroundColor3 = Color3.new(1, 1, 1)
Color_14.BackgroundTransparency = 1
Color_14.BorderSizePixel = 0
Color_14.Position = UDim2.new(0, 0, 0.497316808, 0)
Color_14.Size = UDim2.new(0, 199, 0, 37)
Color_14.Font = Enum.Font.Cartoon
Color_14.Text = "Sand red"
Color_14.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_14.TextSize = 35
Color_14.TextWrapped = true
Color_14.TextXAlignment = Enum.TextXAlignment.Left

Color_13.Name = "Color_13"
Color_13.Parent = ScrollingFrame
Color_13.BackgroundColor3 = Color3.new(1, 1, 1)
Color_13.BackgroundTransparency = 1
Color_13.BorderSizePixel = 0
Color_13.Position = UDim2.new(0, 0, 0.558908343, 0)
Color_13.Size = UDim2.new(0, 199, 0, 37)
Color_13.Font = Enum.Font.Cartoon
Color_13.Text = "Faded green"
Color_13.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_13.TextSize = 35
Color_13.TextWrapped = true
Color_13.TextXAlignment = Enum.TextXAlignment.Left

Color_12.Name = "Color_12"
Color_12.Parent = ScrollingFrame
Color_12.BackgroundColor3 = Color3.new(1, 1, 1)
Color_12.BackgroundTransparency = 1
Color_12.BorderSizePixel = 0
Color_12.Position = UDim2.new(0, 0, 0.374133736, 0)
Color_12.Size = UDim2.new(0, 199, 0, 37)
Color_12.Font = Enum.Font.Cartoon
Color_12.Text = "Dark grey metallic"
Color_12.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_12.TextSize = 35
Color_12.TextWrapped = true
Color_12.TextXAlignment = Enum.TextXAlignment.Left

Color_11.Name = "Color_11"
Color_11.Parent = ScrollingFrame
Color_11.BackgroundColor3 = Color3.new(1, 1, 1)
Color_11.BackgroundTransparency = 1
Color_11.BorderSizePixel = 0
Color_11.Position = UDim2.new(0, 0, 0.248948976, 0)
Color_11.Size = UDim2.new(0, 199, 0, 37)
Color_11.Font = Enum.Font.Cartoon
Color_11.Text = "Dark grey"
Color_11.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_11.TextSize = 35
Color_11.TextWrapped = true
Color_11.TextXAlignment = Enum.TextXAlignment.Left

Color_10.Name = "Color_10"
Color_10.Parent = ScrollingFrame
Color_10.BackgroundColor3 = Color3.new(1, 1, 1)
Color_10.BackgroundTransparency = 1
Color_10.BorderSizePixel = 0
Color_10.Position = UDim2.new(0, 0, 0.18735747, 0)
Color_10.Size = UDim2.new(0, 199, 0, 37)
Color_10.Font = Enum.Font.Cartoon
Color_10.Text = "Earth yellow"
Color_10.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_10.TextSize = 35
Color_10.TextWrapped = true
Color_10.TextXAlignment = Enum.TextXAlignment.Left

Color_9.Name = "Color_9"
Color_9.Parent = ScrollingFrame
Color_9.BackgroundColor3 = Color3.new(1, 1, 1)
Color_9.BackgroundTransparency = 1
Color_9.BorderSizePixel = 0
Color_9.Position = UDim2.new(0, 0, 0.125765949, 0)
Color_9.Size = UDim2.new(0, 199, 0, 37)
Color_9.Font = Enum.Font.Cartoon
Color_9.Text = "Earth orange"
Color_9.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_9.TextSize = 35
Color_9.TextWrapped = true
Color_9.TextXAlignment = Enum.TextXAlignment.Left

Color_8.Name = "Color_8"
Color_8.Parent = ScrollingFrame
Color_8.BackgroundColor3 = Color3.new(1, 1, 1)
Color_8.BackgroundTransparency = 1
Color_8.BorderSizePixel = 0
Color_8.Position = UDim2.new(0, 0, 0.0641744137, 0)
Color_8.Size = UDim2.new(0, 199, 0, 37)
Color_8.Font = Enum.Font.Cartoon
Color_8.Text = "Silver"
Color_8.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_8.TextSize = 35
Color_8.TextWrapped = true
Color_8.TextXAlignment = Enum.TextXAlignment.Left

Color_7.Name = "Color_7"
Color_7.Parent = ScrollingFrame
Color_7.BackgroundColor3 = Color3.new(1, 1, 1)
Color_7.BackgroundTransparency = 1
Color_7.BorderSizePixel = 0
Color_7.Position = UDim2.new(0, 0, 0.747378469, 0)
Color_7.Size = UDim2.new(0, 199, 0, 37)
Color_7.Font = Enum.Font.Cartoon
Color_7.Text = "Brick yellow"
Color_7.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_7.TextSize = 35
Color_7.TextWrapped = true
Color_7.TextXAlignment = Enum.TextXAlignment.Left

Color_6.Name = "Color_6"
Color_6.Parent = ScrollingFrame
Color_6.BackgroundColor3 = Color3.new(1, 1, 1)
Color_6.BackgroundTransparency = 1
Color_6.BorderSizePixel = 0
Color_6.Position = UDim2.new(0, 0, 0.622501612, 0)
Color_6.Size = UDim2.new(0, 199, 0, 37)
Color_6.Font = Enum.Font.Cartoon
Color_6.Text = "Dark red"
Color_6.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_6.TextSize = 35
Color_6.TextWrapped = true
Color_6.TextXAlignment = Enum.TextXAlignment.Left

Color_5.Name = "Color_5"
Color_5.Parent = ScrollingFrame
Color_5.BackgroundColor3 = Color3.new(1, 1, 1)
Color_5.BackgroundTransparency = 1
Color_5.BorderSizePixel = 0
Color_5.Position = UDim2.new(0, 0, 0.870561481, 0)
Color_5.Size = UDim2.new(0, 199, 0, 37)
Color_5.Font = Enum.Font.Cartoon
Color_5.Text = "Hot pink"
Color_5.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_5.TextSize = 35
Color_5.TextWrapped = true
Color_5.TextXAlignment = Enum.TextXAlignment.Left

Color_4.Name = "Color_4"
Color_4.Parent = ScrollingFrame
Color_4.BackgroundColor3 = Color3.new(1, 1, 1)
Color_4.BackgroundTransparency = 1
Color_4.BorderSizePixel = 0
Color_4.Position = UDim2.new(0, 0, 0.685786903, 0)
Color_4.Size = UDim2.new(0, 199, 0, 37)
Color_4.Font = Enum.Font.Cartoon
Color_4.Text = "Rust"
Color_4.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_4.TextSize = 35
Color_4.TextWrapped = true
Color_4.TextXAlignment = Enum.TextXAlignment.Left

Color_3.Name = "Color_3"
Color_3.Parent = ScrollingFrame
Color_3.BackgroundColor3 = Color3.new(1, 1, 1)
Color_3.BackgroundTransparency = 1
Color_3.BorderSizePixel = 0
Color_3.Position = UDim2.new(0, 0, 0.808969975, 0)
Color_3.Size = UDim2.new(0, 199, 0, 37)
Color_3.Font = Enum.Font.Cartoon
Color_3.Text = "Really black"
Color_3.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_3.TextSize = 35
Color_3.TextWrapped = true
Color_3.TextXAlignment = Enum.TextXAlignment.Left

Color_2.Name = "Color_2"
Color_2.Parent = ScrollingFrame
Color_2.BackgroundColor3 = Color3.new(1, 1, 1)
Color_2.BackgroundTransparency = 1
Color_2.BorderSizePixel = 0
Color_2.Position = UDim2.new(0, 0, 0.310848475, 0)
Color_2.Size = UDim2.new(0, 199, 0, 37)
Color_2.Font = Enum.Font.Cartoon
Color_2.Text = "Lemon metalic"
Color_2.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_2.TextSize = 35
Color_2.TextWrapped = true
Color_2.TextXAlignment = Enum.TextXAlignment.Left

local Sound_1 = Instance.new("Sound")
 
Sound_1.Name = "Sound"
Sound_1.SoundId = "rbxassetid://408524543"
Sound_1.Volume = 2
Sound_1.archivable = false
Sound_1.Parent = game:GetService("Workspace")

function Sound1()
    Sound_1:play()
end

local Sound_2 = Instance.new("Sound")
 
Sound_2.Name = "Song1"
Sound_2.SoundId = "rbxassetid://452267918"
Sound_2.Volume = 2
Sound_2.archivable = false
Sound_2.Parent = game:GetService("Workspace")

function Sound2()
    Sound_2:play()
end

local UIGradient = Instance.new("UIGradient", Main)
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(0, 0.4, 1)),
    ColorSequenceKeypoint.new(1, Color3.new(0.54902, 0, 1))
})

local Colors = { Color_1, Color_2, Color_3, Color_4, Color_5, Color_6, Color_7, Color_8, Color_9, Color_10, Color_11, Color_12, Color_13, Color_14, Color_15}

for i, v in pairs(Colors) do
    v.MouseEnter:connect(function() 
        Sound1()
    end)
    v.MouseButton1Down:connect(function()
        Sound2()
        CurColor.Text = " Color: " .. v.Text .. " "
    end)
end

local Tool = Instance.new("Tool", game:GetService("Players").LocalPlayer.Backpack)
Tool.Name = "Car Color Tool"
Tool.RequiresHandle = false
Tool.CanBeDropped = false
Tool.Unequipped:Connect(function()
    Main.Visible = false
end)

local C = nil
local FP = nil

game:GetService("Workspace").PlayerModels.ChildAdded:connect(function(v) v:WaitForChild("Owner")
    if v:WaitForChild("PaintParts") then
        FP = v.PaintParts.Part
    end
end)

local function Press(Button)
    game.ReplicatedStorage.Interaction.RemoteProxy:FireServer(Button)
end

local Car = nil

Tool.Equipped:Connect(function(Mouse)
    Main.Visible = true
    Mouse.Button1Down:connect(function()
        if Mouse.Target and Mouse.Target.Parent.Type and Mouse.Target.Parent.Type.Value == "Vehicle Spot" then
            Car = Mouse.Target.Parent:FindFirstChild("ButtonRemote_SpawnButton", true)
             Vehicle.Text = " Vehicle: " .. Mouse.Target.Parent.ItemName.Value .. " "
        end
    end)
end)

Execute.MouseEnter:connect(function() 
    Sound1()
end)

Execute.MouseButton1Down:connect(function()
    if CurColor.Text ~= " Color: Not Selected " and Car ~= nil then
        Sound2()
        repeat
            Press(Car)
            repeat wait(0.05) until FP ~= C
            C = FP
        until FP.BrickColor.Name == string.sub(CurColor.Text, 9, #CurColor.Text - 1) or FP.BrickColor.Name == "Hot pink"
    end
end)
   end,
})
-- 海贼果实
local tabBloxFruits = Window:CreateTab("blox fruits")
createButton(tabBloxFruits, "RedZ Hub", "https://raw.githubusercontent.com/LuaCrack/Min/refs/heads/main/MinXt2Eng")
createButton(tabBloxFruits, "Quantum Onyx Project", "https://raw.githubusercontent.com/FlazhGG/QTONYX/refs/heads/main/NextGeneration.lua")
createButton(tabBloxFruits, "Zee Hub VIP", "https://scripts.alchemyhub.xyz")
createButton(tabBloxFruits, "Teddy Hub", "https://raw.githubusercontent.com/Teddyseetink/Haidepzai/refs/heads/main/TeddyHub.lua")
createButton(tabBloxFruits, "Raito Hub", "https://raw.githubusercontent.com/Efe0626/RaitoHub/main/Script")
createButton(tabBloxFruits, "Mobile Update 21 Hub", "https://raw.githubusercontent.com/U-ziii/Blox-Fruits/refs/heads/main/SeaEvents.lua")
createButton(tabBloxFruits, "Update 24 OP Loader", "https://api.luarmor.net/files/v3/loaders/3b2169cf53bc6104dabe8e19562e5cc2.lua")
createButton(tabBloxFruits, "Maris Free Hub", "https://raw.githubusercontent.com/U-ziii/Blox-Fruits/refs/heads/main/DFFruit.lua")
createButton(tabBloxFruits, "Adel Top Hub", "https://raw.githubusercontent.com/AdelOnTheTop/Adel-Hub/main/Main.lua")
createButton(tabBloxFruits, "Mukuro All-In-One", "https://raw.githubusercontent.com/xDepressionx/Free-Script/main/AllScript.lua")

-- 宠物模拟器99
local tabPetSim99 = Window:CreateTab("宠物模拟器99")
createButton(tabPetSim99, "Auto Buy Inf Gem Auto Farm", "https://raw.githubusercontent.com/RJ077SIUU/PS99/main/Gems")
createButton(tabPetSim99, "Dupe Script", "https://rentry.co/nb8rcubw/raw")
createButton(tabPetSim99, "Auto Farm & Infinite Boosts", "https://zaphub.xyz/Exec")
createButton(tabPetSim99, "Auto Finish Obby Minigames", "https://rentry.co/vn96engx/raw")
createButton(tabPetSim99, "Auto Collect Drops & Flags", "https://raw.githubusercontent.com/ahmadsgamer2/Zekrom-Hub-X/main/Zekrom-Hub-X-exe")
createButton(tabPetSim99, "Pastebin 2026 Script 6", "https://rentry.co/2uh559tp/raw")
createButton(tabPetSim99, "Pastebin 2026 Script 7", "https://rentry.co/rf7y3gva/raw")
createButton(tabPetSim99, "Pastebin 2026 Script 8", "https://rentry.co/somwxbqr/raw")
createButton(tabPetSim99, "Pastebin 2026 Script 9", "https://rentry.co/tuc9cqdx/raw")

-- 耳光大战
local tabSlapBattles = Window:CreateTab("打屁股战斗")
createButton(tabSlapBattles, "Pastebin 2026 Script 1", "https://raw.githubusercontent.com/rblxscriptsnet/unfair/main/rblxhub.lua")
createButton(tabSlapBattles, "Pastebin 2026 Script 2", "https://raw.githubusercontent.com/Giangplay/Slap_Battles/main/Slap_Battles.lua")
createButton(tabSlapBattles, "Pastebin 2026 Script 3", "https://raw.githubusercontent.com/Bilmemi/bestaura/main/semihu803")
createButton(tabSlapBattles, "Pastebin 2026 Script 4", "https://raw.githubusercontent.com/dizyhvh/slap_battles_gui/main/0.lua")
createCodeButton(tabSlapBattles, "自动杀人(近战)", [[
function isSpawned(player)
   if workspace:FindFirstChild(player.Name) and player.Character:FindFirstChild("HumanoidRootPart") then
       return true
   else
       return false
   end
end
while wait() do
   for i, v in pairs(game.Players:GetPlayers()) do
       if isSpawned(v) and v ~= game.Players.LocalPlayer and not v.Character.Head:FindFirstChild("UnoReverseCard") then
           if (v.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 50 then
               game:GetService("ReplicatedStorage").b:FireServer(v.Character["Right Arm"])
               wait(0.1)
           end
       end
   end
end
]])

-- 起床战争
local tabBedWars = Window:CreateTab("BedWars")
createButton(tabBedWars, "Auto Click & Kill Aura", "https://gist.githubusercontent.com/DeveloperMikey/2b8ee3d5a38c56c2cc1db72554850384/raw/bedwar.lua")
createButton(tabBedWars, "Infinite Jump Fly & Sprint", "https://raw.githubusercontent.com/GamerScripter/Game-Hub/main/loader")
createButton(tabBedWars, "VapeV4 GUI", "https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua")
createButton(tabBedWars, "Crokuranu UI", "https://raw.githubusercontent.com/SlaveDash/Crokuranu/main/Bedwars%20UI%20Source%20Code")
createButton(tabBedWars, "Monkey Script", "https://raw.githubusercontent.com/KuriWasTaken/MonkeyScripts/main/BedWarsMonkey.lua")

-- 谋杀之谜2
local tabMM2 = Window:CreateTab("破坏者联盟2")
createButton(tabMM2, "Eclipse Hub", "https://raw.githubusercontent.com/Doggo-cryto/EclipseMM2/master/Script")
createButton(tabMM2, "Silent Aim & Kill All", "https://rentry.co/xzdu8wnm/raw")
createButton(tabMM2, "Rogue Hub", "https://raw.githubusercontent.com/Kitzoon/Rogue-Hub/main/Main.lua")
createButton(tabMM2, "Aimbot Script", "https://rentry.co/hb89aoq2/raw")
createButton(tabMM2, "Alchemy Hub", "https://luable.netlify.app/AlchemyHub/Luncher.script")
createButton(tabMM2, "Auto Farm MM2 Mobile", "https://raw.githubusercontent.com/NoCapital2/MM2Autofarm/main/script")
createButton(tabMM2, "Auto Farm & Coin Farm", "https://raw.githubusercontent.com/KidichiHB/Kidachi/main/Scripts/MM2")
createButton(tabMM2, "Auto Farm & ESP (New)", "https://raw.githubusercontent.com/luaScriptsRoblox/MM2_AutoFarm/main/Script")
createButton(tabMM2, "Silent Aim v2", "https://pastebin.com/raw/mm2SilentAimV2")

-- 军械库
local tabArsenal = Window:CreateTab("兵工厂")
createButton(tabArsenal, "Tbao Hub Arsenal", "https://raw.githubusercontent.com/tbao143/thaibao/main/TbaoHubArsenal")
createButton(tabArsenal, "Owl Hub", "https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt")
createButton(tabArsenal, "Script 3", "https://raw.githubusercontent.com/cris123452/my/main/cas")
createButton(tabArsenal, "Quotas Hub", "https://raw.githubusercontent.com/Insertl/QuotasHub/main/BETAv1.3")
createButton(tabArsenal, "Strike Hub", "https://raw.githubusercontent.com/ccxmIcal/cracks/main/strikehub.lua")
createButton(tabArsenal, "V.G-Hub", "https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub")

-- 神道生活
local tabShindo = Window:CreateTab("忍者生命2")
createButton(tabShindo, "Project Nexus", "https://raw.githubusercontent.com/IkkyyDF/ProjectNexus/main/Loader.lua")
createButton(tabShindo, "Premier X", "https://raw.githubusercontent.com/SxnwDev/Premier/main/Free-Premier.lua")
createButton(tabShindo, "V.G-Hub", "https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub")
createButton(tabShindo, "SpyHub", "https://raw.githubusercontent.com/Corrupt2625/Revamps/main/SpyHub.lua")
createButton(tabShindo, "Slash Hub", "https://hub.wh1teslash.xyz/")
createButton(tabShindo, "Imp Hub", "https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua")
createButton(tabShindo, "Solix Hub", "https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua")
createButton(tabShindo, "Solaris Hub", "https://solarishub.net/script.lua")

-- 收养我
local tabAdoptMe = Window:CreateTab("收养我")
createButton(tabAdoptMe, "Auto Farm Auto Quest Auto Neon", "https://raw.githubusercontent.com/L1ghtScripts/AdoptmeScript/main/AdoptmeScript/JJR1655-adopt-me.lua")
createButton(tabAdoptMe, "Pet Farming Script", "https://raw.githubusercontent.com/Cospog-Scripts/shnigelutils/main/mainLoader.lua")
createButton(tabAdoptMe, "Auto Farm & Auto Neon", "https://gitfront.io/r/ReQiuYTPL/wFUydaK74uGx/hub/raw/ReQiuYTPLHub.lua")
createButton(tabAdoptMe, "Auto Quest & Auto Heal", "https://raw.githubusercontent.com/billieroblox/jimmer/main/77_HAJ07IP.lua")
createButton(tabAdoptMe, "Auto Buy & Walkspeed", "https://raw.githubusercontent.com/concordeware/sncware/main/sncware")
createButton(tabAdoptMe, "Get All Pets", "https://raw.githubusercontent.com/lf4d7/daphie/main/ame.lua")
createButton(tabAdoptMe, "Pastebin 2026 Script 8", "https://raw.githubusercontent.com/Ultra-Scripts/AdoptmeScript/main/AdoptmeScript/JI5PMVG-adopt-me.lua")

-- 布鲁克海文RP
local tabBrookhaven = Window:CreateTab("布鲁克海文RP")
createButton(tabBrookhaven, "Speed Hack Noclip Auto Farm", "https://raw.githubusercontent.com/riotrapdo-spec/KeySystems/refs/heads/main/Loader.lua")
createButton(tabBrookhaven, "Khosh Script", "https://raw.githubusercontent.com/kllooep/Fjjzxda6/refs/heads/main/KhoshScript.txt")
createButton(tabBrookhaven, "Sarturn Hub", "https://raw.githubusercontent.com/fhrdimybds-byte/Sarturn-hub-BrookhavenRP-/refs/heads/main/main.lua")
createButton(tabBrookhaven, "JOAO HUB", "https://raw.githubusercontent.com/UgiX1/JOAOHUB/refs/heads/main/JOAOHUB.txt")
createButton(tabBrookhaven, "Pastebin 2026 Script 5", "https://ghostbin.axel.org/paste/opp4o/raw")

-- 费什
local tabFisch = Window:CreateTab("Fisch")
createButton(tabFisch, "Venox Universal Scripts", "https://raw.githubusercontent.com/venoxcc/universalscripts/refs/heads/main/fisch")
createButton(tabFisch, "Farming GUI", "https://api.luarmor.net/files/v3/loaders/cba17b913ee63c7bfdbb9301e2d87c8b.lua")
createButton(tabFisch, "Banana Hub", "https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua")
createButton(tabFisch, "Lunor Loader", "https://raw.githubusercontent.com/Just3itx/Lunor-Loadstrings/refs/heads/main/Loader")
createButton(tabFisch, "Solix Auto Shake", "https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua")
createButton(tabFisch, "Mobile Script Y-HUB", "https://raw.githubusercontent.com/Luarmor123/community-Y-HUB/refs/heads/main/Fisch-YHUB")
createButton(tabFisch, "Loader 2529a5f9", "https://api.luarmor.net/files/v3/loaders/2529a5f9dfddd5523ca4e22f21cceffa.lua")
createButton(tabFisch, "Loader 0bbab1d5", "https://api.luarmor.net/files/v3/loaders/0bbab1d51c52f509c1b7c219c86d4d83.lua")

-- 刀锋球
local tabBladeBall = Window:CreateTab("Blade Ball")
createButton(tabBladeBall, "Speed X BladeBall", "https://raw.githubusercontent.com/FriezGG/Scripts/main/Speed%20X%20BladeBall")
createButton(tabBladeBall, "Auto Farm & Auto Walk", "https://pi-hub.pages.dev/protected/loader.lua")
createButton(tabBladeBall, "R3TH PRIV Loader", "https://raw.githubusercontent.com/R3TH-PRIV/R3THPRIV/main/loader.lua")
createButton(tabBladeBall, "Auto Parry Mobile", "https://scriptblox.com/raw/UPD-Blade-Ball-op-autoparry-with-visualizer-8652")
createButton(tabBladeBall, "Close Combat Script", "https://raw.githubusercontent.com/kidshop4/scriptbladeballk/main/bladeball.lua")
createButton(tabBladeBall, "Neon.C Hub X", "https://raw.githubusercontent.com/Neoncat765/Neon.C-Hub-X/main/UnknownVersion")
createButton(tabBladeBall, "Auto Clicker Mobile", "https://raw.githubusercontent.com/GrandmasterOfLife123/lua/main/releasedbladeball.lua")
createButton(tabBladeBall, "FPS Booster", "https://raw.githubusercontent.com/Fsploit/venox-blade-ball-v1/main/K-A-T-S-U-S-F-S-P-L-O-I-T-I-S-A-F-U-R-R-Y%20MAIN%20V4")
createButton(tabBladeBall, "No Key Auto Parry", "https://raw.githubusercontent.com/luascriptsROBLOX/BladeBallXera/main/XeraUltron")
createButton(tabBladeBall, "Wings Hub", "https://wings.ac/loader")
createButton(tabBladeBall, "OPULENCE Hub", "https://api.luarmor.net/files/v3/loaders/987304be42d04f975daf2efce8130d7a.lua")
createButton(tabBladeBall, "Nexus Hub", "https://api.junkie-development.de/api/v1/luascripts/public/c458c939651a0abd1aa5898726665597ab7ed51952b694f518f43333f85628ec/download")
createButton(tabBladeBall, "Skin Changer & Auto Parry", "https://api.getpolsec.com/scripts/0aeb2ed63d72925a96c7987887163935.txt")
createButton(tabBladeBall, "UNION Hub", "https://pastebin.com/raw/XJ8bRWyg")
createButton(tabBladeBall, "Mobile Full ESP", "https://raw.githubusercontent.com/luwriy/jwhub/refs/heads/main/loader")
createButton(tabBladeBall, "Soluna Script", "https://raw.githubusercontent.com/Patheticcs/Soluna-API/refs/heads/main/bladeball.lua")
createButton(tabBladeBall, "Trevous Hub", "https://raw.githubusercontent.com/ImNotRox1/Trevous-Hub/refs/heads/main/blade-ball.lua")
createButton(tabBladeBall, "r4mpage Hub (No Key)", "https://raw.githubusercontent.com/r4mpage4/LuaCom/refs/heads/main/saint.noob")
-- 最强战场
local tabTSB = Window:CreateTab("最坚强的战场")
createButton(tabTSB, "Auto Farm Players Anti Stun", "https://pastefy.app/1emcuiFz/raw")
createButton(tabTSB, "Auto Farm Invisible & Fling", "https://raw.githubusercontent.com/LOLking123456/Saitama111/main/battle121")
createButton(tabTSB, "Aimbot Auto Punch Auto Skill", "https://raw.githubusercontent.com/sandwichk/RobloxScripts/main/Scripts/BadWare/Hub/Load.lua")
createButton(tabTSB, "Infinite Jump & Fly", "https://pastefy.app/v9VSOfM5/raw")
createButton(tabTSB, "Anti Stun & Extra Range", "https://raw.githubusercontent.com/TheHanki/Hawk/main/Loader")
createButton(tabTSB, "Auto Parry", "https://raw.githubusercontent.com/SkibidiCen/MainMenu/main/Code")
createButton(tabTSB, "Mobile Script", "https://raw.githubusercontent.com/tamarixr/tamhub/main/bettertamhub.lua")
createButton(tabTSB, "Saitama Battlegrounds", "https://nicuse.xyz/SaitamaBattlegrounds.lua")
createButton(tabTSB, "Gr* Hub OP", "https://rawscripts.net/raw/The-Strongest-Battlegrounds-Gr*y-Hub-OP-112611")
createButton(tabTSB, "Auto Farm & Anti Stun (GUI)", "https://pastefy.app/1emcuiFz/raw")
createButton(tabTSB, "TSB Aimbot & Auto Skill", "https://raw.githubusercontent.com/sandwichk/RobloxScripts/main/Scripts/BadWare/Hub/Load.lua")
createButton(tabTSB, "TSB Mobile Script", "https://raw.githubusercontent.com/tamarixr/tamhub/main/bettertamhub.lua")
createButton(tabTSB, "TSB Best GUI Script", "https://raw.githubusercontent.com/zeuise0002/SSSWWW222/main/README.md")
-- 宿敌
local tabRivals = Window:CreateTab("竞争对手")
createButton(tabRivals, "Silent Rivals", "https://raw.githubusercontent.com/KxGOATESQUE/SilentRivals/main/SilentRivals")
createButton(tabRivals, "Aimbot & Visuals", "https://raw.githubusercontent.com/PUSCRIPTS/PINGUIN/refs/heads/main/RivalsV1")
createButton(tabRivals, "Rapid Fire Spinbot & ESP", "https://raw.githubusercontent.com/laeraz/ventures/refs/heads/main/rivals.lua")
createButton(tabRivals, "Triggerbot & Skin Changer", "https://dev-8-bit.pantheonsite.io/scripts/?script=rivalsv3.lua")
createButton(tabRivals, "Auto Farm & Auto Fire", "https://api.luarmor.net/files/v3/loaders/212c1198a1beacf31150a8cf339ba288.lua")
createButton(tabRivals, "Mobile Script", "https://raw.githubusercontent.com/MinimalScriptingService/MinimalRivals/main/rivals.lua")
createButton(tabRivals, "Pi Hub Loader", "https://pi-hub.pages.dev/protected/loader.lua")
createButton(tabRivals, "Tbao Hub Rivals", "https://raw.githubusercontent.com/tbao143/thaibao/main/TbaoHubRivals")
createButton(tabRivals, "Midnight CC", "https://raw.githubusercontent.com/laeraz/midnightcc/main/public.lua")

-- 能力之战
local tabAbilityWars = Window:CreateTab("能力之战")
createButton(tabAbilityWars, "Anti-Aura Anti KnockBack", "https://raw.githubusercontent.com/Sw1ndlerScripts/RobloxScripts/main/AbilityWars.lua")
createButton(tabAbilityWars, "Auto Farm & ESP", "https://raw.githubusercontent.com/castycheat/abilitywars/main/Protected%20(29).lua")
createButton(tabAbilityWars, "Stand Attack Time Reset", "https://gameovers.net/Scripts/Free/Ability%20Wars/stando.lua")
createButton(tabAbilityWars, "Pastebin 2026 Script 4", "https://raw.githubusercontent.com/dizyhvh/rbx_scripts/main/ability_wars.lua")
createButton(tabAbilityWars, "Pastebin 2026 Script 5", "https://raw.githubusercontent.com/Testerhubplayer/Ability-wars/main/Ability_wars.lua")

-- 死亡铁轨
local tabDeadRails = Window:CreateTab("死铁轨")
TX = "TX Script"
Script = "TX自动刷债券V4"
createButton(tabDeadRails, "Auto Bond Auto Win", "https://rawscripts.net/raw/Dead-Rails-Beta-Auto-Bond-Auto-Win-117096")
createButton(tabDeadRails, "刷债券V4", "https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Auto-Bond-V4")

-- 突破点
local tabBreakingPoint = Window:CreateTab("突破点")
createButton(tabBreakingPoint, "Funny Squid Hax", "https://raw.githubusercontent.com/ColdStep2/Breaking-Point-Funny-Squid-Hax/main/Breaking%20Point%20Funny%20Squid%20Hax")
createButton(tabBreakingPoint, "Infinite Credits", "https://raw.githubusercontent.com/IsaaaKK/bp/main/script")
createButton(tabBreakingPoint, "Silent Aim Rapid Throw", "https://raw.githubusercontent.com/1iseo/breaking-point-public/main/main.lua")

-- 自然灾害生存
local tabNDS = Window:CreateTab("自然灾害生存模拟器")
createButton(tabNDS, "Auto Farm God Mode Teleport", "https://raw.githubusercontent.com/73GG/Game-Scripts/main/Natural%20Disaster%20Survival.lua")
createButton(tabNDS, "Auto Farm & Free Balloon", "https://raw.githubusercontent.com/2dgeneralspam1/scripts-and-stuff/master/scripts/LoadstringUjHI6RQpz2o8")
createButton(tabNDS, "Anti-Fall & Anti-Weather", "https://raw.githubusercontent.com/pcallskeleton/RX/refs/heads/main/5.lua")
createButton(tabNDS, "No Fall Damage Anti-Water", "https://raw.githubusercontent.com/H17S32/Tiger_Admin/main/MAIN")
createButton(tabNDS, "Auto Clicker Auto Rebirth", "https://raw.githubusercontent.com/ToraIsMe/ToraIsMe/main/0GrimaceRace")
createButton(tabNDS, "Walkspeed & Gravity", "https://raw.githubusercontent.com/RobloxHackingProject/CHHub/main/CHHub.lua")
createButton(tabNDS, "Teleport to Spawn Map", "https://raw.githubusercontent.com/OneProtocol/Project/main/Loader")
createButton(tabNDS, "Mobile Script", "https://raw.githubusercontent.com/Bac0nh1ck/Scripts/main/NDS_A%5EX")
createButton(tabNDS, "Pastebin 2026 Script 9", "https://raw.githubusercontent.com/9NLK7/93qjoadnlaknwldk/main/main")
createButton(tabNDS, "全员变菜鸟", "https://rawscripts.net/raw/Natural-Disaster-Survival-noob-all-110242")

local tabbrainrot = Window:CreateTab("逃离海啸获得脑红")
createButton(tabbrainrot, "海啸无敌", "https://pastebin.com/raw/Ai5WqH8N")
createButton(tabbrainrot, "kdml hub海啸无敌", "https://raw.githubusercontent.com/kedd063/KdmlScripts/refs/heads/main/EscapeTsunamiForBrainrotsV4")
createButton(tabbrainrot, "Vinzhub海啸无敌", "https://script.vinzhub.com/loader")

-- 疯狂城市
local tabMadCity = Window:CreateTab("疯狂之城")
createButton(tabMadCity, "Ruby Hub", "https://raw.githubusercontent.com/aymarko/deni210/main/MadCity/RubyHub")
createButton(tabMadCity, "Auto Escape & Instant Interact", "https://raw.githubusercontent.com/ProBaconHub/ProBaconGUI/main/Script")
createButton(tabMadCity, "Auto Rob & Money Farm", "https://raw.githubusercontent.com/Cesare0328/my-scripts/main/MCARCH2.lua")
createButton(tabMadCity, "Auto Arrest & Teleport", "https://raw.githubusercontent.com/Deni210/madcity/main/Ruby%20Hub%20v1.1")
createButton(tabMadCity, "Pastebin 2026 Script 6", "https://pastes.io/raw/msc-65172")
createButton(tabMadCity, "Ruby Hub v1", "https://raw.githubusercontent.com/Deni210/madcity/main/Ruby%20Hub")
createButton(tabMadCity, "Auto Arrest & Rob", "https://raw.githubusercontent.com/MadCityScripts/madcity/main/auto_arrest_rob.lua")
createButton(tabMadCity, "Infinite Money Farm", "https://rentry.co/madcity_money_farm/raw")
createButton(tabMadCity, "Teleport to Best Heist", "https://raw.githubusercontent.com/MadCityHub/madcity/main/teleport_heist.lua")
createButton(tabMadCity, "Auto Farm All", "https://api.luarmor.net/files/v3/loaders/madcity_auto_farm.lua")
createButton(tabMadCity, "Kill Aura & ESP", "https://raw.githubusercontent.com/MadCityScripts/madcity/main/kill_aura_esp.lua")
-- 犯罪生涯
local tabCriminality = Window:CreateTab("犯罪")
createButton(tabCriminality, "Starlightcc Leaked", "https://raw.githubusercontent.com/eradicator2/starlight-criminality/refs/heads/main/source.lua")
createButton(tabCriminality, "Cinality Script", "https://api.junkie-development.de/api/v1/luascripts/public/facbd46e4ae1e8ae608a9a7251682698bfc57ebd39d041d641ad84e483ce017f/download")
createButton(tabCriminality, "Silent Aim Script", "https://api.jnkie.com/api/v1/luascripts/public/1a000c187ed683ea2548d58eea33f6017ab5aa5ca12dec1f53df795ebc088163/download")
createButton(tabCriminality, "Auro Hub", "https://raw.githubusercontent.com/denzisdat/auro-criminality/main/auro-v1.lua")
createButton(tabCriminality, "Trix Hub (No Key)", "https://raw.githubusercontent.com/TrixAde/criminality/main/TrixHub.lua")
createButton(tabCriminality, "Esp Hub Criminality", "https://api.luarmor.net/files/v3/loaders/criminality_esp_hub.lua")
createButton(tabCriminality, "Silent Aim & Aimbot", "https://rentry.co/criminality_silent_aim/raw")
createButton(tabCriminality, "Auto Rob & Kill All", "https://raw.githubusercontent.com/CriminalityScripts/criminality/main/auto_rob.lua")
-- 咒术师攀登
local tabSorcerer = Window:CreateTab("咒师登顶")
createButton(tabSorcerer, "OP KEYLESS Script", "https://rawscripts.net/raw/RELEASE-Sorcerer-Ascent-SCRIPT-OP-KEYLESS-103228")

-- 大屠杀
local tabMassacre = Window:CreateTab("屠杀者")
createButton(tabMassacre, "BEST SCRIPT MARCH 2026", "https://rawscripts.net/raw/UPD-Massacre-BEST-SCRIPT-MARCH-2026-136108")

-- 崛起交叉
local tabArise = Window:CreateTab("ARISE")
createButton(tabArise, "Speed Hub X", "https://raw.githubusercontent.com/U-ziii/Arise-Crossover/refs/heads/main/MultiFeatureScript.lua")
createButton(tabArise, "Frosties Script", "https://raw.githubusercontent.com/U-ziii/Arise-Crossover/refs/heads/main/ShadowAutomation.lua")
createButton(tabArise, "Auto Dungeon & Mount Farm", "https://raw.githubusercontent.com/U-ziii/Arise-Crossover/refs/heads/main/AutoDungeon.lua")
createButton(tabArise, "Keyless Script", "https://raw.githubusercontent.com/U-ziii/Arise-Crossover/refs/heads/main/KeylessScript.lua")

-- 蓝色监狱
local tabBlueLock = Window:CreateTab("蓝色锁:对手")
createButton(tabBlueLock, "Luarmor Loader", "https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua")
createButton(tabBlueLock, "XZuyaX Hub", "https://raw.githubusercontent.com/XZuuyaX/XZuyaX-s-Hub/refs/heads/main/Main.Lua")
createButton(tabBlueLock, "Aimbot Hub", "https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua")
createButton(tabBlueLock, "Fly Script", "https://raw.githubusercontent.com/Iliankytb/Iliankytb/main/BLRFlyingBall")
createButton(tabBlueLock, "Pastefy Script", "https://pastefy.app/wRGyxNnn/raw")
createButton(tabBlueLock, "Script 6", "https://raw.githubusercontent.com/EnesKam21/bluelock/refs/heads/main/obfuscated%20(2).lua")
createButton(tabBlueLock, "CONTROL BALL Script", "https://rawscripts.net/raw/UPD-Blue-Lock:-Rivals-CONTROL-BALL-32455")
createButton(tabBlueLock, "CONTROL Script (GitHub)", "https://raw.githubusercontent.com/RedJDark/CONTROL-SCRIPTT/refs/heads/main/CONTROL")
-- 森林中的99夜
local tab99Nights = Window:CreateTab("森林中的99夜")
createButton(tab99Nights, "XA脚本", "https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Games/森林中的99夜.lua")
createButton(tab99Nights, "VEX脚本", "https://raw.githubusercontent.com/yoursvexyyy/VEX-OP/refs/heads/main/99%20nights%20in%20the%20forest")
createButton(tab99Nights, "Voidware全能", "https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/nightsintheforest.lua")
createButton(tab99Nights, "刷糖果", "https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FarmCandyFN.lua")
createButton(tab99Nights, "刷钻石", "https://raw.githubusercontent.com/r4mpage4/LuaCom/refs/heads/main/saint.noob")
createButton(tab99Nights, "虚空脚本汉化", "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/99%E5%A4%9C%E8%99%9A%E7%A9%BA.txt")
createButton(tab99Nights, "H4xLoader", "https://raw.githubusercontent.com/H4xScripts/Loader/refs/heads/main/loader.lua")
createButton(tab99Nights, "OP级汉化", "https://raw.githubusercontent.com/hdjsjjdgrhj/script-hub/refs/heads/main/99Nights")
createButton(tab99Nights, "Brone翻译", "https://raw.githubusercontent.com/q639977310-design/-/refs/heads/main/99%E5%A4%9C")
createButton(tab99Nights, "OverHub刷钻石", "https://raw.githubusercontent.com/hellattexyss/autofarmdiamonds/main/overhubaurofarm.lua")

-- 墨水游戏
local tabInk = Window:CreateTab("墨水游戏")
createButton(tabInk, "Voidware", "https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/inkgame.lua")
createButton(tabInk, "Du8汉化", "https://raw.githubusercontent.com/XOTRXONY/INKGAME/main/INKGAMEE.lua")
createButton(tabInk, "XA脚本", "https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Games/墨水游戏.lua")
createButton(tabInk, "Ringta汉化", "https://raw.githubusercontent.com/hdjsjjdgrhj/script-hub/refs/heads/main/Ringta")
createButton(tabInk, "TexRBLlX汉化", "https://raw.githubusercontent.com/hdjsjjdgrhj/script-hub/refs/heads/main/TexRBLlX")
createButton(tabInk, "修复版汉化", "https://raw.githubusercontent.com/hdjsjjdgrhj/OK/refs/heads/main/sb")
createButton(tabInk, "免费会员", "https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/windinkgame.lua")
createButton(tabInk, "AX最新版", "https://officialaxscripts.vercel.app/scripts/AX-Loader.lua")
createButton(tabInk, "AX汉化版", "https://raw.githubusercontent.com/hdjsjjdgrhj/script-hub/refs/heads/main/AX%20CN")
createButton(tabInk, "防踢加载器", "https://raw.githubusercontent.com/S-WTB/-/refs/heads/main/WTB%E5%8A%A0%E8%BD%BD%E5%99%A8")
createButton(tabInk, "早川秋汉化", "https://raw.githubusercontent.com/MTHNBBN666/ZCQNB/refs/heads/main/obfuscated_script-1758110200696.lua")

-- 俄亥俄州
local tabOhio = Window:CreateTab("俄亥俄州")
createButton(tabOhio, "Visurus", "https://scripts.visurus.dev/ohio/source")
createButton(tabOhio, "XA脚本", "https://raw.githubusercontent.com/XingFork/Scripts/refs/heads/main/Ohio")
createButton(tabOhio, "Pastebin脚本", "https://pastebin.com/raw/hkvHeHed")
createButton(tabOhio, "VoidX Hub (无密钥)", "https://raw.githubusercontent.com/coldena/voidhuba/refs/heads/main/voidhubload")
createButton(tabOhio, "Illicit Hub (无密钥)", "https://gist.githubusercontent.com/iltmita/bae56642c39cbaab2e9acdf5cf909585/raw")
createButton(tabOhio, "Sunexn Hub (自动农场)", "https://raw.githubusercontent.com/sunexn/ohio./main/ohio.lua")
createButton(tabOhio, "rxn-xyz 脚本", "https://raw.githubusercontent.com/rxn-xyz/Ohio./main/Ohio.lua")
createButton(tabOhio, "AlphaOhio", "https://raw.githubusercontent.com/scriptpastebin/raw/main/AlphaOhio")
createButton(tabOhio, "Pastebin 2026", "https://pastebin.com/raw/GUmp28kq")
-- SCP角色扮演
local tabSCP = Window:CreateTab("SCP角色扮演")
createButton(tabSCP, "NullZen", "https://raw.githubusercontent.com/axleoislost/NullZen/main/Scp-Roleplay")
createButton(tabSCP, "VoidPath", "https://raw.githubusercontent.com/voidpathhub/VoidPath/refs/heads/main/VoidPath.luau")
createButton(tabSCP, "Magnesium", "https://raw.githubusercontent.com/Bodzio21/Magnesium/refs/heads/main/Loader")
createButton(tabSCP, "M416", "https://raw.githubusercontent.com/xiaoSB33/M416/refs/heads/main/Wind/sb/SCP角色扮演")

-- 河北唐县
local tabTang = Window:CreateTab("河北唐县")
createButton(tabTang, "自动农场", "https://raw.githubusercontent.com/Sw1ndlerScripts/RobloxScripts/main/Tang%20Country.lua")

-- 活到七天
local tab7Days = Window:CreateTab("活到七天")
createButton(tab7Days, "自动脚本", "https://raw.githubusercontent.com/zamzamzan/test/refs/heads/main/7days")

-- 被遗弃
local tabAbandoned = Window:CreateTab("被遗弃")
createButton(tabAbandoned, "陈某汉化", "https://raw.githubusercontent.com/qazwsx422/Je/26ab7022f3767d471f2fbb3d67e0683f0c13a55a/%E8%A2%AB%E9%81%97%E5%BC%83")

-- 通用脚本
local tabDoors = Window:CreateTab("Doors")
createButton(tabDoors, "Vynixius菜单", "https://raw.githubusercontent.com/RegularVynixu/Vynixius/main/Doors/Script.lua")

local tab3008 = Window:CreateTab("SCP-3008")
createButton(tab3008, "Antex脚本", "https://raw.githubusercontent.com/Viserromero/Antex/master/SCP3008")

-- 51区
local tabArea51 = Window:CreateTab("51区")
createButton(tabArea51, "STK菜单v7", "https://raw.githubusercontent.com/Ghostmode65/STK-Bo2/master/STK-Menus/v7/STv7-Engine.txt")

local tabDontPress = Window:CreateTab("不要按第4按But")
createButton(tabDontPress, "EEWE脚本", "https://raw.githubusercontent.com/imaboy12321/EEWE/main/eweweew")

-- 彩虹朋友
local tabRainbow = Window:CreateTab("彩虹朋友")
createButton(tabRainbow, "BorkWare", "https://raw.githubusercontent.com/Ihaveash0rtnamefordiscord/BorkWare/main/Scripts/" .. game.GameId .. ".lua")

-- 点击模拟器
local tabClick = Window:CreateTab("点击模拟器")
createButton(tabClick, "Kederal脚本", "https://raw.githubusercontent.com/Kederal/script.gg/main/loader.lua")

-- 动感星期五
local tabFunky = Window:CreateTab("动感星期五")
createButton(tabFunky, "自动演奏", "https://raw.githubusercontent.com/wally-rblx/funky-friday-autoplay/main/main.lua")

-- 动物模拟器
local tabAnimal = Window:CreateTab("动物模拟器")
createButton(tabAnimal, "牛逼脚本", "\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\112\101\116\105\116\101\98\97\114\116\101\47\109\101\110\117\47\109\97\105\110\47\77\101\110\117")

-- 极速传奇
local tabSpeed = Window:CreateTab("极速传奇")
createButton(tabSpeed, "无限经验", "https://pastebin.com/raw/9KWQXasx")

-- 僵尸起义/进击的僵尸
local tabZombie = Window:CreateTab("僵尸起义")
createButton(tabZombie, "xSyon引擎", "https://raw.githubusercontent.com/xSyon/ZombieAttack/main/engine.lua")
createButton(tabZombie, "Darkrai X", "https://raw.githubusercontent.com/GamingScripter/Darkrai-X/main/Games/Zombie%20Attack")

-- 捐赠游戏 Pls Donate
local tabDonate = Window:CreateTab("请捐赠")
createButton(tabDonate, "自动农场", "https://raw.githubusercontent.com/heqds/Pls-Donate-Auto-Farm-Script/main/plsdonate.lua")

-- 克隆大亨
local tabClone = Window:CreateTab("克隆大亨")
createButton(tabClone, "CT-Destroyer", "https://raw.githubusercontent.com/HELLLO1073/RobloxStuff/main/CT-Destroyer")

-- 汽车经营大亨
local tabCar = Window:CreateTab("Car Dealership Tycoon")
createButton(tabCar, "BlueLock脚本", "https://raw.githubusercontent.com/03sAlt/BlueLockSeason2/main/README.md")
createButton(tabCar, "03koios Auto Farm", "'https://raw.githubusercontent.com/03koios/Loader/main/Loader.lua'")
createButton(tabCar, "ScriptBlox Auto Farm", "'https://scriptblox.com/raw/LIMITED!-Car-Dealership-Tycoon-Update-script-9099'")
createButton(tabCar, "UltimateHub Auto Farm", "'https://raw.githubusercontent.com/IExpIoit/Script/main/UltimateHub'")
-- YBA (Your Bizarre Adventure)
local tabYBA = Window:CreateTab("你的怪异冒险")
createButton(tabYBA, "NukeVsCity脚本", "https://raw.githubusercontent.com/NukeVsCity/hackscript123/main/gui")

-- The Rake
local tabRake = Window:CreateTab("割草机")
createButton(tabRake, "jFn0k6Gz脚本", "https://pastebin.com/raw/jFn0k6Gz")

-- RIU (Roblox Is Unbreakable)
local tabRIU = Window:CreateTab("Roblox是坚不可摧的")
createButton(tabRIU, "无限等级+钱", "https://raw.githubusercontent.com/MorikTV/Roblox-is-Unbreakable/main/Unbreakable.lua")

-- Nico's Nextbots
local tabNico = Window:CreateTab("Nico的下一个机器人")
createButton(tabNico, "aBPrm1vk脚本", "\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\97\66\80\114\109\49\118\107")

local tabLuckyBlock = Window:CreateTab("幸运方块")
createButton(tabLuckyBlock, "Auto Special Collect", "https://pastebin.com/raw/0xzxLuckyBlock")

-- 54. Booga Booga
local tabBooga = Window:CreateTab("Booga Booga")
createButton(tabBooga, "Nebula Hub", "https://raw.githubusercontent.com/Yousuck780/Nebula-Hub/refs/heads/main/boogaboogareborn")
createButton(tabBooga, "Aimbot Hub", "https://api.luarmor.net/files/v4/loaders/3e1fa137895b569a24c95af2bd79b5d8.lua")
createButton(tabBooga, "LuminaProject", "https://raw.githubusercontent.com/LuminaProject/Boooga-Booga/refs/heads/main/main.lua")
createButton(tabBooga, "SunSetV1", "https://raw.githubusercontent.com/Fominkal/NeverHook-2.0/refs/heads/main/SunSetV1_BoogaBooga")

-- 55. Don't Wake the Brainrots
local tabBrainrotslol = Window:CreateTab("别叫醒脑袋!")
createButton(tabBrainrotslol, "Auto Collect Money", "https://raw.githubusercontent.com/gumanba/Scripts/main/DontWaketheBrainrots")
createButton(tabBrainrotslol, "Teleport Brainrot", "https://raw.githubusercontent.com/VylikGylik/Script/refs/heads/main/Don't%20Wake%20the%20Brainrots")
createButton(tabBrainrotslol, "Free Admin Panel", "https://cdn.authguard.org/virtual-file/96959c041820452fb07cbdd94754dcd7")
createButton(tabBrainrotslol, "Auto Safe Place", "https://raw.githubusercontent.com/tls123account/StarStream/refs/heads/main/Hub")
createButton(tabBrainrotslol, "StarStream Hub", "https://raw.githubusercontent.com/starstreamowner/StarStream/refs/heads/main/Hub")
createButton(tabBrainrotslol, "Pastefy Script", "https://pastefy.app/7zBptI7A/raw")
createButton(tabBrainrotslol, "Karbid Script", "https://raw.githubusercontent.com/karbid-dev/Karbid/main/zpp0kogh0t")

-- 56. Survive Bikini Bottom
local tabBikini = Window:CreateTab("生存比基尼底裤")
createButton(tabBikini, "Morning Hub", "https://raw.githubusercontent.com/U-ziii/Survive-Bikini-Bottom/refs/heads/main/Teleports.lua")
createButton(tabBikini, "Instant Open Chests", "https://raw.githubusercontent.com/U-ziii/Survive-Bikini-Bottom/refs/heads/main/FastRewardsScript.lua")
createButton(tabBikini, "Auto Kill & Craft", "https://raw.githubusercontent.com/U-ziii/Survive-Bikini-Bottom/refs/heads/main/AutoKill.lua")
createButton(tabBikini, "SpiderHUB Beta", "https://raw.githubusercontent.com/U-ziii/Survive-Bikini-Bottom/refs/heads/main/SmoothESP.lua")
createButton(tabBikini, "Sponge Hub", "https://raw.githubusercontent.com/U-ziii/Survive-Bikini-Bottom/refs/heads/main/NoKey.lua")

-- 57. Color or Die
local tabColorDie = Window:CreateTab("颜色或死亡")
createButton(tabColorDie, "41kstacks", "https://raw.githubusercontent.com/SkibidiCen/MainMenu/main/Code")
createButton(tabColorDie, "Vex Hub", "https://raw.githubusercontent.com/VexHubOfficial/VexHub-GAMES/refs/heads/main/Color%20or%20Die")
createButton(tabColorDie, "EmberHub", "https://raw.githubusercontent.com/scripter66/EmberHub/refs/heads/main/ColorOrDie.lua")
local tabDrawMe = Window:CreateTab("画我")
createButton(tabDrawMe, "Kenny脚本", "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/KENNY画我.lua")

-- Jailbreak（越狱）
local tabJailbreak = Window:CreateTab("越狱")
createButton(tabJailbreak, "Auto Rob & Arrest", "https://raw.githubusercontent.com/MarsQQ/ScriptHubScripts/main/JailbreakAutoRob.lua")
createButton(tabJailbreak, "Silent Aim & ESP", "https://pastebin.com/raw/jAimESPJailbreak")
createButton(tabJailbreak, "Infinite Money Farm", "https://raw.githubusercontent.com/XeonDev/Jailbreak/main/MoneyFarm.lua")
createButton(tabJailbreak, "Teleport to Jewels", "https://rentry.co/jailteleport/raw")
createButton(tabJailbreak, "AutoRob V6", "'http://scripts.projectauto.xyz/AutoRobV6'")
createButton(tabJailbreak, "Auto Farm & ESP", "'https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/Jailbreak.lua'")
createButton(tabJailbreak, "Auto Arrest & Rob", "'https://raw.githubusercontent.com/MarsQQ/ScriptHubScripts/main/JailbreakAutoRob.lua'")
-- Tower Defense Simulator（塔防模拟器）
local tabTDS = Window:CreateTab("塔防模拟器")
createButton(tabTDS, "Auto Farm & Place", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/TDS.lua")
createButton(tabTDS, "Infinite Money & XP", "https://pastebin.com/raw/tdsAutoMoney")
createButton(tabTDS, "Unlock All Towers", "https://raw.githubusercontent.com/ScriptersCF/TDS/main/UnlockTowers.lua")
createButton(tabTDS, "Auto Skip Wave", "https://rentry.co/tdsSkipWave/raw")

-- Pet Simulator X（宠物模拟器X）
local tabPetSimX = Window:CreateTab("宠物模拟器X")
createButton(tabPetSimX, "Auto Hatch & Farm", "https://raw.githubusercontent.com/Exunys/Pet-Simulator-X/main/Script.lua")
createButton(tabPetSimX, "Dupe Pets (Patched?)", "https://pastebin.com/raw/psxDupeExploit")
createButton(tabPetSimX, "Auto Collect Coins", "https://rentry.co/psxAutoFarm/raw")
createButton(tabPetSimX, "Infinite Enchant", "https://raw.githubusercontent.com/NeoniteScripts/PSX/main/Enchant.lua")

-- Da Hood（达胡德）
local tabDaHood = Window:CreateTab("Da Hood")
createButton(tabDaHood, "Aimbot & Silent Aim", "https://raw.githubusercontent.com/Exunys/Da-Hood/main/Aimbot.lua")
createButton(tabDaHood, "Auto Farm & Auto Rob", "https://pastebin.com/raw/dahoodAutoRob")
createButton(tabDaHood, "Fly & Walkspeed", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/DaHood.lua")
createButton(tabDaHood, "ESP & Visuals", "https://rentry.co/dahoodESP/raw")

-- Ragdoll Engine（布娃娃引擎）
local tabRagdoll = Window:CreateTab("布娃娃引擎")
createButton(tabRagdoll, "God Mode & Fly", "https://raw.githubusercontent.com/RegularVynixu/Vynixius/main/RagdollEngine.lua")
createButton(tabRagdoll, "Auto Win & Explode All", "https://pastebin.com/raw/ragdollAutoWin")
createButton(tabRagdoll, "Fling Players", "https://raw.githubusercontent.com/HubScripts/Ragdoll/main/Fling.lua")

-- Evade（躲避）
local tabEvade = Window:CreateTab("Evade")
createButton(tabEvade, "Auto Dodge & ESP", "https://raw.githubusercontent.com/Exunys/Evade/main/Script.lua")
createButton(tabEvade, "Infinite Stamina", "https://pastebin.com/raw/evadeStamina")
createButton(tabEvade, "Teleport to Safe Zone", "https://rentry.co/evadeTeleport/raw")

-- Big Paintball（大彩蛋射击）
local tabPaintball = Window:CreateTab("大彩蛋射击")
createButton(tabPaintball, "Aimbot & Silent Aim", "https://raw.githubusercontent.com/HubScripts/BigPaintball/main/Aimbot.lua")
createButton(tabPaintball, "Auto Kill & ESP", "https://pastebin.com/raw/bpAutoKill")
createButton(tabPaintball, "Unlock All Guns", "https://raw.githubusercontent.com/ScriptersCF/Paintball/main/UnlockGuns.lua")

-- Build A Boat For Treasure（造船寻宝）
local tabBABFT = Window:CreateTab("造船寻宝")
createButton(tabBABFT, "Auto Build & Farm", "https://raw.githubusercontent.com/RegularVynixu/Vynixius/main/BABFT.lua")
createButton(tabBABFT, "Dupe Items", "https://pastebin.com/raw/babftDupe")
createButton(tabBABFT, "Fly & Noclip", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/BABFT.lua")

-- Legends of Speed（速度传奇）
local tabSpeedLegends = Window:CreateTab("速度传奇")
createButton(tabSpeedLegends, "Auto Run & Rebirth", "https://raw.githubusercontent.com/Exunys/Legends-of-Speed/main/Script.lua")
createButton(tabSpeedLegends, "Infinite Gems", "https://pastebin.com/raw/losGems")
createButton(tabSpeedLegends, "Unlock All Trails", "https://rentry.co/losUnlock/raw")

-- Weight Lifting Simulator（举重模拟器）
local tabWeight = Window:CreateTab("举重模拟器")
createButton(tabWeight, "Auto Lift & Rebirth", "https://raw.githubusercontent.com/HubScripts/WeightLifting/main/AutoFarm.lua")
createButton(tabWeight, "Infinite Strength", "https://pastebin.com/raw/weightStrength")
createButton(tabWeight, "Teleport to Best Gym", "https://raw.githubusercontent.com/RegularVynixu/Vynixius/main/WeightLifting.lua")

-- Zombie Strike（僵尸打击）
local tabZombieStrike = Window:CreateTab("僵尸打击")
createButton(tabZombieStrike, "Auto Farm & Aimbot", "https://raw.githubusercontent.com/Exunys/Zombie-Strike/main/Script.lua")
createButton(tabZombieStrike, "Infinite Ammo", "https://pastebin.com/raw/zsAmmo")
createButton(tabZombieStrike, "God Mode", "https://rentry.co/zsGodmode/raw")

-- 宠物捕手
local tabPetCatchers = Window:CreateTab("宠物捕手")
createButton(tabPetCatchers, "Auto Farm & Pet Collector", "https://pastebin.com/raw/iUiaBfsi")
createButton(tabPetCatchers, "Universal Hub", "https://raw.githubusercontent.com/OhhMyGehlee/Universal/main/NSHUB")
createButton(tabPetCatchers, "Nexus Hub", "https://raw.githubusercontent.com/CrazyHub123/NexusHubMain/main/Main.lua")
createButton(tabPetCatchers, "Gato Hub", "https://raw.githubusercontent.com/Catto-YFCN/GatoHub/main/PetCatchers")
createButton(tabPetCatchers, "InfinityWare", "https://raw.githubusercontent.com/OutDatedUser/scripthub/main/Script/InfinityWare")
createButton(tabPetCatchers, "Krzysztof Hub", "https://raw.githubusercontent.com/KrzysztofHub/script/main/loader.lua")
createButton(tabPetCatchers, "Nousigi Loader", "https://nousigi.com/loader.lua")

-- 摇摆障碍赛
local tabSwingObby = Window:CreateTab("摇摆障碍赛")
createButton(tabSwingObby, "Auto Farm (Pastebin)", "https://pastebin.com/raw/xBQzRQGg")
createButton(tabSwingObby, "Keyless Loader", "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/loader.lua")
createButton(tabSwingObby, "Rockside Script", "https://vss.pandadevelopment.net/virtual/file/2228fb5d1c164373")
createButton(tabSwingObby, "NeoX Hub", "https://raw.githubusercontent.com/hassanxzayn-lua/NEOXHUBMAIN/refs/heads/main/loader")
createButton(tabSwingObby, "Astra Loader", "https://getastra.lol/loader.lua")
createButton(tabSwingObby, "Auto Mythic", "https://raw.githubusercontent.com/wendigo5414-cmyk/promotedscripts/main/swingobbyforbrainrots")
createButton(tabSwingObby, "Teleport Script", "https://raw.githubusercontent.com/CrepScripts/All-Scripts/refs/heads/main/Swing%20Brainrot")
createButton(tabSwingObby, "Luarmor Loader", "https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua")
createButton(tabSwingObby, "Pastebin v9", "https://pastebin.com/raw/jG642962")

-- 拳击模拟器
local tabPunchSim = Window:CreateTab("拳击模拟器")
createButton(tabPunchSim, "Auto Punch & Rebirth", "https://pastebin.com/raw/punchSimAutoFarm")
createButton(tabPunchSim, "Infinite Strength", "https://raw.githubusercontent.com/HubScripts/PunchSim/main/Strength.lua")
createButton(tabPunchSim, "Teleport to Best Area", "https://rentry.co/punchSimTeleport/raw")

-- 海盗时代
local tabPirate = Window:CreateTab("海盗时代")
createButton(tabPirate, "Auto Farm & Auto Quest", "https://pastebin.com/raw/pirateAgeAutoFarm")
createButton(tabPirate, "Infinite Beli", "https://raw.githubusercontent.com/ScriptersCF/PirateAge/main/Beli.lua")
createButton(tabPirate, "Unlock All Fruits", "https://rentry.co/pirateAgeFruits/raw")

-- 忍者传奇
local tabNinja = Window:CreateTab("忍者传奇")
createButton(tabNinja, "Auto Train & Rebirth", "https://pastebin.com/raw/ninjaLegendsAutoTrain")
createButton(tabNinja, "Infinite Chi", "https://raw.githubusercontent.com/HubScripts/NinjaLegends/main/Chi.lua")
createButton(tabNinja, "Unlock All Skills", "https://rentry.co/ninjaSkills/raw")

-- 超市大亨
local tabSupermarket = Window:CreateTab("超市大亨")
createButton(tabSupermarket, "Auto Restock & Sell", "https://pastebin.com/raw/supermarketAutoRestock")
createButton(tabSupermarket, "Infinite Money", "https://raw.githubusercontent.com/ScriptersCF/Supermarket/main/Money.lua")
createButton(tabSupermarket, "Unlock All Upgrades", "https://rentry.co/supermarketUpgrades/raw")

-- 矿工天堂
local tabMiner = Window:CreateTab("矿工天堂")
createButton(tabMiner, "Auto Mine & Sell", "https://pastebin.com/raw/minerHavenAutoMine")
createButton(tabMiner, "Infinite Gems", "https://raw.githubusercontent.com/HubScripts/MinerHaven/main/Gems.lua")
createButton(tabMiner, "Teleport to Best Ore", "https://rentry.co/minerTeleport/raw")

-- 餐厅大亨
local tabRestaurant = Window:CreateTab("餐厅大亨 2")
createButton(tabRestaurant, "Auto Cook & Serve", "https://pastebin.com/raw/restaurantAutoCook")
createButton(tabRestaurant, "Infinite Cash", "https://raw.githubusercontent.com/ScriptersCF/Restaurant/main/Cash.lua")
createButton(tabRestaurant, "Unlock All Recipes", "https://rentry.co/restaurantRecipes/raw")

-- 动物园大亨
local tabZoo = Window:CreateTab("动物园大亨")
createButton(tabZoo, "Auto Feed & Collect", "https://pastebin.com/raw/zooTycoonAutoFeed")
createButton(tabZoo, "Infinite Coins", "https://raw.githubusercontent.com/HubScripts/ZooTycoon/main/Coins.lua")
createButton(tabZoo, "Unlock All Animals", "https://rentry.co/zooAnimals/raw")

-- 农场大亨
local tabFarm = Window:CreateTab("农场大亨")
createButton(tabFarm, "Auto Plant & Harvest", "https://pastebin.com/raw/farmTycoonAutoPlant")
createButton(tabFarm, "Infinite Money", "https://raw.githubusercontent.com/ScriptersCF/FarmTycoon/main/Money.lua")
createButton(tabFarm, "Unlock All Crops", "https://rentry.co/farmCrops/raw")

-- 医院大亨
local tabHospital = Window:CreateTab("医院大亨")
createButton(tabHospital, "Auto Heal & Collect", "https://pastebin.com/raw/hospitalAutoHeal")
createButton(tabHospital, "Infinite Cash", "https://raw.githubusercontent.com/HubScripts/HospitalTycoon/main/Cash.lua")
createButton(tabHospital, "Unlock All Rooms", "https://rentry.co/hospitalRooms/raw")

-- 学校大亨
local tabSchool = Window:CreateTab("学校大亨")
createButton(tabSchool, "Auto Study & Graduate", "https://pastebin.com/raw/schoolTycoonAutoStudy")
createButton(tabSchool, "Infinite Points", "https://raw.githubusercontent.com/ScriptersCF/SchoolTycoon/main/Points.lua")
createButton(tabSchool, "Unlock All Classes", "https://rentry.co/schoolClasses/raw")

-- 水上乐园大亨
local tabWaterPark = Window:CreateTab("水上乐园大亨")
createButton(tabWaterPark, "Auto Build & Collect", "https://pastebin.com/raw/waterparkAutoBuild")
createButton(tabWaterPark, "Infinite Money", "https://raw.githubusercontent.com/HubScripts/WaterPark/main/Money.lua")
createButton(tabWaterPark, "Unlock All Slides", "https://rentry.co/waterparkSlides/raw")

-- 主题公园大亨
local tabThemePark = Window:CreateTab("主题公园大亨")
createButton(tabThemePark, "Auto Build & Ride", "https://pastebin.com/raw/themeParkAutoBuild")
createButton(tabThemePark, "Infinite Tickets", "https://raw.githubusercontent.com/ScriptersCF/ThemePark/main/Tickets.lua")
createButton(tabThemePark, "Unlock All Rides", "https://rentry.co/themeParkRides/raw")

-- 航天大亨
local tabSpace = Window:CreateTab("航天大亨")
createButton(tabSpace, "Auto Mine & Launch", "https://pastebin.com/raw/spaceTycoonAutoMine")
createButton(tabSpace, "Infinite Fuel", "https://raw.githubusercontent.com/HubScripts/SpaceTycoon/main/Fuel.lua")
createButton(tabSpace, "Unlock All Planets", "https://rentry.co/spacePlanets/raw")

-- 军事大亨
local tabMilitary = Window:CreateTab("军事大亨")
createButton(tabMilitary, "Auto Train & Deploy", "https://pastebin.com/raw/militaryAutoTrain")
createButton(tabMilitary, "Infinite Funds", "https://raw.githubusercontent.com/ScriptersCF/MilitaryTycoon/main/Funds.lua")
createButton(tabMilitary, "Unlock All Units", "https://rentry.co/militaryUnits/raw")

-- 恐龙大亨
local tabDino = Window:CreateTab("恐龙大亨")
createButton(tabDino, "Auto Hatch & Feed", "https://pastebin.com/raw/dinoTycoonAutoHatch")
createButton(tabDino, "Infinite DNA", "https://raw.githubusercontent.com/HubScripts/DinoTycoon/main/DNA.lua")
createButton(tabDino, "Unlock All Dinos", "https://rentry.co/dinoDinos/raw")

-- 海岛大亨
local tabIsland = Window:CreateTab("海岛大亨")
createButton(tabIsland, "Auto Gather & Build", "https://pastebin.com/raw/islandAutoGather")
createButton(tabIsland, "Infinite Resources", "https://raw.githubusercontent.com/ScriptersCF/IslandTycoon/main/Resources.lua")
createButton(tabIsland, "Unlock All Islands", "https://rentry.co/islandIslands/raw")

-- ==================== Restaurant Tycoon 3（餐厅大亨3） ====================
local tabRestaurantTycoon3 = Window:CreateTab("餐厅大亨3")
createButton(tabRestaurantTycoon3, "Auto Farm (Luarmor)", "https://api.luarmor.net/files/v4/loaders/d7be76c234d46ce6770101fded39760c.lua")
createButton(tabRestaurantTycoon3, "Zylo Hub", "https://raw.githubusercontent.com/pr0methaxine/Zylo-Hub/refs/heads/main/Loader.lua")
createButton(tabRestaurantTycoon3, "Keyless Hub", "https://rawscripts.net/raw/Restaurant-Tycoon-3-Resteraunt-Tycoon-3-53797")

-- ==================== Hooked!（钓鱼模拟器） ====================
local tabHooked = Window:CreateTab("Hooked! 钓鱼模拟器")
createButton(tabHooked, "Auto Farm / ESP / Speed", "https://vss.pandadevelopment.net/virtual/file/2228fb5d1c164373")
createButton(tabHooked, "Cerberus Free Loader", "https://www.getcerberus.com/free-loader.lua")
createButton(tabHooked, "Luarmor Loader", "https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua")
createButton(tabHooked, "ESP Script", "https://raw.githubusercontent.com/kjefeer/kjefeer/refs/heads/main/loader.luau")

-- ==================== Split The Sea（劈开大海） ====================
local tabSplitSea = Window:CreateTab("Split The Sea")
createButton(tabSplitSea, "Dubu Hub", "https://raw.githubusercontent.com/AintDubu/DubuHub/refs/heads/main/Dubuhub.lua")
createButton(tabSplitSea, "Loot Split AutoFarm", "https://raw.githubusercontent.com/StitchAloha/Scripts/refs/heads/main/Split%20The%20Sea")

-- ==================== Crawl for Brainrot!（脑腐爬行） ====================
local tabCrawlBrainrot = Window:CreateTab("Crawl for Brainrot!")
createButton(tabCrawlBrainrot, "Hub v1 (Auto Rebirth)", "https://gist.githubusercontent.com/GattoHow/28f82f4c10775fab81ff1b7838f77fef/raw/")
createButton(tabCrawlBrainrot, "KhSaeed90 Utility", "https://raw.githubusercontent.com/KhSaeed90/Roblox/refs/heads/workspace/71249794780202")

-- ==================== Cursed Blade[ALPHA]（诅咒之刃） ====================
local tabCursedBlade = Window:CreateTab("Cursed Blade [ALPHA]")
createButton(tabCursedBlade, "Zynex Auto Farm", "https://pastebin.com/raw/V7ZQRigM")
createButton(tabCursedBlade, "Aeonic Hib", "https://pastefy.app/W5SQspeD/raw")

-- ==================== Realistic Street Soccer（真实街头足球） ====================
local tabStreetSoccer = Window:CreateTab("真实街头足球")
createButton(tabStreetSoccer, "No Key Loader", "http://34.88.99.102:16160/loader.luau")
createButton(tabStreetSoccer, "Auto Diver", "https://api.jnkie.com/api/v1/luascripts/public/3e2c3e3e0b0d7f7fd17b5cab1dc7cfd95266b38e3f4ce1d55cee269ba27a9ba5/download")
createButton(tabStreetSoccer, "Nutmeg Chip", "https://raw.githubusercontent.com/WainwrightEnliven/Realistic-Street-Soccer/main/Realistic-Street-Soccer.lua")

-- ==================== War Tycoon（战争大亨） ====================
local tabWarTycoon = Window:CreateTab("War Tycoon")
createButton(tabWarTycoon, "Auto Farm & Aimbot", "https://robloxdatabase.com/script/war-tycoon-script/")

-- ==================== King Legacy（海贼王传奇） ====================
local tabKingLegacy = Window:CreateTab("King Legacy")
createButton(tabKingLegacy, "ArcHub Auto Farm", "https://raw.githubusercontent.com/ArcHubScripts/KingLegacy/main/Loader.lua")


-- ==================== Anime Crusaders（动漫十字军） ====================
local tabAnimeCrusaders = Window:CreateTab("Anime Crusaders")
createButton(tabAnimeCrusaders, "Goomba Hub", "https://raw.githubusercontent.com/JustLevel/goombahub/main/goombahub.lua")
createButton(tabAnimeCrusaders, "Auto Farm & Crates", "https://pastebin.com/raw/iJ3Ruvi2")
createButton(tabAnimeCrusaders, "PC & Mobile", "https://pastebin.com/raw/Y0P0fbTt")
createButton(tabAnimeCrusaders, "No Key GUI", "https://raw.githubusercontent.com/gumanba/Scripts/refs/heads/main/AnimeSaga")
createButton(tabAnimeCrusaders, "GUI Auto Farm", "https://raw.githubusercontent.com/OhhMyGehlee/ga/refs/heads/main/ga")

-- 手臂摔跤模拟器 (Arm Wrestle Simulator) - 全新游戏
local tabArmWrestle = Window:CreateTab("手臂摔跤模拟器")
createButton(tabArmWrestle, "Auto Farm & Auto Hatch", "https://raw.githubusercontent.com/InfinityMercury/Scripts/main/ArmWrestleSimulator/loader.lua")
createButton(tabArmWrestle, "Auto Click & Auto Fight", "https://raw.githubusercontent.com/Odrexyo/Script/main/Loader.lua")
createButton(tabArmWrestle, "Nebula Hub (Auto Farm)", "https://raw.githubusercontent.com/Saitamahaah/SaitaHub/main/NebulaHub")
createButton(tabArmWrestle, "Stat Tracker & Webhook", "https://api.luarmor.net/files/v3/loaders/99d16edc79729a038994f85ce7335971.lua")
createButton(tabArmWrestle, "Auto Farm & Auto Rebirth", "https://raw.githubusercontent.com/Kenniel123/Arm-Wrestle-Simulator-Script/main/Arm-Wrestle-Simulator-Script")
createButton(tabArmWrestle, "Auto Hatch Event Eggs", "https://raw.githubusercontent.com/Tankz3502/ProjectTesla/main/wercT.lua")
createButton(tabArmWrestle, "Pastebin 2026 Script", "https://raw.githubusercontent.com/1Toxin/screech/main/AWS")

-- 鲨鱼咬经典 (SharkBite Classic) - 全新脚本
local tabSharkBite = Window:CreateTab("鲨鱼咬经典")
createButton(tabSharkBite, "Auto Farm & Infinite Tooth", "https://raw.githubusercontent.com/LOOF-sys/Roblox-Shit/main/SharkBite.lua")
createButton(tabSharkBite, "Kill Sharks & Kill Survives", "https://raw.githubusercontent.com/alphaalt0409/WEIRDAPPLEBEEPANEL/main/weirdapplebee.lua")

-- 建造飞机 (Build A Plane) - 全新游戏
local tabBuildPlane = Window:CreateTab("Build A Plane")
createButton(tabBuildPlane, "Blueprint Craft Script", "https://raw.githubusercontent.com/leveehipporoute/Build-A-Plane/main/Build-A-Plane.lua")
createButton(tabBuildPlane, "Script Blueprint (Raw)", "https://rawscripts.net/raw/Build-A-Plane-Script-Blueprint-Wing-Propeller-Craft-*embly-155168")

-- 史莱克在后室 (Shrek in The Backrooms) - 恐怖游戏
local tabShrekBackrooms = Window:CreateTab("史莱克在后室")
createButton(tabShrekBackrooms, "Auto Search Lockers & ESP", "https://raw.githubusercontent.com/danielontopp/huge/main/Shrek%20in%20the%20backrooms")
createButton(tabShrekBackrooms, "Loot Stuff Script", "https://garfieldscripts.xyz/scripts/shrek-backroom.lua")
createButton(tabShrekBackrooms, "LK Hub Loader", "https://lkhub.net/s/loader.lua")
createButton(tabShrekBackrooms, "Rentry Script", "https://rentry.co/v96regvh/raw")

-- 藏或死 (Hide or Die!) - 恐怖游戏
local tabHideOrDie = Window:CreateTab("藏或死")
createButton(tabHideOrDie, "Easy Win Silent Aim", "https://raw.githubusercontent.com/danangori/Hide-or-Die/refs/heads/main/2026-08")
createButton(tabHideOrDie, "Rockside Silent Aim", "https://vss.pandadevelopment.net/virtual/file/2228fb5d1c164373")
createButton(tabHideOrDie, "Conceal Cupboard Script", "https://raw.githubusercontent.com/WellTrucker11/Hide-or-Die/main/Hide-or-Die.lua")

-- 红田小学 (Redfield Elementary) - 恐怖游戏
local tabRedfield = Window:CreateTab("红田小学")
createButton(tabRedfield, "Auto Escape & God Mode", "https://raw.githubusercontent.com/axleoislost/Accent/main/Rivals")
createButton(tabRedfield, "Solix Hub (Teleport & ESP)", "https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/main/solix%20new%20keyui.lua")
createButton(tabRedfield, "Infinite Stamina & ESP", "https://raw.githubusercontent.com/VisioneducationOfLuaCoding/Ambrion/refs/heads/main/RivalsVersion3")
createButton(tabRedfield, "Soluna Hub (God Mode)", "https://soluna-script.vercel.app/main.lua")
createButton(tabRedfield, "Dark Hub (ESP & Teleport)", "https://raw.githubusercontent.com/25Dark25/Scripts/refs/heads/main/key-script")
createButton(tabRedfield, "Fast Run & Auto Escape", "https://raw.githubusercontent.com/4lpaca-pin/Arceney/refs/heads/main/main.luau")

-- 夜间撕咬 (Bite By Night) - 恐怖游戏
local tabBiteByNight = Window:CreateTab("夜间撕咬")
createButton(tabBiteByNight, "ZynixHub (No Key ESP)", "https://zynixscripts.net/raw/bite-by-night-esp")
createButton(tabBiteByNight, "Msploit Hub (Godmode)", "https://github.com/MicLing-7877/Msploit/raw/main/load/Msploit?raw=true")
createButton(tabBiteByNight, "AirFlow Hub (Auto Win)", "https://airflowscript.com/loader")
createButton(tabBiteByNight, "Cerberus Hub (Killer ESP)", "https://api.luarmor.net/files/v4/loaders/48d34d4ce24020fa00c610733b7babc5.lua")
createButton(tabBiteByNight, "Essence Hub (Inf Stamina)", "https://essencesuite.onrender.com/script/loader.lua")

-- 爆炸模拟器 (Boom Simulator) - 全新游戏
local tabBoomSim = Window:CreateTab("爆炸模拟器")
createButton(tabBoomSim, "Auto Nuke & Auto Rebirth", "https://pastesio.com/raw/bss-59129")


-- 大型彩弹射击 (Big Paintball)
local tabBigPaintball = Window:CreateTab("大型彩弹射击")
createButton(tabBigPaintball, "Fazium Loader (Silent Aim/ESP)", "'https://raw.githubusercontent.com/ZaRdoOx/Fazium-files/main/Loader'")
createButton(tabBigPaintball, "Sky Hub (Silent Aim)", "'https://raw.githubusercontent.com/arlists/Sky-Hub/main/Main', true")
createButton(tabBigPaintball, "Luarmor GUI (Kill Aura)", "'https://api.luarmor.net/files/v3/loaders/f6712c9f3171c4e54f0ac695c880c258.lua'")
createButton(tabBigPaintball, "DarkyyWare (Kill All)", "'https://raw.githubusercontent.com/AndrewDarkyy/NOWAY/main/darkyyware.lua'")
createButton(tabBigPaintball, "DarkHub (God Mode)", "'https://raw.githubusercontent.com/RandomAdamYT/DarkHub/master/Init', true")

-- 拳击模拟器 (Punching Simulator)
local tabPunchingSim = Window:CreateTab("拳击模拟器")
createButton(tabPunchingSim, "Auto Punch & Open Eggs", "'https://raw.githubusercontent.com/malicious-dev/RobloxScripting/main/punchsimulator.lua'),true)()")
createButton(tabPunchingSim, "Luarmor Auto Farm", "'https://api.luarmor.net/files/v3/loaders/62ac508ae22ac9d4d5485af7a4531b0b.lua'")
createButton(tabPunchingSim, "PasteJustit Auto Farm", "'https://pastejustit.com/raw/olh5ch9rqf'")

-- 超级拳击模拟器 (Super Punch Simulator)
local tabSuperPunch = Window:CreateTab("超级拳击模拟器")
createButton(tabSuperPunch, "Pjex HUB (Auto Punch/Hatch)", "'https://raw.githubusercontent.com/R1-Common/PJex-HUB/main/PjexHUB',true")
createButton(tabSuperPunch, "OneCreatorX Auto Farm", "'https://raw.githubusercontent.com/OneCreatorX/OneCreatorX/main/Scripts/UGCfree/PunchS.lua'")

-- 拔剑 (Pull a Sword)
local tabPullSword = Window:CreateTab("拔剑")
createButton(tabPullSword, "ToraScript Auto Farm", "'https://raw.githubusercontent.com/ToraScript/Script/main/PullaSword'")
createButton(tabPullSword, "Perfectus Hub (Auto Click)", "'https://raw.githubusercontent.com/PerfectusMim/Perfectus-Hub/main/perfectus-hub'")
createButton(tabPullSword, "ToraIsMe Auto Farm Pets", "'https://raw.githubusercontent.com/ToraIsMe/ToraIsMe/main/0PullaSword'")

-- 蜜蜂群模拟器 (Bee Swarm Simulator)
local tabBeeSwarm = Window:CreateTab("蜜蜂群模拟器")
createButton(tabBeeSwarm, "XorV2 Auto Farm", "'https://raw.githubusercontent.com/XorV2/script/main/Unfair'")
createButton(tabBeeSwarm, "AltsegoD Auto Farm", "'https://raw.githubusercontent.com/AltsegoD/script/master/BeeSwarmSimulator.lua'")
createButton(tabBeeSwarm, "Kocmoc Remastered", "'https://raw.githubusercontent.com/Boxking776/kocmoc/main/kocmoc-remastered.lua'")
createButton(tabBeeSwarm, "BSS Trainer", "'https://raw.githubusercontent.com/not-weuz/Lua/main/bsstrainer.lua'")


-- 剑士模拟器 (Sword Fighters Simulator)
local tabSwordFighters = Window:CreateTab("剑士模拟器")
createButton(tabSwordFighters, "ZaqueHub Auto Swing", "'https://raw.githubusercontent.com/ZaqueHub/Sword-Fighters-Simulator/main/Sword%20Fighters%20Simulator.lua'")
createButton(tabSwordFighters, "Kae Loader Auto Farm", "'https://raw.githubusercontent.com/kae-gg/script/main/loader.lua'")
createButton(tabSwordFighters, "SpaceCat Auto Farm", "'https://raw.githubusercontent.com/SpaceCat1748/Boblox/main/SFS.lua'")
createButton(tabSwordFighters, "DumbHub Auto Farm", "'https://raw.githubusercontent.com/WHYSTRIV3/DumbHub/main/DumbHub.lua'")

-- 足球融合2 (Football Fusion )
local tabFootballFusion = Window:CreateTab("足球融合2")
createButton(tabFootballFusion, "SlimLegoHacks QB Aimbot", "'https://raw.githubusercontent.com/SlimLegoHacks/Scripts/main/FootballFusion.lua'")
createButton(tabFootballFusion, "Kirb Loader (Auto Angle)", "'https://raw.githubusercontent.com/sdhhf1245/kirb/main/loader.lua'")
createButton(tabFootballFusion, "ArgonHub V2 Loader", "'https://raw.githubusercontent.com/mcletshacks/ArgonHubV2/main/Load2/New%20Loader.lua', true")
createButton(tabFootballFusion, "BestFF2 Auto Farm", "https://raw.githubusercontent.com/LOLking123456/ff2/main/Bestff2'")

task.wait()
local elapsed = os.clock() - (_G.LoadStartTime or os.clock())
Rayfield:Notify({
    Title = "加载成功！",
    Content = "欢迎使用91缝合脚本！\n加载用时：" .. string.format("%.2f", elapsed) .. " 秒",
    Duration = 5
})
end
loadChangelog()

-- ==================== 第二步：新版主界面函数 ====================
function load()
local Plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

-- 状态变量
local States = {
    Flying = false,
    Noclip = false,
    InfJump = false,
    AutoInteract = false,
    Spinning = false,
    KillAura = false
}

local FlySpeed = 50
local SpinSpeed = 20
local SelectedPlayer = ""
local bv, bg, flyConn, noclipConn, infJumpConn
local function notify(title, content)
    Rayfield:Notify({Title = title, Content = content, Duration = 3})
end

local function createButton(tab, name, url)
    if url and url ~= "" then
        tab:CreateButton({ Name = name, Callback = function() loadstring(game:HttpGet(url))() end })
    end
end

local function createCodeButton(tab, name, code)
    if code and code ~= "" then
        tab:CreateButton({ Name = name, Callback = function()
            local success, err = pcall(function() loadstring(code)() end)
            if not success then notify("脚本错误", err) end
        end })
    end
end
local Window = Rayfield:CreateWindow({
   Name = "91混合脚本v1.1",
   LoadingTitle = "91混合脚本v1.1 | 脚本加载中",
   LoadingSubtitle = "v1.1",
   ConfigurationSaving = { Enabled = false }, -- 禁用保存功能
   Discord = { Enabled = false },            -- 禁用 Discord
   KeySystem = false                         -- 禁用密钥系统
})

----------------------------------------------------------------
-- 1. 首页
----------------------------------------------------------------
local welcometab = Window:CreateTab("首页")
welcometab:CreateLabel("欢迎使用 91混合脚本 v1.1！")
welcometab:CreateLabel("服务器功能有的可能需要卡密，有的已经失效，大部分没测试")
welcometab:CreateLabel("→脚本功能在右边→")
welcometab:CreateLabel("用户名:"..game.Players.LocalPlayer.Name)
welcometab:CreateLabel("服务器的ID:"..game.GameId)
local hubtab = Window:CreateTab("通用")
_G.FlySpeed = 50
-- 系统工具
hubtab:CreateSection("系统工具")
hubtab:CreateButton({
   Name = "重新加入",
   Callback = function() TeleportService:Teleport(game.PlaceId, Plr) end,
})
hubtab:CreateButton({
   Name = "清理内存",
   Callback = function() 
      collectgarbage("collect")
      Rayfield:Notify({Title = "系统", Content = "内存已清理", Duration = 2})
   end,
})

-- 属性修改
hubtab:CreateSection("属性修改")
hubtab:CreateSlider({
   Name = "行走速度",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) 
      if game.Players.LocalPlayer.Character then 
          game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v 
      else
          notify("行走速度", "未检测到角色，请稍后重试")
      end
   end,
})
hubtab:CreateSlider({
   Name = "跳跃高度",
   Range = {50, 500},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(v) 
      if game.Players.LocalPlayer.Character then 
          local hum = game.Players.LocalPlayer.Character.Humanoid
          hum.JumpPower = v 
          hum.UseJumpPower = true
      else
          notify("跳跃高度", "未检测到角色，请稍后重试")
      end
   end,
})
hubtab:CreateToggle({
   Name = "无限跳跃",
   CurrentValue = false,
   Callback = function(v)
      States.InfJump = v
      if v then
          if not game:GetService("UserInputService").JumpRequest then
              notify("无限跳跃", "当前游戏可能不支持跳跃请求事件")
          end
          infJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
              if States.InfJump and game.Players.LocalPlayer.Character then
                  game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
              end
          end)
      elseif infJumpConn then
          infJumpConn:Disconnect()
      end
   end,
})

-- 物理功能
hubtab:CreateSection("飞行和穿墙")
hubtab:CreateToggle({
   Name = "飞行",
   CurrentValue = false,
   Callback = function(state)
       local bodyGyro, bodyVelocity, flyConnection
       local char = Plr.Character
       if not char then notify("飞行", "角色未加载") return end
       local root = char:WaitForChild("HumanoidRootPart")
       local hum = char:WaitForChild("Humanoid")

       if state then
           hum.PlatformStand = true
           bodyGyro = Instance.new("BodyGyro", root)
           bodyGyro.P = 9e4
           bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
           bodyVelocity = Instance.new("BodyVelocity", root)
           bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)

           local speed = 0
           flyConnection = RunService.RenderStepped:Connect(function()
               if not state then return end
               local cam = workspace.CurrentCamera
               bodyGyro.CFrame = cam.CFrame
               local moveDir = hum.MoveDirection
               if moveDir.Magnitude > 0 then
                   speed = math.min(speed + 3, _G.FlySpeed)
               else
                   speed = math.max(speed - 2, 0)
               end
               local camForward = cam.CFrame.LookVector
               local camRight = cam.CFrame.RightVector
               local flatMove = moveDir.X * camRight + moveDir.Z * camForward
               bodyVelocity.velocity = flatMove * speed
           end)
           notify("飞行", "已启用")
       else
           if flyConnection then flyConnection:Disconnect() end
           if bodyGyro then bodyGyro:Destroy() end
           if bodyVelocity then bodyVelocity:Destroy() end
           hum.PlatformStand = false
           notify("飞行", "已关闭")
       end
   end,
})

hubtab:CreateSlider({
   Name = "飞行速度",
   Range = {10, 200},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(v)
       _G.FlySpeed = v
   end,
})
hubtab:CreateToggle({
   Name = "穿墙",
   CurrentValue = false,
   Callback = function(v)
      States.Noclip = v
      if v then
          noclipConn = game:GetService("RunService").Stepped:Connect(function()
              if States.Noclip and game.Players.LocalPlayer.Character then
                  for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                      if part:IsA("BasePart") then part.CanCollide = false end
                  end
              end
          end)
      elseif noclipConn then
          noclipConn:Disconnect()
      end
   end,
})

-- 战斗与互动
hubtab:CreateSection("战斗与互动")
hubtab:CreateToggle({
   Name = "自动/快速互动",
   CurrentValue = false,
   Callback = function(v)
      States.AutoInteract = v
      if v then
          -- 检测是否存在 ProximityPrompt
          local hasPrompt = false
          for _, d in pairs(workspace:GetDescendants()) do
              if d:IsA("ProximityPrompt") then
                  hasPrompt = true
                  break
              end
          end
          if not hasPrompt then
              notify("自动互动", "未检测到可交互物体，该功能可能无效")
          end
      end
      task.spawn(function()
          while States.AutoInteract do
              for _, d in pairs(workspace:GetDescendants()) do
                  if d:IsA("ProximityPrompt") then
                      d.HoldDuration = 0
                      if (game.Players.LocalPlayer.Character and (d.Parent.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 15) then
                          fireproximityprompt(d)
                      end
                  end
              end
              task.wait(0.2)
          end
      end)
   end,
})
hubtab:CreateToggle({
    Name = "无敌",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.GodModeConn = game:GetService("RunService").RenderStepped:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        -- 锁定生命值为最大值
                        hum.Health = hum.MaxHealth
                        -- 防止断肢死亡（R15/R6通用）
                        hum.BreakJointsOnDeath = false
                        -- 设置无敌状态（某些游戏依赖此属性）
                        if hum:FindFirstChild("ForceField") == nil then
                            local ff = Instance.new("ForceField")
                            ff.Visible = false  -- 隐藏护盾视觉效果
                            ff.Parent = char
                        end
                    end
                end
            end)
            notify("真正无敌", "已启用，生命值锁定，不会死亡")
        else
            if _G.GodModeConn then
                _G.GodModeConn:Disconnect()
                _G.GodModeConn = nil
            end
            -- 移除隐藏的护盾
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("ForceField") then
                char.ForceField:Destroy()
            end
            notify("真正无敌", "已关闭")
        end
    end,
})
hubtab:CreateButton({
    Name = "无敌Hook",
    Callback = function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if method == "FireServer" or method == "InvokeServer" then
                local remoteName = self.Name or ""
                local remotePath = self:GetFullName():lower()
                if remoteName:lower():match("damage") or 
                   remoteName:lower():match("hit") or 
                   remoteName:lower():match("hurt") or
                   remotePath:match("damage") or
                   remotePath:match("hit") then
                    return nil
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
        notify("Hook", "可能会出现闪退，击败特效缺失的情况，发现异常请关闭")
    end,
})
hubtab:CreateToggle({
   Name = "走路创人",
   CurrentValue = false,
   Callback = function(v)
      States.KillAura = v
      if v then
          notify("走路创人", "该功能通过修改速度实现，可能被游戏检测")
      end
      task.spawn(function()
          while States.KillAura do
              if game.Players.LocalPlayer.Character then
                  game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 5000, 0)
                  task.wait(0.1)
                  game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
              end
              task.wait(0.1)
          end
      end)
   end,
})
hubtab:CreateButton({
   Name = "甩飞所有人",
   Callback = function()
      local char = game.Players.LocalPlayer.Character
      if not char then notify("甩飞", "未检测到角色") return end
      local hrp = char.HumanoidRootPart
      local oldV = hrp.Velocity
      hrp.Velocity = Vector3.new(99999, 99999, 99999)
      task.wait(0.1)
      hrp.Velocity = oldV
   end,
})
-- 自动旋转开关
hubtab:CreateToggle({
    Name = "自动旋转",
    CurrentValue = false,
    Callback = function(v)
        States.Spinning = v
        if v then
            task.spawn(function()
                while States.Spinning do
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
                    end
                    task.wait()
                end
            end)
        end
    end,
})

-- 旋转速度调节滑块
hubtab:CreateSlider({
    Name = "旋转速度",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 20,
    Callback = function(v)
        SpinSpeed = v
    end,
})

-- 传送服务
hubtab:CreateSection("传送")
local PlayerDropdown = hubtab:CreateDropdown({
   Name = "选择目标玩家",
   Options = {}, 
   CurrentOption = "",
   Callback = function(Option) SelectedPlayer = Option end,
})
local function Refresh()
    local names = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then table.insert(names, p.Name) end
    end
    PlayerDropdown:Refresh(names, true)
end
hubtab:CreateButton({ Name = "刷新玩家列表", Callback = Refresh })
Refresh()
hubtab:CreateButton({
   Name = "传送到选中玩家",
   Callback = function()
      local target = game.Players:FindFirstChild(SelectedPlayer)
      if target and target.Character and target.Character.HumanoidRootPart then
          game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
          notify("传送", "已传送到 " .. SelectedPlayer)
      else
          notify("传送", "目标玩家不存在或未加载角色")
      end
   end,
})
hubtab:CreateButton({
    Name = "甩飞选中玩家",
    Callback = function()
        if SelectedPlayer == "" then
            notify("甩飞", "请先从下拉菜单选择一个玩家")
            return
        end
        local target = game.Players:FindFirstChild(SelectedPlayer)
        if not target then
            notify("甩飞", "目标玩家已离开")
            return
        end
        local targetChar = target.Character
        if not targetChar then
            notify("甩飞", "目标玩家尚未加载角色")
            return
        end
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            notify("甩飞", "目标角色无根部件")
            return
        end
        
        -- 甩飞实现：赋予一个随机方向的巨大速度
        local randomDir = Vector3.new(
            math.random(-100, 100),
            math.random(50, 100),   -- 向上分量保证飞起来
            math.random(-100, 100)
        ).Unit
        local flingPower = 5000
        
        -- 方法1：直接设置速度（瞬时甩飞）
        targetRoot.Velocity = randomDir * flingPower
        
        -- 方法2：如果上面无效，可以尝试用 BodyVelocity 持续甩（可选）
        -- local bv = Instance.new("BodyVelocity")
        -- bv.Velocity = randomDir * flingPower
        -- bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        -- bv.Parent = targetRoot
        -- game:GetService("Debris"):AddItem(bv, 2)  -- 2秒后自动移除
        
        notify("甩飞", SelectedPlayer .. " 已起飞！")
    end,
})
hubtab:CreateSection("其他")
hubtab:CreateButton({
   Name = "TX自动翻译",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Auto-language"))()
   end,
})
hubtab:CreateButton({
   Name = "AC6服务器放歌",
   Callback = function()
      loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-FE-Ac6-Music-Vulnerability-25536"))()
   end,
})
hubtab:CreateButton({
   Name = "TX私服生成器(会给好友发私服代码)",
   Callback = function()
      TX = "TX Script"
Script = "免费获取任何服务器私服"
loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/%E8%87%AA%E5%8A%A8%E8%8E%B7%E5%8F%96%E7%A7%81%E6%9C%8D.lua"))()
   end,
})
hubtab:CreateButton({
   Name = "改走路动作",
   Callback = function()
      local AnimationChanger = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local Close = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local TextLabel_2 = Instance.new("TextLabel")
local NormalTab = Instance.new("Frame")
local A_Astronaut = Instance.new("TextButton")
local A_Bubbly = Instance.new("TextButton")
local A_Cartoony = Instance.new("TextButton")
local A_Elder = Instance.new("TextButton")
local A_Knight = Instance.new("TextButton")
local A_Levitation = Instance.new("TextButton")
local A_Mage = Instance.new("TextButton")
local A_Ninja = Instance.new("TextButton")
local A_Pirate = Instance.new("TextButton")
local A_Robot = Instance.new("TextButton")
local A_Stylish = Instance.new("TextButton")
local A_SuperHero = Instance.new("TextButton")
local A_Toy = Instance.new("TextButton")
local A_Vampire = Instance.new("TextButton")
local A_Werewolf = Instance.new("TextButton")
local A_Zombie = Instance.new("TextButton")
local Category = Instance.new("TextLabel")
local SpecialTab = Instance.new("Frame")
local A_Patrol = Instance.new("TextButton")
local A_Confident = Instance.new("TextButton")
local A_Popstar = Instance.new("TextButton")
local A_Cowboy = Instance.new("TextButton")
local A_Ghost = Instance.new("TextButton")
local A_Sneaky = Instance.new("TextButton")
local A_Princess = Instance.new("TextButton")
local Category_2 = Instance.new("TextLabel")
local OtherTab = Instance.new("Frame")
local Category_3 = Instance.new("TextLabel")
local A_None = Instance.new("TextButton")
local A_Anthro = Instance.new("TextButton")
local Animate = game.Players.LocalPlayer.Character.Animate

AnimationChanger.Name = "AnimationChanger"
AnimationChanger.Parent = game:WaitForChild("CoreGui")
AnimationChanger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Main.Name = "Main"
Main.Parent = AnimationChanger
Main.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.421999991, 0, -1, 0)
Main.Size = UDim2.new(0, 300, 0, 250)
Main.Active = true
Main.Draggable = true

TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(0, 300, 0, 30)

Close.Name = "Close"
Close.Parent = TopBar
Close.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.899999976, 0, 0, 0)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Font = Enum.Font.SciFi
Close.Text = "x"
Close.TextColor3 = Color3.new(1, 0, 0.0156863)
Close.TextSize = 20
Close.MouseButton1Click:Connect(function()
    wait(0.3)
    Main:TweenPosition(UDim2.new(0.421999991, 0, -1.28400004, 0))
    wait(3)
    AnimationChanger:Destroy()
end)

TextLabel.Parent = TopBar
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0, 0, 0.600000024, 0)
TextLabel.Size = UDim2.new(0, 270, 0, 10)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Made by Nyser#4623"
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextSize = 15

TextLabel_2.Parent = TopBar
TextLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel_2.BackgroundTransparency = 1
TextLabel_2.BorderSizePixel = 0
TextLabel_2.Position = UDim2.new(0, 0, -0.0266667679, 0)
TextLabel_2.Size = UDim2.new(0, 270, 0, 20)
TextLabel_2.Font = Enum.Font.SourceSans
TextLabel_2.Text = "Animation Changer"
TextLabel_2.TextColor3 = Color3.new(1, 1, 1)
TextLabel_2.TextSize = 20

NormalTab.Name = "NormalTab"
NormalTab.Parent = Main
NormalTab.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
NormalTab.BackgroundTransparency = 1
NormalTab.BorderSizePixel = 0
NormalTab.Position = UDim2.new(0.5, 0, 0.119999997, 0)
NormalTab.Size = UDim2.new(0, 150, 0, 500)

A_Astronaut.Name = "A_Astronaut"
A_Astronaut.Parent = NormalTab
A_Astronaut.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Astronaut.BorderSizePixel = 0
A_Astronaut.Position = UDim2.new(0, 0, 0.815764725, 0)
A_Astronaut.Size = UDim2.new(0, 150, 0, 30)
A_Astronaut.Font = Enum.Font.SciFi
A_Astronaut.Text = "Astronaut"
A_Astronaut.TextColor3 = Color3.new(1, 1, 1)
A_Astronaut.TextSize = 20
A_Astronaut.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=891621366"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=891633237"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=891667138"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=891636393"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=891627522"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=891609353"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=891617961"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Bubbly.Name = "A_Bubbly"
A_Bubbly.Parent = NormalTab
A_Bubbly.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Bubbly.BorderSizePixel = 0
A_Bubbly.Position = UDim2.new(0, 0, 0.349019617, 0)
A_Bubbly.Size = UDim2.new(0, 150, 0, 30)
A_Bubbly.Font = Enum.Font.SciFi
A_Bubbly.Text = "Bubbly"
A_Bubbly.TextColor3 = Color3.new(1, 1, 1)
A_Bubbly.TextSize = 20
A_Bubbly.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=910004836"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=910009958"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=910034870"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=910025107"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=910016857"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=910001910"
Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=910030921"
Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=910028158"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Cartoony.Name = "A_Cartoony"
A_Cartoony.Parent = NormalTab
A_Cartoony.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Cartoony.BorderSizePixel = 0
A_Cartoony.Position = UDim2.new(0, 0, 0.407272667, 0)
A_Cartoony.Size = UDim2.new(0, 150, 0, 30)
A_Cartoony.Font = Enum.Font.SciFi
A_Cartoony.Text = "Cartoony"
A_Cartoony.TextColor3 = Color3.new(1, 1, 1)
A_Cartoony.TextSize = 20
A_Cartoony.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=742637544"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=742638445"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=742640026"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=742638842"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=742637942"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=742636889"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=742637151"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Elder.Name = "A_Elder"
A_Elder.Parent = NormalTab
A_Elder.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Elder.BorderSizePixel = 0
A_Elder.Position = UDim2.new(6.51925802e-09, 0, 0.636310041, 0)
A_Elder.Size = UDim2.new(0, 150, 0, 30)
A_Elder.Font = Enum.Font.SciFi
A_Elder.Text = "Elder"
A_Elder.TextColor3 = Color3.new(1, 1, 1)
A_Elder.TextSize = 20
A_Elder.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=845397899"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=845400520"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=845403856"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=845386501"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=845398858"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=845392038"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=845396048"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Knight.Name = "A_Knight"
A_Knight.Parent = NormalTab
A_Knight.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Knight.BorderSizePixel = 0
A_Knight.Position = UDim2.new(0, 0, 0.52352941, 0)
A_Knight.Size = UDim2.new(0, 150, 0, 30)
A_Knight.Font = Enum.Font.SciFi
A_Knight.Text = "Knight"
A_Knight.TextColor3 = Color3.new(1, 1, 1)
A_Knight.TextSize = 20
A_Knight.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=657595757"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=657568135"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=657552124"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=657564596"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=658409194"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=658360781"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=657600338"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Levitation.Name = "A_Levitation"
A_Levitation.Parent = NormalTab
A_Levitation.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Levitation.BorderSizePixel = 0
A_Levitation.Position = UDim2.new(0, 0, 0.115472436, 0)
A_Levitation.Size = UDim2.new(0, 150, 0, 30)
A_Levitation.Font = Enum.Font.SciFi
A_Levitation.Text = "Levitation"
A_Levitation.TextColor3 = Color3.new(1, 1, 1)
A_Levitation.TextSize = 20
A_Levitation.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616006778"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616008087"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616013216"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616010382"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616008936"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616003713"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616005863"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Mage.Name = "A_Mage"
A_Mage.Parent = NormalTab
A_Mage.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Mage.BorderSizePixel = 0
A_Mage.Position = UDim2.new(0, 0, 0.696203232, 0)
A_Mage.Size = UDim2.new(0, 150, 0, 30)
A_Mage.Font = Enum.Font.SciFi
A_Mage.Text = "Mage"
A_Mage.TextColor3 = Color3.new(1, 1, 1)
A_Mage.TextSize = 20
A_Mage.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=707742142"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=707855907"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=707897309"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=707861613"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=707853694"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=707826056"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=707829716"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Ninja.Name = "A_Ninja"
A_Ninja.Parent = NormalTab
A_Ninja.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Ninja.BorderSizePixel = 0
A_Ninja.Position = UDim2.new(0, 0, 0.0597896464, 0)
A_Ninja.Size = UDim2.new(0, 150, 0, 30)
A_Ninja.Font = Enum.Font.SciFi
A_Ninja.Text = "Ninja"
A_Ninja.TextColor3 = Color3.new(1, 1, 1)
A_Ninja.TextSize = 20
A_Ninja.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=656117400"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=656118341"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=656121766"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=656118852"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=656117878"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=656114359"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=656115606"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Pirate.Name = "A_Pirate"
A_Pirate.Parent = NormalTab
A_Pirate.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Pirate.BorderSizePixel = 0
A_Pirate.Position = UDim2.new(-0.000333309174, 0, 0.874588311, 0)
A_Pirate.Size = UDim2.new(0, 150, 0, 30)
A_Pirate.Font = Enum.Font.SciFi
A_Pirate.Text = "Pirate"
A_Pirate.TextColor3 = Color3.new(1, 1, 1)
A_Pirate.TextSize = 20
A_Pirate.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=750781874"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=750782770"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=750785693"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=750783738"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=750782230"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=750779899"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=750780242"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Robot.Name = "A_Robot"
A_Robot.Parent = NormalTab
A_Robot.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Robot.BorderSizePixel = 0
A_Robot.Position = UDim2.new(0, 0, 0.291479498, 0)
A_Robot.Size = UDim2.new(0, 150, 0, 30)
A_Robot.Font = Enum.Font.SciFi
A_Robot.Text = "Robot"
A_Robot.TextColor3 = Color3.new(1, 1, 1)
A_Robot.TextSize = 20
A_Robot.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616088211"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616089559"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616095330"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616091570"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616090535"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616086039"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616087089"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Stylish.Name = "A_Stylish"
A_Stylish.Parent = NormalTab
A_Stylish.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Stylish.BorderSizePixel = 0
A_Stylish.Position = UDim2.new(0, 0, 0.232816339, 0)
A_Stylish.Size = UDim2.new(0, 150, 0, 30)
A_Stylish.Font = Enum.Font.SciFi
A_Stylish.Text = "Stylish"
A_Stylish.TextColor3 = Color3.new(1, 1, 1)
A_Stylish.TextSize = 20
A_Stylish.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616136790"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616138447"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616146177"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616140816"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616139451"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616133594"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616134815"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_SuperHero.Name = "A_SuperHero"
A_SuperHero.Parent = NormalTab
A_SuperHero.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_SuperHero.BorderSizePixel = 0
A_SuperHero.Position = UDim2.new(0, 0, 0.464919746, 0)
A_SuperHero.Size = UDim2.new(0, 150, 0, 30)
A_SuperHero.Font = Enum.Font.SciFi
A_SuperHero.Text = "SuperHero"
A_SuperHero.TextColor3 = Color3.new(1, 1, 1)
A_SuperHero.TextSize = 20
A_SuperHero.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616111295"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616113536"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616122287"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616117076"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616115533"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616104706"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616108001"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Toy.Name = "A_Toy"
A_Toy.Parent = NormalTab
A_Toy.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Toy.BorderSizePixel = 0
A_Toy.Position = UDim2.new(6.51925802e-09, 0, 0.756028414, 0)
A_Toy.Size = UDim2.new(0, 150, 0, 30)
A_Toy.Font = Enum.Font.SciFi
A_Toy.Text = "Toy"
A_Toy.TextColor3 = Color3.new(1, 1, 1)
A_Toy.TextSize = 20
A_Toy.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=782841498"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=782845736"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=782843345"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=782842708"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=782847020"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=782843869"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=782846423"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Vampire.Name = "A_Vampire"
A_Vampire.Parent = NormalTab
A_Vampire.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Vampire.BorderSizePixel = 0
A_Vampire.Position = UDim2.new(0, 0, 0.934021354, 0)
A_Vampire.Size = UDim2.new(0, 150, 0, 30)
A_Vampire.Font = Enum.Font.SciFi
A_Vampire.Text = "Vampire"
A_Vampire.TextColor3 = Color3.new(1, 1, 1)
A_Vampire.TextSize = 20
A_Vampire.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1083445855"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1083450166"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1083473930"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1083462077"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083455352"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1083439238"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1083443587"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Werewolf.Name = "A_Werewolf"
A_Werewolf.Parent = NormalTab
A_Werewolf.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Werewolf.BorderSizePixel = 0
A_Werewolf.Position = UDim2.new(-0.000333368778, 0, 0.174509808, 0)
A_Werewolf.Size = UDim2.new(0, 150, 0, 30)
A_Werewolf.Font = Enum.Font.SciFi
A_Werewolf.Text = "Werewolf"
A_Werewolf.TextColor3 = Color3.new(1, 1, 1)
A_Werewolf.TextSize = 20
A_Werewolf.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1083195517"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1083214717"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1083178339"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1083216690"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083218792"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1083182000"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1083189019"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Zombie.Name = "A_Zombie"
A_Zombie.Parent = NormalTab
A_Zombie.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Zombie.BorderSizePixel = 0
A_Zombie.Position = UDim2.new(-1.1920929e-07, 0, 0.582352936, 0)
A_Zombie.Size = UDim2.new(0, 150, 0, 30)
A_Zombie.Font = Enum.Font.SciFi
A_Zombie.Text = "Zombie"
A_Zombie.TextColor3 = Color3.new(1, 1, 1)
A_Zombie.TextSize = 20
A_Zombie.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616158929"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616160636"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616168032"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616161997"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616156119"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616157476"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

Category.Name = "Category"
Category.Parent = NormalTab
Category.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
Category.BorderSizePixel = 0
Category.Size = UDim2.new(0, 150, 0, 30)
Category.Text = "Normal"
Category.TextColor3 = Color3.new(0, 0.835294, 1)
Category.TextSize = 14

SpecialTab.Name = "SpecialTab"
SpecialTab.Parent = Main
SpecialTab.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
SpecialTab.BackgroundTransparency = 1
SpecialTab.BorderSizePixel = 0
SpecialTab.Position = UDim2.new(0, 0, 0.119999997, 0)
SpecialTab.Size = UDim2.new(0, 150, 0, 230)

A_Patrol.Name = "A_Patrol"
A_Patrol.Parent = SpecialTab
A_Patrol.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Patrol.BorderSizePixel = 0
A_Patrol.Position = UDim2.new(0, 0, 0.259960413, 0)
A_Patrol.Size = UDim2.new(0, 150, 0, 30)
A_Patrol.Font = Enum.Font.SciFi
A_Patrol.Text = "Patrol"
A_Patrol.TextColor3 = Color3.new(1, 1, 1)
A_Patrol.TextSize = 20
A_Patrol.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1149612882"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1150842221"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1151231493"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1150967949"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1148811837"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1148811837"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1148863382"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Confident.Name = "A_Confident"
A_Confident.Parent = SpecialTab
A_Confident.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Confident.BorderSizePixel = 0
A_Confident.Position = UDim2.new(0, 0, 0.389248967, 0)
A_Confident.Size = UDim2.new(0, 150, 0, 30)
A_Confident.Font = Enum.Font.SciFi
A_Confident.Text = "Confident"
A_Confident.TextColor3 = Color3.new(1, 1, 1)
A_Confident.TextSize = 20
A_Confident.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1069977950"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1069987858"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1070017263"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1070001516"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1069984524"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1069946257"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1069973677"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Popstar.Name = "A_Popstar"
A_Popstar.Parent = SpecialTab
A_Popstar.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Popstar.BorderSizePixel = 0
A_Popstar.Position = UDim2.new(0, 0, 0.130671918, 0)
A_Popstar.Size = UDim2.new(0, 150, 0, 30)
A_Popstar.Font = Enum.Font.SciFi
A_Popstar.Text = "Popstar"
A_Popstar.TextColor3 = Color3.new(1, 1, 1)
A_Popstar.TextSize = 20
A_Popstar.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1212900985"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1150842221"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1212980338"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1212980348"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1212954642"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1213044953"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1212900995"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Cowboy.Name = "A_Cowboy"
A_Cowboy.Parent = SpecialTab
A_Cowboy.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Cowboy.BorderSizePixel = 0
A_Cowboy.Position = UDim2.new(0, 0, 0.772964239, 0)
A_Cowboy.Size = UDim2.new(0, 150, 0, 30)
A_Cowboy.Font = Enum.Font.SciFi
A_Cowboy.Text = "Cowboy"
A_Cowboy.TextColor3 = Color3.new(1, 1, 1)
A_Cowboy.TextSize = 20
A_Cowboy.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1014390418"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1014398616"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1014421541"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1014401683"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1014394726"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1014380606"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1014384571"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Ghost.Name = "A_Ghost"
A_Ghost.Parent = SpecialTab
A_Ghost.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Ghost.BorderSizePixel = 0
A_Ghost.Position = UDim2.new(0, 0, 0.900632322, 0)
A_Ghost.Size = UDim2.new(0, 150, 0, 30)
A_Ghost.Font = Enum.Font.SciFi
A_Ghost.Text = "Ghost"
A_Ghost.TextColor3 = Color3.new(1, 1, 1)
A_Ghost.TextSize = 20
A_Ghost.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616006778"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616008087"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616013216"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616013216"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616008936"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616005863"
Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=616012453"
Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=616011509"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Sneaky.Name = "A_Sneaky"
A_Sneaky.Parent = SpecialTab
A_Sneaky.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Sneaky.BorderSizePixel = 0
A_Sneaky.Position = UDim2.new(0, 0, 0.517628431, 0)
A_Sneaky.Size = UDim2.new(0, 150, 0, 30)
A_Sneaky.Font = Enum.Font.SciFi
A_Sneaky.Text = "Sneaky"
A_Sneaky.TextColor3 = Color3.new(1, 1, 1)
A_Sneaky.TextSize = 20
A_Sneaky.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=1132473842"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=1132477671"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=1132510133"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=1132494274"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1132489853"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=1132461372"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=1132469004"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Princess.Name = "A_Princess"
A_Princess.Parent = SpecialTab
A_Princess.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Princess.BorderSizePixel = 0
A_Princess.Position = UDim2.new(0, 0, 0.645296335, 0)
A_Princess.Size = UDim2.new(0, 150, 0, 30)
A_Princess.Font = Enum.Font.SciFi
A_Princess.Text = "Princess"
A_Princess.TextColor3 = Color3.new(1, 1, 1)
A_Princess.TextSize = 20
A_Princess.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=941003647"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=941013098"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=941028902"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=941015281"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=941008832"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=940996062"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=941000007"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

Category_2.Name = "Category"
Category_2.Parent = SpecialTab
Category_2.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
Category_2.BorderSizePixel = 0
Category_2.Size = UDim2.new(0, 150, 0, 30)
Category_2.Text = "Special"
Category_2.TextColor3 = Color3.new(0, 0.835294, 1)
Category_2.TextSize = 14

OtherTab.Name = "OtherTab"
OtherTab.Parent = Main
OtherTab.BackgroundColor3 = Color3.new(0.278431, 0.278431, 0.278431)
OtherTab.BackgroundTransparency = 1
OtherTab.BorderSizePixel = 0
OtherTab.Position = UDim2.new(0, 0, 1.06800008, 0)
OtherTab.Size = UDim2.new(0, 150, 0, 220)

Category_3.Name = "Category"
Category_3.Parent = OtherTab
Category_3.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
Category_3.BorderSizePixel = 0
Category_3.Size = UDim2.new(0, 150, 0, 30)
Category_3.Text = "Other"
Category_3.TextColor3 = Color3.new(0, 0.835294, 1)
Category_3.TextSize = 14

A_None.Name = "A_None"
A_None.Parent = OtherTab
A_None.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_None.BorderSizePixel = 0
A_None.Position = UDim2.new(0, 0, 0.134545445, 0)
A_None.Size = UDim2.new(0, 150, 0, 30)
A_None.Font = Enum.Font.SciFi
A_None.Text = "None"
A_None.TextColor3 = Color3.new(1, 1, 1)
A_None.TextSize = 20
A_None.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.swimidle.SwimIdle.AnimationId = "http://www.roblox.com/asset/?id=0"
Animate.swim.Swim.AnimationId = "http://www.roblox.com/asset/?id=0"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

A_Anthro.Name = "A_Anthro"
A_Anthro.Parent = OtherTab
A_Anthro.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
A_Anthro.BorderSizePixel = 0
A_Anthro.Position = UDim2.new(0, 0, 0.269090891, 0)
A_Anthro.Size = UDim2.new(0, 150, 0, 30)
A_Anthro.Font = Enum.Font.SciFi
A_Anthro.Text = "Anthro (Default)"
A_Anthro.TextColor3 = Color3.new(1, 1, 1)
A_Anthro.TextSize = 20
A_Anthro.MouseButton1Click:Connect(function()
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=2510196951"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=2510197257"
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=2510202577"
Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=2510198475"
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=2510197830"
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=2510192778"
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=2510195892"
game.Players.LocalPlayer.Character.Humanoid.Jump = true
end)

wait(1)
Main:TweenPosition(UDim2.new(0.421999991, 0, 0.28400004, 0))

   end,
})
hubtab:CreateButton({
   Name = "光影",
   Callback = function()
      -- Roblox Graphics Enhancher
local light = game.Lighting
for i, v in pairs(light:GetChildren()) do
	v:Destroy()
end

local ter = workspace.Terrain
local color = Instance.new("ColorCorrectionEffect")
local bloom = Instance.new("BloomEffect")
local sun = Instance.new("SunRaysEffect")
local blur = Instance.new("BlurEffect")

color.Parent = light
bloom.Parent = light
sun.Parent = light
blur.Parent = light

-- enable or disable shit

local config = {

	Terrain = true;
	ColorCorrection = true;
	Sun = true;
	Lighting = true;
	BloomEffect = true;
	
}

-- settings {

color.Enabled = false
color.Contrast = 0.15
color.Brightness = 0.1
color.Saturation = 0.25
color.TintColor = Color3.fromRGB(255, 222, 211)

bloom.Enabled = false
bloom.Intensity = 0.1

sun.Enabled = false
sun.Intensity = 0.2
sun.Spread = 1

bloom.Enabled = false
bloom.Intensity = 0.05
bloom.Size = 32
bloom.Threshold = 1

blur.Enabled = false
blur.Size = 6

-- settings }


if config.ColorCorrection then
	color.Enabled = true
end


if config.Sun then
	sun.Enabled = true
end


if config.Terrain then
	-- settings {
	ter.WaterWaveSize = 0.1
	ter.WaterWaveSpeed = 22
	ter.WaterTransparency = 0.9
	ter.WaterReflectance = 0.05
	-- settings }
end
if config.Lighting then
	-- settings {
	light.Ambient = Color3.fromRGB(0, 0, 0)
	light.Brightness = 4
	light.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
	light.ColorShift_Top = Color3.fromRGB(0, 0, 0)
	light.ExposureCompensation = 0
	light.FogColor = Color3.fromRGB(132, 132, 132)
	light.GlobalShadows = true
	light.OutdoorAmbient = Color3.fromRGB(112, 117, 128)
	light.Outlines = false
	-- settings }
end
local a = game.Lighting
a.Ambient = Color3.fromRGB(33, 33, 33)
a.Brightness = 5.69
a.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
a.ColorShift_Top = Color3.fromRGB(255, 247, 237)
a.EnvironmentDiffuseScale = 0.105
a.EnvironmentSpecularScale = 0.522
a.GlobalShadows = true
a.OutdoorAmbient = Color3.fromRGB(51, 54, 67)
a.ShadowSoftness = 0.18
a.GeographicLatitude = -15.525
a.ExposureCompensation = 0.75
bloom.Enabled = true
bloom.Intensity = 0.99
bloom.Size = 9999 
bloom.Threshold = 0
local c = Instance.new("ColorCorrectionEffect", a)
c.Brightness = 0.015
c.Contrast = 0.25
c.Enabled = true
c.Saturation = 0.2
c.TintColor = Color3.fromRGB(217, 145, 57)
if getgenv().mode == "Summer" then
   c.TintColor = Color3.fromRGB(255, 220, 148)
elseif getgenv().mode == "Autumn" then
   c.TintColor = Color3.fromRGB(217, 145, 57)
else
   warn("No mode selected!")
   print("Please select a mode")
   b:Destroy()
   c:Destroy()
end
local d = Instance.new("DepthOfFieldEffect", a)
d.Enabled = true
d.FarIntensity = 0.077
d.FocusDistance = 21.54
d.InFocusRadius = 20.77
d.NearIntensity = 0.277
local e = Instance.new("ColorCorrectionEffect", a)
e.Brightness = 0
e.Contrast = -0.07
e.Saturation = 0
e.Enabled = true
e.TintColor = Color3.fromRGB(255, 247, 239)
local e2 = Instance.new("ColorCorrectionEffect", a)
e2.Brightness = 0.2
e2.Contrast = 0.45
e2.Saturation = -0.1
e2.Enabled = true
e2.TintColor = Color3.fromRGB(255, 255, 255)
local s = Instance.new("SunRaysEffect", a)
s.Enabled = true
s.Intensity = 0.01
s.Spread = 0.146

print("RTX Graphics loaded! Created by BrickoIcko")

   end,
})
hubtab:CreateButton({
   Name = "操人脚本",
   Callback = function()
      loadstring(game:HttpGet("https://pastebin.com/raw/bzmhRgKL"))();
   end,
})
local invisEnabled = false
local originalTransparencies = {}

-- 开启/关闭隐身的函数
local function setInvis(state)
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end
    
    if state then
        -- 保存原始透明度并设为透明
        originalTransparencies = {}
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                originalTransparencies[part] = part.Transparency
                part.Transparency = 1
            end
        end
        -- 处理玩家头顶的Nametag（如果有）
        local head = char:FindFirstChild("Head")
        if head then
            local tag = head:FindFirstChild("Nametag")
            if tag and tag:IsA("BillboardGui") then
                tag.Enabled = false
            end
        end
        Rayfield:Notify({ Title = "隐身", Content = "已开启隐身，其他玩家看不见你", Duration = 2 })
    else
        -- 恢复原始透明度
        for part, trans in pairs(originalTransparencies) do
            if part and part.Parent then
                part.Transparency = trans
            end
        end
        -- 恢复Nametag
        local head = char:FindFirstChild("Head")
        if head then
            local tag = head:FindFirstChild("Nametag")
            if tag and tag:IsA("BillboardGui") then
                tag.Enabled = true
            end
        end
        originalTransparencies = {}
        Rayfield:Notify({ Title = "隐身", Content = "已关闭隐身", Duration = 2 })
    end
end

-- 监听角色重生成，自动保持隐身状态
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    if invisEnabled then
        task.wait(0.1) -- 等待角色完全加载
        setInvis(true)
    end
end)

-- 添加切换按钮
hubtab:CreateToggle({
    Name = "隐身",
    CurrentValue = false,
    Callback = function(value)
        invisEnabled = value
        setInvis(value)
    end,
})
hubtab:CreateButton({
   Name = "偷物品栏",
   Callback = function()
      for i,v in pairs (game.Players:GetChildren()) do
wait()
for i,b in pairs (v.Backpack:GetChildren()) do
b.Parent = game.Players.LocalPlayer.Backpack
end
end
   end,
})
hubtab:CreateButton({
    Name = "R15人物变小",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char then notify("变小", "角色未加载") return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then notify("变小", "未找到Humanoid") return end
        
        -- 使用 NumberValue 而非直接赋值 Value
        local scaleTypes = {"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}
        for _, scaleName in pairs(scaleTypes) do
            local scaleObj = hum:FindFirstChild(scaleName)
            if scaleObj and scaleObj:IsA("NumberValue") then
                scaleObj.Value = 0.5  -- 缩小到原来的50%
            end
        end
        
        notify("变小", "角色已缩小到50%")
    end,
})
createButton(hubtab, "后门执行器汉化", "https://raw.githubusercontent.com/pijiaobenMSJMleng/backdoor/refs/heads/main/backdoor.lua")
createButton(hubtab, "cccccsnngbydxh f3x gui", "https://raw.githubusercontent.com/cccccsnngbydxh/my-gui/5ecdf34fd58c9db3f4a65a27f4c747cc88838392/gui.lua")
createButton(hubtab, "黄色动作", "https://pastebin.com/raw/ZfaM6tNg")
createButton(hubtab, "通用Rayfield Hub", "https://rawscripts.net/raw/Universal-Script-Universal-Rayfield-Hub-134340")
createButton(hubtab, "阿尔宙斯X", "https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/Arceus%20X%20V3")
-- 1. 无限体力
hubtab:CreateToggle({
    Name = "无限体力",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasStamina = false
            local plr = game.Players.LocalPlayer
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                local hum = plr.Character.Humanoid
                if hum:FindFirstChild("Stamina") then
                    hasStamina = true
                end
            end
            if not hasStamina then
                notify("无限体力", "未检测到体力系统(Stamina)，该功能可能无效")
            end
            _G.StaminaConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum:FindFirstChild("Stamina") then
                        hum.Stamina.Value = hum.Stamina.MaxValue
                    end
                end
            end)
        else
            if _G.StaminaConn then _G.StaminaConn:Disconnect(); _G.StaminaConn = nil end
        end
    end,
})

-- 2. 自动收集
hubtab:CreateToggle({
    Name = "自动收集",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasPickup = false
            for _, item in pairs(workspace:GetDescendants()) do
                if item:IsA("BasePart") and (item:GetAttribute("CanCollect") or item.Name:find("Coin") or item.Name:find("Pickup")) then
                    hasPickup = true
                    break
                end
            end
            if not hasPickup then
                notify("自动收集", "未检测到明显的可收集物品，该功能可能无效")
            end
        end
        _G.AutoCollect = state
        task.spawn(function()
            while _G.AutoCollect do
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart
                if hrp then
                    for _, item in pairs(workspace:GetDescendants()) do
                        if item:IsA("BasePart") and (item:GetAttribute("CanCollect") or item.Name:find("Coin") or item.Name:find("Pickup")) then
                            if (item.Position - hrp.Position).Magnitude < 20 then
                                firetouchinterest(hrp, item, 0)
                                firetouchinterest(hrp, item, 1)
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end,
})

-- 3. 无冷却
hubtab:CreateToggle({
    Name = "无冷却",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasCooldown = false
            local plr = game.Players.LocalPlayer
            for _, tool in pairs(plr.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Cooldown") then
                    hasCooldown = true
                    break
                end
            end
            if not hasCooldown and plr.Character then
                for _, tool in pairs(plr.Character:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Cooldown") then
                        hasCooldown = true
                        break
                    end
                end
            end
            if not hasCooldown then
                notify("无冷却", "未检测到带冷却(Cooldown)的工具，该功能可能无效")
            end
            _G.NoCooldownConn = game:GetService("RunService").Stepped:Connect(function()
                local plr = game.Players.LocalPlayer
                for _, tool in pairs(plr.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Cooldown") then
                        tool.Cooldown.Value = 0
                    end
                end
                if plr.Character then
                    for _, tool in pairs(plr.Character:GetChildren()) do
                        if tool:IsA("Tool") and tool:FindFirstChild("Cooldown") then
                            tool.Cooldown.Value = 0
                        end
                    end
                end
            end)
        else
            if _G.NoCooldownConn then _G.NoCooldownConn:Disconnect(); _G.NoCooldownConn = nil end
        end
    end,
})

-- 4. 显示 FPS
hubtab:CreateToggle({
    Name = "显示 FPS",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local fpsLabel = Instance.new("TextLabel", game.CoreGui)
            fpsLabel.Name = "FPSLabel"
            fpsLabel.Size = UDim2.new(0, 100, 0, 30)
            fpsLabel.Position = UDim2.new(1, -110, 0, 10)
            fpsLabel.BackgroundTransparency = 0.5
            fpsLabel.BackgroundColor3 = Color3.new(0,0,0)
            fpsLabel.TextColor3 = Color3.new(0,1,0)
            fpsLabel.Font = Enum.Font.SourceSansBold
            fpsLabel.TextSize = 18
            fpsLabel.Text = "FPS: --"
            local lastTime = tick()
            local frameCount = 0
            _G.FPSConn = game:GetService("RunService").RenderStepped:Connect(function()
                frameCount = frameCount + 1
                local now = tick()
                if now - lastTime >= 1 then
                    fpsLabel.Text = "FPS: " .. frameCount
                    frameCount = 0
                    lastTime = now
                end
            end)
            notify("显示FPS", "已启用，屏幕右上角显示帧率")
        else
            if _G.FPSConn then _G.FPSConn:Disconnect(); _G.FPSConn = nil end
            local lbl = game.CoreGui:FindFirstChild("FPSLabel")
            if lbl then lbl:Destroy() end
            notify("显示FPS", "已关闭")
        end
    end,
})

-- 5. 防踢
hubtab:CreateToggle({
    Name = "防踢",
    CurrentValue = false,
    Callback = function(state)
        local plr = game.Players.LocalPlayer
        if state then
            if not plr._oldKick then
                plr._oldKick = plr.Kick
                plr.Kick = function() end
                notify("防踢", "已启用（仅拦截Kick方法），部分游戏可能无效")
            end
        else
            if plr._oldKick then
                plr.Kick = plr._oldKick
                plr._oldKick = nil
                notify("防踢", "已禁用")
            end
        end
    end,
})
hubtab:CreateToggle({
    Name = "强制第一人称",
    CurrentValue = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        if state then
            local thirdPersonToggle = hubtab:GetToggle("强制第三人称")
            if thirdPersonToggle and thirdPersonToggle.CurrentValue then
                thirdPersonToggle:SetValue(false)
            end
            workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            local char = player.Character
            if char and char:FindFirstChild("Head") then
                workspace.CurrentCamera.CameraSubject = char.Head
            else
                notify("强制第一人称", "未找到头部，可能无法完美跟随")
            end
            _G.FirstPersonConn = game:GetService("RunService").RenderStepped:Connect(function()
                if not state then return end
                local char = player.Character
                if char and char:FindFirstChild("Head") then
                    workspace.CurrentCamera.CFrame = char.Head.CFrame
                end
            end)
            notify("强制第一人称", "已启用")
        else
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            if _G.FirstPersonConn then _G.FirstPersonConn:Disconnect(); _G.FirstPersonConn = nil end
            notify("强制第一人称", "已关闭")
        end
    end,
})
-- 6. 强制第三人称
hubtab:CreateToggle({
    Name = "强制第三人称",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local firstPersonToggle = hubtab:GetToggle("强制第一人称")
            if firstPersonToggle and firstPersonToggle.CurrentValue then
                firstPersonToggle:SetValue(false)
            end
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            if game.Players.LocalPlayer.Character then
                workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
            end
            notify("强制第三人称", "已启用")
        else
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            notify("强制第三人称", "已关闭")
        end
    end,
})

-- 8. 无限弹药
hubtab:CreateToggle({
    Name = "无限弹药",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasAmmo = false
            local player = game.Players.LocalPlayer
            if player.Character then
                for _, tool in pairs(player.Character:GetChildren()) do
                    if tool:IsA("Tool") and (tool:FindFirstChild("Ammo") or tool:FindFirstChild("Bullets")) then
                        hasAmmo = true
                        break
                    end
                end
            end
            if not hasAmmo then
                notify("无限弹药", "未检测到弹药属性(Ammo/Bullets)，该功能可能无效")
            end
            _G.AmmoConn = game:GetService("RunService").RenderStepped:Connect(function()
                local player = game.Players.LocalPlayer
                if player.Character then
                    for _, tool in pairs(player.Character:GetChildren()) do
                        if tool:IsA("Tool") then
                            local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("Bullets")
                            if ammo and (ammo:IsA("IntValue") or ammo:IsA("NumberValue")) then
                                ammo.Value = 9999
                            end
                        end
                    end
                end
            end)
        else
            if _G.AmmoConn then _G.AmmoConn:Disconnect(); _G.AmmoConn = nil end
        end
    end,
})

-- 9. 无后坐力/无扩散
hubtab:CreateToggle({
    Name = "无后坐力/无扩散",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasRecoil = false
            local player = game.Players.LocalPlayer
            if player.Character then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local stats = tool:FindFirstChild("Stats") or tool:FindFirstChild("GunStats")
                    if stats then
                        for _, v in pairs(stats:GetChildren()) do
                            if v.Name:lower():find("recoil") or v.Name:lower():find("spread") then
                                hasRecoil = true
                                break
                            end
                        end
                    end
                end
            end
            if not hasRecoil then
                notify("无后坐力", "未检测到后坐力/扩散属性，该功能可能无效")
            end
            _G.RecoilConn = game:GetService("RunService").RenderStepped:Connect(function()
                local player = game.Players.LocalPlayer
                if player.Character then
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        local stats = tool:FindFirstChild("Stats") or tool:FindFirstChild("GunStats")
                        if stats then
                            for _, v in pairs(stats:GetChildren()) do
                                if v.Name:lower():find("recoil") or v.Name:lower():find("spread") then
                                    v.Value = 0
                                end
                            end
                        end
                    end
                end
            end)
        else
            if _G.RecoilConn then _G.RecoilConn:Disconnect(); _G.RecoilConn = nil end
        end
    end,
})

-- 10. 水上行走
hubtab:CreateToggle({
    Name = "水上行走",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasWater = false
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Material == Enum.Material.Water then
                    hasWater = true
                    break
                end
            end
            if not hasWater then
                notify("水上行走", "未检测到水材质，该功能可能无效")
            end
            _G.WaterWalkConn = game:GetService("RunService").RenderStepped:Connect(function()
                local player = game.Players.LocalPlayer
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    local vel = player.Character.Humanoid.MoveDirection
                    if vel.Magnitude > 0 then
                        local ray = Ray.new(hrp.Position, Vector3.new(0, -3, 0))
                        local hit = workspace:FindPartOnRay(ray, player.Character)
                        if hit and hit.Material == Enum.Material.Water then
                            local platform = Instance.new("Part")
                            platform.Size = Vector3.new(3, 0.2, 3)
                            platform.Position = hrp.Position - Vector3.new(0, 1.5, 0)
                            platform.Anchored = true
                            platform.CanCollide = true
                            platform.Transparency = 0.8
                            platform.BrickColor = BrickColor.new("Ice")
                            platform.Parent = workspace
                            game:GetService("Debris"):AddItem(platform, 0.5)
                        end
                    end
                end
            end)
        else
            if _G.WaterWalkConn then _G.WaterWalkConn:Disconnect(); _G.WaterWalkConn = nil end
        end
    end,
})

-- 11. 低重力
hubtab:CreateToggle({
    Name = "低重力",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.LowGravConn = game:GetService("RunService").RenderStepped:Connect(function()
                if game.Players.LocalPlayer.Character then
                    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, hrp.Velocity.Y * 0.98, hrp.Velocity.Z)
                end
            end)
            notify("低重力", "已启用，跳跃下落速度减慢")
        else
            if _G.LowGravConn then _G.LowGravConn:Disconnect(); _G.LowGravConn = nil end
            notify("低重力", "已关闭")
        end
    end,
})

-- 12. 自动重生
hubtab:CreateToggle({
    Name = "自动重生",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AutoRespawn = game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
                wait(0.5)
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0 then
                    char.Humanoid.Health = char.Humanoid.MaxHealth
                end
            end)
            notify("自动重生", "已启用，死亡后自动恢复生命")
        else
            if _G.AutoRespawn then _G.AutoRespawn:Disconnect(); _G.AutoRespawn = nil end
            notify("自动重生", "已禁用")
        end
    end,
})

-- 13. 瞬移到鼠标位置（按B键）
hubtab:CreateButton({
    Name = "瞬移到鼠标位置 (按B)",
    Callback = function()
        if _G.BTP then return end
        local mouse = game.Players.LocalPlayer:GetMouse()
        _G.BTP = mouse.KeyDown:Connect(function(key)
            if key == "b" then
                local target = mouse.Hit.p
                if game.Players.LocalPlayer.Character then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(target)
                    notify("瞬移", "已瞬移到鼠标位置")
                else
                    notify("瞬移", "角色不存在")
                end
            end
        end)
        notify("瞬移", "已启用，按 B 键瞬移到鼠标位置")
    end,
})

-- 14. 范围拾取
hubtab:CreateToggle({
    Name = "范围拾取 (20单位)",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasPickup = false
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:match("Pickup|Coin|Money|Item") then
                    hasPickup = true
                    break
                end
            end
            if not hasPickup then
                notify("范围拾取", "未检测到可拾取物品(Pickup/Coin/Money/Item)，该功能可能无效")
            end
        end
        _G.RangeCollect = state
        task.spawn(function()
            while _G.RangeCollect do
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart
                if hrp then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Name:match("Pickup|Coin|Money|Item") then
                            if (obj.Position - hrp.Position).Magnitude < 20 then
                                firetouchinterest(hrp, obj, 0)
                                firetouchinterest(hrp, obj, 1)
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end,
})

-- 15. 自动连跳
hubtab:CreateToggle({
    Name = "自动连跳",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AutoJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum.FloorMaterial ~= Enum.Material.Air then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
            notify("自动连跳", "按住空格即可连续跳跃")
        else
            if _G.AutoJumpConn then _G.AutoJumpConn:Disconnect(); _G.AutoJumpConn = nil end
            notify("自动连跳", "已关闭")
        end
    end,
})

-- 16. 防摔伤
hubtab:CreateToggle({
    Name = "防摔伤",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.NoFallConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum.Health > 0 and hum.FloorMaterial == Enum.Material.Air then
                        local vel = plr.Character.HumanoidRootPart.Velocity
                        if vel.Y < -50 then
                            plr.Character.HumanoidRootPart.Velocity = Vector3.new(vel.X, -30, vel.Z)
                        end
                    end
                end
            end)
            notify("防摔伤", "已启用，落地前减速")
        else
            if _G.NoFallConn then _G.NoFallConn:Disconnect(); _G.NoFallConn = nil end
        end
    end,
})

-- 17. 自动攀爬
hubtab:CreateToggle({
    Name = "自动攀爬",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AutoClimbConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if not plr.Character then return end
                local hrp = plr.Character.HumanoidRootPart
                local hum = plr.Character.Humanoid
                if hum.MoveDirection.Magnitude > 0 then
                    local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 2)
                    local hit = workspace:FindPartOnRay(ray, plr.Character)
                    if hit and hit.Material ~= Enum.Material.Air then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, 20, hrp.Velocity.Z)
                    end
                end
            end)
            notify("自动攀爬", "面向墙壁移动即可攀爬")
        else
            if _G.AutoClimbConn then _G.AutoClimbConn:Disconnect(); _G.AutoClimbConn = nil end
        end
    end,
})

-- 18. 无碰撞队友
hubtab:CreateToggle({
    Name = "无碰撞队友",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.NoCollideConn = game:GetService("RunService").Stepped:Connect(function()
                for _, other in pairs(game.Players:GetPlayers()) do
                    if other ~= game.Players.LocalPlayer and other.Character then
                        for _, part in pairs(other.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
            notify("无碰撞队友", "其他玩家无法碰撞你")
        else
            if _G.NoCollideConn then _G.NoCollideConn:Disconnect(); _G.NoCollideConn = nil end
        end
    end,
})

-- 20. 自动重连
hubtab:CreateToggle({
    Name = "自动重连",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AutoReconnect = game:GetService("TeleportService").TeleportInitiated:Connect(function()
                wait(2)
                game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
            end)
            notify("自动重连", "断线后自动尝试重连")
        else
            if _G.AutoReconnect then _G.AutoReconnect:Disconnect(); _G.AutoReconnect = nil end
        end
    end,
})

-- 21. 锁定准星（带完整检测）
hubtab:CreateToggle({
    Name = "锁定准星",
    CurrentValue = false,
    Callback = function(state)
        local uis = game:GetService("UserInputService")
        if state then
            local supported = pcall(function()
                uis.MouseBehavior = Enum.MouseBehavior.LockCenter
            end)
            if not supported then
                notify("锁定准星", "当前环境不支持鼠标锁定，该功能无效")
                return
            end
            local screenGui = Instance.new("ScreenGui", game.CoreGui)
            screenGui.Name = "CrosshairGUI"
            local crosshair = Instance.new("ImageLabel", screenGui)
            crosshair.Size = UDim2.new(0, 20, 0, 20)
            crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)
            crosshair.BackgroundTransparency = 1
            crosshair.Image = "rbxassetid://1127357821"
            crosshair.ImageColor3 = Color3.new(1, 0, 0)
            _G.Crosshair = screenGui
            uis.MouseBehavior = Enum.MouseBehavior.LockCenter
            task.wait(0.1)
            if uis.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
                notify("锁定准星", "鼠标锁定失败，请检查游戏权限")
            else
                notify("锁定准星", "已启用，鼠标锁定屏幕中央")
            end
            _G.CrosshairConn = uis.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if uis.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
                        uis.MouseBehavior = Enum.MouseBehavior.LockCenter
                    end
                end
            end)
        else
            if _G.Crosshair then _G.Crosshair:Destroy() end
            if _G.CrosshairConn then _G.CrosshairConn:Disconnect() end
            uis.MouseBehavior = Enum.MouseBehavior.Default
            notify("锁定准星", "已关闭，鼠标恢复正常")
        end
    end,
})

-- 22. 快速重生
hubtab:CreateToggle({
    Name = "快速重生",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.FastRespawn = game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0 then
                    char.Humanoid.Health = char.Humanoid.MaxHealth
                end
            end)
            notify("快速重生", "死亡后快速恢复生命")
        else
            if _G.FastRespawn then _G.FastRespawn:Disconnect(); _G.FastRespawn = nil end
        end
    end,
})

-- 23. 自动拾取武器
hubtab:CreateToggle({
    Name = "自动拾取武器",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasTool = false
            for _, tool in pairs(workspace:GetDescendants()) do
                if tool:IsA("Tool") and tool.Parent == workspace then
                    hasTool = true
                    break
                end
            end
            if not hasTool then
                notify("自动拾取武器", "未检测到地上的武器(Tool)，该功能可能无效")
            end
        end
        _G.AutoPickup = state
        task.spawn(function()
            while _G.AutoPickup do
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart
                if hrp then
                    for _, tool in pairs(workspace:GetDescendants()) do
                        if tool:IsA("Tool") and tool.Parent == workspace and (tool.Position - hrp.Position).Magnitude < 10 then
                            hrp.CFrame = tool.CFrame
                            task.wait(0.1)
                            local player = game.Players.LocalPlayer
                            if player.Character then
                                player.Character.Humanoid:EquipTool(tool)
                            end
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
        if state then notify("自动拾取武器", "靠近地上的武器自动捡起") end
    end,
})

-- 24. 时间冻结（视觉）
hubtab:CreateButton({
    Name = "时间冻结 (视觉)",
    Callback = function()
        if _G.TimeFrozen then
            _G.TimeFrozen = false
            if _G.TimeFreezeConn then _G.TimeFreezeConn:Disconnect() end
            notify("时间冻结", "已解冻")
        else
            _G.TimeFrozen = true
            _G.TimeFreezeConn = game:GetService("RunService").RenderStepped:Connect(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Animator") then
                        v:Stop()
                    end
                end
            end)
            notify("时间冻结", "已冻结视觉动画")
        end
    end,
})

-- 25. 自动格挡
hubtab:CreateToggle({
    Name = "自动格挡",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasBlock = false
            local player = game.Players.LocalPlayer
            local char = player.Character
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") and (tool:FindFirstChild("Block") or tool:FindFirstChild("Defense")) then
                        hasBlock = true
                        break
                    end
                end
            end
            if not hasBlock then
                notify("自动格挡", "未检测到格挡/防御属性，该功能可能无效")
            end
            _G.AutoBlockConn = game:GetService("RunService").RenderStepped:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, tool in pairs(char:GetChildren()) do
                        if tool:IsA("Tool") and tool:FindFirstChild("Block") then
                            tool.Block.Value = true
                        elseif tool:IsA("Tool") and tool:FindFirstChild("Defense") then
                            tool.Defense.Value = true
                        end
                    end
                end
            end)
        else
            if _G.AutoBlockConn then _G.AutoBlockConn:Disconnect(); _G.AutoBlockConn = nil end
        end
    end,
})

-- 26. 快速游泳
hubtab:CreateToggle({
    Name = "快速游泳",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasWater = false
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Material == Enum.Material.Water then
                    hasWater = true
                    break
                end
            end
            if not hasWater then
                notify("快速游泳", "未检测到水域，该功能可能无效")
            end
            _G.FastSwimConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum:GetState() == Enum.HumanoidStateType.Swimming then
                        hum.WalkSpeed = 100
                    end
                end
            end)
        else
            if _G.FastSwimConn then _G.FastSwimConn:Disconnect(); _G.FastSwimConn = nil end
        end
    end,
})

-- 27. 自动售卖
hubtab:CreateToggle({
    Name = "自动售卖",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasPrompt = false
            for _, prompt in pairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and (prompt.Name:find("Sell") or prompt.Name:find("Trade")) then
                    hasPrompt = true
                    break
                end
            end
            if not hasPrompt then
                notify("自动售卖", "未检测到售卖/交易交互点，该功能可能无效")
            end
            _G.AutoSell = state
            task.spawn(function()
                while _G.AutoSell do
                    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart
                    if hrp then
                        for _, prompt in pairs(workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") and (prompt.Name:find("Sell") or prompt.Name:find("Trade")) then
                                if (prompt.Parent.Position - hrp.Position).Magnitude < 15 then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end
                    task.wait(0.3)
                end
            end)
        else
            _G.AutoSell = false
        end
    end,
})

-- 28. 防眩晕
hubtab:CreateToggle({
    Name = "防眩晕",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AntiMotionConn = game:GetService("RunService").RenderStepped:Connect(function()
                local cam = workspace.CurrentCamera
                cam.CameraType = Enum.CameraType.Custom
                local shake = cam:FindFirstChild("CameraShake")
                if shake then shake:Destroy() end
            end)
            notify("防眩晕", "已启用，镜头晃动已移除")
        else
            if _G.AntiMotionConn then _G.AntiMotionConn:Disconnect(); _G.AntiMotionConn = nil end
        end
    end,
})

-- 29. 自动跳跃过障碍
hubtab:CreateToggle({
    Name = "自动跳跃过障碍",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.AutoHopConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if not plr.Character then return end
                local hrp = plr.Character.HumanoidRootPart
                local hum = plr.Character.Humanoid
                local vel = hum.MoveDirection
                if vel.Magnitude > 0 then
                    local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 2.5)
                    local hit = workspace:FindPartOnRay(ray, plr.Character)
                    if hit and hit.Size.Y > 1 and hit.Position.Y - hrp.Position.Y < 2 then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
            notify("自动跳跃过障碍", "前方有障碍物时自动跳跃")
        else
            if _G.AutoHopConn then _G.AutoHopConn:Disconnect(); _G.AutoHopConn = nil end
        end
    end,
})

-- 30. 无限氧气
hubtab:CreateToggle({
    Name = "无限氧气",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasOxygen = false
            local plr = game.Players.LocalPlayer
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                local hum = plr.Character.Humanoid
                if hum:FindFirstChild("Oxygen") then
                    hasOxygen = true
                end
            end
            if not hasOxygen then
                notify("无限氧气", "未检测到氧气属性(Oxygen)，该功能可能无效")
            end
            _G.InfOxygenConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum:FindFirstChild("Oxygen") then
                        hum.Oxygen.Value = hum.Oxygen.MaxValue
                    end
                end
            end)
        else
            if _G.InfOxygenConn then _G.InfOxygenConn:Disconnect(); _G.InfOxygenConn = nil end
        end
    end,
})

-- 31. 自动恢复生命
hubtab:CreateToggle({
    Name = "自动恢复生命",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasMed = false
            for _, item in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if item:IsA("Tool") and (item.Name:find("Med") or item.Name:find("Health")) then
                    hasMed = true
                    break
                end
            end
            if not hasMed then
                notify("自动恢复生命", "背包中未找到医疗包，请先获取医疗物品")
            end
            _G.AutoHealConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum.Health < hum.MaxHealth * 0.5 then
                        for _, tool in pairs(plr.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and (tool.Name:find("Med") or tool.Name:find("Health")) then
                                tool.Parent = plr.Character
                                tool:Activate()
                                task.wait(0.5)
                                tool.Parent = plr.Backpack
                                break
                            end
                        end
                    end
                end
            end)
        else
            if _G.AutoHealConn then _G.AutoHealConn:Disconnect(); _G.AutoHealConn = nil end
        end
    end,
})

-- 32. 快速爬梯子
hubtab:CreateToggle({
    Name = "快速爬梯子",
    CurrentValue = false,
    Callback = function(state)
        if state then
            _G.FastLadderConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum:GetState() == Enum.HumanoidStateType.Climbing then
                        hum.WalkSpeed = 50
                    end
                end
            end)
        else
            if _G.FastLadderConn then _G.FastLadderConn:Disconnect(); _G.FastLadderConn = nil end
        end
    end,
})

-- 33. 无脚步声
hubtab:CreateToggle({
    Name = "无脚步声",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local hasFootstep = false
            local plr = game.Players.LocalPlayer
            if plr.Character then
                for _, sound in pairs(plr.Character:GetDescendants()) do
                    if sound:IsA("Sound") and (sound.Name:find("Foot") or sound.Name:find("Step")) then
                        hasFootstep = true
                        break
                    end
                end
            end
            if not hasFootstep then
                notify("无脚步声", "未检测到脚步声部件，该功能可能无效")
            end
            _G.MuteStepConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character then
                    for _, sound in pairs(plr.Character:GetDescendants()) do
                        if sound:IsA("Sound") and (sound.Name:find("Foot") or sound.Name:find("Step")) then
                            sound.Volume = 0
                        end
                    end
                end
            end)
        else
            if _G.MuteStepConn then _G.MuteStepConn:Disconnect(); _G.MuteStepConn = nil end
        end
    end,
})

-- 34. 自动闪避
hubtab:CreateToggle({
    Name = "自动闪避",
    CurrentValue = false,
    Callback = function(state)
        if state then
            local plr = game.Players.LocalPlayer
            if not plr.Character then
                notify("自动闪避", "未检测到角色，无法启用")
                return
            end
            local lastHealth = plr.Character.Humanoid.Health
            _G.AutoDodgeConn = game:GetService("RunService").RenderStepped:Connect(function()
                local plr = game.Players.LocalPlayer
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum.Health < lastHealth then
                        local hrp = plr.Character.HumanoidRootPart
                        local newPos = hrp.Position + hrp.CFrame.RightVector * 10
                        hrp.CFrame = CFrame.new(newPos)
                    end
                    lastHealth = hum.Health
                end
            end)
        else
            if _G.AutoDodgeConn then _G.AutoDodgeConn:Disconnect(); _G.AutoDodgeConn = nil end
        end
    end,
})
hubtab:CreateSection("FPS游戏专用")
hubtab:CreateButton({
   Name = "敌方吸人",
   Callback = function()
      local L_1_ = true;
local L_2_ = game.Players.LocalPlayer.Character.HumanoidRootPart;
local L_3_ = L_2_.Position - Vector3.new(5, 0, 0)

game.Players.LocalPlayer:GetMouse().KeyDown:Connect(function(L_4_arg1)
	if L_4_arg1 == 'f' then
		L_1_ = not L_1_
	end;
	if L_4_arg1 == 'r' then
		L_2_ = game.Players.LocalPlayer.Character.HumanoidRootPart;
		L_3_ = L_2_.Position - Vector3.new(5, 0, 0)
	end
end)

for L_5_forvar1, L_6_forvar2 in pairs(game.Players:GetPlayers()) do
	if L_6_forvar2 == game.Players.LocalPlayer then
	else
		local L_7_ = coroutine.create(function()
			game:GetService('RunService').RenderStepped:Connect(function()
				local L_8_, L_9_ = pcall(function()
					local L_10_ = L_6_forvar2.Character;
					if L_10_ then
						if L_10_:FindFirstChild("HumanoidRootPart") then
							if L_1_ then
								L_6_forvar2.Backpack:ClearAllChildren()
								for L_11_forvar1, L_12_forvar2 in pairs(L_10_:GetChildren()) do
									if L_12_forvar2:IsA("Tool") then
										L_12_forvar2:Destroy()
									end
								end;
								L_10_.HumanoidRootPart.CFrame = CFrame.new(L_3_)
							end
						end
					end
				end)
				if L_8_ then
				else
					warn("Unnormal error: "..L_9_)
				end
			end)
		end)
		coroutine.resume(L_7_)
	end
end;

game.Players.PlayerAdded:Connect(function(L_13_arg1)   
	if L_13_arg1 == game.Players.LocalPlayer then
	else
		local L_14_ = coroutine.create(function()
			game:GetService('RunService').RenderStepped:Connect(function()
				local L_15_, L_16_ = pcall(function()
					local L_17_ = L_13_arg1.Character;
					if L_17_ then
						if L_17_:FindFirstChild("HumanoidRootPart") then
							if L_1_ then
								L_13_arg1.Backpack:ClearAllChildren()
								for L_18_forvar1, L_19_forvar2 in pairs(L_17_:GetChildren()) do
									if L_19_forvar2:IsA("Tool") then
										L_19_forvar2:Destroy()
									end
								end;
								L_17_.HumanoidRootPart.CFrame = CFrame.new(L_3_)
							end
						end
					end
				end)
				if L_15_ then
				else
					warn("Unnormal error: "..L_16_)
				end
			end)
		end)
		coroutine.resume(L_14_)
	end           
end)
   end,
})
local centerTab = Window:CreateTab("脚本中心")

local function copyToClipboard(text, hubName)
    setclipboard(text)
    Rayfield:Notify({
        Title = hubName,
        Content = "此脚本需要解锁，请前往链接获取脚本，已自动复制至剪贴板",
        Duration = 2
    })
end

local hubs = {
    {Name = "XA Hub", Link = "https://raw.githubusercontent.com/XiaoYunUwU/XA/main/Loader.lua"},
    {Name = "XK Hub", Link = "https://github.com/DevSloPo/DVES/raw/main/XK%20Hub"},
    {Name = "SA脚本", Link = "https://raw.githubusercontent.com/Bebo-Mods/BeboScripts/main/StandAwekening.lua"},
    {Name = "ZeroHub", Link = "https://raw.githubusercontent.com/xerath-devx/ETFB/refs/heads/main/tokenmultiplier.lua"},
    {Name = "BHBUO脚本", Link = "https://raw.githubusercontent.com/jbu7666gvv/BHBUO/refs/heads/main/loader"},
    {Name = "BS脚本", Link = "https://gitee.com/BS_script/script/raw/master/BS_Script.Luau"},
    {Name = "Rb脚本中心", Link = "https://raw.githubusercontent.com/Yungengxin/roblox/main/RbHub-v_1.2.4"},
    {Name = "XT缝合脚本", Link = "https://raw.githubusercontent.com/wttdxt/xt/refs/heads/main/XT%E5%8D%A1%E5%AF%86%E7%B3%BB%E7%BB%9F%E5%8A%A0%E5%AF%86%E7%89%88.bak"},
    {Name = "TX V3", Link = "https://raw.githubusercontent.com/JsYb666/TX-Free/refs/heads/main/TX-V3.0"},
    {Name = "TX V2免费版", Link = "https://raw.githubusercontent.com/JsYb666/TX-Free-YYDS/refs/heads/main/TX-Pro-Free"},
    -- 新整合项目 11~30
    {Name = "安脚本中心", Link = "https://raw.githubusercontent.com/wucan114514/gegeyxjb/main/oww"},
    {Name = "大司马脚本中心V6", Link = "https://raw.githubusercontent.com/whenheer/dasimav6/refs/heads/main/dasimaV6.txt"},
    {Name = "德与中山脚本中心", Link = "https://raw.githubusercontent.com/dream77239/Deyu-Zhongshan/refs/heads/main/%E5%BE%B7%E4%B8%8E%E4%B8%AD%E5%B1%B1.txt"},
    {Name = "迪脚本新版", Link = "https://api.junkie-development.de/api/v1/luascripts/public/54464412341ef904e10fb8d7ea70e047969d47b06a488cac60fbf8484ff70b83/download"},
    {Name = "黑白脚本", Link = "https://raw.githubusercontent.com/tfcygvunbind/Apple/main/黑白脚本加载器"},
    {Name = "BSS脚本", Link = "https://api.junker-development.de/api/v1/lua/scripts/public/dd6ffea7a477a9832c/gamelinkbf07a5c1bcd919c1bbd8778cbb4b4c20ae/download"},
    {Name = "皮脚本", Link = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"},
    {Name = "叶脚本", Link = "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua"},
    {Name = "盗图脚本", Link = "https://raw.githubusercontent.com/twobt/famimaiwukollw/bw666/main/DOLL.lua"},
    {Name = "X脚本", Link = "https://raw.githubusercontent.com/hljmg/XSCRIPTP-HUB/Script/main/X-SCRIPTP/"},
    {Name = "本脚本", Link = "https://pastefy.app/N5P1BGT/raw"},
    {Name = "KG脚本", Link = "https://github.com/25-NIKGRAF/main/Zhang-Shuua.lua"},
    {Name = "XPro脚本", Link = "https://pastebin.com/raw/wr7n"},
    {Name = "夜宁脚本", Link = "https://raw.githubusercontent.com/6XWRNTWL/dingding123hh/mg/main/lllllllllllll.lua"},
    {Name = "提子中心脚本", Link = "https://raw.githubusercontent.com/6XWRNTWL/"},
    {Name = "沙脚本", Link = "https://raw.githubusercontent.com/Yb666TX-Free-YDYS/main/ShuHUB.lua"},
    {Name = "安颜脚本", Link = "https://raw.githubusercontent.com/wuancan1415/AnYanPN-Loading/安颜.lua"},
    {Name = "到关脚本", Link = "https://pastefy.app/wa3v2Vgm/raw"},
    {Name = "冷脚本", Link = "https://raw.githubusercontent.com/odhdshhe/lenglenglenglenglenglenglenglenglenglenglenglenglenglenglenglenglenglenglenglengscriptcoldLBT-H/refs/heads/main/LENG%20script%20cold%20LBT-H.txt"},
    {Name = "APEX HUB", Link = "https://api.luarmor.net/files/v3/loaders/b200427847354ec1a5931167334d8.lua"}
}

for _, hub in pairs(hubs) do
    centerTab:CreateButton({
        Name = hub.Name,
        Callback = function() loadstring(game:HttpGet(hub.Link))() end,
    })
end
centerTab:CreateSection("外网脚本")
-- 外网脚本中心分区

-- SpaceHub (支持150+游戏)
centerTab:CreateButton({
   Name = "SpaceHub",
   Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))() end,
})

-- Solvex Hub (自动检测游戏)
centerTab:CreateButton({
   Name = "Solvex Hub",
   Callback = function() loadstring(game:HttpGet("https://cdn.sourceb.in/bins/3UxaWKaCmm/0"))() end,
})

-- Avocat Hub (轻量级通用脚本)
centerTab:CreateButton({
   Name = "Avocat Hub",
   Callback = function() 
      -- 注意: 脚本内容较长，直接从ScriptBlox加载原始代码
      loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Avocat-HUB-142656"))()
   end,
})
createButton(centerTab, "GhostHub", "https://rawscripts.net/raw/Universal-Script-GhostHub-53688")
createButton(centerTab, "VoidX Hub V2", "https://rawscripts.net/raw/Universal-Script-VoidX-Hub-V2-1-0-98319")
-- Flow Script Hub (支持14+游戏)
centerTab:CreateButton({
   Name = "Flow Script Hub",
   Callback = function() loadstring(game:HttpGet('https://rawscripts.net/raw/Universal-Script-Flow-Script-Hub-140129'))() end,
})
centerTab:CreateButton({
   Name = "Midnight Hub",
   Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/yeahblxr/-Midnight-hub/refs/heads/main/Midnight%20Hub"))() end,
})
centerTab:CreateButton({
   Name = "Rakesa Hub",
   Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Nah-185149"))() end,
})
centerTab:CreateButton({
   Name = "Best op universal",
   Callback = function() loadstring(game:HttpGet("https://pastebin.com/raw/XfLES1W2"))() end,
})
-- Redz Hub (多功能脚本)
centerTab:CreateButton({
   Name = "Redz Hub",
   Callback = function() loadstring(game:HttpGet("https://pastefy.app/ACOX6D6h/raw"))() end,
})
-- ZO Vortex Hub (轻量快速)
centerTab:CreateButton({
   Name = "ZO Vortex Hub",
   Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-NeoZ-Hub-70445"))() end,
})

-- WhitzHub (开源脚本库)
centerTab:CreateButton({
   Name = "WhitzHub",
   Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Whitzhub-58566"))() end,
})
centerTab:CreateSection("外网需要卡密的脚本")
createButton(centerTab, "LummaHub (30+游戏)", "https://rawscripts.net/raw/Universal-Script-LummaHub-OP-KEYLESS-30-GAMES-100-FEATURES-99321")
centerTab:CreateButton({
   Name = "Galactic Scripts Hub",
   Callback = function() 
      copyToClipboard("https://discordhunt.com/en/servers/galactic-scripts-hub-1378778070009253898", "Galactic Scripts Hub")
   end,
})

centerTab:CreateButton({
   Name = "neox hub key system bypass",
   Callback = function() copyToClipboard("https://pastefy.app/d3HjRJdF/raw", "neox hub bypass") end,
})

centerTab:CreateButton({
   Name = "Lumin Hub",
   Callback = function() copyToClipboard("https://lumin-hub.lol/loader.lua", "Lumin Hub") end,
})

centerTab:CreateButton({
   Name = "EagleKey (Project E Hub)",
   Callback = function() copyToClipboard("https://www.mycompiler.io/view/EagleKey", "EagleKey") end,
})

centerTab:CreateButton({
   Name = "Kawatan Hub Premium Duel",
   Callback = function() copyToClipboard("https://pastebin.com/raw/GLjW4DuU", "Kawatan Hub") end,
})

centerTab:CreateButton({
   Name = "Freeze Hub (Freeze Trade)",
   Callback = function() copyToClipboard("https://pastebin.com/raw/6gH8Uv0k", "Freeze Hub") end,
})

centerTab:CreateButton({
   Name = "Moondiety Hub (待确认链接)",
   Callback = function() copyToClipboard("https://rawscripts.net/raw/Moondiety-Hub", "Moondiety Hub") end,
})
centerTab:CreateButton({
   Name = "NotHub",
   Callback = function() 
      copyToClipboard("https://top.gg/tr/discord/servers/773661099230834688", "NotHub")
   end,
})

-- 1. Nexus Hub（支持多游戏）
centerTab:CreateButton({
    Name = "Nexus Hub",
    Callback = function() copyToClipboard("https://raw.githubusercontent.com/NexusHub/Nexus/main/Loader.lua", "Nexus Hub") end,
})

-- 2. Eclipse Hub（知名通用脚本）
centerTab:CreateButton({
    Name = "Eclipse Hub",
    Callback = function() copyToClipboard("https://raw.githubusercontent.com/EclipseHub/Eclipse/main/Eclipse.lua", "Eclipse Hub") end,
})

-- 3. Synapse X Hub（需密钥，官方加载器）
centerTab:CreateButton({
    Name = "Synapse X Hub (Official)",
    Callback = function() copyToClipboard("https://synapsehub.xyz/loader.lua", "Synapse X Hub") end,
})

-- 4. Neverlose Hub（竞技游戏脚本）
centerTab:CreateButton({
    Name = "Neverlose Hub",
    Callback = function() copyToClipboard("https://neverlose.cc/market/item?id=123456", "Neverlose Hub") end, -- 示例链接，实际请替换
})

-- 5. Astro Hub（轻量级通用）
centerTab:CreateButton({
    Name = "Astro Hub",
    Callback = function() copyToClipboard("https://rawscripts.net/raw/Universal-Script-Astro-Hub-78901", "Astro Hub") end,
})

-- 6. Vynixius Hub（死轨/狱警等）
centerTab:CreateButton({
    Name = "Vynixius Hub",
    Callback = function() copyToClipboard("https://raw.githubusercontent.com/Vynixius/Hub/main/Loader.lua", "Vynixius Hub") end,
})

-- 7. Quantum Hub（功能全面）
centerTab:CreateButton({
    Name = "Quantum Hub",
    Callback = function() copyToClipboard("https://quantumhub.xyz/loader.lua", "Quantum Hub") end,
})

-- 8. Zypher Hub（自动更新）
centerTab:CreateButton({
    Name = "Zypher Hub",
    Callback = function() copyToClipboard("https://raw.githubusercontent.com/ZypherHub/Zypher/main/loader.lua", "Zypher Hub") end,
})

-- 9. Aegis Hub（反检测较强）
centerTab:CreateButton({
    Name = "Aegis Hub",
    Callback = function() copyToClipboard("https://aegishub.xyz/loader.lua", "Aegis Hub") end,
})

-- 10. Celestial Hub（多游戏支持）
centerTab:CreateButton({
    Name = "Celestial Hub",
    Callback = function() copyToClipboard("https://celestialhub.dev/loader.lua", "Celestial Hub") end,
})

-- 11. Vortex Hub（移动端友好）
centerTab:CreateButton({
    Name = "Vortex Hub (Mobile)",
    Callback = function() copyToClipboard("https://raw.githubusercontent.com/VortexHub/Mobile/main/loader.lua", "Vortex Hub") end,
})

-- 12. Prime Hub（付费脚本破解版链接，仅供研究）
centerTab:CreateButton({
    Name = "Prime Hub (Crack)",
    Callback = function() copyToClipboard("https://pastebin.com/raw/PrimeHubCrack", "Prime Hub") end,
})

-- 13. Edge Hub（边缘竞技）
centerTab:CreateButton({
    Name = "Edge Hub",
    Callback = function() copyToClipboard("https://edgehub.xyz/loader.lua", "Edge Hub") end,
})

-- 14. Xero Hub（新星脚本）
centerTab:CreateButton({
    Name = "Xero Hub",
    Callback = function() copyToClipboard("https://raw.githubusercontent.com/XeroHub/Xero/main/Xero.lua", "Xero Hub") end,
})

-- 15. Oxy Hub（暗黑风格UI）
centerTab:CreateButton({
    Name = "Oxy Hub",
    Callback = function() copyToClipboard("https://oxyhub.xyz/loader.lua", "Oxy Hub") end,
})
local toolsTab = Window:CreateTab("工具脚本")

local tools = {
    {Name = "汉化Spy", Link = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/spy%E6%B1%89%E5%8C%96%20(1).txt"},
    {Name = "改版rspy", Link = "https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"},
    {Name = "Infinite Yield", Link = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"},
    {Name = "汉化 Dex V3", Link = "https://raw.githubusercontent.com/Twbtx/tiamxiabuwu/main/han%20hua%20%20dex%20v3"},
    {Name = "CMD-X - 命令行工具脚本", Link = "https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source"},
    {Name = "Hydroxide - 反向工程和漏洞利用工具", Link = "https://raw.githubusercontent.com/iK4oS/backdoor.exe/v8/src/main.lua"},
    {Name = "SimpleAdmin - 简单的管理员面板", Link = "https://raw.githubusercontent.com/exxtremestuffs/SimpleAdmin/main/SimpleAdmin.lua"},
    {Name = "Remote Spy - 远程调用监控器", Link = "https://raw.githubusercontent.com/470n1/RemoteSpy/main/Main.lua"},
    {Name = "Script Dumper - 脚本转储工具", Link = "https://raw.githubusercontent.com/FilteringEnabled/ScriptDumper/main/ScriptDumper.lua"},
    {Name = "Elysian - 高级脚本管理器", Link = "https://raw.githubusercontent.com/ElysianManager/Elysian/main/Loader.lua"},
    {Name = "Unnamed ESP - 无名透视工具", Link = "https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua"},
}

for _, tool in pairs(tools) do
    toolsTab:CreateButton({
        Name = tool.Name,
        Callback = function() loadstring(game:HttpGet(tool.Link))() end,
    })
end

local lt2Tab = Window:CreateTab("伐木大亨2")
lt2Tab:CreateButton({
   Name = "粉车生成",
   Callback = function()
      -- loadstring(game:GetObjects("rbxassetid://5740257502")[1].Source)()

local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Vehicle = Instance.new("TextLabel")
local CurColor = Instance.new("TextLabel")
local Execute = Instance.new("TextButton")
local ScrollingFrame = Instance.new("ScrollingFrame")
local TextLabel = Instance.new("TextLabel")
local Color_1 = Instance.new("TextButton")
local Color_15 = Instance.new("TextButton")
local Color_14 = Instance.new("TextButton")
local Color_13 = Instance.new("TextButton")
local Color_12 = Instance.new("TextButton")
local Color_11 = Instance.new("TextButton")
local Color_10 = Instance.new("TextButton")
local Color_9 = Instance.new("TextButton")
local Color_8 = Instance.new("TextButton")
local Color_7 = Instance.new("TextButton")
local Color_6 = Instance.new("TextButton")
local Color_5 = Instance.new("TextButton")
local Color_4 = Instance.new("TextButton")
local Color_3 = Instance.new("TextButton")
local Color_2 = Instance.new("TextButton")
 
ScreenGui.Parent = game.CoreGui

Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.new(1, 1, 1)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.372576177, -509, 0.0266900957, 334)
Main.Size = UDim2.new(0, 213, 0, 246)
Main.SizeConstraint = Enum.SizeConstraint.RelativeXX
Main.Visible = false

Vehicle.Name = "Vehicle"
Vehicle.Parent = Main
Vehicle.BackgroundColor3 = Color3.new(0, 0.866667, 1)
Vehicle.BorderSizePixel = 0
Vehicle.Position = UDim2.new(0, 0, 1.16666663, 0)
Vehicle.Size = UDim2.new(0, 214, 0, 30)
Vehicle.Font = Enum.Font.Garamond
Vehicle.Text = " Vehicle: Not Selected "
Vehicle.TextColor3 = Color3.new(1, 0, 0)
Vehicle.TextScaled = true
Vehicle.TextSize = 14
Vehicle.TextWrapped = true

CurColor.Name = "CurColor"
CurColor.Parent = Main
CurColor.BackgroundColor3 = Color3.new(0.854902, 0.854902, 0.854902)
CurColor.BackgroundTransparency = 1
CurColor.BorderSizePixel = 0
CurColor.Size = UDim2.new(0, 213, 0, 46)
CurColor.Font = Enum.Font.SourceSans
CurColor.Text = " Color: Not Selected "
CurColor.TextColor3 = Color3.new(0.0901961, 1, 0.972549)
CurColor.TextScaled = true
CurColor.TextSize = 14
CurColor.TextWrapped = true

Execute.Name = "Execute"
Execute.Parent = Main
Execute.BackgroundColor3 = Color3.new(0.529412, 0.054902, 1)
Execute.BackgroundTransparency = 0.0099999997764826
Execute.BorderSizePixel = 0
Execute.Position = UDim2.new(0, 0, 0.998856544, 0)
Execute.Size = UDim2.new(0, 213, 0, 42)
Execute.Font = Enum.Font.Cartoon
Execute.Text = "Execute"
Execute.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Execute.TextSize = 35
Execute.TextWrapped = true

ScrollingFrame.Parent = Main
ScrollingFrame.Active = true
ScrollingFrame.BackgroundColor3 = Color3.new(1, 1, 1)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 0, 0.182926834, 0)
ScrollingFrame.Size = UDim2.new(0, 213, 0, 201)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 2.4000001, 0)

TextLabel.Parent = ScrollingFrame
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 0, 0.932706356, 0)
TextLabel.Size = UDim2.new(0, 199, 0, 39)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Hacker#8326"
TextLabel.TextColor3 = Color3.new(0, 1, 1)
TextLabel.TextScaled = true
TextLabel.TextSize = 14
TextLabel.TextWrapped = true

Color_1.Name = "Color_1"
Color_1.Parent = ScrollingFrame
Color_1.BackgroundColor3 = Color3.new(1, 1, 1)
Color_1.BackgroundTransparency = 1
Color_1.BorderSizePixel = 0
Color_1.Position = UDim2.new(0, 0, 0.000889120041, 0)
Color_1.Size = UDim2.new(0, 199, 0, 37)
Color_1.Font = Enum.Font.Cartoon
Color_1.Text = "Medium stone grey"
Color_1.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_1.TextSize = 35
Color_1.TextWrapped = true
Color_1.TextXAlignment = Enum.TextXAlignment.Left

Color_15.Name = "Color_15"
Color_15.Parent = ScrollingFrame
Color_15.BackgroundColor3 = Color3.new(1, 1, 1)
Color_15.BackgroundTransparency = 1
Color_15.BorderSizePixel = 0
Color_15.Position = UDim2.new(0, 0, 0.435725302, 0)
Color_15.Size = UDim2.new(0, 199, 0, 37)
Color_15.Font = Enum.Font.Cartoon
Color_15.Text = "Sand green"
Color_15.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_15.TextSize = 35
Color_15.TextWrapped = true
Color_15.TextXAlignment = Enum.TextXAlignment.Left

Color_14.Name = "Color_14"
Color_14.Parent = ScrollingFrame
Color_14.BackgroundColor3 = Color3.new(1, 1, 1)
Color_14.BackgroundTransparency = 1
Color_14.BorderSizePixel = 0
Color_14.Position = UDim2.new(0, 0, 0.497316808, 0)
Color_14.Size = UDim2.new(0, 199, 0, 37)
Color_14.Font = Enum.Font.Cartoon
Color_14.Text = "Sand red"
Color_14.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_14.TextSize = 35
Color_14.TextWrapped = true
Color_14.TextXAlignment = Enum.TextXAlignment.Left

Color_13.Name = "Color_13"
Color_13.Parent = ScrollingFrame
Color_13.BackgroundColor3 = Color3.new(1, 1, 1)
Color_13.BackgroundTransparency = 1
Color_13.BorderSizePixel = 0
Color_13.Position = UDim2.new(0, 0, 0.558908343, 0)
Color_13.Size = UDim2.new(0, 199, 0, 37)
Color_13.Font = Enum.Font.Cartoon
Color_13.Text = "Faded green"
Color_13.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_13.TextSize = 35
Color_13.TextWrapped = true
Color_13.TextXAlignment = Enum.TextXAlignment.Left

Color_12.Name = "Color_12"
Color_12.Parent = ScrollingFrame
Color_12.BackgroundColor3 = Color3.new(1, 1, 1)
Color_12.BackgroundTransparency = 1
Color_12.BorderSizePixel = 0
Color_12.Position = UDim2.new(0, 0, 0.374133736, 0)
Color_12.Size = UDim2.new(0, 199, 0, 37)
Color_12.Font = Enum.Font.Cartoon
Color_12.Text = "Dark grey metallic"
Color_12.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_12.TextSize = 35
Color_12.TextWrapped = true
Color_12.TextXAlignment = Enum.TextXAlignment.Left

Color_11.Name = "Color_11"
Color_11.Parent = ScrollingFrame
Color_11.BackgroundColor3 = Color3.new(1, 1, 1)
Color_11.BackgroundTransparency = 1
Color_11.BorderSizePixel = 0
Color_11.Position = UDim2.new(0, 0, 0.248948976, 0)
Color_11.Size = UDim2.new(0, 199, 0, 37)
Color_11.Font = Enum.Font.Cartoon
Color_11.Text = "Dark grey"
Color_11.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_11.TextSize = 35
Color_11.TextWrapped = true
Color_11.TextXAlignment = Enum.TextXAlignment.Left

Color_10.Name = "Color_10"
Color_10.Parent = ScrollingFrame
Color_10.BackgroundColor3 = Color3.new(1, 1, 1)
Color_10.BackgroundTransparency = 1
Color_10.BorderSizePixel = 0
Color_10.Position = UDim2.new(0, 0, 0.18735747, 0)
Color_10.Size = UDim2.new(0, 199, 0, 37)
Color_10.Font = Enum.Font.Cartoon
Color_10.Text = "Earth yellow"
Color_10.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_10.TextSize = 35
Color_10.TextWrapped = true
Color_10.TextXAlignment = Enum.TextXAlignment.Left

Color_9.Name = "Color_9"
Color_9.Parent = ScrollingFrame
Color_9.BackgroundColor3 = Color3.new(1, 1, 1)
Color_9.BackgroundTransparency = 1
Color_9.BorderSizePixel = 0
Color_9.Position = UDim2.new(0, 0, 0.125765949, 0)
Color_9.Size = UDim2.new(0, 199, 0, 37)
Color_9.Font = Enum.Font.Cartoon
Color_9.Text = "Earth orange"
Color_9.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_9.TextSize = 35
Color_9.TextWrapped = true
Color_9.TextXAlignment = Enum.TextXAlignment.Left

Color_8.Name = "Color_8"
Color_8.Parent = ScrollingFrame
Color_8.BackgroundColor3 = Color3.new(1, 1, 1)
Color_8.BackgroundTransparency = 1
Color_8.BorderSizePixel = 0
Color_8.Position = UDim2.new(0, 0, 0.0641744137, 0)
Color_8.Size = UDim2.new(0, 199, 0, 37)
Color_8.Font = Enum.Font.Cartoon
Color_8.Text = "Silver"
Color_8.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_8.TextSize = 35
Color_8.TextWrapped = true
Color_8.TextXAlignment = Enum.TextXAlignment.Left

Color_7.Name = "Color_7"
Color_7.Parent = ScrollingFrame
Color_7.BackgroundColor3 = Color3.new(1, 1, 1)
Color_7.BackgroundTransparency = 1
Color_7.BorderSizePixel = 0
Color_7.Position = UDim2.new(0, 0, 0.747378469, 0)
Color_7.Size = UDim2.new(0, 199, 0, 37)
Color_7.Font = Enum.Font.Cartoon
Color_7.Text = "Brick yellow"
Color_7.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_7.TextSize = 35
Color_7.TextWrapped = true
Color_7.TextXAlignment = Enum.TextXAlignment.Left

Color_6.Name = "Color_6"
Color_6.Parent = ScrollingFrame
Color_6.BackgroundColor3 = Color3.new(1, 1, 1)
Color_6.BackgroundTransparency = 1
Color_6.BorderSizePixel = 0
Color_6.Position = UDim2.new(0, 0, 0.622501612, 0)
Color_6.Size = UDim2.new(0, 199, 0, 37)
Color_6.Font = Enum.Font.Cartoon
Color_6.Text = "Dark red"
Color_6.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_6.TextSize = 35
Color_6.TextWrapped = true
Color_6.TextXAlignment = Enum.TextXAlignment.Left

Color_5.Name = "Color_5"
Color_5.Parent = ScrollingFrame
Color_5.BackgroundColor3 = Color3.new(1, 1, 1)
Color_5.BackgroundTransparency = 1
Color_5.BorderSizePixel = 0
Color_5.Position = UDim2.new(0, 0, 0.870561481, 0)
Color_5.Size = UDim2.new(0, 199, 0, 37)
Color_5.Font = Enum.Font.Cartoon
Color_5.Text = "Hot pink"
Color_5.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_5.TextSize = 35
Color_5.TextWrapped = true
Color_5.TextXAlignment = Enum.TextXAlignment.Left

Color_4.Name = "Color_4"
Color_4.Parent = ScrollingFrame
Color_4.BackgroundColor3 = Color3.new(1, 1, 1)
Color_4.BackgroundTransparency = 1
Color_4.BorderSizePixel = 0
Color_4.Position = UDim2.new(0, 0, 0.685786903, 0)
Color_4.Size = UDim2.new(0, 199, 0, 37)
Color_4.Font = Enum.Font.Cartoon
Color_4.Text = "Rust"
Color_4.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_4.TextSize = 35
Color_4.TextWrapped = true
Color_4.TextXAlignment = Enum.TextXAlignment.Left

Color_3.Name = "Color_3"
Color_3.Parent = ScrollingFrame
Color_3.BackgroundColor3 = Color3.new(1, 1, 1)
Color_3.BackgroundTransparency = 1
Color_3.BorderSizePixel = 0
Color_3.Position = UDim2.new(0, 0, 0.808969975, 0)
Color_3.Size = UDim2.new(0, 199, 0, 37)
Color_3.Font = Enum.Font.Cartoon
Color_3.Text = "Really black"
Color_3.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_3.TextSize = 35
Color_3.TextWrapped = true
Color_3.TextXAlignment = Enum.TextXAlignment.Left

Color_2.Name = "Color_2"
Color_2.Parent = ScrollingFrame
Color_2.BackgroundColor3 = Color3.new(1, 1, 1)
Color_2.BackgroundTransparency = 1
Color_2.BorderSizePixel = 0
Color_2.Position = UDim2.new(0, 0, 0.310848475, 0)
Color_2.Size = UDim2.new(0, 199, 0, 37)
Color_2.Font = Enum.Font.Cartoon
Color_2.Text = "Lemon metalic"
Color_2.TextColor3 = Color3.new(0.376471, 1, 0.0901961)
Color_2.TextSize = 35
Color_2.TextWrapped = true
Color_2.TextXAlignment = Enum.TextXAlignment.Left

local Sound_1 = Instance.new("Sound")
 
Sound_1.Name = "Sound"
Sound_1.SoundId = "rbxassetid://408524543"
Sound_1.Volume = 2
Sound_1.archivable = false
Sound_1.Parent = game:GetService("Workspace")

function Sound1()
    Sound_1:play()
end

local Sound_2 = Instance.new("Sound")
 
Sound_2.Name = "Song1"
Sound_2.SoundId = "rbxassetid://452267918"
Sound_2.Volume = 2
Sound_2.archivable = false
Sound_2.Parent = game:GetService("Workspace")

function Sound2()
    Sound_2:play()
end

local UIGradient = Instance.new("UIGradient", Main)
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(0, 0.4, 1)),
    ColorSequenceKeypoint.new(1, Color3.new(0.54902, 0, 1))
})

local Colors = { Color_1, Color_2, Color_3, Color_4, Color_5, Color_6, Color_7, Color_8, Color_9, Color_10, Color_11, Color_12, Color_13, Color_14, Color_15}

for i, v in pairs(Colors) do
    v.MouseEnter:connect(function() 
        Sound1()
    end)
    v.MouseButton1Down:connect(function()
        Sound2()
        CurColor.Text = " Color: " .. v.Text .. " "
    end)
end

local Tool = Instance.new("Tool", game:GetService("Players").LocalPlayer.Backpack)
Tool.Name = "Car Color Tool"
Tool.RequiresHandle = false
Tool.CanBeDropped = false
Tool.Unequipped:Connect(function()
    Main.Visible = false
end)

local C = nil
local FP = nil

game:GetService("Workspace").PlayerModels.ChildAdded:connect(function(v) v:WaitForChild("Owner")
    if v:WaitForChild("PaintParts") then
        FP = v.PaintParts.Part
    end
end)

local function Press(Button)
    game.ReplicatedStorage.Interaction.RemoteProxy:FireServer(Button)
end

local Car = nil

Tool.Equipped:Connect(function(Mouse)
    Main.Visible = true
    Mouse.Button1Down:connect(function()
        if Mouse.Target and Mouse.Target.Parent.Type and Mouse.Target.Parent.Type.Value == "Vehicle Spot" then
            Car = Mouse.Target.Parent:FindFirstChild("ButtonRemote_SpawnButton", true)
             Vehicle.Text = " Vehicle: " .. Mouse.Target.Parent.ItemName.Value .. " "
        end
    end)
end)

Execute.MouseEnter:connect(function() 
    Sound1()
end)

Execute.MouseButton1Down:connect(function()
    if CurColor.Text ~= " Color: Not Selected " and Car ~= nil then
        Sound2()
        repeat
            Press(Car)
            repeat wait(0.05) until FP ~= C
            C = FP
        until FP.BrickColor.Name == string.sub(CurColor.Text, 9, #CurColor.Text - 1) or FP.BrickColor.Name == "Hot pink"
    end
end)
   end,
})
-- 海贼果实
local tabBloxFruits = Window:CreateTab("blox fruits")
createButton(tabBloxFruits, "RedZ Hub", "https://raw.githubusercontent.com/LuaCrack/Min/refs/heads/main/MinXt2Eng")
createButton(tabBloxFruits, "Quantum Onyx Project", "https://raw.githubusercontent.com/FlazhGG/QTONYX/refs/heads/main/NextGeneration.lua")
createButton(tabBloxFruits, "Zee Hub VIP", "https://scripts.alchemyhub.xyz")
createButton(tabBloxFruits, "Teddy Hub", "https://raw.githubusercontent.com/Teddyseetink/Haidepzai/refs/heads/main/TeddyHub.lua")
createButton(tabBloxFruits, "Raito Hub", "https://raw.githubusercontent.com/Efe0626/RaitoHub/main/Script")
createButton(tabBloxFruits, "Mobile Update 21 Hub", "https://raw.githubusercontent.com/U-ziii/Blox-Fruits/refs/heads/main/SeaEvents.lua")
createButton(tabBloxFruits, "Update 24 OP Loader", "https://api.luarmor.net/files/v3/loaders/3b2169cf53bc6104dabe8e19562e5cc2.lua")
createButton(tabBloxFruits, "Maris Free Hub", "https://raw.githubusercontent.com/U-ziii/Blox-Fruits/refs/heads/main/DFFruit.lua")
createButton(tabBloxFruits, "Adel Top Hub", "https://raw.githubusercontent.com/AdelOnTheTop/Adel-Hub/main/Main.lua")
createButton(tabBloxFruits, "Mukuro All-In-One", "https://raw.githubusercontent.com/xDepressionx/Free-Script/main/AllScript.lua")

-- 宠物模拟器99
local tabPetSim99 = Window:CreateTab("宠物模拟器99")
createButton(tabPetSim99, "Auto Buy Inf Gem Auto Farm", "https://raw.githubusercontent.com/RJ077SIUU/PS99/main/Gems")
createButton(tabPetSim99, "Dupe Script", "https://rentry.co/nb8rcubw/raw")
createButton(tabPetSim99, "Auto Farm & Infinite Boosts", "https://zaphub.xyz/Exec")
createButton(tabPetSim99, "Auto Finish Obby Minigames", "https://rentry.co/vn96engx/raw")
createButton(tabPetSim99, "Auto Collect Drops & Flags", "https://raw.githubusercontent.com/ahmadsgamer2/Zekrom-Hub-X/main/Zekrom-Hub-X-exe")
createButton(tabPetSim99, "Pastebin 2026 Script 6", "https://rentry.co/2uh559tp/raw")
createButton(tabPetSim99, "Pastebin 2026 Script 7", "https://rentry.co/rf7y3gva/raw")
createButton(tabPetSim99, "Pastebin 2026 Script 8", "https://rentry.co/somwxbqr/raw")
createButton(tabPetSim99, "Pastebin 2026 Script 9", "https://rentry.co/tuc9cqdx/raw")

-- 耳光大战
local tabSlapBattles = Window:CreateTab("打屁股战斗")
createButton(tabSlapBattles, "Pastebin 2026 Script 1", "https://raw.githubusercontent.com/rblxscriptsnet/unfair/main/rblxhub.lua")
createButton(tabSlapBattles, "Pastebin 2026 Script 2", "https://raw.githubusercontent.com/Giangplay/Slap_Battles/main/Slap_Battles.lua")
createButton(tabSlapBattles, "Pastebin 2026 Script 3", "https://raw.githubusercontent.com/Bilmemi/bestaura/main/semihu803")
createButton(tabSlapBattles, "Pastebin 2026 Script 4", "https://raw.githubusercontent.com/dizyhvh/slap_battles_gui/main/0.lua")
createCodeButton(tabSlapBattles, "自动杀人(近战)", [[
function isSpawned(player)
   if workspace:FindFirstChild(player.Name) and player.Character:FindFirstChild("HumanoidRootPart") then
       return true
   else
       return false
   end
end
while wait() do
   for i, v in pairs(game.Players:GetPlayers()) do
       if isSpawned(v) and v ~= game.Players.LocalPlayer and not v.Character.Head:FindFirstChild("UnoReverseCard") then
           if (v.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 50 then
               game:GetService("ReplicatedStorage").b:FireServer(v.Character["Right Arm"])
               wait(0.1)
           end
       end
   end
end
]])

-- 起床战争
local tabBedWars = Window:CreateTab("BedWars")
createButton(tabBedWars, "Auto Click & Kill Aura", "https://gist.githubusercontent.com/DeveloperMikey/2b8ee3d5a38c56c2cc1db72554850384/raw/bedwar.lua")
createButton(tabBedWars, "Infinite Jump Fly & Sprint", "https://raw.githubusercontent.com/GamerScripter/Game-Hub/main/loader")
createButton(tabBedWars, "VapeV4 GUI", "https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua")
createButton(tabBedWars, "Crokuranu UI", "https://raw.githubusercontent.com/SlaveDash/Crokuranu/main/Bedwars%20UI%20Source%20Code")
createButton(tabBedWars, "Monkey Script", "https://raw.githubusercontent.com/KuriWasTaken/MonkeyScripts/main/BedWarsMonkey.lua")

-- 谋杀之谜2
local tabMM2 = Window:CreateTab("破坏者联盟2")
createButton(tabMM2, "Eclipse Hub", "https://raw.githubusercontent.com/Doggo-cryto/EclipseMM2/master/Script")
createButton(tabMM2, "Silent Aim & Kill All", "https://rentry.co/xzdu8wnm/raw")
createButton(tabMM2, "Rogue Hub", "https://raw.githubusercontent.com/Kitzoon/Rogue-Hub/main/Main.lua")
createButton(tabMM2, "Aimbot Script", "https://rentry.co/hb89aoq2/raw")
createButton(tabMM2, "Alchemy Hub", "https://luable.netlify.app/AlchemyHub/Luncher.script")
createButton(tabMM2, "Auto Farm MM2 Mobile", "https://raw.githubusercontent.com/NoCapital2/MM2Autofarm/main/script")
createButton(tabMM2, "Auto Farm & Coin Farm", "https://raw.githubusercontent.com/KidichiHB/Kidachi/main/Scripts/MM2")

-- 军械库
local tabArsenal = Window:CreateTab("兵工厂")
createButton(tabArsenal, "Tbao Hub Arsenal", "https://raw.githubusercontent.com/tbao143/thaibao/main/TbaoHubArsenal")
createButton(tabArsenal, "Owl Hub", "https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt")
createButton(tabArsenal, "Script 3", "https://raw.githubusercontent.com/cris123452/my/main/cas")
createButton(tabArsenal, "Quotas Hub", "https://raw.githubusercontent.com/Insertl/QuotasHub/main/BETAv1.3")
createButton(tabArsenal, "Strike Hub", "https://raw.githubusercontent.com/ccxmIcal/cracks/main/strikehub.lua")
createButton(tabArsenal, "V.G-Hub", "https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub")

-- 神道生活
local tabShindo = Window:CreateTab("忍者生命2")
createButton(tabShindo, "Project Nexus", "https://raw.githubusercontent.com/IkkyyDF/ProjectNexus/main/Loader.lua")
createButton(tabShindo, "Premier X", "https://raw.githubusercontent.com/SxnwDev/Premier/main/Free-Premier.lua")
createButton(tabShindo, "V.G-Hub", "https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub")
createButton(tabShindo, "SpyHub", "https://raw.githubusercontent.com/Corrupt2625/Revamps/main/SpyHub.lua")
createButton(tabShindo, "Slash Hub", "https://hub.wh1teslash.xyz/")
createButton(tabShindo, "Imp Hub", "https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua")
createButton(tabShindo, "Solix Hub", "https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua")
createButton(tabShindo, "Solaris Hub", "https://solarishub.net/script.lua")

-- 收养我
local tabAdoptMe = Window:CreateTab("收养我")
createButton(tabAdoptMe, "Auto Farm Auto Quest Auto Neon", "https://raw.githubusercontent.com/L1ghtScripts/AdoptmeScript/main/AdoptmeScript/JJR1655-adopt-me.lua")
createButton(tabAdoptMe, "Pet Farming Script", "https://raw.githubusercontent.com/Cospog-Scripts/shnigelutils/main/mainLoader.lua")
createButton(tabAdoptMe, "Auto Farm & Auto Neon", "https://gitfront.io/r/ReQiuYTPL/wFUydaK74uGx/hub/raw/ReQiuYTPLHub.lua")
createButton(tabAdoptMe, "Auto Quest & Auto Heal", "https://raw.githubusercontent.com/billieroblox/jimmer/main/77_HAJ07IP.lua")
createButton(tabAdoptMe, "Auto Buy & Walkspeed", "https://raw.githubusercontent.com/concordeware/sncware/main/sncware")
createButton(tabAdoptMe, "Get All Pets", "https://raw.githubusercontent.com/lf4d7/daphie/main/ame.lua")
createButton(tabAdoptMe, "Pastebin 2026 Script 8", "https://raw.githubusercontent.com/Ultra-Scripts/AdoptmeScript/main/AdoptmeScript/JI5PMVG-adopt-me.lua")

-- 布鲁克海文RP
local tabBrookhaven = Window:CreateTab("布鲁克海文RP")
createButton(tabBrookhaven, "Speed Hack Noclip Auto Farm", "https://raw.githubusercontent.com/riotrapdo-spec/KeySystems/refs/heads/main/Loader.lua")
createButton(tabBrookhaven, "Khosh Script", "https://raw.githubusercontent.com/kllooep/Fjjzxda6/refs/heads/main/KhoshScript.txt")
createButton(tabBrookhaven, "Sarturn Hub", "https://raw.githubusercontent.com/fhrdimybds-byte/Sarturn-hub-BrookhavenRP-/refs/heads/main/main.lua")
createButton(tabBrookhaven, "JOAO HUB", "https://raw.githubusercontent.com/UgiX1/JOAOHUB/refs/heads/main/JOAOHUB.txt")
createButton(tabBrookhaven, "Pastebin 2026 Script 5", "https://ghostbin.axel.org/paste/opp4o/raw")

-- 费什
local tabFisch = Window:CreateTab("Fisch")
createButton(tabFisch, "Venox Universal Scripts", "https://raw.githubusercontent.com/venoxcc/universalscripts/refs/heads/main/fisch")
createButton(tabFisch, "Farming GUI", "https://api.luarmor.net/files/v3/loaders/cba17b913ee63c7bfdbb9301e2d87c8b.lua")
createButton(tabFisch, "Banana Hub", "https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua")
createButton(tabFisch, "Lunor Loader", "https://raw.githubusercontent.com/Just3itx/Lunor-Loadstrings/refs/heads/main/Loader")
createButton(tabFisch, "Solix Auto Shake", "https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua")
createButton(tabFisch, "Mobile Script Y-HUB", "https://raw.githubusercontent.com/Luarmor123/community-Y-HUB/refs/heads/main/Fisch-YHUB")
createButton(tabFisch, "Loader 2529a5f9", "https://api.luarmor.net/files/v3/loaders/2529a5f9dfddd5523ca4e22f21cceffa.lua")
createButton(tabFisch, "Loader 0bbab1d5", "https://api.luarmor.net/files/v3/loaders/0bbab1d51c52f509c1b7c219c86d4d83.lua")

-- 刀锋球
local tabBladeBall = Window:CreateTab("Blade Ball")
createButton(tabBladeBall, "Speed X BladeBall", "https://raw.githubusercontent.com/FriezGG/Scripts/main/Speed%20X%20BladeBall")
createButton(tabBladeBall, "Auto Farm & Auto Walk", "https://pi-hub.pages.dev/protected/loader.lua")
createButton(tabBladeBall, "R3TH PRIV Loader", "https://raw.githubusercontent.com/R3TH-PRIV/R3THPRIV/main/loader.lua")
createButton(tabBladeBall, "Auto Parry Mobile", "https://scriptblox.com/raw/UPD-Blade-Ball-op-autoparry-with-visualizer-8652")
createButton(tabBladeBall, "Close Combat Script", "https://raw.githubusercontent.com/kidshop4/scriptbladeballk/main/bladeball.lua")
createButton(tabBladeBall, "Neon.C Hub X", "https://raw.githubusercontent.com/Neoncat765/Neon.C-Hub-X/main/UnknownVersion")
createButton(tabBladeBall, "Auto Clicker Mobile", "https://raw.githubusercontent.com/GrandmasterOfLife123/lua/main/releasedbladeball.lua")
createButton(tabBladeBall, "FPS Booster", "https://raw.githubusercontent.com/Fsploit/venox-blade-ball-v1/main/K-A-T-S-U-S-F-S-P-L-O-I-T-I-S-A-F-U-R-R-Y%20MAIN%20V4")
createButton(tabBladeBall, "No Key Auto Parry", "https://raw.githubusercontent.com/luascriptsROBLOX/BladeBallXera/main/XeraUltron")

-- 最强战场
local tabTSB = Window:CreateTab("最坚强的战场")
createButton(tabTSB, "Auto Farm Players Anti Stun", "https://pastefy.app/1emcuiFz/raw")
createButton(tabTSB, "Auto Farm Invisible & Fling", "https://raw.githubusercontent.com/LOLking123456/Saitama111/main/battle121")
createButton(tabTSB, "Aimbot Auto Punch Auto Skill", "https://raw.githubusercontent.com/sandwichk/RobloxScripts/main/Scripts/BadWare/Hub/Load.lua")
createButton(tabTSB, "Infinite Jump & Fly", "https://pastefy.app/v9VSOfM5/raw")
createButton(tabTSB, "Anti Stun & Extra Range", "https://raw.githubusercontent.com/TheHanki/Hawk/main/Loader")
createButton(tabTSB, "Auto Parry", "https://raw.githubusercontent.com/SkibidiCen/MainMenu/main/Code")
createButton(tabTSB, "Mobile Script", "https://raw.githubusercontent.com/tamarixr/tamhub/main/bettertamhub.lua")
createButton(tabTSB, "Saitama Battlegrounds", "https://nicuse.xyz/SaitamaBattlegrounds.lua")

-- 宿敌
local tabRivals = Window:CreateTab("竞争对手")
createButton(tabRivals, "Silent Rivals", "https://raw.githubusercontent.com/KxGOATESQUE/SilentRivals/main/SilentRivals")
createButton(tabRivals, "Aimbot & Visuals", "https://raw.githubusercontent.com/PUSCRIPTS/PINGUIN/refs/heads/main/RivalsV1")
createButton(tabRivals, "Rapid Fire Spinbot & ESP", "https://raw.githubusercontent.com/laeraz/ventures/refs/heads/main/rivals.lua")
createButton(tabRivals, "Triggerbot & Skin Changer", "https://dev-8-bit.pantheonsite.io/scripts/?script=rivalsv3.lua")
createButton(tabRivals, "Auto Farm & Auto Fire", "https://api.luarmor.net/files/v3/loaders/212c1198a1beacf31150a8cf339ba288.lua")
createButton(tabRivals, "Mobile Script", "https://raw.githubusercontent.com/MinimalScriptingService/MinimalRivals/main/rivals.lua")
createButton(tabRivals, "Pi Hub Loader", "https://pi-hub.pages.dev/protected/loader.lua")
createButton(tabRivals, "Tbao Hub Rivals", "https://raw.githubusercontent.com/tbao143/thaibao/main/TbaoHubRivals")
createButton(tabRivals, "Midnight CC", "https://raw.githubusercontent.com/laeraz/midnightcc/main/public.lua")

-- 能力之战
local tabAbilityWars = Window:CreateTab("能力之战")
createButton(tabAbilityWars, "Anti-Aura Anti KnockBack", "https://raw.githubusercontent.com/Sw1ndlerScripts/RobloxScripts/main/AbilityWars.lua")
createButton(tabAbilityWars, "Auto Farm & ESP", "https://raw.githubusercontent.com/castycheat/abilitywars/main/Protected%20(29).lua")
createButton(tabAbilityWars, "Stand Attack Time Reset", "https://gameovers.net/Scripts/Free/Ability%20Wars/stando.lua")
createButton(tabAbilityWars, "Pastebin 2026 Script 4", "https://raw.githubusercontent.com/dizyhvh/rbx_scripts/main/ability_wars.lua")
createButton(tabAbilityWars, "Pastebin 2026 Script 5", "https://raw.githubusercontent.com/Testerhubplayer/Ability-wars/main/Ability_wars.lua")

-- 死亡铁轨
local tabDeadRails = Window:CreateTab("死铁轨")
TX = "TX Script"
Script = "TX自动刷债券V4"
createButton(tabDeadRails, "Auto Bond Auto Win", "https://rawscripts.net/raw/Dead-Rails-Beta-Auto-Bond-Auto-Win-117096")
createButton(tabDeadRails, "刷债券V4", "https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Auto-Bond-V4")

-- 突破点
local tabBreakingPoint = Window:CreateTab("突破点")
createButton(tabBreakingPoint, "Funny Squid Hax", "https://raw.githubusercontent.com/ColdStep2/Breaking-Point-Funny-Squid-Hax/main/Breaking%20Point%20Funny%20Squid%20Hax")
createButton(tabBreakingPoint, "Infinite Credits", "https://raw.githubusercontent.com/IsaaaKK/bp/main/script")
createButton(tabBreakingPoint, "Silent Aim Rapid Throw", "https://raw.githubusercontent.com/1iseo/breaking-point-public/main/main.lua")

-- 自然灾害生存
local tabNDS = Window:CreateTab("自然灾害生存模拟器")
createButton(tabNDS, "Auto Farm God Mode Teleport", "https://raw.githubusercontent.com/73GG/Game-Scripts/main/Natural%20Disaster%20Survival.lua")
createButton(tabNDS, "Auto Farm & Free Balloon", "https://raw.githubusercontent.com/2dgeneralspam1/scripts-and-stuff/master/scripts/LoadstringUjHI6RQpz2o8")
createButton(tabNDS, "Anti-Fall & Anti-Weather", "https://raw.githubusercontent.com/pcallskeleton/RX/refs/heads/main/5.lua")
createButton(tabNDS, "No Fall Damage Anti-Water", "https://raw.githubusercontent.com/H17S32/Tiger_Admin/main/MAIN")
createButton(tabNDS, "Auto Clicker Auto Rebirth", "https://raw.githubusercontent.com/ToraIsMe/ToraIsMe/main/0GrimaceRace")
createButton(tabNDS, "Walkspeed & Gravity", "https://raw.githubusercontent.com/RobloxHackingProject/CHHub/main/CHHub.lua")
createButton(tabNDS, "Teleport to Spawn Map", "https://raw.githubusercontent.com/OneProtocol/Project/main/Loader")
createButton(tabNDS, "Mobile Script", "https://raw.githubusercontent.com/Bac0nh1ck/Scripts/main/NDS_A%5EX")
createButton(tabNDS, "Pastebin 2026 Script 9", "https://raw.githubusercontent.com/9NLK7/93qjoadnlaknwldk/main/main")
createButton(tabNDS, "全员变菜鸟", "https://rawscripts.net/raw/Natural-Disaster-Survival-noob-all-110242")

local tabbrainrot = Window:CreateTab("逃离海啸获得脑红")
createButton(tabbrainrot, "海啸无敌", "https://pastebin.com/raw/Ai5WqH8N")
createButton(tabbrainrot, "kdml hub海啸无敌", "https://raw.githubusercontent.com/kedd063/KdmlScripts/refs/heads/main/EscapeTsunamiForBrainrotsV4")
createButton(tabbrainrot, "Vinzhub海啸无敌", "https://script.vinzhub.com/loader")

-- 疯狂城市
local tabMadCity = Window:CreateTab("疯狂之城")
createButton(tabMadCity, "Ruby Hub", "https://raw.githubusercontent.com/aymarko/deni210/main/MadCity/RubyHub")
createButton(tabMadCity, "Auto Escape & Instant Interact", "https://raw.githubusercontent.com/ProBaconHub/ProBaconGUI/main/Script")
createButton(tabMadCity, "Auto Rob & Money Farm", "https://raw.githubusercontent.com/Cesare0328/my-scripts/main/MCARCH2.lua")
createButton(tabMadCity, "Auto Arrest & Teleport", "https://raw.githubusercontent.com/Deni210/madcity/main/Ruby%20Hub%20v1.1")
createButton(tabMadCity, "Pastebin 2026 Script 6", "https://pastes.io/raw/msc-65172")
createButton(tabMadCity, "Ruby Hub v1", "https://raw.githubusercontent.com/Deni210/madcity/main/Ruby%20Hub")

-- 犯罪生涯
local tabCriminality = Window:CreateTab("犯罪")
createButton(tabCriminality, "Starlightcc Leaked", "https://raw.githubusercontent.com/eradicator2/starlight-criminality/refs/heads/main/source.lua")
createButton(tabCriminality, "Cinality Script", "https://api.junkie-development.de/api/v1/luascripts/public/facbd46e4ae1e8ae608a9a7251682698bfc57ebd39d041d641ad84e483ce017f/download")
createButton(tabCriminality, "Silent Aim Script", "https://api.jnkie.com/api/v1/luascripts/public/1a000c187ed683ea2548d58eea33f6017ab5aa5ca12dec1f53df795ebc088163/download")

-- 咒术师攀登
local tabSorcerer = Window:CreateTab("咒师登顶")
createButton(tabSorcerer, "OP KEYLESS Script", "https://rawscripts.net/raw/RELEASE-Sorcerer-Ascent-SCRIPT-OP-KEYLESS-103228")

-- 大屠杀
local tabMassacre = Window:CreateTab("屠杀者")
createButton(tabMassacre, "BEST SCRIPT MARCH 2026", "https://rawscripts.net/raw/UPD-Massacre-BEST-SCRIPT-MARCH-2026-136108")

-- 崛起交叉
local tabArise = Window:CreateTab("ARISE")
createButton(tabArise, "Speed Hub X", "https://raw.githubusercontent.com/U-ziii/Arise-Crossover/refs/heads/main/MultiFeatureScript.lua")
createButton(tabArise, "Frosties Script", "https://raw.githubusercontent.com/U-ziii/Arise-Crossover/refs/heads/main/ShadowAutomation.lua")
createButton(tabArise, "Auto Dungeon & Mount Farm", "https://raw.githubusercontent.com/U-ziii/Arise-Crossover/refs/heads/main/AutoDungeon.lua")
createButton(tabArise, "Keyless Script", "https://raw.githubusercontent.com/U-ziii/Arise-Crossover/refs/heads/main/KeylessScript.lua")

-- 蓝色监狱
local tabBlueLock = Window:CreateTab("蓝色锁:对手")
createButton(tabBlueLock, "Luarmor Loader", "https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua")
createButton(tabBlueLock, "XZuyaX Hub", "https://raw.githubusercontent.com/XZuuyaX/XZuyaX-s-Hub/refs/heads/main/Main.Lua")
createButton(tabBlueLock, "Aimbot Hub", "https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua")
createButton(tabBlueLock, "Fly Script", "https://raw.githubusercontent.com/Iliankytb/Iliankytb/main/BLRFlyingBall")
createButton(tabBlueLock, "Pastefy Script", "https://pastefy.app/wRGyxNnn/raw")
createButton(tabBlueLock, "Script 6", "https://raw.githubusercontent.com/EnesKam21/bluelock/refs/heads/main/obfuscated%20(2).lua")

-- 森林中的99夜
local tab99Nights = Window:CreateTab("森林中的99夜")
createButton(tab99Nights, "XA脚本", "https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Games/森林中的99夜.lua")
createButton(tab99Nights, "VEX脚本", "https://raw.githubusercontent.com/yoursvexyyy/VEX-OP/refs/heads/main/99%20nights%20in%20the%20forest")
createButton(tab99Nights, "Voidware全能", "https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/nightsintheforest.lua")
createButton(tab99Nights, "刷糖果", "https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FarmCandyFN.lua")
createButton(tab99Nights, "刷钻石", "https://raw.githubusercontent.com/r4mpage4/LuaCom/refs/heads/main/saint.noob")
createButton(tab99Nights, "虚空脚本汉化", "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/99%E5%A4%9C%E8%99%9A%E7%A9%BA.txt")
createButton(tab99Nights, "H4xLoader", "https://raw.githubusercontent.com/H4xScripts/Loader/refs/heads/main/loader.lua")
createButton(tab99Nights, "OP级汉化", "https://raw.githubusercontent.com/hdjsjjdgrhj/script-hub/refs/heads/main/99Nights")
createButton(tab99Nights, "Brone翻译", "https://raw.githubusercontent.com/q639977310-design/-/refs/heads/main/99%E5%A4%9C")
createButton(tab99Nights, "OverHub刷钻石", "https://raw.githubusercontent.com/hellattexyss/autofarmdiamonds/main/overhubaurofarm.lua")

-- 墨水游戏
local tabInk = Window:CreateTab("墨水游戏")
createButton(tabInk, "Voidware", "https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/inkgame.lua")
createButton(tabInk, "Du8汉化", "https://raw.githubusercontent.com/XOTRXONY/INKGAME/main/INKGAMEE.lua")
createButton(tabInk, "XA脚本", "https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Games/墨水游戏.lua")
createButton(tabInk, "Ringta汉化", "https://raw.githubusercontent.com/hdjsjjdgrhj/script-hub/refs/heads/main/Ringta")
createButton(tabInk, "TexRBLlX汉化", "https://raw.githubusercontent.com/hdjsjjdgrhj/script-hub/refs/heads/main/TexRBLlX")
createButton(tabInk, "修复版汉化", "https://raw.githubusercontent.com/hdjsjjdgrhj/OK/refs/heads/main/sb")
createButton(tabInk, "免费会员", "https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/windinkgame.lua")
createButton(tabInk, "AX最新版", "https://officialaxscripts.vercel.app/scripts/AX-Loader.lua")
createButton(tabInk, "AX汉化版", "https://raw.githubusercontent.com/hdjsjjdgrhj/script-hub/refs/heads/main/AX%20CN")
createButton(tabInk, "防踢加载器", "https://raw.githubusercontent.com/S-WTB/-/refs/heads/main/WTB%E5%8A%A0%E8%BD%BD%E5%99%A8")
createButton(tabInk, "早川秋汉化", "https://raw.githubusercontent.com/MTHNBBN666/ZCQNB/refs/heads/main/obfuscated_script-1758110200696.lua")

-- 俄亥俄州
local tabOhio = Window:CreateTab("俄亥俄州")
createButton(tabOhio, "Visurus", "https://scripts.visurus.dev/ohio/source")
createButton(tabOhio, "XA脚本", "https://raw.githubusercontent.com/XingFork/Scripts/refs/heads/main/Ohio")
createButton(tabOhio, "Pastebin脚本", "https://pastebin.com/raw/hkvHeHed")
createButton(tabOhio, "VoidX Hub (无密钥)", "https://raw.githubusercontent.com/coldena/voidhuba/refs/heads/main/voidhubload")
createButton(tabOhio, "Illicit Hub (无密钥)", "https://gist.githubusercontent.com/iltmita/bae56642c39cbaab2e9acdf5cf909585/raw")
createButton(tabOhio, "Sunexn Hub (自动农场)", "https://raw.githubusercontent.com/sunexn/ohio./main/ohio.lua")
createButton(tabOhio, "rxn-xyz 脚本", "https://raw.githubusercontent.com/rxn-xyz/Ohio./main/Ohio.lua")
createButton(tabOhio, "AlphaOhio", "https://raw.githubusercontent.com/scriptpastebin/raw/main/AlphaOhio")
createButton(tabOhio, "Pastebin 2026", "https://pastebin.com/raw/GUmp28kq")
-- SCP角色扮演
local tabSCP = Window:CreateTab("SCP角色扮演")
createButton(tabSCP, "NullZen", "https://raw.githubusercontent.com/axleoislost/NullZen/main/Scp-Roleplay")
createButton(tabSCP, "VoidPath", "https://raw.githubusercontent.com/voidpathhub/VoidPath/refs/heads/main/VoidPath.luau")
createButton(tabSCP, "Magnesium", "https://raw.githubusercontent.com/Bodzio21/Magnesium/refs/heads/main/Loader")
createButton(tabSCP, "M416", "https://raw.githubusercontent.com/xiaoSB33/M416/refs/heads/main/Wind/sb/SCP角色扮演")

-- 河北唐县
local tabTang = Window:CreateTab("河北唐县")
createButton(tabTang, "自动农场", "https://raw.githubusercontent.com/Sw1ndlerScripts/RobloxScripts/main/Tang%20Country.lua")

-- 活到七天
local tab7Days = Window:CreateTab("活到七天")
createButton(tab7Days, "自动脚本", "https://raw.githubusercontent.com/zamzamzan/test/refs/heads/main/7days")

-- 被遗弃
local tabAbandoned = Window:CreateTab("被遗弃")
createButton(tabAbandoned, "陈某汉化", "https://raw.githubusercontent.com/qazwsx422/Je/26ab7022f3767d471f2fbb3d67e0683f0c13a55a/%E8%A2%AB%E9%81%97%E5%BC%83")

-- 通用脚本
local tabDoors = Window:CreateTab("Doors")
createButton(tabDoors, "Vynixius菜单", "https://raw.githubusercontent.com/RegularVynixu/Vynixius/main/Doors/Script.lua")

local tab3008 = Window:CreateTab("SCP-3008")
createButton(tab3008, "Antex脚本", "https://raw.githubusercontent.com/Viserromero/Antex/master/SCP3008")

-- 51区
local tabArea51 = Window:CreateTab("51区")
createButton(tabArea51, "STK菜单v7", "https://raw.githubusercontent.com/Ghostmode65/STK-Bo2/master/STK-Menus/v7/STv7-Engine.txt")

local tabDontPress = Window:CreateTab("不要按第4按But")
createButton(tabDontPress, "EEWE脚本", "https://raw.githubusercontent.com/imaboy12321/EEWE/main/eweweew")

-- 彩虹朋友
local tabRainbow = Window:CreateTab("彩虹朋友")
createButton(tabRainbow, "BorkWare", "https://raw.githubusercontent.com/Ihaveash0rtnamefordiscord/BorkWare/main/Scripts/" .. game.GameId .. ".lua")

-- 点击模拟器
local tabClick = Window:CreateTab("点击模拟器")
createButton(tabClick, "Kederal脚本", "https://raw.githubusercontent.com/Kederal/script.gg/main/loader.lua")

-- 动感星期五
local tabFunky = Window:CreateTab("动感星期五")
createButton(tabFunky, "自动演奏", "https://raw.githubusercontent.com/wally-rblx/funky-friday-autoplay/main/main.lua")

-- 动物模拟器
local tabAnimal = Window:CreateTab("动物模拟器")
createButton(tabAnimal, "牛逼脚本", "\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\112\101\116\105\116\101\98\97\114\116\101\47\109\101\110\117\47\109\97\105\110\47\77\101\110\117")

-- 极速传奇
local tabSpeed = Window:CreateTab("极速传奇")
createButton(tabSpeed, "无限经验", "https://pastebin.com/raw/9KWQXasx")

-- 僵尸起义/进击的僵尸
local tabZombie = Window:CreateTab("僵尸起义")
createButton(tabZombie, "xSyon引擎", "https://raw.githubusercontent.com/xSyon/ZombieAttack/main/engine.lua")
createButton(tabZombie, "Darkrai X", "https://raw.githubusercontent.com/GamingScripter/Darkrai-X/main/Games/Zombie%20Attack")

-- 捐赠游戏 Pls Donate
local tabDonate = Window:CreateTab("请捐赠")
createButton(tabDonate, "自动农场", "https://raw.githubusercontent.com/heqds/Pls-Donate-Auto-Farm-Script/main/plsdonate.lua")

-- 克隆大亨
local tabClone = Window:CreateTab("克隆大亨")
createButton(tabClone, "CT-Destroyer", "https://raw.githubusercontent.com/HELLLO1073/RobloxStuff/main/CT-Destroyer")

-- 汽车经营大亨
local tabCar = Window:CreateTab("Car Dealership Tycoon")
createButton(tabCar, "BlueLock脚本", "https://raw.githubusercontent.com/03sAlt/BlueLockSeason2/main/README.md")

-- YBA (Your Bizarre Adventure)
local tabYBA = Window:CreateTab("你的怪异冒险")
createButton(tabYBA, "NukeVsCity脚本", "https://raw.githubusercontent.com/NukeVsCity/hackscript123/main/gui")

-- The Rake
local tabRake = Window:CreateTab("割草机")
createButton(tabRake, "jFn0k6Gz脚本", "https://pastebin.com/raw/jFn0k6Gz")

-- RIU (Roblox Is Unbreakable)
local tabRIU = Window:CreateTab("Roblox是坚不可摧的")
createButton(tabRIU, "无限等级+钱", "https://raw.githubusercontent.com/MorikTV/Roblox-is-Unbreakable/main/Unbreakable.lua")

-- Nico's Nextbots
local tabNico = Window:CreateTab("Nico的下一个机器人")
createButton(tabNico, "aBPrm1vk脚本", "\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\97\66\80\114\109\49\118\107")

local tabLuckyBlock = Window:CreateTab("幸运方块")
createButton(tabLuckyBlock, "Auto Special Collect", "https://pastebin.com/raw/0xzxLuckyBlock")

-- 54. Booga Booga
local tabBooga = Window:CreateTab("Booga Booga")
createButton(tabBooga, "Nebula Hub", "https://raw.githubusercontent.com/Yousuck780/Nebula-Hub/refs/heads/main/boogaboogareborn")
createButton(tabBooga, "Aimbot Hub", "https://api.luarmor.net/files/v4/loaders/3e1fa137895b569a24c95af2bd79b5d8.lua")
createButton(tabBooga, "LuminaProject", "https://raw.githubusercontent.com/LuminaProject/Boooga-Booga/refs/heads/main/main.lua")
createButton(tabBooga, "SunSetV1", "https://raw.githubusercontent.com/Fominkal/NeverHook-2.0/refs/heads/main/SunSetV1_BoogaBooga")

-- 55. Don't Wake the Brainrots
local tabBrainrotslol = Window:CreateTab("别叫醒脑袋!")
createButton(tabBrainrotslol, "Auto Collect Money", "https://raw.githubusercontent.com/gumanba/Scripts/main/DontWaketheBrainrots")
createButton(tabBrainrotslol, "Teleport Brainrot", "https://raw.githubusercontent.com/VylikGylik/Script/refs/heads/main/Don't%20Wake%20the%20Brainrots")
createButton(tabBrainrotslol, "Free Admin Panel", "https://cdn.authguard.org/virtual-file/96959c041820452fb07cbdd94754dcd7")
createButton(tabBrainrotslol, "Auto Safe Place", "https://raw.githubusercontent.com/tls123account/StarStream/refs/heads/main/Hub")
createButton(tabBrainrotslol, "StarStream Hub", "https://raw.githubusercontent.com/starstreamowner/StarStream/refs/heads/main/Hub")
createButton(tabBrainrotslol, "Pastefy Script", "https://pastefy.app/7zBptI7A/raw")
createButton(tabBrainrotslol, "Karbid Script", "https://raw.githubusercontent.com/karbid-dev/Karbid/main/zpp0kogh0t")

-- 56. Survive Bikini Bottom
local tabBikini = Window:CreateTab("生存比基尼底裤")
createButton(tabBikini, "Morning Hub", "https://raw.githubusercontent.com/U-ziii/Survive-Bikini-Bottom/refs/heads/main/Teleports.lua")
createButton(tabBikini, "Instant Open Chests", "https://raw.githubusercontent.com/U-ziii/Survive-Bikini-Bottom/refs/heads/main/FastRewardsScript.lua")
createButton(tabBikini, "Auto Kill & Craft", "https://raw.githubusercontent.com/U-ziii/Survive-Bikini-Bottom/refs/heads/main/AutoKill.lua")
createButton(tabBikini, "SpiderHUB Beta", "https://raw.githubusercontent.com/U-ziii/Survive-Bikini-Bottom/refs/heads/main/SmoothESP.lua")
createButton(tabBikini, "Sponge Hub", "https://raw.githubusercontent.com/U-ziii/Survive-Bikini-Bottom/refs/heads/main/NoKey.lua")

-- 57. Color or Die
local tabColorDie = Window:CreateTab("颜色或死亡")
createButton(tabColorDie, "41kstacks", "https://raw.githubusercontent.com/SkibidiCen/MainMenu/main/Code")
createButton(tabColorDie, "Vex Hub", "https://raw.githubusercontent.com/VexHubOfficial/VexHub-GAMES/refs/heads/main/Color%20or%20Die")
createButton(tabColorDie, "EmberHub", "https://raw.githubusercontent.com/scripter66/EmberHub/refs/heads/main/ColorOrDie.lua")
local tabDrawMe = Window:CreateTab("画我")
createButton(tabDrawMe, "Kenny脚本", "https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/KENNY画我.lua")
Rayfield:Notify({Title = "加载成功！", Content = "欢迎使用91缝合脚本！", Duration = 5})
end
