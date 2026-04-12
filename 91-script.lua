--local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
local Window = Rayfield:CreateWindow({
   Name = "91混合脚本 v1.0",
   LoadingTitle = "91混合脚本 | 脚本加载中...",
   LoadingSubtitle = "v1.0",
   ConfigurationSaving = { Enabled = true, FolderName = "91_Amogus_v1" }
})

-- 核心服务
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

----------------------------------------------------------------
-- 1. 首页
----------------------------------------------------------------
local welcometab = Window:CreateTab("首页", 4483362458)
welcometab:CreateLabel("欢迎使用 91混合脚本 v1.0！")
welcometab:CreateLabel("服务器功能有的可能需要卡密，有的已经失效，大部分没测试")
welcometab:CreateLabel("→脚本功能在右边→")
welcometab:CreateLabel("用户名:"..game.Players.LocalPlayer.Name)
welcometab:CreateLabel("服务器的ID:"..game.GameId)
local hubtab = Window:CreateTab("通用", 4483362458)

-- 系统工具
hubtab:CreateSection("系统工具")
hubtab:CreateButton({
   Name = "重新加入",
   Callback = function() TeleportService:Teleport(game.PlaceId, Plr) end,
})
hubtab:CreateButton({
   Name = "清理内存/减少卡顿",
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
hubtab:CreateSection("物理功能")
hubtab:CreateToggle({
   Name = "飞行",
   CurrentValue = false,
   Callback = function(state)
      if state then
          local char = game.Players.LocalPlayer.Character
          if not char then
              notify("飞行", "未检测到角色，无法开启飞行")
              return
          end
          States.Flying = true
          local root = char.HumanoidRootPart
          local hum = char.Humanoid
          hum.PlatformStand = true
          bg = Instance.new("BodyGyro", root)
          bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
          bv = Instance.new("BodyVelocity", root)
          bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
          flyConn = game:GetService("RunService").RenderStepped:Connect(function()
              local cam = workspace.CurrentCamera
              bv.velocity = (hum.MoveDirection.Magnitude > 0) and (hum.MoveDirection * FlySpeed) or Vector3.new(0, 0, 0)
              bg.cframe = cam.CFrame
          end)
      else
          States.Flying = false
          if flyConn then flyConn:Disconnect() end
          if bv then bv:Destroy() end
          if bg then bg:Destroy() end
          if game.Players.LocalPlayer.Character then 
              game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false 
          end
      end
   end,
})
hubtab:CreateSlider({
   Name = "飞行速度",
   Range = {10, 500},
   Increment = 10,
   CurrentValue = 50,
   Callback = function(v) FlySpeed = v end,
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
   Name = "无跌落伤害/无敌",
   CurrentValue = false,
   Callback = function(v) 
      -- 简单实现：每帧重置健康值
      _G.NoFallConn = game:GetService("RunService").RenderStepped:Connect(function()
          local char = game.Players.LocalPlayer.Character
          if char and char:FindFirstChild("Humanoid") then
              char.Humanoid.BreakJointsOnDeath = false
              char.Humanoid.Health = char.Humanoid.MaxHealth
          end
      end)
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
hubtab:CreateToggle({
   Name = "自动旋转 (Spin)",
   CurrentValue = false,
   Callback = function(v)
      States.Spinning = v
      if v then
      end
      task.spawn(function()
          while States.Spinning do
              if game.Players.LocalPlayer.Character then
                  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(SpinSpeed), 0)
              end
              task.wait()
          end
      end)
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
hubtab:CreateButton({
   Name = "隐身",
   Callback = function()
      -- Objects

local GUI = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Topbar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Exit = Instance.new("TextButton")
local Minimize = Instance.new("TextButton")
local SubFrame = Instance.new("Frame")
local AirTP = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local TextLabel_2 = Instance.new("TextLabel")
local BoolToggle = Instance.new("TextButton")
local AutoRun = Instance.new("Frame")
local TextLabel_3 = Instance.new("TextLabel")
local TextLabel_4 = Instance.new("TextLabel")
local BoolToggle_2 = Instance.new("TextButton")
local Keybind = Instance.new("Frame")
local TextLabel_5 = Instance.new("TextLabel")
local TextLabel_6 = Instance.new("TextLabel")
local CurrentBind = Instance.new("TextBox")
local QuickInvis = Instance.new("TextButton")
local Rigtype = Instance.new("TextLabel")
local TextButton = Instance.new("TextButton")

-- Properties

GUI.Name = "GUI"
GUI.Parent = game.CoreGui

Main.Name = "Main"
Main.Parent = GUI
Main.Active = true
Main.BackgroundColor3 = Color3.new(0, 0, 0)
Main.BackgroundTransparency = 0.5
Main.BorderSizePixel = 0
Main.Draggable = true
Main.Position = UDim2.new(0.318181813, 0, 0.312252969, 0)
Main.Size = UDim2.new(0.363636374, 0, 0.375494063, 0)

Topbar.Name = "Topbar"
Topbar.Parent = Main
Topbar.BackgroundColor3 = Color3.new(0, 0, 0)
Topbar.BackgroundTransparency = 0.9990000128746
Topbar.Size = UDim2.new(1, 0, 0.163157895, 0)

Title.Name = "Title"
Title.Parent = Topbar
Title.BackgroundColor3 = Color3.new(0, 0, 0)
Title.BackgroundTransparency = 0.9990000128746
Title.Size = UDim2.new(0.784722209, 0, 1, 0)
Title.Font = Enum.Font.SciFi
Title.FontSize = Enum.FontSize.Size14
Title.Text = "隐身脚本"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14

Exit.Name = "Exit"
Exit.Parent = Topbar
Exit.BackgroundColor3 = Color3.new(0, 0, 0)
Exit.BackgroundTransparency = 0.9990000128746
Exit.Position = UDim2.new(0.892361104, 0, 0, 0)
Exit.Size = UDim2.new(0.107638888, 0, 1, 0)
Exit.Font = Enum.Font.SciFi
Exit.FontSize = Enum.FontSize.Size14
Exit.Text = "X"
Exit.TextColor3 = Color3.new(1, 1, 1)
Exit.TextSize = 14

Minimize.Name = "Minimize"
Minimize.Parent = Topbar
Minimize.BackgroundColor3 = Color3.new(0, 0, 0)
Minimize.BackgroundTransparency = 0.9990000128746
Minimize.Position = UDim2.new(0.784722209, 0, 0, 0)
Minimize.Size = UDim2.new(0.107638888, 0, 1, 0)
Minimize.Font = Enum.Font.SciFi
Minimize.FontSize = Enum.FontSize.Size14
Minimize.Text = "-"
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.TextSize = 14

SubFrame.Name = "SubFrame"
SubFrame.Parent = Main
SubFrame.BackgroundColor3 = Color3.new(0, 0, 0)
SubFrame.BackgroundTransparency = 0.5
SubFrame.BorderSizePixel = 0
SubFrame.Position = UDim2.new(0, 0, 0.163157895, 0)
SubFrame.Size = UDim2.new(1, 0, 0.83684212, 0)

AirTP.Name = "AirTP"
AirTP.Parent = SubFrame
AirTP.BackgroundColor3 = Color3.new(0, 0, 0)
AirTP.BackgroundTransparency = 0.9990000128746
AirTP.BorderSizePixel = 0
AirTP.Position = UDim2.new(0, 0, 0.0628930852, 0)
AirTP.Size = UDim2.new(1, 0, 0.176100627, 0)

TextLabel.Parent = AirTP
TextLabel.BackgroundColor3 = Color3.new(0, 0, 0)
TextLabel.BackgroundTransparency = 0.9990000128746
TextLabel.Position = UDim2.new(0.166666672, 0, 0, 0)
TextLabel.Size = UDim2.new(0.284722209, 0, 1, 0)
TextLabel.Font = Enum.Font.SciFi
TextLabel.FontSize = Enum.FontSize.Size14
TextLabel.Text = "空气"
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextSize = 14
TextLabel.TextXAlignment = Enum.TextXAlignment.Left

TextLabel_2.Parent = AirTP
TextLabel_2.BackgroundColor3 = Color3.new(0, 0, 0)
TextLabel_2.BackgroundTransparency = 0.9990000128746
TextLabel_2.Position = UDim2.new(0.451388896, 0, 0, 0)
TextLabel_2.Size = UDim2.new(0.0972222239, 0, 1, 0)
TextLabel_2.Font = Enum.Font.SciFi
TextLabel_2.FontSize = Enum.FontSize.Size14
TextLabel_2.Text = "-"
TextLabel_2.TextColor3 = Color3.new(1, 1, 1)
TextLabel_2.TextSize = 14

BoolToggle.Name = "BoolToggle"
BoolToggle.Parent = AirTP
BoolToggle.BackgroundColor3 = Color3.new(0.207843, 1, 0.392157)
BoolToggle.BackgroundTransparency = 0.5
BoolToggle.BorderSizePixel = 0
BoolToggle.Position = UDim2.new(0.784722209, 0, 0, 0)
BoolToggle.Size = UDim2.new(0.215277776, 0, 1, 0)
BoolToggle.Font = Enum.Font.SciFi
BoolToggle.FontSize = Enum.FontSize.Size14
BoolToggle.Text = "开启"
BoolToggle.TextColor3 = Color3.new(1, 1, 1)
BoolToggle.TextSize = 14

AutoRun.Name = "AutoRun"
AutoRun.Parent = SubFrame
AutoRun.BackgroundColor3 = Color3.new(0, 0, 0)
AutoRun.BackgroundTransparency = 0.9990000128746
AutoRun.Position = UDim2.new(0, 0, 0.238993704, 0)
AutoRun.Size = UDim2.new(1, 0, 0.176100627, 0)

TextLabel_3.Parent = AutoRun
TextLabel_3.BackgroundColor3 = Color3.new(0, 0, 0)
TextLabel_3.BackgroundTransparency = 0.9990000128746
TextLabel_3.Position = UDim2.new(0.166666672, 0, 0, 0)
TextLabel_3.Size = UDim2.new(0.284722209, 0, 1, 0)
TextLabel_3.Font = Enum.Font.SciFi
TextLabel_3.FontSize = Enum.FontSize.Size14
TextLabel_3.Text = "自动运行"
TextLabel_3.TextColor3 = Color3.new(1, 1, 1)
TextLabel_3.TextSize = 14
TextLabel_3.TextXAlignment = Enum.TextXAlignment.Left

TextLabel_4.Parent = AutoRun
TextLabel_4.BackgroundColor3 = Color3.new(0, 0, 0)
TextLabel_4.BackgroundTransparency = 0.9990000128746
TextLabel_4.Position = UDim2.new(0.451388896, 0, 0, 0)
TextLabel_4.Size = UDim2.new(0.0972222239, 0, 1, 0)
TextLabel_4.Font = Enum.Font.SciFi
TextLabel_4.FontSize = Enum.FontSize.Size14
TextLabel_4.Text = "-"
TextLabel_4.TextColor3 = Color3.new(1, 1, 1)
TextLabel_4.TextSize = 14

BoolToggle_2.Name = "BoolToggle"
BoolToggle_2.Parent = AutoRun
BoolToggle_2.BackgroundColor3 = Color3.new(0.207843, 1, 0.392157)
BoolToggle_2.BackgroundTransparency = 0.5
BoolToggle_2.BorderSizePixel = 0
BoolToggle_2.Position = UDim2.new(0.784722209, 0, 0, 0)
BoolToggle_2.Size = UDim2.new(0.215277776, 0, 1, 0)
BoolToggle_2.Font = Enum.Font.SciFi
BoolToggle_2.FontSize = Enum.FontSize.Size14
BoolToggle_2.Text = "开启"
BoolToggle_2.TextColor3 = Color3.new(1, 1, 1)
BoolToggle_2.TextSize = 14

Keybind.Name = "Keybind"
Keybind.Parent = SubFrame
Keybind.BackgroundColor3 = Color3.new(0, 0, 0)
Keybind.BackgroundTransparency = 0.9990000128746
Keybind.Position = UDim2.new(0, 0, 0.415094346, 0)
Keybind.Size = UDim2.new(1, 0, 0.176100627, 0)

TextLabel_5.Parent = Keybind
TextLabel_5.BackgroundColor3 = Color3.new(0, 0, 0)
TextLabel_5.BackgroundTransparency = 0.9990000128746
TextLabel_5.Position = UDim2.new(0.166666672, 0, 0, 0)
TextLabel_5.Size = UDim2.new(0.284722209, 0, 1, 0)
TextLabel_5.Font = Enum.Font.SciFi
TextLabel_5.FontSize = Enum.FontSize.Size14
TextLabel_5.Text = "键绑定"
TextLabel_5.TextColor3 = Color3.new(1, 1, 1)
TextLabel_5.TextSize = 14
TextLabel_5.TextXAlignment = Enum.TextXAlignment.Left

TextLabel_6.Parent = Keybind
TextLabel_6.BackgroundColor3 = Color3.new(0, 0, 0)
TextLabel_6.BackgroundTransparency = 0.9990000128746
TextLabel_6.Position = UDim2.new(0.451388896, 0, 0, 0)
TextLabel_6.Size = UDim2.new(0.0972222239, 0, 1, 0)
TextLabel_6.Font = Enum.Font.SciFi
TextLabel_6.FontSize = Enum.FontSize.Size14
TextLabel_6.Text = "-"
TextLabel_6.TextColor3 = Color3.new(1, 1, 1)
TextLabel_6.TextSize = 14

CurrentBind.Name = "CurrentBind"
CurrentBind.Parent = Keybind
CurrentBind.BackgroundColor3 = Color3.new(0.262745, 0.964706, 1)
CurrentBind.BackgroundTransparency = 0.5
CurrentBind.BorderSizePixel = 0
CurrentBind.Position = UDim2.new(0.784722209, 0, 0, 0)
CurrentBind.Size = UDim2.new(0.215277776, 0, 1, 0)
CurrentBind.Font = Enum.Font.SciFi
CurrentBind.FontSize = Enum.FontSize.Size14
CurrentBind.Text = "i"
CurrentBind.TextColor3 = Color3.new(1, 1, 1)
CurrentBind.TextSize = 14

QuickInvis.Name = "QuickInvis"
QuickInvis.Parent = SubFrame
QuickInvis.BackgroundColor3 = Color3.new(1, 0.227451, 0.227451)
QuickInvis.BackgroundTransparency = 0.5
QuickInvis.BorderSizePixel = 0
QuickInvis.Position = UDim2.new(0, 0, 0.823899388, 0)
QuickInvis.Size = UDim2.new(1, 0, 0.176100627, 0)
QuickInvis.Font = Enum.Font.SciFi
QuickInvis.FontSize = Enum.FontSize.Size14
QuickInvis.Text = "开启隐身"
QuickInvis.TextColor3 = Color3.new(1, 1, 1)
QuickInvis.TextSize = 14

Rigtype.Name = "Rigtype"
Rigtype.Parent = SubFrame
Rigtype.BackgroundColor3 = Color3.new(0, 0, 0)
Rigtype.BackgroundTransparency = 0.69999998807907
Rigtype.BorderSizePixel = 0
Rigtype.Position = UDim2.new(0, 0, 0.647798777, 0)
Rigtype.Size = UDim2.new(1, 0, 0.176100627, 0)
Rigtype.Font = Enum.Font.SciFi
Rigtype.FontSize = Enum.FontSize.Size14
Rigtype.Text = "阿龙改编"
Rigtype.TextColor3 = Color3.new(1, 1, 1)
Rigtype.TextSize = 14

TextButton.Parent = GUI
TextButton.BackgroundColor3 = Color3.new(0, 0, 0)
TextButton.BackgroundTransparency = 0.5
TextButton.BorderSizePixel = 0
TextButton.Position = UDim2.new(0.0265151523, 0, 0.865612626, 0)
TextButton.Size = UDim2.new(0.0606060624, 0, 0.0948616564, 0)
TextButton.Font = Enum.Font.SciFi
TextButton.FontSize = Enum.FontSize.Size14
TextButton.Text = "打开"
TextButton.TextColor3 = Color3.new(1, 1, 1)
TextButton.TextSize = 14

local Player   = game:GetService('Players').LocalPlayer
local Mouse    = Player:GetMouse()

local AutoRun  = true
local AirTP    = true
local Keybind  = 'i'

local Green    = Color3.fromRGB(53, 255, 100)
local Red      = Color3.fromRGB(255, 58, 58)

local function CheckRig()
   if Player.Character then
       local Humanoid = Player.Character:WaitForChild('Humanoid')
       if Humanoid.RigType == Enum.HumanoidRigType.R15 then
           return 'R15'
       else
           return 'R6'
       end
   end
end

local function InitiateInvis()
   local Character = Player.Character
   local StoredCF = Character.PrimaryPart.CFrame
   if AirTP then
       local Part = Instance.new('Part',workspace)
       Part.Size = Vector3.new(5,0,5)
       Part.Anchored = true
       Part.CFrame = CFrame.new(Vector3.new(9999,9999,9999))
       Character.PrimaryPart.CFrame = Part.CFrame*CFrame.new(0,3,0)
       spawn(function()
           wait(3)
           Part:Destroy()
       end)
   end
   if CheckRig() == 'R6' then
       local Clone = Character.HumanoidRootPart:Clone()
       Character.HumanoidRootPart:Destroy()
       Clone.Parent = Character
   else
       local Clone = Character.LowerTorso.Root:Clone()
       Character.LowerTorso.Root:Destroy()
       Clone.Parent = Character.LowerTorso
   end
   if AirTP then
       wait(1)
       Character.PrimaryPart.CFrame = StoredCF
   end
end

local function OnCharacterAdded()
   SubFrame.Rigtype.Text = ('Your Rigtype - %s'):format(CheckRig())
   if AutoRun then
       InitiateInvis()
   end
end

local function OnButtonPress(Button)
   if Button == Keybind:lower() then
       InitiateInvis()
   end
end

local function OnGoInvisPress()
   InitiateInvis()
end

local function OnKeyBindTextChange()
   local cb = SubFrame.Keybind.CurrentBind
   if cb.Text:match('%w') then
       Keybind = cb.Text:match('%w'):lower()
       cb.Text = Keybind
   elseif cb.Text ~= '' then
       Keybind = 'i'
       cb.Text = Keybind
   end
   print(Keybind)
end

local function OnAutoRunPress()
   local Ar = SubFrame.AutoRun.BoolToggle
   if AutoRun then
       Ar.BackgroundColor3 = Red
       Ar.Text = tostring(not AutoRun)
       AutoRun = false
   else
       Ar.BackgroundColor3 = Green
       Ar.Text = tostring(not AutoRun)
       AutoRun = true
   end
end

local function OnAirTPPress()
   local ATP = SubFrame.AirTP.BoolToggle
   if AirTP then
       ATP.BackgroundColor3 = Red
       ATP.Text = tostring(false)
       AirTP = false
   else
       ATP.BackgroundColor3 = Green
       ATP.Text = tostring(true)
       AirTP = true
   end
end

local function OnMinimizePress()
   Main.Visible = false
   GUI.TextButton.Visible = true
end

local function OnOpenPress()
   Main.Visible = true
   GUI.TextButton.Visible = false
end

local function OnClosePress()
   GUI:Destroy()
end

SubFrame.Keybind.CurrentBind:GetPropertyChangedSignal('Text'):connect(OnKeyBindTextChange)
Mouse.KeyDown:connect(OnButtonPress)
SubFrame.AutoRun.BoolToggle.MouseButton1Down:connect(OnAutoRunPress)
SubFrame.AirTP.BoolToggle.MouseButton1Down:connect(OnAirTPPress)
Main.Topbar.Minimize.MouseButton1Down:connect(OnMinimizePress)
GUI.TextButton.MouseButton1Down:connect(OnOpenPress)
Main.Topbar.Exit.MouseButton1Down:connect(OnClosePress)
SubFrame.QuickInvis.MouseButton1Down:connect(OnGoInvisPress)
Player.CharacterAdded:connect(OnCharacterAdded)

SubFrame.Rigtype.Text = ('Your Rigtype - %s'):format(CheckRig())
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

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local function rm()
	for i,v in pairs(Character:GetDescendants()) do
		if v:IsA("BasePart") then
			if v.Name ~= "Head" then
				for i,cav in pairs(v:GetDescendants()) do
					if cav:IsA("Attachment") then
						if cav:FindFirstChild("OriginalPosition") then
							cav.OriginalPosition:Destroy()
						end
					end
				end
				v:FindFirstChild("OriginalSize"):Destroy()
				if v:FindFirstChild("AvatarPartScaleType") then
					v:FindFirstChild("AvatarPartScaleType"):Destroy()
				end
			end
		end
	end
end

rm()
wait(0.5)
Humanoid:FindFirstChild("BodyTypeScale"):Destroy()
wait(0.2)

rm()
wait(0.5)
Humanoid:FindFirstChild("BodyWidthScale"):Destroy()
wait(0.2)

rm()
wait(0.5)
Humanoid:FindFirstChild("BodyDepthScale"):Destroy()
wait(0.2)

rm()
wait(0.5)
Humanoid:FindFirstChild("HeadScale"):Destroy()
wait(0.2)
   end,
})
createButton(hubtab, "后门执行器汉化", "https://raw.githubusercontent.com/pijiaobenMSJMleng/backdoor/refs/heads/main/backdoor.lua")
createButton(hubtab, "C00lgui FE脚本中心", "https://raw.githubusercontent.com/yourrepo/c00lgui.lua") -- 注意原脚本需特殊处理，此处暂用占位，实际可改为直接执行获取的代码
createButton(hubtab, "cccccsnngbydxh f3x gui", "https://raw.githubusercontent.com/cccccsnngbydxh/my-gui/5ecdf34fd58c9db3f4a65a27f4c747cc88838392/gui.lua")
createButton(hubtab, "黄色动作", "https://pastebin.com/raw/ZfaM6tNg")
createButton(hubtab, "通用Rayfield Hub", "https://rawscripts.net/raw/Universal-Script-Universal-Rayfield-Hub-134340")

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

-- 7. 强制第一人称
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

-- ==================== 进阶通用脚本（带检测提醒） ====================
hubtab:CreateSection("进阶通用功能")

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
local centerTab = Window:CreateTab("脚本中心", 4483362458)

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
local toolsTab = Window:CreateTab("工具脚本", 4483362458)

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

local lt2Tab = Window:CreateTab("伐木大亨2", 4483362458)
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
local tabBloxFruits = Window:CreateTab("blox fruits", 4483362458)
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
local tabPetSim99 = Window:CreateTab("宠物模拟器99", 4483362458)
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
local tabSlapBattles = Window:CreateTab("打屁股大战", 4483362458)
createButton(tabSlapBattles, "Pastebin 2026 Script 1", "https://raw.githubusercontent.com/rblxscriptsnet/unfair/main/rblxhub.lua")
createButton(tabSlapBattles, "Pastebin 2026 Script 2", "https://raw.githubusercontent.com/Giangplay/Slap_Battles/main/Slap_Battles.lua")
createButton(tabSlapBattles, "Pastebin 2026 Script 3", "https://raw.githubusercontent.com/Bilmemi/bestaura/main/semihu803")
createButton(tabSlapBattles, "Pastebin 2026 Script 4", "https://raw.githubusercontent.com/dizyhvh/slap_battles_gui/main/0.lua")

-- 起床战争
local tabBedWars = Window:CreateTab("起床战争", 4483362458)
createButton(tabBedWars, "Auto Click & Kill Aura", "https://gist.githubusercontent.com/DeveloperMikey/2b8ee3d5a38c56c2cc1db72554850384/raw/bedwar.lua")
createButton(tabBedWars, "Infinite Jump Fly & Sprint", "https://raw.githubusercontent.com/GamerScripter/Game-Hub/main/loader")
createButton(tabBedWars, "VapeV4 GUI", "https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua")
createButton(tabBedWars, "Crokuranu UI", "https://raw.githubusercontent.com/SlaveDash/Crokuranu/main/Bedwars%20UI%20Source%20Code")
createButton(tabBedWars, "Monkey Script", "https://raw.githubusercontent.com/KuriWasTaken/MonkeyScripts/main/BedWarsMonkey.lua")

-- 谋杀之谜2
local tabMM2 = Window:CreateTab("谋杀之谜2", 4483362458)
createButton(tabMM2, "Eclipse Hub", "https://raw.githubusercontent.com/Doggo-cryto/EclipseMM2/master/Script")
createButton(tabMM2, "Silent Aim & Kill All", "https://rentry.co/xzdu8wnm/raw")
createButton(tabMM2, "Rogue Hub", "https://raw.githubusercontent.com/Kitzoon/Rogue-Hub/main/Main.lua")
createButton(tabMM2, "Aimbot Script", "https://rentry.co/hb89aoq2/raw")
createButton(tabMM2, "Alchemy Hub", "https://luable.netlify.app/AlchemyHub/Luncher.script")
createButton(tabMM2, "Auto Farm MM2 Mobile", "https://raw.githubusercontent.com/NoCapital2/MM2Autofarm/main/script")
createButton(tabMM2, "Auto Farm & Coin Farm", "https://raw.githubusercontent.com/KidichiHB/Kidachi/main/Scripts/MM2")

-- 军械库
local tabArsenal = Window:CreateTab("军械库", 4483362458)
createButton(tabArsenal, "Tbao Hub Arsenal", "https://raw.githubusercontent.com/tbao143/thaibao/main/TbaoHubArsenal")
createButton(tabArsenal, "Owl Hub", "https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt")
createButton(tabArsenal, "Script 3", "https://raw.githubusercontent.com/cris123452/my/main/cas")
createButton(tabArsenal, "Quotas Hub", "https://raw.githubusercontent.com/Insertl/QuotasHub/main/BETAv1.3")
createButton(tabArsenal, "Strike Hub", "https://raw.githubusercontent.com/ccxmIcal/cracks/main/strikehub.lua")
createButton(tabArsenal, "V.G-Hub", "https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub")

-- 神道生活
local tabShindo = Window:CreateTab("神道生活", 4483362458)
createButton(tabShindo, "Project Nexus", "https://raw.githubusercontent.com/IkkyyDF/ProjectNexus/main/Loader.lua")
createButton(tabShindo, "Premier X", "https://raw.githubusercontent.com/SxnwDev/Premier/main/Free-Premier.lua")
createButton(tabShindo, "V.G-Hub", "https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub")
createButton(tabShindo, "SpyHub", "https://raw.githubusercontent.com/Corrupt2625/Revamps/main/SpyHub.lua")
createButton(tabShindo, "Slash Hub", "https://hub.wh1teslash.xyz/")
createButton(tabShindo, "Imp Hub", "https://raw.githubusercontent.com/alan11ago/Hub/refs/heads/main/ImpHub.lua")
createButton(tabShindo, "Solix Hub", "https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua")
createButton(tabShindo, "Solaris Hub", "https://solarishub.net/script.lua")

-- 收养我
local tabAdoptMe = Window:CreateTab("收养我", 4483362458)
createButton(tabAdoptMe, "Auto Farm Auto Quest Auto Neon", "https://raw.githubusercontent.com/L1ghtScripts/AdoptmeScript/main/AdoptmeScript/JJR1655-adopt-me.lua")
createButton(tabAdoptMe, "Pet Farming Script", "https://raw.githubusercontent.com/Cospog-Scripts/shnigelutils/main/mainLoader.lua")
createButton(tabAdoptMe, "Auto Farm & Auto Neon", "https://gitfront.io/r/ReQiuYTPL/wFUydaK74uGx/hub/raw/ReQiuYTPLHub.lua")
createButton(tabAdoptMe, "Auto Quest & Auto Heal", "https://raw.githubusercontent.com/billieroblox/jimmer/main/77_HAJ07IP.lua")
createButton(tabAdoptMe, "Auto Buy & Walkspeed", "https://raw.githubusercontent.com/concordeware/sncware/main/sncware")
createButton(tabAdoptMe, "Get All Pets", "https://raw.githubusercontent.com/lf4d7/daphie/main/ame.lua")
createButton(tabAdoptMe, "Pastebin 2026 Script 8", "https://raw.githubusercontent.com/Ultra-Scripts/AdoptmeScript/main/AdoptmeScript/JI5PMVG-adopt-me.lua")

-- 布鲁克海文RP
local tabBrookhaven = Window:CreateTab("布鲁克海文RP", 4483362458)
createButton(tabBrookhaven, "Speed Hack Noclip Auto Farm", "https://raw.githubusercontent.com/riotrapdo-spec/KeySystems/refs/heads/main/Loader.lua")
createButton(tabBrookhaven, "Khosh Script", "https://raw.githubusercontent.com/kllooep/Fjjzxda6/refs/heads/main/KhoshScript.txt")
createButton(tabBrookhaven, "Sarturn Hub", "https://raw.githubusercontent.com/fhrdimybds-byte/Sarturn-hub-BrookhavenRP-/refs/heads/main/main.lua")
createButton(tabBrookhaven, "JOAO HUB", "https://raw.githubusercontent.com/UgiX1/JOAOHUB/refs/heads/main/JOAOHUB.txt")
createButton(tabBrookhaven, "Pastebin 2026 Script 5", "https://ghostbin.axel.org/paste/opp4o/raw")

-- 费什
local tabFisch = Window:CreateTab("费什", 4483362458)
createButton(tabFisch, "Venox Universal Scripts", "https://raw.githubusercontent.com/venoxcc/universalscripts/refs/heads/main/fisch")
createButton(tabFisch, "Farming GUI", "https://api.luarmor.net/files/v3/loaders/cba17b913ee63c7bfdbb9301e2d87c8b.lua")
createButton(tabFisch, "Banana Hub", "https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua")
createButton(tabFisch, "Lunor Loader", "https://raw.githubusercontent.com/Just3itx/Lunor-Loadstrings/refs/heads/main/Loader")
createButton(tabFisch, "Solix Auto Shake", "https://raw.githubusercontent.com/debunked69/Solixreworkkeysystem/refs/heads/main/solix%20new%20keyui.lua")
createButton(tabFisch, "Mobile Script Y-HUB", "https://raw.githubusercontent.com/Luarmor123/community-Y-HUB/refs/heads/main/Fisch-YHUB")
createButton(tabFisch, "Loader 2529a5f9", "https://api.luarmor.net/files/v3/loaders/2529a5f9dfddd5523ca4e22f21cceffa.lua")
createButton(tabFisch, "Loader 0bbab1d5", "https://api.luarmor.net/files/v3/loaders/0bbab1d51c52f509c1b7c219c86d4d83.lua")

-- 刀锋球
local tabBladeBall = Window:CreateTab("刀锋球", 4483362458)
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
local tabTSB = Window:CreateTab("最强战场", 4483362458)
createButton(tabTSB, "Auto Farm Players Anti Stun", "https://pastefy.app/1emcuiFz/raw")
createButton(tabTSB, "Auto Farm Invisible & Fling", "https://raw.githubusercontent.com/LOLking123456/Saitama111/main/battle121")
createButton(tabTSB, "Aimbot Auto Punch Auto Skill", "https://raw.githubusercontent.com/sandwichk/RobloxScripts/main/Scripts/BadWare/Hub/Load.lua")
createButton(tabTSB, "Infinite Jump & Fly", "https://pastefy.app/v9VSOfM5/raw")
createButton(tabTSB, "Anti Stun & Extra Range", "https://raw.githubusercontent.com/TheHanki/Hawk/main/Loader")
createButton(tabTSB, "Auto Parry", "https://raw.githubusercontent.com/SkibidiCen/MainMenu/main/Code")
createButton(tabTSB, "Mobile Script", "https://raw.githubusercontent.com/tamarixr/tamhub/main/bettertamhub.lua")
createButton(tabTSB, "Saitama Battlegrounds", "https://nicuse.xyz/SaitamaBattlegrounds.lua")

-- 宿敌
local tabRivals = Window:CreateTab("宿敌", 4483362458)
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
local tabAbilityWars = Window:CreateTab("能力之战", 4483362458)
createButton(tabAbilityWars, "Anti-Aura Anti KnockBack", "https://raw.githubusercontent.com/Sw1ndlerScripts/RobloxScripts/main/AbilityWars.lua")
createButton(tabAbilityWars, "Auto Farm & ESP", "https://raw.githubusercontent.com/castycheat/abilitywars/main/Protected%20(29).lua")
createButton(tabAbilityWars, "Stand Attack Time Reset", "https://gameovers.net/Scripts/Free/Ability%20Wars/stando.lua")
createButton(tabAbilityWars, "Pastebin 2026 Script 4", "https://raw.githubusercontent.com/dizyhvh/rbx_scripts/main/ability_wars.lua")
createButton(tabAbilityWars, "Pastebin 2026 Script 5", "https://raw.githubusercontent.com/Testerhubplayer/Ability-wars/main/Ability_wars.lua")

-- 死亡铁轨
local tabDeadRails = Window:CreateTab("死铁轨", 4483362458)
createButton(tabDeadRails, "Auto Bond Auto Win", "https://rawscripts.net/raw/Dead-Rails-Beta-Auto-Bond-Auto-Win-117096")
createButton(tabDeadRails, "刷债券V3", "https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/%E5%88%B7%E5%80%BA%E5%88%B8")
createButton(tabDeadRails, "刷债券V4", "https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Auto-Bond-V4")

-- 突破点
local tabBreakingPoint = Window:CreateTab("突破点", 4483362458)
createButton(tabBreakingPoint, "Funny Squid Hax", "https://raw.githubusercontent.com/ColdStep2/Breaking-Point-Funny-Squid-Hax/main/Breaking%20Point%20Funny%20Squid%20Hax")
createButton(tabBreakingPoint, "Infinite Credits", "https://raw.githubusercontent.com/IsaaaKK/bp/main/script")
createButton(tabBreakingPoint, "Silent Aim Rapid Throw", "https://raw.githubusercontent.com/1iseo/breaking-point-public/main/main.lua")

-- 自然灾害生存
local tabNDS = Window:CreateTab("自然灾害生存模拟器", 4483362458)
createButton(tabNDS, "Auto Farm God Mode Teleport", "https://raw.githubusercontent.com/73GG/Game-Scripts/main/Natural%20Disaster%20Survival.lua")
createButton(tabNDS, "Auto Farm & Free Balloon", "https://raw.githubusercontent.com/2dgeneralspam1/scripts-and-stuff/master/scripts/LoadstringUjHI6RQpz2o8")
createButton(tabNDS, "Anti-Fall & Anti-Weather", "https://raw.githubusercontent.com/pcallskeleton/RX/refs/heads/main/5.lua")
createButton(tabNDS, "No Fall Damage Anti-Water", "https://raw.githubusercontent.com/H17S32/Tiger_Admin/main/MAIN")
createButton(tabNDS, "Auto Clicker Auto Rebirth", "https://raw.githubusercontent.com/ToraIsMe/ToraIsMe/main/0GrimaceRace")
createButton(tabNDS, "Walkspeed & Gravity", "https://raw.githubusercontent.com/RobloxHackingProject/CHHub/main/CHHub.lua")
createButton(tabNDS, "Teleport to Spawn Map", "https://raw.githubusercontent.com/OneProtocol/Project/main/Loader")
createButton(tabNDS, "Mobile Script", "https://raw.githubusercontent.com/Bac0nh1ck/Scripts/main/NDS_A%5EX")
createButton(tabNDS, "Pastebin 2026 Script 9", "https://raw.githubusercontent.com/9NLK7/93qjoadnlaknwldk/main/main")
createButton(tabNDS, "海啸无敌", "https://pastebin.com/raw/Ai5WqH8N")
createButton(tabNDS, "全员变菜鸟", "https://rawscripts.net/raw/Natural-Disaster-Survival-noob-all-110242")
local tabbrainrot = Window:CreateTab("逃离海啸获得脑红", 4483362458)
createButton(tabbrainrot, "kdml hub海啸无敌", "https://raw.githubusercontent.com/kedd063/KdmlScripts/refs/heads/main/EscapeTsunamiForBrainrotsV4")
createButton(tabbrainrot, "Vinzhub海啸无敌", "https://script.vinzhub.com/loader")

-- 疯狂城市
local tabMadCity = Window:CreateTab("疯狂城市", 4483362458)
createButton(tabMadCity, "Ruby Hub", "https://raw.githubusercontent.com/aymarko/deni210/main/MadCity/RubyHub")
createButton(tabMadCity, "Auto Escape & Instant Interact", "https://raw.githubusercontent.com/ProBaconHub/ProBaconGUI/main/Script")
createButton(tabMadCity, "Auto Rob & Money Farm", "https://raw.githubusercontent.com/Cesare0328/my-scripts/main/MCARCH2.lua")
createButton(tabMadCity, "Auto Arrest & Teleport", "https://raw.githubusercontent.com/Deni210/madcity/main/Ruby%20Hub%20v1.1")
createButton(tabMadCity, "Pastebin 2026 Script 6", "https://pastes.io/raw/msc-65172")
createButton(tabMadCity, "Ruby Hub v1", "https://raw.githubusercontent.com/Deni210/madcity/main/Ruby%20Hub")

-- 犯罪生涯
local tabCriminality = Window:CreateTab("犯罪", 4483362458)
createButton(tabCriminality, "Starlightcc Leaked", "https://raw.githubusercontent.com/eradicator2/starlight-criminality/refs/heads/main/source.lua")
createButton(tabCriminality, "Cinality Script", "https://api.junkie-development.de/api/v1/luascripts/public/facbd46e4ae1e8ae608a9a7251682698bfc57ebd39d041d641ad84e483ce017f/download")
createButton(tabCriminality, "Silent Aim Script", "https://api.jnkie.com/api/v1/luascripts/public/1a000c187ed683ea2548d58eea33f6017ab5aa5ca12dec1f53df795ebc088163/download")

-- 动漫塔防
local tabAnimeTower = Window:CreateTab("动漫塔防", 4483362458)
createButton(tabAnimeTower, "Auto Win No Key", "https://raw.githubusercontent.com/aleksmago1/shadowhub/refs/heads/main/anime-tower-auto-win.lua.txt")
createButton(tabAnimeTower, "Unlock Admin Characters", "https://raw.githubusercontent.com/meobeo8/Misc/a/AnimePower.lua")

-- 咒术师攀登
local tabSorcerer = Window:CreateTab("咒术师攀登", 4483362458)
createButton(tabSorcerer, "OP KEYLESS Script", "https://rawscripts.net/raw/RELEASE-Sorcerer-Ascent-SCRIPT-OP-KEYLESS-103228")

-- 大屠杀
local tabMassacre = Window:CreateTab("大屠杀", 4483362458)
createButton(tabMassacre, "BEST SCRIPT MARCH 2026", "https://rawscripts.net/raw/UPD-Massacre-BEST-SCRIPT-MARCH-2026-136108")

-- 崛起交叉
local tabArise = Window:CreateTab("崛起交叉", 4483362458)
createButton(tabArise, "Speed Hub X", "https://raw.githubusercontent.com/U-ziii/Arise-Crossover/refs/heads/main/MultiFeatureScript.lua")
createButton(tabArise, "Frosties Script", "https://raw.githubusercontent.com/U-ziii/Arise-Crossover/refs/heads/main/ShadowAutomation.lua")
createButton(tabArise, "Auto Dungeon & Mount Farm", "https://raw.githubusercontent.com/U-ziii/Arise-Crossover/refs/heads/main/AutoDungeon.lua")
createButton(tabArise, "Keyless Script", "https://raw.githubusercontent.com/U-ziii/Arise-Crossover/refs/heads/main/KeylessScript.lua")

-- 蓝色监狱
local tabBlueLock = Window:CreateTab("蓝色监狱", 4483362458)
createButton(tabBlueLock, "Luarmor Loader", "https://api.luarmor.net/files/v3/loaders/fda9babd071d6b536a745774b6bc681c.lua")
createButton(tabBlueLock, "XZuyaX Hub", "https://raw.githubusercontent.com/XZuuyaX/XZuyaX-s-Hub/refs/heads/main/Main.Lua")
createButton(tabBlueLock, "Aimbot Hub", "https://api.luarmor.net/files/v3/loaders/34824c86db1eba5e5e39c7c2d6d7fdfe.lua")
createButton(tabBlueLock, "Fly Script", "https://raw.githubusercontent.com/Iliankytb/Iliankytb/main/BLRFlyingBall")
createButton(tabBlueLock, "Pastefy Script", "https://pastefy.app/wRGyxNnn/raw")
createButton(tabBlueLock, "Script 6", "https://raw.githubusercontent.com/EnesKam21/bluelock/refs/heads/main/obfuscated%20(2).lua")

-- 森林中的99夜
local tab99Nights = Window:CreateTab("森林中的99夜", 4483362458)
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
local tabInk = Window:CreateTab("墨水游戏", 4483362458)
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
local tabOhio = Window:CreateTab("俄亥俄州", 4483362458)
createButton(tabOhio, "Visurus", "https://scripts.visurus.dev/ohio/source")
createButton(tabOhio, "XA脚本", "https://raw.githubusercontent.com/XingFork/Scripts/refs/heads/main/Ohio")
createButton(tabOhio, "Pastebin脚本", "https://pastebin.com/raw/hkvHeHed")
-- SCP角色扮演
local tabSCP = Window:CreateTab("SCP角色扮演", 4483362458)
createButton(tabSCP, "NullZen", "https://raw.githubusercontent.com/axleoislost/NullZen/main/Scp-Roleplay")
createButton(tabSCP, "VoidPath", "https://raw.githubusercontent.com/voidpathhub/VoidPath/refs/heads/main/VoidPath.luau")
createButton(tabSCP, "Magnesium", "https://raw.githubusercontent.com/Bodzio21/Magnesium/refs/heads/main/Loader")
createButton(tabSCP, "M416", "https://raw.githubusercontent.com/xiaoSB33/M416/refs/heads/main/Wind/sb/SCP角色扮演")

-- 河北唐县
local tabTang = Window:CreateTab("河北唐县", 4483362458)
createButton(tabTang, "自动农场", "https://raw.githubusercontent.com/Sw1ndlerScripts/RobloxScripts/main/Tang%20Country.lua")

-- 活到七天
local tab7Days = Window:CreateTab("活到七天", 4483362458)
createButton(tab7Days, "自动脚本", "https://raw.githubusercontent.com/zamzamzan/test/refs/heads/main/7days")

-- 被遗弃
local tabAbandoned = Window:CreateTab("被遗弃", 4483362458)
createButton(tabAbandoned, "陈某汉化", "https://raw.githubusercontent.com/qazwsx422/Je/26ab7022f3767d471f2fbb3d67e0683f0c13a55a/%E8%A2%AB%E9%81%97%E5%BC%83")

-- 通用脚本
local tabUniversal = Window:CreateTab("Doors", 4483362458)
createButton(tabUniversal, "菜单", "https://raw.githubusercontent.com/RegularVynixu/Vynixius/main/Doors/Script.lua")

local tab3008 = Window:CreateTab("SCP-3008", 4483362458)
createButton(tab3008, "Antex脚本", "https://raw.githubusercontent.com/Viserromero/Antex/master/SCP3008")

-- 51区
local tabArea51 = Window:CreateTab("51区", 4483362458)
createButton(tabArea51, "STK菜单v7", "https://raw.githubusercontent.com/Ghostmode65/STK-Bo2/master/STK-Menus/v7/STv7-Engine.txt")

-- 阿尔宙斯X（通用）
local tabArceus = Window:CreateTab("阿尔宙斯X", 4483362458)
createButton(tabArceus, "Arceus X V3", "https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/Arceus%20X%20V3")

local tabDontPress = Window:CreateTab("别碰按钮4", 4483362458)
createButton(tabDontPress, "EEWE脚本", "https://raw.githubusercontent.com/imaboy12321/EEWE/main/eweweew")

-- 彩虹朋友
local tabRainbow = Window:CreateTab("彩虹朋友", 4483362458)
createButton(tabRainbow, "BorkWare", "https://raw.githubusercontent.com/Ihaveash0rtnamefordiscord/BorkWare/main/Scripts/" .. game.GameId .. ".lua")

-- 床战/起床战争（已存在，追加新脚本）
local tabBedWars = Window:CreateTab("起床战争", 4483362458)
createButton(tabBedWars, "VapeV4", "https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua")

-- 地下城
local tabDungeon = Window:CreateTab("地下城", 4483362458)
createButton(tabDungeon, "Dungeon脚本", "https://pastebin.com/raw/F5vSFHZt")

-- 点击模拟器
local tabClick = Window:CreateTab("点击模拟器", 4483362458)
createButton(tabClick, "Kederal脚本", "https://raw.githubusercontent.com/Kederal/script.gg/main/loader.lua")

-- 电脑键盘
local tabKeyboard = Window:CreateTab("电脑键盘", 4483362458)
createButton(tabKeyboard, "Keyboard FE", "https://raw.githubusercontent.com/manimcool21/Keyboard-FE/main/Protected%20(3).lua")

-- 动感星期五
local tabFunky = Window:CreateTab("动感星期五", 4483362458)
createButton(tabFunky, "自动演奏", "https://raw.githubusercontent.com/wally-rblx/funky-friday-autoplay/main/main.lua")

-- 动物模拟器
local tabAnimal = Window:CreateTab("动物模拟器", 4483362458)
createButton(tabAnimal, "牛逼脚本", "\104\116\116\112\115\58\47\47\114\97\119\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\112\101\116\105\116\101\98\97\114\116\101\47\109\101\110\117\47\109\97\105\110\47\77\101\110\117")

local tabHouse = Window:CreateTab("房屋生存", 4483362458)
createButton(tabHouse, "Proxima Hub", "https://raw.githubusercontent.com/TrixAde/Proxima-Hub/main/Main.lua")

local tabDemon = Window:CreateTab("鬼灭之刃", 4483362458)
createButton(tabDemon, "Furious脚本", "https://raw.githubusercontent.com/StepBroFurious/Script/main/FuriousFall.lua")

-- 火影
local tabNaruto = Window:CreateTab("火影", 4483362458)
createButton(tabNaruto, "Premier X", "https://raw.githubusercontent.com/SxnwDev/Premier/main/Free-Premier.lua")

-- 极速传奇
local tabSpeed = Window:CreateTab("极速传奇", 4483362458)
createButton(tabSpeed, "无限经验", "https://pastebin.com/raw/9KWQXasx")

-- 僵尸起义/进击的僵尸
local tabZombie = Window:CreateTab("僵尸起义", 4483362458)
createButton(tabZombie, "xSyon引擎", "https://raw.githubusercontent.com/xSyon/ZombieAttack/main/engine.lua")
createButton(tabZombie, "Darkrai X", "https://raw.githubusercontent.com/GamingScripter/Darkrai-X/main/Games/Zombie%20Attack")

-- 捐赠游戏 Pls Donate
local tabDonate = Window:CreateTab("捐赠游戏", 4483362458)
createButton(tabDonate, "自动农场", "https://raw.githubusercontent.com/heqds/Pls-Donate-Auto-Farm-Script/main/plsdonate.lua")

-- 克隆大亨
local tabClone = Window:CreateTab("克隆大亨", 4483362458)
createButton(tabClone, "CT-Destroyer", "https://raw.githubusercontent.com/HELLLO1073/RobloxStuff/main/CT-Destroyer")

-- 汽车经营大亨
local tabCar = Window:CreateTab("汽车经营大亨", 4483362458)
createButton(tabCar, "BlueLock脚本", "https://raw.githubusercontent.com/03sAlt/BlueLockSeason2/main/README.md")

-- YBA (Your Bizarre Adventure)
local tabYBA = Window:CreateTab("YBA", 4483362458)
createButton(tabYBA, "NukeVsCity脚本", "https://raw.githubusercontent.com/NukeVsCity/hackscript123/main/gui")

-- The Rake
local tabRake = Window:CreateTab("The Rake", 4483362458)
createButton(tabRake, "jFn0k6Gz脚本", "https://pastebin.com/raw/jFn0k6Gz")

-- RIU (Roblox Is Unbreakable)
local tabRIU = Window:CreateTab("RIU", 4483362458)
createButton(tabRIU, "无限等级+钱", "https://raw.githubusercontent.com/MorikTV/Roblox-is-Unbreakable/main/Unbreakable.lua")

-- Nico's Nextbots
local tabNico = Window:CreateTab("Nico's Nextbots", 4483362458)
createButton(tabNico, "aBPrm1vk脚本", "\104\116\116\112\115\58\47\47\112\97\115\116\101\98\105\110\46\99\111\109\47\114\97\119\47\97\66\80\114\109\49\118\107")
Refresh() -- 初始刷新玩家列表
Rayfield:Notify({Title = "加载成功！", Content = "欢迎使用91缝合脚本！", Duration = 5})
