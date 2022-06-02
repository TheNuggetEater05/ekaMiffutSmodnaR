-- // Library Tables
local drawing_extension = {
    drawings = {},
    connections = {},
    allowedProperties = {"Visible", "ZIndex", "Transparency", "Color", "Size", "AnchorPoint", "AbsoluteSize", "Position", "AbsolutePosition", "Thickness", "From", "To", "Text", "Font", "Center", "Outline", "OutlineColor", "TextBounds", "Data", "Rounding", "NumSides", "Radius", "Filled", "PointA", "PointB", "PointC", "PointD", "Visibility", "ClassName", "Parent"},
    allowedConnections = {"MouseButton1Down", "MouseButton2Down", "MouseButton1Up", "MouseButton2Up", "MouseButton1Click", "MouseButton2Click", "MouseEnter", "MouseLeave"}
 }
 local utility = {}
 local signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/mvonwalk/signal_library/main/signal_lib.lua"))()
 -- // Variables
 local uis = game:GetService("UserInputService")
 local rs = game:GetService("RunService")
 local ws = game:GetService("Workspace")
 -- // Utility
 function utility:MouseLocation()
    return uis:GetMouseLocation()
 end
 --
 function utility:Connection(connectionType, connectionCallback)
    local connection = connectionType:Connect(connectionCallback)
    --
    drawing_extension.connections[#drawing_extension.connections + 1] = connection
    --
    return connection
 end
 --
 function utility:Unload()
    for index, connection in pairs(drawing_extension.connections) do
        connection:Disconnect()
    end
    --
    for index, drawing in pairs(drawing_extension.drawings) do
        setmetatable(drawing.Drawing, nil)
        drawing.Instance:Remove()
        --
        for ind, connection in pairs(drawing.Connections) do
            connection[1]:Destroy()
            connection = nil
        end
        --
        drawing.Connections = nil
        drawing.Instance = nil
        drawing.Drawing = nil
        drawing = nil
    end
    --
    drawing_extension.drawings = nil
    drawing_extension.connections = nil
    drawing_extension = nil
 end
 --
 function utility:ReverseTable(tbl)
    if tbl then
        local new = {}
        --
        for index, value in pairs(tbl) do
            new[index] = tbl[#tbl - (index - 1)]
        end
        --
        return new
    end
 end
 -- // Functions
 function drawing_extension:NewDrawing(drawingType, drawingProperties)
    local instance = Drawing.new((drawingType == "Button" and "Square" or drawingType))
    local drawing, properties = drawing_extension:HandleNewDrawing(instance, drawingType)
    --
    local drawingProperties = drawingProperties or {}
    --
    for property, value in pairs(drawingProperties) do
        drawing_extension:HandleNewIndex(instance, drawingType, drawing, properties, property, value)
    end
    --
    drawing:Update("Visibility")
    --
    return drawing
 end
 --
 function drawing_extension:HandleNewDrawing(instance, drawingType)
    local drawing = {}
    local properties = {
        Parent = nil,
        Children = {},
        AnchorPoint = Vector2.new(0, 0),
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Visible = true,
        ClassName = drawingType,
        Connections = {}
    }
    --
    function drawing:Remove()
        if properties.Parent then
            properties.Parent:RemoveChild(drawing)
        end
        --
        for index, value in pairs(drawing_extension.drawings) do
            if value.Instance == instance then
                spawn(function()
                    setmetatable(drawing.Drawing, nil)
                    drawing.Instance:Remove()
                    --
                    for ind, connection in pairs(drawing.Connections) do
                        connection[1]:Destroy()
                        connection = nil
                    end
                    --
                    drawing.Connections = nil
                    drawing.Instance = nil
                    drawing.Drawing = nil
                    drawing = nil
                end)
            end
        end
        --
        for index, value in pairs(properties.Connections) do
            value[1]:Destroy()
        end
        --
        for index, value in pairs(properties.Children) do
            value:Remove()
        end
        --
        setmetatable(drawing, {})
        instance:Remove()
        drawing = nil
        properties = nil
    end
    --
    function drawing:Update(updateType)
        if updateType == "Visibility" then
            do
                if properties.Parent then
                    instance.Visible = properties.Parent.Visibility and properties.Visible or false
                else
                    instance.Visible = properties.Visible
                end
            end
        end
        --
        if properties.ClassName ~= "Triangle" then
            if updateType == "Size" then
                do
                    if properties.ClassName ~= "Text" then
                        local parentSize = ((properties.Parent and properties.Parent.AbsoluteSize) or ws.CurrentCamera.ViewportSize)
                        local xSize = parentSize.X * properties.Size.X.Scale + properties.Size.X.Offset
                        local ySize = parentSize.Y * properties.Size.Y.Scale + properties.Size.Y.Offset
                        instance.Size = Vector2.new(xSize, ySize)
                    end
                end
            end
            --
            if updateType == "Position" then
                do
                    local parentPosition = ((properties.Parent and properties.Parent.AbsolutePosition) or Vector2.new(0, 0))
                    local parentSize = ((properties.Parent and properties.Parent.AbsoluteSize) or ws.CurrentCamera.ViewportSize)
                    local parentSize = (properties.Parent and ((properties.Parent.ClassName == "Text" or properties.Parent.ClassName == "Circle") and Vector2.new(0, 0) or properties.Parent.AbsoluteSize) or ws.CurrentCamera.ViewportSize)
                    local xPosition = (parentPosition.X + (properties.Position.X.Scale * parentSize.X) + properties.Position.X.Offset) - ((properties.ClassName == "Text" or properties.ClassName == "Circle") and 0 or (instance.Size.X * properties.AnchorPoint.X))
                    local yPosition = (parentPosition.Y + (properties.Position.Y.Scale * parentSize.Y) + properties.Position.Y.Offset) - ((properties.ClassName == "Text" or properties.ClassName == "Circle") and 0 or (instance.Size.Y * properties.AnchorPoint.Y))
                    instance.Position = Vector2.new(xPosition, yPosition)
                end
            end
        end
        --
        for index, child in pairs(properties.Children) do
            child:Update(updateType)
        end
    end
    --
    function drawing:AddChild(child)
        properties.Children[#properties.Children + 1] = child
    end
    --
    function drawing:RemoveChild(child)
        if table.find(properties.Children, child) then
            table.remove(properties.Children, table.find(properties.Children, child))
        end
    end
    --
    setmetatable(drawing, {
        __newindex = function(self, prop, val)
            drawing_extension:HandleNewIndex(instance, drawingType, drawing, properties, prop, val)
        end,
        __index = function(self, prop)
            return drawing_extension:HandleIndex(instance, drawingType, drawing, properties, prop)
        end
    })
    --
    do
        for index, connection in pairs(drawing_extension.allowedConnections) do
            if properties.ClassName ~= "Text" then
                if properties.ClassName == "Button" then
                    properties.Connections[connection] = {signal.new(connection)}
                else
                    if not connection:find("MouseButton") then
                        properties.Connections[connection] = {signal.new(connection)}
                    end
                end
            end
        end
    end
    --
    drawing_extension.drawings[#drawing_extension.drawings + 1] = {
        Drawing = drawing,
        Instance = instance,
        Connections = properties.Connections
    }
    --
    return drawing, properties
 end
 --
 function drawing_extension:HandleNewIndex(instance, drawingtype, drawing, properties, propertyType, propertyValue)
    for index, property in pairs(drawing_extension.allowedProperties) do
        if property == propertyType then
            if propertyType == "Size" then
                if drawingtype == "Text" then
                    instance[propertyType] = propertyValue
                else
                    properties.Size = propertyValue
                    drawing:Update("Size")
                    drawing:Update("Position")
                end
            elseif propertyType == "Position" then
                if drawingtype == "Circle" then
                    instance[propertyType] = propertyValue
                else
                    properties.Position = propertyValue
                    drawing:Update("Position")
                end
            elseif propertyType == "AnchorPoint" then
                properties.AnchorPoint = propertyValue
                drawing:Update("Size")
                drawing:Update("Position")
            elseif propertyType == "Parent" then
                if properties.Parent then
                    properties.Parent:RemoveChild(drawing)
                end
                --
                properties.Parent = propertyValue
                --
                if properties.Parent then
                    properties.Parent:AddChild(drawing)
                end
                --
                drawing:Update("Position")
                drawing:Update("Size")
            elseif propertyType == "Transparency" then
                instance[propertyType] = 1 - propertyValue
            elseif propertyType == "ClassName" then
            elseif propertyType == "Visible" then
                properties.Visible = propertyValue
                --
                drawing:Update("Visibility")
            else
                instance[propertyType] = propertyValue
            end
            return
        end
    end
 end
 --
 function drawing_extension:HandleIndex(instance, drawingtype, drawing, properties, propertyType)
    for index, property in pairs(drawing_extension.allowedProperties) do
        if property == propertyType then
            if propertyType == "Size" then
                if drawingtype == "Text" then
                    return instance[propertyType]
                else
                    return properties.Size
                end
            elseif propertyType == "AbsoluteSize" then
                return instance.Size
            elseif propertyType == "Position" then
                if drawingtype == "Circle" then
                    return instance[propertyType]
                else
                    return properties.Position
                end
            elseif propertyType == "AbsolutePosition" then
                return instance.Position
            elseif propertyType == "AnchorPoint" then
                return instance.AnchorPoint
            elseif propertyType == "Parent" then
                return properties.Parent
            elseif propertyType == "Transparency" then
                return 1 - instance[propertyType]
            elseif propertyType == "ClassName" then
                return properties.ClassName
            elseif propertyType == "Visible" then
                return properties.Visible
            elseif propertyType == "Visibility" then
                return instance.Visible
            else
                return instance[propertyType]
            end
        end
    end
    --
    for index, connection in pairs(drawing_extension.allowedConnections) do
        if connection == propertyType then
            return properties.Connections[propertyType][1]
        end
    end
 end
 -- // Main
 utility:Connection(uis.InputBegan, function(Input)
    local mouseLocation = utility:MouseLocation()
    --
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2 then
        for index, drawing in pairs(utility:ReverseTable(drawing_extension.drawings)) do
            if drawing.Connections.MouseButton1Down and drawing.Instance.Visible then
                if drawing.Drawing.ClassName ~= "Text" then
                    if (mouseLocation.X > drawing.Instance.Position.X and mouseLocation.Y > drawing.Instance.Position.Y and mouseLocation.X < (drawing.Instance.Position + drawing.Instance.Size).X and mouseLocation.Y < (drawing.Instance.Position + drawing.Instance.Size).Y) then
                        drawing.Connections[Input.UserInputType == Enum.UserInputType.MouseButton1 and "MouseButton1Click" or "MouseButton2Click"][1]:Fire()
                        --
                        do
                            drawing.Connections[Input.UserInputType == Enum.UserInputType.MouseButton1 and "MouseButton1Down" or "MouseButton2Down"][1]:Fire()
                            drawing.Connections[Input.UserInputType == Enum.UserInputType.MouseButton1 and "MouseButton1Down" or "MouseButton2Down"][2] = true
                        end
                        --
                        break
                    end
                end
            end
        end
    end
 end)
 --
 utility:Connection(uis.InputEnded, function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2 then
        for index, drawing in pairs(drawing_extension.drawings) do
            if drawing.Connections.MouseButton1Down and drawing.Connections.MouseButton1Down[2] then
                drawing.Connections.MouseButton1Down[2] = nil
                drawing.Connections.MouseButton1Up[1]:Fire()
            elseif drawing.Connections.MouseButton2Down and drawing.Connections.MouseButton2Down[2] then
                drawing.Connections.MouseButton2Down[2] = nil
                drawing.Connections.MouseButton2Up[1]:Fire()
            end
        end
    end
 end)
 --
 return drawing_extension, utility, signal
