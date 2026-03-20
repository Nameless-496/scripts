--!strict
--!optimize 2
--@version I.C.H.O.R v2
--// Instantaneous Command Highlighting Object Recognition //--

--// Services & Variables //--

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextChannels = TextChatService:WaitForChild("TextChannels")
local RBXGeneral: TextChannel = TextChannels:WaitForChild("RBXGeneral")

local CurrentRoom = workspace.CurrentRoom
local InGamePlayers = workspace.InGamePlayers
local Info = workspace.Info
local BlackOut = Info.BlackOut
local FloorActive = Info.FloorActive
local PickedCharacters = Info.PickedCharacters

local player = Players.LocalPlayer
local CoreGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()

local c = {}
local cache = {
	Machines = false,
	Percentage = false,
	Closest_E = false,
	Closest_P = false,
	Items = false,
	Monsters = false,
	Light = false,
	Waypoints = false,
	
	PShow = false,
	PName = false,
	PToon = false,
	PHearts = false,
	PItems = false,
	PLight = false,
	
	TAG = "I.C.H.O.R._HIGHLIGHT_TAG",
	TotalPages = 0,
	
	CanRefresh = true,
	Toggled = true,
	Collapsed = false,
	Dragging = false,
	DragOffset = Vector2.zero,
	ResizeOffset = Vector2.zero,
	OLD_POSITION = UDim2.new(),
	OLD_SIZE = UDim2.new(),
	DEFAULT_FONT = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold)
}
local CONNECTIONS = {"Connected", "closestPlayerConnect", "runConnect", "UISConnect1", "UISConnect2"}
local CHANGE_CONNECTIONS: {RBXScriptConnection} = {}

local images = {
	Heart = "rbxassetid://16790556042",
	HeartIchor = "rbxassetid://16791471338",
	
	Chocolate = "rbxassetid://17727840139",
	Gumball = "rbxassetid://17728443666",
	Pop = "rbxassetid://17713316055",
	StaminaCandy = "rbxassetid://122723121767996",
	StealthCandy = "rbxassetid://18702541024",
	ExtractionSpeedCandy = "rbxassetid://108547367119591",
	ProteinBar = "rbxassetid://17725435324",
	SkillCheckCandy = "rbxassetid://18702541120",
	SpeedCandy = "rbxassetid://17713663434",
	AirHorn = "rbxassetid://18537864423",
	Bandage = "rbxassetid://17562647343",
	Jawbreaker = "rbxassetid://128185500990835",
	JumperCable = "rbxassetid://17715327284",
	ChocolateBox = "rbxassetid://18853148499",
	HealthKit = "rbxassetid://17564526592",
	PopBottle = "rbxassetid://17714741593",
	EjectButton = "rbxassetid://17727492281",
	Instruction = "rbxassetid://",
	Valve = "rbxassetid://18583522993",
}

local toons = {
	["Blot"] = Color3.new(1, 1, 1),
	["Boxten"] = Color3.fromRGB(144, 58, 140),
	["Brightney"] = Color3.fromRGB(191, 48, 101),
	["Brusha"] = Color3.fromRGB(146, 75, 118),
	["Connie"] = Color3.fromRGB(194, 250, 254),
	["Cosmo"] = Color3.fromRGB(153, 84, 73),
	["Finn"] = Color3.fromRGB(194, 230, 255),
	["Flutter"] = Color3.fromRGB(255, 185, 249),
	["Gigi"] = Color3.fromRGB(231, 93, 103),
	["Glisten"] = Color3.fromRGB(243, 219, 157),
	["Goob"] = Color3.fromRGB(254, 212, 174),
	["Looey"] = Color3.fromRGB(240, 212, 117),
	["Poppy"] = Color3.fromRGB(146, 255, 255),
	["RazzleDazzle"] = Color3.new(1, 1, 1),
	["Rodger"] = Color3.fromRGB(125, 105, 89),
	["Scraps"] = Color3.fromRGB(255, 206, 118),
	["Shrimpo"] = Color3.fromRGB(231, 119, 25),
	["Squirm"] = Color3.fromRGB(162, 217, 130),
	["Teagan"] = Color3.fromRGB(216, 139, 26),
	["Tisha"] = Color3.fromRGB(170, 255, 252),
	["Toodles"] = Color3.new(1, 1, 1),
	["Yatta"] = BrickColor.new("Pink").Color,
	
	["Astro"] = Color3.fromRGB(171, 254, 252),
	["Bassie"] = Color3.fromRGB(168, 122, 98),
	["Bobbete"] = Color3.fromRGB(254, 76, 93),
	["Gourdy"] = Color3.fromRGB(235, 125, 48),
	["Pebble"] = BrickColor.new("Medium stone grey").Color,
	["Shelly"] = Color3.fromRGB(255, 213, 166),
	["Sprout"] = Color3.fromRGB(213, 90, 100),
	["Vee"] = Color3.new(0, 1, 0),
	
	["Coal"] = BrickColor.new("Dark stone grey").Color,
	["Cocoa"] = Color3.fromRGB(158, 99, 69),
	["Eclipse"] = Color3.fromRGB(139, 156, 178),
	["Eggson"] = Color3.fromRGB(252, 165, 81),
	["Flyte"] = Color3.fromRGB(200, 255, 255),
	["Ginger"] = Color3.fromRGB(213, 133, 92),
	["Ribecca"] = Color3.fromRGB(109, 254, 89),
	["Rudie"] = Color3.new(1, 0, 0),
	["Soulvester"] = Color3.fromRGB(129, 215, 179),
	
	["Dandy"] = Color3.new(1, 1, 0),
	["Dyle"] = Color3.fromRGB(185, 156, 109),
}

local ItemsRarity = {
	Rare = {"AirHorn", "Bandage", "Jawbreaker", "JumperCable"},
	VeryRare = {"Boxo'Chocolates", "HealthKit", "Bottleo'Pop"},
	UltraRare = {"EjectButton", "SmokeBomb", "Valve"}
}

local Colors = {
	Primary = BrickColor.new("Storm blue").Color,
	Secondary = BrickColor.new("Earth blue").Color,
	Tertiary = BrickColor.new("Medium blue").Color,
	BLACK = Color3.new(0, 0, 0),
	WHITE = Color3.new(1, 1, 1),
	GREEN = Color3.new(0, 1, 0),
	RED = Color3.new(1, 0, 0),
	CYAN = Color3.new(0, 1, 1),
}

local tweens = {}

--// Functions //--

task.defer(function()
	local mt = '<font color="#000000"><stroke color="#FFFFFF">{msg}</stroke></font>'
	local function msg(str: string)
		local m = mt:gsub("{msg}", str)
		return m
	end
	
	RBXGeneral:DisplaySystemMessage(msg("INSERTED I.C.H.O.R."))
	RBXGeneral:DisplaySystemMessage(msg("THANK YOU FOR CHOOSING OUR SERVICES<br/>|| Instantaneous Command Highlighting Object Recognition "))
end)

--> Gui creation

local function setPropertySafe(instance: any, property: string, value: any): boolean
	return (pcall(function()
		instance[property] = value
	end))
end

local function createInstance(classname: string, parent: Instance?, properties: { [string]: any }?)
	local success, instance = pcall(Instance.new, classname)
	if not success then error(instance) end
	
	if properties then
		for property, value in pairs(properties) do
			setPropertySafe(instance, property, value)
		end
	end
	instance.Parent = parent
	return instance
end

local function corners(instances: {Instance}, radius: number)
	for _, instance in instances do
		createInstance("UICorner", instance, { CornerRadius = UDim.new(0, radius) })
	end
end

local function Copy(from: Instance, to: Instance, changes: { [string]: any }?): any
	local clone = from:Clone()
	if changes then
		for property, value in pairs(changes) do
			setPropertySafe(clone, property, value)
		end
	end
	clone.Parent = to
	return clone
end

local gui: ScreenGui =				createInstance("ScreenGui", CoreGui, { DisplayOrder = 852655, IgnoreGuiInset = true, Name = "I.C.H.O.R.", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
local canvas: CanvasGroup =			createInstance("CanvasGroup", gui, { GroupTransparency = 1, BackgroundColor3 = Colors.Secondary, InputSink = Enum.InputSink.All, Position = UDim2.fromScale(1, 0), Size = UDim2.new() })
local uicorner: UICorner =			createInstance("UICorner", canvas)

local title: TextLabel =			createInstance("TextLabel", canvas, { BackgroundTransparency = 1, Name = "Title", Size = UDim2.new(1, -113, 0, 25), ZIndex = 3, FontFace = cache.DEFAULT_FONT, Text = "I.C.H.O.R.", TextColor3 = Color3.new(1, 1, 1), TextScaled = false, TextSize = 21, TextTruncate = Enum.TextTruncate.SplitWord ,TextXAlignment = Enum.TextXAlignment.Left })
local titlePadding: UIPadding = 	createInstance("UIPadding", title, { PaddingBottom = UDim.new(0, 2), PaddingLeft = UDim.new(0, 5), PaddingTop = UDim.new(0, 2) })

local toggleButton: TextButton =	createInstance("TextButton", canvas, { AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Name = "Toggle", Position = UDim2.fromScale(1, 0), Size = UDim2.fromOffset(22, 25), ZIndex = 3, FontFace = cache.DEFAULT_FONT, Text = "X", TextColor3 = Color3.new(1, 1, 1), TextScaled = true })
local togglePadding: UIPadding = 	createInstance("UIPadding", toggleButton, { PaddingBottom = UDim.new(0, 1) })

local miniButton: ImageButton =		createInstance("ImageButton", canvas, { AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Name = "Minimizer", Position = UDim2.new(1, -22), Size = UDim2.fromOffset(22, 25), ZIndex = 3, Image = "" })
local miniMax: Frame =				createInstance("Frame", miniButton, { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Name = "Maximize", Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.75, 0.75), Visible = false, ZIndex = 3 })
local maxStroke: UIStroke =			createInstance("UIStroke", miniMax, { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, BorderStrokePosition = Enum.BorderStrokePosition.Inner, Color = Color3.new(1, 1, 1), LineJoinMode = Enum.LineJoinMode.Round, Thickness = 2 })
local miniRestore: Frame =			createInstance("Frame", miniButton, { AnchorPoint = Vector2.new(0, 1), BackgroundTransparency = 1, Name = "Restore", Position = UDim2.fromScale(0.2, 0.8), Size = UDim2.fromScale(0.5, 0.5), ZIndex = 3 })
local restoreStroke: UIStroke =		Copy(maxStroke, miniRestore)
local frame2: Frame =				createInstance("Frame", miniRestore, { BackgroundColor3 = Colors.WHITE, Position = UDim2.fromScale(0.2, -0.3), Size = UDim2.fromScale(1, 0.2), ZIndex = 3 })
local frame3: Frame =				Copy(frame2, miniRestore, { Position = UDim2.fromScale(1.1, -0.3), Size = UDim2.fromScale(0.2, 1.1) })

local emptyButton: TextButton =		Copy(toggleButton, canvas, { Name = "Empty", Position = UDim2.new(1, -44), Text = "E" })
local fillButton: TextButton =		Copy(toggleButton, canvas, { Name = "Fill", Position = UDim2.new(1, -66), Text = "F" })
local refreshButton: TextButton =	Copy(toggleButton, canvas, { Name = "Refresh", Position = UDim2.new(1, -88), Text = "R" })

local topbar: Frame =				createInstance("Frame", canvas, { BackgroundColor3 = Colors.Primary, Name = "Topbar", Size = UDim2.new(1, 0, 0, 25) })
local dragger: UIDragDetector =		createInstance("UIDragDetector", topbar, { DragStyle = Enum.UIDragDetectorDragStyle.Scriptable })
local frame4: Frame =				createInstance("Frame", topbar, { AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Colors.Primary, BorderSizePixel = 0, Position = UDim2.fromScale(0, 1), Size = UDim2.fromScale(1, 0.5), ZIndex = 2 })
local divider: Frame =				createInstance("Frame", topbar, { AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Colors.Tertiary, BorderSizePixel = 0, Position = UDim2.fromScale(0, 1), Size = UDim2.fromOffset(0, 2), ZIndex = 3 })
local frame4corner: UICorner =		createInstance("UICorner", frame4, { CornerRadius = UDim.new(0, 0) })

local resizerFrame: Frame =			createInstance("Frame", canvas, { AnchorPoint = Vector2.new(0, 1), BackgroundTransparency = 1, Name = "Resizer", Position = UDim2.fromScale(0, 1), Size = UDim2.fromOffset(15, 15) })
local resizer: UIDragDetector =		Copy(dragger, resizerFrame)
local resizeArrow: Frame =			createInstance("Frame", resizerFrame, { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Colors.Tertiary, BorderSizePixel = 0, Name = "Arrow", Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.5, 0.5) })
local arrowGradient: UIGradient =	createInstance("UIGradient", resizeArrow, { Rotation = 135, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.499, 0), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 1) })})

local content: CanvasGroup =		createInstance("CanvasGroup", canvas, { BackgroundTransparency = 1, Name = "Content", Position = UDim2.fromOffset(0, 25), Size = UDim2.new(1, 0, 1, -25) })
local contentPadding: UIPadding =	createInstance("UIPadding", content, { PaddingBottom = UDim.new(0, 1), PaddingLeft = UDim.new(0, 1), PaddingRight = UDim.new(0, 1), PaddingTop = UDim.new(0, 1) })

local pageButtons: ScrollingFrame =	createInstance("ScrollingFrame", content, { BackgroundTransparency = 1, Name = "Buttons", Size = UDim2.new(1, 0, 0, 30), AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(), ScrollBarImageColor3 = Colors.Tertiary, ScrollBarThickness = 2 })
local btnsPadding: UIPadding =		createInstance("UIPadding", pageButtons, { PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingTop = UDim.new(0, 5) })
local btnsLayout: UIListLayout =	createInstance("UIListLayout", pageButtons, { Padding = UDim.new(0, 5), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center })

local contentPage: Frame =			createInstance("Frame", content, { BackgroundTransparency = 1, Name = "PageFrame", Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, 0, 1, -30) })
local pagePadding: UIPadding =		Copy(contentPadding, contentPage)
local pageLayout: UIPageLayout =	createInstance("UIPageLayout", contentPage, { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, GamepadInputEnabled = false, ScrollWheelInputEnabled = false, TouchInputEnabled = false })

local tempPage: ScrollingFrame =	createInstance("ScrollingFrame", nil, { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollBarImageColor3 = Colors.Tertiary, ScrollBarThickness = 5 })
local tempP_layout: UIListLayout =	createInstance("UIListLayout", tempPage, { SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center })

local bottomDragFrame: Frame =			createInstance("Frame", gui, { BackgroundColor3 = Colors.WHITE, BackgroundTransparency = 1, InputSink = Enum.InputSink.All, Name = "BottomDragger", Position = UDim2.fromScale(1, 0), Size = UDim2.new() })
local bottomDragger: UIDragDetector =	createInstance("UIDragDetector", bottomDragFrame)

local miniToggle: TextButton =			Copy(toggleButton, gui, { AnchorPoint = Vector2.zero, BackgroundColor3 = Colors.Tertiary, BorderSizePixel = 2, InputSink = Enum.InputSink.All, Visible = false })
local minitoggle_outline: Frame =		createInstance("Frame", miniToggle, { AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = Colors.BLACK, Name = "Outline", Position = UDim2.new(0.5, 0, 1, 4), Size = UDim2.new(2, 0, 0, 5), Visible = false })
local minitoggle_padding: UIPadding =	Copy(contentPadding, minitoggle_outline)
local minitoggle_back: Frame =			createInstance("Frame", minitoggle_outline, { BackgroundColor3 = Color3.new(0.5, 0.5, 0.5), Name = "Background", Size = UDim2.fromScale(1, 1) })
local minitoggle_fill: Frame =			createInstance("Frame", minitoggle_back, { BackgroundColor3 = Colors.WHITE, Name = "Fill", Size = UDim2.fromScale(0, 1) })

corners({frame2, frame3, topbar, bottomDragFrame}, 8)

--> Functions and Initialization

task.wait(3)
local apos = canvas.AbsolutePosition.X

local function tween(instance: Instance, config: (number | TweenInfo)?, goal: { [string]: any }, WaitForLastTween: boolean?): Tween
	if typeof(config) ~= "TweenInfo" then
		config = TweenInfo.new(config or 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end
	
	if tweens[instance] and not WaitForLastTween then
		tweens[instance]:Cancel()
		tweens[instance] = nil
	end
	
	local tweenObject = TweenService:Create(instance, config, goal)
	if WaitForLastTween then
		local WAIT
		WAIT = RunService.Heartbeat:Connect(function()
			if not tweens[instance] then
				WAIT:Disconnect()
				tweens[instance] = tweenObject
				tweenObject.Completed:Once(function()
					tweenObject:Destroy()
					tweens[instance] = nil
				end)
				tweenObject:Play()
			end
		end)
		return tweenObject
	end
	
	tweens[instance] = tweenObject
	tweenObject.Completed:Once(function()
		tweenObject:Destroy()
		tweens[instance] = nil
	end)
	tweenObject:Play()
	return tweenObject
end

local function highlight(parent: Instance, color: Color3, text: string, stroke: Color3?, twisted: boolean?)
	local stroke = stroke or Colors.BLACK
	local function addBillboard(p: Instance, offset: Vector3?)
		local BillboardGui: BillboardGui =	createInstance("BillboardGui", p, { Adornee = p, AlwaysOnTop = true, Name = "I.C.H.O.R. | BillboardGui", Size = UDim2.fromScale(5, 2.5), StudsOffsetWorldSpace = offset or Vector3.zero, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ClipsDescendants = true })
		local TextLabel: TextLabel =		createInstance("TextLabel", BillboardGui, { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.RobotoMono, Text = text, TextColor3 = color, TextScaled = true, TextStrokeColor3 = stroke, TextStrokeTransparency = 0 })
		BillboardGui:AddTag(cache.TAG)
	end
	
	local Highlight = parent:FindFirstChild("I.C.H.O.R. | Highlight")
	if Highlight and Highlight:IsA("Highlight") then
		Highlight.FillColor = color
		Highlight.OutlineColor = color
	else
		local newLight: Highlight = createInstance("Highlight", parent, { Adornee = parent, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, FillColor = color, FillTransparency = 0.75, Name = "I.C.H.O.R. | Highlight", OutlineColor = color })
		newLight:AddTag(cache.TAG)
		Highlight = newLight
	end
	
	local function check(p: Instance, offset: Vector3?)
		local BillboardGui = p:FindFirstChild("I.C.H.O.R. | BillboardGui")
		if BillboardGui and BillboardGui:IsA("BillboardGui") then
			if offset then BillboardGui.StudsOffsetWorldSpace = offset end
			local TextLabel = BillboardGui:FindFirstChildOfClass("TextLabel")
			if TextLabel then
				TextLabel.Text = text
				TextLabel.TextColor3 = color
				TextLabel.TextStrokeColor3 = stroke
			end
		else
			addBillboard(p, offset)
		end
	end
	
	local Ichor = parent:FindFirstChild("Ichor")
	if Ichor then check(Ichor) else
		check(parent, Vector3.new(0, twisted and 5 or 3, 0))
	end
end

local function darkenColor(col: Color3)
	local h, s, v = col:ToHSV()
	v = math.clamp(v * 0.5, 0, 1)
	return Color3.fromHSV(h, s, v)
end

local function PlayerHighlight(parent: Instance, name: string, heart: number, slot: StringValue?)
	local inventory = parent:FindFirstChild("Inventory")
	if not inventory then return end
	
	local pickedValue = PickedCharacters:FindFirstChild(parent.Name) :: StringValue
	local picked = pickedValue.Value
	local pickedColor = toons[picked]
	
	local Highlight = parent:FindFirstChild("I.C.H.O.R. | Highlight") :: Highlight?
	if not Highlight then
		local newLight: Highlight = createInstance("Highlight", parent, { Adornee = parent, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, FillColor = pickedColor, FillTransparency = 0.75, Name = "I.C.H.O.R. | Highlight", OutlineColor = pickedColor })
		newLight:AddTag(cache.TAG)
		Highlight = newLight
	end
	
	local billboardGui = parent:FindFirstChild("I.C.H.O.R. | BillboardGui") :: BillboardGui?
	if not billboardGui then
		local billboardGui: BillboardGui =	createInstance("BillboardGui", parent, { Adornee = parent, AlwaysOnTop = true, Name = "I.C.H.O.R. | BillboardGui", Size = UDim2.fromOffset(100, 50), StudsOffsetWorldSpace = Vector3.new(0, 4, 0), ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ClipsDescendants = true })
		billboardGui:AddTag(cache.TAG)
		
		local bbguiLayout: UIListLayout =	createInstance("UIListLayout", billboardGui, { SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom })
		local TextLabel: TextLabel =		createInstance("TextLabel", billboardGui, { BackgroundTransparency = 1, LayoutOrder = 0, Size = UDim2.fromScale(1, 1/4), Visible = cache.PName, Font = Enum.Font.RobotoMono, Text = name, TextColor3 = Colors.CYAN, TextScaled = true, TextStrokeColor3 = Color3.new(0, 0.5, 0.5), TextStrokeTransparency = 0 })
		local ToonLabel: TextLabel =		Copy(TextLabel, billboardGui, { LayoutOrder = -1, Name = "ToonLabel", Visible = cache.PToon, Text = `[{picked}]`, TextColor3 = pickedColor, TextStrokeColor3 = darkenColor(pickedColor) })
		
		local Hearts: Frame =				createInstance("Frame", billboardGui, { BackgroundTransparency = 1, LayoutOrder = -2, Name = "Hearts", Size = UDim2.fromScale(1, 1/4), Visible = cache.PHearts })
		local heartsLayout: UIListLayout =	createInstance("UIListLayout", Hearts, { Padding = UDim.new(0, 10), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center })
		local Items: Frame =				Copy(Hearts, billboardGui, { LayoutOrder = -3, Name = "Items", Visible = cache.PItems })
		
		local h = 0
		repeat h += 1
			local Heart: ImageLabel =				createInstance("ImageLabel", Hearts, { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = h, Name = `Heart{h}`, Size = UDim2.fromScale(1, 1), Image = images.Heart })
			local UIARC: UIAspectRatioConstraint =	createInstance("UIAspectRatioConstraint", Heart, { AspectRatio = 1 })
		until h == heart
		
		local i = 0
		repeat i += 1
			local Slot: ImageLabel =				createInstance("ImageLabel", Items, { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = i, Name = `Slot{i}`, Size = UDim2.fromScale(1, 1) })
			createInstance("UIAspectRatioConstraint", Slot, { AspectRatio = 1 })
			createInstance("UIStroke", Slot, { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, BrickColor = BrickColor.new("Black"), LineJoinMode = Enum.LineJoinMode.Miter, Transparency = 0.75 })
			
			local BackupText: TextLabel =	createInstance("TextLabel", Slot, { BackgroundTransparency = 1, Name = "BackupText", Size = UDim2.fromScale(1, 1), Visible = false, FontFace = Font.fromName("RobotoMono", Enum.FontWeight.Bold), Text = "", TextColor3 = Colors.WHITE, TextScaled = true, TextStrokeColor3 = Colors.BLACK, TextStrokeTransparency = 0 })
			local Charges: TextLabel =		createInstance("TextLabel", Slot, { AnchorPoint = Vector2.new(0, 1), BackgroundTransparency = 1, Name = "Charges", Position = UDim2.fromScale(0, 1), Size = UDim2.fromScale(1, 0.4), Visible = false, FontFace = Font.fromName("RobotoMono", Enum.FontWeight.Bold), Text = "3/3", TextColor3 = Colors.WHITE, TextScaled = true, TextStrokeColor3 = Colors.BLACK, TextStrokeTransparency = 0 })
			
			local inv = inventory:FindFirstChild(`Slot{i}`) :: StringValue?
			if not inv or inv.Value == "None" then
				Slot.Image = ""
			else
				local img = images[inv.Value]
				if img then
					BackupText.Visible = false
					Slot.Image = img
				else
					BackupText.Visible = true
					BackupText.Text = inv.Value
				end
			end
			
			local UsageCharges = inv and inv:FindFirstChild("Charges") or nil
			if UsageCharges and UsageCharges:IsA("NumberValue") then
				local Current = (inv and inv:FindFirstChild("Current")) :: StringValue
				
				Charges.Visible = true
				Charges.Text = tostring(Current.Value).."/"..tostring(UsageCharges.Value)
				Current.Changed:Connect(function()
					Charges.Text = tostring(Current.Value).."/"..tostring(UsageCharges.Value)
				end)
			else
				Charges.Visible = false
			end
		until i == 3
	else
		local Hearts = billboardGui:FindFirstChild("Hearts") :: Frame
		local Items = billboardGui:FindFirstChild("Items") :: Frame
		local TextLabel = billboardGui:FindFirstChild("TextLabel") :: TextLabel
		local ToonLabel = billboardGui:FindFirstChild("ToonLabel") :: TextLabel
		Hearts.Visible = cache.PHearts
		Items.Visible = cache.PItems
		TextLabel.Visible = cache.PName
		ToonLabel.Visible = cache.PToon
		
		if cache.PHearts then
			local h = #Hearts:GetChildren() - 1
			
			if h < heart then
				repeat h += 1
					local Heart: ImageLabel =				createInstance("ImageLabel", Hearts, { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, LayoutOrder = h, Name = `Heart{h}`, Size = UDim2.fromScale(1, 1), Image = images.Heart })
					local UIARC: UIAspectRatioConstraint =	createInstance("UIAspectRatioConstraint", Heart, { AspectRatio = 1 })
				until h == heart
			elseif h > heart then
				repeat h -= 1
					local Heart = Hearts:FindFirstChild("`Heart{h + 1}`")
					if Heart then Heart:Destroy() end
				until h == heart
			end
		end
		
		if cache.PItems then
			for _, s in Items:GetChildren() do
				if not slot or not s:IsA("ImageLabel") then continue end
				if s.Name == slot.Name then
					local img = images[slot.Value]
					local but = s:FindFirstChild("BackupText") :: TextLabel
					if img then
						but.Visible = false
						s.Image = img
					else
						but.Visible = true
						but.Text = slot.Value
					end
					
					local Charges = s:FindFirstChild("Charges") :: TextLabel
					local UsageCharges = slot:FindFirstChild("Charges")
					if UsageCharges and UsageCharges:IsA("NumberValue") then
						local Current = slot:FindFirstChild("Current") :: StringValue
						
						Charges.Visible = true
						Charges.Text = tostring(Current.Value).."/"..tostring(UsageCharges.Value)
						Current.Changed:Connect(function()
							Charges.Text = tostring(Current.Value).."/"..tostring(UsageCharges.Value)
						end)
					else
						Charges.Visible = false
					end
				end
			end
		end
		
		local rootPart = parent:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end
		if cache.PLight and BlackOut.Value then
			local PL = createInstance("PointLight", rootPart, { Brightness = 1, Range = 24, Name = "I.C.H.O.R. | PointLight" })
			PL:AddTag(cache.TAG)
		elseif not cache.Light then
			local PL = rootPart:FindFirstChild("I.C.H.O.R. | PointLight")
			if PL then PL:Destroy() end
		end
	end
end

local function setCanRefresh(can: boolean)
	cache.CanRefresh = can
	refreshButton.Interactable = can
	refreshButton.TextColor3 = can and Colors.WHITE or Color3.new(0.5, 0.5, 0.5)
end

local function destroy(target: string)
	local folder = (target == "PLAYER" and InGamePlayers) or CurrentRoom:FindFirstChild(target, true)
	for _, v in CollectionService:GetTagged(cache.TAG) do
		if v:IsDescendantOf(folder) then
			v:Destroy()
		end
	end
end

local function setnil(sets: {string})
	for _, set in sets do
		if cache[set] then
			cache[set]:Disconnect()
			cache[set] = nil
		end
	end
end

local function refresh(value: boolean?)
	if not cache.CanRefresh or value == false then return end
	setCanRefresh(false)
	
	for _, CONN in CHANGE_CONNECTIONS do
		CONN:Disconnect()
	end
	table.clear(CHANGE_CONNECTIONS)
	
	local Floor = #CurrentRoom:GetChildren()
	if Floor ~= 0 then
		if not cache.Machines then destroy("Generators") else
			local minDistance = math.huge
			local closestGenElevator
			local folder = CurrentRoom:FindFirstChild("Generators", true)
			
			local function buildMessage(gen)
				local msg = "Machine [{p}]"
				if cache.Closest_E and closestGenElevator == gen then
					msg ..= "[CtE]"
				end
				if cache.Closest_P and cache.closestGenerator == gen then
					msg ..= "[CtP]"
				end
				return msg
			end
			
			for _, gen in folder:GetChildren() do
				local IchorFull = gen:FindFirstChild("IchorFull", true)
				if IchorFull and IchorFull:IsA("BasePart") then
					local distance_E = (Info.ElevatorPrompt.Position - IchorFull.Position).Magnitude
					if distance_E < minDistance then
						minDistance = distance_E
						closestGenElevator = gen
					end
				end
			end
			
			for _, gen in folder:GetChildren() do
				local gStats = gen:FindFirstChild("Stats") :: Folder
				local completed = gStats:FindFirstChild("Completed") :: BoolValue
				local Connie = gStats:FindFirstChild("Connie") :: BoolValue
				local Ichor = gen:FindFirstChild("Ichor") :: Part
				local IchorFull = gen:FindFirstChild("IchorFull") :: Part
				local percent = math.floor(100 * Ichor.Size.X / IchorFull.Size.X)
				local per = percent .. "%%"
				
				local function setPercentage()
					if cache.Percentage and not completed.Value then
						percent = math.floor(100 * Ichor.Size.X / IchorFull.Size.X)
						per = percent .. "%%"
						local str = buildMessage(gen):gsub("{p}", 100 / (IchorFull.Size.X/Ichor.Size.X) < 1 and "%%" or per)
						highlight(gen, Colors.RED, str)
					else
						local str = buildMessage(gen):gsub("{p}", "incomplete")
						highlight(gen, Colors.RED, str)
					end
				end
				setPercentage()
				table.insert(CHANGE_CONNECTIONS, Ichor:GetPropertyChangedSignal("Size"):Connect(setPercentage))
				
				if completed.Value then
					local str = buildMessage(gen):gsub("{p}", cache.Percentage and "100%%" or "completed")
					highlight(gen, Colors.GREEN, str)
				end
				if Connie.Value then
					local str = buildMessage(gen):gsub("{p}", "Haunted")
					highlight(gen, Colors.CYAN, str)
				end
				
				table.insert(CHANGE_CONNECTIONS, completed.Changed:Connect(function(value: boolean)
					if value then
						local str = buildMessage(gen):gsub("{p}", "completed")
						highlight(gen, Colors.GREEN, str)
					end
				end))
				
				table.insert(CHANGE_CONNECTIONS, Connie.Changed:Connect(function()
					if completed.Value then
						local str = buildMessage(gen):gsub("{p}", "Haunted")
						highlight(gen, Colors.CYAN, str)
					else
						if cache.Percentage then
							local str = buildMessage(gen):gsub("{p}", per)
							highlight(gen, completed.Value and Colors.GREEN or Colors.RED, str)
						else
							local col = completed.Value and Colors.GREEN or Colors.RED
							local str = buildMessage(gen):gsub("{p}", completed.Value and "completed" or "incomplete")
							highlight(gen, col, str)
						end
					end
				end))
			end
			
			setnil({"closestPlayerConnect"})
			if cache.Closest_P then
				local accum = 0
				cache["closestPlayerConnect"] = RunService.Heartbeat:Connect(function(delta: number)
					accum += delta
					if accum < 0.1 then return end
					accum = 0
					
					local rootPart = character:FindFirstChild("HumanoidRootPart")
					if not rootPart then return end
					local playerPos = rootPart.Position
					local closest
					local minDist = math.huge
					
					for _, gen in folder:GetChildren() do
						local ichorFull = gen:FindFirstChild("IchorFull", true)
						if ichorFull and ichorFull:IsA("BasePart") then
							local dist = (playerPos - ichorFull.Position).Magnitude
							if dist < minDist then
								minDist = dist
								closest = gen
							end
						end
					end
					
					if closest ~= cache.closestGenerator then
						cache.closestGenerator = closest
						refresh()
					end
				end)
			end
		end
		
		if not cache.Items then destroy("Items") else
			local folder = CurrentRoom:FindFirstChild("Items", true)
			for _, item in folder:GetChildren() do
				if item.Name == "ResearchCapsule" then
					local name = item.Prompt.Monster.Value or ""
					name = string.gsub(name, "Monster", "") .. item.Name
					highlight(item, Colors.WHITE, name)
				elseif item.Name == "FakeCapsule" then
					local col = cache.Monsters and Colors.RED or Colors.WHITE
					local nam = cache.Monsters and "Rodger" or "RodgerResearchCapsule"
					local str = cache.Monsters and Colors.WHITE or nil
					local twi = cache.Monsters
					highlight(item, col, nam, str, twi)
				elseif table.find(ItemsRarity.Rare, item.Name) then
					highlight(item, Color3.new(1, 1, 0), item.Name, Color3.new(0.5, 0.5, 0))
				elseif table.find(ItemsRarity.VeryRare, item.Name) then
					highlight(item, Color3.new(1, 0, 1), item.Name, Color3.new(0.5, 0, 0.5))
				elseif table.find(ItemsRarity.UltraRare, item.Name) then
					highlight(item, Color3.new(0.5, 0, 1), item.Name, Color3.new(0.25, 0, 0.5))
				else
					highlight(item, Colors.WHITE, item.Name)
				end
			end
		end
		
		if not cache.Monsters then destroy("Monsters") else
			local folder = CurrentRoom:FindFirstChild("Monsters", true)
			for _, mons in folder:GetChildren() do
				local name = string.gsub(mons.Name, "Monster", "")
				if name == "Rodger" then
					for _, r in CurrentRoom:GetDescendants() do
						if r.Name == "FakeCapsule" then
							highlight(r, Colors.RED, name, Colors.WHITE, true)
						end
					end
				else
					local rootPart = mons:FindFirstChild("HumanoidRootPart")
					if rootPart then
						if cache.Light and BlackOut.Value then
							if not rootPart:FindFirstChild("I.C.H.O.R. | PointLight") then
								local PL = createInstance("PointLight", rootPart, { Brightness = 1, Range = 24, Name = "I.C.H.O.R. | PointLight" })
								PL:AddTag(cache.TAG)
							end
						elseif not cache.Light then
							local PL = rootPart:FindFirstChild("I.C.H.O.R. | PointLight")
							if PL then PL:Destroy() end
						end
						highlight(mons, Colors.RED, name, Colors.WHITE, true)
					end
				end
			end
		end
		
		do
			local folder = CurrentRoom:FindFirstChild("Waypoints", true)
			for _, waypoint in folder:GetChildren() do
				if not waypoint:IsA("BasePart") then continue end
				waypoint.Transparency = cache.Waypoints and 0 or 1
			end
		end
		
		if not cache.PShow then destroy("PLAYER") else
			for _, char in InGamePlayers:GetChildren() do
				if char ~= character then
					local name = char.Name
					local Health = char.Stats.Health
					local Inventory = char.Inventory
					local Slot1, Slot2, Slot3
					
					if cache.PItems then
						for i, slot in pairs(Inventory:GetChildren()) do
							if i == 1 then
								Slot1 = slot
							elseif i == 2 then
								Slot2 = slot
							else
								Slot3 = slot
							end
							if slot.Value ~= "None" then
								PlayerHighlight(char, char.Name, Health.Value, slot)
							end
						end
						
						table.insert(CHANGE_CONNECTIONS, Slot1.Changed:Connect(function()
							PlayerHighlight(char, char.Name, Health.Value, Slot1)
						end))
						
						table.insert(CHANGE_CONNECTIONS, Slot2.Changed:Connect(function()
							PlayerHighlight(char, char.Name, Health.Value, Slot2)
						end))
						
						table.insert(CHANGE_CONNECTIONS, Slot3.Changed:Connect(function()
							PlayerHighlight(char, char.Name, Health.Value, Slot3)
						end))
					else
						PlayerHighlight(char, char.Name, Health.Value)
					end
					
					table.insert(CHANGE_CONNECTIONS, Health.Changed:Connect(function()
						if cache.Hearts then
							PlayerHighlight(char, char.Name, Health.Value)
						end
					end))
					
					PlayerHighlight(char, char.Name, Health.Value)
				end
			end
		end
	end
	
	for btn, nam in pairs(c) do
		btn.Text = cache[nam] and "ON" or "OFF"
	end
	
	setCanRefresh(true)
end

local function createPage(title: string, buttons_data: { [string]: { label: string, index: number }})
	cache.TotalPages += 1
	local newPage: ScrollingFrame =	Copy(tempPage, contentPage, { Name = title })
	local newButton: TextButton =	createInstance("TextButton", pageButtons, { BackgroundColor3 = Colors.Tertiary, BorderSizePixel = 0, Name = title, Size = UDim2.new(0, 75, 1), FontFace = cache.DEFAULT_FONT, Text = title, TextSize = 14, TextColor3 = Colors.WHITE })
	corners({newButton}, 8)
	
	if cache.TotalPages == 1 then
		cache["CurrentPageButton"] = newButton
		newButton.Interactable = false
		newButton.BackgroundColor3 = Color3.fromRGB(77, 107, 141)
	end
	
	newButton.Activated:Connect(function()
		cache["CurrentPageButton"].Interactable = true
		cache["CurrentPageButton"].BackgroundColor3 = Colors.Tertiary
		
		newButton.Interactable = false
		newButton.BackgroundColor3 = Color3.fromRGB(77, 107, 141)
		
		pageLayout:JumpTo(newPage)
		cache["CurrentPageButton"] = newButton
	end)
	
	for name, data in pairs(buttons_data) do
		local page_buttonframe: Frame =			createInstance("Frame", newPage, { BackgroundTransparency = 1, LayoutOrder = data.index, Name = name, Size = UDim2.new(1, 0, 0, 30) })
		local page_buttonpadding: UIPadding =	Copy(titlePadding, page_buttonframe, { PaddingRight = UDim.new(0, 5) })
		local page_buttonlabel: TextLabel =		createInstance("TextLabel", page_buttonframe, { BackgroundTransparency = 1, Size = UDim2.fromScale(0.75, 1), FontFace = Font.fromName("Montserrat"), Text = data.label, TextColor3 = Colors.WHITE, TextSize = 21, TextTruncate = Enum.TextTruncate.SplitWord, TextXAlignment = Enum.TextXAlignment.Left })
		
		local page_buttonhitbox: TextButton = createInstance("TextButton", page_buttonframe, { AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Colors.Tertiary, BorderSizePixel = 0, Name = "Button", Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromScale(0.25, 1), FontFace = cache.DEFAULT_FONT, Text = "OFF", TextColor3 = Colors.WHITE, TextScaled = true })
		corners({page_buttonhitbox}, 4)
		
		if cache[name] == nil then continue end
		c[page_buttonhitbox] = name
		
		page_buttonhitbox.Activated:Connect(function()
			if not cache.CanRefresh then return end
			cache[name] = not cache[name]
			refresh()
		end)
	end
end

canvas.Changed:Connect(function()
	miniToggle.Position = canvas.Position
	miniToggle.Size = canvas.Size
end)

do --> Initialize
	createPage("Machines", {
		["Machines"] =		{ index = 1, label = "Show Machines"		},
		["Percentage"] =	{ index = 2, label = "Show Percentage"		},
		["Closest_E"] =		{ index = 3, label = "Closest To Elevator"	},
		["Closest_P"] =		{ index = 4, label = "Closest To Player"	},
	})
	
	createPage("Items", {
		["Items"] = { index = 1, label = "Show Items" },
	})
	
	createPage("Monsters", {
		["Monsters"] =	{ index = 1, label = "Show Monsters"		},
		["Light"] =		{ index = 2, label = "Light on Blackout"	},
		["Waypoints"] =	{ index = 3, label = "Show Waypoints"		},
	})
	
	createPage("Players", {
		["PShow"] =		{ index = 1, label = "Show Players"			},
		["PName"] =		{ index = 2, label = "Show Names"			},
		["PToon"] =		{ index = 3, label = "Show Toon's Name"		},
		["PHearts"] =	{ index = 4, label = "Show Hearts"			},
		["PItems"] =	{ index = 6, label = "Show Items"			},
		["PLight"] =	{ index = 7, label = "Light on Blackout"	},
	})
	
	cache["Connected"] = FloorActive.Changed:Connect(refresh)
	canvas.Position = UDim2.fromOffset(apos, 0)
	bottomDragFrame.Position = UDim2.fromOffset(apos, 5)
	tween(canvas, 1, { GroupTransparency = 0, Position = UDim2.fromOffset(apos - 310, 10), Size = UDim2.fromOffset(300, 300) })
	tween(divider, 2, { Size = UDim2.new(1, 0, 0, 2) })
	local t = tween(bottomDragFrame, 1, { BackgroundTransparency = 0, Position = UDim2.fromOffset(apos - 285, 315), Size = UDim2.fromOffset(250, 4) })
	t.Completed:Wait()
	tween(bottomDragFrame, 1, {BackgroundTransparency = 1})
end

--> UI Dragging

canvas.MouseEnter:Connect(function()
	tween(bottomDragFrame, nil, {BackgroundTransparency = 0.5}, true)
end)

bottomDragFrame.MouseEnter:Connect(function()
	tween(bottomDragFrame, nil, {BackgroundTransparency = 0}, true)
end)

local function mouseLeave()
	if cache.Dragging then return end
	tween(bottomDragFrame, nil, {BackgroundTransparency = 1}, true)
end
canvas.MouseLeave:Connect(mouseLeave)
bottomDragFrame.MouseLeave:Connect(mouseLeave)

local function dragStart(inputpos: Vector2)
	cache.Dragging = true
	cache.DragOffset = canvas.AbsolutePosition - inputpos
	cache.ResizeOffset = inputpos
	cache.OLD_POSITION = canvas.Position
	cache.OLD_SIZE = canvas.Size
end

local function dragEnd()
	cache.Dragging = false
end

dragger.DragStart:Connect(dragStart)
dragger.DragEnd:Connect(dragEnd)
bottomDragger.DragStart:Connect(dragStart)
bottomDragger.DragEnd:Connect(dragEnd)
resizer.DragStart:Connect(dragStart)
resizer.DragEnd:Connect(dragEnd)

dragger.DragContinue:Connect(function(inputpos: Vector2)
	if not cache.Dragging then return end
	local pos = cache.DragOffset + inputpos + Vector2.new(0, 58)
	canvas.Position = UDim2.fromOffset(pos.X, pos.Y)
	bottomDragFrame.Position = canvas.Position + UDim2.fromOffset(25, canvas.Size.Y.Offset + 5)
end)

bottomDragger.DragContinue:Connect(function()
	if not cache.Dragging then return end
	tween(canvas, 1, { Position = bottomDragFrame.Position - UDim2.fromOffset(25, canvas.Size.Y.Offset + 5) })
end)

resizer.DragContinue:Connect(function(inputpos: Vector2)
	if not cache.Dragging then return end
	local delta = inputpos - cache.ResizeOffset
	local startSize = cache.OLD_SIZE
	local startPos = cache.OLD_POSITION
	local MIN_WIDTH = 125
	local MIN_HEIGHT = 125
	
	local newWidth = math.max(MIN_WIDTH, startSize.X.Offset - delta.X)
	local newHeight = math.max(MIN_HEIGHT, startSize.Y.Offset + delta.Y)
	local newPosX = startPos.X.Offset + (startSize.X.Offset - newWidth)
	
	canvas.Size = UDim2.fromOffset(newWidth, newHeight)
	canvas.Position = UDim2.fromOffset(newPosX, startPos.Y.Offset)
	bottomDragFrame.Position = canvas.Position + UDim2.fromOffset(25, newHeight + 5)
	bottomDragFrame.Size = UDim2.fromOffset(canvas.Size.X.Offset - 50, 4)
end)

--> UI Collapsing

local function toggle()
	bottomDragFrame.Visible = cache.Toggled
	if not cache.Toggled then
		cache.OLD_POSITION = canvas.Position
		cache.OLD_SIZE = canvas.Size
		miniToggle.Visible = true
		
		tween(canvas, 1, { GroupTransparency = 1, Position = UDim2.fromOffset(apos - 24, 8), Size = UDim2.fromOffset(16, 16) })
		tween(miniToggle, 1, { BackgroundTransparency = 0 })
	else
		tween(canvas, 1, { GroupTransparency = 0, Position = cache.OLD_POSITION, Size = cache.OLD_SIZE })
		local t = tween(miniToggle, 1, { BackgroundTransparency = 1 })
		t.Completed:Once(function()
			miniToggle.Visible = false
		end)
	end
end

local function collapse()
	tween(content, 1, { GroupTransparency = cache.Collapsed and 1 or 0 })
	tween(canvas, 1, { Size = UDim2.fromOffset(300, cache.Collapsed and 25 or 300) })
	tween(bottomDragFrame, 1, { Position = canvas.Position + UDim2.fromOffset(25, cache.Collapsed and 30 or 305) })
	tween(frame4corner, 1, { CornerRadius = UDim.new(0, cache.Collapsed and 8 or 0) })
	tween(divider, 1, { BackgroundTransparency = cache.Collapsed and 1 or 0 })
	miniMax.Visible = cache.Collapsed
	miniRestore.Visible = not cache.Collapsed
end

--> UI buttons

local function initButton(button: TextButton)
	local function changeColor(color: Color3)
		button.TextColor3 = color
	end
	
	button.MouseEnter:Connect(function() changeColor(Color3.fromRGB(178, 178, 178)) end)
	button.MouseLeave:Connect(function() changeColor(Color3.new(1, 1, 1)) end)
	button.MouseButton1Down:Connect(function() changeColor(Color3.new(1, 1, 1)) end)
	button.MouseButton1Up:Connect(function() changeColor(Color3.fromRGB(178, 178, 178)) end)
end

initButton(toggleButton)
toggleButton.Activated:Connect(function()
	cache.Toggled = false
	toggle()
end)

miniToggle.Activated:Connect(function()
	cache.Toggled = true
	toggle()
end)

local function changeColor(color: Color3)
	for _, v in miniButton:GetDescendants() do
		if v:IsA("Frame") then
			v.BackgroundColor3 = color
		elseif v:IsA("UIStroke") then
			v.Color = color
		end
	end
end

miniButton.MouseEnter:Connect(function() changeColor(Color3.fromRGB(178, 178, 178)) end)
miniButton.MouseLeave:Connect(function() changeColor(Color3.new(1, 1, 1)) end)
miniButton.MouseButton1Down:Connect(function() changeColor(Color3.new(1, 1, 1)) end)
miniButton.MouseButton1Up:Connect(function() changeColor(Color3.fromRGB(178, 178, 178)) end)

miniButton.Activated:Connect(function()
	cache.Collapsed = not cache.Collapsed
	collapse()
end)

initButton(emptyButton)
emptyButton.Activated:Connect(function()
	for b, n in pairs(c) do
		cache[n] = false
		b.Text = "OFF"
	end
	refresh()
end)

initButton(fillButton)
fillButton.Activated:Connect(function()
	for b, n in pairs(c) do
		cache[n] = true
		b.Text = "ON"
	end
	refresh()
end)

initButton(refreshButton)
refreshButton.Activated:Connect(function() refresh() end)

miniToggle.MouseButton1Down:Connect(function()
	local start = os.clock()
	minitoggle_outline.Visible = true
	cache["DESTROYING"] = RunService.Heartbeat:Connect(function(delta: number)
		local elapsed = os.clock() - start
		local alpha = math.clamp(elapsed / 1, 0, 1)
		minitoggle_fill.Size = UDim2.fromScale(alpha, 1)
		
		if alpha == 1 then
			cache["DESTROYING"]:Disconnect()
			setnil(CONNECTIONS)
			for _, v in CollectionService:GetTagged(cache.TAG) do
				v:Destroy()
			end
			RBXGeneral:DisplaySystemMessage('<font color="#000000"><stroke color="#FFFFFF">I.C.H.O.R. BROKEN</stroke></font>')
			gui:Destroy()
		end
	end)
end)

miniToggle.MouseButton1Up:Connect(function()
	minitoggle_outline.Visible = false
	if cache["DESTROYING"] then
		cache["DESTROYING"]:Disconnect()
		cache["DESTROYING"] = nil
	end
end)
