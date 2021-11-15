-- /* Services
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Camera = game.Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

shared.AimLockSettings = {
    TeamCheck = true,
    AimlockEnabled = false,
    AimlockSensitivity = 0.1,
    AimPart = "Head", -- /* Options: Head, Body,
    FOV = 50,
    FOV_Color = Color3.fromRGB(255, 255, 255),
    FOV_Rainbow = false,
    FOV_RainbowColor = Color3.fromHSV(1,1,1), -- <-- DO NOT EDIT
    WallCheck = true,
    SilentAimEnabled = false,
    FOV_Visible = true
}

local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Visible = true
FOV_Circle.Thickness = 1
FOV_Circle.Filled = false
FOV_Circle.Color = shared.AimLockSettings.FOV_Color

local aiming = false

local function GetClosestPlayer()
	local MaximumDistance = shared.AimLockSettings.FOV
	local Target = nil

	for _, v in next, Players:GetPlayers() do
		if v.Name ~= LocalPlayer.Name then
			if shared.TeamCheck == true then
				if v.Team ~= LocalPlayer.Team then
					if v.Character ~= nil then
						if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
							if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
								local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
								local VectorDistance = (Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
								
								if VectorDistance < MaximumDistance then
									Target = v
								end
							end
						end
					end
				end
			else
				if v.Character ~= nil then
					if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
						if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
							local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
							local VectorDistance = (Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
							
							if VectorDistance < MaximumDistance then
								Target = v
							end
						end
					end
				end
			end
		end
	end

	return Target
end

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

local function isBehindWall(x)
    
    if not shared.AimLockSettings.WallCheck then
        return false
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    raycastParams.IgnoreWater = true
    local raycastResult = workspace:Raycast(game.Players.LocalPlayer.Character.Head.Position, (x.Position-game.Players.LocalPlayer.Character.Head.Position).Unit*9e9, raycastParams)
    -- Interpret the result
    if raycastResult then
        if raycastResult.Instance:IsDescendantOf(x.Parent) then 
            return false 
        end
    end
    return true
end

local TargetPart = nil
local Target = nil

local old; old = hookmetamethod(game, "__index", function(self, idx)
    if (idx == 'Hit' and math.random(1,1) == 1) and shared.AimLockSettings.SilentAimEnabled then
        return CFrame.new(TargetPart.Position)
    end
    return old(self, idx) 
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if shared.AimLockSettings.FOV_Visible then
        FOV_Circle.Visible = true
    else
        FOV_Circle.Visible = false
    end
    FOV_Circle.Radius = shared.AimLockSettings.FOV
    if shared.AimLockSettings.FOV_Rainbow then
        FOV_Circle.Color = shared.AimLockSettings.FOV_RainbowColor
        -- /* SoonTM....
        local t = 5; --how long does it take to go through the rainbow
        
        local hue = tick() % t / t
        local color = Color3.fromHSV(hue, 1, 1)
        --> set the color
        -- Thx for Devforum <- Credits
        FOV_Circle.Color = color
    else
        FOV_Circle.Color = shared.AimLockSettings.FOV_Color
    end

    local mouse = UIS:GetMouseLocation()

    FOV_Circle.Position = Vector2.new(mouse.X, mouse.Y)

    Target = GetClosestPlayer()
    
    local HeadVec, head_onscreen = Camera:WorldToViewportPoint(Target.Character.Head.CFrame.p)
    local BodyVec, body_onscreen = Camera:WorldToViewportPoint(Target.Character.HumanoidRootPart.CFrame.p)
    if shared.AimLockSettings.AimPart == "Head" then
        TargetPart = Target.Character["Head"]
        if aiming and shared.AimLockSettings.AimlockEnabled and head_onscreen and not isBehindWall(Target.Character.Head) then
            mousemoverel((HeadVec.X - mouse.X) * shared.AimLockSettings.AimlockSensitivity, (HeadVec.Y - mouse.Y) * shared.AimLockSettings.AimlockSensitivity)
        end
    elseif shared.AimLockSettings.AimPart == "Body" then
        TargetPart = Target.Character["HumanoidRootPart"]
        if aiming and shared.AimLockSettings.AimlockEnabled and body_onscreen and not isBehindWall(Target.Character.Head) then
            mousemoverel((BodyVec.X - mouse.X) * shared.AimLockSettings.AimlockSensitivity, (BodyVec.Y - mouse.Y) * shared.AimLockSettings.AimlockSensitivity)
        end
    end
end)
