local plrs = game["Players"]
local rs = game["RunService"]

local plr = plrs.LocalPlayer
local mouse = plr:GetMouse()
local camera = workspace.CurrentCamera
local worldToViewportPoint = camera.worldToViewportPoint
local emptyCFrame = CFrame.new();
local pointToObjectSpace = emptyCFrame.PointToObjectSpace

-- thank you demo for the optim variables saved me so much time

local Drawingnew = Drawing.new
local Color3fromRGB = Color3.fromRGB
local Vector3new = Vector3.new
local Vector2new = Vector2.new
local mathfloor = math.floor
local mathceil = math.ceil
local cross = Vector3new().Cross;
local esp = {
    players = {},
    objects = {},
    enabled = false,
    teamcheck = false,
    fontsize = 13,
    font = 2,
    maxdist = 0,
    settings = {
        name = {enabled = false, outline = true, displaynames = true, color = Color3fromRGB(255, 255, 255)},
        box = {enabled = false, outline = true, color = Color3fromRGB(255, 255, 255)},
        filledbox = {enabled = false, outline = true, transparency = 0.5, color = Color3fromRGB(255, 255, 255)},
        healthbar = {enabled = false, size = 3, outline = true},
        healthtext = {enabled = false, outline = true, color = Color3fromRGB(255, 255, 255)},
        distance = {enabled = false, outline = true, color = Color3fromRGB(255, 255, 255)},
        viewangle = {enabled = false, size = 6, color = Color3fromRGB(255, 255, 255)},
        weapon = {enabled = false, size = 6, color = Color3fromRGB(255, 255, 255)},
        skeleton = {enabled = false, color = Color3fromRGB(255, 255, 255)},
        tracer = {enabled = false, origin = "Middle", color = Color3fromRGB(255, 255, 255)},
        arrow = {enabled = false, radius = 100, size = 25, filled = false, transparency = 1, color = Color3fromRGB(255, 255, 255)}
    },
    settings_chams = {
        enabled = false,
        teamcheck = false,
        outline = false,
        fill_color = Color3fromRGB(255, 255, 255),
        outline_color = Color3fromRGB(0, 0, 0), 
        fill_transparency = 0,
        outline_transparency = 0,
        autocolor = true,
        visible_Color = Color3fromRGB(0, 255, 0),
        invisible_Color = Color3fromRGB(255, 0, 0),
    },
    customsettings = {
        enabled = true,
        maxdist = 4000,
        names = {enabled = true, outline = true, size = 13, color = Color3fromRGB(255, 255, 255)},
        distance = {enabled = true, outline = true, color = Color3fromRGB(255, 255, 255)},
        chams = {enabled = true, fill_transparency = 0, outline_transparency = 0, fill_color = Color3fromRGB(255, 255, 255), outline_color = Color3fromRGB(0, 0, 0)}
    }
}

esp.NewDrawing = function(type, properties)
    local newDrawing = Drawingnew(type)

    for i,v in next, properties or {} do
        newDrawing[i] = v
    end

    return newDrawing
end

esp.NewCham = function(properties)
    local newCham = Instance.new("Highlight", game.CoreGui)

    for i,v in next, properties or {} do
        newCham[i] = v
    end

    return newCham
end

esp.WallCheck = function(v)
    local ray = Ray.new(camera.CFrame.p, (v.Position - camera.CFrame.p).Unit * 300)
    local part, position = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(ray, {plr.Character, camera}, false, true)
    if part then
        local hum = part.Parent:FindFirstChildOfClass("Humanoid")
        if not hum then
            hum = part.Parent.Parent:FindFirstChildOfClass("Humanoid")
        end
        if hum and v and hum.Parent == v.Parent then
            local Vector, Visible = camera:WorldToScreenPoint(v.Position)
            if Visible then
                return true
            end
        end
    end
end

esp.TeamCheck = function(v)
    if plr.TeamColor == v.TeamColor then
        return false
    end

    return true
end

esp.GetEquippedTool = function(v)
    local Character =  v.Parent == game.Players and v.Character or v
    if Character:FindFirstChildOfClass("Tool") then
        return tostring(Character:FindFirstChildOfClass("Tool"))
    end
    return "None"
end

esp.NewPlayer = function(v)
    esp.players[v] = {
        name = esp.NewDrawing("Text", {Color = Color3fromRGB(255, 255, 255), Outline = true, Center = true, Size = 13, Font = 2}),
        filledbox = esp.NewDrawing("Square", {Color = Color3fromRGB(255, 255, 255), Thickness = 1, Filled = true}),
        boxOutline = esp.NewDrawing("Square", {Color = Color3fromRGB(0, 0, 0), Thickness = 3}),
        box = esp.NewDrawing("Square", {Color = Color3fromRGB(255, 255, 255), Thickness = 1}),
        healthBarOutline = esp.NewDrawing("Line", {Color = Color3fromRGB(0, 0, 0), Thickness = 3}),
        healthBar = esp.NewDrawing("Line", {Color = Color3fromRGB(255, 255, 255), Thickness = 1}),
        healthText = esp.NewDrawing("Text", {Color = Color3fromRGB(255, 255, 255), Outline = true, Center = true, Size = 13, Font = 2}),
        distance = esp.NewDrawing("Text", {Color = Color3fromRGB(255, 255, 255), Outline = true, Center = true, Size = 13, Font = 2}),
        viewAngle = esp.NewDrawing("Line", {Color = Color3fromRGB(255, 255, 255), Thickness = 1}),
        weapon = esp.NewDrawing("Text", {Color = Color3fromRGB(255, 255, 255), Outline = true, Center = true, Size = 13, Font = 2}),
        tracer = esp.NewDrawing("Line", {Color = Color3fromRGB(255, 255, 255), Thickness = 1}),
        cham = esp.NewCham({FillColor = esp.settings_chams.fill_color, OutlineColor = esp.settings_chams.outline_color, FillTransparency = esp.settings_chams.fill_transparency, OutlineTransparency = esp.settings_chams.outline_transparency}),
        arrow = esp.NewDrawing("Triangle", {Color = Color3fromRGB(255, 255, 255), Thickness = 1})
    }
end

function CreateNameTag(Parent, Text)
    local NameTag = Instance.new("BillboardGui", Parent)
    NameTag.Size = UDim2.new(1,1, 1,1)
    NameTag.Name = "ESP"
    NameTag.AlwaysOnTop = true
    local NameTag2 = Instance.new("Frame", NameTag)
    NameTag2.Size = UDim2.new(1,1, 1,1)
    NameTag2.BackgroundTransparency = 1
    NameTag2.BorderSizePixel = 0
    local NameTag3 = Instance.new("TextLabel", NameTag2)
    NameTag3.Text = Text
    NameTag3.Size = UDim2.new(1,1, 1,1)
    NameTag3.BackgroundTransparency = 1
    NameTag3.BorderSizePixel = 1
    NameTag3.TextColor3 = Color3.fromRGB(255,255,255)
end

function CreateHighlight(Model)
    local Highlight = Instance.new("Highlight")
        Highlight.Name = "Chams"
		Highlight.Parent = Model
		Highlight.OutlineColor = esp.customsettings.chams.outline_color
		Highlight.FillColor = esp.customsettings.chams.fill_color
		Highlight.Enabled = true
		Highlight.FillTransparency = esp.customsettings.chams.fill_transparency
		Highlight.OutlineTransparency = esp.customsettings.chams.outline_transparency
end

local esp_Loop
esp_Loop = rs.RenderStepped:Connect(function()
    for i,v in pairs(esp.players) do
        if i.Character and i.Character:FindFirstChild("Humanoid") and i.Character:FindFirstChild("HumanoidRootPart") and i.Character:FindFirstChild("Head") and i.Character:FindFirstChild("Humanoid").Health > 0 and (esp.maxdist == 0 or (i.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude < esp.maxdist) then
            local hum = i.Character.Humanoid
            local hrp = i.Character.HumanoidRootPart
            local head = i.Character.Head

            local Vector, onScreen = camera:WorldToViewportPoint(i.Character.HumanoidRootPart.Position)
    
            local Size = (camera:WorldToViewportPoint(hrp.Position - Vector3new(0, 3, 0)).Y - camera:WorldToViewportPoint(hrp.Position + Vector3new(0, 2.6, 0)).Y) / 2
            local BoxSize = Vector2new(mathfloor(Size * 1.5), mathfloor(Size * 1.9))
            local BoxPos = Vector2new(mathfloor(Vector.X - Size * 1.5 / 2), mathfloor(Vector.Y - Size * 1.6 / 2))
    
            local BottomOffset = BoxSize.Y + BoxPos.Y + 1

            if onScreen and esp.settings_chams.enabled then
                v.cham.Adornee = i.Character
                v.cham.Enabled = esp.settings_chams.enabled
                v.cham.OutlineTransparency = esp.settings_chams.outline and esp.settings_chams.outline_transparency or 1
                v.cham.OutlineColor = esp.settings_chams.autocolor and esp.settings_chams.autocolor_outline and esp.WallCheck(i.Character.Head) and esp.settings_chams.visible_Color or esp.settings_chams.autocolor and esp.settings_chams.autocolor_outline and not esp.WallCheck(i.Character.Head) and esp.settings_chams.invisible_Color or esp.settings_chams.outline_color
                v.cham.FillColor = esp.settings_chams.autocolor and esp.WallCheck(i.Character.Head) and esp.settings_chams.visible_Color or esp.settings_chams.autocolor and not esp.WallCheck(i.Character.Head) and esp.settings_chams.invisible_Color or esp.settings_chams.fill_color
                v.cham.FillTransparency = esp.settings_chams.fill_transparency

                if esp.settings_chams.teamcheck then
                    if not esp.TeamCheck(i) then
                        v.cham.Enabled = false
                    end
                end
            else
                v.cham.Enabled = false
            end

            if esp.settings.tracer.enabled and esp.enabled then
                if esp.settings.tracer.origin == "Bottom" then
                    v.tracer.From = Vector2new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                elseif esp.settings.tracer.origin == "Top" then
                    v.tracer.From = Vector2new(workspace.CurrentCamera.ViewportSize.X / 2,0)
                elseif esp.settings.tracer.origin == "Middle" then
                    v.tracer.From = Vector2new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
                else
                    v.tracer.From = Vector2new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
                end

                v.tracer.To = Vector2new(Vector.X, Vector.Y)
                v.tracer.Color = esp.settings.tracer.color
                v.tracer.Visible = true
            else
                v.tracer.Visible = false
            end

            if onScreen and esp.enabled then
                if esp.settings.name.enabled then
                    v.name.Position = Vector2new(BoxSize.X / 2 + BoxPos.X, BoxPos.Y - 16)
                    v.name.Outline = esp.settings.name.outline
                    v.name.Color = esp.settings.name.color

                    v.name.Font = esp.font
                    v.name.Size = esp.fontsize

                    if esp.settings.name.displaynames then
                        v.name.Text = i.DisplayName
                    else
                        v.name.Text = i.Name
                    end

                    v.name.Visible = true
                else
                    v.name.Visible = false
                end

                if esp.settings.distance.enabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    v.distance.Position = Vector2new(BoxSize.X / 2 + BoxPos.X, BottomOffset)
                    v.distance.Outline = esp.settings.distance.outline
                    v.distance.Text = "[" .. mathfloor((hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                    v.distance.Color = esp.settings.distance.color
                    BottomOffset = BottomOffset + 15

                    v.distance.Font = esp.font
                    v.distance.Size = esp.fontsize

                    v.distance.Visible = true
                else
                    v.distance.Visible = false
                end

                if esp.settings.filledbox.enabled then
                    v.filledbox.Size = BoxSize + Vector2.new(-2, -2)
                    v.filledbox.Position = BoxPos + Vector2.new(1, 1)
                    v.filledbox.Color = esp.settings.filledbox.color
                    v.filledbox.Transparency = esp.settings.filledbox.transparency
                    v.filledbox.Visible = true
                else
                    v.filledbox.Visible = false
                end

                if esp.settings.box.enabled then
                    v.boxOutline.Size = BoxSize
                    v.boxOutline.Position = BoxPos
                    v.boxOutline.Visible = esp.settings.box.outline
    
                    v.box.Size = BoxSize
                    v.box.Position = BoxPos
                    v.box.Color = esp.settings.box.color
                    v.box.Visible = true
                else
                    v.boxOutline.Visible = false
                    v.box.Visible = false
                end

                if esp.settings.healthbar.enabled then
                    v.healthBar.From = Vector2new((BoxPos.X - 5), BoxPos.Y + BoxSize.Y)
                    v.healthBar.To = Vector2new(v.healthBar.From.X, v.healthBar.From.Y - (hum.Health / hum.MaxHealth) * BoxSize.Y)
                    v.healthBar.Color = Color3fromRGB(255 - 255 / (hum["MaxHealth"] / hum["Health"]), 255 / (hum["MaxHealth"] / hum["Health"]), 0)
                    v.healthBar.Visible = true
                    v.healthBar.Thickness = esp.settings.healthbar.size

                    v.healthBarOutline.From = Vector2new(v.healthBar.From.X, BoxPos.Y + BoxSize.Y + 1)
                    v.healthBarOutline.To = Vector2new(v.healthBar.From.X, (v.healthBar.From.Y - 1 * BoxSize.Y) -1)
                    v.healthBarOutline.Visible = esp.settings.healthbar.outline
                    v.healthBarOutline.Thickness = esp.settings.healthbar.size + 2
                else
                    v.healthBarOutline.Visible = false
                    v.healthBar.Visible = false
                end

                if esp.settings.healthtext.enabled then
                    v.healthText.Text = tostring(mathfloor(hum.Health))
                    v.healthText.Position = Vector2new((BoxPos.X - 20), (BoxPos.Y + BoxSize.Y - 1 * BoxSize.Y) -1)
                    v.healthText.Color = esp.settings.healthtext.color
                    v.healthText.Outline = esp.settings.healthtext.outline

                    v.healthText.Font = esp.font
                    v.healthText.Size = esp.fontsize

                    v.healthText.Visible = true
                else
                    v.healthText.Visible = false
                end

                if esp.settings.viewangle.enabled and head and head.CFrame then
                    v.viewAngle.From = Vector2new(camera:worldToViewportPoint(head.CFrame.p).X, camera:worldToViewportPoint(head.CFrame.p).Y)
                    v.viewAngle.To = Vector2new(camera:worldToViewportPoint((head.CFrame + (head.CFrame.lookVector * esp.settings.viewangle.size)).p).X, camera:worldToViewportPoint((head.CFrame + (head.CFrame.lookVector * esp.settings.viewangle.size)).p).Y)
                    v.viewAngle.Color = esp.settings.viewangle.color
                    v.viewAngle.Visible = true
                else
                    v.viewAngle.Visible = false
                end
                v.arrow.Visible = false
                if esp.settings.weapon.enabled then
                    v.weapon.Visible = true
                    v.weapon.Position = Vector2new(BoxSize.X + BoxPos.X + v.weapon.TextBounds.X / 2 + 3, BoxPos.Y - 3)
                    v.weapon.Outline = esp.settings.weapon.outline
                    v.weapon.Color = esp.settings.weapon.color
                    v.weapon.Font = esp.font
                    v.weapon.Size = esp.fontsize
                    v.weapon.Text = esp.GetEquippedTool(i)
                else
                    v.weapon.Visible = false
                end
                if esp.teamcheck then
                    if esp.TeamCheck(i) then
                        v.name.Visible = esp.settings.name.enabled
                        v.box.Visible = esp.settings.box.enabled
                        v.filledbox.Visible = esp.settings.box.enabled
                        v.healthBar.Visible = esp.settings.healthbar.enabled
                        v.healthText.Visible = esp.settings.healthtext.enabled
                        v.distance.Visible = esp.settings.distance.enabled
                        v.viewAngle.Visible = esp.settings.viewangle.enabled
                        v.weapon.Visible = esp.settings.weapon.enabled
                        v.tracer.Visible = esp.settings.tracer.enabled
                        v.arrow.Visible = esp.settings.arrow.enabled
                    else
                        v.name.Visible = false
                        v.boxOutline.Visible = false
                        v.box.Visible = false
                        v.filledbox.Visible = false
                        v.healthBarOutline.Visible = false
                        v.healthBar.Visible = false
                        v.healthText.Visible = false
                        v.distance.Visible = false
                        v.viewAngle.Visible = false
                        v.weapon.Visible = false
                        v.tracer.Visible = false
                        v.arrow.Visible = false
                    end
                end
            else
                v.name.Visible = false
                v.boxOutline.Visible = false
                v.box.Visible = false
                v.filledbox.Visible = false
                v.healthBarOutline.Visible = false
                v.healthBar.Visible = false
                v.healthText.Visible = false
                v.distance.Visible = false
                v.viewAngle.Visible = false
                v.weapon.Visible = false
                v.tracer.Visible = false
                if esp.enabled and esp.settings.arrow.enabled then
                    local currentCamera = workspace.CurrentCamera
                    local screenCenter = Vector2new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2);
                    local objectSpacePoint = (pointToObjectSpace(currentCamera.CFrame, hrp.Position) * Vector3new(1, 0, 1)).Unit;
                    local crossVector = cross(objectSpacePoint, Vector3new(0, 1, 1));
                    local rightVector = Vector2new(crossVector.X, crossVector.Z);

                    local arrowRadius, arrowSize = esp.settings.arrow.radius, esp.settings.arrow.size;
                    local arrowPosition = screenCenter + Vector2new(objectSpacePoint.X, objectSpacePoint.Z) * arrowRadius;
                    local arrowDirection = (arrowPosition - screenCenter).Unit;

                    local pointA, pointB, pointC = arrowPosition, screenCenter + arrowDirection * (arrowRadius - arrowSize) + rightVector * arrowSize, screenCenter + arrowDirection * (arrowRadius - arrowSize) + -rightVector * arrowSize;

                    v.arrow.Visible = true
                    v.arrow.Filled = esp.settings.arrow.filled;
                    v.arrow.Transparency = esp.settings.arrow.transparency;
                    v.arrow.Color = esp.settings.arrow.color
                    v.arrow.PointA = pointA;
                    v.arrow.PointB = pointB;
                    v.arrow.PointC = pointC;
                else
                    v.arrow.Visible = false
                end
            end
        else
            v.name.Visible = false
            v.boxOutline.Visible = false
            v.box.Visible = false
            v.filledbox.Visible = false
            v.healthBarOutline.Visible = false
            v.healthBar.Visible = false
            v.healthText.Visible = false
            v.distance.Visible = false
            v.viewAngle.Visible = false
            v.cham.Enabled = false
            v.weapon.Visible = false
            v.tracer.Visible = false
            v.arrow.Visible = false
        end
    end

    local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

    for _,Folders in pairs(game.Workspace.AiZones:GetChildren()) do
        for _,Bot in pairs(Folders:GetChildren()) do
            if Bot and esp.customsettings.enabled and Bot:FindFirstChild("HumanoidRootPart") and (hrp.Position - Bot.HumanoidRootPart.Position).Magnitude <= esp.customsettings.maxdist and Bot.Humanoid.Health >= 1 then

                if esp.customsettings.names.enabled then
                    if Bot:FindFirstChild("ESP") then
                        Bot.ESP.StudsOffset = Vector3.new(0,3.5,0)
                        Bot.ESP.Frame.TextLabel.TextColor3 = esp.customsettings.names.color
                        Bot.ESP.Frame.TextLabel.BorderColor3 = Color3.new(1,1,1)
                        Bot.ESP.Frame.TextLabel.TextSize = esp.customsettings.names.size
                        Bot.ESP.Frame.TextLabel.Font = 3
                        if not esp.customsettings.distance.enabled then
                            Bot.ESP.Frame.TextLabel.Text = Bot.Name
                        elseif esp.customsettings.distance.enabled then
                            Bot.ESP.Frame.TextLabel.Text = Bot.Name .. " [ " .. math.floor((hrp.Position - Bot.HumanoidRootPart.Position).Magnitude) .. " ]"
                        end
                        if esp.customsettings.names.outline then
                            Bot.ESP.Frame.TextLabel.BorderSizePixel = 10
                        else
                            Bot.ESP.Frame.TextLabel.BorderSizePixel = 1
                        end
                    else
                        CreateNameTag(Bot, "Bot")
                    end
                else
                    if Bot:FindFirstChild("ESP") then
                        Bot.ESP:Destroy()
                    end
                end

                if esp.customsettings.chams.enabled then
                    if not Bot:FindFirstChild("Chams") then
                        CreateHighlight(Bot)
                    elseif Bot:FindFirstChild("Chams") then
                        Bot.Chams:Destroy()
                        CreateHighlight(Bot)
                    end
                else
                    if Bot:FindFirstChild("Chams") then
                        Bot.Chams:Destroy()
                    end
                end
            else
                if Bot:FindFirstChild("ESP") then
                    Bot.ESP:Destroy()
                end
            end
        end
    end
end)

local function DrawLine()
    local l = Drawing.new("Line")
    l.Visible = false
    l.From = Vector2.new(0, 0)
    l.To = Vector2.new(1, 1)
    l.Color = esp.settings.skeleton.color
    l.Thickness = 1
    l.Transparency = 1
    return l
end

local function Skeletonesp(plr)
    repeat wait() until plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil
    local limbs = {}
    local R15 = (plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R15) and true or false
    limbs = {
        -- Spine
        Head_UpperTorso = DrawLine(),
        UpperTorso_LowerTorso = DrawLine(),
        -- Left Arm
        UpperTorso_LeftUpperArm = DrawLine(),
        LeftUpperArm_LeftLowerArm = DrawLine(),
        LeftLowerArm_LeftHand = DrawLine(),
        -- Right Arm
        UpperTorso_RightUpperArm = DrawLine(),
        RightUpperArm_RightLowerArm = DrawLine(),
        RightLowerArm_RightHand = DrawLine(),
        -- Left Leg
        LowerTorso_LeftUpperLeg = DrawLine(),
        LeftUpperLeg_LeftLowerLeg = DrawLine(),
        LeftLowerLeg_LeftFoot = DrawLine(),
        -- Right Leg
        LowerTorso_RightUpperLeg = DrawLine(),
        RightUpperLeg_RightLowerLeg = DrawLine(),
        RightLowerLeg_RightFoot = DrawLine(),
    }
    local function Visibility(state)
        for i, v in pairs(limbs) do
            v.Visible = state
        end
    end

    local function Colorize(color)
        for i, v in pairs(limbs) do
            v.Color = color
        end
    end

    local function UpdaterR15()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 then
                local HUM, vis = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis and esp.settings.skeleton.enabled and esp.enabled then
                    -- Head
                    local H = camera:WorldToViewportPoint(plr.Character.Head.Position)
                    if limbs.Head_UpperTorso.From ~= Vector2.new(H.X, H.Y) then
                        --Spine
                        local UT = camera:WorldToViewportPoint(plr.Character.UpperTorso.Position)
                        local LT = camera:WorldToViewportPoint(plr.Character.LowerTorso.Position)
                        -- Left Arm
                        local LUA = camera:WorldToViewportPoint(plr.Character.LeftUpperArm.Position)
                        local LLA = camera:WorldToViewportPoint(plr.Character.LeftLowerArm.Position)
                        local LH = camera:WorldToViewportPoint(plr.Character.LeftHand.Position)
                        -- Right Arm
                        local RUA = camera:WorldToViewportPoint(plr.Character.RightUpperArm.Position)
                        local RLA = camera:WorldToViewportPoint(plr.Character.RightLowerArm.Position)
                        local RH = camera:WorldToViewportPoint(plr.Character.RightHand.Position)
                        -- Left leg
                        local LUL = camera:WorldToViewportPoint(plr.Character.LeftUpperLeg.Position)
                        local LLL = camera:WorldToViewportPoint(plr.Character.LeftLowerLeg.Position)
                        local LF = camera:WorldToViewportPoint(plr.Character.LeftFoot.Position)
                        -- Right leg
                        local RUL = camera:WorldToViewportPoint(plr.Character.RightUpperLeg.Position)
                        local RLL = camera:WorldToViewportPoint(plr.Character.RightLowerLeg.Position)
                        local RF = camera:WorldToViewportPoint(plr.Character.RightFoot.Position)

                        --Head
                        limbs.Head_UpperTorso.From = Vector2.new(H.X, H.Y)
                        limbs.Head_UpperTorso.To = Vector2.new(UT.X, UT.Y)

                        --Spine
                        limbs.UpperTorso_LowerTorso.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_LowerTorso.To = Vector2.new(LT.X, LT.Y)

                        -- Left Arm
                        limbs.UpperTorso_LeftUpperArm.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_LeftUpperArm.To = Vector2.new(LUA.X, LUA.Y)

                        limbs.LeftUpperArm_LeftLowerArm.From = Vector2.new(LUA.X, LUA.Y)
                        limbs.LeftUpperArm_LeftLowerArm.To = Vector2.new(LLA.X, LLA.Y)

                        limbs.LeftLowerArm_LeftHand.From = Vector2.new(LLA.X, LLA.Y)
                        limbs.LeftLowerArm_LeftHand.To = Vector2.new(LH.X, LH.Y)

                        -- Right Arm
                        limbs.UpperTorso_RightUpperArm.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_RightUpperArm.To = Vector2.new(RUA.X, RUA.Y)

                        limbs.RightUpperArm_RightLowerArm.From = Vector2.new(RUA.X, RUA.Y)
                        limbs.RightUpperArm_RightLowerArm.To = Vector2.new(RLA.X, RLA.Y)

                        limbs.RightLowerArm_RightHand.From = Vector2.new(RLA.X, RLA.Y)
                        limbs.RightLowerArm_RightHand.To = Vector2.new(RH.X, RH.Y)

                        -- Left Leg
                        limbs.LowerTorso_LeftUpperLeg.From = Vector2.new(LT.X, LT.Y)
                        limbs.LowerTorso_LeftUpperLeg.To = Vector2.new(LUL.X, LUL.Y)

                        limbs.LeftUpperLeg_LeftLowerLeg.From = Vector2.new(LUL.X, LUL.Y)
                        limbs.LeftUpperLeg_LeftLowerLeg.To = Vector2.new(LLL.X, LLL.Y)

                        limbs.LeftLowerLeg_LeftFoot.From = Vector2.new(LLL.X, LLL.Y)
                        limbs.LeftLowerLeg_LeftFoot.To = Vector2.new(LF.X, LF.Y)

                        -- Right Leg
                        limbs.LowerTorso_RightUpperLeg.From = Vector2.new(LT.X, LT.Y)
                        limbs.LowerTorso_RightUpperLeg.To = Vector2.new(RUL.X, RUL.Y)

                        limbs.RightUpperLeg_RightLowerLeg.From = Vector2.new(RUL.X, RUL.Y)
                        limbs.RightUpperLeg_RightLowerLeg.To = Vector2.new(RLL.X, RLL.Y)

                        limbs.RightLowerLeg_RightFoot.From = Vector2.new(RLL.X, RLL.Y)
                        limbs.RightLowerLeg_RightFoot.To = Vector2.new(RF.X, RF.Y)
                    end

                    Colorize(esp.settings.skeleton.color)

                    if limbs.Head_UpperTorso.Visible ~= true then
                        Visibility(true)
                    end
                else 
                    if limbs.Head_UpperTorso.Visible ~= false then
                        Visibility(false)
                    end
                end
            else 
                if limbs.Head_UpperTorso.Visible ~= false then
                    Visibility(false)
                end
                if game.Players:FindFirstChild(plr.Name) == nil then 
                    for i, v in pairs(limbs) do
                        v:Remove()
                    end
                    connection:Disconnect()
                end
            end
        end)
    end
    
    coroutine.wrap(UpdaterR15)()
end

for _,v in ipairs(plrs:GetPlayers()) do
    if v ~= plr then
        esp.NewPlayer(v)
        Skeletonesp(v)
    end
end

plrs.ChildAdded:Connect(function(v)
    esp.NewPlayer(v)
    Skeletonesp(v)
end)

plrs.PlayerRemoving:Connect(function(v)
    for i2,v2 in pairs(esp.players[v]) do
        pcall(function()
            v2:Remove()
            v2:Destroy()
        end)
    end

    esp.players[v] = nil
end)

esp.Unload = function()
    esp_Loop:Disconnect()
    esp_Loop = nil
    
    for i,v in pairs(esp.players) do
        for i2, v2 in pairs(v) do
            if v2 == "cham" then
                v2:Destroy()
            else
                v2:Remove()
            end
        end
    end

    table.clear(esp)
    esp = nil
end

getgenv().esp = esp
return esp
