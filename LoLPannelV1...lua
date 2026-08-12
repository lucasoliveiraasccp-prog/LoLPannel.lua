--========================================================
-- LoL Pannel V1
-- by: zaishi
-- Mobile Edition
-- Luau / Roblox
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

--========================================================
-- MOBILE ONLY
--========================================================

if not UIS.TouchEnabled then
	return
end

--========================================================
-- PLAYER
--========================================================

local Player = Players.LocalPlayer

if not Player then
	return
end

local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================
-- REMOVE OLD GUI
--========================================================

local oldGui = PlayerGui:FindFirstChild("LoLPannelV1")

if oldGui then
	oldGui:Destroy()
end

--========================================================
-- CONFIG
--========================================================

local CONFIG = {
	PanelWidth = 430,
	PanelHeight = 315,

	PanelMinScale = 0.55,
	PanelMaxScale = 0.90,

	MessageDefaultSize = 78,
	MessageMinSize = 48,
	MessageMaxSize = 150,

	ArrowSize = 64,
	ArrowGap = 7,

	ESPColor = Color3.fromRGB(255, 35, 35),

	PanelColor = Color3.fromRGB(12, 12, 16),
	ButtonColor = Color3.fromRGB(28, 28, 35),

	Red = Color3.fromRGB(150, 0, 0),
	Green = Color3.fromRGB(0, 125, 65),

	LedRed = Color3.fromRGB(255, 25, 25),
	LedBlue = Color3.fromRGB(80, 140, 255),

	TorettoWheelSize = 180,
	TorettoPedalWidth = 105,
	TorettoPedalHeight = 70
}

--========================================================
-- STATE
--========================================================

local State = {
	PanelOpen = true,

	EditMode = false,
	PositionMode = false,

	ESP = false,
	ShiftLock = false,

	Arrows = true,
	DoubleSend = false,

	FreeCam = false,
	Optimization = false,

	Toretto = false,

	SelectedButton = nil,

	Moving = {
		Up = false,
		Down = false,
		Left = false,
		Right = false
	},

	Toretto = {
		Steer = 0,
		Throttle = 0,
		Brake = 0
	}
}

--========================================================
-- CHARACTER
--========================================================

local Character
local Humanoid
local RootPart

local function UpdateCharacter(character)

	Character = character

	Humanoid = character:WaitForChild(
		"Humanoid",
		10
	)

	RootPart = character:WaitForChild(
		"HumanoidRootPart",
		10
	)

	if Humanoid and State.ShiftLock then
		Humanoid.AutoRotate = false
	end
end

if Player.Character then
	task.spawn(
		UpdateCharacter,
		Player.Character
	)
end

Player.CharacterAdded:Connect(
	UpdateCharacter
)

--========================================================
-- GUI
--========================================================

local Gui = Instance.new("ScreenGui")

Gui.Name = "LoLPannelV1"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 1000

Gui.Parent = PlayerGui

--========================================================
-- UTILITIES
--========================================================

local function Corner(object, radius)

	local c = Instance.new("UICorner")

	c.CornerRadius = UDim.new(0, radius)
	c.Parent = object

	return c
end

local function Stroke(object, color, thickness)

	local s = Instance.new("UIStroke")

	s.Color = color
	s.Thickness = thickness

	s.Parent = object

	return s
end

local function Gradient(object, color1, color2, rotation)

	local gradient = Instance.new("UIGradient")

	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color1),
		ColorSequenceKeypoint.new(1, color2)
	})

	gradient.Rotation = rotation or 90
	gradient.Parent = object

	return gradient
end

local function Tween(object, properties, duration)

	local info = TweenInfo.new(
		duration or 0.15,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	TweenService:Create(
		object,
		info,
		properties
	):Play()
end

local function CreateButton(parent, text, size, position)

	local button = Instance.new("TextButton")

	button.Size = size
	button.Position = position

	button.BackgroundColor3 =
		CONFIG.ButtonColor

	button.BorderSizePixel = 0

	button.Text = text

	button.TextColor3 =
		Color3.new(1, 1, 1)

	button.TextSize = 14

	button.Font =
		Enum.Font.GothamBold

	button.AutoButtonColor = false

	button.Parent = parent

	Corner(button, 10)

	Stroke(
		button,
		Color3.fromRGB(70, 70, 80),
		1
	)

	Gradient(
		button,
		Color3.fromRGB(40, 40, 48),
		Color3.fromRGB(22, 22, 28),
		90
	)

	button.MouseEnter:Connect(function()

		Tween(
			button,
			{
				BackgroundColor3 =
					Color3.fromRGB(55, 55, 65)
			},
			0.12
		)

	end)

	button.MouseLeave:Connect(function()

		Tween(
			button,
			{
				BackgroundColor3 =
					CONFIG.ButtonColor
			},
			0.12
		)

	end)

	return button
end

local function SetButtonState(button, enabled, name)

	button.Text =
		name ..
		(enabled and ": ON" or ": OFF")

	if enabled then

		button.BackgroundColor3 =
			CONFIG.Green

		local stroke =
			button:FindFirstChildOfClass("UIStroke")

		if stroke then
			stroke.Color =
				Color3.fromRGB(
					80,
					255,
					150
				)
		end

	else

		button.BackgroundColor3 =
			CONFIG.ButtonColor

		local stroke =
			button:FindFirstChildOfClass("UIStroke")

		if stroke then
			stroke.Color =
				Color3.fromRGB(
					70,
					70,
					80
				)
		end

	end
end

--========================================================
-- PANEL
--========================================================

local Panel = Instance.new("Frame")
Panel.Name = "MainPanel"

Panel.Size =
	UDim2.fromOffset(
		CONFIG.PanelWidth,
		CONFIG.PanelHeight
	)

Panel.AnchorPoint =
	Vector2.new(0.5, 0.5)

Panel.Position =
	UDim2.fromScale(
		0.5,
		0.5
	)

Panel.BackgroundColor3 =
	CONFIG.PanelColor

Panel.BorderSizePixel = 0

Panel.Parent = Gui

Corner(Panel, 18)

local PanelStroke =
	Stroke(
		Panel,
		Color3.fromRGB(140, 0, 0),
		2
	)

Gradient(
		Panel,
		Color3.fromRGB(22, 22, 28),
		Color3.fromRGB(8, 8, 12),
		90
)

--========================================================
-- LED LINE
--========================================================

local LedLine = Instance.new("Frame")

LedLine.Size =
	UDim2.new(1, -24, 0, 2)

LedLine.Position =
	UDim2.fromOffset(12, 3)

LedLine.BackgroundColor3 =
	CONFIG.LedRed

LedLine.BorderSizePixel = 0

LedLine.Parent = Panel

Corner(LedLine, 2)

local LedGlow =
	Stroke(
		LedLine,
		CONFIG.LedRed,
		2
	)

task.spawn(function()

	while Gui.Parent do

		Tween(
			LedLine,
			{
				BackgroundTransparency = 0.65
			},
			0.8
		)

		task.wait(0.8)

		Tween(
			LedLine,
			{
				BackgroundTransparency = 0
			},
			0.8
		)

		task.wait(0.8)

	end

end)

--========================================================
-- TITLE
--========================================================

local Title = Instance.new("TextLabel")

Title.Size =
	UDim2.new(1, -20, 0, 34)

Title.Position =
	UDim2.fromOffset(10, 7)

Title.BackgroundTransparency = 1

Title.Text =
	"LoL Pannel V1"

Title.TextColor3 =
	Color3.fromRGB(255, 55, 55)

Title.TextSize = 21

Title.Font =
	Enum.Font.GothamBold

Title.Parent = Panel

--========================================================
-- AUTHOR
--========================================================

local Author = Instance.new("TextLabel")

Author.Size =
	UDim2.new(1, -20, 0, 17)

Author.Position =
	UDim2.fromOffset(10, 36)

Author.BackgroundTransparency = 1

Author.Text =
	"by: zaishi"

Author.TextColor3 =
	Color3.fromRGB(145, 145, 155)

Author.TextSize = 10

Author.Font =
	Enum.Font.Gotham

Author.Parent = Panel

--========================================================
-- PANEL DRAG
--========================================================

local DragArea = Instance.new("TextButton")

DragArea.Size =
	UDim2.new(1, -130, 0, 50)

DragArea.Position =
	UDim2.fromOffset(10, 0)

DragArea.BackgroundTransparency = 1
DragArea.Text = ""
DragArea.AutoButtonColor = false

DragArea.Parent = Panel

local panelDragging = false
local panelStart
local panelPosition

DragArea.InputBegan:Connect(function(input)

	if input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	panelDragging = true
	panelStart = input.Position
	panelPosition = Panel.Position

end)

UIS.InputChanged:Connect(function(input)

	if not panelDragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local delta =
		input.Position - panelStart

	Panel.Position =
		UDim2.new(
			panelPosition.X.Scale,
			panelPosition.X.Offset + delta.X,

			panelPosition.Y.Scale,
			panelPosition.Y.Offset + delta.Y
		)

end)

UIS.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch then

		panelDragging = false

	end

end)

--========================================================
-- MESSAGE INPUT
--========================================================

local MessageInput = Instance.new("TextBox")

MessageInput.Size =
	UDim2.new(1, -30, 0, 40)

MessageInput.Position =
	UDim2.fromOffset(15, 58)

MessageInput.BackgroundColor3 =
	Color3.fromRGB(35, 35, 42)

MessageInput.BorderSizePixel = 0

MessageInput.TextColor3 =
	Color3.new(1, 1, 1)

MessageInput.PlaceholderColor3 =
	Color3.fromRGB(140, 140, 150)

MessageInput.PlaceholderText =
	"Digite uma mensagem..."

MessageInput.ClearTextOnFocus = false

MessageInput.TextSize = 14
MessageInput.Font = Enum.Font.Gotham

MessageInput.Parent = Panel

Corner(MessageInput, 9)

Stroke(
	MessageInput,
	Color3.fromRGB(65, 65, 75),
	1
)

--========================================================
-- MESSAGE LAYER
--========================================================

local MessageLayer = Instance.new("Frame")

MessageLayer.Name = "MessageButtons"

MessageLayer.Size =
	UDim2.fromScale(1, 1)

MessageLayer.BackgroundTransparency = 1

MessageLayer.Parent = Gui

local MessageButtons = {}

--========================================================
-- CHAT
--========================================================

local function SendMessage(message)

	if typeof(message) ~= "string" then
		return
	end

	if message == "" then
		return
	end

	local channels =
		TextChatService:FindFirstChild(
			"TextChannels"
		)

	if not channels then
		return
	end

	local channel =
		channels:FindFirstChild(
			"RBXGeneral"
		)

	if not channel then

		for _, object in ipairs(
			channels:GetChildren()
		) do

			if object:IsA("TextChannel") then
				channel = object
				break
			end

		end

	end

	if not channel then
		return
	end

	pcall(function()
		channel:SendAsync(message)
	end)

end

--========================================================
-- MESSAGE SELECTION
--========================================================

local function SelectMessageButton(button)

	if State.SelectedButton then

		local old =
			State.SelectedButton:FindFirstChild(
				"Selection"
			)

		if old then
			old:Destroy()
		end

	end

	State.SelectedButton = button

	if not button then
		return
	end

	local selection =
		Instance.new("UIStroke")

	selection.Name = "Selection"

	selection.Color =
		Color3.fromRGB(
			255,
			220,
			0
		)

	selection.Thickness = 3

	selection.Parent = button

end

--========================================================
-- POSITION MODE
--========================================================

local function EnableMessageDragging(button)

	local dragging = false
	local startTouch
	local startPosition

	button.InputBegan:Connect(function(input)

		if not State.PositionMode then
			return
		end

		if input.UserInputType ~=
			Enum.UserInputType.Touch then
			return
		end

		dragging = true

		startTouch =
			input.Position

		startPosition =
			button.Position

		SelectMessageButton(button)

	end)

	UIS.InputChanged:Connect(function(input)

		if not dragging then
			return
		end

		if input.UserInputType ~=
			Enum.UserInputType.Touch then
			return
		end

		local delta =
			input.Position - startTouch

		button.Position =
			UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,

				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)

	end)

	UIS.InputEnded:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.Touch then

			dragging = false

		end

	end)

end

--========================================================
-- RESIZE HANDLE
--========================================================

local function CreateResizeHandle(button)

	local handle =
		Instance.new("TextButton")

	handle.Name = "ResizeHandle"

	handle.Size =
		UDim2.fromOffset(34, 26)

	handle.AnchorPoint =
		Vector2.new(0.5, 0)

	handle.Position =
		UDim2.new(
			0.5,
			0,
			1,
			5
		)

	handle.BackgroundColor3 =
		Color3.fromRGB(
			255,
			205,
			0
		)

	handle.Text = "↔"

	handle.TextColor3 =
		Color3.fromRGB(
			20,
			20,
			20
		)

	handle.TextSize = 15
	handle.Font = Enum.Font.GothamBold

	handle.Visible = false
	handle.AutoButtonColor = false

	handle.Parent = button

	Corner(handle, 13)

	local resizing = false
	local startTouch
	local startSize

	handle.InputBegan:Connect(function(input)

		if not State.EditMode then
			return
		end

		if input.UserInputType ~=
			Enum.UserInputType.Touch then
			return
		end

		resizing = true

		startTouch =
			input.Position

		startSize =
			button.AbsoluteSize

		SelectMessageButton(button)

	end)

	UIS.InputChanged:Connect(function(input)

		if not resizing then
			return
		end

		if input.UserInputType ~=
			Enum.UserInputType.Touch then
			return
		end

		local delta =
			input.Position - startTouch

		local width =
			math.clamp(
				startSize.X + delta.X,
				CONFIG.MessageMinSize,
				CONFIG.MessageMaxSize
			)

		local height =
			math.clamp(
				startSize.Y + delta.Y,
				CONFIG.MessageMinSize,
				CONFIG.MessageMaxSize
			)

		button.Size =
			UDim2.fromOffset(
				width,
				height
			)

	end)

	UIS.InputEnded:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.Touch then

			resizing = false

		end

	end)

	return handle
end

--========================================================
-- CREATE MESSAGE BUTTON
--========================================================

local function CreateMessageButton(message)

	if typeof(message) ~= "string" then
		return
	end

	if message == "" then
		return
	end

	local button =
		Instance.new("TextButton")

	button.Name =
		"MessageButton"

	button.Size =
		UDim2.fromOffset(
			CONFIG.MessageDefaultSize,
			CONFIG.MessageDefaultSize
		)

	local index =
		#MessageButtons

	local column =
		index % 5

	local row =
		math.floor(index / 5)

	button.Position =
		UDim2.fromOffset(
			10 + column * 88,
			100 + row * 88
		)

	button.BackgroundColor3 =
		CONFIG.Red

	button.BorderSizePixel = 0

	button.Text =
		message

	button.TextColor3 =
		Color3.new(1, 1, 1)

	button.TextWrapped = true
	button.TextScaled = true

	button.Font =
		Enum.Font.GothamBold

	button.Parent =
		MessageLayer

	Corner(button, 12)

	Stroke(
		button,
		Color3.fromRGB(
			255,
			60,
			60
		),
		1
	)

	Gradient(
		button,
		Color3.fromRGB(185, 15, 15),
		Color3.fromRGB(95, 0, 0),
		90
	)

	local handle =
		CreateResizeHandle(button)

	EnableMessageDragging(button)

	button.Activated:Connect(function()

		if State.PositionMode then
			SelectMessageButton(button)
			return
		end

		if State.EditMode then
			SelectMessageButton(button)
			return
		end

		SendMessage(message)

		if State.DoubleSend then

			task.defer(function()
				SendMessage(message)
			end)

		end

	end)

	table.insert(
		MessageButtons,
		{
			Object = button,
			Message = message,
			Handle = handle
		}
	)

end

MessageInput.FocusLost:Connect(function(enterPressed)

	if not enterPressed then
		return
	end

	local message =
		MessageInput.Text

	if message == "" then
		return
	end

	CreateMessageButton(message)

	MessageInput.Text = ""

end)

--========================================================
-- PANEL BUTTONS
--========================================================

local EditButton =
	CreateButton(
		Panel,
		"Edição: OFF",
		UDim2.fromOffset(125, 38),
		UDim2.fromOffset(15, 110)
	)

local PositionButton =
	CreateButton(
		Panel,
		"Posição: OFF",
		UDim2.fromOffset(125, 38),
		UDim2.fromOffset(150, 110)
	)

local ESPButton =
	CreateButton(
		Panel,
		"ESP: OFF",
		UDim2.fromOffset(125, 38),
		UDim2.fromOffset(285, 110)
	)

local ShiftButton =
	CreateButton(
		Panel,
		"ShiftLock: OFF",
		UDim2.fromOffset(125, 38),
		UDim2.fromOffset(15, 157)
	)

local ArrowButton =
	CreateButton(
		Panel,
		"Setas: ON",
		UDim2.fromOffset(125, 38),
		UDim2.fromOffset(150, 157)
	)

local DoubleButton =
	CreateButton(
		Panel,
		"Enviar 2x: OFF",
		UDim2.fromOffset(125, 38),
		UDim2.fromOffset(285, 157)
	)

local TorettoButton =
	CreateButton(
		Panel,
		"Toretto: OFF",
		UDim2.fromOffset(125, 38),
		UDim2.fromOffset(15, 204)
	)

local OptimizationButton =
	CreateButton(
		Panel,
		"Otimização: OFF",
		UDim2.fromOffset(125, 38),
		UDim2.fromOffset(150, 204)
	)

local CloseButton =
	CreateButton(
		Panel,
		"Fechar",
		UDim2.fromOffset(125, 38),
		UDim2.fromOffset(285, 204)
	)

--========================================================
-- EDIT MODE
--========================================================

EditButton.Activated:Connect(function()
	State.EditMode =
		not State.EditMode

	if State.EditMode then
		State.PositionMode = false
	end

	SetButtonState(
		EditButton,
		State.EditMode,
		"Edição"
	)

	SetButtonState(
		PositionButton,
		State.PositionMode,
		"Posição"
	)

	for _, data in ipairs(
		MessageButtons
	) do

		if data.Handle then
			data.Handle.Visible =
				State.EditMode
		end

	end

	if not State.EditMode then
		SelectMessageButton(nil)
	end

end)

--========================================================
-- POSITION MODE
--========================================================

PositionButton.Activated:Connect(function()

	State.PositionMode =
		not State.PositionMode

	if State.PositionMode then
		State.EditMode = false
	end

	SetButtonState(
		PositionButton,
		State.PositionMode,
		"Posição"
	)

	SetButtonState(
		EditButton,
		State.EditMode,
		"Edição"
	)

	for _, data in ipairs(
		MessageButtons
	) do

		if data.Handle then
			data.Handle.Visible =
				State.EditMode
		end

	end

	SelectMessageButton(nil)

end)

--========================================================
-- DELETE
--========================================================

local DeleteButton =
	CreateButton(
		Panel,
		"Apagar",
		UDim2.fromOffset(125, 38),
		UDim2.fromOffset(15, 251)
	)

DeleteButton.Activated:Connect(function()

	if not State.EditMode then
		return
	end

	local selected =
		State.SelectedButton

	if not selected then
		return
	end

	for i, data in ipairs(
		MessageButtons
	) do

		if data.Object == selected then

			table.remove(
				MessageButtons,
				i
			)

			break

		end

	end

	selected:Destroy()

	State.SelectedButton = nil

end)

--========================================================
-- ESP
--========================================================

local ESPObjects = {}

local function RemoveESP(player)

	local data =
		ESPObjects[player]

	if not data then
		return
	end

	if data.Highlight then
		data.Highlight:Destroy()
	end

	if data.Tag then
		data.Tag:Destroy()
	end

	ESPObjects[player] = nil

end

local function CreateESP(player)

	if player == Player then
		return
	end

	RemoveESP(player)

	local character =
		player.Character

	if not character then
		return
	end

	local head =
		character:FindFirstChild("Head")

	if not head then
		return
	end

	local highlight =
		Instance.new("Highlight")

	highlight.Name =
		"LoL_ESP"

	highlight.Adornee =
		character

	highlight.FillColor =
		CONFIG.ESPColor

	highlight.OutlineColor =
		CONFIG.ESPColor

	highlight.FillTransparency =
		0.55

	highlight.OutlineTransparency =
		0

	highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Parent =
		character

	-- Nick menor
	local tag =
		Instance.new("BillboardGui")

	tag.Name =
		"LoL_ESP_Name"

	tag.Adornee =
		head

	tag.Size =
		UDim2.fromOffset(
			145,
			24
		)

	tag.StudsOffset =
		Vector3.new(
			0,
			2.7,
			0
		)

	tag.AlwaysOnTop = true
	tag.Parent = head

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.fromScale(1, 1)

	label.BackgroundTransparency = 1

	label.Text =
		player.DisplayName

	label.TextColor3 =
		CONFIG.ESPColor

	label.TextStrokeTransparency = 0.25

	label.TextScaled = true

	label.Font =
		Enum.Font.GothamBold

	label.Parent = tag

	ESPObjects[player] = {
		Highlight = highlight,
		Tag = tag
	}

end

local function UpdateESP()

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if player ~= Player then

			if State.ESP then
				CreateESP(player)
			else
				RemoveESP(player)
			end

		end

	end

end

ESPButton.Activated:Connect(function()

	State.ESP =
		not State.ESP

	SetButtonState(
		ESPButton,
		State.ESP,
		"ESP"
	)

	UpdateESP()

end)

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function()

		if State.ESP then

			task.wait(0.2)

			CreateESP(player)

		end

	end)

end)

Players.PlayerRemoving:Connect(function(player)

	RemoveESP(player)

end)

--========================================================
-- SHIFTLOCK
--========================================================

local Crosshair =
	Instance.new("TextLabel")

Crosshair.Size =
	UDim2.fromOffset(40, 40)

Crosshair.AnchorPoint =
	Vector2.new(0.5, 0.5)

Crosshair.Position =
	UDim2.fromScale(0.5, 0.5)

Crosshair.BackgroundTransparency = 1

Crosshair.Text = "+"

Crosshair.TextColor3 =
	Color3.new(1, 1, 1)

Crosshair.TextStrokeTransparency = 0

Crosshair.TextSize = 30

Crosshair.Font =
	Enum.Font.GothamBold

Crosshair.Visible = false

Crosshair.Parent = Gui

local function SetShiftLock(enabled)

	State.ShiftLock =
		enabled

	if Humanoid then
		Humanoid.AutoRotate =
			not enabled
	end

	Crosshair.Visible =
		enabled

	SetButtonState(
		ShiftButton,
		enabled,
		"ShiftLock"
	)

end

ShiftButton.Activated:Connect(function()

	SetShiftLock(
		not State.ShiftLock
	)

end)

--========================================================
-- MOBILE ARROWS
--========================================================

local ArrowFrame =
	Instance.new("Frame")

ArrowFrame.Name =
	"MobileArrows"

ArrowFrame.AnchorPoint =
	Vector2.new(0, 1)

ArrowFrame.Size =
	UDim2.fromOffset(
		205,
		145
	)

ArrowFrame.Position =
	UDim2.new(
		0,
		15,
		1,
		-15
	)

ArrowFrame.BackgroundTransparency = 1

ArrowFrame.Visible =
	State.Arrows

ArrowFrame.Parent = Gui

local function CreateArrow(name, text, position)

	local button =
		Instance.new("TextButton")

	button.Name = name

	button.Size =
		UDim2.fromOffset(
			CONFIG.ArrowSize,
			CONFIG.ArrowSize
		)

	button.Position = position

	button.BackgroundColor3 =
		Color3.fromRGB(
			28,
			28,
			35
		)

	button.BackgroundTransparency = 0.05

	button.BorderSizePixel = 0

	button.Text = text

	button.TextColor3 =
		Color3.new(1, 1, 1)

	button.TextSize = 27

	button.Font =
		Enum.Font.GothamBold

	button.AutoButtonColor = false

	button.Parent =
		ArrowFrame

	Corner(button, 20)

	local stroke =
		Stroke(
			button,
			Color3.fromRGB(
				90,
				90,
				105
			),
			1
		)

	Gradient(
		button,
		Color3.fromRGB(48, 48, 58),
		Color3.fromRGB(20, 20, 25),
		90
	)

	local pressed = false

	button.InputBegan:Connect(function(input)

		if input.UserInputType ~=
			Enum.UserInputType.Touch then
			return
		end

		pressed = true

		Tween(
			button,
			{
				Size =
					UDim2.fromOffset(
						CONFIG.ArrowSize - 6,
						CONFIG.ArrowSize - 6
					)
			},
			0.08
		)

		stroke.Color =
			CONFIG.LedBlue

	end)

	button.InputEnded:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.Touch then

			pressed = false

			Tween(
				button,
				{
					Size =
						UDim2.fromOffset(
							CONFIG.ArrowSize,
							CONFIG.ArrowSize
						)
				},
				0.08
			)

			stroke.Color =
				Color3.fromRGB(
					90,
					90,
					105
				)

		end

	end)

	return button
end

local Up =
	CreateArrow(
		"Up",
		"▲",
		UDim2.fromOffset(70, 0)
	)

local Down =
	CreateArrow(
		"Down",
		"▼",
		UDim2.fromOffset(70, 72)
	)

local Left =
	CreateArrow(
		"Left",
		"◀",
		UDim2.fromOffset(0, 72)
	)

local Right =
	CreateArrow(
		"Right",
		"▶",
		UDim2.fromOffset(140, 72)
	)

local function ConnectArrow(button, direction)

	button.InputBegan:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.Touch then

			State.Moving[direction] = true

		end

	end)

	button.InputEnded:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.Touch then

			State.Moving[direction] = false

		end

	end)

end

ConnectArrow(Up, "Up")
ConnectArrow(Down, "Down")
ConnectArrow(Left, "Left")
ConnectArrow(Right, "Right")

ArrowButton.Activated:Connect(function()

	State.Arrows =
		not State.Arrows

	ArrowFrame.Visible =
		State.Arrows

	SetButtonState(
		ArrowButton,
		State.Arrows,
		"Setas"
	)

end)

--========================================================
-- MOVEMENT
--========================================================

RunService.RenderStepped:Connect(function()

	if not Humanoid then
		return
	end

	local camera =
		workspace.CurrentCamera

	if not camera then
		return
	end

	local direction =
		Vector3.zero

	local forward =
		Vector3.new(
			camera.CFrame.LookVector.X,
			0,
			camera.CFrame.LookVector.Z
		)

	local right =
		Vector3.new(
			camera.CFrame.RightVector.X,
			0,
			camera.CFrame.RightVector.Z
		)

	if forward.Magnitude > 0 then
		forward = forward.Unit
	end

	if right.Magnitude > 0 then
		right = right.Unit
	end

	if State.Moving.Up then
		direction += forward
	end

	if State.Moving.Down then
		direction -= forward
	end

	if State.Moving.Right then
		direction += right
	end

	if State.Moving.Left then
		direction -= right
	end

	if direction.Magnitude > 0 then
		Humanoid:Move(
			direction.Unit,
			false
		)
	end

end)

--========================================================
-- TORETTO MODE
--========================================================

local TorettoGui =
	Instance.new("Frame")

TorettoGui.Name =
	"TorettoControls"

TorettoGui.Size =
	UDim2.fromScale(
		1,
		1
	)

TorettoGui.BackgroundTransparency = 1

TorettoGui.Visible = false

TorettoGui.Parent = Gui

--========================================================
-- VEHICLE SEAT
--========================================================

local function GetVehicleSeat()

	if not Humanoid then
		return nil
	end

	local seatPart =
		Humanoid.SeatPart

	if not seatPart then
		return nil
	end

	if seatPart:IsA("VehicleSeat") then
		return seatPart
	end

	local vehicleSeat =
		seatPart:FindFirstAncestorWhichIsA(
			"VehicleSeat"
		)

	if vehicleSeat then
		return vehicleSeat
	end

	return nil
end

--========================================================
-- STEERING WHEEL
--========================================================

local Wheel =
	Instance.new("Frame")

Wheel.Name =
	"SteeringWheel"

Wheel.Size =
	UDim2.fromOffset(
		CONFIG.TorettoWheelSize,
		CONFIG.TorettoWheelSize
	)

Wheel.AnchorPoint =
	Vector2.new(
		0,
		1
	)

Wheel.Position =
	UDim2.new(
		0,
		20,
		1,
		-25
	)

Wheel.BackgroundTransparency = 1

Wheel.Parent = TorettoGui

local WheelRing =
	Instance.new("Frame")

WheelRing.Size =
	UDim2.fromScale(
		1,
		1
	)

WheelRing.BackgroundColor3 =
	Color3.fromRGB(
		18,
		18,
		20
	)

WheelRing.BorderSizePixel = 0

WheelRing.Parent = Wheel

Corner(
	WheelRing,
	100
)

local WheelStroke =
	Stroke(
		WheelRing,
		Color3.fromRGB(
			100,
			100,
			110
		),
		8
)

-- central hub: fixed
local WheelCenter =
	Instance.new("Frame")

WheelCenter.Size =
	UDim2.fromOffset(
		62,
		62
	)

WheelCenter.AnchorPoint =
	Vector2.new(
		0.5,
		0.5
	)

WheelCenter.Position =
	UDim2.fromScale(
		0.5,
		0.5
	)

WheelCenter.BackgroundColor3 =
	Color3.fromRGB(
		35,
		35,
		40
	)

WheelCenter.BorderSizePixel = 0

WheelCenter.Parent = Wheel

Corner(
	WheelCenter,
	100
)

Stroke(
	WheelCenter,
	Color3.fromRGB(
		120,
		120,
		130
	),
	2
)

local WheelMark =
	Instance.new("TextLabel")

WheelMark.Size =
	UDim2.fromScale(
		1,
		1
	)

WheelMark.BackgroundTransparency = 1

WheelMark.Text = "◆"

WheelMark.TextColor3 =
	Color3.fromRGB(
		220,
		220,
		225
	)

WheelMark.TextSize = 18

WheelMark.Font =
	Enum.Font.GothamBold

WheelMark.Parent =
	WheelCenter

--========================================================
-- WHEEL TOUCH AREA
--========================================================

local WheelTouch =
	Instance.new("TextButton")

WheelTouch.Name =
	"WheelTouch"

WheelTouch.Size =
	UDim2.fromScale(
		1,
		1
	)

WheelTouch.BackgroundTransparency = 1
WheelTouch.Text = ""

WheelTouch.AutoButtonColor = false

WheelTouch.Parent =
	Wheel

local wheelDragging = false
local wheelCenterScreen
local wheelAngle = 0

local function UpdateWheelFromTouch(position)

	local absolutePosition =
		Wheel.AbsolutePosition

	local absoluteSize =
		Wheel.AbsoluteSize

	local center =
		absolutePosition +
		absoluteSize / 2

	local offset =
		position - center

	if offset.Magnitude < 10 then
		return
	end

	local angle =
		math.deg(
			math.atan2(
				offset.Y,
				offset.X
			)
		) + 90

	if angle > 180 then
		angle -= 360
	end

	angle =
		math.clamp(
			angle,
			-70,
			70
		)

	wheelAngle = angle

	WheelRing.Rotation =
		wheelAngle

	State.Toretto.Steer =
		math.clamp(
			angle / 70,
			-1,
			1
		)

end

WheelTouch.InputBegan:Connect(function(input)

	if input.UserInputType ~=
		Enum.UserInputType.Touch then
		return
	end

	wheelDragging = true

	UpdateWheelFromTouch(
		input.Position
	)

end)

UIS.InputChanged:Connect(function(input)

	if not wheelDragging then
		return
	end

	if input.UserInputType ~=
		Enum.UserInputType.Touch then
		return
	end

	UpdateWheelFromTouch(
		input.Position
	)

end)

UIS.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch then

		wheelDragging = false

		State.Toretto.Steer = 0

		Tween(
			WheelRing,
			{
				Rotation = 0
			},
			0.18
		)

	end

end)

--========================================================
-- PEDALS
--========================================================

local function CreatePedal(
	name,
	text,
	position
)

	local pedal =
		Instance.new("TextButton")

	pedal.Name = name

	pedal.Size =
		UDim2.fromOffset(
			CONFIG.TorettoPedalWidth,
			CONFIG.TorettoPedalHeight
		)

	pedal.AnchorPoint =
		Vector2.new(
			1,
			1
		)

	pedal.Position =
		position

	pedal.BackgroundColor3 =
		Color3.fromRGB(
			28,
			28,
			32
		)

	pedal.BorderSizePixel = 0

	pedal.Text = text

	pedal.TextColor3 =
		Color3.new(
			1,
			1,
			1
		)

	pedal.TextSize = 15

	pedal.Font =
		Enum.Font.GothamBold

	pedal.AutoButtonColor = false

	pedal.Parent =
		TorettoGui

	Corner(
		pedal,
		15
	)

	Stroke(
		pedal,
		Color3.fromRGB(
			85,
			85,
			95
		),
		2
	)

	return pedal
end

local Brake =
	CreatePedal(
		"Brake",
		"FREIO",
		UDim2.new(
			1,
			-25,
			1,
			-25
		)
	)

local Accelerator =
	CreatePedal(
		"Accelerator",
		"ACELERADOR",
		UDim2.new(
			1,
			-145,
			1,
			-25
		)
	)

local function SetupPedal(
	pedal,
	valueName,
	value
)

	local active = false

	pedal.InputBegan:Connect(function(input)

		if input.UserInputType ~=
			Enum.UserInputType.Touch then
			return
		end

		active = true

		State.Toretto[valueName] =
			value

		Tween(
			pedal,
			{
				BackgroundColor3 =
					CONFIG.Green
			},
			0.08
		)

	end)

	pedal.InputEnded:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.Touch then

			active = false

			State.Toretto[valueName] =
				0

			Tween(
				pedal,
				{
					BackgroundColor3 =
						Color3.fromRGB(
							28,
							28,
							32
						)
				},
				0.12
			)

		end

	end)

end

SetupPedal(
	Accelerator,
	"Throttle",
	1
)

SetupPedal(
	Brake,
	"Brake",
	1
)

--========================================================
-- TORETTO CONTROL
--========================================================

local function ApplyToretto()
	if not State.Toretto then
		return
	end

	local seat =
		GetVehicleSeat()

	if not seat then
		return
	end

	-- VehicleSeat é utilizado como interface
	-- padrão do Roblox para veículos.
	--
	-- O script não cria física própria.
	-- O chassis do veículo continua responsável
	-- pela movimentação.

	pcall(function()

		seat.Throttle =
			State.Toretto.Throttle

		seat.Steer =
			State.Toretto.Steer

	end)

end

RunService.RenderStepped:Connect(
	ApplyToretto
)

--========================================================
-- TORETTO TOGGLE
--========================================================

local function SetToretto(enabled)

	State.Toretto =
		enabled
		and {
			Steer = 0,
			Throttle = 0,
			Brake = 0
		}
		or State.Toretto

	TorettoGui.Visible =
		enabled

	SetButtonState(
		TorettoButton,
		enabled,
		"Toretto"
	)

	if not enabled then

		WheelRing.Rotation = 0

	end

end

TorettoButton.Activated:Connect(function()

	SetToretto(
		not State.Toretto
	)

end)

--========================================================
-- OPTIMIZATION
--========================================================

local originalLighting = {}

OptimizationButton.Activated:Connect(function()

	State.Optimization =
		not State.Optimization

	if State.Optimization then

		originalLighting.GlobalShadows =
			Lighting.GlobalShadows

		originalLighting.FogEnd =
			Lighting.FogEnd

		Lighting.GlobalShadows = false
		Lighting.FogEnd = 100000

	else

		if originalLighting.GlobalShadows ~= nil then
			Lighting.GlobalShadows =
				originalLighting.GlobalShadows
		end

		if originalLighting.FogEnd ~= nil then
			Lighting.FogEnd =
				originalLighting.FogEnd
		end

	end

	SetButtonState(
		OptimizationButton,
		State.Optimization,
		"Otimização"
	)

end)

--========================================================
-- DOUBLE SEND
--========================================================

DoubleButton.Activated:Connect(function()

	State.DoubleSend =
		not State.DoubleSend

	SetButtonState(
		DoubleButton,
		State.DoubleSend,
		"Enviar 2x"
	)

end)

--========================================================
-- CLOSE / MINIMIZE
--========================================================

local MinimizedButton =
	Instance.new("TextButton")

MinimizedButton.Name =
	"ReducedPanel"

MinimizedButton.Size =
	UDim2.fromOffset(
		50,
		50
	)

MinimizedButton.Position =
	UDim2.new(
		1,
		-65,
		0,
		20
	)

MinimizedButton.BackgroundColor3 =
	CONFIG.Red

MinimizedButton.Text =
	"LoL"

MinimizedButton.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

MinimizedButton.TextSize = 13
MinimizedButton.Font =
	Enum.Font.GothamBold

MinimizedButton.BorderSizePixel = 0

MinimizedButton.Parent =
	Gui

Corner(
	MinimizedButton,
	16
)

local minStroke =
	Stroke(
		MinimizedButton,
		CONFIG.LedRed,
		2
)

Gradient(
	MinimizedButton,
	Color3.fromRGB(190, 10, 10),
	Color3.fromRGB(80, 0, 0),
	90
)

--========================================================
-- REDUCED BUTTON DRAG
--========================================================

local reducedDragging = false
local reducedStart
local reducedPosition

MinimizedButton.InputBegan:Connect(function(input)

	if input.UserInputType ~=
		Enum.UserInputType.Touch then
		return
	end

	reducedDragging = true

	reducedStart =
		input.Position

	reducedPosition =
		MinimizedButton.Position

end)

UIS.InputChanged:Connect(function(input)

	if not reducedDragging then
		return
	end

	if input.UserInputType ~=
		Enum.UserInputType.Touch then
		return
	end

	local delta =
		input.Position -
		reducedStart

	MinimizedButton.Position =
		UDim2.new(
			reducedPosition.X.Scale,
			reducedPosition.X.Offset + delta.X,

			reducedPosition.Y.Scale,
			reducedPosition.Y.Offset + delta.Y
		)

end)

UIS.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch then

		reducedDragging = false

	end

end)

--========================================================
-- MINIMIZE / OPEN
--========================================================

local function SetPanelVisible(value)

	State.PanelOpen =
		value

	Panel.Visible =
		value

	MinimizedButton.Visible =
		not value

end

CloseButton.Activated:Connect(function()

	SetPanelVisible(false)

end)

MinimizedButton.Activated:Connect(function()

	SetPanelVisible(true)

end)

--========================================================
-- RESPONSIVE SCALE
--========================================================

local PanelScale =
	Instance.new("UIScale")

PanelScale.Parent =
	Panel

local function UpdatePanelScale()

	local camera =
		workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport =
		camera.ViewportSize

	local scale =
		math.min(
			viewport.X / 900,
			viewport.Y / 700
		)

	PanelScale.Scale =
		math.clamp(
			scale,
			CONFIG.PanelMinScale,
			CONFIG.PanelMaxScale
		)

end

local camera =
	workspace.CurrentCamera

if camera then

	camera:GetPropertyChangedSignal(
		"ViewportSize"
	):Connect(
		UpdatePanelScale
	)

end

UpdatePanelScale()

--========================================================
-- STARTUP
--========================================================

Panel.Visible = true
MinimizedButton.Visible = false
ArrowFrame.Visible = true

SetButtonState(
	ArrowButton,
	true,
	"Setas"
)

print(
	"[LoL Pannel V1] Inicializado com sucesso."
)
