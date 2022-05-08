-- SyntaxCMD
-- // Variables
local ws = game:GetService("Workspace")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local hs = game:GetService("HttpService")
local plrs = game:GetService("Players")
local stats = game:GetService("Stats")
-- UI Variables
local library = {
    drawings = {output = {Log = {Count = 0, Position = {},},},},
    hidden = {},
    connections = {},
    pointers = {},
    began = {},
    ended = {},
    changed = {},
    folders = {},
    shared = {
        initialized = false,
        fps = 0,
        ping = 0
    }
}
-- // Utility Functions

local utility = {} do
    function utility:Size(xScale,xOffset,yScale,yOffset,instance)
        if instance then
            local x = xScale*instance.Size.x+xOffset
            local y = yScale*instance.Size.y+yOffset
            --
            return Vector2.new(x,y)
        else
            local vx,vy = ws.CurrentCamera.ViewportSize.x,ws.CurrentCamera.ViewportSize.y
            --
            local x = xScale*vx+xOffset
            local y = yScale*vy+yOffset
            --
            return Vector2.new(x,y)
        end
    end
    --
    function utility:Position(xScale,xOffset,yScale,yOffset,instance)
        if instance then
            local x = instance.Position.x+xScale*instance.Size.x+xOffset
            local y = instance.Position.y+yScale*instance.Size.y+yOffset
            --
            return Vector2.new(x,y)
        else
            local vx,vy = ws.CurrentCamera.ViewportSize.x,ws.CurrentCamera.ViewportSize.y
            --
            local x = xScale*vx+xOffset
            local y = yScale*vy+yOffset
            --
            return Vector2.new(x,y)
        end
    end
    --
	function utility:Create(instanceType, instanceOffset, instanceProperties, instanceParent)
        local instanceType = instanceType or "Frame"
        local instanceOffset = instanceOffset or {Vector2.new(0,0)}
        local instanceProperties = instanceProperties or {}
        local instanceHidden = false
        local instance = nil
        --
		if instanceType == "Frame" or instanceType == "frame" then
            local frame = Drawing.new("Square")
            frame.Visible = true
            frame.Filled = true
            frame.Thickness = 0
            frame.Color = Color3.fromRGB(255,255,255)
            frame.Size = Vector2.new(100,100)
            frame.Position = Vector2.new(0,0)
            frame.ZIndex = 50
            frame.Transparency = library.shared.initialized and 1 or 0
            instance = frame
        elseif instanceType == "TextLabel" or instanceType == "textlabel" then
            local text = Drawing.new("Text")
            text.Font = 3
            text.Visible = true
            text.Outline = true
            text.Center = false
            text.Color = Color3.fromRGB(255,255,255)
            text.ZIndex = 50
            text.Transparency = library.shared.initialized and 1 or 0
            instance = text
        elseif instanceType == "Triangle" or instanceType == "triangle" then
            local frame = Drawing.new("Triangle")
            frame.Visible = true
            frame.Filled = true
            frame.Thickness = 0
            frame.Color = Color3.fromRGB(255,255,255)
            frame.ZIndex = 50
            frame.Transparency = library.shared.initialized and 1 or 0
            instance = frame
        elseif instanceType == "Image" or instanceType == "image" then
            local image = Drawing.new("Image")
            image.Size = Vector2.new(12,19)
            image.Position = Vector2.new(0,0)
            image.Visible = true
            image.ZIndex = 50
            image.Transparency = library.shared.initialized and 1 or 0
            instance = image
        elseif instanceType == "Circle" or instanceType == "circle" then
            local circle = Drawing.new("Circle")
            circle.Visible = false
            circle.Color = Color3.fromRGB(255, 0, 0)
            circle.Thickness = 1
            circle.NumSides = 30
            circle.Filled = true
            circle.Transparency = 1
            circle.ZIndex = 50
            circle.Radius = 50
            circle.Transparency = library.shared.initialized and 1 or 0
            instance = circle
        elseif instanceType == "Quad" or instanceType == "quad" then
            local quad = Drawing.new("Quad")
            quad.Visible = false
            quad.Color = Color3.fromRGB(255, 255, 255)
            quad.Thickness = 1.5
            quad.Transparency = 1
            quad.ZIndex = 50
            quad.Filled = false
            quad.Transparency = library.shared.initialized and 1 or 0
            instance = quad
        elseif instanceType == "Line" or instanceType == "line" then
            local line = Drawing.new("Line")
            line.Visible = false
            line.Color = Color3.fromRGB(255, 255, 255)
            line.Thickness = 1.5
            line.Transparency = 1
            line.Thickness = 1.5
            line.ZIndex = 50
            line.Transparency = library.shared.initialized and 1 or 0
            instance = line
        end
        --
        if instance then
            for i, v in pairs(instanceProperties) do
                if i == "Hidden" or i == "hidden" then
                    instanceHidden = true
                else
                    if library.shared.initialized then
                        instance[i] = v
                    else
                        if i ~= "Transparency" then
                            instance[i] = v
                        end
                    end
                end
                --[[if typeof(v) == "Color3" then
                    local found_theme = utility:Find(theme, v)
                    if found_theme then
                        themes[found_theme] = themes[found_theme] or {}
                        themes[found_theme][i] = themes[found_theme][i]
                        table.insert(themes[found_theme][i], instance)
                    end
                end]]
            end
            --
            if not instanceHidden then
                library.drawings[#library.drawings + 1] = {instance, instanceOffset, instanceProperties["Transparency"] or 1}
            else
                library.hidden[#library.hidden + 1] = {instance}
            end
            --
            if instanceParent then
                instanceParent[#instanceParent + 1] = instance
            end
            --
            return instance
        end
	end
    --
    function utility:UpdateOffset(instance, instanceOffset)
        for i,v in pairs(library.drawings) do
            if v[1] == instance then
                v[2] = instanceOffset
            end
        end
    end
    --
    function utility:UpdateTransparency(instance, instanceTransparency)
        for i,v in pairs(library.drawings) do
            if v[1] == instance then
                v[3] = instanceTransparency
            end
        end
    end
    --
    function utility:Remove(instance, hidden)
        local ind = 0
        --
        for i,v in pairs(hidden and library.hidden or library.drawings) do
            if v[1] == instance then
                ind = i
                if hidden then
                    v[1] = nil
                else
                    v[2] = nil
                    v[1] = nil
                end
            end
        end
        --
        table.remove(hidden and library.hidden or library.drawings, ind)
        instance:Remove()
    end
    --
    function utility:GetSubPrefix(str)
        local str = tostring(str):gsub(" ","")
        local var = ""
        --
        if #str == 2 then
            local sec = string.sub(str,#str,#str+1)
            var = sec == "1" and "st" or sec == "2" and "nd" or sec == "3" and "rd" or "th"
        end
        --
        return var
    end
    --
    function utility:Connection(connectionType, connectionCallback)
        local connection = connectionType:Connect(connectionCallback)
        library.connections[#library.connections + 1] = connection
        --
        return connection
    end
    --
    function utility:Disconnect(connection)
        for i,v in pairs(library.connections) do
            if v == connection then
                library.connections[i] = nil
                v:Disconnect()
            end
        end
    end
    --
    function utility:MouseLocation()
        return uis:GetMouseLocation()
    end
    --
    function utility:MouseOverDrawing(values, valuesAdd)
        local valuesAdd = valuesAdd or {}
        local values = {
            (values[1] or 0) + (valuesAdd[1] or 0),
            (values[2] or 0) + (valuesAdd[2] or 0),
            (values[3] or 0) + (valuesAdd[3] or 0),
            (values[4] or 0) + (valuesAdd[4] or 0)
        }
        --
        local mouseLocation = utility:MouseLocation()
	    return (mouseLocation.x >= values[1] and mouseLocation.x <= (values[1] + (values[3] - values[1]))) and (mouseLocation.y >= values[2] and mouseLocation.y <= (values[2] + (values[4] - values[2])))
    end
    --
    function utility:GetTextBounds(text, textSize, font)
        local textbounds = Vector2.new(0, 0)
        --
        local textlabel = utility:Create("TextLabel", {Vector2.new(0, 0)}, {
            Text = text,
            Size = textSize,
            Font = font,
            Hidden = true
        })
        --
        textbounds = textlabel.TextBounds
        utility:Remove(textlabel, true)
        --
        return textbounds
    end
    --
    function utility:GetScreenSize()
        return ws.CurrentCamera.ViewportSize
    end
    --
    function utility:LoadImage(instance, imageName, imageLink)
        local data
        --
        if isfile(library.folders.assets.."/"..imageName..".png") then
            data = readfile(library.folders.assets.."/"..imageName..".png")
        else
            if imageLink then
                data = game:HttpGet(imageLink)
                writefile(library.folders.assets.."/"..imageName..".png", data)
            else
                return
            end
        end
        --
        if data and instance then
            instance.Data = data
        end
    end
    --
    function utility:Lerp(instance, instanceTo, instanceTime)
        local currentTime = 0
        local currentIndex = {}
        local connection
        --
        for i,v in pairs(instanceTo) do
            currentIndex[i] = instance[i]
        end
        --
        local function lerp()
            for i,v in pairs(instanceTo) do
                instance[i] = ((v - currentIndex[i]) * currentTime / instanceTime) + currentIndex[i]
            end
        end
        --
        connection = rs.RenderStepped:Connect(function(delta)
            if currentTime < instanceTime then
                currentTime = currentTime + delta
                lerp()
            else
                connection:Disconnect()
            end
        end)
    end
    --
    function utility:Combine(table1, table2)
        local table3 = {}
        for i,v in pairs(table1) do table3[i] = v end
        local t = #table3
        for z,x in pairs(table2) do table3[z + t] = x end
        return table3
    end
end


local window = {} do
    function library:New(size, settings)

        local window = {pages = {}, isVisible = false, uibind = Enum.KeyCode.Z, unloadbind = Enum.KeyCode.End, currentPage = nil, fading = false, dragging = false, drag = Vector2.new(0,0), currentContent = {frame = nil, dropdown = nil, multibox = nil, colorpicker = nil, keybind = nil}}

        local winSize = size or Vector2.new(400, 350)
        local main_frame = utility:Create("Frame", {Vector2.new(0,0)}, {
            Size = utility:Size(0, winSize.X, 0, winSize.Y),
            Position = utility:Position(0.5, -(winSize.X/2) ,0.5, -(winSize.Y/2)),
            Color = Color3.fromRGB(51, 51, 51),
            Transparency = settings.Transparency,
        });
        local main_inline = utility:Create("Frame", {Vector2.new(1,1)}, {
            Size = utility:Size(1, -2, 1, -2, main_frame),
            Position = utility:Position(0, 1, 0, 1, main_frame),
            Color = Color3.fromRGB(21, 21, 21),
            Transparency = settings.Transparency,
        });
        local title_textbox = utility:Create("TextLabel", {Vector2.new(0, 0)}, {
            Text = "SyntaxCMD v1",
            Size = 14,
            Font = 3,
            Color = Color3.fromRGB(255, 255, 255),
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Outline = true,
            Center = false,
            Position = utility:Position(0, 1, 0, -15, main_inline)
        });
        local cmd_outline = utility:Create("Frame", {Vector2.new(4,15)}, {
            Size = utility:Size(1, -8, 0, 30, main_inline),
            Position = utility:Position(0, 4, 0, winSize.Y - 38, main_inline),
            Color = Color3.fromRGB(109, 109, 109),
            Transparency = settings.Transparency,
        });
        local cmd_inline = utility:Create("Frame", {Vector2.new(1,1)}, {
            Size = utility:Size(1, -2, 1, -2, cmd_outline),
            Position = utility:Position(0, 1, 0, 1, cmd_outline),
            Color = Color3.fromRGB(12, 12, 12),
            Transparency = settings.Transparency,
        });
        local cmd_textbox = utility:Create("TextLabel", {Vector2.new(0, 0)}, {
            Text = "> Command here...",
            Size = 12,
            Font = 2,
            Color = Color3.fromRGB(110, 110, 110),
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Outline = false,
            Center = false,
            Position = utility:Position(0, 15, 0.25, 0, cmd_inline)
        });

        function window:AddCommand(text, callback)
            window.commands[text] = callback
        end
        function window:Log(text)
            if library.drawings.output.Log.Count ~= 0 then
                local log = utility:Create("TextLabel", {Vector2.new(0, 0)}, {
                    Text = text,
                    Size = 12,
                    Font = 2,
                    Color = Color3.fromRGB(213, 204, 65),
                    OutlineColor = Color3.fromRGB(0, 0, 0),
                    Outline = false,
                    Center = false,
                    Position = utility:Position(0, library.drawings.output.Log.Position[library.drawings.output.Log.Count].X, 0, library.drawings.output.Log.Position[library.drawings.output.Log.Count].Y + 13)
                });
                library.drawings.output.Log.Count = library.drawings.output.Log.Count+1
                table.insert(library.drawings.output.Log.Position, log.Position)
            else
                local log = utility:Create("TextLabel", {Vector2.new(0, 0)}, {
                    Text = text,
                    Size = 12,
                    Font = 2,
                    Color = Color3.fromRGB(213, 204, 65),
                    OutlineColor = Color3.fromRGB(0, 0, 0),
                    Outline = false,
                    Center = false,
                    Position = utility:Position(0, 15, 0, 5, main_inline)
                });
                library.drawings.output.Log.Count = library.drawings.output.Log.Count+1
                table.insert(library.drawings.output.Log.Position, log.Position)
            end
            
        end

        local textbox_focused = false
        
        library.began[#library.began + 1] = function(Input)
            if Input.KeyCode == Enum.KeyCode.Semicolon then
                textbox_focused = true
                cmd_textbox.Text = ''
            end
        end

        local function keyCodeToString(keyCode)
            if keyCode.Value < 127 and keyCode.Value > 33 then --// excluding space (32) character
                return string.char(keyCode.Value)
            elseif keyCode.Name == "Space" then
                return " "
            elseif keyCode.Name == "Return" then
                return
            else
                return keyCode.Name --// just return keycode name if not within range
            end
        end

        game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
            if textbox_focused then
                cmd_textbox.Text = cmd_textbox.Text..keyCodeToString(input.KeyCode)
            end
        end)

        library.began[#library.began + 1] = function(Input)
            if Input.KeyCode == Enum.KeyCode.Return then
                
                -- Command Handler
                if cmd_textbox.Text == ";print" then
                    window:Log("Hello, world!");
                end

                if string.split(cmd_textbox.Text, " ")[1] == ";speed" then
                    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = string.split(cmd_textbox.Text, " ")[2]
                    window:Log("Set speed to: "..string.split(cmd_textbox.Text, " ")[2])
                end

                cmd_textbox.Text = "> Command here..."
                textbox_focused = false
            end
        end

        function window:Move(vector)
            for i,v in pairs(library.drawings) do
                if v[2][2] then
                    v[1].Position = utility:Position(0, v[2][1].X, 0, v[2][1].Y, v[2][2])
                else
                    v[1].Position = utility:Position(0, vector.X, 0, vector.Y)
                end
            end
        end

        function window:Unload()
            for i,v in pairs(library.connections) do
                v:Disconnect()
                v = nil
            end
            --
            for i,v in next, library.hidden do
                coroutine.wrap(function()
                    if v[1] and v[1].Remove and v[1].__OBJECT_EXISTS then
                        local instance = v[1]
                        v[1] = nil
                        v = nil
                        --
                        instance:Remove()
                    end
                end)()
            end
            --
            for i,v in pairs(library.drawings) do
                coroutine.wrap(function()
                    if v[1].__OBJECT_EXISTS then
                        local instance = v[1]
                        v[2] = nil
                        v[1] = nil
                        v = nil
                        --
                        instance:Remove()
                    end
                end)()
            end
            --
            for i,v in pairs(library.began) do
                v = nil
            end
            --
            for i,v in pairs(library.ended) do
                v = nil
            end
            --
            for i,v in pairs(library.changed) do
                v = nil
            end
            --
            library.drawings = nil
            library.hidden = nil
            library.connections = nil
            library.began = nil
            library.ended = nil
            library.changed = nil
            --
            uis.MouseIconEnabled = true
        end

        function window:Cursor(info)
            window.cursor = {}
            --
            local cursor = utility:Create("Triangle", nil, {
                Color = Color3.fromRGB(111, 111, 111),
                Thickness = 2.5,
                Filled = false,
                ZIndex = 65,
                Hidden = true
            });window.cursor["cursor"] = cursor
            --
            local cursor_inline = utility:Create("Triangle", nil, {
                Color = Color3.fromRGB(190, 190, 190),
                Filled = true,
                Thickness = 0,
                ZIndex = 65,
                Hidden = true
            });window.cursor["cursor_inline"] = cursor_inline
            --
            utility:Connection(rs.RenderStepped, function()
                local mouseLocation = utility:MouseLocation()
                --
                cursor.PointA = Vector2.new(mouseLocation.X, mouseLocation.Y)
                cursor.PointB = Vector2.new(mouseLocation.X + 9, mouseLocation.Y + 9)
                cursor.PointC = Vector2.new(mouseLocation.X, mouseLocation.Y + 13)
                --
                cursor_inline.PointA = Vector2.new(mouseLocation.X, mouseLocation.Y)
                cursor_inline.PointB = Vector2.new(mouseLocation.X + 9, mouseLocation.Y + 9)
                cursor_inline.PointC = Vector2.new(mouseLocation.X, mouseLocation.Y + 13)
            end)
            --
            uis.MouseIconEnabled = false
            --
            return window.cursor
        end

        function window:Fade()
            window.fading = true
            window.isVisible = not window.isVisible
            --
            spawn(function()
                for i, v in pairs(library.drawings) do
                    utility:Lerp(v[1], {Transparency = window.isVisible and v[3] or 0}, 0.25)
                end
            end)
            --
            window.cursor["cursor"].Transparency = window.isVisible and 1 or 0
            window.cursor["cursor_inline"].Transparency = window.isVisible and 1 or 0
            uis.MouseIconEnabled = not window.isVisible
            --
            window.fading = false
        end

        library.began[#library.began + 1] = function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and window.isVisible and window.isVisible and utility:MouseOverDrawing({main_frame.Position.X,main_frame.Position.Y,main_frame.Position.X + main_frame.Size.X,main_frame.Position.Y + 20}) then
                local mouseLocation = utility:MouseLocation()
                --
                window.dragging = true
                window.drag = Vector2.new(mouseLocation.X - main_frame.Position.X, mouseLocation.Y - main_frame.Position.Y)
            end
        end
        --
        library.ended[#library.ended + 1] = function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 and window.isVisible and window.dragging then
                window.dragging = false
                window.drag = Vector2.new(0, 0)
            end
        end
        --
        library.changed[#library.changed + 1] = function(Input)
            if window.dragging and window.isVisible then
                local mouseLocation = utility:MouseLocation()
                if utility:GetScreenSize().Y-main_frame.Size.Y-5 > 5 then
                    local move = Vector2.new(math.clamp(mouseLocation.X - window.drag.X, 5, utility:GetScreenSize().X-main_frame.Size.X-5), math.clamp(mouseLocation.Y - window.drag.Y, 5, utility:GetScreenSize().Y-main_frame.Size.Y-5))
                    window:Move(move)
                else
                    local move = Vector2.new(mouseLocation.X - window.drag.X, mouseLocation.Y - window.drag.Y)
                    window:Move(move)
                end
            end
        end
        --
        library.began[#library.began + 1] = function(Input)
            if Input.KeyCode == window.uibind then
                window:Fade()
            elseif Input.KeyCode == window.unloadbind then
                window:Unload()
            end
            --[[
            if Input.KeyCode == Enum.KeyCode.P then
                local plrs = game:GetService("Players")
                local plr = plrs.LocalPlayer
                if #plrs:GetPlayers() <= 1 then
                    plr:Kick("\nRejoining...")
                    wait()
                    game:GetService('TeleportService'):Teleport(game.PlaceId, plr)
                else
                    game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
                end
            end]]
        end
        --
        utility:Connection(uis.InputBegan,function(Input)
            for _, func in pairs(library.began) do
                if not window.dragging then
                    local e,s = pcall(function()
                        func(Input)
                    end)
                else
                    break
                end
            end
        end)
        --
        utility:Connection(uis.InputEnded,function(Input)
            for _, func in pairs(library.ended) do
                local e,s = pcall(function()
                    func(Input)
                end)
            end
        end)
        --
        utility:Connection(uis.InputChanged,function()
            for _, func in pairs(library.changed) do
                local e,s = pcall(function()
                    func()
                end)
            end
        end)
        --
        utility:Connection(ws.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),function()
            window:Move(Vector2.new((utility:GetScreenSize().X/2) - (size.X/2), (utility:GetScreenSize().Y/2) - (size.Y/2)))
        end)
        --

        return setmetatable(window, library)
    end
end


library.shared.initialized = true

local Win = library:New(Vector2.new(375, 300), {Transparency = 0.8})

Win:Cursor()
