local library = {}

function library:CreateWindow(text, gamename)
	local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
	syn.protect_gui(gui)
	local titlebar = Instance.new("Frame", gui)
	local title = Instance.new("TextLabel", titlebar)
	local curgame = Instance.new("TextLabel", titlebar)
	local mainframe = Instance.new("Frame", titlebar)
	local contentholder = Instance.new("Frame", mainframe)
	local uicorner = Instance.new("UICorner", contentholder)
	local rsection = Instance.new("Frame", contentholder)
	local lsection = Instance.new("Frame", contentholder)
	local ruicorner = Instance.new("UICorner", rsection)
	local luicorner = Instance.new("UICorner", lsection)
	local ruilist = Instance.new("UIListLayout", rsection)
	local luilist = Instance.new("UIListLayout", lsection)
	local rtoppadding = Instance.new("Frame", rsection)
	local ltoppadding = Instance.new("Frame", lsection)

	titlebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	titlebar.BorderSizePixel = 0
	titlebar.Position = UDim2.new(0.368, 0, 0.304, 0)
	titlebar.Size = UDim2.new(0, 448, 0, 47)
	
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0.02, 0, 0, 0)
	title.Size = UDim2.new(0, 91, 0, 46)
	title.Text = text
	title.TextColor3 = Color3.fromRGB(235, 235, 235)
	title.Font = Enum.Font.RobotoMono
	title.TextSize = 22
	
	curgame.BackgroundTransparency = 1
	curgame.Position = UDim2.new(0.283, 0, 0, 0)
	curgame.Size = UDim2.new(0, 320, 0, 46)
	curgame.Text = "game: "..gamename
	curgame.TextColor3 = Color3.fromRGB(235, 235, 235)
	curgame.Font = Enum.Font.RobotoMono
	curgame.TextSize = 22
	curgame.TextXAlignment = Enum.TextXAlignment.Left

	mainframe.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
	mainframe.BorderSizePixel = 0
	mainframe.Position = UDim2.new(-0, 0, 0.998, 0)
	mainframe.Size = UDim2.new(0, 448, 0, 373)

	contentholder.AnchorPoint = Vector2.new(0.5, 0.5)
	contentholder.BackgroundColor3 = Color3.fromRGB(84, 84, 84)
	contentholder.BackgroundTransparency = 0.9
	contentholder.BorderSizePixel = 0
	contentholder.Position = UDim2.new(0.5, 0, 0.5, 0)
	contentholder.Size = UDim2.new(0, 428, 0, 353)

	uicorner.CornerRadius = UDim.new(0, 8)

	rsection.AnchorPoint = Vector2.new(0.5, 0.5)
	rsection.BackgroundColor3 = Color3.fromRGB(84, 84, 84)
	rsection.BackgroundTransparency = 0.9
	rsection.BorderSizePixel = 0
	rsection.Position = UDim2.new(0.277, 0, 0.5, 0)
	rsection.Size = UDim2.new(0, 180, 0, 296)

	lsection.AnchorPoint = Vector2.new(0.5, 0.5)
	lsection.BackgroundColor3 = Color3.fromRGB(84, 84, 84)
	lsection.BackgroundTransparency = 0.9
	lsection.BorderSizePixel = 0
	lsection.Position = UDim2.new(0.722, 0, 0.5, 0)
	lsection.Size = UDim2.new(0, 180, 0, 296)

	ruicorner.CornerRadius = UDim.new(0, 8)

	luicorner.CornerRadius = UDim.new(0, 8)
	
	ruilist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ruilist.Padding = UDim.new(0, 5)
	
	luilist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	luilist.Padding = UDim.new(0, 5)
	
	rtoppadding.BackgroundTransparency = 1
	rtoppadding.Size = UDim2.new(0, 100, 0, 8)
	
	ltoppadding.BackgroundTransparency = 1
	ltoppadding.Size = UDim2.new(0, 100, 0, 8)
	
	local sections = {}
	
	function sections:AddToggle(text, default, section, callback)
		local togglesection
		if section == "right" then
			togglesection = rsection
		else
			togglesection = lsection
		end
		
		local toggled = default
		
		local toggleframe = Instance.new("Frame", togglesection)
		local toggleuicorner = Instance.new("UICorner", toggleframe)
		local togglebutton = Instance.new("TextButton", toggleframe)
		
		togglebutton.MouseButton1Click:Connect(function()
			toggled = not toggled
			
			callback(toggled)
			
			if toggled then
				togglebutton.BackgroundColor3 = Color3.fromRGB(132, 189, 112)
			else
				togglebutton.BackgroundColor3 = Color3.fromRGB(84, 84, 84)
			end
		end)
		
		local togglelabel = Instance.new("TextLabel", toggleframe)
		local togglebuttonuicorner = Instance.new("UICorner", togglebutton)
		
		toggleframe.BackgroundColor3 = Color3.fromRGB(84, 84, 84)
		toggleframe.BackgroundTransparency = 0.8
		toggleframe.BorderSizePixel = 0
		toggleframe.Size = UDim2.new(0, 160, 0, 35)
		
		toggleuicorner.CornerRadius = UDim.new(0, 8)
		
		togglebutton.BackgroundColor3 = Color3.fromRGB(84, 84, 84)
		togglebutton.BorderSizePixel = 0
		togglebutton.Position = UDim2.new(0.038, 0, 0.143, 0)
		togglebutton.Size = UDim2.new(0, 25, 0, 25)
		togglebutton.Font = Enum.Font.SourceSans
		togglebutton.Text = ""
		
		togglelabel.BackgroundTransparency = 1
		togglelabel.Position = UDim2.new(0.262, 0, 0, 0)
		togglelabel.Size = UDim2.new(0, 118, 0, 35)
		togglelabel.Font = Enum.Font.RobotoMono
		togglelabel.Text = text
		togglelabel.TextColor3 = Color3.fromRGB(222, 222, 222)
		togglelabel.TextSize = 15
		togglelabel.TextXAlignment = Enum.TextXAlignment.Left
		
		togglebuttonuicorner.CornerRadius = UDim.new(0, 8)
	end
	
	return sections
end
local window = library:CreateWindow("v-hub", "baseplate")

window:AddToggle("Abc", false, "right", function(toggled)
    if toggled then
        print("Toggled")
    else
        print("Untoggled!")
    end
end)

window:AddToggle("def", false, "left", function(toggled)
    if toggled then
        print("1Toggled")
    else
        print("1Untoggled!")
    end
end)
return library
