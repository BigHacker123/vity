--[[

    Oblivity Private ESP Library
      created by demo (demo#0007)

    [YOU MUST GIVE CREDIT IF USED]
    [YOU MUST GIVE CREDIT IF USED]
    [YOU MUST GIVE CREDIT IF USED]

    Terms of Use
      You are allowed to use this ESP as long as you provice a free service, therefore if your script is paid you are not allowed to use this.
      If you want to use the ESP in a paid script you must be allowed by demo to do so.

    (I know nobody is probably going to read that but I just rather state it, please do not use my code unless you are providing a free service)

]]

local esp = {
    players = {},
    connections = {
        ChildAdded = nil,
        ChildRemoved = nil,
        RenderStepped = nil
    },
    settings = {
        enabled = true,
        ai = true,
        team_check = false,
        use_display_names = true,
        max_distance = 0,
        
        text_settings = {
            font_size = 13,
            font_family = 2
        },

        target_settings = {
            enabled = true,
            target = nil,
            color = Color3.fromRGB(255, 50, 50)
        },

        friend_settings = {
            enabled = true,
            color = Color3.fromRGB(50, 50, 255),

            friend_targetted = false,
            friend_targetted_color = Color3.fromRGB(50, 255, 50)
        },

        drawings = {
            name = {enabled = true, outline = true, color = Color3.fromRGB(255, 255, 255)},
            box = {enabled = true, outline = true, color = Color3.fromRGB(255, 255, 255)},
            filled_box = {enabled = true, transparency = 0.3, color = Color3.fromRGB(255, 255, 255)},
            health_bar = {enabled = true, outline = true, size = 3},
            health_text = {enabled = true, outline = true, color = Color3.fromRGB(255, 255, 255)},
            distance = {enabled = true, outline = true, color = Color3.fromRGB(255, 255, 255)},
            view_angle = {enabled = true, size = 10, color = Color3.fromRGB(255, 255, 255)},
            tool = {enabled = true, outline = true, color = Color3.fromRGB(255, 255, 255)}
        }
    },
    functions = {}
}

--// Functions
do
    esp.functions.Draw = function(type, properties)
        local newDrawing = Drawing.new(type)
        for i,v in pairs(properties or {}) do
            newDrawing[i] = v
        end
        return newDrawing
    end

    esp.functions.CheckTeam = function(v)
        if v.Parent == game.Players then
            if game.Players.LocalPlayer.TeamColor == v.TeamColor then
                return false
            end
        end
        return true
    end

    esp.functions.GetTool = function(v)
        local Character =  v.Parent == game.Players and v.Character or v
        if Character:FindFirstChildOfClass("Tool") then
            return tostring(Character:FindFirstChildOfClass("Tool"))
        end
        return "None"
    end

    esp.functions.NewPlayer = function(v)
        esp.players[v] = {
            name = esp.functions.Draw("Text", {Color = Color3.new(1,1,1), Outline = true, Center = true, Size = 13, Font = 2}),
            filled_box = esp.functions.Draw("Square", {Color = Color3.new(1,1,1), Thickness = 1, Filled = true}),
            box_outline = esp.functions.Draw("Square", {Color = Color3.new(0,0,0), Thickness = 3}),
            box = esp.functions.Draw("Square", {Color = Color3.new(1,1,1), Thickness = 1}),
            health_bar_outline = esp.functions.Draw("Line", {Color = Color3.new(0,0,0), Thickness = 3}),
            health_bar = esp.functions.Draw("Line", {Color = Color3.new(1,1,1), Thickness = 1}),
            health_text = esp.functions.Draw("Text", {Color = Color3.new(1,1,1), Outline = true, Center = true, Size = 13, Font = 2}),
            distance = esp.functions.Draw("Text", {Color = Color3.new(1,1,1), Outline = true, Center = true, Size = 13, Font = 2}),
            view_angle = esp.functions.Draw("Line", {Color = Color3.new(1,1,1), Thickness = 1}),
            tool = esp.functions.Draw("Text", {Color = Color3.new(1,1,1), Outline = true, Center = true, Size = 13, Font = 2})
        }
    end

    esp.functions.Unload = function()
        for i,v in pairs(esp.players) do
            for i,v in pairs(v) do
                v:Remove()
            end
            esp.players[v] = nil
        end
        for i,v in pairs(esp.connections) do
            v:Disconnect()
        end
        table.clear(esp)
        esp = nil
    end
end

--// Setup
do
    for _,player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            esp.functions.NewPlayer(player)
        end
    end

    esp.connections.ChildAdded = game.Players.ChildAdded:Connect(function(player)
        esp.functions.NewPlayer(player)
    end)

    esp.connections.ChildRemoved  = game.Players.ChildRemoved:Connect(function(player)
        for i,v in pairs(esp.players[player]) do
            v:Remove()
        end
        esp.players[player] = nil
    end)
end

esp.connections.RenderStepped = game.RunService.RenderStepped:Connect(function()
    for i,v in pairs(esp.players) do
        if i.Parent ~= game.Players then
            if esp.settings.ai == false then
                for i,drawing in pairs(v) do
                    drawing.Visible = false
                end
                continue
            end
        end
        local Character =  i.Parent == game.Players and i.Character or i
        if Character then
            if Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("Head") then
                if Character.Humanoid.Health > 0 and (esp.settings.max_distance == 0 or (Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < esp.settings.max_distance) then
                    local Humanoid = Character.Humanoid
                    local HumanoidRootPart = Character.HumanoidRootPart
                    local Head = Character.Head

                    local Vector, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(Character.HumanoidRootPart.Position)

                    if onScreen and esp.settings.enabled then
                        local Size = (game.Workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 3, 0)).Y - game.Workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position + Vector3.new(0, 2.6, 0)).Y) / 2
                        local BoxSize = Vector2.new(math.floor(Size * 1.5), math.floor(Size * 1.9))
                        if BoxSize.X < 10 and BoxSize.Y < 12 then
                            BoxSize = Vector2.new(10,12)
                        end
                        local BoxPos = Vector2.new(math.floor(Vector.X - Size * 1.5 / 2), math.floor(Vector.Y - Size * 1.6 / 2))
                        local BottomOffset = BoxSize.Y + BoxPos.Y + 1

                        if esp.settings.drawings.name.enabled then
                            v.name.Position = Vector2.new(BoxSize.X / 2 + BoxPos.X, BoxPos.Y - 16)
                            v.name.Outline = esp.settings.drawings.name.outline
                            v.name.Color =  (esp.settings.target_settings.enabled and esp.settings.target_settings.target == i and esp.settings.target_settings.color) or (i.Parent == game.Players and esp.settings.friend_settings.enabled and i:IsFriendsWith(game.Players.LocalPlayer.UserId) and esp.settings.friend_settings.color) or esp.settings.drawings.name.color
                            v.name.Font = esp.settings.text_settings.font_family
                            v.name.Size = esp.settings.text_settings.font_size
                            v.name.Text = (i.Parent == game.Players and esp.settings.use_display_names and i.DisplayName) or i.Name
                            v.name.Visible = true
                        else
                            v.name.Visible = false
                        end

                        if esp.settings.drawings.box.enabled then
                            v.box_outline.Size = BoxSize
                            v.box_outline.Position = BoxPos
                            v.box_outline.Visible = esp.settings.drawings.box.outline
                            v.box.Size = BoxSize
                            v.box.Position = BoxPos
                            v.box.Color = (esp.settings.target_settings.enabled and esp.settings.target_settings.target == i and esp.settings.target_settings.color) or (i.Parent == game.Players and esp.settings.friend_settings.enabled and i:IsFriendsWith(game.Players.LocalPlayer.UserId) and esp.settings.friend_settings.color) or esp.settings.drawings.box.color
                            v.box.Visible = true
                        else
                            v.box_outline.Visible = false
                            v.box.Visible = false
                        end

                        if esp.settings.drawings.filled_box.enabled then
                            v.filled_box.Size = BoxSize + Vector2.new(-2, -2)
                            v.filled_box.Position = BoxPos + Vector2.new(1, 1)
                            v.filled_box.Color = (esp.settings.target_settings.enabled and esp.settings.target_settings.target == i and esp.settings.target_settings.color) or (i.Parent == game.Players and esp.settings.friend_settings.enabled and i:IsFriendsWith(game.Players.LocalPlayer.UserId) and esp.settings.friend_settings.color) or esp.settings.drawings.filled_box.color
                            v.filled_box.Transparency = esp.settings.drawings.filled_box.transparency
                            v.filled_box.Visible = true
                        else
                            v.filled_box.Visible = false
                        end

                        if esp.settings.drawings.health_bar.enabled then
                            v.health_bar.From = Vector2.new((BoxPos.X - 5), BoxPos.Y + BoxSize.Y)
                            v.health_bar.To = Vector2.new(v.health_bar.From.X, v.health_bar.From.Y - (Humanoid.Health / Humanoid.MaxHealth) * BoxSize.Y)
                            v.health_bar.Color = Color3.fromRGB(255 - 255 / (Humanoid["MaxHealth"] / Humanoid["Health"]), 255 / (Humanoid["MaxHealth"] / Humanoid["Health"]), 0)
                            v.health_bar.Visible = true
                            v.health_bar.Thickness = esp.settings.drawings.health_bar.size
        
                            v.health_bar_outline.From = Vector2.new(v.health_bar.From.X, BoxPos.Y + BoxSize.Y + 1)
                            v.health_bar_outline.To = Vector2.new(v.health_bar.From.X, (v.health_bar.From.Y - 1 * BoxSize.Y) -1)
                            v.health_bar_outline.Visible = esp.settings.drawings.health_bar.outline
                            v.health_bar_outline.Thickness = esp.settings.drawings.health_bar.size + 2
                        else
                            v.health_bar_outline.Visible = false
                            v.health_bar.Visible = false
                        end
        
                        if esp.settings.drawings.health_text.enabled then
                            v.health_text.Text = tostring(math.floor(Humanoid.Health))
                            v.health_text.Position = Vector2.new((BoxPos.X - 20), (BoxPos.Y + BoxSize.Y - 1 * BoxSize.Y) -1)
                            v.health_text.Color = (esp.settings.target_settings.enabled and esp.settings.target_settings.target == i and esp.settings.target_settings.color) or (i.Parent == game.Players and esp.settings.friend_settings.enabled and i:IsFriendsWith(game.Players.LocalPlayer.UserId) and esp.settings.friend_settings.color) or esp.settings.drawings.health_text.color
                            v.health_text.Outline = esp.settings.drawings.health_text.outline
        
                            v.health_text.Font = esp.settings.text_settings.font_family
                            v.health_text.Size = esp.settings.text_settings.font_size
        
                            v.health_text.Visible = true
                        else
                            v.health_text.Visible = false
                        end

                        if esp.settings.drawings.distance.enabled and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            v.distance.Position = Vector2.new(BoxSize.X / 2 + BoxPos.X, BottomOffset)
                            v.distance.Outline = esp.settings.drawings.distance.outline
                            v.distance.Text = ("%sm"):format(tostring(math.floor((HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude / 3.5714285714)))
                            v.distance.Color = (esp.settings.target_settings.enabled and esp.settings.target_settings.target == i and esp.settings.target_settings.color) or (i.Parent == game.Players and esp.settings.friend_settings.enabled and i:IsFriendsWith(game.Players.LocalPlayer.UserId) and esp.settings.friend_settings.color) or esp.settings.drawings.distance.color
                            BottomOffset = BottomOffset + 15
        
                            v.distance.Font = esp.settings.text_settings.font_family
                            v.distance.Size = esp.settings.text_settings.font_size
        
                            v.distance.Visible = true
                        else
                            v.distance.Visible = false
                        end

                        if esp.settings.drawings.view_angle.enabled and Head and Head.CFrame then
                            v.view_angle.From = Vector2.new(game.Workspace.CurrentCamera:worldToViewportPoint(Head.CFrame.p).X, game.Workspace.CurrentCamera:worldToViewportPoint(Head.CFrame.p).Y)
                            v.view_angle.To = Vector2.new(game.Workspace.CurrentCamera:worldToViewportPoint((Head.CFrame + (Head.CFrame.lookVector * esp.settings.drawings.view_angle.size)).p).X, game.Workspace.CurrentCamera:worldToViewportPoint((Head.CFrame + (Head.CFrame.lookVector * esp.settings.drawings.view_angle.size)).p).Y)
                            v.view_angle.Color = (esp.settings.target_settings.enabled and esp.settings.target_settings.target == i and esp.settings.target_settings.color) or (i.Parent == game.Players and esp.settings.friend_settings.enabled and i:IsFriendsWith(game.Players.LocalPlayer.UserId) and esp.settings.friend_settings.color) or esp.settings.drawings.view_angle.color
                            v.view_angle.Visible = true
                        else
                            v.view_angle.Visible = false
                        end

                        if esp.settings.drawings.tool.enabled then
                            v.tool.Visible = true
                            v.tool.Position = Vector2.new(BoxSize.X + BoxPos.X + v.tool.TextBounds.X / 2 + 3, BoxPos.Y - 3)
                            v.tool.Outline = esp.settings.drawings.tool.outline
                            v.tool.Color = (esp.settings.target_settings.enabled and esp.settings.target_settings.target == i and esp.settings.target_settings.color) or (i.Parent == game.Players and esp.settings.friend_settings.enabled and i:IsFriendsWith(game.Players.LocalPlayer.UserId) and esp.settings.friend_settings.color) or esp.settings.drawings.tool.color
        
                            v.tool.Font = esp.settings.text_settings.font_family
                            v.tool.Size = esp.settings.text_settings.font_size
        
                            v.tool.Text = esp.functions.GetTool(i)
                        else
                            v.tool.Visible = false
                        end
                    else
                        for i,drawing in pairs(v) do
                            drawing.Visible = false
                        end
                    end
                else
                    for i,drawing in pairs(v) do
                        drawing.Visible = false
                    end
                end
            else
                for i,drawing in pairs(v) do
                    drawing.Visible = false
                end
            end
        else
            for i,drawing in pairs(v) do
                drawing.Visible = false
            end
        end
    end
end)

getgenv().esp = esp
