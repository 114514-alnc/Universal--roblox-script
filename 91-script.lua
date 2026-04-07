local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "91混合脚本 v1.0",
   LoadingTitle = "脚本加载中...",
   LoadingSubtitle = "91混合脚本v1.0",
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

----------------------------------------------------------------
-- 1. 首页
----------------------------------------------------------------
local welcometab = Window:CreateTab("首页", 4483362458)
welcometab:CreateLabel("欢迎使用 91混合脚本 v1.0！")
welcometab:CreateLabel("服务器功能有的可能需要卡密，有的已经失效，大部分没测试")
welcometab:CreateLabel("→脚本功能在右边→")
welcometab:CreateLabel("用户名:"..game.Players.LocalPlayer.Name)
welcometab:CreateLabel("服务器的ID"..game.GameId)
----------------------------------------------------------------
-- 2. 通用功能页面
----------------------------------------------------------------
local hubtab = Window:CreateTab("通用", 4483362458)

-- 系统工具
hubtab:CreateSection("系统工具")
hubtab:CreateButton({
   Name = "重新加入游戏 (Rejoin)",
   Callback = function() TeleportService:Teleport(game.PlaceId, Plr) end,
})
hubtab:CreateButton({
   Name = "清理内存/减少卡顿 (GC)",
   Callback = function() 
      collectgarbage("collect")
      Rayfield:Notify({Title = "系统", Content = "内存已清理", Duration = 2})
   end,
})

-- 属性修改
hubtab:CreateSection("属性修改")
hubtab:CreateSlider({
   Name = "行走速度 (WalkSpeed)",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) if Plr.Character then Plr.Character.Humanoid.WalkSpeed = v end end,
})
hubtab:CreateSlider({
   Name = "跳跃高度 (JumpHeight)",
   Range = {50, 500},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(v) 
      if Plr.Character then 
          Plr.Character.Humanoid.JumpPower = v 
          Plr.Character.Humanoid.UseJumpPower = true
      end 
   end,
})
hubtab:CreateToggle({
   Name = "无限跳跃 (Infinite Jump)",
   CurrentValue = false,
   Callback = function(v)
      States.InfJump = v
      if v then
          infJumpConn = UserInputService.JumpRequest:Connect(function()
              if States.InfJump and Plr.Character then
                  Plr.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
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
   Name = "摇杆飞行 (Joystick Fly)",
   CurrentValue = false,
   Callback = function(state)
      if state then
          States.Flying = true
          local char = Plr.Character
          local root = char.HumanoidRootPart
          local hum = char.Humanoid
          hum.PlatformStand = true
          bg = Instance.new("BodyGyro", root)
          bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
          bv = Instance.new("BodyVelocity", root)
          bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
          flyConn = RunService.RenderStepped:Connect(function()
              local cam = workspace.CurrentCamera
              bv.velocity = (hum.MoveDirection.Magnitude > 0) and (hum.MoveDirection * FlySpeed) or Vector3.new(0, 0, 0)
              bg.cframe = cam.CFrame
          end)
      else
          States.Flying = false
          if flyConn then flyConn:Disconnect() end
          if bv then bv:Destroy() end
          if bg then bg:Destroy() end
          if Plr.Character then Plr.Character.Humanoid.PlatformStand = false end
      end
   end,
})
hubtab:CreateSlider({
   Name = "飞行速度设定",
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
          noclipConn = RunService.Stepped:Connect(function()
              if States.Noclip and Plr.Character then
                  for _, part in pairs(Plr.Character:GetDescendants()) do
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
      task.spawn(function()
          while States.AutoInteract do
              for _, d in pairs(workspace:GetDescendants()) do
                  if d:IsA("ProximityPrompt") then
                      d.HoldDuration = 0
                      if (Plr.Character.HumanoidRootPart.Position - d.Parent.Position).Magnitude < 15 then
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
   Callback = function(v) Rayfield:Notify({Title = "提示", Content = "该功能已在后台静默运行", Duration = 2}) end,
})
hubtab:CreateToggle({
   Name = "走路创人",
   CurrentValue = false,
   Callback = function(v)
      States.KillAura = v
      task.spawn(function()
          while States.KillAura do
              if Plr.Character then
                  Plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 5000, 0)
                  task.wait(0.1)
                  Plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
              end
              task.wait(0.1)
          end
      end)
   end,
})
hubtab:CreateButton({
   Name = "甩飞所有人",
   Callback = function()
      local hrp = Plr.Character.HumanoidRootPart
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
      task.spawn(function()
          while States.Spinning do
              if Plr.Character then
                  Plr.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(SpinSpeed), 0)
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
        if p ~= Plr then table.insert(names, p.Name) end
    end
    PlayerDropdown:Refresh(names, true)
end
hubtab:CreateButton({ Name = "刷新玩家列表", Callback = Refresh })
hubtab:CreateButton({
   Name = "传送到选中玩家",
   Callback = function()
      local target = game.Players:FindFirstChild(SelectedPlayer)
      if target and target.Character then
          Plr.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
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
b.Enabled = true
b.Intensity = 0.99
b.Size = 9999 
b.Threshold = 0
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
centerTab:CreateButton({
   Name = "走马观花v1.5",
   Callback = function()
      _, Protected_by_MoonSecV2, Discord = 'discord.gg/gQEH2uZxUk'


,nil,nil;(function() _msec=(function(e,d,l)local j=d["جكندحكآئټڪټؠ"];local G=l[e[(0x2d0+-23)]][e["زضس؃دڝدڪدؠڪئنآس"]];local T=((0x48-49)+-#[[I like gargling cum]])/(462/((-#[[free trojan]]+(0x245a-4675))/0x14))local y=(-0x41+(1474/(2486/0x71)))-(-#{'nil';(function()return#{('MoBmmM'):find("\66")}>0 and 1 or 0 end);{},'}','}';42}+7)local M=l[e[(0x7161/225)]][e["ضنحدڪئكنقټق"]];local F=(11/((213-0x84)+-0x46))+((-51+0x4a)+-#"notbelugafan was here")local S=l[e[(19760/(-19+0x39))]][e["قسؠن؃سج؃كنؠټقټټآ"]]local o=(66+-0x40)-(((206-((0xe2+-19)+-0x56))+-#'Never gonna give u up')/0x40)local i=(0x9e/(-0x6f+((-#{'nil',",",1,'}',1}+484)-289)))local b=((((0xe860/(-#'Cock and ball torture'+(15403/(-#[[Nitro Activated]]+(0x220-318)))))+-#'911WasAnInsideJob')/0x31)+-#'Never gonna give u up')local s=(((-#[[ILoveBlowJobs]]+((319+-#{",";(function()return{','}end)(),1,(function()return{','}end)(),1;","})-196))-95)+-#'Hi skid')local h=((((276-(((470+-#{",",",",(function()return#{('pBppMM'):find("\112")}>0 and 1 or 0 end)})-0x125)+-#[[looadstring]]))+-#"test 123")+-0x5d)+-#[[sins daddy]])local k=(32+(-#'Bong'+(0xa-(-#[[require]]+(-49+(296-0xcc))))))local c=(((0x163-(0x1cf-(0x239-328)))+-#"guys Please proceed to translate D to Sinhala")+-0x56)local w=(((-#{(function()return#{('fLHhBK'):find("\72")}>0 and 1 or 0 end);1,(function()return#{('fLHhBK'):find("\72")}>0 and 1 or 0 end);'nil',1,(function()return{','}end)()}+6294)/48)-0x80)local x=(9+-#{'nil',1,'}';98;(function()return{','}end)(),'}'})local u=((-#{56;(function()return{','}end)();(function()return#{('LfpLBb'):find("\112")}>0 and 1 or 0 end);56;56,'}',(function()return{','}end)()}+46)-0x24)local t=((((((-10168/0xf8)+-#"fish was here")+0x1224)-0x91f)/0xcd)+-#'test 123')local g=((-73+(((0x5923-11447)-0x1672)/0x3a))+-#[[Two trucks having sex]])local f=(115+(((-12000/((0x97d4/123)+-0x74))-7)+-#'guys Please proceed to translate D to Sinhala'))local H=(-#[[guys Please proceed to translate D to Sinhala]]+(127+(-#[[sinsploit]]+((((-0x12115b/(49+-#{1,",",190,(function()return{','}end)(),1;(function()return#{('lHLHfp'):find("\76")}>0 and 1 or 0 end)}))+-#"dick cheese")+13748)/0xc8))))local B=(-#"CockAndBallTorture"+(0x44+(-10626/(-50+(-#{'nil';",";","}+284)))))local I=(69+((((-3825767+0x1d3011)/0x8b)+-#'iam u Furry iPipeh')/0xd4))local P=(0x1c/((600/(87-(65+-#{28;'nil',162})))+-#[[911WasAnInsideJob]]))local v=((567+-#{(function()return{','}end)(),(function()return{','}end)();",",(function()return#{('oKKPbB'):find("\75")}>0 and 1 or 0 end),1,'nil';(function()return#{('oKKPbB'):find("\75")}>0 and 1 or 0 end)})/0x8c)local A=(-#{'}',{},1;",";(function()return#{('PPkFbK'):find("\107")}>0 and 1 or 0 end)}+9)local O=e[(0xb0a-1473)];local E=l[e[(136+-#{1;'nil';'}';'}';(function()return#{('PbmoPH'):find("\109")}>0 and 1 or 0 end);118;'}'})]][e["آسئئجسقجڪټضزټټآؠضك"]];local z=l[(function(e)return type(e):sub(1,1)..'\101\116'end)('حقئزڪقآق')..'\109\101'..('\116\97'or'نكئزسقحئ')..e[(95160/0xb7)]];local m=l[e[(-#{96;96,(function()return#{('KoOKpb'):find("\79")}>0 and 1 or 0 end);114}+524)]][e["جئكقكآؠئئجضضآضنجك"]];local C=(0x4b-73)-(0x65-(0x507/(0x625/121)))local L=((-0x41+(-#"me big peepee"+(-64+((2480/0x10)+-#"test"))))+-#[[test123]])-(-127+0x81)local Y=l[e[(-#[[FBI is going to attack you now escape mf]]+(383-0xd6))]][e["كح؃ؠؠقڝنجڝڪح"]];local n=function(l,e)return l..e end local W=(0x2d8/182)*((((26166/(39-0x21))+-#'no thanks')/0x88)+-#[[IPIPEH I WANNA FUCK WITH YOU]])local U=l[e["ڪنڝ؃جآؠؠسض"]];local r=(0x7b-121)*((196+(-#"Hard Sex with iPipeh"+(-0x1b00/(0x19d-221))))+-#[[deobfuscated]])local K=(0x7400/29)*(-#'911WasAnInsideJob'+(0x273/(6105/(0x1c3-266))))local _=(6604/(((0x2d3-(0x15a14/214))+-#"Rivers Cuomo")-170))local N=((((419-0xf8)-0x7f)+-#'420Script Was Here')-24)*(0x66+-100)local p=l[e["دضز؃دضججضټسسدق؃ئ"]]or l[e[(1149-0x275)]][e["دضز؃دضججضټسسدق؃ئ"]];local a=((13248/(((-#'Hard Sex with iPipeh'+(0x22f+-117))-0x108)+-112))+-#'xenny its znugget please respond')local e=l[e["ټدڪججڝزئزقسآحڝس"]];local S=(function(n)local i,d=2,0x10 local l={j={},v={}}local a=-o local e=d+y while true do l[n:sub(e,(function()e=i+e return e-y end)())]=(function()a=a+o return a end)()if a==(W-o)then a=""d=C break end end local a=#n while e<a+y do l.v[d]=n:sub(e,(function()e=i+e return e-y end)())d=d+o if d%T==C then d=L m(l.j,(Y((l[l.v[L]]*W)+l[l.v[o]])))end end return S(l.j)end)("..:::MoonSec::..؃دحجئضسزقكنؠآټڪڝ؃ززك؃كككحكؠكئكټكسؠڝكقكدكضكجكحدس؃ڪكزك؃كڪڝكححآؠحجؠټضضڪقآدكنكجكآكدټڪكزك؃كككحكؠكئك؃كدقڝكقكدكنؠجكآنضكڪكقټ؃كككحكؠنئكټكسكڝكقؠدكنكجكآكضكڪكزكدزككحكؠكآآټآسكڝكقكقؠ؃نكټزسضكڪكزك؃كككټكحآقكقسسكڝكقكدكنكجكڪټككسآزڝ؃كككحكڝآقڝئؠآنسسڪڪڝدجئنضؠ؃ضئكحسنټؠضقټسؠكئكټكسكڝكقك؃كڪقسسآټضكڪكزكزسڝنكټحدندټڝسكڝكقكضندزن؃جضؠڪضآزن؃كككحكؠكئكضكؠڝجكسحدآنكجكآكآزئڪڝ؃سدكټحكؠكئكض؃آنسحڝټكؠنكجكآكضكڪكزك؃كككنآآ؃ئكټكسكئڝڪڪزآدټنقجؠقآئ؃حټټد؃ڝڪزضقؠؠحڪنكدسقكدكنكئؠجحضكڪكزك؃ڝككحكؠكضؠئحسكڝنقكدآنكجكآكسؠضحزك؃ؠككحڝؠكئكټكسټجڝقكدكنكضضآكضنڪكقؠڪكككحټؠكضئټكسكڝكقكئجنكجټآكضنڪكزن؃كككحكؠكئټټكسكڝكقكدكؠؠجكآكضڪڪكزټ؃كككحكټكئكټكسڪڝكقڪدكؠججكټؠضكڪكزڝ؃كنسحكؠكئكڝكسكڝكقڝدكنڝجكټجضكڝؠزك؃كن؃حكؠؠئكټكسك؃ؠقكدكؠدجكآڪضكڪكزكدؠككحكآحئكڪزسكڝكقكدكنكجكآڝضكڝحزك؃كككحكؠكئكټڪسكڝكقكدؠنكئؠآكضكڪڝزك؃ټككحكؠكسكټكسكڝڝقكدڝنكئدآكسؠڪكزكد؃ككج؃ؠكئكټكقكڝكقكح؃نكئ؃آكضنڪكقؠ؃كككجدؠكضحټكسكڝكقكدكنكئ؃آكضؠڪكزؠ؃كنؠحكؠكضدټكزضڝكقكدكؠؠجكآكسحڪكقض؃كككحكؠكئكټكسڝڝككحدكنؠجكآكضكڪكزڪ؃ككڪحكؠڝئكڪكسكڝكقټدكنټجكآڪضكڪټض؃؃كككحكؠټئكټنسكڝككټدكنكجكآنضكڪكزك؃كككحكؠكئكڪدسكڝكقككؠنكجكآكضكڪكزكجټټكحؠؠټئكټكسكس؃ڪنقس؃ڪجؠآټضكڪكزكق؃ڝنكححټندڪئسكڝكقكسحدزنټحڪآؠئنټآزټ؃حكقحزآؠټكسكڝكقكدكنكحك؃قټآڝجزك؃كككسڝححؠؠجڪؠآضڪڝؠقڝ؃ڪنؠحدسكڪكزك؃كټآكضححنڪئزټټئحڝآضټدؠكنج؃آ؃ضحڪزز؃ڝدجنؠكئكټكؠؠضڪڝكقضدحكآحنآټئڪټټضآ؃ټكقحؠننئ؃آڪ؃ققكدكنكئؠجحضكڪكزك؃ڪككحكؠكضؠئحسكڝنقكدننكجكآكسؠضحزك؃ؠككحڪؠكئكټكسټجڝقكدكنكئزآكضنڪكقؠڪكككحټؠكئآټكسكڝكقكڝڪنكجټآكضنڪكزن؃كنؠحكؠكئټټكسؠڝكقكدكآكجكآكضټڪكزټ؃كندحكټكئكټكسټڝكقټدكنټجكڪكضكڪكزټ؃ككټحكآ؃ئكڝكسكڝكقټدكنټجكآڝضكڪكزك؃ككڝحكؠكئكټكسكڝكقكدكنټجكآڝضكڪنزك؃ټز؃حكؠكئكټټسكڝنقكدكؠټجكآكضكڪنزك؃كككحكآزئكټكسكحسكئدكنكجكح؃آقضقټټضآڝڪقآحټؠحئقټزنزقڪدكنكجكدكآضئنڪززئئزحټؠكئكټكؠزضنڝسزڪټسئضآكضكڪكآكزضڝننحدڪؠؠحسټقضټڪڪقضدآدحآڪضكڪكزكزكڝنكححؠؠآؠحز؃ڝكقكدكڝكنضحنټحئڪڪؠزآآسحڪؠكئكټكؠڝضنڝضقڪ؃ڪكدآټضكڪكزكز؃ڝنكسدڪآآڪئسكڝكقكس؃؃ڪنټ؃آآدضحڪضسټ؃ؠقڪحززسڪئسكڝكقكسضدقكآحنآضجكڪضسندحقڪحؠآآټڪسكڝكقكقآدككنئ؃آزكزقز؃كككحكدڝؠحئزآټجڝڝحقؠدآنټ؃آآدضحڪضسټكؠحڪؠكئكټكؠقز؃ڝززڪدؠكدټحضكڪكزكس؃؃قكؠحئؠآئكآنضآڪڪئقنكجكآكسؠنڪزك؃كككحڪؠكئكټكزؠڝكقكدننكئدآكضكڪككك؃كككحنؠكئنټكززڝكنكدكنكجنآكضنڪكزټ؃كؠكحكؠكئنټكسنڝككحدكنكجكآكضنڪكزؠ؃كككحكؠكئكټكسكڝكقكدكنؠجكآټضكڪكزك؃كآضحكؠنئكڝكنئڝكقڪدكنټجكآآضك؃ڝقح؃ككڪحكڪئئكټنسكڝؠقكدټحآجكآكضكدئزك؃نككئكض؃ئكټڪسكڝټقكحضنكئؠجحضكڝ؃زكدسككحكؠكئكدڪسكڝڪقكح؃نكجؠآكضڝسززك؃ڪككضئؠكئنټكسكڝكقټكآنكجكآكقئڪكزن؃كؠكسئؠكئڪټكسټڝككسدكآكضآآكضڪڪكزڪ؃كن؃حكآؠئكټكسڝڝككددكنكجكڪكضكڪكزڝ؃ككڝحكؠڝئكڝكسكڝكقڝدكنڝجكټجضكڪڝزك؃ككڪحكټدئكټنسكڝڝقكدټحآجكآكضك؃دزك؃نككحټجآئكټكسكحئقكدننكئؠنكضكڪڪزك؃ڪككحكؠكسكز؃سكڝڝقكدټنكئحآكضكڪآزك؃ڝككج؃ؠكئكټكسكڝسقكدڪنكجكآكس؃ڪكزټقآككحكؠكسڪټكسنڝكنكضئنكئجآكسحڪكزآ؃كؠڝجحؠكضجټكقټڝكقندكننجكآټټآڪكزك؃كؠټحكؠنئكڪؠئكڝككجدكؠئجكآكضكڪڝ؃ټ؃كنئحكؠكئكټنسكڝنقكدكټدجكآكضكڝحزك؃كككحكآئئكڪجسكڝؠقكدننكجكڪ؃ضكڝدزك؃كككحكؠكئڝ؃ضسكڝڪقكجسنكجنآكضؠڪكزټقآككحكؠكسسټكسنڝككؠڝكنكجڪآكسئڪكزك؃ككڝؠټؠكئڝټكسنڝكقندكننجكآكقدڪكزك؃ككټحكؠكئكټكزئڝكقڪدكنؠجكآنضكڪكك؃؃ككآحكؠكئكټكسكڝڝؠضدكنكجكټدضكڪنزك؃ؠككحټجآئكټكسك؃دقكدننكجكټټضكڪكزك؃نككحكؠكئكټكسكڝكقكدؠنكجكآكؠجڪنضحد؃ككحكؠككڝئحټآسحڪؠقض؃ڪجآآكضكڪكزكآټككحكؠكئكټكسكڝكؠكآقنكجكآكضؠڪكزن؃كككجټؠكئكټكسنڝكقكدكنكجؠآكضكڪكزك؃كككحكآآئكټكسكڝؠكئدكنكجكد؃ؠڪضټؠآزد؃حكضدټؠؠجڪټززآكددكنكجك؃ؠؠنئآڪئزكڝنقآحئآآټڪسكڝكقكسټدقنؠجآآقئدقج؃كككحكڝڝؠحئؠآڪئآڪڪقؠدڝكڪجؠضؠڪټزك؃كككك؃دنؠسجڪكس؃حقكدكنكزآجدؠنضؠټنسآ؃ټقڪحؠزسڪكسكڝكقكضآدضنححڪآزضټآحزز؃ټقڪحؠننجآټټضڪڪټزدنآجكآكضكضزټڪق؃كؠحټؠكئكټكؠټسقڝققضحآئنآكضكڪكآؠسڪ؃ككضححنآجنټټضڪڪټسآدټنقجؠؠنض؃ټڪجسنححكؠكئكدټټؠسقڝكجكدټنقجقآضسآقج؃كككحك؃؃نڪئټؠآضڪڝؠقڝدحكآحڪټؠڪكزك؃كككحكؠكضټدكئح؃ئقكدكنكقحجزآټئڪڪؠسنڝآكټححؠقئزكسڝټقكدكنكقزحنآسئڪزؠدئككحكؠككآجنآڝضڪټؠزڪدآنكحنټ؃ضززن؃كككحكؠكئكټكسكڝكقؠدڝنكجكآككآحڝڪؠسن؃سقڪجآئڪټكسكڝكڝكزندحنؠجآزڪڪكزك؃كنؠ؃ؠؠكئكټكزكڝكقكدكنكجكآكضكڪكزن؃ككنحكآؠئكټكسكڝككآدكنكجكآكضكڪكزن؃كككحكؠكئكڝكسكڝكقندكننجكآؠضك؃كزك؃ككنحكؠنئكټنسكڝكقكدكننجكآؠضكڪكزك؃كككحكؠكئكټكسكڝؠقكدټنكجكآكضك؃ؠزك؃نككئكڝئئكټڪسكڝټقكحقنكضڝدزضكڪڪزكدسككحنؠكضحټكسټزآقكدكنكئسآكضنڪكزټقآككحكؠكسؠټكسنڝككؠڝكنكجڪآكضڪڪكزك؃كؠكنكؠكئڪټكسڪڝككضدكؠؠجكآكس؃ڪكقج؃كككحكؠكئكټكسڪڝكك؃دكنؠجكڪكضكڪكزڪ؃ككڪحكآزئكڝكسكڝكقڪدكنڪجكټ؃ضك؃كزك؃ككڪحكؠڪئكټټسكڝكقكدكؠ؃جكآټضكڪكزكدؠككحكآدئكڪئسكڝكقكدكنكجكټحضكڪكزك؃كككئكؠكئكڪحسك؃حقكدڝنكضكآكضكڝحزكدحككحآؠكسكټكسك؃حقكححنكئؠآكسؠڪكزكدجككجؠؠكئكټكقكڝكقكحجنكئجآكسدڪكقؠ؃كككجئؠكضنټكسكڝككؠدكنكئضآكسسڪكزك؃كنؠحكؠكضسټكزنڝكقكدكنكجكآكسجڪكقس؃ككؠحكؠكئكټكزحڝككحدكؠججكآكضكڪكزڪ؃كنححكؠنئكټڝكضڝكقكدكؠحجكآنضكڪؠزك؃ټدآحكؠكئكڪحسكڝنقكدكؠټجكآكضكڪنزك؃كككحكؠكئكټكسكڝآقكدكنكجؠټحضكڪكزكئآ؃دقنحؠننجآټټضڪڝؠآزنټجكآكضكجدټڪسنڝټنآآ؃ئكټكسكجټڪڪقآدټنؠجقټحڪڝزك؃كككحكجنئكټكسكڝكقكدكنكضكآكضكڪكزك؃كككحنؠكسكټكسكڝكقكدكنكجؠآكزكڪكزك؃كككحكؠكئآټكسكڝكقكدكنكجؠآكضنڪكزك؃كككحكؠكئنټكسكڝكقكدڝنكجكآكجحڪټزك؃كككسټحڪؠكجڪآد؃؃قكدكنكقكجضؠنسحټڪزؠ؃آضسآئئكټكسكئضڝقزآ؃ننضدكآضئنڝحسڪ؃ؠټزؠټئكټكسكس؃ڪنقس؃ڪكدټئضكڪكزكضآڝنقڝدڪكؠجڪټآسكڪنك؃دزجؠټ؃ضكڪكزكزآڝڪكؠحڝؠحجآآڪ؃زقكدكنكئؠقڝضكڪكزك؃ټككحكؠكسكټكسكڝكقكدكنكجڝآكسؠڪكزك؃ؠككحؠؠكئكټكسكڝكقكدكنكجؠآكضؠڪككك؃كككحكؠكئكټكسآڝكقڝنټنكجنآكضنڪكزن؃ككنحكؠكزدټكسكڝكقكدكنكجكټؠسآڪكزن؃ككڪحكؠكئكټڝڝټڝكقندكنكجكآنضكڪنزك؃كآدحكؠكئكټكسكڝكقكحؠؠآجكآنضكڪنزك؃كككجؠككئكټنسكڝنقكدكنكجكټدضكڪنزك؃نككحنؠكئكڪټسكڝكقكدننكجكآكضكڪنزك؃كككحكؠكئكټكز؃ڝكقكدكقحئؠآكضكڪكآكزؠ؃قككدڪؠؠئټڪحئكڝڪقؠ؃آندحنآآضحڪزز؃زحججؠكئكټكنڝسحڝؠزڪڝآكڪجؠآڝئڪڪؠسدكټحكؠكئكجؠآنسآڪڪئسنټجكآكضكض؃ټنزسڝڪنآآنئكټكسكئؠڪڪقكدضنححآؠنضټټڪسټڪآكټحقؠؠجنټ؃ضڪؠسحجنكجكآكن؃ئڪڪټضآڝڪكؠحڝؠحجآآڪحسكڝدكنكجك؃آآضضحټڪزز؃ټسڪجدؠكجنټزضټڪڪزټڝكنؠجقآكئڪڪؠزټدحجئؠكئكټكزؠؠڝقكدننكجټآكضكڪككك؃كككحنؠكئنټكسڝڝككؠدكنكجآآكضڪڪكزك؃كككحكؠكئنټكسآڝكقؠدكآكجكآكضنڪكزن؃ككنحكټكئؠټكسنڝكقندكؠ؃جكڪكضكڪكزؠ؃ككنحكؠؠئكڪؠسكڝكقټدكنآجكآكضكڪكزك؃ككڪحكؠكئكټكسكڝكقكدكنؠجكآڪضكڪنزك؃كككحكؠكئكټنسكڝكقكدنآدجكآكضكآحزڝ؃كككحكڝآقڝئؠآنسسڪڪدؠنڪجكآكضكجقڝ؃ززڝڪكؠؠؠضئټكسكڝكټ؃زڪدټزآجدآحضضټټزؠڝڪكزددئنټكسكڝكڪحدؠنټجكآكضكضآڪكزق؃آقدؠنئكټكسكضدڪدححنكجكآكؠ؃ضقڪؠزئ؃آككدننآجڪكسڝنقكدكنككجڝضضكڪكزك؃كككحكڝټقكقززجڝكقكدكڝكنؠجقآكئڪڪؠزټ؃حقڪحآآؠټكسكڝكقكدكنكقټ؃كجحڪټزك؃كككك؃دنؠسجڪدز؃؃قكدكنكقكجضؠنسحټڪزؠ؃آ؃حآئئكټكسكئضڝقزآ؃ننضدكآضئنڝحسڪ؃ؠقدآضئكټكسكئقڝؠقحد؃نحجزنآضنڪڪسن؃ؠقڪجآضدټكسكڝكڝسزندئكڪحؠؠنضآټڪڪحندحكؠكئكحكټقسآڝحقټدحنقجزجحڪڪزك؃كككزڝدنؠضئڪآڪضدكزدكنكجك؃ڝآحضزټټئڝ؃حكؠحآؠټدآټدسحڝضزټنؠجڪآكضكڪكڪكسن؃حكؠحآآآڪجسكڝكقكس؃؃ڪنټدآؠڪضؠڪڝزحڝآقڪسزئڝټكسكڝكڝآقندڪكنجؠؠڪدسزټ؃كككحكدؠننئآآڪحسقآدكنكجكجزؠڪس؃آن؃نككحكآؠئ؃ټكسكڝككټدكنكجكټؠضكڪكزن؃كنضحكؠكئكڝكسكڝكقندكننجكټڪضكڝؠزك؃ككآحكآ؃ئكټكسكڝكقكدكننجكآآضكڪؠزكحكككحكؠنئكټنسك؃جقكجكنكجكآنضكڪنزك؃آككحكؠكئكټنسكڝؠقكدكنكجكآكضكڪكزك؃كككحؠؠكئټټكسكڝكقكجحنكجنآكزكق؃زك؃ڪككحټؠكضآټكزؠسحقكح؃نكجؠآكضكڪكزكئڪككحڪؠكض؃ټكسؠڝكقڝكزنكجڪآكزحڪكزن؃كككحكؠټآآټكسكڝكنحدكننجكڪككئڪكزڪ؃ككټحكؠؠئكڝكئئڝكقڪدكنڪجكټؠضكڝؠزك؃ككڝحكآضئكټكسكدكقكدكنڝجكآڝضكڝسزكحكككحكؠڝئكټڝسك؃زقكدڝنكجكآڪضك؃حزك؃نككحڝؠكئټضآسكڝكقكجحنكجنآكسؠڝآزك؃ټككئ؃ؠكئكټكقكجئقكدڪنكجټآكسقڪكقؠدآككحڪؠكضڝټكسكڝكقڝئضنكجكآكسجڪكزن؃ككؠحكؠټآآټكسكڝككجدكننجكآؠقزڪكزك؃كككحكؠكئكڪؠنحڝكقكدكؠكجكآكضكڝؠزك؃كككحكآڝئكټكسكدكقكدكنكجكآكضكڝنزكدؠككحكؠكئكټڪسكڝكقكحؠنكجكآكضكڝكزك؃كككجؠؠكئكټنسكڝنقكدكنكضكآكضكڪنزك؃نككئدؠكضؠټكسكڝؠقكدڪنكجكآكزكڪكزك؃ؠككحؠؠكئڝټكقكڝكقكدؠنكجؠآكسحڪكقؠ؃كككحآؠكئڪټكسكڝكنكدكنكجآآكضآڪكزټ؃كنؠحكؠكئټټكسڪڝكقكدكآكجكآكضټڪكزټ؃كندحكؠكئكټكسنڝكقټدكنكجكآكضكڪكزك؃كككحكؠنئكڪؠسكڝكقكدكؠكجكآكضكڝؠزك؃ككنحكؠنئكټكسكدكقكدكننجكآنضك؃دزكدؠككحكؠؠئكټڪسكڝكقكجكنكجكآؠضكڪؠزك؃ڝككئكؠكئكټؠسكڝؠقكححنكئؠآكضكڪآزك؃ڪككحكؠكسكټكسكڝآقكدآنكجټآكسؠڪكزك؃ټككحڪؠكئكټكقكڝكقكدټنكجټآكسدڪكزك؃كككحنؠكئټټكسكڝكقكدكنكجكآكضكڪكزن؃كنؠحكؠكئكټكزكڝكقكدكؠؠجكآكضنڪكزن؃كككحكټكئكټكسنڝكقندكآدجكټؠضكڪكزؠ؃ككڪحكؠكئكڝكسكڝكقؠدكنؠجكآڝضكڝؠزك؃ككآحكؠڪئكټكسكدكقكدكنآجكآآضكڪټزكدؠككحكؠټئكټڪسكڝكقكجكنكجكآټضكڪټزكددككئكؠكئكټټسكڝټقكححنكجكآكضكڪنزك؃ټككحكؠكئكټكسكڝكقكدكنكجنآكسؠڪكزك؃كككجكؠكئكټكزؠڝكقكدننكجنآكضكڪككك؃كككحنؠكئنټكقدڝككؠدكنكجؠآكضڪڪكزك؃كؠكحكؠكئؠټكسؠڝكقڝدكؠؠجكآكضآڪكزڪ؃كككحكټكئكټكسآڝكقآدكنټجكټؠضكڪكزټ؃ككڪحكؠكئكڝكسكڝكقټدكنټجكټدضك؃كزك؃ككټحكؠټئكڪحسكڝكقكدكننجكآټضكڪكزك؃كككحكؠكئكټكسكڝنقكحؠنكجكآكضكڝكزك؃كككجؠؠكئكټنسكڝنقكدكنكضكآكضكڪنزك؃نككئدؠكضؠټكسكڝؠقكدڪنكجكآكزكڪكزك؃ؠككحؠؠكئڝټكقكڝكقكدؠنكجؠآكسحڪكقؠ؃كككحآؠكئڪټكسكڝكنكدكنكجآآكضآڪكزټ؃كنؠحكؠكئټټكسڪڝكقكدكآكجكآكضټڪكزټ؃كندحكټكئكټكسټڝكقټدكؠحجكآكضكڪكزن؃ككټحكؠكئكټكسكڝكقكدكنكجكآنضكڝؠزك؃كككحكآكئكټكسك؃ؠقكدكننجكآنضكڪكزكحكككحكؠنئكټنسكددقكحؠنكجكآؠضكڪڪزك؃كككئكؠكئكټؠسكڝؠقكدڝنكضكآكضكڪؠزك؃ؠككجحؠكضؠټكسكڝآقكدڪنكجكآكزكڪكزك؃آككحآؠكئټټكزؠڝكقكدټنكجڪآكضكڪككك؃كككحټؠكئټټكزدڝكنكدكنكجټآكضټڪكقح؃كككحكؠكئنټكسټڝكقكدكنكجكآكضكڪكزك؃ككنحكآؠئكټكسكڝكككدكنكجكټؠضكڪكزن؃ككنحكؠكئكڝكنئڝكقندكننجكڪدضكڝؠكس؃ككؠحكؠڪئكټكسكدكقكدكنؠجكآؠضكڪڝزكحكككحكؠؠئكټؠسك؃حقكحؠنكجكآآضكڪڪزك؃كككئكؠكئكټآسكڝآقكدټنكئؠآكضكڪټزك؃ڪككحكؠكسكټكسكڝټقكدټنكئدآكزكڪكزك؃ټككحټؠكضحټكسكڝكقكدننكجټآكضكڪكزك؃كككحكؠكئكټكسنڝككؠدكنكجكآكسكڪكزك؃كنؠحكؠكئنټكسنڝكقكدكآكجكآكضنڪكزن؃كؠدحكآؠئكټكسؠڝكقڪدكنكجكڪكضكڪكزؠ؃ككؠحكؠڝئكڝكسكڝكقؠدكنؠجكټحضكڝؠزك؃ككآحكؠڪئكټكسكدكقكدكنآجكآآضكڪټزكدؠككحكؠټئكټڪسكڝكقكجكنكجكآټضكڪټزكددككئكؠكئكټټسكڝټقكححنكجكآكضكڪنزك؃ټككحكؠكئكټكسكڝكقكدكنكجنآكسؠڪكزك؃كككجكؠكئكټكزؠڝكقكدننكجنآكضكڪككك؃كككحنؠكئنټكقدڝككؠدكنكجؠآكضڪڪكزك؃كؠكحكؠكئؠټكسؠڝكقڝدكآكجكآكضؠڪكزؠ؃كنئحكآؠئكټكسآڝكقڪدكنكجكڪكضكڪكزآ؃ككآحكؠټئكڪؠسكڝكقټدكنڪجكآكضك؃كزك؃ككټحكؠټئكڪدسكڝكقكدكننجكآټضكڪكزك؃كككحكؠكئكټكسكڝنقكحؠنكجكآكضكڝكزك؃كككجؠؠكئكټنسكڝنقكدكنكضكآكضكڪنزك؃نككئدؠكضؠټكسكڝؠقكدڪنكجكآكزكڪكزك؃ؠككحؠؠكئڝټكقكڝكقكدؠنكجؠآكسئڪكقؠ؃كككحآؠكئڪټكسكڝكنكدكنكجآآكضآڪكزټ؃كنؠحكؠكئټټكسڪڝكقكدكآكجكآكضټڪكزټ؃كندحكؠكئكټكسنڝكقټدكنكجكآكضكڪكزك؃كككحكؠنئكڪؠسكڝكقكدكؠكجكآكضكڝؠزك؃ككنحكؠنئكټكسكدكقكدكننجكآنضك؃دزكدؠككحكؠؠئكټڪسكڝكقكجكنكجكآؠضكڪؠزك؃ڝككجؠؠكئكټآسكڝڪقكدكنكضكآكضكڪآزك؃آككحټؠكضؠټكسكڝټقكدڪنكجكآكزكڪكزك؃ټككحټؠكضدټكقكڝكقكدټنكجټآكسئڪكزك؃كككحنؠكئټټكسكڝكقكدكنكجكآكضكڪكزن؃كنؠحكؠكئكټكزكڝكقكدكؠؠجكآكضنڪكزن؃كككحكټكئكټكسنڝكقندكآدجكټؠضكڪكزؠ؃ككڪحكؠكئكڝكسكڝكقؠدكنؠجكآڝضكڝؠزك؃ككآحكؠڪئكټكسكدكقكدكنآجكآآضكڪټزكدؠككحكؠټئكټڪسكڝكقكجكنكجكآټضكڪټزكددككئكؠكئكټټسكڝټقكحئنكجكآكضكڪنزك؃ټككحكؠكئكټكسكڝكقكدكنكجنآكسؠڪكزك؃كككجكؠكئكټكزؠڝكقكدننكجنآكضكڪككك؃كككحنؠكئنټكقدڝككؠدكنكجؠآكضڪڪكزك؃كؠكحكؠكئؠټكسؠڝكقڝدكآكجكآكضؠڪكزؠ؃كنئحكآؠئكټكسآڝكقڪدكنكجكڪكضكڪكزآ؃ككآحكؠټئكڪؠسكڝكقټدكنڪجكآكضك؃كؠئ؃ككټحكؠټئكڪدسكدكزڝدكنټجكآټضكڝئزك؃كككحكؠنئكټټسكڝكقكدكنكجكآكضكڪكزك؃نككجؠؠكئكټكسك؃كقكدكنكئؠآكضكڪنزك؃نككحكؠكسكټكسكڝنقكدننكضدآكسؠڪكزك؃ؠككحڪؠكئكټكقكڝكقكدؠنكجؠآكضڝڪككك؃كككحؠؠكئؠټكزئڝككؠدكنكجآآكضڪڪكزك؃كؠكحكؠكئآټكسآڝكقټدكؠؠجكآكضټڪكزڪ؃كككحكټكئكټكسټڝكقټدكؠدجكڪكضكڪكزټ؃ككټحكآئئكټكسكڝكقندكنټجكآكضكڪكزك؃كككحكؠكئكټنسك؃ؠقكدكنكجكټكضكڪكزكدؠككحكؠنئكټنسكڝكقكجكنكجكآنضكڪنزكحدككجؠؠكئكټؠسكڝڪقكدكنكضكآكضكڪؠزك؃ؠككحڝؠكسكټكسكڝؠقكدؠنكئئآكسؠڪكزك؃آككحڪؠكئكټكقكڝكقكدآنكجآآكضټڪكقؠ؃كككحټؠكئڪټكسكڝكنكدكنكجټآكضټڪكقد؃كؠكحكؠكئټټكسټڝككئدكنكجكآكضنڪكزټ؃كككحكؠكئكټكسكڝكقكدكننجكټؠضكڪكزك؃كنكحكؠكئكڪؠسكڝكقندكننجكآكضك؃كزك؃ككنحكؠنئكڝدسك؃ؠقكدكنؠجكآڪضكڪكزكحكككحكؠؠئكټؠسكڝڝقكجكنكجكآؠضكڪؠزكدئككجؠؠكئكټآسكڝڪقكدكنكضكآكضكڪآزك؃آككحټؠكضؠټكسكڝټقكدڪنكجكآكزكڪكزك؃ټككحټؠكضدټكقكڝكقكدټنكجټآكسئڪكزك؃كككحنؠكئټټكسكڝكقكدكنكجكآكضكڪكزن؃كنؠحكؠكئكټكزكڝكقكدكؠؠجكآكضنڪكزن؃كككحكټكئكټكسنڝكقندكآدجكټؠضكڪكزؠ؃ككڪحكؠكئكڝكسكڝكقؠدكنؠجكآڝضك؃كزك؃ككؠحكؠؠئكڪحسك؃ؠقكدكنآجكآڪضكڪكزكحكككحكؠآئكټآسكڝټقكحؠنكجكآټضكڪڪزك؃كككئكؠكئكټټسكڝټقكحدنكضكآكضكڪټزك؃ټككجئؠكئكټكسكڝنقكدټنكجكآكضكڪكزك؃كككحكؠكئنټكزؠڝكقكدكنكئكآكضكڪكقؠ؃كككحنؠكئنټكسكڝكنكدكنكجنآكضنڪككد؃كنؠحكؠكئؠټكسڪڝكقكدكآكجكآكضؠڪكزؠ؃ككڝحكټكئكټكسؠڝكقؠدكؠحجكټؠضكڪكزآ؃ككڪحكؠكئكڝكسكڝكقآدكنآجكآټضكڝؠزك؃ككټحكؠڪئكټكسكدكقكدكنټجكآټضكڝدزكحكككحكؠټئكټټسك؃ئقكدكنكجكآنضكڪټزك؃كككحكؠكئكټكسكڝكقكدننكئؠآكضكڪكزكدكككحكؠكضؠټكسكڝنقكدننكجكآكزكڪكزك؃نككحنؠكسدټكزؠڝكقكدؠنكجڪآكضكڪككك؃كككحؠؠكئؠټكسڝڝكنكدكنكجؠآكضؠڪكقئ؃كنؠحكؠكئآټكسڪڝكقكدكآكجكآكضآڪكزآ؃ككټحكآؠئكټكسټڝكقڪدكنكجكڪكضكڪكزټ؃ككټحكآدئكڝكسكڝكقټدكنټجكټحضكڪكزك؃ككنحكؠټئكټكسكڝكسقدكنكجكآكضكڪنزكدؠن؃حكؠكئكڪكسكڝكقكحؠنكجكآنضكڪنزك؃كككئكؠكئكټنسكڝنقكجدنكئؠآكضكڪؠزك؃ڪككحكؠكسكټكسكڝؠقكدؠنكجڝآكزكڪكزك؃ؠككحؠؠكضئټكزؠڝكقكدآنكجڪآكضكڪككك؃كككحآؠكئآټكسټڝككؠدكنكجټآكضڪڪكزك؃كؠكحكؠكئټټكسټڝككددكآكجكآكضټڪكزټ؃كنححكؠكئكټكسنڝكقټدكنكجكآكضكڪكزك؃كككحكؠنئكڪؠسكڝكقكدكؠكجكآكضكڝؠزك؃ككنحكؠنئكټكسكدكقكدكننجكآنضك؃دزكدؠككحكؠؠئكټڪسكڝكقكجكنكجكآؠضكڪؠزك؃ڝككئكؠكئكټؠسكڝؠقكحئنكئؠآكضكڪآزك؃ڪككحكؠكسكټكسكڝآقكدآنكجټآكسؠڪكزك؃ټككحڪؠكئكټكقكڝكقكدټنكجټآكسدڪككك؃كككحټؠكئټټكزحڝكقكدكنكجنآكضټڪكزك؃كككحكؠكئكټكسكڝكقندكؠؠجكآكضكڪكقك؃كككحكآؠئكټكسنڝكقندكنكجكڪكضكڪكزن؃ككنحكټدئكڪؠسكڝكقؠدكنڪجكآكضك؃كزك؃ككؠحكؠؠئكټڝسكدكقكدكنؠجكآؠضكڝئزكدؠككحكؠآئكټڪسكڝكقكجكنكجكآآضكڪآزك؃ټككجؠؠكئكټټسكڝڪقكدكنكضكآكضكڪټزك؃ټككجدؠكسكټكسكڝټقكدټنكئحآكضكڪكزك؃نككحټؠكئكټكسكڝكقكدكنكجكآكضنڪكقؠ؃كككحكؠكضكټكسكڝككؠدكنكجنآكضنڪكزك؃كؠكحكؠكئنټكسنڝكنددكؠؠجكآكضؠڪكزڪ؃كككحكټكئكټكسؠڝكقؠدكنڝجكڪكضكڪكزؠ؃ككؠحكآحئكڪؠسكڝكقآدكنڪجكآكضك؃كزك؃ككآحكؠآئكټټسك؃ؠقكدكنټجكآڪضكڪكزكحكككحكؠټئكټټسك؃دقكجكنكجكآټضكڪټزكدئككحكؠكئكټنسكڝټقكدكنكجكآكضكڪكزك؃كككحنؠكضؠټكسكڝكقكحكنكجكآكسؠڪكزك؃نككحنؠكئكټكقكڝكقكدننكجنآكزدڪكقؠ؃كككحؠؠكئڪټكسكڝكنكدكنكجؠآكضؠڪكزڝ؃كؠكحكؠكئؠټكسؠڝككحدكؠؠجكآكضآڪكزڪ؃كككحكټكئكټكسآڝكقآدكنټجكټؠضكڪكزټ؃ككڪحكؠكئكڝكسكڝكقټدكنټجكټدضك؃كزك؃ككټحكؠټئكڪئسكڝكقكدكننجكآټضكڪكزك؃كككحكؠكئكټكسكڝنقكدكنكجكآكضكڪنزك؃كككحكؠكئكټكسكڝټقكدكنكسسآټضكڪكزكز؃ڝنكسدڪڝزڝنسكڝكقكقددټنټجكآآحجنقجق؃كقنحآؠټجڪآؠسحڝزئز؃آنقجسققضؠټنق؃آقكد؃ڪؠڝئ؃ندحټټنزؠنؠئجآكضكڪكڪضزقڝنقټحآؠټئؠټحسزڝ؃زدؠضجكآكضكجدڪټزټ؃كز؃دڪؠټدنټآزحڝززآؠدجكآكضكڝؠئئ؃كككحكؠآئكټكسك؃ؠقكدكننجكآنضكڪكزكحكككحكؠنئكټنسكڝټقكحؠنكجكآآضكڪؠزك؃كككحكؠكئكټنسكڝآقكدكنكجكآكضكڪكزك؃كككحؠؠكئكټكسكڝكقكدننكجنآكضكڪكزك؃كككحنؠكئكټكسكڝكقكدكنكجټآكضكڪكزؠدضككحكؠككدئټټټسكټ؃زڪدټزنجآټحضزټآجسنجحكؠكئكئضټقضنڪټقآدټنؠجحآزض؃ضححنككحكؠكؠدئټټټسكڝآضجټقسقجكؠنضآڪټسڪڝؠكححزززجآټقسسؠققؠ؃نؠ؃ڝقآئجڪنټضڝد؃زڝدټكئؠحسټڝكقكدكد؃كنجسؠڪڝدزك؃كككجؠقئئكټكسكڝؠقكدكنكئؠآكضكڪنزك؃ټككحكؠكسكټكسكڝنقكدننكجنآكسؠڪكزك؃آككحآؠكئكټكسكڝكقكدننكجآآكضكڪكزك؃كككحكؠكئكټكسؠڝكقكدكنكجكآكضنڪكزن؃كككحكؠكئكټكسنڝكقكدكنكجكآكضكڪكن؃؃كككحكددئټټكسكڝكټززندسكڪززضڝڪكزك؃كټآسڝحؠننئسآڪضدقڪدكنكجكدقټ؃ضزټڪزؠكؠجضؠكئكټكؠقسؠڝحق؃دحنزدآآنضڪټنزؠڝڪحكسسئكټكسكڝكقكدكؠدزكئآضڪڪكزك؃كڪڝقنحضؠڪجڪڪآ؃ئقكدكنكقضجقؠآئنڪضضك؃ضقنجحنڪئؠآد؃جقكدكنكزڝجحآؠئڪآآسڪ؃ؠكڝدڪؠؠجدزئڝكقكدكڝحنزجټؠڪضؠټنسآ؃ټكححقؠزضآسټڝكقكدكح؃كنجحآټسآق؃؃كككحكحآنڪئؠټڝسحڪآزڪحؠجكآكضكڪكزك؃كزكسقكحضضټكسكڝكټققؠدحن؃جحآزحآؠڝزؠڝنكسدڪڝزڪ؃سكڝكقكسڝ؃ڪكآجټآقضؠنآجسنؠحكؠكئكحكټؠسقڝكزڪدؠنټئحنكضڪڪؠسآ؃دقنحآؠحئزټ؃ض؃قكدكنكجكآكضك؃ټؠكجسنححكؠكئكج؃ټقسؠڝئقآدككنحآؠڪسآزآ؃كككحكڝؠننئزآدد؃قكدكنكزآجضآحئڪڪززټڪككڪحؠنآئدآنسآڪڪزټڝكنؠجقآكئڪڪؠزټدحضسآجئكټكسكئكڝؠققدككڪجؠآټضحټڪزآكؠحآؠكئكټكټزضڪ؃؃آزؠئجكآكضكج؃ټڪزټټآكدححؠضجټټؠضڪڝزدؠؠكجكآكضكجدڪڪزسڝنكزحقؠحجټؠؠسقڝققټڝككنجؠآټكزقح؃كككحكڝآؠدجنټؠضنڪآقټ؃ڪنؠززسحڪكزك؃كد؃كقحؠؠئئآټكضنڪآزڪنؠجټآكضكڪكڪ؃سن؃سقڪڪسضئټكسكڝكټؠزڪدسنقجټؠڪحڪڪڝسڪ؃زكټددئټټكسكڝكټجقڪدسنكآؠسنڪكزك؃كڪؠقڪحكؠضئحآآضنڝټزڪ؃ټقآجټآقضؠټنز؃ڝڪحټؠنئؠڪ؃سكڝكقكسكدضكنئحؠڪضؠڪآؠزكڪحكؠكئكئكآنسحڝؠقآضزجنآكضكڪكڪكقؠججآحضحڪحزح؃حؠحآقڝدنكجكآكضكڪكزك؃كككقدآدئكټكسكئدڝڪقس؃ننزجقآحئټټدددككحكؠككحئزټآسټڪنقز؃آكڪئآسزڪكزك؃كټڝكححزنټدڝټحسؠڝآقټڪآندجحآضئټڪئ؃كككحكآؠسڝټكسكڝكنندكنكجكټؠضكڪكزن؃كؠجحكؠكئكڝكسكڝكقندكننجكټڪضك؃كزك؃ككنحكؠنئكڝ؃سكڝكقكدكننجكآؠضكڪكزك؃كككحكؠكئكټكسكڝؠقكدټنكجكآكضكضدزك؃نككئكض؃ئكټڪسكڝټقكئ؃نكئؠجحضكڝ؃زك؃آككحكؠكئكدڪسكڝڪقكح؃نكجؠآكضڝسززك؃ڪكككدؠكئنټكسكڝكقټكآنكجكآكآدڪكزن؃كؠكآ؃ؠكئڪټكسټڝكؠ؃دكؠؠنحآكس؃ڪكزټ؃كككحكؠكقڪټكسڪڝكك؃دكنؠجكآڝ؃زڪكزڪ؃كنؠحكؠنئكټنسكڝټ؃آدكنكجكټؠضكڪنزك؃ټدآحكؠكئكئدسكڝنقكجكڪئجكآڪضكڪټزك؃آككئكڝئئكټڪسكڝڪقكح؃نكضڝدزضكڪڪزكح؃ككحنؠكئڪټكسټزآقكدكنكض؃آكضنڪكزټقآككحكؠكؠدټكسنڝككؠڝكنكجڪآكزئڪكزك؃كؠكڝزؠكئڪټكسڪڝكنزدكآكجكآكضڪڪكزڪ؃كنكحكټكئكټكسڪڝكقڪدكؠټجكڪكضكڪكزڪ؃ككڪحكآحئكټكسكڝكك؃دكنټجكآكضك؃كزك؃كندحكؠټئكټټسكدكقكدكؠدجكټدضكڝززكحكككحكآدئكڪدسك؃؃قكجكنكجكټدضكڝدزكحؠككجؠؠكئكڪحسك؃ققكدكنكضكآكضكڝحزكدحككجڝؠكضؠټكسك؃جقكجټنكجكآكسؠڪكزكدئككحڝؠكئكټكزؠڝكقكحضنكضټآكضكڪكزك؃كككجحؠكضضټكسؠڝكقكدكنكئدآكسدڪكقح؃كككحكؠكئڪټكزدڝكقندكؠؠجكآكضڪڪكقئ؃كككحكآؠئكټكسڝڝككسدكنكجكآكضكڪكزڪ؃ككؠحكؠنئكڪؠسكڝكقڪدكآڝجكآكضك؃كزك؃ككڪحكؠڪئكڪڝسك؃ؠقكدكنڝجكڪضضكڪكزكدؠككحكآ؃ئكڝئسكڝكقكجكنكجكټ؃ضكڝ؃زكدضككجؠؠكئكڪحسكدزقكدكنكجكآكضكڝ؃زكدحككحؠؠكسكټكسك؃؃قكح؃نكئجآكضكڪكزك؃ڪككج؃ؠكئؠټكككڝكقكدڪنكجنآكسآڪكقؠ؃كككحڪؠكسنټكسكڝككؠدكنكجڝآكزئڪكزك؃كؠكحكؠكئڝټكسڝڝككؠدكآكجكآكضڝڪكزڝ؃كنڪحكټكئكټكسڝڝكقڝدكآ؃جكآكضكڪكزڝ؃كن؃حكؠكئكټكسكڝكقڪدكنكجكټ؃ضكڪټزك؃كككحكدڝئكټنسكدكآئدكؠججكټحضكڪآزكحكزئحكآجئكڪجسك؃؃قكحؠنكجكټئضك؃ئزك؃كككئكؠكئكڪئسك؃ئقكجكنكضكآكضكڝئزكدئككجدؠكئڝټكسك؃جقكزڝنكجنآكسئڪكزټقآككحكؠكنڝټكسنڝككؠڝكنكئجآكزئڪكزك؃كؠكحكؠنضجټكزجڝكنكدكآكجكآكسجڪكقج؃كندحكټكئكټكزجڝككجدكآحجكڪكضكڪكقج؃كنجحكټڪئك؃كسكڝككجدكآسجكڪقضكڝؠزك؃كنجحكآئئكټكسك؃ؠقكدكؠئجكڪآضكڪكزك؃كككحكآجئكټؠسكڝنقكحؠنكجكټجضك؃ئزك؃كككئكؠكئكڪجسك؃جقكجكنكضكآكضكڝجزكدجككجدؠكسكټكسك؃جقكحجنكضحآكزكڪكزكدجككججؠكسدټكقكڝكقكحئنكئحآكضټڪككك؃كككجئؠكضئټكسؠڝككؠدكنكئضآكسقڪكزك؃كؠكحكؠكضضټكزضڝككڝدكؠؠجكآكسسڪككټ؃كككحكآؠئكټكززڝككندكنكجكټؠضكڪكقق؃كؠټحكؠكئكټكسكڝككضدكؠقجكآؠضكڪكزك؃كنئحكآئئكڪضسك؃كقكدكؠججكآؠضكڝئزكدؠككحكآجئكڝئسكڝكقكجكنكجكټجضكڝجزكحكككئكؠكئكڪجسك؃جقكحدنكضكآكضكڝجزكدجككئحؠكسكټكسك؃جقكحجنكضڪآكقكڪكزكدجككئسؠكسقټكزؠڝكقكحجنكئئآكضكڪكقؠ؃كككجئؠكسآټكسكڝكقكدكنكئجآكضؠڪكزن؃ككڝضضؠكئڪټكنزڝكقندكنؠجكآټټآڪكزك؃كټزحكؠنئكټڝكضڝكقكدكؠ؃جكآنضكڪؠزك؃ټدآحكؠكئكڪ؃سكڝنقكدكؠټجكآكضكڪنزك؃كككحكؠؠئكټكسكڝكقكدكنكئسآكضكڪكزؠ؃ڝككحكؠكقآدڝټؠضنڝسزڪټسئ؃آكضكڪكآڝسڪڝآكټحقؠؠ؃آدزڝآقكدكنكنزحڪټ؃كززټ؃كككحكج؃ننئحټټڝنقكدكنكجكآكضكڪكزكجضككحكؠكئكټكنكئټآككآنآجكآكضكضؠټنسټئسحكؠكئكټكسكڝكنټضك؃؃جكآكضكڪكزك؃كقكسقكدئكټكسكڝكقكككڝڝزكزسضكڪكزك؃كككټكحآقكټؠسټڝكقكدكدسكنجټآدآحزڝ؃كككحكڝنؠزئ؃ټضضڪڝآجسنكجكآكسؠضحزك؃كككجحؠكئكټكزؠسحقكدننكئدآكضكڪكقؠزحككحؠؠكضحټكسكڝكقټضڝنكجكآكزضڪكزن؃كنؠ؃كؠكئټټكسټڝكقكدكنكسجآكضټڪكزن؃ككنحكؠكئكټكسټڝكقكدكنكجكټؠضكڪكزڪ؃ككنحكؠكئكڝكسكڝكقڪدكنڪجكآآضكڝؠزك؃ككڝحكؠؠئكټكسكدكقكدكنڝجكآڝضكڪآزكدؠككحكآ؃ئكڪئسكڝكقكحؠنكجكټدضكڪڪزك؃كككجؠؠكئكڪحسكڝڝقكدكنكجكآكضكڪڝزكدحككحكؠكئكټكسكڝڪقكدكنكجؠآكسؠڪكزك؃ڝككحنؠكئكټكقكڝكقكدڝنكجڝآكسسڪكقؠ؃كككج؃ؠكضضټكسكڝكنكدكنكئ؃آكس؃ڪكق؃؃كنؠحكؠكضدټكزجڝكقكدكنكجكآكس؃ڪكزؠ؃ككؠحكآؠئكټكزدڝكقڪدكنكجكټؠضكڪكقح؃ككڪحكؠكئكټكسكڝكقڝدكؠحجكآؠضكڪكزك؃ككڪحكؠڪئكټڝسك؃كقكدكنټجكآنضكڪڪزك؃ټز؃حكؠكئكټټسكڝنقكدكؠټجكآكضكڪنزك؃كككحكؠكئكټكسك؃دقكدكنكؠآآټضكڪكزكز؃ڝنكسدڪآؠټكسكڝكقكدكنكحك؃ق؃سڪكزك؃كككحكؠكزټدككس؃جقكدكنكزڝجحآؠئڪآآسڪ؃ؠكڝدڪؠؠټؠزكڝكقكدكڪآنضجحؠڪضزڪټضح؃آسټحؠننئ؃ټ؃سحڝزق؃؃دجټآكضكڪكڝ؃سن؃حكټددضئټكسكڝكټحقزدټكڪجؠؠنئآڪټزح؃قكزڪسضنټكسكڝكټؠزڪدكنضجحؠآئنڪټسڪڝټزآحټؠقئؠآنس؃ڪڪحقنكجكآكسؠضحزك؃كككحؠؠكئكټكزؠسحقكدننكجآآكضكڪكقؠزحككحؠؠكئؠټكسكڝكقټضڝنكجكآكسزڪكزن؃كنؠ؃كؠكئټټكسڝڝكقكدكنكدڪآكضټڪكزن؃ككنحكآؠئكټكسټڝكقندكنكجكڪكضكڪكزټ؃ككټحكآدئكڝكسكڝكقټدكنټجكټ؃ضك؃كزك؃ككټحكؠټئكټڪسكدكقكدكنټجكآټضكڪټزك؃كككحكؠڝئكټكسكڝكقكدكنكجكآټضكڪڝزك؃نككحټك؃ئكټكسكڝټقكدننكجكټټضكڪكزك؃نككحكؠكئكڪنسكڝكقكآزؠزجكآكضكئڝڪحززڝټسڝححؠؠئآټټجآڝدقحدضكټڝضضكڪكزك؃كككحكټدقك؃سزئڝكقكدك؃؃نقجقؠټجآټڪسآ؃ټكححقؠزجدسټڝكقكدكڝزكنجسؠڪدسقئ؃كككحك؃ضؠقجآآنسضټكقض؃نؠححڪآؠئدزآ؃كككحكحآؠڪجؠئدڝكقكدكنكجكآكئكحقضح؃ڪككحكؠكؠكجنټحسؠڝآزدنڝجكآكضكجضڪقزق؃آقڪدقڝزڪحسكڝكقكسضدقن؃دسآقئټټڪزض؃آ؃حآئئكټكسكئ؃ڪڪقټڪآندجحآضئټڪؠسڪ؃زحؠآحئكټكسكز؃ڝققؠدئنآجكؠنئآټڪؠزكڪحكؠكئكحڝآنسضڝڪزڪ؃دئ؃آكضكڪكآكزضڝننحدڪؠؠئآسؠڝڪقكدكنكققئ؃آزئڪڪؠسدكڪحكؠكئكئآټكضن؃؃قزټسجټآكضكڪكڪ؃سن؃سقڪڪټئكټكسك؃ؠنڝدكنكجكټدضكڪكزكدؠككحكؠنئكڪضسكڝكقكجكنكجكآنضكڪنزكدجككئكؠكئكټنسكڝنقكحئنكجكآكضكڪنزك؃ؠككحكؠكئكټكسكڝكقكدكنكجؠآكضټڪكزك؃كككضنؠكئنټكقكجئقكدڪنكجټآكضټڪكككدسككحڪؠكئڪټكسڝڝككؠدكنكئ؃آكس؃ڪكزك؃كنؠحكؠكضدټكسؠڝكقكدكنكجكآكضڪڪكقد؃ككؠحكټڝئكټكسڪڝككقدكننجكټحضكڪټڝآ؃كككحكآقئكټنسكڝټ؃آدكنكجكڝكضكڪنزكحكج؃حكؠڪئكټټسكڝنقكحؠدحجكټ؃ضكڝقزك؃كككحكڝڪئكټڪسك؃؃قكدؠنكجڝززضكڪڪزكدڪككحنؠكئنټكسټزآقكدكنكئڪآكضنڪكزټقآككحكؠكزكټكسنڝكنكضئنكجڪآكضټڪكقق؃كؠكئآؠكئڪټكسڪڝككسدكؠؠجكآكضڝڪكقن؃كككحكټكئكټكسڝڝكقڝدكؠزجكڪكضكڪكزڝ؃ككڝحكؠڪئكټڝسكڝكقڪدكآسجكآنضكڪڝزك؃ټدآحكؠكئكڝسسكڝنقكدټحآجكآكضكدكزك؃نككجؠككئكټڪسك؃دقكدكنكضكس؃ضكڪڝزك؃ټككجئؠكئكټآسكڝڝقكح؃نكجكآكضكڪسزك؃ڪككحكؠكض؃ټكسټزآقكدكنكسجآكضنڪكككئئككججؠكضحټكسټڝكنڝححنكئجآكقحڪكزن؃ككآحكؠټآآټكسكڝكؠحدكننجكټؠجكڪكقج؃كنكحكؠكئكټڝڝټڝككئدكنكجكآنضكڪنزك؃كآدحكؠكئكڪحسكڝكقكدكؠئجكټجضكڪؠزك؃نككحكټ؃ئكڪدسكڝكقكدكنكجڝڝضضكڪڪزكحؠككحنؠكئؠټكسټزآقكدكنكضؠآكضنڪكقؠڪكككحڪؠكضكټكسكڝكقڝنټنكجڝآكضنڪكزن؃ككنحكؠكزدټكسكڝكقټدكنكجكآكسئڪكزڪ؃ككؠحكؠنئكټكق؃ڝكقآدكنكجكآكضكڪڝنض؃كككحكآ؃ئكټنسكڝؠقكدټحآجكآكضكڝ؃زك؃نككحكآټئكټكسكڝنقكدكنكجكآكضكڪكزك؃ټككحكؠكآآټټسكڝكقكق؃؃ننسحڪ؃زڝضزك؃كككزدحټؠټئكؠ؃ضڪڝټضندآؠحجزؠآڪؠقج؃كككحكحضؠقجنآټسآڝټقؠدحنزج؃ضؠ؃نزك؃ككككدحټؠټئكټآججؠقئقدككنجآآټئڪټؠزح؃زضزدآؠقئسكقسؠڪنك؃ټققججؠآڝجدنڪضڝڝحقجآدئكټكسك؃ؠضئدكنكجكآآضكڪكزكدؠككحكؠنئكټنسكڝكقكجكنكجكآنضكڪنزك؃ؠككجؠؠكئكټآسكڝټقكدكنكجكآكضكڪنزك؃آككحكؠكئكټكسكڝكقكدكنكجؠآكضكڪكزك؃كككحنؠكئنټكسكڝكقكدكنكجنآكضكڪكزك؃آككحكؠكئكټكسكڝكقآدكنكجكززسټڪكزك؃كڪآقڪحټككئؠټحسسڪنقؠححقكحنآؠضټؠآئڝ؃ؠقنحسنڪ؃سسڝڝكقكدكڝككنجؠؠڪضزڪټقآنححكؠكئكدآټدضنڝؠزن؃آنټحڪآؠڝقزك؃كككئكڝئئكټنسكڝكقكدؠنكجكقټضكڪؠزك؃كككحكؠكسكدئسكڝؠقكدؠنكجآآكضڝڪآزن؃نككحڝؠكئنټكسؠڝكقټكآنكجكآكضڝڪكزن؃ككټنآؠكئكټكززڝكقندكنكڝټآكضنڪكزن؃كككحكؠڝآزټكسنڝككزدكننجكآكضكڪټڝآ؃كككحكآزئكټنسكڝكئټدكننجكآكضكڪكزكحكټئحكؠنئكټنسكڝآقكجكئ؃جكآنضكڪنزك؃نككحكزټئكټآسكڝنقكدكنكجككضضكڪنزك؃آككحنؠكئكڪټسكڝكقكدننكجكآكضنڪكزك؃كككجحؠكئكټكئح؃زقكدكنكزڝجحآزئټؠڝزح؃ؠكآحټقآئدټحسضڪټئسؠججكآكضكج؃ټڪزټڪككضدنآحجڪټؠسآڪدحئنكجكآكنضضقټآسن؃ضزكحضننضحآڪسؠقؠحقنكجكآككؠضضټنسآ؃ئكضححؠآئټنڝسقڝضزټ؃ڪنؠنحس؃ڪكزك؃كڪككضدنآحجڪټؠسآؠسدټنكجكآكنزئنڪسسڪزححڪؠكئكټكټكضنڝحقؠدآجؠټ؃ضكڪكزكئټڝڪكآحټؠؠئقڪحڝؠقټدكنكجكج؃ؠنضسټڪحضككحكؠكضؠڝڝسكڝكقكح؃نكجكآكسؠڪكزك؃نككجحؠكئكټكقكڝكقكدننكجنآكضڪڪككك؃كككحنؠكئنټكسؠڝكقكدكنكجنآكضؠڪكزك؃كككحكؠكئكټكسكڝكقؠدكنټجكآكضكڪككح؃ككنحكټكقئټكسڪڝكقټدكنټجكڪكققڪكزڪ؃ككڪحكؠنئكڪؠسكڝكك؃دكؠحجكآكضك؃كزك؃كن؃حكآ؃ئكټڪسكدكقكدكؠ؃جكټ؃ضكڪآزكحكككحكآ؃ئكڪ؃سكڝڝقكدكنكجكآڪضكڝ؃زك؃ؠككحڝؠكئكټڪسك؃نقكدننكجنآكضټسآزك؃كككجنؠكئنټكسټزآقكدكنكضحآكضنڪكككئئككحڪؠكئټټكسټڝككؠجڪنكجڝآكسحڪكزك؃كؠكحكؠكئڝټكسڝڝكقڪدكآكجكآكضڝڪكزڝ؃ككآحكټكئكټكسڝڝكقڝدكنڝجكآكضكڪكزڪ؃ككڪحكؠڝئكڝكسكڝكقڪدكنڪجكټدضكڪكزك؃ككڪحكؠؠئكټنسكڝڝؠضدكنكجكټ؃ضكڪنزك؃ؠككحټجآئكټكسك؃؃قكدننكجكټټضكڪكزك؃نككحكؠكئكټكسكڝكقكدڝنكجكآكؠدڪټزك؃كككك؃دنؠسجڪآد؃ئقكدكنكقكجؠآحضسټنزؠدحزكدنؠؠئټسؠڝڝقكدكنكزآ؃ڝآؠئنڪسسڪدآجئؠكئكټكؠضسقڪآزندضقكجضؠنسحټڪزؠڝدجحؠكئكټكنآسدڪنقؠ؃نكآجټؠڪضؠحزد؃ككحكؠكككئضآنزحڪڪقؠدآئكآكضكڪكقؠضجككحكؠكئنټكسكڝكنكدكنكجكآكضكڪكزڝ؃كؠكحكؠكئكټكسكڝكقټدكآكجكآكضكڪكزك؃ككڪحكټكئكټكسكڝكقكدكنؠجكآڝضكڪكزك؃كندحكؠنئكټنسكڝټ؃آدكنكجكټدضكڪنزك؃ټدآحكؠكئكڪقسكڝنقكحؠقكجكآكضكڪنزك؃كككئكززئكټكسكڝكقكدڝنكضكآكضكڪكزك؃كككحټؠكسكټكسكڝكقكدكنكجڪآكزكڪكزك؃كككحكؠكئؠټكقكڝكقكدكنكجكآكضآڪكزك؃كككحكؠكئكټكسكڝكقكحټنكجكآكضنڪكزك؃كككئڪؠكئكټكدز؃؃قكدكنكزآجقآزضزټڪسآ؃ټټزآجئكټكسكئ؃ڪڪقټڝآكڪجؠآڝضحټآسڪئزججؠكئكټكؠؠسڪڝزسآ؃ڪنؠجڝآحئآټڪ؃ؠنححكؠكئكج؃ټقسؠڝئقآدككنحآؠڪدسقق؃كككحكڝؠؠضجنآآسئڝضقحدآنټ؃ڝآقضضټټسڪ؃ؠ؃حآدئكټكسكئزټقجكڝدزن؃آنئجآضحدجككحكؠكقآئدټحسضڪټضن؃ټكټحڪؠټدسزټ؃كككحكح؃ننئسآڪحسقڪدكنكجكدڝؠنضضڪڪسڪڝدجئؠكئكټكؠضسقڪآزندضقكجضؠنسحټڪزؠآسججؠكئكټكټضضنڝآقټڝڪنكحټؠنضټټڪڪحنسحكؠكئكحآټكضن؃؃قزڝضنقحآؠنضټڪحزق؃زقدآزئكټكسكجڝڝحقز؃ټزڝجحآؠضآڪټئآ؃دكححضنټضآز؃ڝكقكدكڪټكڪجآآټضؠڪققحآسحټؠكئكټكؠزضنڝسزڪنؠجټآكضكڪكآضسن؃آكټكحئآټكسكڝكټحقآڪنجؠآټضكڪكزكزټدحككدڪآآڪئسكڝكقكق؃؃ڪنټجڪآكضڝټنزض؃ڪقڪحآندټڪسكڝكقكقك؃ننحجؠآآڪؠق؃؃كككحك؃كؠضجنڪحضڪڝؠقآنؠجڪآكضكڪكټټسڪڝؠكڪح؃ڝزڪجسكڝكقكقآ؃ڪنټجڪآكضڝټنزض؃ڪقڪكحض؃ټكسكڝكآڪزڝ؃ڝكڪحآآټضآزؠد؃ككحكؠككټئقټڪضآڝدزڪ؃ټدحټ؃ضكڪكزكسآ؃قكزحزنڪجآټټنزقټدكنكجكجدآڪض؃ټڪ؃ؠندحكؠكئكجڝټڪسزڪآقټدحنقجزقسڝحزك؃كككن؃حقؠؠئئټآسكڪنزآ؃ڪجؠآټضكڪكزكززڝڪندحټئؠټټسكڝكقكقس؃ننټجدجحڝئزك؃كككك؃دڪؠټئؠآڪس؃ڝحقآدټنؠئحجحڝجزك؃كككز؃دڪؠټحكټضضن؃حزڪدؠنآززسكڪكزك؃كټؠكححزنټحټټقئؠڪڪقز؃ټكڪجؠنآضټټڪزككؠجزؠكئكټكؠ؃ضڪڝټضټ؃ڪنآحآؠڪضزټټسن؃زكټحآندڪزسكڝكقكسؠ؃ڪنزحټؠڪضؠآكزؠ؃حكقحؠؠحئټڪححسقټدكنكجك؃ڪآزضڪڪسسؠككحكؠكضؠڝڝسكڝكقكحټنكجكآكسؠڪكزك؃نككجدؠكئكټكقكڝكقكدننكجنآكسڪڪككك؃كككحنؠكئنټكقنڝكقكدكنكجنآكضؠڪكزك؃كككحكؠكئكټكسكڝكقؠدكنټجكآكضكڪككح؃ككنحكټكقئټكسڪڝكقټدكنڪجكڪكققڪكزڪ؃ككڪحكآسئكڪؠسكڝكك؃دكؠدجكآكضك؃كزك؃كن؃حكآ؃ئكڪڪسكدكقكدكؠ؃جكټ؃ضكڝجزكحكككحكآ؃ئكڪ؃سك؃ققكدكنكجكآڪضكڝ؃زك؃ؠككحڝؠكئكټڪسك؃نقكدننكجنآكضټسآزك؃كككجنؠكئنټكسټزآقكدكنكضحآكضنڪكككئئككحڪؠكئټټكسڪڝككؠجڪنكجڝآكسدڪكزك؃كؠكحكؠكئڝټكسڝڝككڪدكآكجكآكضڝڪكزڝ؃كنجحكټكئكټكسڝڝكقڝدكؠقجكآكضكڪكزڪ؃ككڪحكؠڝئكڝكسكڝكقڪدكنڪجكټزضكڪكزك؃ككڪحكؠؠئكټنسكڝڝؠضدكنكجكټ؃ضكڪنزك؃ؠككحټجآئكټكسك؃؃قكدننكئؠنكضكڪكزكددككحكؠكسكدئسكڝكقكدكنكجټآكزكحئزك؃كككحكؠكسدټكقكجئقكدكنكجكآكس؃ڪكككن؃ككحكؠكئكټكقجڝكقؠئزنكجؠآكضنڪكزك؃كككټڪؠكئكټكسؠڝكقندكؠؠجكآكضكڪكقد؃كككحكټكئكټكسكڝكقكدكؠڪجكڪكضكڪكزك؃كككحكآجئكټكسكڝكقندكننجكآكضكڝؠزك؃ككؠحكټزئكټكسك؃ؠقكدكنآجكڪسضكڪكزكحكككحكؠآئكټآسكدآقكدكنكجكآآضكڪؠزك؃ټككحټؠكئكټكسكحڝقكدننكضكس؃ضكڝ؃زك؃ڝككجنؠكضؠئحسك؃حقكحضنكجكآكضكحڪزكد؃ككجحؠكئؠټكسڝززقكح؃نكسڝآكضنڪكزك؃ككټنآؠكئكټككڝڝكقندكآكزئآكس؃ڪكزڝ؃كؠححكټكڪ؃ټكز؃ڝكك؃دكننجكآڝڪټڪكقح؃كككحكؠنئكټؠسكڝكؠددكنكجكآكضكڪكزك؃كآدحكؠكئكټنسكڝكقكدكزضجكټ؃ضكڝحزك؃نككحڝڪضئكټؠسكحئقكدننكجؠآكضټسآزك؃كككضئؠكئنټكزؠټكقكدؠنكئدآكضكڪكككنآككحؠؠكئؠټكسؠڝككؠدكنكجټآكضآڪكزك؃كككحكؠكئؠټكسټڝكقؠدكآكجكآكضؠڪكزؠ؃كؠؠحكآؠئكټكسټڝكقڝدكنكجكټؠضكڪكزڪ؃كؠڪحكؠكئكڝكسكڝكقڪدكنڪجكڪټضك؃كزك؃ككڪحكؠڪئكڪكسكدكقكدكنڪجكآڪضكڝحزك؃ڝحټحكؠڝئكټؠسكڝنقكدننكجكڝدضكڪكزك؃نككحكؠكئكنڝسكڝؠقكدڝنكجنآكسؠڪكزك؃ؠككئزؠكئكټكزؠڝكقكدآنكئڝآكضكڪككك؃كككحآؠكئآټكقكڝكقكدكنكجآآكضنڪكزټ؃ككټحكؠكئكټكآقڝكقندكؠؠدكآكس؃ڪكقؠ؃كككحكؠكآدټكزدڝكقڝدكنكجكآك؃ضڪكق؃؃ككؠحكؠؠئكڝڝؠزڝكك؃دكڝكجكآنضك؃ضزك؃ټدآحكؠكئكحكسكڝنقكدټحآجكآكضكئقزك؃نككجؠككئكڪ؃سك؃ڝقكدكنكضكضڪضكڝ؃زكد؃ككجآؠكئكټكسك؃دقكدڝنكجكآكضكڪكزكد؃ككحؠؠكئؠټكقكڝكقكح؃نكئ؃آكسئڪكزڝ؃كككج؃ؠكنقټكسنڝكقكدكنټؠآآكضكڪكټق؃ككنحكآؠحكټكز؃ڝككڝدكنكجكڪكضڪڪكق؃؃كن؃حكټ؃ئكټكسكڝككددكنڝجكآكضكڝؠزك؃كنححكآئئكټكسك؃ؠقكدكؠججكڪقضكڪكزكحكككحكآجئكڪجسكدئقكدكنكجكټ؃ضكڝجزك؃نككحټؠكئكټكسكضنقكدننكجڝڝضضكڪؠزكضجككحنؠكئؠټكسټزآقكدكنكقجآكضنڪكزكدټككحكؠكئنټكسكڝكقكدؠنكجكآكضكڪكزك؃كنزحكؠكئكقسسكڝكقكدكنكجكڝڝككڪنزك؃كككحكؠكئكڝټنكنزقآدكنكجكجؠؠنئټضح؃ټككحكؠكؠسجنټټسدسحدآنكجكآكآزئڪڝ؃جضككحكؠكئكټكسكڪكآقآسنكجكآكضكڪكزك؃كككټسؠكئكټكسكڝكآكسټسكسسټ؃ضكڪكزكضڝڝڪقآحټؠقئؠكآضدقڝدكنكجك؃آكڝضؠټنزسڝڪق؃ؠكئكټكسكڝكآكققڪكدحآڝضكڪكزكئن؃زك؃حضنڪئآكضڝكقكدكنكجكئكنڝحكټد؃ټككحكؠكآ؃جنټحسټنسدكنكجكټؠآحڪكزك؃ككڝحكؠكئكڪؠټحڝكقندكنؠجكآكضكڝؠڪح؃ككؠحكؠڝئكټكسكڝټآڝدكنكجكڪضضكڪنزكدؠزكحكؠټئكڪزسكڝكقكدكټججكآټضكڪنزك؃نككحكؠكئكټټسكڝكقكدكنكئؠآكضكڪڪزكدجككحكؠكسكټكسكڝڪقكدڪنكجڪآكسؠڪكزك؃ڝككجحؠكئكټكقكڝكقكدڝنكجڝآكضڪڪكقؠ؃كككج؃ؠكضئټكسكڝككؠدكنكئدآكضنڪكزك؃كنؠحكؠكضحټكزدڝكقكدكنكجكآكضڝڪكقح؃كككحكؠكئكټكسڪڝكقكدكنؠجكټؠضكڪكزڝ؃كنجحكؠكئكڝكسكڝكقڝدكنڝجكټضضكڝؠزك؃كن؃حكؠټئكټكسكدكقكدكؠ؃جكټ؃ضكڪآزكدؠككحكآدئكڪسسكڝكقكدكنكجكټ؃ضكڪؠزك؃ؠككجؠؠكئكڪدسك؃؃قكدكنكئؠآكضكڝحزكد؃ككحكؠكئكټكسكڝڝقكححنكجؠآكضكڪكزك؃ڪككحڪؠكئڝټكزكڝكقكدټنكئجآكضڪڪكزټڪ؃ككحكؠكئټټكسنڝكقكحټنكجكآكضنڪكزك؃كككحكؠكئكټكزدڝكقكدكقحئئآكضكڪكآحزز؃ټقڪحؠننجآټټسحڝققزقدجكآكضكڪكزك؃كقكسقؠؠضكټكسكڝكآآقضدحكڪجزآټجحڪآئټ؃ؠقنح؃ؠ؃ئحټزس؃جزحجنكجكآككڝضحڪؠسڪڪآقڪحؠؠڝجڪټؠنزقټدكنكجكج؃ؠنضسټڪ؃ؠكټحكؠكئكض؃آنسحڝټڝحؠنجكآكضكجؠټڪزك؃ضكحدآننئټآڪضټټآقټدقنؠحنآ؃ئڪضد؃كككحكؠكئكټككټجككقدكنكجكټؠآحڪكزك؃ككؠحكؠكئكڪؠټحڝكقندكؠدجكآكضكڝؠڪح؃ككؠحكؠؠئكټكسكڝټآڝدكنكجكټزضكڪنزكدؠزكحكؠټئكټڝسكڝكقكدكقڪجكآټضكڪنزك؃نككجؠؠكئكټټسكڝڪقكدكنكضكآكضكڪټزك؃ټككج؃ؠكسكټكسكڝټقكدټنكجنآكزكڪكزك؃ټككحټؠكئآټكقكڝكقكدټنكجټآكضټڪكزك؃كككحڝؠكئكټكسكڝكقكدكنكجټآكضڝڪكزن؃ككټ؃؃ؠكئكټكسټڝكقندكنكئټآكضكڪكزن؃كككحكؠكضنټكسكڝكؠسحئنكجكآكؠ؃ضقڪقسټڪآقڪدآؠټئحټقسزقؠحزنكجكآكؠڝضحڪزسټټڝكححؠؠآئټنآسدڝحقض؃ټدحټ؃ضكڪكزكضك؃ضقنجحنڪئؠټآټحكئدكنكجكدضآقئآټنزضڪككضدنآحجڪټؠڝؠقټدكنكجكدزؠنضسټڪسدكڪحكؠكئكحقڪ؃سزڪڪقؠټسجڪآكضكڪكآڝسن؃ضكڪدڪئؠټڪسكڝكقكقآدككنئ؃آزكززټ؃كككحكح؃ننئسآڪزآقآدكنكجكجآآڪئؠحزدحككحكؠكآ؃ئقټؠسئڝآقك؃نكآحڪ؃زڝئزك؃كككز؃دڪؠټدآټدسحڝضزټدؠكڪجزقسڝحزك؃كككزضحقؠ؃حسټقضټڪڪقضدآجنآكضكڪكزك؃كككئدڝكحدټكسكڝكقكدكنكحك؃قؠدڪڝزك؃كككزضحقؠقئآآڪضققؠدڪنكجكآكآكئنڪحزؠ؃آضآؠكئكټكزؠدڝقكدكنكئنآكضكڪكقؠ؃كككحنؠكضئټكسكڝكنكدكنكجنآكضنڪكقس؃كؠكحكؠكئنټكسنڝككضدكنكجكآكضنڪكزؠ؃كككحكؠكئكټكسكڝكقكدكنؠجكآټضكڪكزك؃كآكحكؠنئكڝكنئڝكقڪدكنټجكآڪضك؃ككد؃ككڪحكؠڪئكڪجسك؃ؠقكدكؠ؃جكټقضكڪكزكدؠككحكآدئكڪزسكڝكقكدكنكجكآڪضكڝدزك؃ؠككئڝؠكئكټڪسكحققكدننكئكآكضټسآزك؃كككضقؠكئنټكقكك؃قكدڪنكجټآكضؠڪكقؠزحككج؃ؠكئڝټكسكڝكقكضڪنكجڪآكس؃ڪكزؠ؃ككڝنزؠكئڪټككقڝكقندكنكجكآټټآڪكزك؃كآقحكؠنئكڝكنئڝكقڪدكنټجكآڝضك؃ككآ؃ككڪحكؠڪئكڪ؃سك؃ؠقكدكنڝجكټحضكڪكزكحكككحكؠڝئكټڝسكڝآقكجكنكجكآڝضكڪڝزك؃ټككحڝؠكئكټڪسكدئقكدننكجڝآكضټسآزك؃كككئئؠكئنټكسټزآقكدكنكسقآكضنڪكقؠڪكككحڪؠكضنټكسكڝكنكؠ؃نكجڝآكضټڪكقض؃كككحآؠكئڝټكز؃ڝكقكدكنكجسآكضڪڪكزك؃كن؃حكؠټآآټكسكڝكؠحدكننجكڪككئڪكقج؃كنححكؠڪئكڝڝؠزڝككجدكآټجكآنضكڪنزك؃ټدآحكؠكئكڝټسكڝنقكدټحآجكآكضكددزك؃نككجؠككئكڪجسك؃دقكدكنكجڝضټضكڝئزك؃كككحنؠكئنټكسكحدقكدكنكئحآكضكڪكزكدئككججؠكئؠټكسنڝكقكج؃نكئدآكضكڪكزك؃ككڝضضؠكئڪټكقكڝكقندكنؠجكآټټآڪكزك؃كؠكحكؠنئكڪؠئكڝكقڪدكؠدجكآكضكڪڝ؃ټ؃ككڝحكؠنئكټنسكڝنقكدكټدجكآكضكڪټزك؃كككحكآئئكټڪسكڝؠقكدننكجكڪ؃ضكڪآزك؃كككحكؠكئڝ؃ضسكڝكقكح؃نكجنآكضؠڪكزټقآككحكؠكض؃ټكسنڝكقكحټنكجكآكضنڪكزك؃كككحكؠكئكټكزدڝكقكدكضزجټآكضكڪكڝ؃سن؃حكټؠؠئټټكسكڝكڝ؃زندسكڪڝسسئڪكزك؃كڪضكقدآننئضؠكسضڪنكح؃ڪنؠنحسدڪكزك؃كڪدكڪحسننئزټقسحڪټزدنټجكآكضكجټټڪقد؃ټقدآحئكټكسكض؃ڪنقضدئقآجكؠڪئڪټټجسن؃حكؠكئكحكټضضن؃حزڪدؠنآآؠسحڪكزك؃كټآكددنؠؠجنآآسټڪڪقؠؠضجكآكضكڝؠضك؃كككحكؠنئكټكسكڝك؃ڝدكنكجكآنضكڪنزكدؠككحكؠكئكټؠسكڝكقكجكنكجكآكضكڪكزكد؃ككئكؠكئكټكسكڝكقكدآنكضكآكضكڪكزك؃كككجدؠكسكټكسكڝكقكدكنكجټآكضكڪكزك؃نككحكؠكئكټكقكڝكقكدننكجنآكضڪڪكقك؃كككحكؠكئڝټكسنڝكقټدكنكجكآكضكڪكزن؃كككجټؠكئكټكسنڝكقكدكنكجكآكضكڪكزؠ؃كككحكجڪئنټؠز؃ڝكقكدكڝڝنحجآآحئؠڪضسڪكآحكؠكئكټكحټڝكقكدكنكجكآكضكدكحق؃كككحكؠؠئكټنسكڝككټدكنكجكآنضكڪكزك؃كككحكؠكئكڪسسكڝكقكدؠنڪجكآكضكحآڪضزق؃زقڪسزضضټكسكڝكټكقڪدؠكآجدؠنضآټنسؠ؃ضقڪحآئؠټڪسكڝكقكقك؃ننحجؠآآدسقك؃كككحك؃كؠضجنڪحضڪڝؠضؠدضنڪحڪآكضؠڪحزز؃ټكآددض؃ټكسكڝكټكقض؃نؠححڪآؠضآټددآككحكؠكقؠئضټڪضڪڝكقؠدحنزجټنآضټڪؠزڪڝآكټحڪؠؠجڪټآټحكئدكنكجكدضآقئآټنزضڪككضدنآحجڪټؠنزقڝدكنكجكدكؠنضؠټڪزز؃ټنآآئئكټكسكئ؃ڪڪقټڪآندجحآضئټڪؠسڪ؃زحؠآجئكټكسكجؠڝضقڪ؃ڪنكجؠآحضزڪټزآكؠحټؠكئكټكټ؃ضنڝسزڪنؠئنآكضكڪكآؠسڪ؃ككضححنآجنټټضڪڪټسآدټنقجؠؠنض؃ټڪسدنجحكؠكئكحآټټسؠڝڪزآدټنڪجؠؠڪضآقڪ؃كككحكآؠق؃ټكسكڝكقآدكنكجكټؠضكڪكزن؃كنئحكؠكئكڝكسكڝكقندكننجكټضضك؃كزك؃ككنحكؠنئكټؠسكدكقكدكننجكآنضكڝسزكحكككحكؠنئكټنسكڝڝقكجكنكجكآنضكڪنزكدحككحكؠكئكټنسكڝؠقكدكنكجكآكضكڪكزك؃كككحؠؠكئټټكسكڝكقكحؠنكجنآكزكق؃زك؃ڪككحټؠكئنټكسككضقكدڪنكجؠآكضؠڪكقؠ؃كككحڝؠكضئټكسكڝكنكدكنكجڝآكضڝڪكزڪ؃كؠكحكؠكئڝټكسڝڝكك؃دكآكجكآكضڝڪكزڝ؃ككټحكټكئكټكسڝڝكقڝدكؠججكټكضكڪكزڪ؃كندحكؠڝئكټڝكضڝكقكدكؠججكآنضكڪؠزك؃ټدآحكؠكئكڪجسكڝنقكدكؠټجكآكضكڪنزك؃كككحكؠنئكټكسكڝكقكدكنكئنآكضكڪكټد؃ڝككحكؠككټجنټؠس؃ڪڪقټنؠجڝآكضكڪكآسزق؃ڝقڪ؃ټؠققزسټڝكقكدكڝزكنجسؠڪآحقد؃كككحك؃؃نڪئټؠسسقڝڪقآ؃ڪجؠټنضكڪكزكضؠڝڪككحضؠحجآآنسټڪڪزټڝآنټجقآؠئنڪ؃سڪڝدجضؠكئكټكؠقسؠڝحق؃دحنزدآآنضڪټنزؠڝڪضسآئئكټكسكئحڝزقټ؃ڪنؠحنؠآضټڪحزق؃ز؃حآئئكټكسكئضڝقزآ؃ننضدكآضئنڝحسڪ؃ؠحنؠكئكټكسكڝكقك؃كڪقڪزټجضكڪكزكئڝ؃حكؠدڪكآجڪټؠسڝڪڪقؠحآئ؃آكضكڪكآكزضڝننحدڪؠؠئآئدڝكقكدكنكجكآكؠححكضح؃ڝككحكؠككآئنټڪضنڝؠزڪحآئجآكضكڪكؠټزح؃آقآحقؠزئزآڪضآڝټڝحؠدجكآكضكجكڪقزآ؃حكټححؠقئزئحڝټقكدكنكن؃حنآسئڪحزدكككحكؠكقآئضټحضڪڝزقټڝحنآ؃ټآؠئنڪ؃ز؃؃حكزح؃سڪټكسكڝككؠڝسنكجكآكسكڪكزك؃كؠكحكؠكئكټكسكڝككئدكآكجكآكضكڪكزك؃كندحكټكئكټكسكڝكقكدكنټجكآكضكڪكزك؃ككؠحكؠؠئكڝكسكڝكقكدكنكجكآنضكڝؠزك؃كككحكآسئكټكسك؃ؠقكدكنكجكټسضكڪكزكحكككحكؠكئكټكسكڝآقكجڝنكجكآكضكڝضزك؃نككحڝؠكئټضآسكڝكقكحضنكجنآكضټسآزك؃كككجكؠكئنټكزؠټكقكدكنكئسآكضكڪكككئئككحكؠكئكټكسآڝكنڝححنكجكآكزټڪكزن؃كنسحكؠټآآټكسكڝكنټدكننجكآكدټڪكزك؃كككحكؠكئكڝكټدڝكقكدكنكجكټزضكڪكزك؃كككحكؠؠئكټنسكڝكقكدكنكجكآنضكڪكزكحكككحكؠكئكټكسكڝؠقكحؠنكجكآؠضكڝسزك؃كككئكؠكئكټؠسكڝؠقكحقنكجكآكضكڪكزك؃ؠككحنؠكضؠټكسكڝكقكححنكجكآكسؠڪكزك؃نككجضؠكئكټكزؠڝكقكدؠنكئحآكضكڪكزټ؃كككحكؠكسټټكسنڝككؠڝكنكجټآكسكڪكزك؃كؠكقآؠكئټټكسټڝكقڪدكآكجكآكضټڪكزټ؃كن؃حكټكئكټكسټڝكقټدكؠنجكڪكضكڪكزټ؃ككټحكآجئكټكسكڝكقڝدكننجكآكضكڪكزك؃ككټحكؠڝئكټنسكڝټس؃دكنكجكڪضضكڪنزك؃كنټحكؠكئكټنسكڝكقكدكؠڪجكآكضككزقئ؃كككحك؃؃نڪئټنآسدڝحقض؃ټنؠحڪآزآحقز؃كككحك؃آنڪئزآټئڪڝآزڪدؠقزجقآټضحټآسڪدآجحؠكئكټكآ؃سقڝؠقئدآنكحنؠآئڪنسدنككحكؠككؠجڪټكسضڝحزآ؃ننټحڪؠټجآڪټزق؃ؠقنح؃نڪ؃سز؃ڝكقكدكڝكنضحنټحئڪڪؠزآڝدحڪؠكئكټكؠڝضنڝضقڪ؃ڪؠآآټضكڪكزكز؃ڝنكسدڪندټټسكڝكقكسز؃ننسحڪؠدڝئزك؃كككسؠحڪؠټئټټقسزؠنضټدقؠ؃جزؠدڝززك؃كككقڝححؠزجټنڝسحڝؠقآدټزآجدآحضضټټسدنجحكؠكئكئآآڪسزڪټسزدقنټجحؠآئڪنسددككحكؠكك؃جڪټټئسڝققڪدآكڪڝسسضڪكزك؃كڪككضدنآحجڪټؠئسڝقزټ؃ڪنضجآقسڪڪزك؃كككزكحضننئزټئڝؠقڪدكنكجكدقټ؃ضزټڪزؠئزج؃ؠكئكټكؠزسقڝټقح؃آكڪجآ؃زڝ؃زك؃كككسآحقؠزئزآڪضآڝټڝحټضجكآكضكحآڪضزحڝآكئټكآ؃ئدآڪسؠڪڪجكححنقجڪزكس؃ټنزز؃ټئكڝنكضحضقكسټڝدزڪآكقكجضؠنضزڪئزآؠككټحقسكحټؠكدكڝټقققحجټآكضكڪكؠڝزح؃ؠقڪجآئڪټكسكڝكڝكزندحنؠجآټآڝئزك؃كككزضحقنآجنټضئكڝضزنححكڪجؠقآڪكزك؃كنؠڪڪؠكئكټكزټڝكقكدكؠؠجكآكضنڪكق؃؃كككحكټكئكټكسنڝكقندكنآجكڪكضكڪكزن؃ككنحكآسئكڝكسكڝكقندكننجكآنضكڪكزك؃ككنحكؠؠئكټكسكڝكقكدكنكجكآكضكڪؠزك؃ټككحكؠكئك؃كسكڝنقكجكڪئجكآڪضكڪټزكددككئڝآحئكټڪسكحققكدننكئزآكضټسآزك؃كككضقؠكئنټكقكك؃قكدڪنكجټآكسجڪكقؠزحككج؃ؠكضقټكسكڝكقكضڪنكجڪآكس؃ڪكزؠ؃ككڝنزؠكئڪټككقڝكقندكنكجكآټټآڪكزك؃كآقحكؠنئكڝكنئڝكقڪدكنټجكټقضك؃ككآ؃ككڪحكؠڪئكټڝسك؃ؠقكدكنڝجكټ؃ضكڪكزكحكككحكؠڝئكټڝسكڝڪقكجكنكجكآڝضكڪڝزكدڪككحڝؠكئكټڪسكددقكدننكجڝآكضټسآزك؃كككئدؠكئنټكسټزآقكدكنكسقآكضنڪكقؠڪكككحڪؠكض؃ټكسكڝكنكقؠنكجڪآكضڪڪكزټ؃كؠكحكؠكئڪټكسڪڝكككدكآكجكآكضڪڪكزڪ؃ككؠحكآؠئكټكسڪڝككئدكنكجكټؠضكڪكزڪ؃كنئحكؠكئكڝكسكڝكقڪدكنڪجكټآضكڝؠزك؃كن؃حكآؠئكټكسكڝكقكدكنڪجكټ؃ضكڪنزك؃كككحكؠڪئكټڪسكڝكقكحؠنكجكآڝضكڝ؃زك؃كككئكؠكئكټڝسكڝڝقكدڪنكضكآكضكڪڝزك؃ڝككجڪؠكسكټكسكڝڝقكدڝنكئضآكضكڪكزك؃ڝككحؠؠكئؠټكقكڝكقكدڝنكجڝآكسحڪككك؃كككحڝؠكئڝټكزنڝكقڝنټنكئدآكضكڪكزن؃ككؠحكؠكزدټكسكڝكقڪدكنكجكآكقدڪكزك؃ككټحكؠكئكټكنڪڝكقڝدكؠدجكآؠضكڪكڝد؃ككڪحكؠڝئكټكسكڝكن؃دكنڪجكآكضكڪكزك؃كؠ؃حكؠآئكټكسكڝكقكدڝټضجكآكضكڝدزك؃نككحؠؠكئټضآسكڝكقكحدنكجنآكضكڝټزك؃كككحنؠكئكټكسكڝكقكدكنكئزآكضكڪكزؠدكككحكؠكقؠجنآآسئڝ؃قؠدقنڪجزؠټحآڪقزض؃قكؠڪآآؠټكسكڝكقكدكنكنح؃كؠدڝ؃زك؃كككقڝحؠؠقئسؠؠئ؃آؠئسنټجكآكضكجقڪكسڪ؃ز؃حؠڝئكټكسكجآڝققضدقنؠڝآضؠڝ؃زك؃كككزسدڪؠزئڪؠ؃ئڪټحكآنټجكآكضكجسټنزح؃زضسؠټئكټكسكس؃ڪنقس؃ڪكدټ؃ضكڪكزكضك؃ضقنجحنڪئؠټآنزكئدكنكجكدضآقئآټنزضڪككضدنآحجڪټؠټحقټدكنكجكدسؠڪضزڪڪڪدككحكؠكئكټكسكڝكقكڝدنكجكآكضكڪكضكزقټكضسآحئكټكسكئكڝضزنححكڪجؠن؃ضڪڪححضككحكؠكضؠئڪسكڝكقكحدنكجكآكزكڪكزك؃كككحكؠكضحټكقكڝكقكدكنكجكآكسجڪككك؃كككحكؠكئكټكززڝكنكدكنكجكآكضكڪكزڝ؃كؠكحكؠكئكټكسكڝكقټدكؠؠجكآكضنڪكزڪ؃كككحكټكئكټكسنڝكقندكنآجكټؠضكڪكزؠ؃كنسحكؠكئكڪؠسكڝكقآدكؠضجكآكضكڝؠزك؃ككټحكآضئكټكسكڝكقكدكننجكآټضكڪؠزكدكككحكؠكئكټنسكڝنقكحؠنكجكآكضكڝدزك؃كككئكؠكئكټكسكڝكقكححنكضكآكضكڪكزك؃كككججؠكسكټكسكڝكقكدكنكئزآكزكڪكزك؃كككحكؠكئڝټكقكڝكقكدكنكجكآكسئڪككك؃كككحكؠكئكټكز؃ڝككؠدكنكجنآكضڪڪكزك؃كؠكحكؠكئنټكسنڝكقآدكؠؠجكآكضؠڪكزؠ؃كككحكآؠئكټكسآڝككضدكنكجكټؠضكڪكزټ؃كنضحكؠكئكټكسكڝكقندكنټجكآؠضكڝكزك؃كككحكؠنئكټنسكڝكقكدكنكجكآنضكڪكزك؃كككحكؠكئكټټسكڝكقكئسنكجكآكضكسآزآ؃كككحك؃حؠآدنسؠ؃؃قكدكنكقآجقآڪضزټټضحڝټحؠؠڪئكټكسكئآڝققڪدزكټټ؃ضكڪكزكحكج؃حكؠنئكټكسكڝؠقكحؠدحجكآآضكڪټزك؃كككحكڝڪئكټنسكڝآقكدؠنكجڝئزضكڪنزك؃ڝككحنؠكئكټكسټزآقكدكنكجڝآكضنڪكنكؠقككحكؠكئآټكسنڝكقكحټنكجكآكضنڪكزك؃ككنحكؠكئكټكزدڝكقكدكضزجټآكضكڪكټآزدڝنكؠڪضئكټكسكڝكقكدكككزقئآضكڪكزك؃كدآحټؠكئكټكآؠزحڝټزڪنؠئضآكضكڪكآضز؃ڝجسڪ؃ڝؠئئآؠدئحڝضقدڪؠددآكضكڪكزك؃كككككڝكڝزټڝسكڝكقكقآدټنؠجحآزض؃ضح؃آككحكؠكؠآئڪآؠدنقكدكنكئؠنكضكڪآزك؃ڪككحكؠكئكدآسكڝآقكدآنكجنآكضڝسززك؃آككج؃ؠكئنټكسكڝكقټكآنكجكآكس؃ڪكزن؃كنؠ؃كؠكئآټكسڪڝكقكدكنكزآآكضآڪكزآ؃ككنحكؠكزسټكسآڝكقؠدكنكجكټؠآحڪكزآ؃ككؠحكؠكئكڪؠحؠڝكقټدكنآجكآكضكڝؠزك؃ككڪحكؠؠئكټكسكڝكقكدكنڝجكآكضكڪكزكدؠككحكآ؃ئكټؠسكڝكقكدټنكجكآڪضك؃سزك؃نككحكجدئكڪحسكڝټقكدكنكئؠدآضكڝجزكد؃ككحكؠكسكټكسك؃جقكحجنكجنآكزكڪكزكدئككحكؠكضدټكسكڝكقكحسنكئدآكضكڪكزك؃كككجزؠكضدټكسكڝكقكدكنكئئآكسزڪكزؠ؃كؠكحكؠكضئټكزئڝكقټدكنكجكآكسئڪكزؠ؃ككؠحكؠكئكټكزئڝككئدكنآجكڪكضكڪكقئ؃كنئحكؠڝئكټكسكڝككجدكنؠجكآؠضكڪكزك؃ككټحكآحئكڪجسكڝكقكدكؠحجكآآضكڪؠزكحكككحكؠآئكڪحسكڝڝقكدټق؃جكآڪضكڝسزك؃نككجؠككئكټڪسكڝڪقكدكنكجكضزضكڪڪزك؃نككحټؠكئك؃سسكڝټقكدؠنكجكآكضكڝټزك؃كككحنؠكئكټكسآڝكقكدكنكجؠآكضكڪكټج؃كدآج؃ؠكئكټكؠڝسحڝآقح؃ؠنضحڪضآڪكزك؃كككڪټؠكئكټكسكڝكقكدكټكڪقآكضكڪكزؠ؃ككنحكؠكضټټكسكڝكقندكنكجكآكضكڪكزك؃كنححكؠكئك؃سسټڝكقكدكڝككنجؠآټدسزټ؃كككحكح؃ننئسآڪنكقندؠؠئجكآكضكج؃ټڪزټټآكدححؠضجټټؠضڪڝزئسنآجكآكضكجحڪآئنآسججؠكئكټكنآضنڝزضآدقنضجضآحئټټڪقآكڪحكؠكئكج؃آنسټڪڪقؠټسجڪآكضكڪكڪكسن؃حكؠحآئؠڪحسكڝكقكز؃دقنؠجئآآضكټنسآڝڪجؠؠكئكټكزؠؠڪقكدكنكئدآكضكڪكقؠ؃كككحنؠكئؠټكسكڝكنكدكنكجنآكضنڪكقح؃كؠكحكؠكئنټكسنڝكك؃دكآكجكآكضنڪكزن؃ككټحكؠكئكټكسنڝكقؠدكنكجكآكضكڪكزك؃كككحكؠؠئكټټسكڝكقكدكؠقجكآنضك؃كد؃؃ككڪحكؠټئكټڪسك؃ؠڝحدكؠ؃جكآنضكڪكزك؃كټڪحكؠڪئكڪ؃سكڝؠقكدڝضزجكآڪضكڝززك؃نككحنؠكئټضآسكڝكقكحزنكجنآكضټسآزك؃كككجقؠكئنټكككنققكدټنكجڝآكضآڪكزڝجضككحكؠكضدټكسنڝكقؠدكنټؠآآكضكڪكقد؃ككنحكؠكضټټكسكڝكقندكنكجكآكضنڪكزك؃كككحكؠكئكڪ؃سكڝكقكدؠؠحجكآكضكئآڪضسن؃آكآ؃زننئسآڪضدقټدكنكجكدكؠنضؠڪټسجكك؃حؠټئكټكسكئدڪڪزن؃ټجؠآڪضكڪكزكضس؃ققټدڪؠضؠحزجڝكقكدكڪآكنجزكآضقڪضزض؃حقټدڪآآڪحسكڝكقكضآدضكنجآآآجزټنزسڝڪجكؠكئكټكسكؠټقكدكنكجكآكضكڪكككئئككحكؠكئكټكسنڝكنڝححنكجكآكس؃ڪكزن؃ككؠحكؠټآآټكسكڝكك؃دكننجكآكدټڪكزك؃كككحكؠكئك؃كدقڝكقكدكنڝجكآآضكڪټڝآ؃كككحكآقئكټنسكڝكئټدكنكجكآكضكڪكزكحكټئحكؠكئكټكسك؃؃قكجڝڝزجكآكضكڝضزك؃نككحڪؠكئټضآسكڝكقكحضنكجنآكضټسآزك؃كككجقؠكئنټكسكؠټقكدكنكجكآكضكڪكككئئككحكؠكئكټكسټڝكؠكآقنكجكآكضڝڪكزآ؃كككجټؠكئكټكسنڝكقكدكنكئسآكضكڪكټد؃ټككحكؠكنآئدآنسؠڪجدن؃دجټآكضكڪكڪ؃سن؃سقڪؠؠئڪټكسكڝكڝكزآ؃ننضجض؃زڝحزك؃كككسآحدننئؠآنضآڝټزڪدؠجؠټدضكڪكزكسآ؃دكححضنټئؠآڪسز؃آحجنكجكآكنؠضڪڪزضآڝڪكؠحڝؠحجآآڪنزقڪدكنكجكجكؠنضحڪؠزآكؠج؃ؠكئكټكؠكسضڪنكح؃ڪنؠجآؠدڝئزك؃كككزضحقنآجنټضئكڝضزنححكڪجؠجحڪټزك؃كككن؃دنؠحئټآد؃؃قكدكنكقآجټؠڪضكڪكسڪڝټقدآ؃ئكټكسكسآڪڪقؠدڝنححآؠڪ؃قزك؃كككحكؠټئكټكسكڝنقكدكنكئؠآكضكڪنزك؃آككحكؠكسكټكسكڝنقكدننكئحآكزكڪكزك؃نككحنؠكضجټكقكڝكقكدننكجنآكضڪڪكقؠ؃كككحنؠكئنټكسكڝكنڝسزنكجكآكسحڪكزن؃ككؠحكؠټآآټكسكڝككحدكننجكآټټآڪكزك؃كنڝحكؠنئكڪؠئكڝكقندكؠدجكآكضكڝؠسح؃ككؠحكؠنئكټكسكدكقكدكنؠجكآؠضكڪڝزك؃كككحكؠؠئكټآسكڝكقكدكنكجكآنضكڪكزك؃آككحټؠكئكټكسك؃ټقكدننكئؠنكضكڪڝزك؃ټككحكؠكئڝسټسك؃؃قكدكنكجنآكضنڪكزكجدككحكؠكئڪټكسكڝكقكحئنكجڝآكضؠڪكزن؃كككئ؃ؠكئټټكسكڝكقكدكنڝسضآكضنڪكقق؃ككنحكؠؠئكټټڪآڝكقكدكؠقجكآنضكڝؠضك؃ككنحكؠآئكټكسكدكدئدكننجكآنضكڝسزكدؠككحكؠآئكڪ؃سكڝكقكدكنكجكآنضكڪآزك؃ؠككئكؠكئكټنسكڝنقكحضنكضكآكضكڪنزك؃نككجئؠكئكټكسكڝنقكدؠنكجنآكضټڪكزك؃كككحڝؠكئنټكسك؃ټقكدكنكجنآكضكڪكزك؃كككحكؠكئؠټكسكڝكڪدح؃نكجكآكنڝضحڪآزحڝؠكضدڪنجټنسآڝكقكدكنكڝټآكضكڪكزك؃كككحكڪكڝقټكسكڝكقندكنؠجكآكسټڪكزك؃ككنحكؠكئكټكسكڝكقكدكؠدجكآكضكڪؠزټ؃كككحكح؃ننئسآڪزآكحدكنكجك؃آآدئنڪؠسنڝآكټدڪؠؠټؠزئڝكقكدكڝضنقحآؠنضضآكزضڝننحدڪؠؠټؠزحڝكقكدكڝجنڪجسآكجكڪقق؃ڝڪكؠؠؠئټټكسكڝك؃؃زندحنټنحسدڪكزك؃كڪدكڪحسننئزټقسحڪټآزؠ؃جكآكضكجكڪضسندحقڪحؠؠآقزسټڝكقكدكڝټكڪئدآټڝضزك؃كككجؠككئكټكسكڝڪقكدكنكجكئڝضكڪكزك؃نككحنؠكضؠټكسكڝكقكدننكجكآكزكڪكزك؃كككحكؠكض؃ټكقكڝكقكدكنكجكآكضآڪككك؃كككحكؠكئكټكسؠڝكنكدكنكجكآكضكڪكزڝ؃كككحكؠكئنټكسكڝكقكدكآكجكآكضنڪكزن؃كندحكآكئكټكسكڝكقټدكننجكآټضكڪكزك؃كككحكؠنئكټكزټڝكقكدكننجكآكضكڪكزك؃كككحكؠؠئكټكسكنزك؃دكنكجكدڝآحضآڪحسؠ؃ضقڪجڪئكټآسكڝكقكدكسټجكآكضكڪكزك؃كككضكسقئكټكسكڝنقكدؠنكجكټټضكڪكزك؃نككحكؠكئكټنسكڝكقكدكنكجكآكضكڪكزك؃كن؃حكؠكئكټكحآڝكقكدكننجكآكضكڪكزك؃كككحكؠكئكټكسكڝكقكدكنكجكآكضكڪكزك؃كككحكؠكئكټآسكڝكقكدكنكجكآكضكڪكزك؃كككحكؠكئكټكسكڝؠقكدكنكجكآكضكڪكزك؃نككحكؠكئكټؠسكڝكقكڝدنكجكآكضكڪكزك؃كككقدؠڪئكټكسكسكڪآزندضنضڪسضكڪكزكدؠ؃ححكؠؠئكټنسكڝكقكحؠدحجكآآضكڪنزك؃كككجؠككئكټټسكڝؠقكدكنكجڝضټضكڪڪزك؃كككحنؠكئټټكسكحدقكدكنكجؠآكضكڪكزكجدككحكؠكئكټكسكڝكقكئدنكجكآكضآڪكزك؃كككضدؠكئكټكسنڝكقكدكنكئئآكضټڪكزؠ؃ككنحكؠڝضزټكسكڝكنحدكننجكآنضكڪټڝآ؃كككحكټحئكټنسكڝڝقآدننكجكټزضكڪنزك؃نككحټجآئكټكسك؃زقكدننكجټئآضكڪكزكححككحنؠكئڝټآسنڝنقكحننكجنآكضكڪكزټقآككحكؠكضنټكسنڝكقټكآنكجكآكزحڪكزن؃ككككټؠكئټټكسؠڝكقآدكنكنټآكضڪڪكزآ؃ككؠحكؠڝضزټكسټڝكنحدكننجكآڪضكڪټڝآ؃كككحكټحئكټنسكڝكڝټدكنټجكآؠضكڪآزك؃ك؃ټحكؠڪئكټآسكڝؠقكدڝنآجنآټضك؃جزك؃نككحڪؠكئټضآسكڝكقكججنكجنآكضكڪؠزن؃ټككحكؠكئكټكسكضزقكدټنكجنآكضكڪكزكجسككحټؠكئؠټكسكڝكقكحټنكجكآكضنڪكزك؃ككؠحكؠكئكټكسنڝكقكدكنؠئ؃آكضكڪكؠټسڪ؃آكټحؠؠقضحسټڝكقكدكنكڝټآكضكڪكزك؃كككحكټكڪ؃ټكسكڝكقكدكننجكآكسئڪكزك؃ككؠحكؠنئكټكزټڝكقكدكننجكآكضكڪكزك؃كككحكؠؠئكټكسكنكقكئسؠ؃جكآكضكجڝڪحزآ؃حقؠحضنڪټآسكڝكقكدكسټجكآكضكڪكزك؃كككضكسقئكټكسكڝؠقكدننكجكټټضكڪكزك؃نككحكؠكئكټكسكڝكقكدؠنكجكآكقسڝ؃زك؃كككزڝححؠآئحآؠسضڪڪكڪننجآآكضكڪكزكآټككحكؠكئكټكسكڝكؠكآقنكجكآكضنڪكزؠ؃كككجټؠكئكټكسنڝكقكدكنكجنآكضكڪكزك؃كككحكآقئكټكسكنزقټدكنكجكج؃ؠنضسټڪقآكنحكؠكئكجحآد؃؃قكدكنكقكجضؠنسحټڪزؠ؃آقدؠآئكټكسكئدڝحقټحآجآآكضكڪكڪزسڪد؃ق؃ؠكئكټكسكڝكقكدټڪكڪزآڪضكڪكزكزس؃قكڪحآنڪټؠز؃ڝكقكدكڝڝكڪحآآټضقڪؠجآئزحڝؠكئكټكنآجڝڝؠزندسكڪآنضكڪكزك؃كككحكؠكئكؠحزئڝكقكدكڝضنقحآؠنضضآكزضڝننحدڪؠؠقززحڝكقكدكڪآندحنآؠئنټآزټڝڪكؠڪسئنټكسكڝكڪدئسؠكجكآكضكجدڪڪزسڝنكزحقؠحجټؠؠسقڝققټڝككنجؠآټآحزن؃كككحكدجس؃ټكسكڝككؠڪ؃نكجكآكس؃ڪكزك؃كؠكحكؠكئكټكسكڝكقټدكؠؠجكآكضنڪكقد؃كككحكټكئكټكسنڝكقندكنڪجكټؠضكڪكزؠ؃كنجحكؠكئكڪؠسكڝكقآدكنڝجكآكضكڝؠزك؃ككټحكآجئكټكسكڝكقكدكننجكآټضكڪؠزك؃كككحكؠكئكټكسكڝنقكحؠنكجكآنضكڝحزك؃كككئكؠكئكټنسكڝنقكدڪنكضكآكضكڪؠزك؃كككجسؠكسكټكسكڝآقكدكنكجؠآكزكڪكزك؃ټككحكؠكضقټكسكڝكقكدننكجټآكضؠڪكزك؃كككحكؠكئنټكسكڝككؠدكنكجنآكضنڪكزك؃كؠكحكؠكئنټكسنڝكقآدكآكجكآكضنڪكزن؃كنئحكټكئكټكسنڝكقندكؠضجكڪكضكڪكزن؃ككنحكآزئكڪكسكڝكقندكؠحجكآكضكڪكزك؃كككحكؠنئكټكسكڝككندكنكجكززسئڪكزك؃كڪضكقدآننئضؠكسضڪنكح؃ڪنؠئڪضكدسزټ؃كككحكحټؠقئقټضنزقټدكنكجكدزؠنضسټڪڪحكآحكؠكئكئزآڪز؃سحح؃نكجكآكؠآضقڪزززڝڪقآحټححټټسكڝكقكسټدقنقجضټآڝدزك؃كككز؃دڪؠټحسټقسڪڝآزڪحآئزآكضكڪكؠآزض؃حقآحئسكحټآڪسضڪڪقكدقنؠجټټآڝ؃زك؃كككزكحضننضحآڪسؠڝآكآنڪجكآكضكضسڪقزڪ؃آقڪددضدټكسكڝكآؠزن؃آنئجكؠنئآڪئڪحنزحكؠكئكحؠآڪسنڝڪقحدؠكڪجآندئنڪزسټ؃ضقڪسزضحټكسكڝكآنزآدټنحجڝؠنضټټڪسټدآجدؠكئكټكؠحسزڝآقټ؃ننزحآؠڪآحزڝ؃كككحك؃كننئؠآڪسزڝټڝحنټجكآكضكض؃ټنزسڝڪئئؠكئكټكزؠآسقكدكنكئنآكضكڪككك؃كككحكؠكئكټكزجڝكنكدكنكجكآكضكڪكزن؃كؠكحكؠكئكټكسكڝككددكنكجكآكضكڪكزؠ؃ككؠحكآؠئكټكسكڝككئدكنكجكټؠضكڪكزك؃كنقحكؠكئكڝكسكڝكقكدكنكجكآڪضكڝؠزك؃ككنحكآ؃ئكټكسكڝكقكدكنكجكآؠضكڪؠزكدؠككحكؠكئكټآسكڝكقكحؠنكجكآكضكڪآزك؃كككضكؠكئكټكسك؃سقكدؠنكئؠآكضكڪكزك؃آككحكؠكزكټكسكڝكقكدټنكئحآكسؠڪكزك؃كككحآؠكئكټكقكڝكقكدكنكجكآكسزڪككك؃كككحكؠكئكټكسڝڝكقؠئزنكجؠآكضكڪكزك؃كككټسؠكئكټكسؠڝكقندكؠؠجكآكضكڪكزآ؃كككحكآؠئكټكسنڝككندكنكجكڪكضكڪكزن؃ككنحكآجئكڝكسكڝكقندكننجكآنضك؃كزك؃ككنحكؠنئكڪضسك؃كقكدكنكجكټكضكڪنزك؃كككحكؠكئكټنسكڝكقكدكؠججنآكضكدسقز؃كككحكح؃ننئسآڪسآڪڪقزدآكڪڝقآدضټڪټزكڝدجضؠكئكټكئڪزڪدس؃دضټڝحنڪڝقنجضڪنضئكټزآ؃ئكټكسكئسڪڪقزدڪق؃دڪنحكززآ؃كككحكندڝ؃ضؠئدڝسزټدؠننجكآكټكحززؠدجككحكؠككټجڪڪدسټټآزآ؃ننضحڪؠټسآقن؃كككحك؃سؠقئڪټآضڪآؠقڪدټنټجقآزدنؠآزض؃حقآحئزسڪحسكڝكقكز؃؃ننضجئآآضكټڪسڪڝټقدآحئكټكسكجآڝدزندؠكنحآآټئڪڪؠ؃نددحټؠؠنكؠڝڪؠڪجآقزدؠسجكآكضكئنڪكزحآقن؃دڪنؠئدټقسقڝئقآټقدحټ؃ضكڪكزكزد؃ټكټحكقج؃قكقټحكئدكنكجكحآآدئڪټآزئڝآقنحضؠضجڪټؠټحقآدكنكجك؃ننكجحټد؃ڝككحكؠكككئضآنزحڪڪقؠ؃دئدآكضكڪكآحزز؃آكټدنؠزجآآڪڝنؠحكدټكؠكؠڪئجآڪؠقؠسئټددكټحقدآدڝآټآقزدؠئجكآكضكحؠآضضقڪقسټكڝڝنسحئڪقضدڝكؠنكجكآكضكڪكڝكضآټكنآآدئكټكسكضؠڝحقټټزكؠئدآقضؠنضضؠآز؃آدقزنآزض؃جق؃ؠزجؠڪئنحكدحك؃دنآقئزجدؠكئكټكؠآضڪڝضقضح؃نقجقؠټڪؠقج؃كككحكححؠآئضآآسضڝققآدڪنؠحڪجحڪټزك؃ككككټححؠسجڪدز؃ضقكدكنكدڝسضټكآڪدټؠ؃زڪآضضقحڪزضدكټدڪټټآ؃كضقڪحكؠنټؠقڪدنټكدؠحآققجقنټكآقڝحنټجكآكضكجټټڪقد؃ټضسؠټئكټكسكئكڪنقؠدټسسآڝضكڪكزكضؠڝڪكسحقؠټجڪكس؃دقكدكنكزؠجقؠټسحآ؃قح؃ؠكقؠؠض؃ټكسكڝكټكقض؃نؠححڪآؠجئڝآ؃ڪككحكؠككآجآټقسؠڪڪآزنڪجكآكضكحڝڪقزؠڝآقڪددضحټكسكڝك؃؃ققدؠنئجآآكئنټآسڪكؠججؠكئكټكنآسدڝحقض؃ټزنحټؠټئڪټټؠزندحكؠكئكحآآآسؠڪڪقزڝ؃نڪجحټآڝټزك؃كككزآدڪؠټحكټؠسحڝسزندؠؠحدكؠنضؠڪټئآټڝكؠدنؠسجڪدزڝآقكدكنكق؃حڪآټئدقد؃كككحكڝڝؠؠجڪآڪئضڪنقز؃ټؠآټضضكڪكزكڪڪح؃ڪجكڪټټقزئڝكضجدڝڝئسآكنحسجڪكزك؃كڪ؃قڪحټكآجڪټؠسڝڝحزآ؃ڪكدآڪضكڪكزكس؃؃قكقدټك؃قزسڝڝكقكدكڪننسجقآڪضزڪټؠس؃ئضآڝضنكزدكدټآآقآزؠكجكآكضكحؠټنسآ؃ئك؃حؠؠقئڪټزضټآآققدضنقجؠقآڪؠزټ؃كككحك؃سنڪئزټڪټحكضدكنكجكنڝ؃نقنضڪنزجؠضؠڪززټؠڝڝټؠحسححئنكجكآكآضئڪټنسټڝڪكؠحآؠټجنټټسآقؠحجنكجكآكنټئڪڝدزټټؠكڪحټؠټئقټزڝنڪ؃آڪد؃زكآټآقؠؠؠقسدن؃حكؠكئكحدټټسټڝكس؃؃ڪنټڝسضؠڪكزك؃ك؃قكآكحئڝټكسكڝكڝآقد؃نكټجقټ؃آحقج؃كككحك؃جؠآئقټزجټڪڪزآدقكټحڪجحڝدزك؃كككزكحقؠآئحټټسحڝققزضزجڝآكضكڪكټ؃سن؃ټقڪحؠن؃ټؠزئڝكقكدكڝټكڪئدآټئ؃ڪؠسن؃كككدڪنټجدزحڝكقكدكڪآندحنآؠئنټآزټڝڪكؠسزئټټكسكڝكڝ؃زندسكڪحدضڪڪكزك؃كڪجكڪحسؠكحڝآ؃ڝكقكدكنكجكآكؠڪحكحز؃ڝككحكؠكك؃ئقآټجن؃دزڪټسجآآكضكڪكآټضكټڝټسؠكئكټكسكڝكقكسحڪكڪزټضضكڪكزكئنڝټقټڝڪآدئټټؠضنآآزندآندحدسجڪكزك؃كڪټقڪجدؠټدآټقسضڝققؠټآڪسڝزضز؃زڝكڝڝسزننزقئنسآټئدنقك؃ضس؃حج؃قجحڝدزك؃ككككججدآدجڝآنجآڝ؃سآقدزټكجكؠسكڝئحجسنسقكحض؃ټكسكڝكڪڝقؠدقنسدؠن؃حؠضح؃ڪككحكؠككدئقټزضڪ؃حئسنټجكآكضكحؠټنزآڝڪټسټحج؃ڪ؃آقنضڝكڪدڪقڪزټحضكڪكزكئؠ؃ققټجحقڝئقټؠضآڪڪزدنڪجكآكضكئ؃ڪقزقڝټزئڪسضدټكسكڝكټدقټدټنكدكآقضآڪټ؃ؠنئحكؠكئكححټسضنڝ؃زڪڪؠنڪجټآټضقڪز؃ؠكآحكؠكئكآدڝجننجزححنكجكآكنټئڪڝدزټڪضقندؠنڪئضئدضجنجڝڪ؃قڝحز؃ټنحقزټ؃كآضؠ؃ؠحقآټقسقڝقد؃ضزننجقدڪحكسقئؠئجزڪسقسسئكټكسكڝكقكضكڝڪزكنحس؃ڪكزك؃كڪككضدنآحجڪټؠسآجسدكنكجكآكضكسكآنئكزححؠؠكئكټكؠټئكڪدحزنكجكآكنزئڪڝ؃زټ؃قكزحآؠقجڝټټئجټآسقڝزسسآآضكڪكزكضټڪكزئجآئڪټكسكڝكآڝقضدحنزج؃قسڝضزك؃ككك؃ڝسكڝټؠټحدقجزدؠنجضحدزڪ؃كآحزڪ؃كككحكڝؠننئآآڪئ؃قؠدڝنكجكآكنكئنڪؠسڪ؃زكټؠؠضدټكسكڝكټټسكقڪڝ؃سڪجڪسڪج؃؃نككحكؠكئكټكؠكسآآكئضقكضئن؃كقج؃دټؠدټقحنجضټئؠجنقئ؃آؠڝكڪقجؠآڪضكڪكزكئآ؃ضكقج؃ؠزجدسڪڝكقكدكڝڪزټجحآسدؠټد؃ټككحكؠككزجنټسضڪسددكنكجكآكضكحكټسئكزحجحؠكئكټكؠآضڪڝضقضدكنضحنآزضئزؠد؃ككحكؠكقآئحټټسح؃جزڪدزسسآكضكڪكزكقؠككحكؠكئكټكسكڪكآقدؠؠئجكآكضكجضڪقسآڝنكض؃كؠضجنڪحضڪڝؠدؠنآجكآكضكضزټڪق؃كؠجدؠكئكټكنؠسقڪټكحڝ؃ؠحجؠآقسآقك؃كككحك؃دؠڪئسآنسزڝققح؃ټقؠجقآقضټآكسن؃ؠكټجؠئكټكسكڝكقكدكڪسزكآؠضڪڪكزك؃كټآكددڪؠآئټآد؃حقكدكنككآجدؠنضؠټنسآ؃ټقڪحؠئؠټڪسكڝكقكز؃دقنقحټكڝئدزڝ؃كككحك؃سؠقئزټئضڪ؃حزدنټجكآكضكض؃ټنزسڝڪقدآكئكټكسكئسڝققڪدآكڪ؃ؠآڪضټڪټزق؃زضنڝټؠقض؃ټزحسقڝدكنكجكؠ؃؃حنقضڪنؠجح؃حآجئكټكسكئآڝققڪدؠكآحڪنآئنڪززآزحجدؠكئكټكؠآضڪڝټسآ؃آنقجؠؠڪسؠزك؃كككحكؠك؃كجقنكټدټنضڪقؠجق؃سټنآټؠققآكآحكؠكئكدڝټضزح؃آححنكجكآكجڪنزڝڪڪڪئزؠضكڝټدسكآ؃ټحڝئڪدققڝكسئجټحقحزد؃ككحكؠكقآئقټزسزڪڪزآدټدحټحضكڪكزكق؃ڝڪقؠحدؠقئقټئئحآټدؠؠ؃جكآكضكئټڪحزآڝآكقحؠنټضؠسكڝكقكدكنكجكحسككسآزن؃كككحكددئنزڪ؃ئددنكضزحن؃ټ؃ققسڝدزك؃كككزټدڪآدئټؠآسح؃جزڪنؠئ؃آكضكڪكآكزضڝننحدڪؠؠح؃ڪآڝټقكدكنكقدحڪؠنئټنضحضؠنڝآڝقنكؠضئزجقسحدټنكجكآكآسضقڪقززكؠحڪؠكئكټكؠآسكڪڪزڪ؃ټسسټضضكڪكزكڝحدكنككڪټ؃كجضدزټحجڝڝئضڪضندضكڪكزك؃كككنكڝؠقك؃سسنڝكقكدك؃قڪسحسضضڝحزكؠكئ؃آنزقآؠټكسكڝكقكدكنكجكآك؃زڝ؃زك؃كككسآحقؠؠجڪؠ؃سڪڝحآزؠحجكآكضكجسټنز؃؃زكححټؠڪجټآڪنزكقدكنكجك؃نؠټئټؠڪزڝڝڪكزحټكدجنټزضټڝضزڪدؠؠآټحضكڪكزكضك؃ضقنجحنڪئؠؠ؃سڪڝحڝحنڪجكآكضكحؠټنزآڝڪسڝكحضئټكسكڝكآآقحدټنحئجؠڪضزڪآزد؃حككجآئآټكسكڝكزحآحضضؠآآڪضكڪكزكئآڝنكؠ؃ټككقزز؃ڝكقكدكڪآنقجؠؠڪج؃ڪڪزحكنڝحنڪآټجقجحزحسحضقټسجټآكضكڪكآضسڪڝڝكټؠؠئڪټكسكڝكټؠقحد؃ندجټ؃سحؠكضدسككڪدس؃آندقڪآ؃؃قكدكنكقټحڪټدضټؠؠزقددضسؠټئكټكسكجآڪنقآددسسآټضكڪكزكزكڝنكؠحټآآڪڪسكڝكقكزټدحنآحآآقضؠټټجز؃؃ك؃ڪقؠ؃حننڪئدؠؠقڪ؃جؠددڪآئئ؃قټقدآ؃آقټزسئكټنقزآقټدكنكجكح؃آقضقټټڪحنضحكؠكئكؠڪڝققسزحټئجندڪضكڪسآڪ؃سكڪڝ؃حكؠكئكټكسكڝكټؠضكحؠؠضئجقؠ؃كز؃جټزؠسقجآضضټكسكڝكسڝنڝض؃دڪسټ؃ټآڪدټكسزڪؠدسڝزسڪضسكڝكقكسضد؃كج؃ڪنڝضئڪآضدڪحكضحدقؠټؠسڪڝكقكدكڪؠكنجآؠڪجئحزججككحكؠكؠدئټټټسكآجئقټقؠ؃ئ؃ټ؃دزڪؠزقڝؠكضحقآد؃زآآسقڝسئق؃ننآجآؠڪضټنقئق؃حقټڝسقدد؃كڝجحآدض؃ټؠزد؃حكدكزقد؃كككحك؃دؠڪئسآنسزڝققح؃ټكدټئضكڪكزكضضڝڪقندټنڪئؠآؠسقڪنقؠ؃ټك؃آكضكڪكزك؃كككضدڝكئنټكسكڝكقكدكقكنق؃كقسڪټزك؃كككزددڪننجټڪآڝڝقكدكنكقآجكؠڪئڪټټضڝكنحكؠكئكټكسكڝكؠضضكننجكآكضكڪكزكسكڝكسكؠؠئټټكسكڝكټدزڪ؃نكټنحسضڪكزك؃كڪټكؠححؠ؃ئ؃آڪسؠآڪقڝ؃ڪنزجټجحڪآزك؃ككككزدڪآ؃ؠحسڪڝكقكدكڪآنضجقآآئڪضح؃آككحكؠكننئكټحټحكددكنكجك؃آؠنضضڪضسؠڝنقآحئآآټآسكڝكقك؃دضڪڪكندضكڪكزك؃كككحكڝنقكؠدڝكؠ؃آآزكڪدجحؠجكقڪنڪزټؠڝؠقكجڪضجنڪنقڝنؠئقآټدؠكقدزټؠڪؠقڪحننحكؠكئكحؠآڪسكڝضقح؃آكنجټؠڪئټآآزټ؃قكؠدنؠ؃جڪئحددقكدكنكنكحنآآضټټڪسؠ؃حكزڪزنآئقټسحقڝؠزنح؃سقجڪنئدآؠ؃ئڝ؃جسڪسزئنټكسكڝكؠسآزؠضجكآكضكجحڪززڝ؃قكئدڪكآجڪټؠسڝڪڪقؠضسقحنآئقسقسزټزدنڪقجؠسئسؠز؃ټكڝزڪؠكجزقحدسحڪكزك؃ك؃؃قنحسنڪئآآڪسزڝآزڪضسنؠكحض؃آكؠآؠڝضټسقكحئڪټكسكڝكټڪضټدحنسڝؠضؠڝضزك؃ككك؃ڪئ؃؃جؠڪڝټنزسڝؠضضددڝسسدقدسقق؃كككحكندڝزكزض؃ؠسجز؃دس؃ڪآؠدد؃سآضڪكججئضسؠڝئكټكسكئزڝقزآدضنحجكؠ؃زضزآئئټكضدنڝحڪدقڪآ؃جقكدكنككقحقآآئڪټآزڪ؃ؠقڪدڪؠنټؠز؃ڝكقكدكڝڝكڪحآآټضقڪؠجآآضكڪټټسدضك؃ڝجئزدضقنؠئؠآكضكڪكسدكزض؃؃ڪززڪ؃ؠڪڪڪندزحكآضدحدضآڝسآڪدئآزآسجحؠكئكټكننسزڝټقحڪؠنضحنؠآضئڝآ؃ڪككحكؠكقڝئؠآنسسڪڪآزنټجكآكضكججڪآزق؃زنآؠآئكټكسكجڪټآسكنټجنئآضآڪكزك؃كڪضقڪح؃ندټآسكڝكقكسټڝكق؃حدس؃ڪكزك؃كڪڝكححآؠحجؠټضضڪڪدحئنكجكآكنضضقټآسن؃ضزكحضننضحآڪسؠجزحضنكجكآكجټنضدكڝحدكننكڝڪضقدئڝكسئقكآنټجكآكضكض؃ټنزسڝڪټزؠڪئكټكسكئحڝسزند؃كڪحدضڝڪكزك؃كڝ؃كقحقنټحټؠكزآقڪدكنكجكدسآقضزټڪقحئزحټؠكئكټكؠآسح؃جزڪ؃؃جكآكضكڪكزك؃كڪئسكڪضڝټئئحضدكدټحجسآزقآؠس؃ڪكزك؃كڪككضدنآحجڪټؠجڝجسدكنكجكآكضكڪكؠټئككنقز؃دزڝدككنڪزز؃ضقضسنددجنننكقټجئئضسقجآض؃ټكسكڝكڪآققدزنزحڪؠآضټڝآحجككحكؠكحټكض؃كڪح؃ككنقڝټضزدجڝقس؃كجدزڪآضضقحڪزضدكټڪدڪكڝقڪڝجس؃قحآحق؃؃كككحك؃ټككئكټضضنڝزقئقحئئآكضكڪكؠنسټ؃سكححزكؠجڪټسسقڝټزڪټضجدسئټزنكڪئئڝزقسقكحضقټكسكڝكڪټقآ؃ڝضكجحآآ؃كڪدسن؃ؠكسحضنڪئآټآټدڝجقټزټڝقضزقحآكؠقؠزكڝحكؠكئكحآټدسقڝكسټڝككدآڝضكڪكزكڝحجآآزندڪنسضآ؃ڝكقكدكنكجك؃كؠڪحكحزدڝككحكؠكقؠجنآآسئڝ؃قؠدقنڪجزؠټجټڪؠسن؃زكآحكننئؠآڪسزڪآكحضزجټآكضكڪكؠڝزق؃زكټددضجټكسكڝكټئقح؃آنئدكآضئنڝحسڪ؃ؠټزآ؃ئكټكسكئسڪنكدڝضكنجزؠټدسزڝ؃كككحك؃كؠضجنڪحضڪڝؠز؃؃ڝؠسججدقدضضؠآآټققدآحئكټكسكز؃ڪنقضدئنآجكؠڪئڪټټڪحكڝحكؠكئكضدټكضآڪنقضدضسسآڝضكڪكزكضټڪكن؃حقؠقجټكس؃دقكدكنكقحجزآآضټټنززڝآقڪڪضټقدجقحككڪسئآكجزقحدسحڪكزك؃كڪككضدنآحجڪټؠئ؃ڝڪقحضسجكآكضكڪكزكآكڝضسكسزضحټكسكڝكټآزآدؠكڪحڪآزج؃ڪڪزحزححټؠكئكټكؠجسڪڝسقك؃دجڝآكضكڪكؠآزق؃ضكقحؠزآضآسټڝكقكدكڝدكڪحنؠټسآقج؃كككحكڝڝؠحئؠآڪئآڪڪقؠدڝكڪجؠ؃زڝجزك؃كككزآحڪؠؠجڝآنضآڪڪس؃دڪنحڝسسحڪكزك؃كڝ؃كقحؠؠئئآټكضنڪآزڪ؃؃دسجټضزڪق؃ڪقئزؠسقددض؃ټكسكڝكآنقڪدټنق؃آآڪضټنسدحككحكؠكقؠئقآټزحآڝققدؠكآحڪؠدڝضزك؃كككددسز؃زآ؃حسنززحككئقدڪقجڝڝكسزك؃كككحكؠكآكدآنكڝؠقټدكنكجك؃ڪآزضڪڪسؠسټحزڝڝڝئكح؃؃ټندآقآزؠ؃جكآكضكئڝڪؠزق؃سزؠ؃؃قؠآقسڝڝكقكدؠټزجكآكضك؃حزك؃كككجؠټحئكټكسكآضقكدكنكجكآكضكڪكزك؃كككحكؠكئكټكسكڝنقكدكنكجكآكسؠڪكزك؃نككټحؠكئكټكزؠڝكقكدننكآقآكضكڪككڝ؃كككحنؠكضحټكسنڝكحؠدكنټؠآآكضكڪكقح؃ككنحكؠټآآټكسكڝككجدكننجكآكسټڪكزك؃ككنحكؠكئكټؠكزڝكقندكؠؠجكآكضكڝؠدڝ؃ككنحك؃دئكټكسك؃ؠقكدكننجكټكضكڪكزكحكككحكؠنئكټنسكسققكحؠنكجكآؠضكڪضزك؃كككحكؠكئكټنسكڝؠقكدؠنكئؠآكضكڪؠزكدكككحكؠكسكټكسكڝؠقكدؠنكنقآكسؠڪكزك؃آككزآؠكئكټكسكڝكقكدؠنكجؠآكضؠڪكقؠ؃كككحآؠكضكټكسكڝكنكدكنكجآآكضآڪكڪق؃كنؠحكؠكئټټككټڝكقكدكنكجكآكضآڪكزؠ؃ككؠحكآؠئكټكسټڝكككدكنكجكڪكضكڪكزټ؃ككټحكحقئكڪؠسكڝكقڪدكټټجكآكضكڪكزك؃ككټحكؠؠئكټؠسك؃ؠقكدكنڪجكټكضكڪكزكحكككحكؠڪئكټڪسكسققكحؠنكجكآڝضكجآزك؃كككحكؠكئكټڪسكڝؠقكدؠنكئؠآكضكڪڝزكدكككحكؠكسكټكسكڝڝقكدڝنكنقآكسؠڪكزكد؃ككضټؠكئكټكسكڝكقكدڝنكجؠآكضؠڪكقؠ؃كككج؃ؠكضكټكسكڝكنكدكنكئ؃آكس؃ڪكڪق؃كنؠحكؠكضدټككټڝكقكدكنكجكآكس؃ڪكزؠ؃ككؠحكآؠئكټكزدڝكككدكنكجكڪكضكڪكقد؃كندحكحقئكڪؠسكڝككحدكڝآجكآكضكڪكزك؃كندحكؠؠئكټؠسك؃ؠقكدكؠحجكټكضكڪكزكحكككحكآحئكڪحسكسققكحؠنكجكټجضكدټزك؃كككحكؠكئكڪحسكڝؠقكدؠنكئؠآكضكڝجزكدكككحكؠكسكټكسك؃جقكحجنكنقآكسؠڪكزكدئككضټؠكئكټكسكڝكقكحجنكجؠآكضؠڪكقؠ؃كككجئؠكضكټكسكڝكنكدكنكئئآكسئڪكڪق؃كنؠحكؠكضضټكؠآڝكقكدكنكجكآكسئڪكزؠ؃ككؠحكآؠئكټكزضڝكككدكنكجكڪكضكڪكقض؃كنضحكحقئكڪؠسكڝككسدكټټجكآكضكڪكزك؃كنضحكؠؠئكټؠسك؃ؠقكدكؠسجكټكضكڪكزكحكككحكآسئكڪسسكسققكحؠنكجكټزضكدټزك؃كككحكؠكئكڪسسكڝؠقكدؠنكئؠآكضكڝززكدكككحكؠكسكټكسك؃زقكحزنكنقآكسؠڪكزكدقككڝنؠكئكټكسكڝكقكحزنكجؠآكضؠڪكقؠ؃كككجقؠكضكټكسكڝكنكدكنكئقآكسقڪكڪق؃كنؠحكؠكضكټك؃قڝكقكدكنكجكآكسقڪكزؠ؃ككؠحكآؠئكټكزكڝكككدكنكجكڪكضكڪكقك؃كنكحكحقئكڪؠسكڝككندكئقجكآكضكڪكزك؃كنكحكؠؠئكټؠسك؃ؠقكدكؠنجكټكضكڪكزكحكككحكآنئكڪنسكسققكحؠنكجكټؠضكدټزك؃كككحكؠكئكڪنسكڝؠقكدؠنكئؠآكضكڝؠزكدكككحكؠكسكټكسك؃ؠقكحؠنكنقآكسؠڪكزكدآككضټؠكئكټكسكڝكقكحؠنكجؠآكضؠڪكقؠ؃كككجآؠكضكټكسكڝكنكدكنكئآآكسآڪكڪق؃كنؠحكؠكضټټككټڝكقكدكنكجكآكسآڪكزؠ؃ككؠحكآؠئكټكزټڝكككدكنكجكڪكضكڪكقټ؃كنټحكحقئكڪؠسكڝككڪدكټټجكآكضكڪكحض؃كنټحكؠؠئكټؠسك؃ؠقڪدنؠڪجكټكضكڪكزكحكككحكآڪئكڪڪسكسققكحؠنكجكټڝضكدټزك؃كككحكؠكئكڪڪسكڝؠقكدؠنكئؠآكضكڝڝزكدكككحكؠكسكټكسك؃ڝقكحڝنكنقآكسؠڪكزكح؃ككضټؠكئكټكسكڝكقكحڝنكجؠآكضؠڪكقؠ؃كككئ؃ؠكضكټكسكڝكنكدكنكض؃آكز؃ڪكڪق؃كنؠحكؠكسدټكجنڝكقكدكنكجكآكز؃ڪكزؠ؃ككؠحكآؠئكټكقدڝكككدكنكجكڪكضكڪككد؃كؠدحكحقئكڪؠسكڝكنحدكټټجكآكضكڪكزك؃كؠدحكؠؠئكټؠسك؃ؠقكدكآحجكټكضكڪكزكحكككحكټحئكڝحسكسققكحؠنكجكڪجضكدټزك؃كككحكؠكئكڝحسكڝؠقكدؠنكئؠآكضك؃جزكدكككحكؠكسكټكسكدجقكججنكنقآكسؠڪكزكحئككضټؠكئكټكسكڝكقكججنكجؠآكضؠڪكقؠ؃كككئئؠكضكټكسكڝكنكدكنكضئآكزئڪكڪق؃كنؠحكؠكسضټككټڝكقكدكنكجكآكزئڪكزؠ؃ككؠحكآؠئكټكقضڝكككدكنكجكڪكضكڪككض؃كؠضحكحقئكڪؠسكڝكنسدكټټجكآكضكڪكزك؃كؠضحكؠؠئكټؠسك؃ؠقكدكآسجكټكضكڪكزكحكككحكټسئكڝسسكسققكحؠنكجكڪزضكدټزك؃كككحكؠكئكڝسسكڝؠقكدؠنكئؠآكضك؃ززكدكككحكؠكسكټكسكدزقكجزنكنقآكسؠڪكزكحقككڝنؠكئكټكسكڝكقكجزنكجؠآكضؠڪكقؠ؃كككئقؠكضكټكسكڝكنكدكنكضقآكزقڪكڪق؃كنؠحكؠكسكټككټڝكقكدكنكجكآكزقڪكزؠ؃ككؠحكآؠئكټكقكڝكككدكنكجكڪكضكڪككك؃كؠكحكحقئكڪؠسكڝكنندكټټجكآكضكڪكزك؃كؠكحكؠؠئكټؠسك؃ؠقكدكآنجكټكضكڪكزكحكككحكټنئكڝنسكسققكحؠنكجكڪؠضكدټزك؃كككحكؠكئكڝنسكڝؠقكدؠنكئؠآكضك؃ؠزكدكككحكؠكسكټكسكدؠقكجؠنكنقآكسؠڪكزكحآككضټؠكئكټكسكڝكقكجؠنكجؠآكضؠڪكقؠ؃كككئآؠكضكټكسكڝكنكدكنكضآآكزآڪكڪق؃كنؠحكؠكسټټككټڝكقكدكنكجكآكزآڪكزؠ؃ككؠحكآؠئكټكقټڝكككدكنكجكڪكضكڪككټ؃كؠټحكحقئكڪؠسكڝكنڪدكزنجكآكضكڪكزك؃كؠټحكؠؠئكټؠسك؃ؠقكدكآڪجكټكضكڪكزكحكككحكټڪئكڝڪسكسققكحؠنكجكڪڝضكدټزك؃كككحكؠكئكڝڪسكڝؠقكدؠنكئؠآكضك؃ڝزكدكككحكؠكسكټكسكدڝقكجڝنكنقآكسؠڪكزكج؃ككضټؠكئكټكسكڝكقكجڝنكجؠآكضؠڪكقؠ؃كككض؃ؠكضكټكسكڝكنكدكنكس؃آكق؃ڪكڪق؃كنؠحكؠكزدټككټڝكقكدكنكجكآكق؃ڪكزؠ؃ككؠحكآؠئكټككدڝكككدكنكجكڪكضكڪكند؃كآدحكحقئكڪؠسكڝكؠحدكټټجكآكضكڪكزك؃كآدحكؠؠئكټؠسك؃ؠسكدكټحجكټكضكڪكزكحكؠئحكڪحئك؃حسكسققكحؠنكجكڝجضكجنزك؃كككحكؠكئك؃حسكڝؠقكدؠنكئؠآكضكدجزكئزككحكؠكسكټكسكحجقكئجنكټجآكسكڪكزك؃نككقنؠكزجټكككڝكقكدؠنكندآكئآڪكقك؃كككحؠؠكننټكسنڝككؠدكنكسجآكضزڪكزك؃كؠكحكؠكزجټككجڝككجدنؠؠجكآكقئڪكؠك؃كككحكآؠئكټككضڝكآكدكنكجكټؠضكڪكنس؃كټكحكؠكئكټكسكڝكؠجدكټسجكآؠضكڝكزك؃ككؠحكڪكئك؃جسك؃ؠقكدكټججكج؃ضكڪكزكحكككحكڪجئك؃جسكسققكحؠنكجكڝئضك؃ضزك؃كككجؠؠكئك؃ضسكقنقكدكنكئؠآكضكدسزكسټككحكؠكضؠټكسكحزقكنننكجكآكضكڪكزكججككضزؠكئؠټكزكڝكقكدؠنكزجآكقجڪكقؠ؃كككضجؠكؠ؃ټكسكڝكنكدكنكسجآكقجڪكڪق؃كنؠحكؠكزئټكڝنڝكقكدكؠؠجكآكقضڪكزئ؃كككحكآؠئكټككسڝكدندكنكجكټؠضكڪكنز؃ك؃ؠحكؠكئكټكسكڝكؠجدكټزجكآؠضكڝكزك؃ككؠحككزئك؃جسك؃ؠقكدكټججكټدضنڪكزكحكككحكڪجئك؃جسكڪكقكجكنكجكڝجضكدجزكقجككجكؠكئكټؠسكڪكقكئجنكسكآكضكڪؠزكحزككڪجؠكضؠټكسكحجقكدزنكجكآكزكڪكزكججككضجؠكضجټنزؠڝكقكئئنكآنآكضكڪكقؠ؃كككضضؠكټنټكسكڝككؠدكنكسسآكڪنڪكزك؃كككحكؠكزجټككسڝكقؠدكؠكجكآكضؠڪكؠڪ؃كآجحكڪكئكټكسؠڝكد؃دكضؠجكڝكضكڪكزآ؃ك؃دحكئدئكڪكسكڝكقآدك؃نجكآؠضكڝؠزك؃كآجحكؠزئكټكسكدكقكدكټججكڝجضكڝجزندؠككحكڪئئكزڝسكڝكقكحؠنكجكڝضضكقڝزك؃كككجؠؠكئك؃سسككڝقكدكنكجكآكضكدجزكجسككحؠؠكضكټكسكڝآقكئكنكسجآكسؠڪكزكججككك؃ؠكئكټكقكڝكقكئجنكسجآكآقڪكقؠ؃كككضئؠكحآټكسكڝككؠدكنكسضآكڪنڪكزك؃كنؠحكؠكزسټكڝنڝكقكدكؠؠجكآكقزڪك؃ن؃كككحكؠكئكټككجڝكؠزدكنؠجكټكضكڪكزآ؃كټجحكڪجئكڪؠسكڝكؠجدكد؃جكآكضك؃كزك؃كآجحكڪجئكئقسك؃ؠقكدكټئجكضنضكڪكزكدؠككحكڪضئكئؠسكڝكقكحؠنكجكڝسضكزنزك؃كككجؠؠكئك؃زسكسؠقكدكنكجكآكضكدجزكجزككحؠؠكضكټكسكڝآقكڝزنكسجآكسؠڪكزكججككجدؠنئكټكقكڝكقكئجنكسجآكئكڪككك؃كككضجؠكزجټكڪجڝكككدكنكجآآكئكڪكنج؃كآكحكؠكئآټكقزڝك؃ڪدكؠؠجكآكقجڪكزز؃كككحكټكئكټككجڝكؠجدكؠججنټؠضكڪكنئ؃كحنحكؠكئكڪؠسكڝكؠضدكجنجكآكضكڝؠزك؃كآسحكئنئكټكسكڝكقكدكټججكڝسضكڪؠزكدكجححكؠآئكدڪسكحجقكئكنكجكآآضكڪڝزكټټككضكؠكئكټآسكق؃قكآؠنكسكآكضكڪآزكئضككڝټؠكسكټكسكحجقكدآنكؠدآكزكڪكزكججككضجؠكآنټكسڝقټقكئضنكجكآكضنڪكزن؃كككضدؠكئكټكززڝكقكدكنك؃حآكقجڪكنض؃ككنحكڪكئكټكسټڝكڝددكآؠجكټكضكڪكزټ؃كڝنحكؠؠئكڪؠسكڝكؠجدكنزجكآكضك؃كزك؃كآجحكڪجئكڪجسن؃ؠقكدكټئجكسڝضكڪكزكدؠككحكڪضئكزڝسكڝكقكحؠنكجكڝسضكقڝزك؃كككحكؠكئك؃جسكحسقكدؠنكئكآكضكڪټزكجكككضجؠكضؠؠكسكحجقكق؃نكجكآكزكڪقزكججككضجؠكؠقټكزؠڝكقكئئنكزڝآكضكڪكقؠ؃كككضضؠكټنټكسكڝككؠدكنكسسآكز؃ڪكزك؃كنؠحكؠكززټكڝنڝكقكدكنكجكآكقجڪكنز؃ككؠحكآكئكټكسټڝكآجدكټججكټؠضكڪكنج؃ك؃؃حكؠكئكڝكسكڝكؠجدكټججكجقضكڝؠزك؃كآئحكئنئكټكسك؃ؠڝحدكټضجكجؠضكڪكزكدؠنجحكڪسئكسنسكڝكقكحؠنكجكڝزضكضؠزك؃كككحكؠكئك؃جسكحزقكدؠنكئكآكضكڪټزكڪزككضجؠكضؠټكسكحجقكحدننجكآكزكڪكزكججككضجؠكجكټكقكڝكقكئجنكسجآكټجڪكقك؃كككحټؠكجكټككجڝكؠكدكنكجټآكززڪكجن؃كنؠحكؠكزجټكسزڝكقكدكآكزئآكقجڪكنج؃كنجحنآؠڪؠټككئڝكدندكنكجكټؠضكڪكنض؃كحنحكؠكئكڪؠسكڝكؠسدكجنجكآكضكڪكزك؃كآجحكڪسئكټؠسك؃كقكدكنټجك؃ڪضكدجزكجكككحكؠټئكټڝسكآټقكئكنكجكآټضكز؃زكؠؠككضكؠكئكټټسكجضقكڪټنكضكآكضكدجزك؃ټككندؠكسكټكسكحجقكئجنكؠنآكضڝزټزكجضككجڝؠكئنټكسنڝكقكئدنكجكآكسزڪكزك؃كككڝجؠكزجټككضڝكقندكټكجكآكضڪڪكڪد؃كڪضحكآكئكټكسڪڝكڪندكننجكټؠضكڪكنج؃ككزحكؠكئكڝكسكڝكؠجدكټججكټجضنڝؠزك؃كآئحكڝكئكټكسك؃ؠقكدكټضجك؃كضكڪكزكدؠككحكڪسئكدكسكڝكقكدكنكجكڝجضكدسزك؃ؠككجكؠكئكټڪسكحكقكئجنكئؠآكضكدجزكز؃ككحكؠكسكټكسكحجقكئجنكنقآكسؠڪكزكجئككڪزؠكئكټكزؠڝكقكئضنكآنآكضكڪكقؠ؃كككضسؠكنټټكسكڝككؠدكنكسزآكڪنڪكزك؃كككحكؠكزجټككزڝكقؠدكؠكجكآكضڪڪكؠج؃كآجحكآؠئكټككجڝكڝ؃دكنكجكڪكضكڪكنج؃كآجحكحقئكڪؠسكڝكؠئدكجنجكآكضكڝؠزك؃كآضحكؠئئكټكسك؃ؠقكدكټسجكضنضكڪكزكدؠككحكڪزئكئؠسكڝكقكدكنكجكڝجضكدززك؃ؠككجكؠكئكټڪسكټزقكئجنكئؠآكضكدجزكددكنحكؠكسكټكسكحجقكئجنكحكآكزكڪكزكججككضجؠكآجټكزكڝكقكدڪنكحكآكقجڪكنك؃كككحڪؠكسزټك؃دڝككؠدكنكسجآكضزڪكزك؃كؠكحكؠكزجټككجڝككجدنؠؠجكآكقئڪك؃ن؃كككحكآؠئكټككضڝكدندكنكجكټؠضكڪكنس؃كحنحكؠكئكټكسكڝكؠجدكټسجكآؠضكڝكزك؃ككڪحكڝڪئك؃جسكحكقكدكنڪجكض؃ضككؠزكجكككحكؠڝئكئدسكنجقكحكنكجكآڝضكئنزك؃ڪككجؠؠكئك؃جسكڝزقكدكنكضكآكضكدجزكججككججؠنضؠټكسكحئقكؠڝنكجكآكسؠڪكزكجضككآڝؠكئكټكزؠڝكقكئسنكټڝآكضكڪكزك؃كككضجؠكزسټكسؠڝكككدكنكجڝآكقكڪكنج؃كنؠحكؠكزجټكټ؃ڝكقكدكآكجكآكقجڪكنج؃ك؃قحكآؠئكټككئڝكئآدكنكجكټؠضكڪكنض؃كحنحكؠكئكڪؠسكڝكؠسدكجنجكآكضكڝؠزك؃كآزحكئنئكټكسكڝكقكدكټججكڝزضكڪؠزكدكككحكؠڝئكدجسكحجقكحؠنكجكڝجضكض؃زك؃كككئكؠكئك؃جسكحجقكققنكئؠآكضكدئزككنككحكؠكضؠټكسكحضقكقؠنكجكآكسؠڪكزكجسككؠنؠكئكټكزؠڝكقكئزنكنؠآكضكڪكزك؃كككضجؠكززټكسؠڝكككدكنكجڝآكجزڪكنج؃كنؠحكؠكزجټكزدڝنقكدكآكجكآكقجڪكنج؃كقكحكټكئكټككجڝكؠجدكحججكټكضكڪكزڝ؃كقكحكڪجئك؃كسكڝكقڝدكآزجكقنضكڝؠزك؃كآجحكؠزئكټكسكدكقكدكټججكڝجضكڝجزندؠككحكڪئئكسنسكڝكقكحؠنكجكڝضضكزنزك؃كككجؠؠكئك؃سسكقنقكدكنكجكآكضكدجزكجسككحؠؠكضكټكسكڝڝقكضڪنكسجآكقكڪكزك؃ڝككحڝؠكدټټكككڝكقكدڝنكآ؃آك؃ؠڪكنك؃كككحڝؠكقضټكجټڝكنكدكنكسجآكضڝڪكڝد؃كؠكآ؃ؠكزجټككجڝك؃ندكنڝآټآكقضڪككض؃ككنحكؠنئكټككدڝكقكدكآټجكآكضكڪكئح؃كآجحكڪضئكټنسكحكقكدكؠ؃جكجدضكئكزكدكككحكآ؃ئكجنسكڝڪقكحؠنكجكڝجضكڪززك؃كككئكؠكئك؃جسكحجقكحجننئؠآكضكدئزكنڝككحكؠكضؠټكسكحضقكؠڝنكجكآكسؠڪكزكجسككآڝؠكئكټكسكڝكقكئجنكسسآكضؠڪكقك؃كككج؃ؠكزكټككجڝككؠڝكنكسجآكآ؃ڪكزك؃كؠكحقؠكزجټككجڝكڝقدكؠؠجكآكقئڪكقڝ؃كككحكآؠئكټككضڝكدندكنكجكټؠضكڪكنس؃كحنحكؠكئكڪؠسكڝكؠزدكجنجكآكضكڪكزك؃كآجحكڪزئكټؠسك؃كقكدكؠ؃جك؃جضكدجزكدؠككحكڪجئكئ؃سكڝكقكجكنكجكڝجضكدجزكزقككجؠؠكئك؃ئسكقنقكدكنكئؠجحضكدضزكزؠككحكؠكضؠڪجسكحسقكنننكجكآكسؠڪكزكجزكككؠؠكئكټكسكڝكقكئجنكسزآكضؠڪكقك؃كككج؃ؠكحزټككجڝككؠدكنكسجآكسدڪنزك؃كؠكحكؠكزجټككجڝكزكدكآكجكآكقجڪكنج؃كدجحكآكئكټكز؃ڝكزكدكټججكڝكضكڪكق؃؃كؠزحكجڪئكڪؠسكڝكؠجدكنزجكآكضك؃كؠئ؃كآجحكڪجئكڪجسن؃ؠحؠدكټئجكضنضكڪكزكدؠككحكڪضئكسنسكڝكقكحؠنكجكڝسضكزنزك؃كككحكؠكئك؃جسكحسقكدؠنكئكآكضكڝ؃زكئڪككضجؠكزكټكسك؃؃قكدڝنك؃ټآكقكڪكزكد؃ككؠ؃ؠكڝؠټكككڝكقكح؃نكزضآكحټڪككك؃كككضجؠكض؃ټكڪدڝكنكدكنكسجآكقجڪكڝن؃ككڝؠټؠكزضټكقئڝكقندكننجكآكقدڪكزك؃كؠټحكؠكئكټكججڝكؠجدكټضجكآنضكدكزك؃كندحكحدئكزټسك؃كقكدكؠدجكحنضكڪنزكدؠككحكڪجئكټزسكڝكقكجكنكجكڝجضكدجزكدجكنجؠؠكئك؃ئسكجكقكدكنكئؠآكضكدضزكئكككحكؠكضؠټكسكحسقكضكنكجكآكضكڪكزكججككضسؠكئؠټكزكڝكقكحدنكسكآكقجڪكقؠ؃كككضجؠكؠ؃ټكسكڝكنكدكنكسجآكقجڪكڪق؃كنؠحكؠكزئټكضئڝكقكدكؠؠجكآكقضڪك؃ن؃كككحكآؠئكټككسڝكڪټدكنكجكټؠضكڪكنز؃كحنحكؠكئكټكسكڝكؠجدكټزجكآؠضكڝكزك؃كندحكڝجئك؃جسك؃ؠقكدكټججكج؃ضكڪكزكحكككحكڪجئك؃جسكسققكحؠنكجكڝئضكزنزك؃كككجؠؠكئك؃ضسكڝئقكدكنكئؠآكضكدسزككنككحكؠكضؠټكسكحزقكقؠنكجكآكضكڪكزكججككضزؠكئؠټكزكڝكقكحدنكدزآكقجڪكقؠ؃كككضجؠكضدټنسكڝكنكدكنكسجآكقجڪكسك؃كؠكحكؠكزجټككجڝك؃جدكؠكجكآكسدڪكسك؃كآجحكڪكئكټكزدڝكنزدكنټجكټؠضكڪكنج؃ككزحكؠكئكڝكسكڝكؠجدكټججكټجضنڝؠزك؃كآئحكئنئكټكسك؃ؠقكدكټضجكضنضكڪكزكدؠككحكڪسئكسنسكڝكقكدكنكجكڝجضكدسزك؃ؠككجكؠكئكڪدسكجڪقكئجنكسكآكضكڝدزكك؃ككټؠؠكزكټكسك؃حقكقدنكققآكسكڪكزكدحككقنؠكضدټكزؠڝكقكئجنكجزآكضكڪككك؃كككضجؠكزجټكزجڝنكؠدكنكسئآكڝڝڪكزك؃كنؠحكؠكزضټك؃ڝڝكقكدكؠؠجكآكقسڪكدڝ؃كككحكؠكئكټككجڝكؠسدكنؠجكټكضكڪكقح؃كآكحكڪجئكڪؠسكڝكؠجدكد؃جكآكضك؃كزك؃كآجحكڪجئكئقسك؃ؠقكدكټئجكدڝضكڪكزكدؠككحكڪضئكسنسكڝكقكحؠنكجكڝسضكزنزك؃كككجؠؠكئك؃زسكقنقكدكنكجكآكضكدجزكجزككحؠؠكضكټكسك؃حقكضجنكسجآكسؠڪكزكججككك؃ؠكئكټكقكڝكقكئجنكسجآكآقڪكقؠ؃كككضئؠكټنټكسكڝككؠدكنكسضآكآؠڪكزك؃كنؠحكؠكزسټكڝنڝكقكدكؠؠجكآكقزڪكڪؠ؃كككحكؠكئكټككجڝكؠزدكنؠجكټكضكڪكقح؃كززحكڪجئكڪؠسكڝكؠجدكؠدجنآكضك؃كزك؃كآجحكڪجئكآكسكدكقكدكټججكڝجضكسجزكدكككحكآحئكآكسكحجقكئكنكجكټحضك؃ززكآنككجؠؠكئك؃جسكڝزقكدكنكضكآكضكدجزكججككججؠنضؠټكسكحئقكنننكجكآكسؠڪكزكجضككؠنؠكئكټكزؠڝكقكئسنكآنآكضكڪكزك؃كككضجؠكزسټكسؠڝكككدكنكئحآككڪڪكنج؃كآكحكؠكضحټكسڝڝكضټدكټكجكآكسحڪك؃؃؃كئؠحكڪكئكټكزحڝكآضدكزټجكڪكضكڪكنج؃كنححكجدئكڝك؃؃ڝكؠجدكټججكئنضكڪڝ؃ټ؃كآضحكآسئكټنسكڝنقكدكټدجكآكضك؃؃زك؃كككحكقحئك؃جسكحضقكدننكسكآكضكڝجزكزدككضسؠكضكټكسك؃جقكزننكئدآكسؠڪكزكججككحزؠكئكټكقكڝكقكئجنكسجآكسجڪنقؠ؃كككضئؠكڪڝټكسكڝككؠدكنكسضآكڝڝڪكزك؃كنؠحكؠكزسټك؃ڝڝكقكدكنكجكآكقجڪكنس؃ككؠحكآكئكټكزجڝكؠكدكټججكټؠجكڪكنج؃ك؃؃حكؠكئكڝكسقڝكؠجدكټججكجقضكڝؠزك؃كآئحككآئكټكسك؃ؠقكدكټضجكضنضكڪكزكدؠككحكڪسئكسكسكڝكقكحؠنكجكڝزضكزنزك؃كككحكؠكئك؃جسكحزقكدؠنكئكآكضكڝجزكئجككضجؠكضؠټكسكحجقكق؃نكجكآكزكڪكزكججككضجؠكؠقټكزؠڝكقكئئنكآنآكضكڪكقؠزحككضضؠكؠؠټكسكڝككؠحجنكسسآكڪنڪكزك؃كنؠحكؠكززټكټؠڝكقكدكنكجكآكقجڪكنز؃ككؠحكآكئكټكزجڝكسزدكټججكټؠضكڪكنج؃كندحنؠكئكڝكسكڝكؠجدكټججكؠكضك؃كزك؃كآجحكڪجئكضجسك؃كقكدكؠججكؠكضكدجزكجكككحكآجئكڝزسكزڪقكحؠنكجكڝجضكڪززك؃كككئكڝئئك؃جسكحجقكحجننئؠسؠضكدئزككنككحكؠكضؠټكسكحضقكنننكجكآكسؠڪكزكجسككؠنؠكئكټكسكڝكقكئجنكسسآكضؠڪكقك؃كككججؠكقڪټككجڝكؠكدكنكئجآكضڝڪكئټ؃كآكحكؠكضجټكڝ؃ڝكجؠدكټكجكآكسجڪكؠض؃كسټحكټكئكټككجڝككجدكحدجكڪكضكڪكنج؃كآجحكجنئكټڝڝټڝكؠضدكؠآجكآنضكڪنزك؃كآدحكؠكئكڝ؃سكڝكقكدكزججكڝجضكدضزك؃نككضكؠكئكڪئسكسدقكزئنكئكآكضكڝئزكسنككحنؠكضؠټكسكحجقكدزنكجكآكزكڪكزكججككضجؠكضجټنزؠڝكقكئئنكزكآكضكڪكقؠ؃كككضضؠكقكټكسكڝككؠدكنكسسآكككڪكزك؃كككحكؠكزجټككسڝكقؠدكؠكجكآكسئڪكنك؃كآجحكآؠئكټككجڝكڝ؃دكنكجكڪكضكڪكنج؃كآجحكحقئكڪؠسكڝكؠئدكزئجكآكضكڝؠزك؃كآضحكئنئكټكسك؃ؠقكدكټسجكټحضنڪكزكدؠككحكڪزئكسنسكڝكقكدكنكجكڝجضكدززك؃ؠككجكؠكئكڪئسكججقكئجنكئؠآكضكدجزكز؃ككحكؠكسكټكسكحجقكئجنكنقآكسؠڪكزكجئككؠنؠكئكټكزؠڝكقكئضنكجئآكضكڪكقؠ؃كككضسؠكټنټكسكڝككؠدكنكسزآكآؠڪكزك؃كككحكؠكزجټككزڝكقؠدكؠكجكآكسئڪكضز؃كآجحكآؠئكټككجڝككددننكجكڪكضكڪكنج؃كآجحكنكئكڝكسكڝكؠجدكټججكئجضكڝكزك؃كنئحكنكئك؃جسكحكقكدكؠئجكڪزضكجؠزكدؠككحكڪجئكټزسكڝكقكجكنكجكڝجضكدجزكدجكنجؠؠكئك؃ئسكقنقكدكنكئؠآكضكدضزككنككحكؠكضؠټكسكحسقكنننكجكآكضكڪكزكججككضسؠكئؠټكزكڝكقكحئنكزڪآكقجڪكنك؃كككجئؠكټ؃ټكدؠڝكؠكدكنكئضآكآدڪكټس؃كنكحكؠكضضټكآنڝككئدكؠؠجكآكقجڪكزز؃كككحكټكئكټككجڝكؠجدكؠججنټؠضكڪكنئ؃كجڝحكؠكئكڪؠسكڝكؠضدكئڝجكآكضكڝؠزك؃كآسحكضڝئكټكسكڝكقكدكټججكڝسضكڪؠزكدكككحكآضئك؃كسكحجقكحؠنكجكڝجضكض؃زك؃كككئكؠكئك؃جسكحجقكققنكئؠآكضكدئزك؃ڪككحكؠكضؠټكسكحضقكنننكجكآكسؠڪكزكجسككؠنؠكئكټكزؠڝكقكئزنكآنآكضكڪكزك؃كككضجؠكززټكسؠڝكككدكنكئضآككجڪكنج؃كنؠحكؠكزجټكټ؃ڝكقكدكآكجكآكقجڪكنج؃ك؃قحكآؠئكټككئڝكدندكنكجكټؠضكڪكنض؃ك؃ؠحكؠكئكڪؠسكڝكؠسدكجنجكآكضكڝؠزك؃كآزحكحؠئكټكسكڝكقكدكټججكڝزضكڪؠزكدكككحكآضئكؠزسكحجقكحؠنكجكڝجضكڝدزن؃كككئكؠكئك؃جسكحجقك؃كنكضكآكضكدجزكججككنجؠكضكټكسك؃ضقك؃كنكسجآكقكڪكزكدضككئزؠك؃نټكزؠڝكقكئجنكجزآكضكڪككك؃كككضجؠكزجټكزجڝنكؠدكنكسئآكڪنڪكزك؃كنؠحكؠكزضټكڝنڝكقكدكؠؠجكآكقسڪك؃ن؃كككحكؠكئكټككجڝكؠسدكنؠجكټكضكڪكقض؃كټڪحكڪجئك؃كسكڝككضدكنڝجككټضكدكزك؃كنضحكئ؃ئكقؠسكحكقكدكؠضجك؃ضضكؠټزكحكككحكڪجئكڪضسكزدقكجكئ؃جكڝجضكدجزكقنككحڝئټئك؃ضسكڝؠقكدننكجنآكضكددزك؃كككئزؠكئكټكسكآحقكئجنكسضآكضنڪكنك؃كككجسؠكؠدټكجڝڝكككدكنكئسآكؠنڪكقئ؃كنؠحكؠكزجټكسزڝكقكدكآكجكآكقجڪكنج؃كنجحنآؠئكټككئڝكحڝدكنكجكټؠضكڪكنض؃كجڝحكؠكئكڪؠسكڝكؠسدكئڝجكآكضكڪكزك؃كآجحكڪسئكټؠسك؃كقكدكؠسجكڝكضكدجزكدؠزكحكڪجئكئ؃سكڝكقكجكنقجكڝجضكدجزكزقككجؠؠكئك؃ئسكټآقكدكنكئؠآكضكدضزككنككحكؠكضؠټكسكحسقكج؃نكجكآكسؠڪكزكجزككؠنؠكئكټكسكڝكقكئجنكسزآكضؠڪكقك؃كككجسؠكقجټككجڝككؠدكنكسجآكآ؃ڪكزك؃كؠكحكؠكزجټككجڝكڝقدكؠؠجكآكقئڪك؃ن؃كككحكآؠؠحټككضڝكڝؠدكنكجكټؠسجڪكنس؃كحنحكؠكئكڪؠسكڝكؠزدكدؠجكآكضكڪكزك؃كآجحكڪزئكټؠسك؃كقكدكؠسجكنزضكدجزكدؠككحكڪجئكڪدسنڝكقكجكنكجكڝجضكدجزكڝكككئكؠكئك؃جسكحجقككجنكئكآكضكڝسزكڝكككضجؠكزكټكسك؃سقكجزنكؠڪآكسؠڪكزكججككحزؠكئكټكقكجئقكئجنكسجآكسجڪنقؠنؠككضئؠكټنټكسكڝككؠدكنكسضآكڪنڪكزك؃كنؠحكؠكزسټكڝنڝكقكدكنكجكآكقجڪكنس؃ككؠحكآكئكټكزسڝكآڪدكټججكڝكضكڪكقس؃ككڝحكقټئك؃كسكڝككسدكج؃جكزؠضكدكزك؃كنسحكڝضئكنټسكدكقكدكټججكټسضكسدزكحكككحكڪجئك؃جسكزنقكدڝجټجكڝضضك؃دزك؃نككحنؠكئك؃دسكڝكقكجزنكجكآكضكئجزكججككضضؠكئنټكككڝكقكحزنكندآكجنڪكقك؃كككجزؠكننټكسنڝككؠدكنكسجآكضزڪكزك؃كؠكحكؠكزجټككجڝككجدنؠؠجكآكقئڪكڪح؃كككحكآؠئكټككضڝكڝحدكنكجكټؠضكڪكنس؃ك؃ححكؠكئكټكسكڝكؠجدكټسجكآؠضكڝكزك؃كنزحكڪكئك؃جسك؃ؠقكدكټججكج؃ضكڪكزكحكككحكڪجئك؃جسكسققكحؠنكجكڝئضكقآزك؃كككجؠؠكئك؃ضسكقنقكدكنكئؠآكضكدسزكڪكككحكؠكضؠټكسكحزقكنننكجكآكضكڪكزكججككضزؠكئؠټكزكڝكقكحزنكزجآكقجڪكقؠ؃كككضجؠكؠ؃ټكسكڝكنكدكنكسجآكقجڪكڪق؃كنؠحكؠكزئټكڝنڝكقكدكؠؠجكآكقضڪكڝټ؃كككحكآؠئكټككسڝكدندكنكجكټؠضكڪكنز؃كڝآحكؠكئكټكسكڝكؠجدكټزجكآؠضكڝكزك؃كنزحككزئك؃جسكحكقكدكؠزجكن؃ضكجڪزكجكككحكآقئكئدسكننقكحكنكجكټقضكئنزكدزككجؠؠكئك؃جسكڝزقكدكنكضكآكضكدجزكججككججؠنضؠټكسكحئقكحټنكجكآكسؠڪكزكجضككټآؠكئكټكزؠڝكقكئسنكڪقآكضكڪكزك؃كككضجؠكزسټكسؠڝكككدكنكئقآكقكڪكنج؃كنؠحكؠكزجټكټ؃ڝكقكدكآكجكآكقجڪكنج؃ك؃قحكآؠئكټككئڝكټټدكنكجكټؠضكڪكنض؃كحنحكؠكئكڪؠسكڝكؠسدكجنجكآكضكڝؠزك؃كآزحكئنئكټكسكڝكقكدكټججكڝزضكڪؠزكدكككحكآقئكدجسكحجقكحؠنكجكڝجضكض؃زك؃كككئكؠكئك؃جسكحجقكققنكئؠآكضكدئزككنككحكؠكضؠټكسكحضقككټنكجكآكسؠڪكزكجسككؠنؠكئكټكزؠڝكقكئزنكدؠآكضكڪكزك؃كككضجؠكززټكسؠڝكككدكنكئقآكجزڪكنج؃كنؠحكؠكزجټكزدڝنقكدكآكجكآكقجڪكنج؃كقكحكټكئكټككجڝكؠجدكحججكټكضكڪكقق؃كقكحكڪجئك؃كسكڝككقدكآزجكجضضكڝؠزك؃كآجحكؠزئكټكسكدكقكدكټججكڝجضكڝجزندؠككحكڪئئكسنسكڝكقكحؠنكجكڝضضكزنزك؃كككجؠؠكئك؃سسكقنقكدكنكجكآكضكدجزكجسككحؠؠكضكټكسك؃ققكضڪنكسجآكقكڪكزكدقككؠ؃ؠكڝؠټكككڝكقكحكنكندآككقڪكقك؃كككجكؠكننټكززڝككؠدكنكسجآكضزڪكزك؃كؠكحكؠكزجټككجڝككجدنؠؠجكآكقئڪكقټ؃كككحكآؠئكټككضڝكجآدكنكجكټؠضكڪكنس؃كئقحكؠكئكټكسكڝكؠجدكټسجكآؠضكڝكزك؃كنكحكڪكئك؃جسك؃ؠقكدكټججكج؃ضكڪكزكحكككحكڪجئك؃جسكسققكحؠنكجكڝئضكزنزك؃كككجؠؠكئك؃ضسكقنقكدكنكئؠآكضكدسزكقڝككحكؠكضؠټكسكحزقكنننكجكآكضكحڪزكججككضزؠكئؠټكزكدكقكحكنكزجآكقجڪكقؠ؃كككضجؠكؠ؃ټكسكڝكنكدكنكسجآكقجڪكڪق؃كنؠحكؠكزئټكڝنڝكقكدكؠؠجكآكقضڪكڝټ؃كككحكآؠئكټككسڝكدندكنكجكټؠضكڪكنز؃كزؠحكؠكئكټكسكڝكؠجدكټزجكآؠضكڝكزك؃كنكحككزئك؃جسك؃ؠقكدكټججكټدضنڪكزكحكككحكڪجئك؃جسكڪكقكجكنكجكڝجضكدجزكقجككجكؠكئكڪكسكڪكقكئجنكسكآكضكڝكزكحزكككضؠكضؠټكسكحجقكدزنكجكآكزكڪكزكججككضجؠكضجټنزؠڝكقكئئنكآنآكضكڪكقؠ؃كككضضؠكټنټكسكڝككؠدكنكسسآكڪنڪكزك؃كككحكؠكزجټككسڝكقؠدكؠكجكآكسكڪكؠڪ؃كآجحكڪكئكټكزكڝكد؃دكضؠجكڝكضكڪكقن؃ك؃دحكئضئكڪكسكڝككندك؃نجكټزضكڝؠزك؃كآجحكؠزئكټكسكدكقكدكټججكڝجضكڝجزندؠككحكڪئئكققسكڝكقكحؠنكجكڝضضكئدزك؃كككجؠؠكئك؃سسكزضقكدكنكجكآكضكدجزكجسككحؠؠكضكټكسك؃نقكئكنكسجآكسؠڪكزكججككك؃ؠكئكټكقكڝكقكئجنكسجآكآقڪكقؠ؃كككضئؠككټټكسكڝككؠدكنكسضآكڪنڪكزك؃كنؠحكؠكزسټكحڝڝكقكدكؠؠجكآكقزڪك؃ن؃كككحكؠكئكټككجڝكؠزدكنؠجكټكضكڪكقن؃كټجحكڪجئكڪؠسكڝكؠجدكد؃جكآكضك؃كزك؃كآجحكڪجئكئقسك؃ؠقكدكټئجكضنضكڪكزكدؠككحكڪضئكضټسكڝكقكحؠنكجكڝسضكزنزك؃كككجؠؠكئك؃زسكقزقكدكنكجكآكضكدجزكجزككحؠؠكضكټكسك؃نقكڝزنكسجآكسؠڪكزكججككجدؠنئكټكقكڝكقكئجنكسجآكئكڪككك؃كككضجؠكزجټكڪجڝكككدكنكئنآكئكڪكنج؃كآكحكؠكضنټكقزڝكقڝدنؠؠجكآكقجڪكزز؃كككحكټكئكټككجڝكؠجدكؠججنټؠضكڪكنئ؃كحنحكؠكئكڪؠسكڝكؠضدكجنجكآكضكڝؠزك؃كآسحكئنئكټكسكڝكقكدكټججكڝسضكڪؠزكدكككحكآنئكدڪسكحجقكئكنكجكټنضكز؃زكؠؠككئكؠكئك؃جسك؃نقككدنكضكآكضكدجزكججكك؃ڪؠكئڝسټسكحضقكحضنكجنآكضنڪكزكجدككحكؠكضقټكسكڝكقكڪحنكسجآكقضڪكزن؃كآكحكؠكضؠټكټدڝكقسدكؠكجكآكسؠڪكټن؃كنزحكآؠئكټككجڝكقزدكنكجكڪكضكڪكنج؃كآجحكآجئنڪؠسكڝكؠئدكضقجكآكضكڝؠزك؃كآضحكددئكټكسك؃ؠقكدكټسجكئضضكڪكزك؃كككحكڪجئك؃سسكڝؠقكحكنكجكټؠضكدكزكججككجؠككئك؃جسكس؃قكدكنكضكآقضكدجزكججكككقؠكضؠټكسكحئقكسټنكجكآكسؠڪكزكجضككؠنؠكئكټكزؠڝكقكئسنكححآكضكڪكقؠ؃كككضزؠكټنټكسكڝكقكدكنكسجآكقزڪكزؠ؃كنكحكؠكضؠټكنجڝكؠجدكؠؠجكآكقجڪكڪ؃؃كككحكټكئكټككجڝكؠجدكدقجكټؠضكڪكنئ؃كحنحكؠكئكڪؠټحڝكؠضدكحټجكآكضكڝؠقج؃كآسحكئنئكټكسك؃ؠقكدكټزجكضزضكڪكزك؃كككحكڪجئك؃زسكڝؠقكحكنكجكټؠضكآززكججككجؠؠكئك؃جسك؃دقندكنكضكآكضكدجزكججككدكؠكسكټكسكحجقكئجنكؠجآكسكڪكزكدؠككدكؠكزجټكككڝكقكحؠنكضزآكححڪكقؠ؃كككضجؠكئزټكسكڝكنكضئنكسجآكقجڪكقج؃ننؠجڝؠكزئټكڝنڝكقكدكؠؠجكآكقضڪك؃ن؃كككحكآؠئكټككسڝكدندكنكجكآكضكڪكنج؃كآسحكؠؠئكڪكسكڝككؠدكڪڪجكڝجضكدكزك؃كنؠحكئ؃ئكقؠسكدكقكدكټججكټؠضكسدزكحكككحكڪجئك؃جسكټڪقكدڝجټجكڝضضك؃؃زك؃نككحنؠكئك؃دسكڝكقكحكنكجكآكضكؠحزكججككضضؠكئنټكككڝكقكحآنكندآكټزڪكقك؃كككجآؠكننټكززڝككؠدكنكسجآكضزڪكزك؃كؠكحكؠكزجټككجڝككجدنؠؠجكآكقئڪك؃ن؃كككحكآؠئكټككضڝكززدكنكجكټؠضكڪكنس؃كئقحكؠكئكټكسكڝكؠجدكټسجكآؠضكڝكزك؃كنآحكڪكئك؃جسك؃ؠسكدكټججكج؃ضكڪكزكحككقحكڪجئك؃جسكسققكحؠنكجكڝئضكزنزك؃كككجؠؠكئك؃ضسكقنقكدكنكئؠآكضكدسزكقكككحكؠكضؠټكسكحزقكنننكجكآكضكڪكزكججككضزؠكئؠټكزكڝكقكحآنكزجآكقجڪكقؠ؃كككضجؠكؠ؃ټكسكڝكنكدكنكسجآكقجڪكڪق؃كنؠحكؠكزئټكڝنڝكقكدكؠؠنحآكقضڪكؠآ؃كككحكآؠضجټككسڝكدندكنكجكټؠضكڪكنز؃كټآحكؠكئكټكسكڝكؠجدكټزجكآؠضكڝكزك؃كنآحككزئك؃جسك؃ؠقكدكټججكټدضنڪكزكحكككحكڪجئك؃جسكڪكقكجكنكجكڝجضكدجزكقجككجكؠكئكڪآسكڪكقكئجنكسكآكضكڝآزكحزككدسؠكضؠټكسكحجقكدزنكجكآكزكحئزكججككضجؠكضجټنزؠ؃ڝقكئئنكآنآكضكڪكقؠ؃كككضضؠكټنټكسكڝككؠدكنكسسآكڪنڪكزك؃كككحكؠكزجټككسڝكقؠدكؠكجكآكسآڪكؠڪ؃كآجحكڪكئكټكزآڝكد؃دكضؠجكڪكضكڪكنج؃كنآحكجدئكڝكسكڝكؠجدكټججكنڪضكڪؠنز؃كآضحكؠڪئكټكسكڝكضحدكټججكڝضضكڪنزكجكككحكآټئكئدسكآجقكحكنكجكټټضكئنزكدزككجؠؠكئك؃جسكڝزقكدكنكضكآكضكدجزكججككججؠنضؠټكسكحئقكنننكجكآكسؠڪكزكجضككدزؠكئكټكزؠڝكقكئسنكڪقآكضكڪكزك؃كككضجؠكزسټكسؠڝكككدكنكئټآكقكڪكنج؃كنؠ؃كؠكزجټكټ؃ڝكقكدكآكجقآكقجڪكنج؃ك؃قحكآؠئكټككئڝكج؃دكنكجكټؠضكڪكنض؃كحنحكؠكئكڪؠسكڝكؠسدكحسجكآكضكڝؠزك؃كآزحكئنئكټكسكڝكقكدكټججكڝزضكڪؠزكدكككحكآټئكدجسكحجقكحؠنكجكڝجضكض؃زك؃كككئكؠكئك؃جسكحجقكققنكئؠآكضكدئزككنككحكؠكضؠئحسكحضقكضآنكجكآكسؠڝجزكجسككؠنؠكئكټكزؠڝكقكئزنكزآآكضكڪكزك؃كككضجؠكززټكسؠڝكككدكنكئټآكجزڪكنج؃كنؠحكؠكزجټكزدڝنقكدكآكجكآكقجڪكنج؃كقكحكټكئكټككجڝكؠجدكحججكټكضكڪكقټ؃كقكحكڪجئك؃كسكڝككټدكآزجكئحضكڝؠزك؃كآجحكؠزئكټكسكدكآئدكټججكڝجضكڝجزندؠنڝحكڪئئكسنسكڝكقكحؠنكجكڝضضكزنزك؃كككجؠؠكئك؃سسكقنقكدكنكجكآكضكدجزكجسككحؠؠكضكټكسك؃ټقكضڪنكسجآكقكڪكزكدټككؠ؃ؠكڝؠټكقكڝكقكئجنكئټآكټدڪككك؃كككضجؠكزجټكئڪڝكقؠئزنكسضآكسڪڪكزك؃كككڝحؠكزجټككضڝكقندكټكجكآكسڪڪكڪد؃كڝزحكآكئكټكزڪڝكڪندكؠزجكټؠضكڪكنج؃ككزحكؠكئكڝكسكڝكؠجدكټججكټجضنڝؠزك؃كآئحكئنئكټكسك؃ؠقكدكټضجكؠزضكڪكزكدؠككحكڪسئكققسكڝكقكدكنكجكڝجضكدسزك؃ؠككجكؠكئكڪڪسكحكقكئجنكئؠنكضكدجزكز؃ككحكؠكسكټقسكحجقكئجنكنقآكسؠڪكزكجئككحآؠنئكټكزؠڝكقكئضنكآنآكضكڪكقؠ؃كككضسؠكك؃ټكسكڝككؠدكنكسزآكڪنڪكزك؃كككحكؠكزجټككزڝكقؠدكؠكجكآكسڪڪكؠج؃كآجحكآؠئكټككجڝكڝ؃دكنكجكڪكضكڪكنج؃كآجحكحقئكڪؠسكڝكؠئدكجنجكآكضكڝؠڪح؃كآضحكڝآئكټكسك؃ؠكجدكټسجكضنضكڪكزكدؠككحكڪزئكدآسكڝكقكدكنكجكڝجضكدززك؃ؠككجكؠكئكڪڪسكټزقكئجنكئؠآكضكدجزكددكنحكؠكسكټكسكحجقكئجنكحكآكزكڪكزكججككضجؠكآجټكزكڝكقكحڪنكحكآكقجڪكنك؃كككجڪؠكسزټكجقڝككؠدكنكسجآكضزڪكزك؃كؠكسئؠكزجټككجڝككجدنؠؠئڝآكقئڪك؃ن؃كككحكآؠئكټككضڝكدندكنكجكټؠضكڪكنس؃كحنحكؠكئكټكسكڝكؠجدكټسجكآؠضكڝكزك؃كنڪحكڝڪئك؃جسكحكقكدكؠڪجكض؃ضككززكحكككحكڪجئكڪڪسكزدقكجكنكجكڝجضكدجزكڪڪككحؠڪزئك؃ضسك؃زقكدكنكجككحضكدجزكجضككحنؠكزكټكسك؃ڝقكقدنكزئآكسكڪكزكدڝككقنؠكضزټكزؠڝكقكئجنكجزآكضكڪككك؃كككضجؠكزجټكزجڝنكؠدكنكسئآكڪنڪكزك؃كنؠحكؠكزضټكضزڝكقكدكؠؠجكآكقسڪكحق؃كككحكؠكئكټككجڝكؠسدكنؠجكټكضكڪكقڝ؃كآكحكڪجئكڪؠئكڝكؠجدكد؃جكآكضك؃كزق؃كآجحكڪجئكئقسك؃ؠقكدكټئجكسزضكڪكزكدؠككحكڪضئكسنسكڝكقكحؠنكجكڝسضكنټزك؃كككجؠؠكئك؃زسكقنقكدكنكجكآكضكدجزكجزككحؠؠكضكټكسك؃ڝقكضجنكسجآكسؠڪكزكججككك؃ؠكئكټكقكڝكقكئجنكسجآكآقڪكقؠ؃كككضئؠكټنټكسكڝككؠقحنكسضآككآڪكزك؃كنؠججؠكزسټكڝنڝكقكدكؠؠجكآكقزڪكؠآ؃كككحكؠكئكټككجڝكؠزدكنؠجكټكضكڪكقڝ؃كززحكڪجئكڪؠسكڝكؠجدكؠدجنآكضك؃كزك؃كآجحكڪجئكآكسكدكقكدكټججكڝجضكسجزكدكككحكآڝئكآكسكحجقكئكنكجكټڝضك؃ززكسقككجؠؠكئك؃جسكڝزقكدكنكضك؃ئضكدجزكججككججؠنضؠڪڝسكحئقكنننكجكآكسؠڪكزكجضككؠنؠكئكټكزؠڝكقكئسنكآنآكضكڪكزك؃كككضجؠكزسټكسؠڝكككدكنكئڝآككڪڪكنج؃كآكحكؠكضڝټكڝ؃ڝكجؠدكآكجكآكقجڪكقڝ؃كددحكټكئكټككجڝكؠجدكقڪجكآؠقزڪكنض؃كنټحكؠكئكټكجحڝكؠجدكټضجكآنضكدكزك؃كؠ؃حكحدئكئڪسك؃كقكدكآ؃جكحنضكڪنزكدؠككحكڪجئكټزسكڝكقكجكنكجكڝجضكدجزكدجكنجؠؠكئك؃ئسكسحقكدكنكئؠآكضكدضزكزحككحكؠكضؠټكسكحسقكقحنكجكآكضكڪكزكججككضسؠكئؠټكزكڝكقكج؃نكسكآكقجڪكقؠڪكككضجؠكؠ؃ټكسكڝكنكدقنكسجآكقجڪكڪق؃كنؠحكؠكزئټكقسڝكقكدكؠؠجكآكقضڪك؃ن؃كككحكآؠئكټككسڝكسكدكنكجكټؠضكڪكنز؃كحنحكؠكئكټكسكڝكؠجدكټزجكآؠضكڝكزك؃كؠ؃حكڝجئك؃جسك؃ؠقكدكټججكج؃ضكڪكزكحكككحكڪجئك؃جسكسققكحؠنكجكڝئضكزنزك؃كككجؠححئك؃ضسكزټقكدكنكئؠئضضكدسزككنككحكؠكضؠټكسكحزقكزآنكجكآكضكڪكزكججككضزؠكئؠټكزكڝكقكج؃نكدزآكقجڪكنك؃كككئ؃ؠكح؃ټكؠڪڝكؠكدكنكضدآكآدڪكز؃؃كنكحكؠكسدټكآنڝكن؃دكؠؠجكآكقجڪكزز؃كككحكټكئكټككجڝكؠجدكؠججنټؠضكڪكنئ؃كئقحكؠكئكڪؠټحڝكؠضدكضقجكآكضكڝؠضن؃كآسحكئنئكټكسكڝكقكدكټججكڝسضكڪؠزكدكككحكټدئك؃كسكحجقكحؠنكجكڝجضكض؃زك؃كككئكؠكئك؃جسكحجقكققنكئؠآكضكدئزككنككحكؠكضؠټكسكحضقككټنكجكآكسؠڪكزكجسككؠنؠكئكټكزؠڝكقكئزنكئ؃آنضكڪكزك؃كككضجؠكززټكسؠڝكككحقنكضدآكجزڪكنج؃كنؠڝآؠكزجټكزدڝنقكدكآكجكآكقجڪكنج؃كقكحكټكئكټككجڝكؠجدكحججكټكضكڪككد؃كقكحكڪجئك؃كسكڝكنددكآزجكنڝضكڝؠزك؃كآجحكؠزئكټكسكدكقكدكټججكڝجضكڝجزندؠككحكڪئئكسنسكڝكقكحؠنكجكڝضضكزنزك؃كككجؠؠكئك؃سسكقنقكدكنكجك؃ڪضكدجزكجسككحؠؠكضكڪقسكددقكضڪنكسجآكقككقزكحدككؠ؃ؠكڝؠټكقكجئقكئجنكضدآكټدڪكككن؃ككضجؠكزجټكئڪڝكقؠئزنكسضآكسئڪكزك؃كككڝحؠكزجټككضڝكقندكټكجكآكزحڪكڪد؃كؠدحكآكئكټكقحڝكڪندكآ؃جكټؠضكڪكنج؃ككزحكؠكئكڝكسكڝكؠجدكټججكټجضنڝؠزك؃كآئحكسقئكټكسك؃ؠقكدكټضجكزقضكڪكزكدؠككحكڪسئكسنسكڝكقكدكنكجكڝجضكدسزك؃ؠككجكؠكئكڝحسكحكقكئجنكئؠنكضكدجزكز؃ككحكؠكسكټقسكحجقكئجنكنقآكسؠڪكزكجئككزټؠكئكټكزؠڝكقكئضنكآنآكضكڪكقؠ؃كككضسؠكجټټكسكڝككؠدكنكسزآكڪنڪكزك؃كككحكؠكزجټككزڝكقؠدكؠكجكآكزحڪكؠج؃كآجحكآؠئكټككجڝكڝ؃دكنكجكڪكضكڪكنج؃كآجحكحقئكڪؠسكڝكؠئدكجنجكآكضكڝؠڪح؃كآضحكجټئكټكسك؃ؠكجدكټسجكضنضكڪكزكدؠككحكڪزئكڪ؃سنڝكقكدكنكجكڝجضكدززك؃ؠككجكؠكئكڝحسكټزقكئجنكئؠآكضكدجزكددكنحكؠكسكټكسكحجقكئجنكحكآكزكڪكزكججككضجؠكآجټكزكڝكقكجحنكحكآكقجڪكنك؃كككئحؠكسزټككئڝككؠدكنكسجآكضزڪكزك؃كؠكسئؠكزجټككجڝككجدنؠؠئڝآكقئڪك؃ن؃كككحكآؠئكټككضڝكدندكنكجكټؠضكڪكنس؃كحنحكؠكئكټكسكڝكؠجدكټسجكآؠضكڝكزك؃كؠححكڝڪئك؃جسكحكقكدكآحجكض؃ضككؠزكحكككحكڪجئكڝحسكزدقكجكنكجكڝجضكدجزكڪڪككحؠڪزئك؃ضسك؃دقكدكنكجككحضكدجزكجضككحنؠكزكټكسكدجقكقدنكنجآكسكڪكزكحجككقنؠكس؃ټكزؠڝكقكئجنكجزآكضكڪككك؃كككضجؠكزجټكزجڝنكؠدكنكسئآك؃قڪكزك؃كنؠحكؠكزضټكدقڝكقكدكؠؠجكآكقسڪك؃ن؃كككحكؠكئكټككجڝكؠسدكنؠجكټكضكڪككج؃كآكحكڪجئكڪؠئكڝكؠجدكد؃جكآكضك؃كزق؃كآجحكڪجئكئقسك؃ؠقكدكټئجكدټضكڪكزكدؠككحكڪضئكسنسكڝكقكحؠنكجكڝسضكزجزك؃كككجؠؠكئك؃زسكقنقكدكنكجكآكضكدجزكجزككحؠؠكضكټكسكدجقكضجنكسجآكسؠڪكزكججككك؃ؠكئكټكقكڝكقكئجنكسجآكآقڪكقؠ؃كككضئؠكټنټكسكڝككؠقحنكسضآكټټڪكزك؃كنؠججؠكزسټكڝنڝكقكدكؠؠجكآكقزڪكق؃؃نككحكؠكئكټككجڝكؠزدكنؠجكټكضكڪككج؃كززحكڪجئكڪؠسكڝكؠجدكؠدجنآكضك؃كزك؃كآجحكڪجئكآكسكدكقكدكټججكڝجضكسجزكدكككحكټجئكآكسكحجقكئكنكجكڪجضك؃ززكټدككجؠؠكئك؃جسكڝزقكدكنكضك؃ئضكدجزكججككججؠنضؠڪڝسكحئقكنننكجكآكسؠڪكزكجضككؠنؠكئكټكزؠڝكقكئسنكآنآكضكڪكزك؃كككضجؠكزسټكسؠڝكككدكنكضجآككڪڪكنج؃كآكحكؠكسجټكڝ؃ڝكجؠدكآكجكآكقجڪككج؃كن؃حكټكئكټككجڝكؠجدكحنجكآؠقزڪكنض؃ككنحكؠكئكټكجحڝكؠجدكټضجكآنضكدكزك؃كؠئحكحدئكآ؃سك؃كقكدكآئجكحنضك؃؃زكدؠككحكڪجئكټزسكڝكقكجكنكجكڝجضكدجزكدجكنجؠؠكئك؃ئسكنققكدكنكئؠآكضكدضزكؠقككحكؠكضؠټكسكحسقكنننكجكآكضكڪكزكججككضسؠكئؠټكزكڝكقكجئنكسكآكقجڪكقؠڪكككضجؠكؠ؃ټكسكڝكنكدقنكسجآكقجڪكڪق؃كنؠحكؠكزئټكؠټڝكقكدكؠؠجكآكقضڪك؃ن؃كككحكآؠئكټككسڝككؠدكنكجكټؠضكڪكنز؃كحنحكؠكئكټكسكڝكؠجدكټزجكآؠضكڝكزك؃كؠئحكڝجئك؃جسك؃ؠقكدكټججكج؃ضكڪكزكحكككحكڪجئك؃جسكسققكحؠنكجكڝئضكزنزك؃كككجؠححئك؃ضسكزټقكدكنكئؠټجضكدسزككنككحكؠكضؠټكسكحزقكح؃ننجكآكضكڪكزكججككضزؠكئؠټكزكڝكقكجئنكدزآكقجڪكقؠ؃كككضجؠكضدټنسكڝكنكدكنكسجآكقجڪكسك؃كؠكحكؠكزجټككجڝك؃جدكؠكجكآكزئڪكسك؃كآجحكڪكئكټكقئڝكنزدكقحجكټؠضكڪكنج؃ككزحكؠكئكڝكنئڝكؠجدكټججكټجضنڝؠقڝ؃كآئحكئنئكټكسك؃ؠقكدكټضجكضنضكڪكزكدؠككحكڪسئكسنسكڝكقكدكنكجكڝجضكدسزك؃ؠككجكؠكئكڝئسكجڪقكئجنكسكآكضك؃ئزكك؃ككټؠؠكسكټكسكحجقكجئنكئ؃آكزكڪكزكججككضجؠكآنټكسؠحزقكئضنكئقآكضكڪكزكټحككضجؠكزضټكسنڝكؠكدكنكضضآكآدڪكزټ؃ننكحكؠكسضټكآنڝكن؃دكؠؠجكآكقجڪكزز؃كككحكټكئكټككجڝكؠجدكؠججنټؠضكڪكنئ؃كئقحكؠكئكڪؠسكڝكؠضدكضقجكآكضكڝؠزك؃كآسحكئنئكټكسكڝكقكدكټججكڝسضكڪؠزكدكككحكټضئك؃كسكحجقكحؠقكجكڝجضكض؃زك؃كككئكؠقئك؃جسكحجقكققنكئؠآكضكدئزكضټككحكؠكضؠټكسكحضقكنننكجكآكسؠڪكزكجسككججؠكئكټكزؠڝكقكئزنكآنآكضكڪكزك؃كككضجؠكززټكسؠڝكككدكنكضضآككجڪكنج؃كنؠحكؠكزجټكټ؃ڝكقكدكآكجكآكقجڪكنج؃ك؃قحكآؠئكټككئڝكدندكنكجكټؠآحڪكنض؃كدټحكؠكئكڪؠزجڝكؠسدكجنجكآكضكڝؠزك؃كآزحكآ؃ئنټكسكڝكقكدكټججكڝزضكڪؠزكدكككحكټضئكؠزسكحجقكحؠنكجكڝجضكڝدزن؃كككئكؠكئك؃جسكحجقك؃كنكضكآكضكدجزكججككنجؠكضكټكسكدضقك؃كنكسجآكقكڪكزكحضككئزؠكنؠټكزؠڝكقكئجنكجزآكضكڪكككئئككضجؠكزجټكزجڝنكؠحڝنكسئآكڪنڪكزك؃كنؠحكؠكزضټكڝنڝكقكدكؠؠجكآكقسڪك؃ن؃كككحكؠكئكټككجڝكؠسدكنؠجكټكضكڪككض؃كټڪحكڪجئك؃كسكڝكنضدكج؃جكزؠضك؃كزك؃كآجحكټضئكضدسكدكقكدكټججكڝجضكآڪزك؃ؠآزحكڪضئكڝسسكڝكقكدكؠؠجكڝجضكدضزك؃نككضكؠكئكڝسسكسدقكضننكئكآكضك؃سزكسنككئ؃ؠكضؠټكسكحجقكدزنكجكآكزكڪكزكججككضجؠكضجټنزؠڝكقكئئنكڪقآكضكڪكقؠ؃كككضضؠكڝقټكسكڝككؠدكنكسسآكڪنڪكزك؃كككحكؠكزجټككسڝكقؠدكؠكجكآكزسڪكنك؃كآجحكآؠئكټككجڝكڝ؃دكنكجكڪكضكڪكنج؃كآجحكحقئكڪؠسكڝكؠئدكڝټجكآكضكڝؠزك؃كآضحكئنئكټكسك؃ؠقكدكټسجكح؃ضكڪكزكدؠككحكڪزئكسنسكڝكقكدكنكجكڝجضكدززك؃ؠككجكؠكئكڝسسكججقكئجنكئؠآكضكدجزكز؃ككحكؠكسكټكسكحجقكئجنكنقآكسؠڪكزكجئككؠنؠكئكټكزؠڝكقكئضنكؠټآكضكڪكقؠ؃كككضسؠكټنټكسكڝككؠدكنكسزآكس؃ڪنزك؃كككحكؠكزجټككزڝكقؠدكؠكجكآكزسڪكضز؃كآجحكآؠئكټككجڝككددننكجكڪكضكڪكنج؃كآجحكنكئكڝكسكڝكؠجدكټججكئجضكڝكزك؃كؠسحكنكئك؃جسكحكقكدكآسجكڪزضكسقزكدؠككحكڪجئكټزسكڝكقكجكنكجكڝجضكدجزكدجكنجؠؠكئك؃ئسكقنقكدكنكئؠآكضكدضزككنككحكؠكضؠټكسكحسقكنننكجكآكضكڪكزكججككضسؠكئؠټكزكڝكقكجسنكزڪآكقجڪكنك؃كككئسؠكټ؃ټكدؠڝكؠكدكنكضزآكآدڪكؠؠ؃كنكحكؠكسزټكآنڝكقندكؠؠجكآكقجڪكزز؃كككحكټكئكټككجڝكؠجدكؠججنټؠضكڪكنئ؃ك؃ححكؠكئكڪؠسكڝكؠضدكدحجكآكضكڝؠزك؃كآسحكححئكټكسكڝكقكدكټججكڝسضكڪؠزكدكككحكټزئك؃كسكحجقكحؠنكجكڝجضكض؃زك؃كككئكؠكئك؃جسكحجقكققنكئؠآكضكدئزكدنككحكؠكضؠټكسكحضقكنننكجكآكسؠڪكزكجسكك؃كؠكئكټكزؠڝكقكئزنكآنآكضكڪكزك؃كككضجؠكززټكسؠڝكككدكنكضزآككجڪكنج؃كنؠحكؠكزجټكټ؃ڝكقكدكآكجكآكقجڪكنج؃ك؃قحكآؠئكټككئڝكدندكنكجكټؠضكڪكنض؃كدټحكؠكئكڪؠسكڝكؠسدكجنجكآكضكڝؠزك؃كآزحكدآئكټكسكڝكقكدكټججكڝزضكڪؠزكدكككحكټزئكؠزسكحجقكئكنكجكڪزضكآ؃زكضڪككضكؠكئكڝقسكسدقكڝضنكئكآكضك؃قزكسنككئزؠكضؠټكسكحجقكدزنكجكآكزكڪكزكججككضجؠكضجټنزؠڝكقكئئنككدآكضكڪكقؠ؃كككضضؠكڝقټكسكڝككؠدكنكسسآكټضڪكزك؃كككحكؠكزجټككسڝكقؠدكؠكجكآكزقڪكنك؃كآجحكآؠئكټككجڝكڝ؃دكنكجكڪكضكڪكنج؃كآجحكحقئكڪؠسكڝكؠئدكجنجكآكضكڝؠزك؃كآضحكجټئكټكسك؃ؠقكدكټسجكضنضكڪكزكدؠككحكڪزئكدآسكڝكقكدك؃سجكڝجضكدززك؃ؠككجكؠكئكڝقسكټزقكئجنكئؠآكضكدجزكددكنحكؠكسكټكسكحجقكئجنكحكآكزكڪكزكججككضجؠكآجټكزكڝكقكجقنكحكآكقجڪكنك؃كككئقؠكسزټككؠڝككؠدكنكسجآكضزڪكزك؃كؠكحكؠكزجټككجڝككجدنؠؠجكآكقئڪك؃ن؃كككحكآؠؠحټككضڝكدندكنكجكټؠدقڪكنس؃كحنحكؠكئكټكسكڝكؠجدكټسجكآؠضكڝكزك؃كؠقحكڝڪئك؃جسكحكقكدكآقجكض؃ضككؠزكحكككحكڪجئكڝقسكزدقكجكنكجكڝجضكدجزكڪڪككحؠڪزئك؃ضسكڝڝقكدكنكجككحضكدجزكجضككحنؠكزكټكسكدكقكقدنكحضآكسكڪكزكحكككقنؠكسزټكزؠڝكقكئجنكجزآكضكڪككك؃كككضجؠكزجټكزجڝنكؠدكنكسئآكؠدڪكزك؃كنؠحكؠكزضټكدقڝكقكدكؠؠجكآكقسڪكڝض؃كككحكؠكئكټككجڝكؠسدكنؠجكټكضكڪككك؃كآكحكڪجئكڪؠئكڝكؠجدكد؃جكآكضك؃كزق؃كآجحكڪجئكئقسك؃ؠقكدكټئجكضنضكڪكزكدؠككحكڪضئكسنسكڝكقكحؠنكجكڝسضكقئزك؃كككجؠؠكئك؃زسكقنقكدكنكجكآكضكدجزكجزككحؠؠكضكټكسكدكقكضجنكسجآكسؠڪكزكججككك؃ؠكئكټكقكڝكقكئجنكسجآكآقڪكقؠ؃كككضئؠكټنټكسكڝككؠقحنكسضآكټټڪكزك؃كنؠججؠكزسټكڝنڝكقكدكؠؠجكآكقزڪكؠآ؃كككحكؠكئكټككجڝكؠزدكنؠجكټكضكڪككك؃كززحكڪجئكڪؠسكڝكؠجدكؠدجنآكضك؃كزك؃كآجحكڪجئكآكسكدكقكدكټججكڝجضكسجزكدكككحكټكئكآكسكحجقكئكنكجكڪكضك؃ززكدآككجؠؠكئك؃جسكڝزقكدكنكضك؃ئضكدجزكججككججؠنضؠڪڝسكحئقكنننكجكآكسؠڪكزكجضككؠنؠكئكټكزؠڝكقكئسنكآنآكضكڪكزك؃كككضجؠكزسټكسؠڝكككدكنكضكآككڪڪكنج؃كآكحكؠكسكټكڝ؃ڝكجؠدكآكجكآكقجڪككك؃كددحكټكئكټككجڝكؠجدكقڪجكآؠقزڪكنض؃كنححكؠكئكټكحسڝكؠجدكټضجكآنضكدكزك؃كؠنحكحدئكزحسك؃كقكدكآنجكحنضك؃ززكدؠككحكڪجئكټزسكڝكقكجكنكجكڝجضكدجزكدجكنجؠؠكئك؃ئسكضدقكدكنكئؠآكضكدضزكؠقككحكؠكضؠټكسكحسقككضنكجكآكضكڪكزكججككضسؠكئؠټكزكڝكقكجننكسكآكقجڪكقؠ؃كككضجؠكؠ؃ټكسكڝكنكدكنكسجآكقجڪكڪق؃كنؠحكؠكزئټكڝنڝكقكدكؠؠجكآكقضڪك؃ن؃كككحكآؠئكټككسڝكټسدكنكجكټؠضكڪكنز؃كحنحكؠكئكټكسكڝكؠجدكټزجكآؠضكڝكزك؃كؠنحكڝجئك؃جسك؃ؠقكدكټججكج؃ضكڪكزكحكككحكڪجئك؃جسكسققكحؠنكجكڝئضكزنزك؃كككجؠؠكئك؃ضسكزټقكدكنكئؠآكضكدسزككنككحكؠكضؠټكسكحزقكضآنكجكآكضكڪكزكججككضزؠكئؠټكزكڝكقكجننكدزآكقجڪكقؠ؃كككضجؠكضدټنسكڝكنكدكنكسجآكقجڪكسك؃كؠكحكؠكزجټككجڝك؃جدكؠكجكآكزنڪكسك؃كآجحكڪكئكټكقنڝكنزدكحقجكټؠضكڪكنج؃ككزحكؠكئكڝكسكڝكؠجدكټججكټجضنڝؠزك؃كآئحكئنئكټكسك؃ؠقكدكټضجكضنضكڪكزكدؠككحكڪسئكسنسكڝكقكدكنكجكڝجضكدسزك؃ؠككجكؠكئكڝنسكجڪقكئجنكسكآكضك؃نزكك؃ككټؠؠكزكټكسكدؠقكقدنككئآكسكڪكزكحؠككقنؠكسزټكزؠڝكقكئجنكجزآكضكڪككك؃كككضجؠكزجټكزجڝنكؠدكنكسئآكؠدڪكزك؃كنؠحكؠكزضټكدقڝكقكدكؠؠجكآكقسڪكڝض؃كككحكؠكئكټككجڝكؠسدكنؠجكټكضكڪككؠ؃كآكحكڪجئكڪؠسكڝكؠجدكد؃جكآكضك؃كزك؃كآجحكڪجئكئقسك؃ؠقكدكټئجكدټضكڪكزكدؠككحكڪضئكسنسكڝكقكحؠنكجكڝسضكدقزك؃كككجؠؠكئك؃زسكقنقكدكنكجكآكضكدجزكجزككحؠؠكضكټكسكدؠقكضجنكسجآكسؠڪكزكججككك؃ؠكئكټكقكڝكقكئجنكسجآكآقڪكقؠ؃كككضئؠكټنټكسكڝككؠدكنكسضآكضئڪكزك؃كنؠحكؠكزسټكڝنڝكقكدكؠؠجكآكقزڪكؠآ؃كككحكؠكئكټككجڝكؠزدكنؠجكټكضكڪككؠ؃كززحكڪجئكڪؠسكڝكؠجدكؠدجنآكضك؃كزك؃كآجحكڪجئكآكسكدكقكدكټججكڝجضكسجزكدكككحكټؠئكآكسكحجقكئكنكجكڪؠضك؃ززكققككجؠؠكئك؃جسكڝزقكدكنكضكآكضكدجزكججككججؠنضؠټكسكحئقكنننكجكآكسؠڪكزكجضككؠنؠكئكټكزؠڝكقكئسنكآنآكضكڪكزك؃كككضجؠكزسټكسؠڝكككدكنكضؠآككڪڪكنج؃كآكحكؠكسؠټكڝ؃ڝكجؠدكټكجكآكزآڪكڪد؃كض؃حكآكئكټكقآڝكڪندكآزجكټؠضكڪكنج؃ككزحكؠكئكڝكسنڝكؠجدكټججكټجضنڝؠزك؃كآئحكآټئكټكسك؃ؠقكدكټضجكزآضكڪكزكدؠككحكڪسئكققسكڝكقكدكنكجكڝجضكدسزك؃ؠككجكؠكئكڝآسكحكقكئجنكئؠآكضكدجزكز؃ككحكؠكسكټكسكحجقكئجنكنقآكسؠڪكزكجئككزحؠكئكټكزؠڝكقكئضنكآنآكضكڪكقؠزحككضسؠكئحټكسكڝككؠڝننكسزآكڪنڪكزك؃كككحكؠكزجټككزڝكقؠدكؠكجكآكزآڪكؠج؃كآجحكآؠئكټككجڝكڝ؃دكنكجكڪكضكڪكنج؃كآجحكحقئكڪؠسكڝكؠئدكجنجكآكضكڝؠزك؃كآضحككقئكټكسك؃ؠقكدكټسجكضنضكڪكزكدؠككحكڪزئككئسكڝكقكدكنكجكڝجضكدززك؃ؠككجكآقئكڝآسكټزقكئجنكئؠكآضكدجزكددكنحكؠكسكټكسكحجقكئجنكحكآكزكڪكزكججككضجؠكآجټكزكڝكقكجآنكحكآكقجڪكنك؃كككئآؠكسزټكڝسڝككؠدكنكسجآكضزڪكزك؃كؠكحكؠكزجټككجڝككجدنؠؠجكآكقئڪك؃ن؃كككحكآؠئكټككضڝكدندكنكجكټؠضكڪكنس؃كحنحكؠكئكټكنڪڝكؠجدكټسجكآؠضكڝكقق؃كؠآحكڝڪئك؃جسكحكجقدكآآجكض؃ضككؠزكحكټئحكڪجئكڝآسكزدقكجكئ؃جكڝجضكدجزكقنككحڝئټئك؃ضسكدجقكدننكجنآكضكددزك؃كككحنؠكئكټكسكحآقكئجنكسضآكضنڪكنك؃كككئټؠكؠدټكڝڝڝكككدكنكضټآكؠنڪكزن؃كنؠحكؠكزجټكسزڝكقكدكآكجكآكقجڪكنج؃كنجحنآؠئكټككئڝكڝحدكنكجكټؠضكڪكنض؃ك؃ححكؠكئكڪؠسكڝكؠسدكدحجكآكضكڪكزك؃كآجحكڪسئكټؠسك؃كقكدكآټجكڝكضكدجزكدؠككحكڪجئكئ؃سكڝكقكجكنكجكڝجضكدجزكزقككجؠؠكئك؃ئسكؠسقكدكنكئؠآكضكدضزككنككحكؠكضؠټكسكحسقكڝكنكجكآكسؠڪكزكجزككؠنؠكئكټكسكڝكقكئجنكسزآكضؠڪكقك؃كككئټؠكقجټككجڝككؠدكنكسجآكآ؃ڪكزك؃كؠكحكؠكزجټككجڝكڝقدكؠؠجكآكقئڪك؃ن؃كككحكآؠئكټككضڝك؃ټدكنكجكټؠضكڪكنس؃كحنحكؠكئكڪؠسكڝكؠزدك؃آجكآكضكڪكزك؃كآجحكڪزئكټؠسك؃كقكدكآټجكنزضكدجزكجكككحكټټئكؠ؃سكئڪقكئكنكجكڪڪضكضدزكججككجكؠكئكڝڪسكضنقكجټنكئؠآكضكدجزك؃زككحكؠكسكټكسكحجقكئجنكئجآنسؠڪكزكجئككؠنؠكئكټكزؠڝكقكئضنككدآكضكڪكقؠ؃كككضسؠكڝقټكسكڝكقكدكنكسجآكقسڪكزؠ؃كنكحكؠكسڪټكككڝكؠجدكؠؠجكآكقجڪكڪ؃؃كككحكټكئكټككجڝكؠجدكدقجكټؠضكڪكنئ؃كحنحكؠكئكڪؠسكڝكؠضدكجنجكآكضكڝؠزك؃كآسحككټئكټكسك؃ؠقكدكټزجكضنضكڪكزك؃كككحكڪجئك؃زسكڝؠقكحكنكجكڪڪضكحجزكججككجؠؠكئك؃جسكس؃قكدكنكضكآكضكدجزكججكككقؠكضؠټكسكحئقكنننكجكآكسؠڪكزكجضككنټؠكئكټكزؠڝكقكئسنكآنآكضكڪكقؠ؃كككضزؠكقآټكسكڝكقكدكنكسجآكقزڪكزؠ؃كنكحكؠكسڪټكئزڝكؠجدكؠؠجكآكقجڪكقد؃نككحكټكئكټككجڝكؠجدكككجكڪكضكڪكنج؃كآجحكججئكڪكسكڝكنڪدكككجكڝجضكدكزك؃كؠڪحكټزئكټؠسك؃ؠقكدكټججكآزضكڪكزكحكككحكڪجئك؃جسك؃جقنحؠنكجكڝئضكزنزك؃كككجؠؠكئك؃ضسكقنقكدكنكئؠآكضكدسزككنككحكؠكئكټكسكحجقكئسنكجؠآكسكڪكزكحڪككسڪؠكزجټكككڝكقكجڪنكآ؃آك؃ؠڪككك؃كككضجؠكسڪټكڪدڝكنكدكنكسجآكقجڪكضڪ؃ككؠضزؠكزضټكز؃ڝكقكدكنك؃حآكقجڪكنض؃ككنحكڪكئكټكقڝڝكڝددكزكجكټكضكڪككڝ؃كڝنحكټټئكڪؠسكڝكؠجدكنزجكآكضك؃كزك؃كآجحكڪجئكڪجسن؃ؠقكدكټئجكضنضكڪكزكدؠككحكڪضئكجدسكڝكقكحؠنكجكڝسضككقزك؃كككحكؠكئك؃جسكحسقكدؠنكئكآكضك؃ڝزكجكككضجؠكضؠؠكسكحجقكق؃نكجكآكزكڪقزكججككضجؠكؠقټكزؠڝكقكئئنكآنآكضكڪكقؠ؃كككضضؠكټنټكسكڝككؠدكنكسسآكؠڪڪكزك؃كنؠحكؠكززټكڝنڝكقكدكنكجكآكقجڪكنز؃ككؠحكآكئكټكقڝڝكآجدكټججكټؠضكڪكنج؃ك؃؃حكؠكئكڝكسكڝكؠجدكټججكجقضكڝؠزك؃كآئحكئنئكټكسك؃ؠڝحدكټضجكئټضكڪكزكدؠنجحكڪسئكسنسكڝكقكحؠنكجكڝزضكحآزك؃كككحكؠكئك؃جسكحزقكدؠنكئكآكضك؃ڝزكڪزككضجؠكضؠټكسكحجقكحدننجكآكزكڪكزكججككضجؠكجكټكقكڝكقكئجنكسجآكټجڪكقك؃كككئڝؠكجكټككجڝكؠكدكنكضڝآكززڪكدڪ؃كنؠحكؠكزجټكسزڝكقكدكآكزئآكقجڪكنج؃كنجحنآؠضڝټككئڝكدندكنكجكټؠضكڪكنض؃كحنحكؠكئكڪؠسكڝكؠسدكجنجكآكضكڪكزك؃كآجحكڪسئكټؠسك؃كقكدكآڝجك؃ڪضكدجزكجكككحكټڝئكس؃سكنؠقكجكنكجكڝجضك؃ڝزكقدككئكؠكئك؃جسكحجقكڝڪنكجؠڝزضكدضزكدجككحكؠكئك؃ڪسكحجقكئضنكجنآكسؠڪكزكججككسزؠكئكټكقكڝكقكئجنكسجآكؠحڪككك؃كككضجؠكزجټكټزڝكنكدكنكسجآكقجڪكؠس؃كؠكحكؠكزئټككجڝكجټدكآكجكآكقئڪكنئ؃كؠڝحكټكئكټككئڝكؠئدكقڪجكآؠقزڪكنس؃كننحكؠكئكټكجحڝكؠئدكټسجكآنضكدكزك؃كآ؃حكحدئكآؠسك؃كقكدكټ؃جكحنضك؃ټزكدؠككحكڪئئكټزسكڝكقكجكنكجكڝئضكدئزكدجكنجؠؠكئك؃ضسكقنقكدكنكئؠآكضكدسزكسدككحكؠكضؠټكسكحزقكآقنكجكآكضكڪكزكجئككضزؠكئؠټكزكڝكقكئ؃نكسكآكقئڪكقؠڪكككضئؠكؠ؃ټكسكڝكنكدقنكسئآكقئڪكڪق؃كنؠحكؠكزضټكڝنڝكقكدكؠؠجكآكقسڪك؃ن؃كككحكآؠئكټككزڝكؠڪدكنكجكټؠضكڪكنق؃كحنحكؠكئكټكسكڝكؠئدكټقجكآؠضكڝكزك؃كآ؃حكڝجئك؃ئسك؃ؠقكدكټئجكج؃ضكڪكزكحكككحكڪئئك؃ئسكسققكحؠنكجكڝضضكزنزك؃كككجؠححئك؃سسكزټقكدكنكئؠټجضكدززككنككحكؠكضؠټكسكحققكضآنكجكآكضكڪكزكجئككضقؠكئؠټكزكڝكقكئ؃نكدزآكقئڪكقؠ؃كككضئؠكضدټنسكڝكنكدكنكسئآكقئڪكسك؃كؠكحكؠكزئټككئڝك؃جدكؠكجكآكق؃ڪكسك؃كآئحكڪكئكټكك؃ڝكنزدكآئجكټؠضكڪكنئ؃ككزحكؠكئكڝكنئڝكؠئدكټئجكټجضنڝؠقڝ؃كآضحكئنئكټكسك؃ؠقكدكټسجكضنضكڪكزكدؠككحكڪزئكسنسكڝكقكدكنكجكڝئضكدززك؃ؠككجكؠكئك؃؃سكجڪقكئئنكسكآكضكد؃زكك؃ككټؠؠكسكټكسكحئقكئ؃نكؠدآكزكڪكزكجئككضئؠكآنټكسؠحزقكئسنكجټآكضكڪكزكټحككضئؠكزسټكسنڝكؠكدكنكسدآكآدڪك؃ئ؃كنكحكؠكزدټكآنڝكنټدكؠؠجكآكقئڪكزز؃كككحكټكئكټككئڝكؠئدكؠججنټؠضكڪكنض؃كحنحكؠكئكڪؠسكڝكؠسدك؃دجكآكضكڝؠزك؃كآزحكسقئكټكسكڝكقكدكټئجكڝزضكڪؠزكدكككحكڪدئك؃كسكحئقكحؠقكجكڝئضكض؃زك؃كككئكؠقئك؃ئسكحئقكققنكئؠآكضكدضزككنككحكؠكضؠټكسكحسقكنننكجكآكسؠڪكزكجزككڝزؠكئكټكزؠڝكقكئقنكآنآكضكڪكزك؃كككضئؠكزقټكسؠڝكككدكنكسدآككجڪكنئ؃كنؠحكؠكزئټكټ؃ڝكقكدكآكجكآكقئڪكنئ؃ك؃قحكآؠئكټككضڝكدندكنكجكټؠآحڪكنس؃كدټحكؠكئكڪؠزجڝكؠزدكجنجكآكضكڝؠزك؃كآقحكڝآئكټكسكڝكقكدكټئجكڝقضكڪؠزكدكككحكڪدئكؠزسكحئقكحؠنكجكڝئضكڝدزن؃كككئكؠكئك؃ئسكحئقك؃كنكضكآكضكدئزكجئككنجؠكضكټكسكحدقك؃كنكسئآكقكڪكزكجدككئزؠكڝدټكزؠڝكقكئئنكجزآكضكڪكككئئككضئؠكزئټكزجڝنكؠحڝنكسضآكڪنڪكزك؃كنؠحكؠكزسټكڝنڝكقكدكؠؠجكآكقزڪك؃ن؃كككحكؠكئكټككئڝكؠزدكنؠجكټكضكڪكند؃كټڪحكڪئئك؃كسكڝكؠددكج؃جكزؠضك؃كزك؃كآئحكڪدئكضدسكدكقكدكټئجكڝئضكآڪزك؃ؠآزحكڪسئكټآسكڝكقكدكؠضجكڝئضكدسزك؃نككجؠؠكئك؃ئسكجزقكدكنكضكآكضكدئزكجئككقحؠكسكټكسكحئقكئئنكنزآكزكڪكزكجئككضئؠكئجټكقكڝكقكئئنكسئآكضآڪككك؃كككضئؠكزئټككنڝككؠدكنكسئآكضآڪكزك؃كنكحكؠكزحټكآنڝكقندكؠؠجكآكقئڪكزز؃كككحكټكقئټككئڝكؠئدكؠججنټؠڪكڪكنض؃كئقحكؠكئكڪؠسكڝكؠسدكضقجكآكضكڝؠزك؃كآزحكسقئكټكسكڝكقكدكټئجكڝزضكڪؠزكدكككحكڪحئك؃كسكحئقكئكنكجكڝحضكټقزكزسككجؠؠكئك؃ئسكس؃قكدكنكضكآكضكدئزكجئكككقؠكضؠټكسكحضقكټضنكجكآكسؠڪكزكجسككؠنؠكئكټكزؠسحقكئزنكآنآكضكڪكقؠڪنككضقؠكټنټكسكڝكقكدكنكسئآكققڪكزؠ؃كنكحكؠكزحټكنجڝكؠئدكؠؠجكآكقئڪكڪ؃؃كككحكټكئكټككئڝكؠئدكدقجكټؠضكڪكنض؃كحنحكؠكئكڪؠسكڝكؠسدك؃ججكآكضكڝؠزك؃كآزحكئنئكټكسك؃ؠقكدكټقجكحجضكڪكزك؃كككحكڪئئك؃قسكڝؠقكحكؠقجكڝحضكآززكجئككضكسقئك؃حسكټئقكآئنكضك؃ئضكدئزكجحككندؠكسكز؃سكحئقكئئنكدڪآكضؠدززكجسككجكؠكئكټكسكآضقكئئنكسسآكضنڪكزكدټككحكؠكئنټكسكڝكقك");local m=(-43+0x9b)local l=23 local d=o;local e={}e={[((0x118/20)+-#'big hard cock')]=function()local e,i,o,n=M(S,d,d+F);d=d+N;l=(l+(m*N))%a;return(((n+l-(m)+r*(N*T))%r)*((T*K)^T))+(((o+l-(m*T)+r*(T^F))%a)*(r*a))+(((i+l-(m*F)+K)%a)*r)+((e+l-(m*N)+K)%a);end,[(-0x41+(0x1ee2/118))]=function(e,e,e)local e=M(S,d,d);d=d+y;l=(l+(m))%a;return((e+l-(m)+K)%r);end,[(-#'This is working now'+(100-0x4e))]=function()local o,e=M(S,d,d+T);l=(l+(m*T))%a;d=d+T;return(((e+l-(m)+r*(T*N))%r)*a)+((o+l-(m*T)+a*(T^F))%r);end,[(-0x3d+65)]=function(l,e,d)if d then local e=(l/T^(e-o))%T^((d-y)-(e-o)+y);return e-e%o;else local e=T^(e-y);return(l%(e+e)>=e)and o or L;end;end,[((257-0xac)/0x11)]=function()local l=e[((980/0x46)+-#"iPipeh My God")]();local d=e[(204/0xcc)]();local i=o;local n=(e[((-66+0x65)+-31)](d,y,W+N)*(T^(W*T)))+l;local l=e[(0x86-130)](d,21,31);local e=((-o)^e[(-#'Fuck nigger wank shit dipshit cunt bullshit fuckyou hoe lol'+(-0x30+((0x191-244)+-#'edp445 what are you doing to my 3 year old son')))](d,32));if(l==L)then if(n==C)then return e*L;else l=y;i=C;end;elseif(l==(r*(T^F))-y)then return(n==L)and(e*(y/C))or(e*(L/C));end;return G(e,l-((a*(N))-o))*(i+(n/(T^_)));end,[(-#"me big peepee"+(2166/0x72))]=function(n,i,i)local i;if(not n)then n=e[(98+-0x61)]();if(n==L)then return'';end;end;i=E(S,d,d+n-o);d=d+n;local e=''for d=y,#i do e=O(e,Y((M(E(i,d,d))+l)%a))l=(l+m)%r end return e;end}local function L(...)return{...},U('#',...)end local function E()local i={};local x={};local l={};local n={i,x,nil,l};local d={}local c=((-68+0x86)+-#"test")local a={[((0x2838/234)+-#'FBI is going to attack you now escape mf')]=(function(l)return not(#l==e[((0x94-136)+-#"sins daddy")]())end),[(-#[[looadstring]]+(876/0x49))]=(function(l)return e[(865/0xad)]()end),[(((0x59bb/247)+-#"187 ist die gang")-75)]=(function(l)return e[(-85+0x5b)]()end),[(387/0x81)]=(function(l)local d=e[(1164/0xc2)]()local l=''local e=1 for o=1,#d do e=(e+c)%a l=O(l,Y((M(d:sub(o,o))+e)%r))end return l end)};for e=y,e[(0x78+-119)]()do x[e-y]=E();end;local l=e[(0x56/86)]()for l=1,l do local e=e[(-#"Sub To BKProsYT"+(117+-0x64))]();local o;local e=a[e%(3612/0x54)];d[l]=e and e({});end;for n=1,e[(0x14-19)]()do local l=e[(0x14e/167)]();if(e[(-0x66+(-110+0xd8))](l,o,y)==C)then local r=e[(976/(13420/0x37))](l,T,F);local a=e[(-106+(0x4dc6/181))](l,N,T+N);local l={e[(0xa2/54)](),e[((77+-0x3a)+-#"iPipeh Is My God")](),nil,nil};local x={[((-#[[dont use it anymore]]+(355-0xe8))-0x68)]=function()l[g]=e[(327/0x6d)]();l[H]=e[(0x243/193)]();end,[(((13-0x39)+-#"Candyman was here")+0x3e)]=function()l[t]=e[(0x54-83)]();end,[(-96+0x62)]=function()l[t]=e[(-70+0x47)]()-(T^W)end,[(((0x2178/21)+-#[[Nitro Activated]])/131)]=function()l[f]=e[(-#[[edp445 what are you doing to my 3 year old son]]+(66+-0x13))]()-(T^W)l[A]=e[(-0x78+123)]();end};x[r]();if(e[(-#'Fuck nigger wank shit dipshit cunt bullshit fuckyou hoe lol'+(-0x6a+169))](a,y,o)==y)then l[h]=d[l[h]]end if(e[(0x318/198)](a,T,T)==o)then l[t]=d[l[w]]end if(e[((87-0x37)+-#"IPIPEH I WANNA FUCK WITH YOU")](a,F,F)==y)then l[I]=d[l[B]]end i[n]=l;end end;n[3]=e[(0x55-83)]();return n;end;local function S(e,C,r)local W=e[T];local m=e[F];local e=e[o];return(function(...)local a=e;local F=-y;local d={};local M={};local l=o;local Y={};local m=m;local N=L local L={...};local K=W;local W=U('#',...)-y;for e=0,W do if(e>=m)then Y[e-m]=L[e+y];else d[e]=L[e+o];end;end;local e=W-m+o local e;local m;while true do e=a[l];m=e[(-#'ez monke'+(0x60c/172))];n=(6991335)while(288-0x9d)>=m do n=-n n=(9043461)while m<=(211-0x92)do n=-n n=(4064795)while m<=(-#'free trojan'+(0x26a2/230))do n=-n n=(4983367)while m<=(104+-0x59)do n=-n n=(8546100)while(0x72-107)>=m do n=-n n=(264776)while(0x6f-108)>=m do n=-n n=(4626084)while m<=(0xc7/199)do n=-n n=(146421)while m>(0/0xe7)do n=-n local n;d[e[i]]=d[e[x]][e[P]];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[s]][e[u]]=d[e[v]];l=l+o;e=a[l];d[e[i]]=r[e[u]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[b]]=e[f];l=l+o;e=a[l];d[e[c]]=e[g];break end while(n)/((0x8d+-54))==1683 do local n;n=e[h]d[n](p(d,n+y,e[x]))l=l+o;e=a[l];d[e[i]][e[x]]=e[I];l=l+o;e=a[l];d[e[s]][e[u]]=d[e[v]];l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[c]][e[w]]=d[e[P]];break end;break;end while(n)/((295179/0xb7))==2868 do n=(8198085)while(-23+0x19)<m do n=-n local e=e[b]local a,l=N(d[e](d[e+y]))F=l+e-o local l=0;for e=e,F do l=l+o;d[e]=a[l];end;break end while 3353==(n)/((-#'test123'+(0x2eb18/78)))do local x;local n;d[e[i]]=d[e[w]][e[B]];l=l+o;e=a[l];n=e[i];x=d[e[f]];d[n+1]=x;d[n]=x[e[B]];l=l+o;e=a[l];d[e[k]]=r[e[t]];l=l+o;e=a[l];d[e[b]]=d[e[f]];l=l+o;e=a[l];n=e[c]d[n](p(d,n+y,e[g]))l=l+o;e=a[l];do return end;break end;break;end break;end while(n)/(((337317/0xe5)+-#[[mee6 what are you doing to my wife]]))==184 do n=(1382735)while(35+-0x1e)>=m do n=-n n=(2548960)while m>(-#[[FBI is going to attack you now escape mf]]+(0x92-102))do n=-n local n;d[e[s]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[k]]=d[e[g]];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];d[e[c]]=r[e[w]];l=l+o;e=a[l];d[e[c]]=d[e[u]][e[A]];l=l+o;e=a[l];n=e[i]d[n](p(d,n+y,e[t]))l=l+o;e=a[l];l=e[f];break end while 1432==(n)/((-#'Bong'+(-71+0x73f)))do d[e[i]]=(e[x]~=0);l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[v]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[I]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[I]];l=l+o;e=a[l];r[e[t]]=d[e[k]];break end;break;end while(n)/((-#'zNugget is dad'+(5747-0xb42)))==485 do n=(2180250)while m>((4784/0x5c)+-#"edp445 what are you doing to my 3 year old son")do n=-n local m;local W,C;local n;local L;d[e[h]]=r[e[x]];l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[s]]=d[e[x]][e[v]];l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[v]];l=l+o;e=a[l];L={e,d};L[T][L[y][h]]=L[T][L[o][x]]+L[y][v];l=l+o;e=a[l];d[e[h]]=r[e[t]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[h]]=d[e[f]][e[B]];l=l+o;e=a[l];d[e[i]]=d[e[t]]-e[v];l=l+o;e=a[l];n=e[c]W,C=N(d[n](p(d,n+1,e[x])))F=C+n-1 m=0;for e=n,F do m=m+o;d[e]=W[m];end;l=l+o;e=a[l];n=e[c]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[H]];l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=d[e[f]][e[v]];l=l+o;e=a[l];d[e[k]]=d[e[t]]-e[P];l=l+o;e=a[l];d[e[s]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[I]];l=l+o;e=a[l];L={e,d};L[T][L[y][i]]=L[T][L[o][f]]+L[y][v];l=l+o;e=a[l];n=e[s]W,C=N(d[n](p(d,n+1,e[x])))F=C+n-1 m=0;for e=n,F do m=m+o;d[e]=W[m];end;l=l+o;e=a[l];n=e[h]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[k]]=r[e[t]];l=l+o;e=a[l];d[e[i]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[h]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[P]];l=l+o;e=a[l];d[e[c]]=d[e[t]]-e[P];l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[I]];l=l+o;e=a[l];d[e[h]]=r[e[u]];l=l+o;e=a[l];d[e[i]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[c]]=d[e[u]]-e[P];l=l+o;e=a[l];n=e[i]W,C=N(d[n](p(d,n+1,e[x])))F=C+n-1 m=0;for e=n,F do m=m+o;d[e]=W[m];end;l=l+o;e=a[l];n=e[i]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[h]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=r[e[u]];l=l+o;e=a[l];d[e[i]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[s]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[B]];l=l+o;e=a[l];L={e,d};L[T][L[y][c]]=L[T][L[o][t]]+L[y][A];l=l+o;e=a[l];d[e[k]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[b]]=d[e[w]]-e[A];l=l+o;e=a[l];n=e[c]W,C=N(d[n](p(d,n+1,e[f])))F=C+n-1 m=0;for e=n,F do m=m+o;d[e]=W[m];end;l=l+o;e=a[l];n=e[b]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[I]];l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[v]];l=l+o;e=a[l];d[e[k]]=d[e[g]]-e[B];l=l+o;e=a[l];d[e[h]]=r[e[u]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[A]];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[s]]=d[e[g]]-e[A];l=l+o;e=a[l];n=e[s]W,C=N(d[n](p(d,n+1,e[t])))F=C+n-1 m=0;for e=n,F do m=m+o;d[e]=W[m];end;l=l+o;e=a[l];n=e[h]d[n](p(d,n+y,F))l=l+o;e=a[l];do return end;break end while 850==(n)/((-0x54+2649))do local n;d[e[b]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[b]][e[g]]=d[e[I]];l=l+o;e=a[l];d[e[h]]=r[e[u]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[H]];l=l+o;e=a[l];d[e[i]]=e[t];break end;break;end break;end break;end while(n)/((3776+-0x74))==2335 do n=(748417)while(-#[[BluntMan420 Was Here]]+(92+-0x3d))>=m do n=-n n=(10429963)while m<=((594/0x16)+-#[[iam u Furry iPipeh]])do n=-n n=(2339260)while m>((153-(17649/0x9f))+-#[[mee6 what are you doing to my wife]])do n=-n if(d[e[i]]==e[A])then l=l+y;else l=e[x];end;break end while(n)/((0x15d82/83))==2170 do d[e[i]]();break end;break;end while(n)/((0xed9+-80))==2803 do n=(4516785)while(-#[[me big peepee]]+((7666-0xf36)/164))<m do n=-n local e=e[b]d[e](d[e+y])break end while(n)/(((-#[[Sub To BKProsYT]]+(0xa8a97-345479))/0xfd))==3309 do local n;d[e[s]]=e[t];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[h]][e[g]]=d[e[B]];l=l+o;e=a[l];d[e[b]]=r[e[g]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[I]];l=l+o;e=a[l];d[e[i]][e[w]]=d[e[A]];l=l+o;e=a[l];d[e[h]][e[w]]=e[B];l=l+o;e=a[l];d[e[k]]=r[e[g]];break end;break;end break;end while 211==(n)/(((53490/(750/0x32))+-#"dont use it anymore"))do n=(3284776)while m<=(-#[[guys Please proceed to translate D to Sinhala]]+((3509000/0xf2)/0xfa))do n=-n n=(6546738)while m>((5500/0x7d)+-#[[xenny its znugget please respond]])do n=-n local r;local n;n=e[b];r=d[e[f]];d[n+1]=r;d[n]=r[e[A]];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];if(d[e[i]]~=e[A])then l=l+y;else l=e[x];end;break end while 2118==(n)/((-#"Hi skid"+((-0x2da5/205)+0xc53)))do local n;n=e[k]d[n](p(d,n+y,e[u]))l=l+o;e=a[l];d[e[s]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[I]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[B]];l=l+o;e=a[l];r[e[u]]=d[e[c]];l=l+o;e=a[l];d[e[i]][e[g]]=d[e[P]];l=l+o;e=a[l];d[e[i]]=r[e[w]];break end;break;end while(n)/((3786-0x7a2))==1793 do n=(1841064)while(0x498/84)<m do n=-n d[e[s]][e[u]]=d[e[H]];break end while 492==(n)/(((7551-(295776/0x4e))+-#[[iPipeh I Love You]]))do if(d[e[k]]==d[e[v]])then l=l+y;else l=e[u];end;break end;break;end break;end break;end break;end while(n)/((-#[[require]]+(-16+0x720)))==2767 do n=(8686200)while(828/0x24)>=m do n=-n n=(1155362)while((0x61c/(9430/0xcd))+-#'Sub To BKProsYT')>=m do n=-n n=(3264160)while(-#"looadstring"+(0x51+-53))>=m do n=-n n=(272055)while m>(-0x4f+95)do n=-n local e={d,e};e[y][e[T][i]]=e[o][e[T][P]]+e[y][e[T][t]];break end while 105==(n)/((0x14bc-2717))do local l=e[i]d[l]=d[l](p(d,l+o,e[u]))break end;break;end while 920==(n)/((-#[[iPipeh My God]]+(188733/0x35)))do n=(1194930)while(-73+0x5b)<m do n=-n r[e[w]]=d[e[b]];break end while 561==(n)/(((0x1142-2270)+-#'420Script Was Here'))do local n;n=e[b]d[n](p(d,n+y,e[x]))l=l+o;e=a[l];d[e[h]][e[f]]=e[P];l=l+o;e=a[l];d[e[i]][e[u]]=d[e[H]];l=l+o;e=a[l];d[e[s]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[i]][e[u]]=d[e[B]];l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[B]];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];d[e[s]]=e[x];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[h]][e[f]]=d[e[I]];l=l+o;e=a[l];d[e[h]]=r[e[t]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];d[e[c]]=e[g];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[c]][e[t]]=d[e[P]];l=l+o;e=a[l];d[e[i]]=r[e[w]];l=l+o;e=a[l];d[e[c]]=d[e[u]][e[A]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[c]][e[x]]=d[e[A]];l=l+o;e=a[l];d[e[c]][e[x]]=e[A];l=l+o;e=a[l];d[e[i]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[t]][e[H]];l=l+o;e=a[l];d[e[b]]=e[f];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[i]][e[x]]=d[e[I]];l=l+o;e=a[l];d[e[k]][e[x]]=e[H];l=l+o;e=a[l];d[e[h]][e[f]]=e[I];l=l+o;e=a[l];d[e[b]][e[f]]=d[e[B]];l=l+o;e=a[l];d[e[k]]=r[e[x]];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[A]];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[c]][e[w]]=d[e[I]];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];d[e[s]]=e[g];l=l+o;e=a[l];d[e[s]]=e[g];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[i]][e[w]]=d[e[I]];l=l+o;e=a[l];d[e[i]]=r[e[f]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];d[e[b]]=e[g];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[c]][e[f]]=d[e[B]];l=l+o;e=a[l];d[e[i]][e[f]]=e[v];l=l+o;e=a[l];d[e[b]][e[f]]=e[I];l=l+o;e=a[l];d[e[k]][e[u]]=d[e[B]];l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];d[e[k]]=e[x];l=l+o;e=a[l];d[e[c]]=e[g];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[c]][e[u]]=d[e[I]];l=l+o;e=a[l];d[e[s]]=r[e[u]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];d[e[i]]=e[f];break end;break;end break;end while(n)/((0x146ee/87))==1201 do n=(778800)while((-0x1f+56)+-#'Bong')>=m do n=-n n=(2791800)while m>(4060/0xcb)do n=-n if d[e[k]]then l=l+o;else l=e[u];end;break end while 1100==(n)/((0x8675a/217))do do return end;break end;break;end while(n)/((-0x54+674))==1320 do n=(250962)while(0xb00/128)<m do n=-n local n=e[h];local a={};for e=1,#M do local e=M[e];for l=0,#e do local l=e[l];local o=l[1];local e=l[2];if o==d and e>=n then a[e]=o[e];l[1]=a;end;end;end;break end while 453==(n)/(((((0x428f3/227)+-#[[iPipeh iam u Best Fan]])-0x25f)+-#'dont use it anymore'))do local r;local n;d[e[k]]=e[f];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[i]][e[x]]=d[e[B]];l=l+o;e=a[l];d[e[i]][e[w]]=e[H];l=l+o;e=a[l];d[e[k]]=d[e[f]][e[A]];l=l+o;e=a[l];n=e[c];r=d[e[u]];d[n+1]=r;d[n]=r[e[A]];break end;break;end break;end break;end while(n)/((265256/0x47))==2325 do n=(2444670)while m<=(-49+0x4c)do n=-n n=(1075355)while m<=(127-(0x5ad8/228))do n=-n n=(1612884)while((-27+0x44)+-#"911WasAnInsideJob")<m do n=-n r[e[u]]=d[e[k]];l=l+o;e=a[l];d[e[b]]={};l=l+o;e=a[l];d[e[c]]={};l=l+o;e=a[l];r[e[w]]=d[e[k]];l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];if(d[e[i]]==e[H])then l=l+y;else l=e[g];end;break end while(n)/((236320/0xa0))==1092 do local r;local n;n=e[k];r=d[e[x]];d[n+1]=r;d[n]=r[e[I]];l=l+o;e=a[l];d[e[c]]=e[g];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];if(d[e[i]]==e[I])then l=l+y;else l=e[t];end;break end;break;end while 479==(n)/((-69+0x90a))do n=(11657032)while(-#"zNugget is dad"+(0x1298/119))<m do n=-n local n;d[e[b]]=d[e[g]][e[v]];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];n=e[b]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[s]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[s]][e[u]]=d[e[v]];l=l+o;e=a[l];d[e[c]][e[x]]=e[A];l=l+o;e=a[l];d[e[k]][e[t]]=d[e[v]];l=l+o;e=a[l];d[e[k]]=r[e[w]];l=l+o;e=a[l];d[e[s]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];d[e[c]]=e[t];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[i]][e[u]]=d[e[v]];l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[i]][e[t]]=d[e[H]];l=l+o;e=a[l];d[e[h]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[h]][e[g]]=d[e[B]];l=l+o;e=a[l];d[e[i]]=r[e[w]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[i]]=d[e[g]][e[v]];l=l+o;e=a[l];d[e[c]][e[t]]=d[e[A]];l=l+o;e=a[l];d[e[h]][e[t]]=e[A];l=l+o;e=a[l];d[e[h]]=r[e[t]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[I]];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[k]][e[x]]=d[e[P]];l=l+o;e=a[l];d[e[h]][e[x]]=e[I];l=l+o;e=a[l];d[e[c]][e[u]]=e[I];l=l+o;e=a[l];d[e[h]][e[f]]=d[e[I]];l=l+o;e=a[l];d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[v]];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[b]][e[f]]=d[e[A]];l=l+o;e=a[l];d[e[k]]=r[e[t]];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[P]];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];d[e[k]]=e[u];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[c]][e[t]]=d[e[v]];l=l+o;e=a[l];d[e[h]]=r[e[w]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[k]]=e[g];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[i]][e[t]]=d[e[I]];l=l+o;e=a[l];d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[i]]=d[e[g]][e[B]];l=l+o;e=a[l];d[e[c]][e[g]]=d[e[A]];l=l+o;e=a[l];d[e[c]][e[g]]=e[v];l=l+o;e=a[l];d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[P]];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[f]))break end while 2894==(n)/(((1348710/0xa5)-0x1032))do d[e[k]]=d[e[u]]-e[I];break end;break;end break;end while(n)/((0x589-727))==3543 do n=(3070620)while m<=((0x8554/212)-132)do n=-n n=(2093063)while(-0x68+132)<m do n=-n local m;local C,W;local n;local L;d[e[h]]=r[e[w]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[b]]=d[e[f]]-e[B];l=l+o;e=a[l];d[e[c]]=r[e[t]];l=l+o;e=a[l];d[e[k]]=d[e[f]][e[H]];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[P]];l=l+o;e=a[l];L={e,d};L[T][L[y][b]]=L[T][L[o][t]]+L[y][v];l=l+o;e=a[l];n=e[b]C,W=N(d[n](p(d,n+1,e[g])))F=W+n-1 m=0;for e=n,F do m=m+o;d[e]=C[m];end;l=l+o;e=a[l];n=e[k]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[c]]=r[e[u]];l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[h]]=r[e[t]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[B]];l=l+o;e=a[l];d[e[b]]=d[e[f]]-e[v];l=l+o;e=a[l];d[e[k]]=r[e[g]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[H]];l=l+o;e=a[l];d[e[c]]=r[e[w]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[h]]=d[e[g]]-e[I];l=l+o;e=a[l];n=e[i]C,W=N(d[n](p(d,n+1,e[g])))F=W+n-1 m=0;for e=n,F do m=m+o;d[e]=C[m];end;l=l+o;e=a[l];n=e[h]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[h]]=r[e[u]];l=l+o;e=a[l];d[e[k]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[k]]=r[e[t]];l=l+o;e=a[l];d[e[k]]=d[e[t]][e[I]];l=l+o;e=a[l];L={e,d};L[T][L[y][s]]=L[T][L[o][u]]+L[y][H];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[A]];l=l+o;e=a[l];d[e[h]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[A]];l=l+o;e=a[l];n=e[b]C,W=N(d[n](p(d,n+1,e[u])))F=W+n-1 m=0;for e=n,F do m=m+o;d[e]=C[m];end;l=l+o;e=a[l];n=e[s]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[A]];l=l+o;e=a[l];d[e[c]]=r[e[t]];l=l+o;e=a[l];d[e[k]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[i]]=d[e[w]]-e[P];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[i]]=d[e[g]][e[v]];l=l+o;e=a[l];d[e[s]]=r[e[g]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[B]];l=l+o;e=a[l];n=e[k]C,W=N(d[n](p(d,n+1,e[u])))F=W+n-1 m=0;for e=n,F do m=m+o;d[e]=C[m];end;l=l+o;e=a[l];n=e[b]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[i]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[f]][e[H]];l=l+o;e=a[l];d[e[h]]=r[e[t]];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[c]]=r[e[w]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[B]];l=l+o;e=a[l];L={e,d};L[T][L[y][c]]=L[T][L[o][u]]+L[y][B];l=l+o;e=a[l];n=e[b]C,W=N(d[n](p(d,n+1,e[t])))F=W+n-1 m=0;for e=n,F do m=m+o;d[e]=C[m];end;l=l+o;e=a[l];n=e[k]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[s]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[A]];l=l+o;e=a[l];d[e[i]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[B]];l=l+o;e=a[l];d[e[h]]=r[e[t]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[I]];l=l+o;e=a[l];d[e[c]]=r[e[t]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[i]]=d[e[u]]-e[H];l=l+o;e=a[l];n=e[b]C,W=N(d[n](p(d,n+1,e[g])))F=W+n-1 m=0;for e=n,F do m=m+o;d[e]=C[m];end;l=l+o;e=a[l];n=e[b]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=r[e[t]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[v]];l=l+o;e=a[l];d[e[b]]=r[e[u]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[B]];l=l+o;e=a[l];L={e,d};L[T][L[y][b]]=L[T][L[o][t]]+L[y][H];l=l+o;e=a[l];d[e[i]]=r[e[t]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[s]]=r[e[t]];break end while 721==(n)/(((414214/0x8e)+-#[[big black sins]]))do local n;d[e[i]]=e[f];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[b]][e[w]]=d[e[P]];l=l+o;e=a[l];d[e[i]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[A]];l=l+o;e=a[l];d[e[h]][e[w]]=d[e[B]];l=l+o;e=a[l];d[e[k]][e[w]]=e[v];l=l+o;e=a[l];d[e[h]]=r[e[u]];break end;break;end while 1260==(n)/((-#"iPipeh My God"+(-0x10+2466)))do n=(3381123)while(-0x2c+74)>=m do n=-n local e=e[s]d[e]=d[e](p(d,e+o,F))break;end while(n)/((0x4fb45/143))==1481 do n=(4376905)while(0xa0-129)<m do n=-n local m;local n;d[e[b]][e[x]]=d[e[I]];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[v]];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];d[e[b]]=e[f];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[c]][e[u]]=d[e[H]];l=l+o;e=a[l];d[e[h]]=r[e[w]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[I]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[h]][e[w]]=d[e[P]];l=l+o;e=a[l];d[e[b]][e[t]]=e[B];l=l+o;e=a[l];d[e[h]]=r[e[u]];l=l+o;e=a[l];d[e[s]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[b]][e[f]]=d[e[B]];l=l+o;e=a[l];d[e[c]][e[g]]=e[H];l=l+o;e=a[l];d[e[k]][e[w]]=e[B];l=l+o;e=a[l];d[e[h]][e[w]]=d[e[I]];l=l+o;e=a[l];d[e[h]]=r[e[g]];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[A]];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[h]][e[f]]=d[e[P]];l=l+o;e=a[l];d[e[k]]=r[e[t]];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[I]];l=l+o;e=a[l];d[e[k]]=e[u];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[b]][e[t]]=d[e[H]];l=l+o;e=a[l];d[e[h]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[B]];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[c]][e[f]]=d[e[I]];l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[i]][e[g]]=d[e[P]];l=l+o;e=a[l];d[e[h]][e[u]]=e[v];l=l+o;e=a[l];d[e[i]]=r[e[t]];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];d[e[k]]=e[x];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[h]][e[t]]=d[e[I]];l=l+o;e=a[l];d[e[i]][e[f]]=e[H];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[H]];l=l+o;e=a[l];n=e[b];m=d[e[f]];d[n+1]=m;d[n]=m[e[A]];break end while(n)/((-#"Nitro Activated"+(59000/0x32)))==3757 do local r;local n;d[e[s]]=e[x];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[c]][e[t]]=d[e[P]];l=l+o;e=a[l];d[e[i]][e[t]]=e[A];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[B]];l=l+o;e=a[l];n=e[h];r=d[e[x]];d[n+1]=r;d[n]=r[e[H]];break end;break;end break;end break;end break;end break;end break;end while(n)/((0x8ff/1))==1765 do n=(2025752)while m<=(-#"sinsploit"+(207-0x96))do n=-n n=(2938572)while m<=(-#'dick cheese'+(223-0xac))do n=-n n=(2368290)while m<=(-59+0x5f)do n=-n n=(416362)while m<=(0x79-87)do n=-n n=(989443)while((-0x7a+170)+-#[[iPipeh Is Magic]])<m do n=-n local n;n=e[h]d[n](p(d,n+y,e[w]))l=l+o;e=a[l];d[e[h]][e[x]]=e[P];l=l+o;e=a[l];d[e[i]][e[u]]=d[e[v]];l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[f]][e[H]];l=l+o;e=a[l];d[e[b]]=e[f];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[h]][e[w]]=d[e[B]];break end while(n)/((1735+-0x20))==581 do local n;d[e[s]]=d[e[x]][e[B]];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[k]][e[x]]=d[e[B]];l=l+o;e=a[l];d[e[h]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[c]]=e[x];break end;break;end while(n)/((0x12644/148))==818 do n=(181152)while m>(0xc2-159)do n=-n d[e[i]]=S(K[e[g]],nil,r);break end while 444==(n)/((-#"FBI is going to attack you now escape mf"+(109760/0xf5)))do d[e[s]]=d[e[u]][e[I]];l=l+o;e=a[l];d[e[k]]=r[e[x]];l=l+o;e=a[l];d[e[s]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[i]]=d[e[f]][e[B]];l=l+o;e=a[l];if(d[e[b]]~=d[e[v]])then l=l+y;else l=e[x];end;break end;break;end break;end while(n)/((3643-0x74d))==1335 do n=(10514364)while(108-0x46)>=m do n=-n n=(173040)while m>(-34+0x47)do n=-n local n;local t;local f,m;local s;local n;d[e[k]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[H]];l=l+o;e=a[l];n=e[c];s=d[e[w]];d[n+1]=s;d[n]=s[e[I]];l=l+o;e=a[l];n=e[b]f,m=N(d[n](d[n+y]))F=m+n-o t=0;for e=n,F do t=t+o;d[e]=f[t];end;l=l+o;e=a[l];n=e[i]f={d[n](p(d,n+1,F))};t=0;for e=n,e[P]do t=t+o;d[e]=f[t];end l=l+o;e=a[l];l=e[u];break end while 2884==(n)/((0x1860/104))do local i;local n;d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[P]];l=l+o;e=a[l];d[e[c]]=d[e[x]][d[e[A]]];l=l+o;e=a[l];n=e[h];i=d[e[f]];d[n+1]=i;d[n]=i[e[I]];l=l+o;e=a[l];n=e[s]d[n](d[n+y])break end;break;end while 2786==(n)/((0xe56ce/249))do n=(1726450)while(((-#"sinsploit"+(0x4c49-9802))/0xe2)+-#"Bong")<m do n=-n d[e[h]]=d[e[f]];break end while 2150==(n)/((0x1e954/156))do local n;n=e[s]d[n](p(d,n+y,e[w]))l=l+o;e=a[l];d[e[i]][e[x]]=e[P];l=l+o;e=a[l];d[e[s]][e[g]]=d[e[I]];l=l+o;e=a[l];d[e[k]]=r[e[t]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[c]]=e[g];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[k]]=e[u];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[s]][e[f]]=d[e[B]];l=l+o;e=a[l];d[e[h]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[c]][e[g]]=d[e[A]];l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];d[e[s]]=e[x];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[i]][e[x]]=d[e[B]];l=l+o;e=a[l];d[e[h]]=r[e[t]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[A]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[v]];l=l+o;e=a[l];d[e[h]][e[w]]=d[e[B]];l=l+o;e=a[l];d[e[s]][e[g]]=e[H];l=l+o;e=a[l];d[e[c]]=r[e[t]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[v]];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];d[e[k]]=e[g];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[i]][e[f]]=d[e[B]];l=l+o;e=a[l];d[e[h]][e[f]]=e[I];l=l+o;e=a[l];d[e[k]][e[w]]=e[I];l=l+o;e=a[l];d[e[b]][e[t]]=d[e[H]];l=l+o;e=a[l];d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[H]];l=l+o;e=a[l];d[e[s]]=e[x];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[h]][e[x]]=d[e[H]];l=l+o;e=a[l];d[e[h]]=r[e[u]];l=l+o;e=a[l];d[e[s]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[k]]=e[g];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];d[e[k]]=e[g];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[h]][e[g]]=d[e[P]];l=l+o;e=a[l];d[e[h]]=r[e[u]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[A]];l=l+o;e=a[l];d[e[k]]=e[g];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[s]][e[g]]=d[e[v]];l=l+o;e=a[l];d[e[b]]=r[e[g]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[H]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[H]];l=l+o;e=a[l];d[e[c]][e[w]]=d[e[B]];l=l+o;e=a[l];d[e[k]][e[x]]=e[B];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[B]];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[k]][e[u]]=d[e[H]];l=l+o;e=a[l];d[e[h]][e[t]]=e[v];l=l+o;e=a[l];d[e[c]][e[f]]=e[B];l=l+o;e=a[l];d[e[b]][e[t]]=e[B];l=l+o;e=a[l];d[e[c]]=d[e[u]][e[v]];break end;break;end break;end break;end while(n)/((-#[[Cock and ball torture]]+(-0x56+1073)))==3042 do n=(12246710)while m<=(-#[[iam u Furry iPipeh]]+(0x22e/(486/0x36)))do n=-n n=(1360872)while(-26+0x44)>=m do n=-n n=(227626)while(0x98-111)<m do n=-n local m;local A,B;local n;d[e[k]]();l=l+o;e=a[l];d[e[h]]=C[e[x]];l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[P]];l=l+o;e=a[l];d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[s]]=d[e[w]][e[H]];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];n=e[c]A,B=N(d[n](p(d,n+1,e[t])))F=B+n-1 m=0;for e=n,F do m=m+o;d[e]=A[m];end;l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,F))l=l+o;e=a[l];d[e[i]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[H]];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];n=e[k]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[s]]=e[g];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[c]]=d[e[g]]*d[e[v]];l=l+o;e=a[l];d[e[b]][e[x]]=d[e[H]];break end while 3206==(n)/((-0x18+95))do d[e[k]]={};break end;break;end while 3688==(n)/((0x12bd0/208))do n=(2015720)while m>(0x993/57)do n=-n local a=e[s];local i=e[A];local n=a+2 local a={d[a](d[a+1],d[n])};for e=1,i do d[n+e]=a[e];end;local a=a[1]if a then d[n]=a l=e[w];else l=l+o;end;break end while 1610==(n)/((237880/0xbe))do local n;local x;local t,m;local s;local n;d[e[c]]=r[e[u]];l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[H]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[B]];l=l+o;e=a[l];n=e[i];s=d[e[f]];d[n+1]=s;d[n]=s[e[P]];l=l+o;e=a[l];n=e[h]t,m=N(d[n](d[n+y]))F=m+n-o x=0;for e=n,F do x=x+o;d[e]=t[x];end;l=l+o;e=a[l];n=e[h]t={d[n](p(d,n+1,F))};x=0;for e=n,e[B]do x=x+o;d[e]=t[x];end l=l+o;e=a[l];l=e[g];break end;break;end break;end while 3710==(n)/((6676-0xd2f))do n=(880933)while m<=(0x87-89)do n=-n n=(13243586)while(0x97e/54)<m do n=-n d[e[c]]=S(K[e[g]],nil,r);break end while(n)/((-#'dont use it anymore'+(0x1e2c-3884)))==3466 do do return d[e[k]]end break end;break;end while 821==(n)/((-0x5a+((0x4ad+-21)+-#[[iPipeh My God]])))do n=(6350460)while m>(0xca-155)do n=-n do return end;break end while 1590==(n)/(((0x1f9b-4081)+-#"iPipeh is Winner"))do local i;local n;n=e[k];i=d[e[t]];d[n+1]=i;d[n]=i[e[B]];l=l+o;e=a[l];d[e[s]]=r[e[u]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[v]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[H]];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];if not d[e[b]]then l=l+y;else l=e[x];end;break end;break;end break;end break;end break;end while(n)/((1527-0x323))==2798 do n=(1443744)while m<=(0xb9-(284-0x9b))do n=-n n=(2163739)while((-68+0x87)+-#[[Sub To BKProsYT]])>=m do n=-n n=(2438968)while(0xcf-((4080/0x18)+-#"ILoveBlowJobs"))>=m do n=-n n=(7630824)while((0x1323/69)+-#"IPIPEH ILOVE YOU AAAAA")<m do n=-n local i;local k,w;local h;local n;d[e[b]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];n=e[c];h=d[e[t]];d[n+1]=h;d[n]=h[e[A]];l=l+o;e=a[l];d[e[s]]=e[x];l=l+o;e=a[l];n=e[s]k,w=N(d[n](p(d,n+1,e[g])))F=w+n-1 i=0;for e=n,F do i=i+o;d[e]=k[i];end;l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,F))l=l+o;e=a[l];d[e[b]]();l=l+o;e=a[l];do return end;break end while(n)/((-59+0x811))==3804 do d[e[k]]=d[e[x]][e[A]];l=l+o;e=a[l];d[e[i]]=r[e[t]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[B]];l=l+o;e=a[l];d[e[c]]=d[e[u]][e[P]];l=l+o;e=a[l];if(d[e[k]]==d[e[P]])then l=l+y;else l=e[w];end;break end;break;end while(n)/(((44663/0x3b)+-78))==3592 do n=(33912)while((0x2b50/168)+-#[[iPipeh Is Magic]])<m do n=-n local n;d[e[s]]=e[w];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[i]][e[f]]=d[e[v]];l=l+o;e=a[l];d[e[b]]=r[e[u]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[H]];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[i]][e[t]]=d[e[v]];l=l+o;e=a[l];d[e[k]][e[u]]=e[H];l=l+o;e=a[l];d[e[c]]=r[e[g]];break end while(n)/(((-0x39+1018)+-#'I like gargling cum'))==36 do local m;local n;n=e[i]d[n](p(d,n+y,e[u]))l=l+o;e=a[l];d[e[k]][e[g]]=e[H];l=l+o;e=a[l];d[e[c]][e[t]]=d[e[v]];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[v]];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[k]][e[f]]=d[e[I]];l=l+o;e=a[l];d[e[h]]=r[e[x]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[v]];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[i]][e[f]]=d[e[H]];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[h]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[b]]=e[g];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];d[e[c]]=e[t];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[b]][e[x]]=d[e[P]];l=l+o;e=a[l];d[e[k]][e[u]]=e[B];l=l+o;e=a[l];d[e[i]][e[f]]=e[H];l=l+o;e=a[l];d[e[s]][e[f]]=d[e[I]];l=l+o;e=a[l];d[e[s]]=r[e[g]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[I]];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];d[e[s]]=e[x];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[i]][e[x]]=d[e[v]];l=l+o;e=a[l];d[e[h]]=r[e[w]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[A]];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];d[e[c]]=e[g];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[i]][e[x]]=d[e[H]];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[s]][e[t]]=d[e[H]];l=l+o;e=a[l];d[e[k]]=r[e[u]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[A]];l=l+o;e=a[l];d[e[c]][e[f]]=d[e[P]];l=l+o;e=a[l];d[e[s]][e[w]]=e[B];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[A]];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[k]][e[t]]=d[e[A]];l=l+o;e=a[l];d[e[c]][e[w]]=e[v];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[P]];l=l+o;e=a[l];n=e[b];m=d[e[u]];d[n+1]=m;d[n]=m[e[H]];break end;break;end break;end while 2423==(n)/((0x75f-994))do n=(7610760)while(0x6c0/32)>=m do n=-n n=(315216)while(0xce-153)<m do n=-n for e=e[h],e[w]do d[e]=nil;end;break end while(n)/((0x77a0/58))==597 do local c;local n;n=e[b]d[n](p(d,n+y,e[f]))l=l+o;e=a[l];d[e[i]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[P]];l=l+o;e=a[l];n=e[s];c=d[e[f]];d[n+1]=c;d[n]=c[e[P]];break end;break;end while(n)/((7025-0xdd9))==2187 do n=(4260260)while m>(0xdc/4)do n=-n d[e[s]]=#d[e[w]];break end while(n)/((0xf63+-94))==1108 do local n;local c;local k,g;local w;local n;d[e[i]]=r[e[u]];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[P]];l=l+o;e=a[l];d[e[i]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[B]];l=l+o;e=a[l];n=e[h];w=d[e[f]];d[n+1]=w;d[n]=w[e[I]];l=l+o;e=a[l];n=e[b]k,g=N(d[n](d[n+y]))F=g+n-o c=0;for e=n,F do c=c+o;d[e]=k[c];end;l=l+o;e=a[l];n=e[b]k={d[n](p(d,n+1,F))};c=0;for e=n,e[I]do c=c+o;d[e]=k[c];end l=l+o;e=a[l];l=e[t];break end;break;end break;end break;end while(n)/((-0x70+544))==3342 do n=(13922307)while m<=(4380/0x49)do n=-n n=(2872314)while(-0x77+177)>=m do n=-n n=(11582970)while m>(232-0xaf)do n=-n local n;d[e[k]]=d[e[x]][e[B]];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[i]][e[w]]=d[e[H]];l=l+o;e=a[l];d[e[b]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[H]];l=l+o;e=a[l];d[e[b]]=e[f];break end while(n)/((0xba0+-73))==3990 do local L;local C,W;local n;local m;r[e[w]]=d[e[s]];l=l+o;e=a[l];d[e[h]]=r[e[x]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[P]];l=l+o;e=a[l];r[e[x]]=d[e[s]];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[h]]=r[e[g]];l=l+o;e=a[l];d[e[h]]=d[e[g]][e[I]];l=l+o;e=a[l];m={e,d};m[T][m[y][c]]=m[T][m[o][u]]+m[y][B];l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[H]];l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];d[e[i]]=d[e[g]][e[A]];l=l+o;e=a[l];n=e[i]C,W=N(d[n](p(d,n+1,e[t])))F=W+n-1 L=0;for e=n,F do L=L+o;d[e]=C[L];end;l=l+o;e=a[l];n=e[b]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[h]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[k]]=r[e[g]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[H]];l=l+o;e=a[l];d[e[h]]=d[e[t]]-e[P];l=l+o;e=a[l];d[e[b]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[k]]=r[e[t]];l=l+o;e=a[l];d[e[h]]=d[e[f]][e[A]];l=l+o;e=a[l];n=e[s]C,W=N(d[n](p(d,n+1,e[g])))F=W+n-1 L=0;for e=n,F do L=L+o;d[e]=C[L];end;l=l+o;e=a[l];n=e[b]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[k]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[f]][e[v]];l=l+o;e=a[l];d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[v]];l=l+o;e=a[l];d[e[i]]=r[e[u]];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[h]]=r[e[f]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[I]];l=l+o;e=a[l];m={e,d};m[T][m[y][i]]=m[T][m[o][g]]+m[y][A];l=l+o;e=a[l];n=e[k]C,W=N(d[n](p(d,n+1,e[g])))F=W+n-1 L=0;for e=n,F do L=L+o;d[e]=C[L];end;l=l+o;e=a[l];n=e[b]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[i]]=r[e[u]];l=l+o;e=a[l];d[e[k]]=r[e[u]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[I]];l=l+o;e=a[l];d[e[k]]=r[e[u]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[i]]=r[e[u]];l=l+o;e=a[l];d[e[b]]=d[e[g]][e[B]];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[b]]=d[e[x]]-e[I];l=l+o;e=a[l];n=e[c]C,W=N(d[n](p(d,n+1,e[f])))F=W+n-1 L=0;for e=n,F do L=L+o;d[e]=C[L];end;l=l+o;e=a[l];n=e[b]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[b]]=r[e[g]];l=l+o;e=a[l];d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[k]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[c]]=r[e[t]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[B]];l=l+o;e=a[l];m={e,d};m[T][m[y][c]]=m[T][m[o][g]]+m[y][A];l=l+o;e=a[l];d[e[h]]=r[e[w]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[b]]=r[e[t]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[A]];l=l+o;e=a[l];m={e,d};m[T][m[y][c]]=m[T][m[o][t]]+m[y][v];l=l+o;e=a[l];n=e[b]C,W=N(d[n](p(d,n+1,e[t])))F=W+n-1 L=0;for e=n,F do L=L+o;d[e]=C[L];end;l=l+o;e=a[l];n=e[c]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=d[e[g]][e[I]];l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[P]];l=l+o;e=a[l];m={e,d};m[T][m[y][c]]=m[T][m[o][f]]+m[y][P];l=l+o;e=a[l];d[e[c]]=r[e[u]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[H]];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[k]]=d[e[f]]-e[H];l=l+o;e=a[l];n=e[k]C,W=N(d[n](p(d,n+1,e[w])))F=W+n-1 L=0;for e=n,F do L=L+o;d[e]=C[L];end;l=l+o;e=a[l];n=e[s]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=r[e[u]];break end;break;end while 2322==(n)/((2495-0x4ea))do n=(3698631)while(0x29f2/182)<m do n=-n d[e[h]]=d[e[x]]*d[e[P]];break end while(n)/((0x2b332/154))==3219 do d[e[b]]=d[e[u]][e[A]];break end;break;end break;end while(n)/((-40+0xf4d))==3591 do n=(847000)while(-#[[Rivers Cuomo]]+(0xc7+-125))>=m do n=-n n=(975744)while(-99+0xa0)<m do n=-n local n;d[e[h]]=d[e[w]][e[H]];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[c]]=e[g];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[s]][e[x]]=d[e[P]];l=l+o;e=a[l];d[e[h]]=r[e[t]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[I]];l=l+o;e=a[l];d[e[h]]=e[w];break end while 484==(n)/((0x831+-81))do local n;local i;local x,P;local m;local n;d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[s]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[A]];l=l+o;e=a[l];n=e[h];m=d[e[f]];d[n+1]=m;d[n]=m[e[B]];l=l+o;e=a[l];n=e[k]x,P=N(d[n](d[n+y]))F=P+n-o i=0;for e=n,F do i=i+o;d[e]=x[i];end;l=l+o;e=a[l];n=e[b]x={d[n](p(d,n+1,F))};i=0;for e=n,e[A]do i=i+o;d[e]=x[i];end l=l+o;e=a[l];l=e[u];break end;break;end while(n)/((0x1b9+-56))==2200 do n=(2997702)while m<=(4095/0x41)do n=-n local r;local n;d[e[c]]=e[w];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[s]][e[x]]=d[e[B]];l=l+o;e=a[l];d[e[s]][e[t]]=e[H];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[B]];l=l+o;e=a[l];n=e[i];r=d[e[u]];d[n+1]=r;d[n]=r[e[P]];break;end while 1291==(n)/((0x129a-2440))do n=(1087956)while(-#[[me big peepee]]+(-103+(-#'Two trucks having sex'+(0x109+-64))))<m do n=-n local n;d[e[h]]=e[f];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[i]][e[w]]=d[e[I]];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[A]];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[g]))break end while(n)/((-0x67+1389))==846 do local n;d[e[s]]=d[e[t]][e[v]];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];d[e[b]]=e[f];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[s]][e[g]]=d[e[B]];l=l+o;e=a[l];d[e[s]]=r[e[u]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[H]];l=l+o;e=a[l];d[e[s]]=e[g];break end;break;end break;end break;end break;end break;end break;end break;end while 3717==(n)/((-124+0x9fd))do n=(796848)while m<=(-105+0xcb)do n=-n n=(4050522)while m<=((0x130-195)+-#'IPIPEH I WANNA FUCK WITH YOU')do n=-n n=(218226)while m<=(-0x34+125)do n=-n n=(4214721)while m<=(188-0x77)do n=-n n=(1854280)while m<=(-23+0x5a)do n=-n n=(15718200)while m>(0xb3+-113)do n=-n d[e[i]]=d[e[w]][d[e[H]]];break end while 4020==(n)/((7907-0xf9d))do local n;d[e[c]]=e[f];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[k]][e[u]]=d[e[I]];l=l+o;e=a[l];d[e[b]]=r[e[u]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[i]]=d[e[w]][e[A]];l=l+o;e=a[l];d[e[b]][e[f]]=d[e[P]];l=l+o;e=a[l];d[e[s]][e[f]]=e[B];l=l+o;e=a[l];d[e[c]]=r[e[x]];break end;break;end while(n)/(((871+-0x55)+-#'black mess more like white mesa'))==2456 do n=(2859293)while m>((3660/0x14)-0x73)do n=-n local l=e[h]d[l]=d[l](p(d,l+o,e[f]))break end while(n)/((-#'tonka'+(0x31b54/141)))==1987 do d[e[i]]=r[e[g]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[I]];l=l+o;e=a[l];d[e[k]]=d[e[t]][e[v]];l=l+o;e=a[l];d[e[i]][e[t]]=d[e[P]];l=l+o;e=a[l];d[e[k]][e[x]]=e[v];l=l+o;e=a[l];d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[b]]=d[e[g]][e[I]];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[k]]=e[u];break end;break;end break;end while(n)/((0xbad-1552))==2933 do n=(1136000)while(0x105-190)>=m do n=-n n=(2385192)while(9380/0x86)<m do n=-n local n;d[e[k]]=e[g];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[c]][e[t]]=d[e[P]];l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[i]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[h]][e[w]]=d[e[B]];l=l+o;e=a[l];d[e[k]][e[u]]=e[I];l=l+o;e=a[l];d[e[i]]=r[e[x]];break end while 3427==(n)/(((1489-0x304)+-#[[iPipeh iam u Best Fan]]))do local o=e[s];local a=d[o]local n=d[o+2];if(n>0)then if(a>d[o+1])then l=e[f];else d[o+3]=a;end elseif(a<d[o+1])then l=e[g];else d[o+3]=a;end break end;break;end while(n)/(((329+-0x18)+-#[[notbelugafan was here]]))==4000 do n=(3317960)while(0x25b0/(0xf2+-108))<m do n=-n local r;local n;d[e[c]]=e[w];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[h]][e[t]]=d[e[H]];l=l+o;e=a[l];d[e[i]][e[t]]=e[P];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[A]];l=l+o;e=a[l];n=e[k];r=d[e[t]];d[n+1]=r;d[n]=r[e[A]];break end while(n)/((-#'iPipeh My God'+(931592/0xf4)))==872 do local o=e[k];local a=d[o]local n=d[o+2];if(n>0)then if(a>d[o+1])then l=e[g];else d[o+3]=a;end elseif(a<d[o+1])then l=e[t];else d[o+3]=a;end break end;break;end break;end break;end while 983==(n)/(((7776/0x20)+-#"Two trucks having sex"))do n=(3648720)while(193-0x74)>=m do n=-n n=(5673324)while(-#"big black sins"+(0x79+-32))>=m do n=-n n=(2102844)while m>(0x1b2c/94)do n=-n d[e[c]][e[x]]=e[P];break end while(n)/((0x22914/108))==1604 do d[e[c]]=r[e[u]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[A]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[h]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[H]];l=l+o;e=a[l];if not d[e[i]]then l=l+y;else l=e[w];end;break end;break;end while 2004==(n)/((0xb55+-70))do n=(11406300)while((0x9d+(-0x4608/249))+-#[[sinsploit]])<m do n=-n local e={e,d};e[T][e[y][b]]=e[T][e[o][x]]+e[y][I];break end while(n)/((-#"Dick"+(694144/0xb0)))==2895 do local n;d[e[k]]=d[e[x]][e[P]];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[h]][e[t]]=d[e[I]];l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];d[e[i]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[b]]=e[t];break end;break;end break;end while(n)/((2264-0x488))==3305 do n=(4567602)while m<=(212-0x85)do n=-n n=(4885370)while(-#[[ez monke]]+(0x12a-212))<m do n=-n local l=e[i]d[l](p(d,l+y,e[g]))break end while 3455==(n)/(((0x5f3+-92)+-#'iPipeh I Love You'))do if(d[e[b]]~=e[I])then l=l+y;else l=e[w];end;break end;break;end while(n)/(((3859-0x7ab)+-#[[Hi skid]]))==2418 do n=(4983870)while m>((1740/0x14)+-#"test123")do n=-n local r;local n;d[e[c]]=e[u];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[h]][e[u]]=d[e[B]];l=l+o;e=a[l];d[e[i]][e[u]]=e[P];l=l+o;e=a[l];d[e[c]][e[f]]=e[H];l=l+o;e=a[l];d[e[b]][e[f]]=e[I];l=l+o;e=a[l];d[e[i]]=d[e[g]][e[B]];l=l+o;e=a[l];n=e[i];r=d[e[g]];d[n+1]=r;d[n]=r[e[B]];break end while 1426==(n)/((3534+-0x27))do local r;local n;d[e[h]]=e[g];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[k]][e[x]]=d[e[A]];l=l+o;e=a[l];d[e[b]][e[x]]=e[B];l=l+o;e=a[l];d[e[h]][e[u]]=e[v];l=l+o;e=a[l];d[e[c]][e[f]]=e[I];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[A]];l=l+o;e=a[l];n=e[k];r=d[e[w]];d[n+1]=r;d[n]=r[e[I]];break end;break;end break;end break;end break;end while 2142==(n)/((-#[[me big peepee]]+(59024/0x1f)))do n=(13577289)while m<=(0xd1+-120)do n=-n n=(5934375)while((0xf1b8/238)-0xaf)>=m do n=-n n=(1263626)while m<=(0xc7-(-#'require'+(0xf8+-125)))do n=-n n=(11337277)while m>(276-0xc2)do n=-n local s;local h;local w;local n;d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[A]];l=l+o;e=a[l];n=e[b];w=d[e[g]];d[n+1]=w;d[n]=w[e[P]];l=l+o;e=a[l];d[e[i]]=d[e[x]];l=l+o;e=a[l];d[e[b]]=d[e[g]];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];n=e[b];w=d[e[t]];d[n+1]=w;d[n]=w[e[P]];l=l+o;e=a[l];n=e[k]d[n]=d[n](d[n+y])l=l+o;e=a[l];h={d,e};h[y][h[T][k]]=h[o][h[T][A]]+h[y][h[T][u]];l=l+o;e=a[l];d[e[b]]=d[e[x]]%e[A];l=l+o;e=a[l];n=e[c]d[n]=d[n](d[n+y])l=l+o;e=a[l];w=e[f];s=d[w]for e=w+1,e[P]do s=s..d[e];end;d[e[k]]=s;l=l+o;e=a[l];h={d,e};h[y][h[T][c]]=h[o][h[T][H]]+h[y][h[T][x]];l=l+o;e=a[l];d[e[k]]=d[e[t]]%e[B];break end while(n)/(((0xb4fc6-370682)/0x7c))==3793 do local n;d[e[c]]=e[f];l=l+o;e=a[l];d[e[s]]=e[x];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[h]][e[w]]=d[e[B]];l=l+o;e=a[l];d[e[k]]=r[e[w]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[H]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[B]];l=l+o;e=a[l];d[e[b]][e[x]]=d[e[A]];l=l+o;e=a[l];d[e[c]][e[t]]=e[P];l=l+o;e=a[l];d[e[c]]=r[e[f]];break end;break;end while(n)/((-0x2e+3452))==371 do n=(2981325)while m>(0x10b-183)do n=-n C[e[t]]=d[e[i]];break end while(n)/(((-0x5d+1679)+-#"iPipeh iam u Best Fan"))==1905 do local n;d[e[b]]=e[u];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[i]][e[f]]=d[e[v]];l=l+o;e=a[l];d[e[h]]=r[e[w]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[i]][e[w]]=d[e[v]];l=l+o;e=a[l];d[e[c]][e[x]]=e[B];l=l+o;e=a[l];d[e[i]]=r[e[g]];break end;break;end break;end while(n)/(((429552/0xe4)+-#[[pinkerton]]))==3165 do n=(539308)while(-124+0xd3)>=m do n=-n n=(822720)while m>(-98+0xb8)do n=-n local n;d[e[c]]=d[e[g]][e[I]];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];d[e[k]]=e[u];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[k]][e[w]]=d[e[A]];l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[b]]=e[f];break end while 1714==(n)/((0x1b120/231))do local e=e[h]d[e]=d[e](p(d,e+o,F))break end;break;end while 1442==(n)/(((0x339-430)+-#'Never gonna give u up'))do n=(1810068)while(-118+0xce)<m do n=-n d[e[b]]=d[e[u]][e[I]];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[H]];l=l+o;e=a[l];d[e[s]]=d[e[w]][e[v]];l=l+o;e=a[l];if(d[e[i]]~=d[e[A]])then l=l+y;else l=e[t];end;break end while 1132==(n)/(((228655/0x8b)+-#"edp445 what are you doing to my 3 year old son"))do d[e[s]][d[e[t]]]=d[e[A]];break end;break;end break;end break;end while(n)/((-#[[deobfuscated]]+(3824+-0x53)))==3641 do n=(2469536)while m<=(((0x209-290)-0x7f)+-#"Little kids")do n=-n n=(954600)while m<=((0x1ea093/161)/137)do n=-n n=(3216586)while((0x239-303)-0xb0)<m do n=-n local n;n=e[i]d[n](p(d,n+y,e[f]))l=l+o;e=a[l];d[e[c]][e[w]]=e[P];l=l+o;e=a[l];d[e[k]][e[g]]=d[e[H]];l=l+o;e=a[l];d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[s]][e[w]]=d[e[B]];break end while(n)/(((0xe94-1926)+-#'Hard Sex with iPipeh'))==1801 do local n;n=e[h]d[n](p(d,n+y,e[u]))l=l+o;e=a[l];d[e[s]][e[x]]=e[H];l=l+o;e=a[l];d[e[b]][e[g]]=d[e[H]];l=l+o;e=a[l];d[e[h]]=r[e[f]];l=l+o;e=a[l];d[e[i]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[k]][e[f]]=d[e[H]];l=l+o;e=a[l];d[e[h]]=r[e[u]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[B]];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];d[e[k]]=e[u];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[b]][e[g]]=d[e[v]];l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[g]][e[B]];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[b]]=e[f];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[s]][e[t]]=d[e[B]];l=l+o;e=a[l];d[e[i]][e[w]]=e[A];l=l+o;e=a[l];d[e[h]][e[t]]=e[A];l=l+o;e=a[l];d[e[b]][e[x]]=d[e[H]];l=l+o;e=a[l];d[e[s]]=r[e[u]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[b]][e[g]]=d[e[v]];l=l+o;e=a[l];d[e[b]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[s]]=e[x];l=l+o;e=a[l];d[e[k]]=e[x];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[b]][e[t]]=d[e[P]];l=l+o;e=a[l];d[e[h]]=r[e[f]];l=l+o;e=a[l];d[e[s]]=d[e[w]][e[H]];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[s]]=e[x];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[h]][e[x]]=d[e[H]];l=l+o;e=a[l];d[e[h]]=r[e[f]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[H]];l=l+o;e=a[l];d[e[h]][e[u]]=d[e[P]];l=l+o;e=a[l];d[e[s]][e[g]]=e[P];l=l+o;e=a[l];d[e[k]]=r[e[u]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[B]];l=l+o;e=a[l];d[e[b]]=e[g];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[h]][e[t]]=d[e[H]];l=l+o;e=a[l];d[e[i]][e[x]]=e[I];l=l+o;e=a[l];d[e[k]][e[f]]=e[H];l=l+o;e=a[l];d[e[h]][e[t]]=d[e[v]];l=l+o;e=a[l];d[e[k]]=r[e[t]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[I]];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];d[e[s]]=e[g];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[s]][e[g]]=d[e[I]];l=l+o;e=a[l];d[e[c]]=r[e[t]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[k]]=e[x];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];d[e[i]]=e[u];break end;break;end while(n)/((0x2c6+-65))==1480 do n=(194394)while((25217/0xa7)+-#'Fuck nigger wank shit dipshit cunt bullshit fuckyou hoe lol')<m do n=-n local n;n=e[h]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[s]][e[t]]=d[e[v]];l=l+o;e=a[l];d[e[c]]=r[e[t]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[i]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[b]][e[x]]=d[e[I]];l=l+o;e=a[l];d[e[h]][e[u]]=e[A];l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[v]];l=l+o;e=a[l];d[e[k]]=e[u];break end while 537==(n)/((0xec26/(13527/0x51)))do local n;d[e[c]]=e[t];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[i]][e[f]]=d[e[H]];l=l+o;e=a[l];d[e[b]]=r[e[t]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[v]];l=l+o;e=a[l];d[e[i]][e[x]]=d[e[P]];l=l+o;e=a[l];d[e[b]][e[x]]=e[H];l=l+o;e=a[l];d[e[h]]=r[e[t]];break end;break;end break;end while(n)/((0x9d70/44))==2696 do n=(3458250)while m<=((0x4413/157)+-#'iPipeh is Winner')do n=-n n=(380295)while m>((-0x2d+156)+-#[[Candyman was here]])do n=-n local n;n=e[b]d[n](p(d,n+y,e[x]))l=l+o;e=a[l];d[e[b]][e[w]]=e[P];l=l+o;e=a[l];d[e[c]][e[u]]=d[e[v]];l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[I]];l=l+o;e=a[l];d[e[k]]=e[x];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[s]][e[f]]=d[e[v]];break end while 939==(n)/((-#[[187 ist die gang]]+(0x5a73/55)))do d[e[k]]=(e[x]~=0);break end;break;end while(n)/((0x9a1+((-0x45+10)+-#"Never gonna give u up")))==1450 do n=(2256307)while(-#[[This is working now]]+(-0x38+171))>=m do n=-n local n;local h;local b,u;local w;local n;d[e[i]]=r[e[f]];l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];d[e[s]]=d[e[x]][e[v]];l=l+o;e=a[l];n=e[c];w=d[e[f]];d[n+1]=w;d[n]=w[e[H]];l=l+o;e=a[l];n=e[k]b,u=N(d[n](d[n+y]))F=u+n-o h=0;for e=n,F do h=h+o;d[e]=b[h];end;l=l+o;e=a[l];n=e[s]b={d[n](p(d,n+1,F))};h=0;for e=n,e[v]do h=h+o;d[e]=b[h];end l=l+o;e=a[l];l=e[t];break;end while 2831==(n)/((1625-0x33c))do n=(8565625)while(223-0x7e)<m do n=-n local n;d[e[i]]=e[f];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[c]][e[g]]=d[e[A]];l=l+o;e=a[l];d[e[i]]=r[e[w]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[k]][e[f]]=d[e[v]];l=l+o;e=a[l];d[e[b]][e[w]]=e[I];l=l+o;e=a[l];d[e[c]]=r[e[t]];break end while(n)/((6288-0xc5b))==2741 do local i;local n;d[e[k]]();l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[v]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[I]];l=l+o;e=a[l];n=e[s];i=d[e[f]];d[n+1]=i;d[n]=i[e[v]];l=l+o;e=a[l];d[e[k]]=C[e[x]];l=l+o;e=a[l];n=e[s]d[n](p(d,n+y,e[g]))break end;break;end break;end break;end break;end break;end break;end while(n)/((((72829/0x1)+-#[[FBI is going to attack you now escape mf]])/19))==208 do n=(9858000)while m<=(298-0xb8)do n=-n n=(1403129)while(0x2aa6/103)>=m do n=-n n=(557280)while m<=(0x2970/104)do n=-n n=(166260)while m<=((28024/0xf8)+-#'big hard cock')do n=-n n=(9948631)while m>(-0x53+(-0x7f+309))do n=-n local e=e[c]d[e](p(d,e+y,F))break end while(n)/(((14699-0x1cf4)-0xe54))==2749 do local r;local n;d[e[i]]=d[e[t]][e[H]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[b]]=d[e[g]][e[B]];l=l+o;e=a[l];n=e[c];r=d[e[f]];d[n+1]=r;d[n]=r[e[v]];l=l+o;e=a[l];d[e[s]]=C[e[w]];l=l+o;e=a[l];n=e[b]d[n](p(d,n+y,e[u]))break end;break;end while(n)/((215-0x93))==2445 do n=(3232375)while(0xd0+-107)<m do n=-n if(d[e[s]]==e[v])then l=l+y;else l=e[w];end;break end while(n)/(((2810-0x59d)+-#'Rivers Cuomo'))==2375 do local i;local n;d[e[k]]=e[u];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[c]][e[f]]=d[e[I]];l=l+o;e=a[l];d[e[s]][e[f]]=e[A];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[v]];l=l+o;e=a[l];n=e[k];i=d[e[x]];d[n+1]=i;d[n]=i[e[A]];break end;break;end break;end while(n)/((6559-0xcf7))==172 do n=(5269320)while(0x123-187)>=m do n=-n n=(3600872)while m>(0x148-225)do n=-n local m;local f;local h;local n;n=e[s];h=d[e[w]];d[n+1]=h;d[n]=h[e[v]];l=l+o;e=a[l];n=e[s]d[n](d[n+y])l=l+o;e=a[l];d[e[i]]=C[e[u]];l=l+o;e=a[l];n=e[b];h=d[e[w]];d[n+1]=h;d[n]=h[e[H]];l=l+o;e=a[l];d[e[k]]=r[e[g]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[H]];l=l+o;e=a[l];n=e[b]d[n](p(d,n+y,e[g]))l=l+o;e=a[l];d[e[c]]=e[g];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];d[e[k]]=e[x];l=l+o;e=a[l];n=e[s];f=d[n]m=d[n+2];if(m>0)then if(f>d[n+1])then l=e[w];else d[n+3]=f;end elseif(f<d[n+1])then l=e[x];else d[n+3]=f;end break end while(n)/((((1932592-0xebea4)+-#'Dick')/0xf5))==913 do local n;d[e[i]]=d[e[g]][e[v]];l=l+o;e=a[l];d[e[c]]=e[g];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[s]][e[f]]=d[e[B]];l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[s]]=e[g];break end;break;end while(n)/((-75+0xbd3))==1785 do n=(1367856)while(0x5622/210)<m do n=-n local n;d[e[h]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[c]]=e[t];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[s]][e[x]]=d[e[A]];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[i]]=e[u];break end while 1062==(n)/(((0xa9f-1412)+-#"dont use it anymore"))do d[e[b]]=e[x];break end;break;end break;end break;end while(n)/((0x734-937))==1547 do n=(6892974)while(15070/0x89)>=m do n=-n n=(2780232)while((165+(-0x21f6/189))+-#[[Little kids]])>=m do n=-n n=(16258086)while m>((-95+0xdc)+-#'CockAndBallTorture')do n=-n local r;local n;d[e[s]]=e[g];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[h]][e[w]]=d[e[I]];l=l+o;e=a[l];d[e[i]][e[g]]=e[B];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[B]];l=l+o;e=a[l];n=e[b];r=d[e[f]];d[n+1]=r;d[n]=r[e[v]];break end while 3978==(n)/((4211+-0x7c))do local o=e[k];local l=d[e[t]];d[o+1]=l;d[o]=l[e[v]];break end;break;end while(n)/((-85+0x69d))==1729 do n=(4514265)while m>(146+-0x25)do n=-n local n;d[e[s]]=e[x];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[h]][e[u]]=d[e[A]];l=l+o;e=a[l];d[e[h]]=r[e[x]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[v]];l=l+o;e=a[l];d[e[i]][e[w]]=d[e[v]];l=l+o;e=a[l];d[e[s]][e[x]]=e[P];l=l+o;e=a[l];d[e[k]]=r[e[g]];break end while 1785==(n)/((-67+0xa24))do local n;d[e[b]]=d[e[u]][e[I]];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];d[e[k]]=e[g];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[k]][e[f]]=d[e[v]];l=l+o;e=a[l];d[e[c]]=r[e[t]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[A]];l=l+o;e=a[l];d[e[i]]=e[g];break end;break;end break;end while(n)/((-#"pinkerton"+((-#"iPipeh I Love You"+(781909+-0x50))/254)))==2246 do n=(3454296)while(0x6510/231)>=m do n=-n n=(393295)while(9102/0x52)<m do n=-n local b;local n;d[e[c]]=r[e[x]];l=l+o;e=a[l];n=e[i];b=d[e[f]];d[n+1]=b;d[n]=b[e[I]];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[h]]=d[e[w]][e[I]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[I]];l=l+o;e=a[l];n=e[s];b=d[e[f]];d[n+1]=b;d[n]=b[e[B]];l=l+o;e=a[l];d[e[h]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=d[e[u]];l=l+o;e=a[l];n=e[s]d[n](p(d,n+y,e[x]))l=l+o;e=a[l];do return end;break end while 661==(n)/((85680/0x90))do local n;n=e[s]d[n](p(d,n+y,e[x]))l=l+o;e=a[l];d[e[i]][e[x]]=e[v];l=l+o;e=a[l];d[e[k]][e[u]]=d[e[v]];l=l+o;e=a[l];d[e[h]]=r[e[u]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[v]];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[s]][e[g]]=d[e[P]];break end;break;end while 3912==(n)/((0x15206/98))do n=(1600823)while(-0x28+153)<m do n=-n local m;local n;d[e[h]]=d[e[u]][e[A]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[I]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[B]];l=l+o;e=a[l];r[e[w]]=d[e[b]];l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];n=e[i];m=d[e[t]];d[n+1]=m;d[n]=m[e[I]];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];n=e[b]d[n](p(d,n+y,e[f]))l=l+o;e=a[l];for e=e[s],e[w]do d[e]=nil;end;l=l+o;e=a[l];d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[B]];l=l+o;e=a[l];d[e[i]]=d[e[f]][e[P]];l=l+o;e=a[l];n=e[i];m=d[e[g]];d[n+1]=m;d[n]=m[e[v]];l=l+o;e=a[l];n=e[k]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[b]]=d[e[x]][e[H]];l=l+o;e=a[l];n=e[s];m=d[e[f]];d[n+1]=m;d[n]=m[e[A]];break end while(n)/((2880-0x5c5))==1141 do local a=e[k];local i=e[I];local n=a+2 local a={d[a](d[a+1],d[n])};for e=1,i do d[n+e]=a[e];end;local a=a[1]if a then d[n]=a l=e[w];else l=l+o;end;break end;break;end break;end break;end break;end while 2480==(n)/((838725/0xd3))do n=(658292)while(-#"big black sins"+(251+-0x73))>=m do n=-n n=(1507310)while((0x9c+-27)+-#[[free trojan]])>=m do n=-n n=(10401400)while(-#'notbelugafan was here'+(-0x7f+264))>=m do n=-n n=(151050)while(287-0xac)<m do n=-n d[e[c]]=d[e[u]]-d[e[H]];break end while 1425==(n)/(((0x151-200)+-#'black mess more like white mesa'))do local k;local n;d[e[b]]();l=l+o;e=a[l];d[e[h]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[I]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[H]];l=l+o;e=a[l];n=e[h];k=d[e[t]];d[n+1]=k;d[n]=k[e[H]];l=l+o;e=a[l];d[e[h]]=C[e[u]];l=l+o;e=a[l];n=e[c]d[n](p(d,n+y,e[f]))break end;break;end while(n)/((0x18e7-3199))==3275 do n=(3708578)while(-#[[IPIPEH ILOVE YOU AAAAA]]+(21128/(0x110+-120)))<m do n=-n local n;d[e[i]]=e[g];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[c]][e[t]]=d[e[H]];l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[P]];l=l+o;e=a[l];d[e[i]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[i]][e[x]]=d[e[v]];l=l+o;e=a[l];d[e[i]][e[g]]=e[I];l=l+o;e=a[l];d[e[h]]=r[e[x]];break end while 2494==(n)/((-104+0x637))do local n;d[e[c]]=r[e[u]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[s]]=d[e[x]][e[A]];l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[B]];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[b]]=e[f];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[s]][e[f]]=d[e[B]];l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[A]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[B]];l=l+o;e=a[l];d[e[h]]=d[e[g]][e[I]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[A]];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[c]][e[x]]=d[e[B]];l=l+o;e=a[l];do return end;break end;break;end break;end while 1765==(n)/((-0x5e+948))do n=(10138)while m<=(352-0xe8)do n=-n n=(2848260)while m>(-#'Candyman was here'+(353-0xd9))do n=-n d[e[b]]=d[e[x]];break end while(n)/((5216-((-25+0xa80)+-#'ILoveBlowJobs')))==1110 do local n;d[e[c]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[b]][e[f]]=d[e[A]];l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[s]]=d[e[w]][e[I]];l=l+o;e=a[l];d[e[b]]=e[u];break end;break;end while 137==(n)/((263-0xbd))do n=(2212650)while(-#'mee6 what are you doing to my wife'+(0x4eb6/130))<m do n=-n local m;local v,P;local n;d[e[h]]();l=l+o;e=a[l];d[e[i]]=C[e[x]];l=l+o;e=a[l];d[e[b]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[B]];l=l+o;e=a[l];d[e[i]]=r[e[t]];l=l+o;e=a[l];d[e[s]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];n=e[h]v,P=N(d[n](p(d,n+1,e[g])))F=P+n-1 m=0;for e=n,F do m=m+o;d[e]=v[m];end;l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,F))l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[H]];l=l+o;e=a[l];d[e[b]]=r[e[t]];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[B]];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];n=e[b]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[k]]=d[e[t]]*d[e[A]];l=l+o;e=a[l];d[e[c]][e[f]]=d[e[A]];break end while(n)/((0x728-938))==2475 do d[e[s]]=d[e[g]]-d[e[P]];break end;break;end break;end break;end while(n)/((503+-0x69))==1654 do n=(417526)while m<=(-0x39+183)do n=-n n=(17287)while m<=((0xd3+(-0x48-4))+-#'free trojan')do n=-n n=(7674394)while(0x38b2/118)<m do n=-n local n;d[e[s]]=e[g];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[c]][e[g]]=d[e[H]];l=l+o;e=a[l];d[e[k]][e[u]]=e[B];l=l+o;e=a[l];d[e[i]][e[f]]=e[v];l=l+o;e=a[l];d[e[k]][e[t]]=d[e[A]];l=l+o;e=a[l];d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[v]];l=l+o;e=a[l];d[e[c]]=e[g];break end while(n)/(((0x48d6e/((399-0xe3)+-#"dont use it anymore"))+-#[[ILoveBlowJobs]]))==3962 do local n=e[h];local o={};for e=1,#M do local e=M[e];for l=0,#e do local e=e[l];local a=e[1];local l=e[2];if a==d and l>=n then o[l]=a[l];e[1]=o;end;end;end;break end;break;end while 293==(n)/((0x29f2/182))do n=(3517992)while m>(270-0x91)do n=-n if d[e[c]]then l=l+o;else l=e[f];end;break end while 3294==(n)/((0xd8f0/52))do local n;local h;local s,P;local m;local n;d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[b]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=d[e[f]][e[H]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[v]];l=l+o;e=a[l];n=e[c];m=d[e[u]];d[n+1]=m;d[n]=m[e[A]];l=l+o;e=a[l];n=e[c]s,P=N(d[n](d[n+y]))F=P+n-o h=0;for e=n,F do h=h+o;d[e]=s[h];end;l=l+o;e=a[l];n=e[i]s={d[n](p(d,n+1,F))};h=0;for e=n,e[H]do h=h+o;d[e]=s[h];end l=l+o;e=a[l];l=e[w];break end;break;end break;end while(n)/((0xd3e4/142))==1093 do n=(5481310)while(0x126-166)>=m do n=-n n=(2288472)while m>(0x14a-(-0x27+242))do n=-n local m;local n;n=e[h];m=d[e[g]];d[n+1]=m;d[n]=m[e[B]];l=l+o;e=a[l];d[e[b]]=e[g];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[c]]=d[e[x]][e[P]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[B]];l=l+o;e=a[l];n=e[s];m=d[e[g]];d[n+1]=m;d[n]=m[e[v]];l=l+o;e=a[l];d[e[k]]=d[e[u]];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];d[e[s]]=C[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[B]];l=l+o;e=a[l];d[e[s]]=d[e[x]][e[B]];l=l+o;e=a[l];d[e[s]]=d[e[x]][e[A]];l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[P]];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[k]]=d[e[g]]*d[e[B]];l=l+o;e=a[l];n=e[i]d[n](p(d,n+y,e[x]))break end while 1704==(n)/((2754-0x583))do local r;local n;d[e[b]]=e[x];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[b]][e[x]]=d[e[H]];l=l+o;e=a[l];d[e[s]][e[u]]=e[v];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[A]];l=l+o;e=a[l];n=e[h];r=d[e[g]];d[n+1]=r;d[n]=r[e[H]];break end;break;end while(n)/((0xd8e-((0xe07-1807)+-#[[looadstring]])))==3230 do n=(3844060)while((0x1b3-261)+-#[[guys Please proceed to translate D to Sinhala]])>=m do n=-n local r;local n;d[e[s]]=C[e[g]];l=l+o;e=a[l];d[e[i]]=d[e[w]][e[B]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[H]];l=l+o;e=a[l];n=e[b];r=d[e[g]];d[n+1]=r;d[n]=r[e[I]];l=l+o;e=a[l];n=e[s]d[n](d[n+y])l=l+o;e=a[l];do return end;break;end while(n)/((1218+-0x6b))==3460 do n=(12393906)while m>(-#"amena jumping"+(-0x1e+173))do n=-n l=e[t];break end while 3291==(n)/((139342/0x25))do local n;d[e[k]]=e[g];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[h]][e[f]]=d[e[I]];l=l+o;e=a[l];d[e[k]]=r[e[w]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[v]];l=l+o;e=a[l];d[e[k]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[b]][e[f]]=d[e[I]];l=l+o;e=a[l];d[e[h]][e[u]]=e[P];l=l+o;e=a[l];d[e[k]]=r[e[f]];break end;break;end break;end break;end break;end break;end break;end break;end break;end while 2405==(n)/((-127+0xbda))do n=(9197110)while m<=(433-0xec)do n=-n n=(11342180)while m<=((-66+0x106)+-#"xenny its znugget please respond")do n=-n n=(2192298)while m<=(-#'iPipeh Is My God'+(288+-0x7d))do n=-n n=(3046470)while m<=((0xa1e0-20729)/0x95)do n=-n n=(8170992)while((-65-0x4)+204)>=m do n=-n n=(1776006)while(194+-0x3d)>=m do n=-n n=(1223734)while m>(22836/0xad)do n=-n local n;n=e[k]d[n](p(d,n+y,e[t]))l=l+o;e=a[l];d[e[h]][e[f]]=e[B];l=l+o;e=a[l];d[e[s]][e[g]]=d[e[v]];l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[b]][e[g]]=d[e[I]];break end while(n)/(((374340/0xff)-0x2f7))==1726 do d[e[s]]();break end;break;end while(n)/((1065+-0x27))==1731 do n=(12375558)while(8576/0x40)<m do n=-n if(d[e[b]]==d[e[I]])then l=l+y;else l=e[g];end;break end while 3757==(n)/((-#'tonka'+(-0x28+3339)))do d[e[c]]();l=l+o;e=a[l];d[e[s]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[v]];l=l+o;e=a[l];d[e[i]]=d[e[w]][e[B]];l=l+o;e=a[l];d[e[k]]=d[e[t]][e[I]];l=l+o;e=a[l];d[e[s]]=C[e[u]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[H]];l=l+o;e=a[l];d[e[c]][e[f]]=d[e[v]];l=l+o;e=a[l];l=e[g];break end;break;end break;end while 2148==(n)/(((7702-0xf33)+-#"test123"))do n=(8781780)while((0x8c1a/227)+-#"Two trucks having sex")>=m do n=-n n=(128234)while(353-0xd9)<m do n=-n local n;d[e[c]]=d[e[x]][e[B]];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];d[e[k]]=e[g];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[k]][e[w]]=d[e[v]];l=l+o;e=a[l];d[e[i]]=r[e[f]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[v]];l=l+o;e=a[l];d[e[i]]=e[x];break end while 1322==(n)/((-0x41+162))do local i;local n;n=e[b];i=d[e[t]];d[n+1]=i;d[n]=i[e[I]];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[v]];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];if not d[e[k]]then l=l+y;else l=e[t];end;break end;break;end while(n)/(((69069/0x17)+-#"iPipeh Is My God"))==2940 do n=(7837690)while m>(378-0xf0)do n=-n local i;local n;n=e[k];i=d[e[w]];d[n+1]=i;d[n]=i[e[B]];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[b]]=d[e[g]][e[P]];l=l+o;e=a[l];n=e[c];i=d[e[g]];d[n+1]=i;d[n]=i[e[B]];l=l+o;e=a[l];n=e[h]d[n](d[n+y])l=l+o;e=a[l];l=e[u];break end while 2485==(n)/((0x1922-3280))do local l=e[i]local n={d[l](d[l+1])};local a=0;for e=l,e[B]do a=a+o;d[e]=n[a];end break end;break;end break;end break;end while 815==(n)/((-0x40+3802))do n=(9242478)while((12300/(229-0x9a))+-#"iPipeh iam u Best Fan")>=m do n=-n n=(341380)while m<=(387-0xf6)do n=-n n=(6361531)while m>(0x698c/193)do n=-n if(d[e[h]]~=e[I])then l=l+y;else l=e[g];end;break end while 3463==(n)/((0xeb0-1923))do local x=K[e[g]];local i;local o={};i=z({},{__index=function(l,e)local e=o[e];return e[1][e[2]];end,__newindex=function(d,e,l)local e=o[e]e[1][e[2]]=l;end;});for n=1,e[H]do l=l+y;local e=a[l];if e[(-#"Dick"+(-118+0x7b))]==40 then o[n-1]={d,e[f]};else o[n-1]={C,e[f]};end;M[#M+1]=o;end;d[e[k]]=S(x,i,r);break end;break;end while(n)/((-#[[ez monke]]+(0x11f+-110)))==2020 do n=(1560543)while m>(387-0xf5)do n=-n local n;n=e[h]d[n](p(d,n+y,e[f]))l=l+o;e=a[l];d[e[i]][e[t]]=e[I];l=l+o;e=a[l];d[e[i]][e[f]]=d[e[A]];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[b]][e[t]]=d[e[v]];break end while(n)/(((0x2bb+-119)+-#"sinsploit"))==2733 do d[e[h]][d[e[w]]]=d[e[B]];break end;break;end break;end while 3087==(n)/((482034/(0x5a90/144)))do n=(36456)while(-#"Candyman was here"+(0xc0+-30))>=m do n=-n n=(592503)while(378-0xea)<m do n=-n d[e[h]][e[u]]=d[e[B]];break end while(n)/((-119+0x340))==831 do local n;d[e[h]]=e[t];l=l+o;e=a[l];d[e[k]]=e[x];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[c]][e[x]]=d[e[P]];l=l+o;e=a[l];d[e[k]][e[u]]=e[A];l=l+o;e=a[l];d[e[c]]=r[e[t]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[P]];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];d[e[k]]=e[u];break end;break;end while(n)/((0x731-973))==42 do n=(6009717)while m>(325-0xb3)do n=-n local n;local b;local t,g;local s;local n;d[e[i]]=r[e[u]];l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[w]][e[P]];l=l+o;e=a[l];n=e[h];s=d[e[x]];d[n+1]=s;d[n]=s[e[v]];l=l+o;e=a[l];n=e[k]t,g=N(d[n](d[n+y]))F=g+n-o b=0;for e=n,F do b=b+o;d[e]=t[b];end;l=l+o;e=a[l];n=e[i]t={d[n](p(d,n+1,F))};b=0;for e=n,e[B]do b=b+o;d[e]=t[b];end l=l+o;e=a[l];l=e[x];break end while 2049==(n)/((3032+-0x63))do local l=e[i]local n={d[l](d[l+1])};local a=0;for e=l,e[A]do a=a+o;d[e]=n[a];end break end;break;end break;end break;end break;end while 573==(n)/((7742-0xf4c))do n=(16148286)while((0x591e/122)+-#[[xenny its znugget please respond]])>=m do n=-n n=(4869325)while(-0x4c+227)>=m do n=-n n=(679559)while((345-0xb7)+-#'me big peepee')>=m do n=-n n=(15420033)while m>(26048/0xb0)do n=-n local n;d[e[s]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[b]]=d[e[t]];l=l+o;e=a[l];n=e[s]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[h]]=d[e[w]][e[A]];l=l+o;e=a[l];if d[e[b]]then l=l+o;else l=e[x];end;break end while 3963==(n)/((505830/0x82))do local x=K[e[f]];local i;local o={};i=z({},{__index=function(l,e)local e=o[e];return e[1][e[2]];end,__newindex=function(d,e,l)local e=o[e]e[1][e[2]]=l;end;});for n=1,e[P]do l=l+y;local e=a[l];if e[((2121/0x65)+-#[[Hard Sex with iPipeh]])]==40 then o[n-1]={d,e[t]};else o[n-1]={C,e[w]};end;M[#M+1]=o;end;d[e[c]]=S(x,i,r);break end;break;end while 1487==(n)/((-120+0x241))do n=(3250521)while m>(186+-0x24)do n=-n local o=e[b];local l=d[e[g]];d[o+1]=l;d[o]=l[e[I]];break end while(n)/(((-102+0x426)+-#"iPipeh I Love You"))==3447 do d[e[k]]=#d[e[w]];break end;break;end break;end while 1891==(n)/((0x20b0c/52))do n=(2659992)while m<=(383-0xe6)do n=-n n=(2161392)while m>(180+-0x1c)do n=-n local n;local r;d[e[h]][e[u]]=d[e[A]];l=l+o;e=a[l];d[e[k]][e[f]]=e[I];l=l+o;e=a[l];d[e[b]][e[g]]=e[v];l=l+o;e=a[l];d[e[k]][e[x]]=e[A];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[B]];l=l+o;e=a[l];r=e[i];n=d[e[w]];d[r+1]=n;d[r]=n[e[H]];break end while(n)/((((0x8d608-289579)+-#'amena jumping')/0xa3))==1217 do d[e[k]]={};break end;break;end while(n)/((0x35f+-54))==3288 do n=(2843247)while(14938/0x61)<m do n=-n local n;d[e[c]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[b]][e[t]]=d[e[H]];l=l+o;e=a[l];d[e[h]]=r[e[w]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[B]];l=l+o;e=a[l];d[e[h]]=e[f];break end while(n)/((-#"require"+((3971-0x7ea)-0x3d5)))==2971 do local n;n=e[b]d[n](p(d,n+y,e[x]))l=l+o;e=a[l];d[e[s]][e[g]]=e[B];l=l+o;e=a[l];d[e[h]][e[f]]=d[e[v]];l=l+o;e=a[l];d[e[b]]=r[e[u]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];d[e[c]]=e[g];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[s]][e[w]]=d[e[A]];break end;break;end break;end break;end while(n)/((8167-0x102d))==4011 do n=(4147720)while(277+-0x76)>=m do n=-n n=(4806781)while(0x18f-242)>=m do n=-n n=(12243111)while m>(329-0xad)do n=-n local n;n=e[c]d[n](p(d,n+y,e[f]))l=l+o;e=a[l];d[e[i]][e[x]]=e[v];l=l+o;e=a[l];d[e[s]][e[x]]=d[e[I]];l=l+o;e=a[l];d[e[s]]=r[e[f]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[v]];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[s]][e[x]]=d[e[P]];break end while 3417==(n)/(((0x1c9f-3698)+-#[[edp445 what are you doing to my 3 year old son]]))do local n;n=e[c]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[B]];l=l+o;e=a[l];d[e[k]][e[g]]=d[e[A]];break end;break;end while 2479==(n)/((0x7b5+-34))do n=(2859102)while m>(342-0xb8)do n=-n l=e[t];break end while(n)/((45162/0xd))==823 do local n;n=e[s]d[n](p(d,n+y,e[w]))l=l+o;e=a[l];d[e[k]][e[w]]=e[v];l=l+o;e=a[l];d[e[c]][e[w]]=d[e[A]];l=l+o;e=a[l];d[e[s]]=r[e[x]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];d[e[k]]=e[g];l=l+o;e=a[l];d[e[s]]=e[g];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[s]][e[u]]=d[e[A]];break end;break;end break;end while 1069==(n)/((675120/0xae))do n=(8096828)while m<=(-#"iPipeh iam u Best Fan"+(0x133+-125))do n=-n n=(860146)while m>(12000/0x4b)do n=-n d[e[s]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[k]]=r[e[t]];l=l+o;e=a[l];d[e[i]]=d[e[w]][e[H]];l=l+o;e=a[l];d[e[k]]=d[e[f]][e[v]];l=l+o;e=a[l];if(d[e[h]]~=d[e[P]])then l=l+y;else l=e[x];end;break end while 917==(n)/((0x7ad-1027))do local n;d[e[c]]=e[g];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[c]][e[f]]=d[e[B]];l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[H]];l=l+o;e=a[l];d[e[i]][e[w]]=d[e[P]];l=l+o;e=a[l];d[e[i]][e[g]]=e[B];l=l+o;e=a[l];d[e[i]]=r[e[f]];break end;break;end while(n)/((-#[[dont use it anymore]]+(-42+0xf3e)))==2108 do n=(11621220)while m<=((215+-0x2e)+-#[[Hi skid]])do n=-n local r;local n;d[e[h]]=e[x];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[h]][e[w]]=d[e[B]];l=l+o;e=a[l];d[e[i]][e[u]]=e[v];l=l+o;e=a[l];d[e[h]][e[f]]=e[B];l=l+o;e=a[l];d[e[c]][e[t]]=e[I];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[A]];l=l+o;e=a[l];n=e[c];r=d[e[x]];d[n+1]=r;d[n]=r[e[P]];break;end while 3055==(n)/((0x1ded-3857))do n=(6875712)while m>(431-0x10c)do n=-n local n;d[e[b]]=e[t];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[s]][e[x]]=d[e[P]];l=l+o;e=a[l];d[e[b]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=d[e[u]][e[P]];l=l+o;e=a[l];d[e[b]]=d[e[g]][e[I]];l=l+o;e=a[l];d[e[s]][e[f]]=d[e[v]];l=l+o;e=a[l];d[e[s]][e[w]]=e[v];l=l+o;e=a[l];d[e[k]]=r[e[w]];break end while(n)/((-#[[iPipeh I Love You]]+(0x8d7+-38)))==3114 do local b;local n;n=e[k];b=d[e[g]];d[n+1]=b;d[n]=b[e[I]];l=l+o;e=a[l];d[e[k]]=e[g];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];n=e[s];b=d[e[f]];d[n+1]=b;d[n]=b[e[P]];l=l+o;e=a[l];d[e[k]]=e[x];l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=d[e[g]][e[I]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[v]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[v]];break end;break;end break;end break;end break;end break;end break;end while(n)/((-0x16+4067))==2804 do n=(6788454)while(-#"big black sins"+(-0x5d+287))>=m do n=-n n=(7734285)while((0x1b1-249)+-#"Rivers Cuomo")>=m do n=-n n=(853050)while m<=(413-(0x115+-32))do n=-n n=(9373656)while(0x1a1-251)>=m do n=-n n=(928710)while(-#[[dick cheese]]+(0x17a-202))<m do n=-n local n;r[e[g]]=d[e[k]];l=l+o;e=a[l];d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[b]]=d[e[g]][e[v]];l=l+o;e=a[l];d[e[k]]=e[u];l=l+o;e=a[l];n=e[s]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[k]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];n=e[c]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[v]];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];n=e[c]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[k]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[I]];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];n=e[i]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[b]]=r[e[g]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[H]];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];n=e[s]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];n=e[i]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[k]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];n=e[c]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];n=e[s]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];n=e[h]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[i]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[g]][e[v]];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];n=e[s]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];n=e[k]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[c]]=e[t];l=l+o;e=a[l];n=e[i]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[b]]=r[e[g]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];n=e[b]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[s]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];n=e[i]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[k]]=r[e[u]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];n=e[s]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[b]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[A]];l=l+o;e=a[l];d[e[k]]=e[x];l=l+o;e=a[l];n=e[k]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];n=e[s]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[i]]=r[e[u]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];n=e[h]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[i]]=r[e[w]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[v]];l=l+o;e=a[l];d[e[k]]=e[u];l=l+o;e=a[l];n=e[c]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[b]]=e[u];break end while(n)/(((2515-(0xa6a-1378))+-#"fish was here"))==765 do local o=e[s];local n=d[o+2];local a=d[o]+n;d[o]=a;if(n>0)then if(a<=d[o+1])then l=e[t];d[o+3]=a;end elseif(a>=d[o+1])then l=e[w];d[o+3]=a;end break end;break;end while(n)/((8080-0xff1))==2344 do n=(6236398)while(275+-0x6c)<m do n=-n local n;n=e[b]d[n](p(d,n+y,e[w]))l=l+o;e=a[l];d[e[b]][e[g]]=e[A];l=l+o;e=a[l];d[e[c]][e[x]]=d[e[I]];l=l+o;e=a[l];d[e[h]]=r[e[t]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[k]]=e[u];l=l+o;e=a[l];d[e[k]]=e[x];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[c]][e[g]]=d[e[v]];break end while 2902==(n)/((0x12e34/36))do local l=e[i]local n={d[l](p(d,l+1,F))};local a=0;for e=l,e[B]do a=a+o;d[e]=n[a];end break end;break;end break;end while(n)/((0x1c01-3644))==242 do n=(984966)while m<=(-#"test123"+(((-66+0x21c)+-#[[Never gonna give u up]])-276))do n=-n n=(3298460)while(0x1bd-(569-0x125))<m do n=-n local e=e[b]local a,l=N(d[e](d[e+y]))F=l+e-o local l=0;for e=e,F do l=l+o;d[e]=a[l];end;break end while 2585==(n)/((151844/0x77))do local x;local k,t;local h;local n;d[e[i]]=r[e[u]];l=l+o;e=a[l];d[e[i]]=r[e[w]];l=l+o;e=a[l];n=e[b];h=d[e[u]];d[n+1]=h;d[n]=h[e[B]];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];n=e[b]k,t=N(d[n](p(d,n+1,e[u])))F=t+n-1 x=0;for e=n,F do x=x+o;d[e]=k[x];end;l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,F))l=l+o;e=a[l];d[e[b]]();l=l+o;e=a[l];do return end;break end;break;end while 501==(n)/(((366420/0xba)+-#'Bong'))do n=(7482078)while m>(0x195-234)do n=-n local e=e[i]d[e]=d[e](d[e+y])break end while(n)/((-#"test"+(0xd13+-70)))==2286 do d[e[h]]=d[e[w]]%e[B];break end;break;end break;end break;end while 3051==(n)/(((0x535b8/(-#'dick cheese'+(386-0xf1)))+-#'ILoveBlowJobs'))do n=(4534794)while(0x1de-302)>=m do n=-n n=(1833552)while(0x10b+-93)>=m do n=-n n=(4253179)while m>(-#"zNugget is dad"+(-0x3b+((-0x4e+336)+-#[[Rivers Cuomo]])))do n=-n if not d[e[s]]then l=l+y;else l=e[x];end;break end while(n)/((0x45ae5/163))==2429 do local n;n=e[k]d[n](p(d,n+y,e[u]))l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[i]]=r[e[t]];l=l+o;e=a[l];d[e[i]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[B]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[h]][e[u]]=d[e[P]];l=l+o;e=a[l];do return end;break end;break;end while 1819==(n)/((-#"print"+(183353/0xb5)))do n=(3699840)while(-#"Bong"+(-0x5c+271))<m do n=-n local l=e[k]local a,e=N(d[l](p(d,l+1,e[u])))F=e+l-1 local e=0;for l=l,F do e=e+o;d[l]=a[e];end;break end while(n)/((0x381c6/163))==2624 do d[e[k]][e[w]]=e[H];break end;break;end break;end while 3714==(n)/((0xb53e/38))do n=(3006055)while m<=(-127+0x131)do n=-n n=(4401075)while m>(13806/0x4e)do n=-n local e=e[c]d[e](d[e+y])break end while 1245==(n)/((0xe40+-113))do local n;d[e[s]]=d[e[g]][e[v]];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[s]][e[g]]=d[e[v]];l=l+o;e=a[l];d[e[s]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[B]];l=l+o;e=a[l];d[e[c]]=e[w];break end;break;end while 1339==(n)/((309810/0x8a))do n=(693280)while(228+-0x31)<m do n=-n local r;local n;d[e[h]]=e[t];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[i]][e[w]]=d[e[B]];l=l+o;e=a[l];d[e[s]][e[g]]=e[v];l=l+o;e=a[l];d[e[k]]=d[e[w]][e[I]];l=l+o;e=a[l];n=e[s];r=d[e[w]];d[n+1]=r;d[n]=r[e[I]];break end while(n)/(((5080-0xa0a)-1272))==560 do local r;local n;d[e[k]]=e[x];l=l+o;e=a[l];d[e[c]]=e[t];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[c]][e[w]]=d[e[I]];l=l+o;e=a[l];d[e[h]][e[x]]=e[A];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[B]];l=l+o;e=a[l];n=e[h];r=d[e[x]];d[n+1]=r;d[n]=r[e[I]];break end;break;end break;end break;end break;end while 2217==(n)/((422556/0x8a))do n=(142379)while m<=(15228/0x51)do n=-n n=(151321)while(449-(-#'Hard Sex with iPipeh'+(0x26a-333)))>=m do n=-n n=(7380486)while m<=(-0x7d+307)do n=-n n=(213738)while m>(12670/0x46)do n=-n local o=e[w];local l=d[o]for e=o+1,e[H]do l=l..d[e];end;d[e[h]]=l;break end while 147==(n)/(((1530+-0x3f)+-#"fish was here"))do local i;local w;local h;local n;n=e[s]d[n](p(d,n+y,e[t]))l=l+o;e=a[l];d[e[b]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[P]];l=l+o;e=a[l];for e=e[k],e[x]do d[e]=nil;end;l=l+o;e=a[l];d[e[b]]=r[e[t]];l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];n=e[s];h=d[e[g]];d[n+1]=h;d[n]=h[e[B]];l=l+o;e=a[l];n=e[b]w={d[n](d[n+1])};i=0;for e=n,e[I]do i=i+o;d[e]=w[i];end l=l+o;e=a[l];l=e[t];break end;break;end while 2361==(n)/((-#'fish was here'+(-118+0xcb9)))do n=(4038992)while(444-0x105)<m do n=-n for e=e[s],e[w]do d[e]=nil;end;break end while 3854==(n)/(((-54+0x460)+-#[[iam u Furry iPipeh]]))do local n;d[e[k]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[s]][e[x]]=d[e[P]];l=l+o;e=a[l];d[e[b]]=r[e[t]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[b]]=e[g];break end;break;end break;end while 389==(n)/((-0x18+413))do n=(6211685)while m<=(0x1a3-233)do n=-n n=(889865)while m>(0x1ce-277)do n=-n d[e[b]]=d[e[x]]%e[B];break end while 2465==(n)/((0x34f-486))do local x;local n;d[e[i]]=r[e[u]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[B]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[v]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[B]];l=l+o;e=a[l];d[e[s]]=d[e[w]][d[e[H]]];l=l+o;e=a[l];n=e[s];x=d[e[w]];d[n+1]=x;d[n]=x[e[H]];l=l+o;e=a[l];n=e[h]d[n](d[n+y])break end;break;end while 2551==(n)/(((-456/0xc)+2473))do n=(3072780)while(0x186-203)<m do n=-n d[e[i]]=d[e[x]]*d[e[v]];break end while(n)/(((4936-0x9d8)+-#[[mee6 what are you doing to my wife]]))==1290 do local n;d[e[k]]=e[u];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[h]][e[u]]=d[e[H]];l=l+o;e=a[l];d[e[s]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[P]];l=l+o;e=a[l];d[e[k]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[c]][e[x]]=d[e[P]];l=l+o;e=a[l];d[e[s]][e[w]]=e[P];l=l+o;e=a[l];d[e[c]]=r[e[f]];break end;break;end break;end break;end while 173==(n)/((21398/0x1a))do n=(5066901)while m<=(233+-0x29)do n=-n n=(5236850)while m<=((39960/0xb4)+-#"xenny its znugget please respond")do n=-n n=(12236)while m>(-86+0x113)do n=-n d[e[c]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[h]]=d[e[f]][e[H]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[A]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[v]];l=l+o;e=a[l];C[e[t]]=d[e[s]];break end while(n)/((-#'Candyman was here'+(0x283-360)))==46 do local n;n=e[b]d[n](p(d,n+y,e[t]))l=l+o;e=a[l];d[e[c]][e[f]]=e[A];l=l+o;e=a[l];d[e[i]][e[x]]=d[e[B]];l=l+o;e=a[l];d[e[i]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[H]];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];d[e[s]]=e[g];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[i]][e[w]]=d[e[P]];l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[k]]=e[x];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[s]][e[w]]=d[e[B]];l=l+o;e=a[l];d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[P]];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[s]][e[f]]=d[e[B]];l=l+o;e=a[l];d[e[h]]=r[e[u]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[B]];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[h]][e[x]]=d[e[P]];l=l+o;e=a[l];d[e[i]][e[w]]=e[P];l=l+o;e=a[l];d[e[c]]=r[e[t]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[h]][e[t]]=d[e[v]];l=l+o;e=a[l];d[e[b]][e[f]]=e[I];l=l+o;e=a[l];d[e[k]][e[g]]=e[H];l=l+o;e=a[l];d[e[b]][e[f]]=d[e[v]];l=l+o;e=a[l];d[e[h]]=r[e[g]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[c]][e[t]]=d[e[v]];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[I]];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];d[e[c]]=e[g];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[c]][e[x]]=d[e[P]];l=l+o;e=a[l];d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[v]];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];d[e[b]]=e[f];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[c]][e[w]]=d[e[P]];l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[b]][e[t]]=d[e[A]];l=l+o;e=a[l];d[e[b]][e[w]]=e[P];l=l+o;e=a[l];d[e[k]]=r[e[g]];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[P]];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];d[e[k]]=e[x];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[i]][e[t]]=d[e[H]];l=l+o;e=a[l];d[e[i]][e[g]]=e[P];l=l+o;e=a[l];d[e[k]][e[x]]=e[P];l=l+o;e=a[l];d[e[b]][e[x]]=d[e[I]];l=l+o;e=a[l];d[e[b]]=r[e[w]];break end;break;end while 1717==(n)/((0x27772/53))do n=(506844)while m>(0xad18/232)do n=-n local i;local n;d[e[b]]=e[u];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[c]][e[f]]=d[e[I]];l=l+o;e=a[l];d[e[s]][e[g]]=e[P];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[I]];l=l+o;e=a[l];n=e[b];i=d[e[g]];d[n+1]=i;d[n]=i[e[A]];break end while 361==(n)/((2907-0x5df))do local r;local n;d[e[b]]=e[w];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[i]][e[g]]=d[e[I]];l=l+o;e=a[l];d[e[b]][e[x]]=e[H];l=l+o;e=a[l];d[e[b]]=d[e[g]][e[A]];l=l+o;e=a[l];n=e[h];r=d[e[f]];d[n+1]=r;d[n]=r[e[v]];break end;break;end break;end while(n)/(((661906+-0x1c)/206))==1577 do n=(4615209)while m<=(-#[[IPIPEH I WANNA FUCK WITH YOU]]+((-59+0x16e)+-0x55))do n=-n n=(13625280)while(428-0xeb)<m do n=-n local x;local r;local n;d[e[k]]=e[w];l=l+o;e=a[l];d[e[c]]=e[t];l=l+o;e=a[l];d[e[c]]=#d[e[t]];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];n=e[h];r=d[n]x=d[n+2];if(x>0)then if(r>d[n+1])then l=e[g];else d[n+3]=r;end elseif(r<d[n+1])then l=e[w];else d[n+3]=r;end break end while(n)/((8090-0x100a))==3420 do if(d[e[b]]~=d[e[B]])then l=l+y;else l=e[g];end;break end;break;end while(n)/((-43+0xa8c))==1737 do n=(631154)while m<=((236+-0x1e)+-#"looadstring")do n=-n d[e[i]]=C[e[f]];l=l+o;e=a[l];d[e[k]]=#d[e[u]];l=l+o;e=a[l];C[e[t]]=d[e[i]];l=l+o;e=a[l];d[e[i]]=C[e[g]];l=l+o;e=a[l];d[e[s]]=#d[e[w]];l=l+o;e=a[l];C[e[g]]=d[e[c]];l=l+o;e=a[l];do return end;break;end while(n)/((-114+0x125))==3526 do n=(14398165)while m>(-0x2e+242)do n=-n local n;local i;local b,f;local k;local n;d[e[s]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=r[e[u]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[H]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[B]];l=l+o;e=a[l];n=e[h];k=d[e[w]];d[n+1]=k;d[n]=k[e[v]];l=l+o;e=a[l];n=e[s]b,f=N(d[n](d[n+y]))F=f+n-o i=0;for e=n,F do i=i+o;d[e]=b[i];end;l=l+o;e=a[l];n=e[s]b={d[n](p(d,n+1,F))};i=0;for e=n,e[P]do i=i+o;d[e]=b[i];end l=l+o;e=a[l];l=e[t];break end while(n)/((0xfaa+-75))==3659 do d[e[c]]=C[e[t]];break end;break;end break;end break;end break;end break;end break;end break;end while(n)/(((3484+-0x2e)+-#"I like gargling cum"))==2690 do n=(1917948)while(0x237-337)>=m do n=-n n=(10404709)while((((0x30a-404)+-#[[iPipeh iam u Best Fan]])+-127)+-#[[amena jumping]])>=m do n=-n n=(1702943)while m<=(6560/0x20)do n=-n n=(442114)while(-#'mee6 what are you doing to my wife'+(47705/0xcb))>=m do n=-n n=(954528)while m<=(236+(0x10-53))do n=-n n=(12328112)while(0x1b4-(-0x39+295))<m do n=-n local m;local n;d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=d[e[u]][e[H]];l=l+o;e=a[l];d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[B]];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];m={d,e};m[y][m[T][b]]=m[o][m[T][A]]+m[y][m[T][t]];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[v]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[I]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[I]];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[k]]=d[e[u]];l=l+o;e=a[l];d[e[b]]=r[e[u]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[H]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[B]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[h]][e[g]]=d[e[I]];l=l+o;e=a[l];do return end;break end while 4066==(n)/((-#'FBI is going to attack you now escape mf'+(0xc5f+-95)))do local i;local n;d[e[k]]=r[e[x]];l=l+o;e=a[l];n=e[c];i=d[e[u]];d[n+1]=i;d[n]=i[e[v]];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[h]]=d[e[f]][e[v]];break end;break;end while 976==(n)/((1060+-0x52))do n=(9840576)while m>(458-0x102)do n=-n local n;n=e[h]d[n](p(d,n+y,e[w]))l=l+o;e=a[l];d[e[k]][e[x]]=e[A];l=l+o;e=a[l];d[e[b]][e[t]]=d[e[P]];l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[k]]=e[u];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[b]][e[g]]=d[e[P]];break end while 2874==(n)/((-81+(-#[[fish was here]]+(0xe2a+-108))))do d[e[b]]=d[e[f]]-e[P];break end;break;end break;end while 998==(n)/((0x15a18/200))do n=(3895458)while(238+(-0xaf/5))>=m do n=-n n=(135870)while(266+-0x40)<m do n=-n local b;local g,u;local t;local n;d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=r[e[f]];l=l+o;e=a[l];n=e[c];t=d[e[x]];d[n+1]=t;d[n]=t[e[P]];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];n=e[k]g,u=N(d[n](p(d,n+1,e[w])))F=u+n-1 b=0;for e=n,F do b=b+o;d[e]=g[b];end;l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,F))l=l+o;e=a[l];d[e[s]]();l=l+o;e=a[l];do return end;break end while(n)/((0xbb2e7/237))==42 do local n;n=e[s]d[n](p(d,n+y,e[f]))l=l+o;e=a[l];d[e[s]][e[x]]=e[I];l=l+o;e=a[l];d[e[i]][e[t]]=d[e[B]];l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[s]][e[f]]=d[e[v]];l=l+o;e=a[l];d[e[k]]=r[e[u]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];d[e[s]]=e[x];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[s]][e[t]]=d[e[I]];l=l+o;e=a[l];d[e[c]]=r[e[u]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[v]];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[k]]=e[g];l=l+o;e=a[l];d[e[b]]=e[f];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[i]][e[t]]=d[e[I]];l=l+o;e=a[l];d[e[k]]=r[e[w]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[i]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[s]][e[f]]=d[e[P]];l=l+o;e=a[l];d[e[h]][e[t]]=e[H];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[h]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[i]][e[x]]=d[e[H]];l=l+o;e=a[l];d[e[b]][e[t]]=e[B];l=l+o;e=a[l];d[e[h]][e[t]]=e[I];l=l+o;e=a[l];d[e[b]][e[u]]=d[e[H]];l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[i]][e[u]]=d[e[B]];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[b]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[k]]=e[u];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];d[e[c]]=e[t];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[i]][e[f]]=d[e[B]];l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[B]];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];d[e[k]]=e[x];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[k]][e[x]]=d[e[H]];l=l+o;e=a[l];d[e[h]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[P]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[B]];l=l+o;e=a[l];d[e[i]][e[t]]=d[e[I]];l=l+o;e=a[l];d[e[s]][e[t]]=e[A];l=l+o;e=a[l];d[e[b]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[k]][e[w]]=d[e[v]];l=l+o;e=a[l];d[e[i]][e[u]]=e[P];l=l+o;e=a[l];d[e[b]][e[x]]=e[B];l=l+o;e=a[l];d[e[b]][e[u]]=e[P];l=l+o;e=a[l];d[e[k]]=d[e[w]][e[B]];break end;break;end while(n)/((4157-0x84e))==1918 do n=(70245)while(6936/0x22)<m do n=-n local w;local n;d[e[i]]=r[e[u]];l=l+o;e=a[l];d[e[c]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[I]];l=l+o;e=a[l];n=e[i];w=d[e[x]];d[n+1]=w;d[n]=w[e[A]];l=l+o;e=a[l];n=e[c]d[n]=d[n](d[n+y])l=l+o;e=a[l];r[e[x]]=d[e[k]];l=l+o;e=a[l];d[e[s]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[H]];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];n=e[h]d[n]=d[n](d[n+y])l=l+o;e=a[l];r[e[x]]=d[e[c]];l=l+o;e=a[l];d[e[k]]=r[e[u]];l=l+o;e=a[l];d[e[i]][e[g]]=e[P];l=l+o;e=a[l];d[e[b]]=r[e[t]];l=l+o;e=a[l];d[e[i]][e[u]]=e[A];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[I]];l=l+o;e=a[l];n=e[k];w=d[e[g]];d[n+1]=w;d[n]=w[e[H]];break end while 223==(n)/(((0x8f10/112)+-#"Rivers Cuomo"))do local l=e[s]d[l](p(d,l+y,e[w]))break end;break;end break;end break;end while(n)/(((131236/0xda)+-#[[dont use it anymore]]))==2921 do n=(16168416)while m<=(-115+0x144)do n=-n n=(2540170)while(438-0xe7)>=m do n=-n n=(5763852)while((0x15d+-127)+-#"187 ist die gang")<m do n=-n local n;n=e[b]d[n](p(d,n+y,e[w]))l=l+o;e=a[l];d[e[s]][e[w]]=e[I];l=l+o;e=a[l];d[e[b]][e[f]]=d[e[v]];l=l+o;e=a[l];d[e[h]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[i]][e[f]]=d[e[A]];break end while(n)/((591624/0xc6))==1929 do local n;local L;local W,M;local C;local m;local n;d[e[i]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[B]];l=l+o;e=a[l];n=e[c];m=d[e[w]];d[n+1]=m;d[n]=m[e[I]];l=l+o;e=a[l];d[e[i]]=d[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[f]][e[B]];l=l+o;e=a[l];d[e[i]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[B]];l=l+o;e=a[l];d[e[k]]=d[e[w]][e[I]];l=l+o;e=a[l];d[e[b]]=r[e[t]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[k]]=e[u];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];C={d,e};C[y][C[T][k]]=C[o][C[T][B]]+C[y][C[T][x]];l=l+o;e=a[l];n=e[i]d[n](p(d,n+y,e[x]))l=l+o;e=a[l];d[e[h]]=r[e[g]];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];n=e[b]d[n](d[n+y])l=l+o;e=a[l];d[e[k]]=r[e[x]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[v]];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];d[e[h]]=r[e[u]];l=l+o;e=a[l];n=e[h];m=d[e[g]];d[n+1]=m;d[n]=m[e[A]];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[h]]=d[e[x]][e[I]];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[k]][e[t]]=e[H];l=l+o;e=a[l];d[e[k]]=r[e[t]];l=l+o;e=a[l];d[e[k]]=r[e[u]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[B]];l=l+o;e=a[l];d[e[s]]=d[e[x]][e[P]];l=l+o;e=a[l];n=e[k];m=d[e[f]];d[n+1]=m;d[n]=m[e[B]];l=l+o;e=a[l];n=e[h]W,M=N(d[n](d[n+y]))F=M+n-o L=0;for e=n,F do L=L+o;d[e]=W[L];end;l=l+o;e=a[l];n=e[h]W={d[n](p(d,n+1,F))};L=0;for e=n,e[A]do L=L+o;d[e]=W[L];end l=l+o;e=a[l];l=e[t];break end;break;end while(n)/((0x2f3+-102))==3890 do n=(5930604)while m>(465-0x101)do n=-n d[e[s]]=(e[u]~=0);l=l+y;break end while(n)/((0x1d66-3824))==1602 do d[e[k]]=d[e[g]][d[e[B]]];break end;break;end break;end while 4026==(n)/((562240/0x8c))do n=(1284720)while((8288/0x25)+-#[[amena jumping]])>=m do n=-n n=(901269)while(-30+0xf0)<m do n=-n d[e[i]]=r[e[u]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[H]];l=l+o;e=a[l];d[e[k]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[k]][e[t]]=d[e[B]];l=l+o;e=a[l];d[e[i]][e[w]]=e[H];l=l+o;e=a[l];d[e[h]]=r[e[u]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[B]];l=l+o;e=a[l];d[e[s]]=e[x];l=l+o;e=a[l];d[e[k]]=e[g];l=l+o;e=a[l];d[e[b]]=e[u];break end while 239==(n)/((595818/0x9e))do local n;n=e[c]d[n](p(d,n+y,e[x]))l=l+o;e=a[l];d[e[s]][e[f]]=e[A];l=l+o;e=a[l];d[e[k]][e[g]]=d[e[P]];l=l+o;e=a[l];d[e[k]]=r[e[u]];l=l+o;e=a[l];d[e[s]]=d[e[x]][e[P]];l=l+o;e=a[l];d[e[c]]=e[t];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[b]][e[w]]=d[e[P]];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[c]][e[x]]=d[e[A]];l=l+o;e=a[l];d[e[h]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[I]];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];d[e[c]]=e[u];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[h]][e[t]]=d[e[A]];l=l+o;e=a[l];d[e[h]]=r[e[u]];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[H]];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[H]];l=l+o;e=a[l];d[e[s]][e[g]]=d[e[P]];l=l+o;e=a[l];d[e[s]][e[g]]=e[P];l=l+o;e=a[l];d[e[i]]=r[e[w]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[P]];l=l+o;e=a[l];d[e[h]]=e[x];l=l+o;e=a[l];d[e[h]]=e[f];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[c]][e[x]]=d[e[v]];l=l+o;e=a[l];d[e[c]][e[w]]=e[H];l=l+o;e=a[l];d[e[h]][e[g]]=e[H];l=l+o;e=a[l];d[e[i]][e[t]]=d[e[P]];l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[k]]=e[u];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[s]][e[t]]=d[e[v]];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=d[e[f]][e[v]];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];d[e[s]]=e[w];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[k]][e[w]]=d[e[H]];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[s]]=e[g];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[k]][e[u]]=d[e[v]];l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[k]][e[u]]=d[e[A]];l=l+o;e=a[l];d[e[k]][e[u]]=e[B];l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[I]];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[h]][e[t]]=d[e[P]];l=l+o;e=a[l];d[e[k]][e[f]]=e[P];l=l+o;e=a[l];d[e[k]][e[g]]=e[H];l=l+o;e=a[l];d[e[k]][e[w]]=e[A];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[A]];break end;break;end while(n)/(((965-0x21f)+-#[[CockAndBallTorture]]))==3180 do n=(1843452)while((-0x62+326)+-#'iPipeh Is My God')<m do n=-n local n;d[e[k]]=e[t];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[i]][e[f]]=d[e[P]];l=l+o;e=a[l];d[e[c]]=r[e[t]];l=l+o;e=a[l];d[e[s]]=d[e[x]][e[v]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[k]][e[f]]=d[e[I]];l=l+o;e=a[l];d[e[c]][e[g]]=e[I];l=l+o;e=a[l];d[e[s]]=r[e[f]];break end while 1818==(n)/((-#"black mess more like white mesa"+(119130/0x72)))do do return d[e[b]]end break end;break;end break;end break;end break;end while(n)/((284321/0x4f))==2891 do n=(2758400)while m<=((-#"ez monke"+(642+-0x78))-0x125)do n=-n n=(3185908)while m<=((264+-0x1f)+-#[[iPipeh Is My God]])do n=-n n=(531570)while m<=(-33+0xf8)do n=-n n=(12210450)while m>(18190/0x55)do n=-n local o=e[i];local n=d[o+2];local a=d[o]+n;d[o]=a;if(n>0)then if(a<=d[o+1])then l=e[t];d[o+3]=a;end elseif(a>=d[o+1])then l=e[t];d[o+3]=a;end break end while(n)/((8091-0xff1))==3045 do local h;local b;local k;local n;n=e[c]d[n](p(d,n+y,e[x]))l=l+o;e=a[l];d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[B]];l=l+o;e=a[l];n=e[i]k={d[n]()};b=e[I];h=0;for e=n,b do h=h+o;d[e]=k[h];end l=l+o;e=a[l];l=e[u];break end;break;end while 1410==(n)/((0x1617/15))do n=(2969440)while(0xe9+-17)<m do n=-n if not d[e[s]]then l=l+y;else l=e[t];end;break end while(n)/((0x1920/6))==2770 do d[e[h]]=e[w];break end;break;end break;end while 1187==(n)/((-#"Two trucks having sex"+(297550/0x6e)))do n=(4534842)while m<=((16614/0x47)+-#[[Sub To BKProsYT]])do n=-n n=(2517728)while(0x1108/20)<m do n=-n d[e[c]]=d[e[g]][e[H]];l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[I]];l=l+o;e=a[l];if(d[e[h]]==d[e[v]])then l=l+y;else l=e[u];end;break end while 3838==(n)/(((-0x9-18)+683))do r[e[u]]=d[e[h]];break end;break;end while(n)/(((7399-0xe88)+-#[[big hard cock]]))==1237 do n=(6656328)while m>((0x136+-79)+-#[[dick cheese]])do n=-n local c;local n;d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[i]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[B]];l=l+o;e=a[l];n=e[b];c=d[e[x]];d[n+1]=c;d[n]=c[e[P]];l=l+o;e=a[l];n=e[i]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[h]]=d[e[u]][e[I]];l=l+o;e=a[l];r[e[u]]=d[e[k]];l=l+o;e=a[l];d[e[b]]=r[e[t]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[B]];l=l+o;e=a[l];if(d[e[h]]==e[I])then l=l+y;else l=e[w];end;break end while 2632==(n)/((-#[[deobfuscated]]+(622545/0xf5)))do local n;n=e[b]d[n](p(d,n+y,e[x]))l=l+o;e=a[l];d[e[s]][e[x]]=e[B];l=l+o;e=a[l];d[e[s]][e[x]]=d[e[I]];l=l+o;e=a[l];d[e[b]]=r[e[u]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[B]];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];d[e[s]]=e[g];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[k]][e[t]]=d[e[v]];break end;break;end break;end break;end while(n)/((163780/0xbe))==3200 do n=(4976495)while m<=((567-0x146)+-#'iPipeh Is My God')do n=-n n=(6321735)while m<=((2056/0x8)+-#'mee6 what are you doing to my wife')do n=-n n=(1465842)while m>(-0x4c+298)do n=-n local e=e[c]d[e](p(d,e+y,F))break end while(n)/((-#[[me big peepee]]+(409068/0xc6)))==714 do local n;n=e[s]d[n](p(d,n+y,e[t]))l=l+o;e=a[l];d[e[k]][e[u]]=e[P];l=l+o;e=a[l];d[e[b]][e[f]]=d[e[I]];l=l+o;e=a[l];d[e[k]]=r[e[w]];l=l+o;e=a[l];d[e[i]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[h]][e[w]]=d[e[P]];break end;break;end while(n)/((0x10ff-2236))==2989 do n=(10669335)while(-37+0x105)<m do n=-n local n;d[e[i]]=e[u];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[b]][e[g]]=d[e[B]];l=l+o;e=a[l];d[e[c]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];d[e[b]]=e[f];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];d[e[c]]=e[g];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[t]))break end while 3831==(n)/((-#[[test]]+(5692-0xb57)))do d[e[k]]=r[e[u]];break end;break;end break;end while(n)/((4666-0x939))==2159 do n=(3845600)while m<=(39725/0xaf)do n=-n n=(7686754)while((0x492-634)-310)<m do n=-n local r;local n;d[e[i]]=e[g];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[x]))l=l+o;e=a[l];d[e[c]][e[t]]=d[e[A]];l=l+o;e=a[l];d[e[s]][e[u]]=e[I];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[H]];l=l+o;e=a[l];n=e[i];r=d[e[x]];d[n+1]=r;d[n]=r[e[P]];break end while 2771==(n)/(((0x2f98c/68)+-0x5d))do local n;local x;local s,P;local m;local n;d[e[c]]=r[e[w]];l=l+o;e=a[l];d[e[k]]();l=l+o;e=a[l];d[e[h]]=r[e[g]];l=l+o;e=a[l];d[e[b]]=C[e[f]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[A]];l=l+o;e=a[l];n=e[c];m=d[e[t]];d[n+1]=m;d[n]=m[e[H]];l=l+o;e=a[l];n=e[i]s,P=N(d[n](d[n+y]))F=P+n-o x=0;for e=n,F do x=x+o;d[e]=s[x];end;l=l+o;e=a[l];n=e[b]s={d[n](p(d,n+1,F))};x=0;for e=n,e[v]do x=x+o;d[e]=s[x];end l=l+o;e=a[l];l=e[t];break end;break;end while(n)/((3579-0x71b))==2185 do n=(6569640)while m<=(((1120-0x251)-0x121)+-#[[sins daddy]])do n=-n local n;d[e[c]]=e[u];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[k]][e[f]]=d[e[A]];l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[P]];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];d[e[i]]=e[w];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[u]))break;end while 2212==(n)/((0x5cd0/8))do n=(9792504)while m>(41678/0xb6)do n=-n local e=e[b]d[e]=d[e](d[e+y])break end while 3324==(n)/((0xbe3+-97))do local k;local n;d[e[c]]();l=l+o;e=a[l];d[e[i]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[f]][e[H]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[v]];l=l+o;e=a[l];n=e[b];k=d[e[u]];d[n+1]=k;d[n]=k[e[I]];l=l+o;e=a[l];d[e[s]]=C[e[t]];l=l+o;e=a[l];n=e[c]d[n](p(d,n+y,e[g]))break end;break;end break;end break;end break;end break;end break;end while 2308==(n)/((201102/0xf2))do n=(1144634)while m<=(0x264-(-#[[I like gargling cum]]+(893-0x1fc)))do n=-n n=(4069643)while(0x1ef-257)>=m do n=-n n=(3544640)while(0x9a7a/169)>=m do n=-n n=(14435253)while m<=(-40+0x110)do n=-n n=(1203150)while m>(-#'black mess more like white mesa'+(587-0x145))do n=-n C[e[g]]=d[e[s]];break end while(n)/((-#"tonka"+(0x1a1+-22)))==3085 do local n;n=e[s]d[n](p(d,n+y,e[f]))l=l+o;e=a[l];d[e[b]][e[g]]=e[A];l=l+o;e=a[l];d[e[b]][e[w]]=d[e[v]];l=l+o;e=a[l];d[e[h]]=r[e[t]];l=l+o;e=a[l];d[e[s]]=d[e[x]][e[B]];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[k]][e[u]]=d[e[B]];break end;break;end while 3969==(n)/((152754/0x2a))do n=(1688197)while m>((26136/0x6c)+-#'pinkerton')do n=-n local n;d[e[s]]=e[g];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[c]][e[u]]=d[e[P]];l=l+o;e=a[l];d[e[h]]=r[e[x]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[H]];l=l+o;e=a[l];d[e[b]][e[f]]=d[e[H]];l=l+o;e=a[l];d[e[s]][e[t]]=e[P];l=l+o;e=a[l];d[e[c]]=r[e[w]];break end while(n)/((3731-0x762))==917 do local n;local x;local h,w;local b;local n;d[e[i]]=r[e[f]];l=l+o;e=a[l];n=e[c];b=d[e[g]];d[n+1]=b;d[n]=b[e[P]];l=l+o;e=a[l];n=e[i]h,w=N(d[n](d[n+y]))F=w+n-o x=0;for e=n,F do x=x+o;d[e]=h[x];end;l=l+o;e=a[l];n=e[k]h={d[n](p(d,n+1,F))};x=0;for e=n,e[P]do x=x+o;d[e]=h[x];end l=l+o;e=a[l];l=e[t];break end;break;end break;end while 2014==(n)/((-#"Dick"+(0xe21-1853)))do n=(298284)while(25252/(-82+0xbd))>=m do n=-n n=(5043000)while m>(0x153+-104)do n=-n local n;n=e[k]d[n](p(d,n+y,e[x]))l=l+o;e=a[l];d[e[k]][e[f]]=e[P];l=l+o;e=a[l];d[e[c]][e[g]]=d[e[v]];l=l+o;e=a[l];d[e[s]]=r[e[f]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];d[e[c]]=e[t];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[i]][e[x]]=d[e[I]];break end while(n)/((4218-0x878))==2460 do local n;n=e[k]d[n](p(d,n+y,e[u]))l=l+o;e=a[l];d[e[s]][e[w]]=e[I];l=l+o;e=a[l];d[e[i]][e[g]]=d[e[H]];l=l+o;e=a[l];d[e[b]]=r[e[g]];l=l+o;e=a[l];d[e[s]]=d[e[g]][e[B]];l=l+o;e=a[l];d[e[k]]=e[t];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[b]][e[w]]=d[e[v]];break end;break;end while(n)/((-#[[ILoveBlowJobs]]+(0x108+-39)))==1407 do n=(1473708)while m>(-0x2d+282)do n=-n d[e[h]]=d[e[w]][e[B]];break end while 2901==(n)/((-70+0x242))do local n;d[e[i]]=d[e[t]][e[A]];l=l+o;e=a[l];d[e[h]]=e[g];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];d[e[c]]=e[t];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[b]][e[f]]=d[e[B]];l=l+o;e=a[l];d[e[k]]=r[e[u]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[v]];l=l+o;e=a[l];d[e[b]]=e[x];break end;break;end break;end break;end while(n)/((-#[[dick cheese]]+(3093+-0x53)))==1357 do n=(333144)while((603-0x153)+-#'IPIPEH ILOVE YOU AAAAA')>=m do n=-n n=(3645880)while m<=(0x235-325)do n=-n n=(3307554)while(0x211-290)<m do n=-n local l=e[h]local a={d[l]()};local n=e[A];local e=0;for l=l,n do e=e+o;d[l]=a[e];end break end while 3603==(n)/((968+-0x32))do local o=e[t];local l=d[o]for e=o+1,e[I]do l=l..d[e];end;d[e[c]]=l;break end;break;end while 1796==(n)/((-#"Hi skid"+((-0x7c+4316)-2155)))do n=(329928)while m>(0x8972/146)do n=-n local l=e[b]local a,e=N(d[l](p(d,l+1,e[w])))F=e+l-1 local e=0;for l=l,F do e=e+o;d[l]=a[e];end;break end while(n)/(((-0x77+849)+-#"IPIPEH ILOVE YOU AAAAA"))==466 do local r;local n;d[e[i]]=e[t];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];n=e[k]d[n]=d[n](p(d,n+o,e[t]))l=l+o;e=a[l];d[e[i]][e[g]]=d[e[H]];l=l+o;e=a[l];d[e[h]][e[x]]=e[v];l=l+o;e=a[l];d[e[h]][e[g]]=e[B];l=l+o;e=a[l];d[e[k]][e[t]]=e[P];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[P]];l=l+o;e=a[l];n=e[i];r=d[e[w]];d[n+1]=r;d[n]=r[e[P]];break end;break;end break;end while 2644==(n)/(((0x2fcc/92)+-#[[test123]]))do n=(7601552)while m<=(-#"420Script Was Here"+(647-0x181))do n=-n n=(5695030)while(-0x6f+354)<m do n=-n local l=e[b]local n={d[l]()};local a=e[I];local e=0;for l=l,a do e=e+o;d[l]=n[e];end break end while(n)/((-0x39+2587))==2251 do d[e[h]]=d[e[w]][e[H]];l=l+o;e=a[l];d[e[s]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[A]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[I]];l=l+o;e=a[l];if(d[e[b]]~=d[e[B]])then l=l+y;else l=e[w];end;break end;break;end while 2026==(n)/((0x1db8-3856))do n=(2065944)while m>(-#"xenny its znugget please respond"+((0x346-467)+-0x5e))do n=-n local L;local W,C;local n;local m;m={e,d};m[T][m[y][k]]=m[T][m[o][f]]+m[y][P];l=l+o;e=a[l];n=e[i]W,C=N(d[n](p(d,n+1,e[w])))F=C+n-1 L=0;for e=n,F do L=L+o;d[e]=W[L];end;l=l+o;e=a[l];n=e[i]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[i]]=r[e[g]];l=l+o;e=a[l];d[e[k]]=r[e[w]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[H]];l=l+o;e=a[l];d[e[b]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[P]];l=l+o;e=a[l];m={e,d};m[T][m[y][h]]=m[T][m[o][f]]+m[y][B];l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[B]];l=l+o;e=a[l];d[e[k]]=r[e[w]];l=l+o;e=a[l];d[e[i]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[c]]=d[e[g]]-e[I];l=l+o;e=a[l];n=e[b]W,C=N(d[n](p(d,n+1,e[x])))F=C+n-1 L=0;for e=n,F do L=L+o;d[e]=W[L];end;l=l+o;e=a[l];n=e[k]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[b]]=r[e[x]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[h]]=d[e[t]]-e[I];l=l+o;e=a[l];d[e[b]]=r[e[g]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[A]];l=l+o;e=a[l];d[e[h]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[I]];l=l+o;e=a[l];m={e,d};m[T][m[y][i]]=m[T][m[o][f]]+m[y][P];l=l+o;e=a[l];n=e[c]W,C=N(d[n](p(d,n+1,e[x])))F=C+n-1 L=0;for e=n,F do L=L+o;d[e]=W[L];end;l=l+o;e=a[l];n=e[s]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[h]]=r[e[w]];l=l+o;e=a[l];d[e[s]]=r[e[u]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[B]];l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[b]]=d[e[g]][e[P]];l=l+o;e=a[l];d[e[b]]=d[e[w]]-e[P];l=l+o;e=a[l];d[e[h]]=r[e[w]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[I]];l=l+o;e=a[l];d[e[b]]=r[e[u]];l=l+o;e=a[l];d[e[k]]=d[e[t]][e[H]];l=l+o;e=a[l];d[e[b]]=d[e[f]]-e[A];l=l+o;e=a[l];n=e[h]W,C=N(d[n](p(d,n+1,e[t])))F=C+n-1 L=0;for e=n,F do L=L+o;d[e]=W[L];end;l=l+o;e=a[l];n=e[k]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[i]]=r[e[w]];l=l+o;e=a[l];d[e[s]]=r[e[w]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[A]];l=l+o;e=a[l];m={e,d};m[T][m[y][h]]=m[T][m[o][t]]+m[y][A];l=l+o;e=a[l];d[e[k]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[B]];l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[v]];l=l+o;e=a[l];m={e,d};m[T][m[y][h]]=m[T][m[o][x]]+m[y][H];l=l+o;e=a[l];n=e[i]W,C=N(d[n](p(d,n+1,e[w])))F=C+n-1 L=0;for e=n,F do L=L+o;d[e]=W[L];end;l=l+o;e=a[l];n=e[i]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[k]]=r[e[x]];l=l+o;e=a[l];d[e[k]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[I]];l=l+o;e=a[l];d[e[h]]=r[e[t]];l=l+o;e=a[l];d[e[k]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[h]]=d[e[w]]-e[v];l=l+o;e=a[l];d[e[h]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[P]];l=l+o;e=a[l];d[e[i]]=r[e[w]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[B]];l=l+o;e=a[l];m={e,d};m[T][m[y][s]]=m[T][m[o][t]]+m[y][B];l=l+o;e=a[l];n=e[k]W,C=N(d[n](p(d,n+1,e[f])))F=C+n-1 L=0;for e=n,F do L=L+o;d[e]=W[L];end;l=l+o;e=a[l];n=e[i]d[n](p(d,n+y,F))l=l+o;e=a[l];d[e[c]]=r[e[w]];l=l+o;e=a[l];d[e[b]]=r[e[w]];l=l+o;e=a[l];d[e[k]]=d[e[t]][e[v]];l=l+o;e=a[l];d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=d[e[t]][e[A]];l=l+o;e=a[l];m={e,d};m[T][m[y][i]]=m[T][m[o][f]]+m[y][B];l=l+o;e=a[l];d[e[k]]=r[e[x]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[h]]=r[e[g]];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[A]];l=l+o;e=a[l];m={e,d};m[T][m[y][i]]=m[T][m[o][x]]+m[y][H];l=l+o;e=a[l];n=e[c]W,C=N(d[n](p(d,n+1,e[t])))F=C+n-1 L=0;for e=n,F do L=L+o;d[e]=W[L];end;break end while 1459==(n)/((((0x63308/140)-0x5bc)+-#"iam u Furry iPipeh"))do d[e[c]]=C[e[f]];break end;break;end break;end break;end break;end while(n)/(((348193/0xbf)+-#"pinkerton"))==631 do n=(5139444)while(-#"BluntMan420 Was Here"+(0x638a/93))>=m do n=-n n=(2250388)while m<=(((-85+0x2a3)-0x135)+-#"black mess more like white mesa")do n=-n n=(4531800)while(0x21d-293)>=m do n=-n n=(15606)while m>(0x228-(-#[[me big peepee]]+(-0x3c+378)))do n=-n local e={d,e};e[y][e[T][h]]=e[o][e[T][A]]+e[y][e[T][f]];break end while(n)/(((738-0x1aa)+-#[[weezer]]))==51 do local n;local b;local B,A;local m;local n;d[e[i]]=r[e[t]];l=l+o;e=a[l];d[e[k]]=r[e[g]];l=l+o;e=a[l];n=e[k];m=d[e[g]];d[n+1]=m;d[n]=m[e[v]];l=l+o;e=a[l];d[e[c]]=e[x];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[s]]=d[e[f]][e[I]];l=l+o;e=a[l];n=e[c];m=d[e[u]];d[n+1]=m;d[n]=m[e[H]];l=l+o;e=a[l];n=e[s]B,A=N(d[n](d[n+y]))F=A+n-o b=0;for e=n,F do b=b+o;d[e]=B[b];end;l=l+o;e=a[l];n=e[k]B={d[n](p(d,n+1,F))};b=0;for e=n,e[P]do b=b+o;d[e]=B[b];end l=l+o;e=a[l];l=e[w];break end;break;end while 3320==(n)/((0x5b7+(-#[[notbelugafan was here]]+(-0x4ae5/249))))do n=(9249297)while(-#'IPIPEH I WANNA FUCK WITH YOU'+(((471+-0x67)+-#[[black mess more like white mesa]])+-0x3c))<m do n=-n local m;local v,I;local n;d[e[i]]();l=l+o;e=a[l];d[e[i]]=C[e[f]];l=l+o;e=a[l];d[e[k]]=r[e[w]];l=l+o;e=a[l];d[e[b]]=d[e[x]][e[P]];l=l+o;e=a[l];d[e[i]]=r[e[t]];l=l+o;e=a[l];d[e[i]]=d[e[g]][e[B]];l=l+o;e=a[l];d[e[b]]=e[u];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];n=e[k]v,I=N(d[n](p(d,n+1,e[g])))F=I+n-1 m=0;for e=n,F do m=m+o;d[e]=v[m];end;l=l+o;e=a[l];n=e[i]d[n]=d[n](p(d,n+o,F))l=l+o;e=a[l];d[e[s]]=r[e[u]];l=l+o;e=a[l];d[e[c]]=d[e[g]][e[B]];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[A]];l=l+o;e=a[l];d[e[i]]=e[f];l=l+o;e=a[l];n=e[c]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[u]))l=l+o;e=a[l];d[e[b]]=d[e[u]]*d[e[H]];l=l+o;e=a[l];d[e[b]][e[g]]=d[e[P]];break end while 2427==(n)/((-#'Fuck nigger wank shit dipshit cunt bullshit fuckyou hoe lol'+(54180/0xe)))do local i;local n;d[e[k]]=e[x];l=l+o;e=a[l];d[e[s]]=e[g];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];n=e[s]d[n]=d[n](p(d,n+o,e[w]))l=l+o;e=a[l];d[e[b]][e[g]]=d[e[A]];l=l+o;e=a[l];d[e[b]][e[x]]=e[P];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[H]];l=l+o;e=a[l];n=e[c];i=d[e[f]];d[n+1]=i;d[n]=i[e[v]];break end;break;end break;end while(n)/((-#[[Never gonna give u up]]+((1925+-0x13)-987)))==2506 do n=(10650453)while(0x21f-291)>=m do n=-n n=(5044692)while m>(0x7c85/127)do n=-n d[e[s]]=r[e[x]];break end while(n)/((-#[[sinsploit]]+((-0x12+-26)+2254)))==2292 do local n;d[e[c]]=d[e[x]][e[P]];l=l+o;e=a[l];d[e[s]]=e[u];l=l+o;e=a[l];d[e[s]]=e[f];l=l+o;e=a[l];d[e[s]]=e[g];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];n=e[c]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[s]][e[g]]=d[e[A]];l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];d[e[s]]=d[e[f]][e[P]];l=l+o;e=a[l];d[e[k]]=e[f];break end;break;end while(n)/(((0x1f4a-4030)+-#"black mess more like white mesa"))==2697 do n=(4952272)while(599-0x15a)<m do n=-n local e={e,d};e[T][e[y][h]]=e[T][e[o][x]]+e[y][I];break end while 3284==(n)/((-68+0x628))do local l=e[b]local n={d[l](p(d,l+1,F))};local a=0;for e=l,e[I]do a=a+o;d[e]=n[a];end break end;break;end break;end break;end while(n)/((((937560/0xf)/0x1a)+-#'iam u Furry iPipeh'))==2154 do n=(15579980)while((-37+-0x45)+0x16c)>=m do n=-n n=(981020)while((0x14d+-73)+-#'test')>=m do n=-n n=(1577125)while m>(0x276-((-64+0x1c0)+-#'sinsploit'))do n=-n local m;local n;d[e[i]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[P]];l=l+o;e=a[l];d[e[c]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[i]][e[w]]=e[I];l=l+o;e=a[l];d[e[c]]=r[e[g]];l=l+o;e=a[l];d[e[c]]=e[w];l=l+o;e=a[l];n=e[b]d[n](d[n+y])l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[i]]=d[e[g]][e[I]];l=l+o;e=a[l];d[e[b]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[k]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[c]]=d[e[t]][e[v]];l=l+o;e=a[l];d[e[i]]=d[e[w]][e[I]];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[b]]=r[e[f]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];n=e[b]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];m={d,e};m[y][m[T][h]]=m[o][m[T][A]]+m[y][m[T][u]];l=l+o;e=a[l];d[e[i]][e[x]]=d[e[I]];l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[A]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[I]];l=l+o;e=a[l];d[e[s]]=d[e[u]][e[H]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[B]];l=l+o;e=a[l];d[e[k]][e[w]]=e[I];l=l+o;e=a[l];d[e[h]]=r[e[f]];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];n=e[i]d[n](d[n+y])break end while 3875==(n)/(((-16+-0x6a)+0x211))do local n;d[e[h]]=d[e[u]][e[A]];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];d[e[c]]=e[g];l=l+o;e=a[l];d[e[s]]=e[t];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[g]))l=l+o;e=a[l];d[e[h]][e[t]]=d[e[v]];l=l+o;e=a[l];d[e[k]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[k]]=e[g];break end;break;end while 1810==(n)/(((94734/0xab)+-#'Rivers Cuomo'))do n=(7857927)while m>(582-(0x182+-61))do n=-n d[e[c]]=(e[u]~=0);l=l+y;break end while 3451==(n)/((-#"free trojan"+(4683-0x95b)))do local r;local n;d[e[i]]=e[u];l=l+o;e=a[l];d[e[b]]=e[f];l=l+o;e=a[l];d[e[c]]=e[f];l=l+o;e=a[l];n=e[h]d[n]=d[n](p(d,n+o,e[f]))l=l+o;e=a[l];d[e[k]][e[x]]=d[e[v]];l=l+o;e=a[l];d[e[c]][e[g]]=e[H];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[I]];l=l+o;e=a[l];n=e[s];r=d[e[w]];d[n+1]=r;d[n]=r[e[H]];break end;break;end break;end while(n)/((0x1e4c-(-52+0xf66)))==4030 do n=(1515652)while(-#[[no thanks]]+(-0x46+339))>=m do n=-n n=(2099785)while m>(-#[[iam u Furry iPipeh]]+(400+(-0x4e+-45)))do n=-n d[e[b]]();l=l+o;e=a[l];d[e[i]]=r[e[t]];l=l+o;e=a[l];d[e[k]]=d[e[f]][e[v]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[i]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[c]]=d[e[x]][e[A]];l=l+o;e=a[l];d[e[i]]=C[e[w]];l=l+o;e=a[l];d[e[k]]=d[e[g]][e[H]];l=l+o;e=a[l];d[e[i]][e[w]]=d[e[B]];l=l+o;e=a[l];l=e[w];break end while(n)/((-#'Bong'+(986+-0x15)))==2185 do if(d[e[b]]~=d[e[B]])then l=l+y;else l=e[u];end;break end;break;end while 2876==(n)/((1099-0x23c))do n=(519675)while(31059/0x77)>=m do n=-n local n;d[e[s]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[A]];l=l+o;e=a[l];d[e[h]]=e[t];l=l+o;e=a[l];n=e[h]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[h]]=r[e[x]];l=l+o;e=a[l];d[e[b]]=d[e[u]][e[H]];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];n=e[s]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[c]]=r[e[x]];l=l+o;e=a[l];d[e[k]]=d[e[w]][e[I]];l=l+o;e=a[l];d[e[i]]=e[u];l=l+o;e=a[l];n=e[s]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[i]]=r[e[f]];l=l+o;e=a[l];d[e[i]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[k]]=e[f];l=l+o;e=a[l];n=e[i]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[b]]=r[e[g]];l=l+o;e=a[l];d[e[s]]=d[e[t]][e[P]];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];n=e[s]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[h]]=r[e[x]];l=l+o;e=a[l];d[e[h]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[i]]=e[x];l=l+o;e=a[l];n=e[i]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[s]]=r[e[u]];l=l+o;e=a[l];d[e[k]]=d[e[x]][e[H]];l=l+o;e=a[l];d[e[h]]=e[w];l=l+o;e=a[l];n=e[i]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[h]]=r[e[t]];l=l+o;e=a[l];d[e[h]]=d[e[g]][e[A]];l=l+o;e=a[l];d[e[k]]=e[g];l=l+o;e=a[l];n=e[h]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[s]]=r[e[u]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[B]];l=l+o;e=a[l];d[e[i]]=e[g];l=l+o;e=a[l];n=e[s]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[b]]=r[e[u]];l=l+o;e=a[l];d[e[h]]=d[e[t]][e[v]];l=l+o;e=a[l];d[e[b]]=e[t];l=l+o;e=a[l];n=e[k]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[s]]=r[e[x]];l=l+o;e=a[l];d[e[c]]=d[e[f]][e[H]];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];n=e[k]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[c]]=r[e[f]];l=l+o;e=a[l];d[e[h]]=d[e[x]][e[P]];l=l+o;e=a[l];d[e[k]]=e[w];l=l+o;e=a[l];n=e[b]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[h]]=r[e[t]];l=l+o;e=a[l];d[e[h]]=d[e[w]][e[B]];l=l+o;e=a[l];d[e[b]]=e[f];l=l+o;e=a[l];n=e[s]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[c]]=r[e[u]];l=l+o;e=a[l];d[e[s]]=d[e[w]][e[H]];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];n=e[i]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[s]]=r[e[t]];l=l+o;e=a[l];d[e[k]]=d[e[w]][e[v]];l=l+o;e=a[l];d[e[b]]=e[x];l=l+o;e=a[l];n=e[i]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[h]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[u]][e[I]];l=l+o;e=a[l];d[e[s]]=e[x];l=l+o;e=a[l];n=e[h]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[i]]=r[e[x]];l=l+o;e=a[l];d[e[i]]=d[e[u]][e[v]];l=l+o;e=a[l];d[e[b]]=e[w];l=l+o;e=a[l];n=e[h]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[c]]=r[e[w]];l=l+o;e=a[l];d[e[b]]=d[e[w]][e[H]];l=l+o;e=a[l];d[e[h]]=e[u];l=l+o;e=a[l];n=e[s]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[k]]=r[e[f]];l=l+o;e=a[l];d[e[k]]=d[e[t]][e[v]];l=l+o;e=a[l];d[e[i]]=e[t];l=l+o;e=a[l];n=e[c]d[n]=d[n](d[n+y])l=l+o;e=a[l];d[e[i]]=r[e[u]];l=l+o;e=a[l];d[e[b]]=d[e[f]][e[I]];l=l+o;e=a[l];d[e[c]]=e[g];l=l+o;e=a[l];n=e[k]d[n]=d[n](d[n+y])break;end while(n)/((-#[[looadstring]]+(3245-0x663)))==325 do n=(425568)while m>(587-0x145)do n=-n d[e[b]]=(e[g]~=0);break end while(n)/((0x2520/54))==2418 do local n;local x;local b,m;local k;local n;d[e[h]]=r[e[g]];l=l+o;e=a[l];d[e[s]]=r[e[f]];l=l+o;e=a[l];d[e[i]]=d[e[w]][e[P]];l=l+o;e=a[l];n=e[i];k=d[e[t]];d[n+1]=k;d[n]=k[e[H]];l=l+o;e=a[l];n=e[c]b,m=N(d[n](d[n+y]))F=m+n-o x=0;for e=n,F do x=x+o;d[e]=b[x];end;l=l+o;e=a[l];n=e[s]b={d[n](p(d,n+1,F))};x=0;for e=n,e[B]do x=x+o;d[e]=b[x];end l=l+o;e=a[l];l=e[u];break end;break;end break;end break;end break;end break;end break;end break;end break;end l=l+o;end;end);end;return S(E(),{},j())()end)_msec({[(0x176-245)]='\115\116'..(function(e)return(e and'ټقحڪآنكنئددضسټ')or'\114\105'or'\120\58'end)((0x4ce/246)==(1140/0xbe))..'\110g',["زضس؃دڝدڪدؠڪئنآس"]='\108\100'..(function(e)return(e and'ئكؠڝزنآجس')or'\101\120'or'\119\111'end)((0x78+-115)==(0x6a-(284-0xb8)))..'\112',["ضنحدڪئكنقټق"]=(function(e)return(e and'ټدآآنئسڝڝئنسق')and'\98\121'or'\100\120'end)((0x4a-69)==(82-0x4d))..'\116\101',["كح؃ؠؠقڝنجڝڪح"]='\99'..(function(e)return(e and'س؃حآ؃سحڪ')and'\90\19\157'or'\104\97'end)((55-0x32)==((-46+0x69)-0x38))..'\114',[(1085-0x235)]='\116\97'..(function(e)return(e and'؃ئئجحڪڪزقسټجسجټڝؠ؃')and'\64\113'or'\98\108'end)((42-0x24)==((123+-0x6f)+-#"require"))..'\101',["آسئئجسقجڪټضزټټآؠضك"]=(function(e)return(e and'ئڝڪئحقكزآڝززڝآؠجټجئ')or'\115\117'or'\78\107'end)((-#'deobfuscated'+(0x45-54))==(-#'I like gargling cum'+(202-0x98)))..'\98',["قسؠن؃سج؃كنؠټقټټآ"]='\99\111'..(function(e)return(e and'سڪقڝنندئدزجحټقنآنآن')and'\110\99'or'\110\105\103\97'end)((147-0x74)==((5289/0x29)-98))..'\97\116',[(-#[[pinkerton]]+(18356/0x1a))]=(function(e,l)return(e and'نكآڝضئض؃ؠټزڪز')and'\48\159\158\188\10'or'\109\97'end)(((0x71-100)+-#"test 123")==(33-0x1b))..'\116\104',[(0x561+-24)]=(function(l,e)return((101-0x60)==(0x57-84)and'\48'..'\195'or l..((not'\20\95\69'and'\90'..'\180'or e)))or'\199\203\95'end),["جئكقكآؠئئجضضآضنجك"]='\105\110'..(function(e,l)return(e and'ئڪزكټنضن')and'\90\115\138\115\15'or'\115\101'end)((0x4d-72)==((250-0xae)+-#'guys Please proceed to translate D to Sinhala'))..'\114\116',["دضز؃دضججضټسسدق؃ئ"]='\117\110'..(function(e,l)return(e and'ڝڝن؃ټسجقزجدكآ')or'\112\97'or'\20\38\154'end)((0x33-46)==(-#[[xenny its znugget please respond]]+(-97+0xa0)))..'\99\107',["ڪنڝ؃جآؠؠسض"]='\115\101'..(function(e)return(e and'قآحدټزنجنقئآڪڝؠحؠ')and'\110\112\99\104'or'\108\101'end)(((49-0x4d)+33)==(0xb62/94))..'\99\116',["ټدڪججڝزئزقسآحڝس"]='\116\111\110'..(function(e,l)return(e and'ڪقڝآټ؃ټ؃كنكج؃نق')and'\117\109\98'or'\100\97\120\122'end)((108-0x67)==(((-0x22-3)+-#[[fish was here]])+0x37))..'\101\114'},{["جكندحكآئټڪټؠ"]=((getfenv)or(function()return(_ENV)end))},((getfenv)or(function()return(_ENV)end))()) end)()



   end,
})
Refresh() -- 初始刷新玩家列表
Rayfield:Notify({Title = "加载成功！", Content = "欢迎使用91缝合脚本！", Duration = 5})