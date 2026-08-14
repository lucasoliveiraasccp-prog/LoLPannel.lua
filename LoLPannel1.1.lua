--========================================================
-- LoL Painnel 1.1
-- Mobile Edition
-- Luau / Roblox
--
-- REESTRUTURADO:
-- • Toretto removido
-- • Edição Setas
-- • Modo Posição para Setas
-- • Driving
-- • Edição Driving
-- • ShiftLock forçado aprimorado
-- • TallPoint
-- • Edição TallPoint
-- • Otimização aprimorada
-- • Painel por categorias
-- • Minimizar / Fechar
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

for _, name in ipairs({
	"LoLPannelV1",
	"LoLPainnel11"
}) do
	local old = PlayerGui:FindFirstChild(name)

	if old then
		old:Destroy()
	end
end

--========================================================
-- CONFIG
--========================================================

local CONFIG = {

	PanelWidth = 520,
	PanelHeight = 360,

	PanelMinScale = 0.48,
	PanelMaxScale = 0.90,

	SidebarWidth = 145,

	MessageDefaultWidth = 82,
	MessageDefaultHeight = 62,

	MessageMinWidth = 45,
	MessageMaxWidth = 180,

	MessageMinHeight = 38,
	MessageMaxHeight = 140,

	ArrowDefaultWidth = 64,
	ArrowDefaultHeight = 64,

	ArrowMinWidth = 35,
	ArrowMaxWidth = 140,

	ArrowMinHeight = 35,
	ArrowMaxHeight = 140,

	TallPointDefaultSize = 72,

	TallPointMinSize = 40,
	TallPointMaxSize = 180,

	DrivingWheelWidth = 150,
	DrivingWheelHeight = 150,

	DrivingStickWidth = 76,
	DrivingStickHeight = 185,

	DrivingMinWidth = 40,
	DrivingMaxWidth = 260,

	DrivingMinHeight = 40,
	DrivingMaxHeight = 260,

	ESPColor = Color3.fromRGB(255, 35, 35),

	PanelColor = Color3.fromRGB(12, 12, 16),
	ButtonColor = Color3.fromRGB(27, 27, 34),

	Red = Color3.fromRGB(150, 0, 0),
	RedLight = Color3.fromRGB(220, 25, 25),

	Green = Color3.fromRGB(0, 125, 65),

	Blue = Color3.fromRGB(55, 110, 210),

	Yellow = Color3.fromRGB(220, 175, 35),

	Text = Color3.fromRGB(240, 240, 245),
	SubText = Color3.fromRGB(145, 145, 155)
}

--========================================================
-- STATE
--========================================================

local State = {

	PanelOpen = true,
	PanelMinimized = false,

	EditMode = false,
	PositionMode = false,

	ArrowEditMode = false,
	TallPointEditMode = false,
	DrivingEditMode = false,

	ESP = false,
	ShiftLock = false,

	Arrows = true,
	TallPoint = false,
	Driving = false,

	DoubleSend = false,
	Optimization = false,

	SelectedObject = nil,

	Moving = {
		Up = false,
		Down = false,
		Left = false,
		Right = false
	},

	Driving = {
		Steer = 0,
		Throttle = 0
	}
}

--========================================================
-- CHARACTER
--========================================================

local Character
local Humanoid
local RootPart

local OriginalAutoRotate = true
local OriginalCameraOffset = Vector3.zero

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

	if Humanoid then

		OriginalAutoRotate =
			Humanoid.AutoRotate

		if State.ShiftLock then

			Humanoid.AutoRotate = false

		end

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

Gui.Name = "LoLPainnel11"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 1000

Gui.Parent = PlayerGui

--========================================================
-- UTILITIES
--========================================================

local function Corner(object, radius)

	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(
			0,
			radius
		)

  corner.CornerRadius =
		UDim.new(
			0,
			radius
		)

	corner.Parent = object

	return corner
end

local function Stroke(object, color, thickness)

	local stroke =
		Instance.new("UIStroke")

	stroke.Color = color
	stroke.Thickness = thickness or 1

	stroke.Parent = object

	return stroke
end

local function Gradient(
	object,
	color1,
	color2,
	rotation
)

	local gradient =
		Instance.new("UIGradient")

	gradient.Color =
		ColorSequence.new({
			ColorSequenceKeypoint.new(
				0,
				color1
			),

			ColorSequenceKeypoint.new(
				1,
				color2
			)
		})

	gradient.Rotation =
		rotation or 90

	gradient.Parent =
		object

	return gradient
end

local function Tween(
	object,
	properties,
	duration
)

	local success =
		pcall(function()

			TweenService:Create(
				object,

				TweenInfo.new(
					duration or 0.15,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				),

				properties
			):Play()

		end)

	return success
end

local function SafeDestroy(object)

	if object then

		pcall(function()
			object:Destroy()
		end)

	end

end

local function SetVisible(object, value)

	if object then

		pcall(function()
			object.Visible = value
		end)

	end

end

--========================================================
-- GENERIC BUTTON
--========================================================

local function CreateButton(
	parent,
	text,
	size,
	position
)

	local button =
		Instance.new("TextButton")

	button.Size = size
	button.Position = position

	button.BackgroundColor3 =
		CONFIG.ButtonColor

	button.BorderSizePixel = 0

	button.Text = text

	button.TextColor3 =
		CONFIG.Text

	button.TextSize = 13

	button.Font =
		Enum.Font.GothamBold

	button.AutoButtonColor = false

	button.Parent = parent

	Corner(
		button,
		9
	)

	Stroke(
		button,
		Color3.fromRGB(
			65,
			65,
			75
		),
		1
	)

	Gradient(
		button,
		Color3.fromRGB(
			42,
			42,
			50
		),

		Color3.fromRGB(
			20,
			20,
			26
		),

		90
	)

	button.InputBegan:Connect(function(input)

		if input.UserInputType ~=
			Enum.UserInputType.Touch then
			return
		end

		Tween(
			button,
			{
				BackgroundColor3 =
					Color3.fromRGB(
						50,
						50,
						60
					)
			},
			0.08
		)

	end)

	button.InputEnded:Connect(function(input)

		if input.UserInputType ~=
			Enum.UserInputType.Touch then
			return
		end

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

local function SetButtonState(
	button,
	enabled,
	name
)

	if not button then
		return
	end

	button.Text =
		name ..
		(enabled and ": ON" or ": OFF")

	if enabled then

		button.BackgroundColor3 =
			CONFIG.Green

		local stroke =
			button:FindFirstChildOfClass(
				"UIStroke"
			)

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
			button:FindFirstChildOfClass(
				"UIStroke"
			)

		if stroke then

			stroke.Color =
				Color3.fromRGB(
					65,
					65,
					75
				)

		end

	end
end

--========================================================
-- MAIN PANEL
--========================================================

local Panel =
	Instance.new("Frame")

Panel.Name =
	"MainPanel"

Panel.Size =
	UDim2.fromOffset(
		CONFIG.PanelWidth,
		CONFIG.PanelHeight
	)

Panel.AnchorPoint =
	Vector2.new(
		0.5,
		0.5
	)

Panel.Position =
	UDim2.fromScale(
		0.5,
		0.5
	)

Panel.BackgroundColor3 =
	CONFIG.PanelColor

Panel.BorderSizePixel = 0

Panel.ClipsDescendants = true

Panel.Parent =
	Gui

Corner(
		Panel,
		16
)

Stroke(
		Panel,
		Color3.fromRGB(
			125,
			0,
			0
		),
		2
)

Gradient(
	Panel,
	Color3.fromRGB(
		23,
		23,
		29
	),

	Color3.fromRGB(
		8,
		8,
		12
	),

	90
)

--========================================================
-- TOP BAR
--========================================================

local TopBar =
	Instance.new("Frame")

TopBar.Size =
	UDim2.new(
		1,
		0,
		0,
		48
	)

TopBar.BackgroundTransparency = 1
TopBar.Parent = Panel

--========================================================
-- TITLE ON BORDER
--========================================================

local Title =
	Instance.new("TextLabel")

Title.Size =
	UDim2.fromOffset(
		210,
		32
	)

Title.AnchorPoint =
	Vector2.new(
		0.5,
		0.5
	)

Title.Position =
	UDim2.new(
		0.5,
		0,
		0,
		0
	)

Title.BackgroundColor3 =
	CONFIG.PanelColor

Title.BorderSizePixel = 0

Title.Text =
	"LoL Painnel 1.1"

Title.TextColor3 =
	Color3.fromRGB(
		255,
		65,
		65
	)

Title.TextSize = 18

Title.Font =
	Enum.Font.GothamBold

Title.ZIndex = 10

Title.Parent =
	Panel

--========================================================
-- CLOSE X
--========================================================

local CloseButton =
	Instance.new("TextButton")

CloseButton.Size =
	UDim2.fromOffset(
		36,
		36
	)

CloseButton.AnchorPoint =
	Vector2.new(
		1,
		0.5
	)

CloseButton.Position =
	UDim2.new(
		1,
		-7,
		0,
		23
	)

CloseButton.BackgroundTransparency = 1

CloseButton.Text = "×"

CloseButton.TextColor3 =
	Color3.fromRGB(
		255,
		80,
		80
	)

CloseButton.TextSize = 27

CloseButton.Font =
	Enum.Font.GothamBold

CloseButton.ZIndex = 20

CloseButton.Parent =
	Panel

--========================================================
-- MINIMIZE
--========================================================

local MinimizeButton =
	Instance.new("TextButton")

MinimizeButton.Size =
	UDim2.fromOffset(
		36,
		36
	)

MinimizeButton.AnchorPoint =
	Vector2.new(
		1,
		0.5
	)

MinimizeButton.Position =
	UDim2.new(
		1,
		-45,
		0,
		23
	)

MinimizeButton.BackgroundTransparency = 1

MinimizeButton.Text = "−"

MinimizeButton.TextColor3 =
	Color3.fromRGB(
		220,
		220,
		225
	)

MinimizeButton.TextSize = 26

MinimizeButton.Font =
	Enum.Font.GothamBold

MinimizeButton.ZIndex = 20

MinimizeButton.Parent =
	Panel

--========================================================
-- DRAG PANEL
--========================================================

local DragArea =
	Instance.new("TextButton")

DragArea.Size =
	UDim2.new(
		1,
		-95,
		0,
		48
	)

DragArea.Position =
	UDim2.fromOffset(
		10,
		0
	)

DragArea.BackgroundTransparency = 1

DragArea.Text = ""

DragArea.AutoButtonColor = false

DragArea.ZIndex = 5

DragArea.Parent =
	Panel

local panelDragging = false
local panelStart
local panelStartPosition

DragArea.InputBegan:Connect(function(input)

	if input.UserInputType ~=
		Enum.UserInputType.Touch then
		return
	end

	panelDragging = true

	panelStart =
		input.Position

	panelStartPosition =
		Panel.Position

end)

UIS.InputChanged:Connect(function(input)

	if not panelDragging then
		return
	end

	if input.UserInputType ~=
		Enum.UserInputType.Touch then
		return
	end

	local delta =
		input.Position -
		panelStart

	Panel.Position =
		UDim2.new(
			panelStartPosition.X.Scale,
			panelStartPosition.X.Offset + delta.X,

			panelStartPosition.Y.Scale,
			panelStartPosition.Y.Offset + delta.Y
		)

end)

UIS.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch then

		panelDragging = false

	end

end)

--========================================================
-- CONTENT CONTAINER
--========================================================

local Body =
	Instance.new("Frame")

Body.Name =
	"Body"

Body.Size =
	UDim2.new(
		1,
		0,
		1,
		-48
	)

Body.Position =
	UDim2.fromOffset(
		0,
		48
	)

Body.BackgroundTransparency = 1

Body.Parent =
	Panel

--========================================================
-- SIDEBAR
--========================================================

local Sidebar =
	Instance.new("Frame")

Sidebar.Name =
	"Sidebar"

Sidebar.Size =
	UDim2.new(
		0,
		CONFIG.SidebarWidth,
		1,
		0
	)

Sidebar.BackgroundColor3 =
	Color3.fromRGB(
		10,
		10,
		14
	)

Sidebar.BorderSizePixel = 0

Sidebar.Parent =
	Body

--========================================================
-- SIDEBAR LIST
--========================================================

local SidebarList =
	Instance.new("UIListLayout")

SidebarList.Padding =
	UDim.new(
		0,
		5
	)

SidebarList.HorizontalAlignment =
	Enum.HorizontalAlignment.Center

SidebarList.SortOrder =
	Enum.SortOrder.LayoutOrder

SidebarList.Parent =
	Sidebar

local SidebarPadding =
	Instance.new("UIPadding")

SidebarPadding.PaddingTop =
	UDim.new(
		0,
		10
	)

SidebarPadding.PaddingLeft =
	UDim.new(
		0,
		8
	)

SidebarPadding.PaddingRight =
	UDim.new(
		0,
		8
	)

SidebarPadding.Parent =
	Sidebar

local function CreateCategoryButton(
	text,
	order
)

	local button =
		Instance.new("TextButton")

	button.Size =
		UDim2.new(
			1,
			0,
			0,
			43
		)

	button.BackgroundColor3 =
		Color3.fromRGB(
			20,
			20,
			26
		)

	button.BorderSizePixel = 0

	button.Text =
		text

	button.TextColor3 =
		CONFIG.Text

	button.TextSize = 12

	button.Font =
		Enum.Font.GothamBold

	button.AutoButtonColor = false

	button.LayoutOrder =
		order

	button.Parent =
		Sidebar

	Corner(
		button,
		9
	)

	Stroke(
		button,
		Color3.fromRGB(
			45,
			45,
			55
		),
		1
	)

	return button
end

local CategoryButtons = {}

CategoryButtons.Botoes =
	CreateCategoryButton(
		"▣  Botões",
		1
	)

CategoryButtons.Locomocao =
	CreateCategoryButton(
		"↕  Locomoção",
		2
	)

CategoryButtons.Visualizacao =
	CreateCategoryButton(
		"◉  Visualização",
		3
	)

CategoryButtons.Configuracoes =
	CreateCategoryButton(
		"⚙  Configurações",
		4
	)

--========================================================
-- CONTENT
--========================================================

local Content =
	Instance.new("ScrollingFrame")

Content.Name =
	"Content"

Content.Size =
	UDim2.new(
		1,
		-CONFIG.SidebarWidth - 10,
		1,
		-10
	)

Content.Position =
	UDim2.new(
		0,
		CONFIG.SidebarWidth + 5,
		0,
		5
	)

Content.BackgroundTransparency = 1

Content.BorderSizePixel = 0

Content.ScrollBarThickness = 3

Content.ScrollBarImageColor3 =
	Color3.fromRGB(
		125,
		20,
		20
	)

Content.CanvasSize =
	UDim2.fromOffset(
		0,
		0
	)

Content.AutomaticCanvasSize =
	Enum.AutomaticSize.Y

Content.Parent =
	Body

local ContentList =
	Instance.new("UIListLayout")

ContentList.Padding =
	UDim.new(
		0,
		10
	)

ContentList.HorizontalAlignment =
	Enum.HorizontalAlignment.Center

ContentList.SortOrder =
	Enum.SortOrder.LayoutOrder

ContentList.Parent =
	Content

local ContentPadding =
	Instance.new("UIPadding")

ContentPadding.PaddingTop =
	UDim.new(
		0,
		5
	)

ContentPadding.PaddingBottom =
	UDim.new(
		0,
		10
	)

ContentPadding.PaddingLeft =
	UDim.new(
		0,
		8
	)

ContentPadding.PaddingRight =
	UDim.new(
		0,
		8
	)

ContentPadding.Parent =
	Content

--========================================================
-- SECTION
--========================================================

local Sections = {}

local function CreateSection(
	name,
	order
)

  	local section =
		Instance.new("Frame")

	section.Name =
		name

	section.Size =
		UDim2.new(
			1,
			-2,
			0,
			0
		)

	section.AutomaticSize =
		Enum.AutomaticSize.Y

	section.BackgroundTransparency = 1

	section.LayoutOrder =
		order

	section.Parent =
		Content

	local title =
		Instance.new("TextLabel")

	title.Size =
		UDim2.new(
			1,
			0,
			0,
			28
		)

	title.BackgroundTransparency = 1

	title.Text =
		name

	title.TextXAlignment =
		Enum.TextXAlignment.Left

	title.TextColor3 =
		Color3.fromRGB(
			240,
			240,
			245
		)

	title.TextSize = 16

	title.Font =
		Enum.Font.GothamBold

	title.Parent =
		section

	local list =
		Instance.new("UIListLayout")

	list.Padding =
		UDim.new(
			0,
			6
		)

	list.SortOrder =
		Enum.SortOrder.LayoutOrder

	list.Parent =
		section

	local padding =
		Instance.new("UIPadding")

	padding.PaddingTop =
		UDim.new(
			0,
			32
		)

	padding.Parent =
		section

	Sections[name] =
		section

	return section
end

local BotoesSection =
	CreateSection(
		"Botões",
		1
	)

local LocomocaoSection =
	CreateSection(
		"Locomoção",
		2
	)

local VisualizacaoSection =
	CreateSection(
		"Visualização",
		3
	)

local ConfiguracoesSection =
	CreateSection(
		"Configurações",
		4
	)

local function CreateSectionButton(
	parent,
	text
)

	local button =
		Instance.new("TextButton")

	button.Size =
		UDim2.new(
			1,
			0,
			0,
			43
		)

	button.BackgroundColor3 =
		CONFIG.ButtonColor

	button.BorderSizePixel = 0

	button.Text =
		text

	button.TextColor3 =
		CONFIG.Text

	button.TextSize = 13

	button.TextXAlignment =
		Enum.TextXAlignment.Left

	button.Font =
		Enum.Font.GothamBold

	button.AutoButtonColor = false

	button.Parent =
		parent

	Corner(
		button,
		8
	)

	local padding =
		Instance.new("UIPadding")

	padding.PaddingLeft =
		UDim.new(
			0,
			14
		)

	padding.Parent =
		button

	Stroke(
		button,
		Color3.fromRGB(
			55,
			55,
			65
		),
		1
	)

	return button
end

--========================================================
-- BOTÕES
--========================================================

local MessageButton =
	CreateSectionButton(
		BotoesSection,
		"Mensagens"
	)

local EditButton =
	CreateSectionButton(
		BotoesSection,
		"Edição: OFF"
	)

local PositionButton =
	CreateSectionButton(
		BotoesSection,
		"Modo Posição: OFF"
	)

local TallPointButton =
	CreateSectionButton(
		BotoesSection,
		"TallPoint: OFF"
	)

local TallPointEditButton =
	CreateSectionButton(
		BotoesSection,
		"Edição TallPoint: OFF"
	)

local DoubleButton =
	CreateSectionButton(
		BotoesSection,
		"Enviar 2x: OFF"
	)

--========================================================
-- LOCOMOÇÃO
--========================================================

local ArrowButton =
	CreateSectionButton(
		LocomocaoSection,
		"Setas: ON"
	)

local ArrowEditButton =
	CreateSectionButton(
		LocomocaoSection,
		"Edição Setas: OFF"
	)

local DrivingButton =
	CreateSectionButton(
		LocomocaoSection,
		"Driving: OFF"
	)

local DrivingEditButton =
	CreateSectionButton(
		LocomocaoSection,
		"Edição Driving: OFF"
	)

--========================================================
-- VISUALIZAÇÃO
--========================================================

local ESPButton =
	CreateSectionButton(
		VisualizacaoSection,
		"ESP: OFF"
	)

local ShiftButton =
	CreateSectionButton(
		VisualizacaoSection,
		"ShiftLock Forçado: OFF"
	)

--========================================================
-- CONFIGURAÇÕES
--========================================================

local OptimizationButton =
	CreateSectionButton(
		ConfiguracoesSection,
		"Otimização: OFF"
	)

--========================================================
-- MESSAGE INPUT
--========================================================

local MessageInput =
	Instance.new("TextBox")

MessageInput.Name =
	"MessageInput"

MessageInput.Size =
	UDim2.new(
		1,
		0,
		0,
		42
	)

MessageInput.BackgroundColor3 =
	Color3.fromRGB(
		30,
		30,
		37
	)

MessageInput.BorderSizePixel = 0

MessageInput.TextColor3 =
	Color3.new(
		1,
		1,
		1
	)

MessageInput.PlaceholderColor3 =
	Color3.fromRGB(
		140,
		140,
		150
	)

MessageInput.PlaceholderText =
	"Digite uma mensagem e pressione ENTER"

MessageInput.ClearTextOnFocus = false

MessageInput.TextSize = 13

MessageInput.Font =
	Enum.Font.Gotham

MessageInput.Visible = false

MessageInput.Parent =
	BotoesSection

Corner(
	MessageInput,
	8
)

Stroke(
	MessageInput,
	Color3.fromRGB(
		65,
		65,
		75
	),
	1
)

--========================================================
-- MESSAGE LAYER
--========================================================

local MessageLayer =
	Instance.new("Frame")

MessageLayer.Name =
	"MessageButtons"

MessageLayer.Size =
	UDim2.fromScale(
		1,
		1
	)

MessageLayer.BackgroundTransparency = 1

MessageLayer.ZIndex = 20

MessageLayer.Parent =
	Gui

local MessageButtons = {}

--========================================================
-- SELECTION
--========================================================

local function ClearSelection()

	local selected =
		State.SelectedObject

	if selected then

		local selection =
			selected:FindFirstChild(
				"LoLSelection"
			)

		if selection then
			selection:Destroy()
		end

	end

	State.SelectedObject = nil

end

local function SelectObject(object)

	ClearSelection()

	if not object then
		return
	end

	State.SelectedObject =
		object

	local selection =
		Instance.new("UIStroke")

	selection.Name =
		"LoLSelection"

	selection.Color =
		CONFIG.Yellow

	selection.Thickness = 2

	selection.Parent =
		object

end

--========================================================
-- GENERIC POSITION DRAG
--========================================================

local function EnablePositionDrag(
	object,
	enabledFunction
)

	local dragging = false
	local startTouch
	local startPosition

	object.InputBegan:Connect(function(input)

		if not enabledFunction() then
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
			object.Position

		SelectObject(object)

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
			input.Position -
			startTouch

		object.Position =
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
-- GENERIC RESIZE HANDLE
--========================================================

local function CreateResizeHandle(
	object,
	minWidth,
	maxWidth,
	minHeight,
	maxHeight,
	enabledFunction
)

	local handle =
		Instance.new("TextButton")

	handle.Name =
		"ResizeHandle"

	handle.Size =
		UDim2.fromOffset(
			34,
			30
		)

	handle.AnchorPoint =
		Vector2.new(
			1,
			1
		)

	handle.Position =
		UDim2.new(
			1,
			-3,
			1,
			-3
		)

	handle.BackgroundColor3 =
		CONFIG.Yellow

	handle.Text =
		"↘"

	handle.TextColor3 =
		Color3.fromRGB(
			20,
			20,
			20
		)

	handle.TextSize = 16

	handle.Font =
		Enum.Font.GothamBold

	handle.AutoButtonColor = false

	handle.Visible = false

	handle.ZIndex = 100

	handle.Parent =
		object

	Corner(
		handle,
		10
	)

	local resizing = false
	local startTouch
	local startSize

	handle.InputBegan:Connect(function(input)

		if not enabledFunction() then
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
			object.AbsoluteSize

		SelectObject(object)

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
			input.Position -
			startTouch

		local width =
			math.clamp(
				startSize.X + delta.X,
				minWidth,
				maxWidth
			)

		local height =
			math.clamp(
				startSize.Y + delta.Y,
				minHeight,
				maxHeight
			)

		object.Size =
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
-- CHAT
--========================================================

local function SendMessage(message)

	if typeof(message) ~= "string" then
		return
	end

	message =
		message:match("^%s*(.-)%s*$")

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

			if object:IsA(
				"TextChannel"
			) then

				channel =
					object

				break

			end

		end

	end

	if not channel then
		return
	end

	pcall(function()

		channel:SendAsync(
			message
		)

	end)

end

--========================================================
-- CREATE MESSAGE BUTTON
--========================================================

local function CreateMessageButton(
	message
)

	if typeof(message) ~= "string" then
		return
	end

	message =
		message:match("^%s*(.-)%s*$")

	if message == "" then
		return
	end

	local button =
		Instance.new("TextButton")

	button.Name =
		"MessageButton"

	button.Size =
		UDim2.fromOffset(
			CONFIG.MessageDefaultWidth,
			CONFIG.MessageDefaultHeight
		)

	local index =
		#MessageButtons

	local column =
		index % 5

	local row =
		math.floor(
			index / 5
		)

	button.Position =
		UDim2.fromOffset(
			15 + column * 92,
			90 + row * 72
		)

	button.BackgroundColor3 =
		CONFIG.Red

	button.BorderSizePixel = 0

	button.Text =
		message

	button.TextColor3 =
		Color3.new(
			1,
			1,
			1
		)

	button.TextWrapped = true
	button.TextScaled = true

	button.Font =
		Enum.Font.GothamBold

	button.ZIndex = 25

	button.Parent =
		MessageLayer

	Corner(
		button,
		10
	)

	Stroke(
		button,
		Color3.fromRGB(
			255,
			70,
			70
		),
		1
	)

	Gradient(
		button,
		Color3.fromRGB(
			185,
			15,
			15
		),

		Color3.fromRGB(
			80,
			0,
			0
		),

		90
	)

	local handle =
		CreateResizeHandle(
			button,

			CONFIG.MessageMinWidth,
			CONFIG.MessageMaxWidth,

			CONFIG.MessageMinHeight,
			CONFIG.MessageMaxHeight,

			function()
				return State.EditMode
			end
		)

	EnablePositionDrag(
		button,

		function()
			return State.PositionMode
		end
	)

	button.Activated:Connect(function()

		if State.PositionMode then

			SelectObject(
				button
			)

			return

		end

		if State.EditMode then

			SelectObject(
				button
			)

			return

		end

		SendMessage(
			message
		)

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

MessageInput.FocusLost:Connect(
	function(enterPressed)

		if not enterPressed then
			return
		end

		local message =
			MessageInput.Text

		if message == "" then
			return
		end

		CreateMessageButton(
			message
		)

		MessageInput.Text = ""

	end
)

--========================================================
-- MESSAGE MODE
--========================================================

MessageButton.Activated:Connect(
	function()

		MessageInput.Visible =
			not MessageInput.Visible

	end
)

--========================================================
-- EDIT MESSAGE MODE
--========================================================

EditButton.Activated:Connect(
	function()

		State.EditMode =
			not State.EditMode

		if State.EditMode then

			State.PositionMode = false
			State.ArrowEditMode = false
			State.TallPointEditMode = false
			State.DrivingEditMode = false

		end

		SetButtonState(
			EditButton,
			State.EditMode,
			"Edição"
		)

		SetButtonState(
			PositionButton,
			State.PositionMode,
			"Modo Posição"
		)

		for _, data in ipairs(
			MessageButtons
		) do

			if data.Handle then

				data.Handle.Visible =
					State.EditMode

			end

		end

	end
)

--========================================================
-- DELETE SELECTED MESSAGE
--========================================================

local DeleteMessageButton =
	CreateSectionButton(
		BotoesSection,
		"Apagar selecionado"
	)

DeleteMessageButton.Activated:Connect(
	function()

		if not State.EditMode then
			return
		end

		local selected =
			State.SelectedObject

		if not selected then
			return
		end

		for i, data in ipairs(
			MessageButtons
		) do

			if data.Object ==
				selected then

				table.remove(
					MessageButtons,
					i
				)

				break

			end

		end

		SafeDestroy(
			selected
		)

		State.SelectedObject = nil

	end
)

--========================================================
-- POSITION MODE
--========================================================

PositionButton.Activated:Connect(
	function()

		State.PositionMode =
			not State.PositionMode

		if State.PositionMode then

			State.EditMode = false
			State.ArrowEditMode = false
			State.TallPointEditMode = false
			State.DrivingEditMode = false

		end

		SetButtonState(
			PositionButton,
			State.PositionMode,
			"Modo Posição"
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
				data.Handle.Visible = false
			end

		end

	end
)

--========================================================
-- DOUBLE SEND
--========================================================

DoubleButton.Activated:Connect(
	function()

		State.DoubleSend =
			not State.DoubleSend

		SetButtonState(
			DoubleButton,
			State.DoubleSend,
			"Enviar 2x"
		)

	end
)

--========================================================
-- MOBILE ARROWS
--========================================================

local ArrowFrame =
	Instance.new("Frame")

ArrowFrame.Name =
	"MobileArrows"

ArrowFrame.Size =
	UDim2.fromOffset(
		215,
		150
	)

ArrowFrame.AnchorPoint =
	Vector2.new(
		0,
		1
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

ArrowFrame.ZIndex = 30

ArrowFrame.Parent =
	Gui

local function CreateArrow(
	name,
	text,
	position
)

	local button =
		Instance.new("TextButton")

	button.Name =
		name

	button.Size =
		UDim2.fromOffset(
			CONFIG.ArrowDefaultWidth,
			CONFIG.ArrowDefaultHeight
		)

	button.Position =
		position

	button.BackgroundColor3 =
		Color3.fromRGB(
			28,
			28,
			35
		)

	button.BorderSizePixel = 0

	button.Text =
		text

	button.TextColor3 =
		Color3.new(
			1,
			1,
			1
		)

	button.TextSize = 25

	button.Font =
		Enum.Font.GothamBold

	button.AutoButtonColor = false

	button.ZIndex = 31

	button.Parent =
		ArrowFrame

	Corner(
		button,
		18
	)

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
		Color3.fromRGB(
			48,
			48,
			58
		),

		Color3.fromRGB(
			20,
			20,
			25
		),

		90
	)

	local handle =
		CreateResizeHandle(
			button,

			CONFIG.ArrowMinWidth,
			CONFIG.ArrowMaxWidth,

			CONFIG.ArrowMinHeight,
			CONFIG.ArrowMaxHeight,

			function()
				return State.ArrowEditMode
			end
		)

	EnablePositionDrag(
		button,

		function()
			return State.PositionMode
		end
	)

	button.InputBegan:Connect(
		function(input)

			if input.UserInputType ~=
				Enum.UserInputType.Touch then
				return
			end

			if State.ArrowEditMode then

				SelectObject(
					button
				)

				return

			end

			if State.PositionMode then
				return
			end

			Tween(
				button,
				{
					BackgroundColor3 =
						Color3.fromRGB(
							55,
							55,
							68
						)
				},
				0.08
			)

		end
	)

	button.InputEnded:Connect(
		function(input)

			if input.UserInputType ~=
				Enum.UserInputType.Touch then
				return
			end

			Tween(
				button,
				{
					BackgroundColor3 =
						Color3.fromRGB(
							28,
							28,
							35
						)
				},
				0.12
			)

		end
	)

	return button, handle
end

local Up, UpHandle =
	CreateArrow(
		"Up",
		"▲",
		UDim2.fromOffset(
			74,
			0
		)
	)

local Down, DownHandle =
	CreateArrow(
		"Down",
		"▼",
		UDim2.fromOffset(
			74,
			72
		)
	)

local Left, LeftHandle =
	CreateArrow(
		"Left",
		"◀",
		UDim2.fromOffset(
			0,
			72
		)
	)

local Right, RightHandle =
	CreateArrow(
		"Right",
		"▶",
		UDim2.fromOffset(
			148,
			72
		)
	)

--========================================================
-- ARROW INPUT
--========================================================

local function ConnectArrow(
	button,
	direction
)

	button.InputBegan:Connect(
		function(input)

			if State.PositionMode
				or State.ArrowEditMode then
				return
			end

			if input.UserInputType ==
				Enum.UserInputType.Touch then

				State.Moving[direction] =
					true

			end

		end
	)

	button.InputEnded:Connect(
		function(input)

			if input.UserInputType ==
				Enum.UserInputType.Touch then

				State.Moving[direction] =
					false

			end

		end
	)

end

ConnectArrow(
	Up,
	"Up"
)

ConnectArrow(
	Down,
	"Down"
)

ConnectArrow(
	Left,
	"Left"
)

ConnectArrow(
	Right,
	"Right"
)

--========================================================
-- ARROW TOGGLE
--========================================================

ArrowButton.Activated:Connect(
	function()

		State.Arrows =
			not State.Arrows

		ArrowFrame.Visible =
			State.Arrows

		SetButtonState(
			ArrowButton,
			State.Arrows,
			"Setas"
		)

	end
)

--========================================================
-- ARROW EDIT MODE
--========================================================

ArrowEditButton.Activated:Connect(
	function()

		State.ArrowEditMode =
			not State.ArrowEditMode

		if State.ArrowEditMode then

			State.PositionMode = false
			State.EditMode = false
			State.TallPointEditMode = false
			State.DrivingEditMode = false

		end

		SetButtonState(
			ArrowEditButton,
			State.ArrowEditMode,
			"Edição Setas"
		)

		SetButtonState(
			PositionButton,
			State.PositionMode,
			"Modo Posição"
		)

		for _, handle in ipairs({
			UpHandle,
			DownHandle,
			LeftHandle,
			RightHandle
		}) do

			handle.Visible =
				State.ArrowEditMode

		end

	end
)

--========================================================
-- TALLPOINT
--========================================================

local TallPoint =
	Instance.new("TextButton")

TallPoint.Name =
	"TallPoint"

TallPoint.Size =
	UDim2.fromOffset(
		CONFIG.TallPointDefaultSize,
		CONFIG.TallPointDefaultSize
	)

TallPoint.AnchorPoint =
	Vector2.new(
		0.5,
		0.5
	)

TallPoint.Position =
	UDim2.new(
		0.5,
		0,
		0.5,
		100
	)

TallPoint.BackgroundTransparency = 1

TallPoint.BorderSizePixel = 0

TallPoint.Text = ""

TallPoint.AutoButtonColor = false

TallPoint.Visible = false

TallPoint.ZIndex = 50

TallPoint.Parent =
	Gui

Corner(
	TallPoint,
	100
)

local TallPointStroke =
	Stroke(
		TallPoint,
		Color3.fromRGB(
			230,
			230,
			235
		),
		3
)

--========================================================
-- TALLPOINT CENTER DOT
--========================================================

local TallPointDot =
	Instance.new("TextLabel")

TallPointDot.Name =
	"CenterPoint"

TallPointDot.Size =
	UDim2.fromScale(
		1,
		1
	)

TallPointDot.BackgroundTransparency = 1

TallPointDot.Text =
	"•"

TallPointDot.TextColor3 =
	Color3.fromRGB(
		255,
		255,
		255
	)

TallPointDot.TextSize = 25

TallPointDot.Font =
	Enum.Font.GothamBold

TallPointDot.ZIndex = 51

TallPointDot.Parent =
	TallPoint

--========================================================
-- TALLPOINT RESIZE
--========================================================

local TallPointHandle =
	CreateResizeHandle(
		TallPoint,

		CONFIG.TallPointMinSize,
		CONFIG.TallPointMaxSize,

		CONFIG.TallPointMinSize,
		CONFIG.TallPointMaxSize,

		function()
			return State.TallPointEditMode
		end
	)

EnablePositionDrag(
	TallPoint,

	function()
		return State.PositionMode
	end
)

--========================================================
-- TALLPOINT ACTION
--========================================================

local function TallPointAction()

	-- A área inteira do círculo funciona como toque.
	-- A função padrão é abrir/reduzir o painel.

	State.PanelMinimized =
		not State.PanelMinimized

end

TallPoint.Activated:Connect(
	function()

		if State.PositionMode then

			SelectObject(
				TallPoint
			)

			return

		end

		if State.TallPointEditMode then

			SelectObject(
				TallPoint
			)

			return

		end

		TallPointAction()

	end
)

--========================================================
-- TALLPOINT TOGGLE
--========================================================

TallPointButton.Activated:Connect(
	function()

		State.TallPoint =
			not State.TallPoint

		TallPoint.Visible =
			State.TallPoint

		SetButtonState(
			TallPointButton,
			State.TallPoint,
			"TallPoint"
		)

	end
)

--========================================================
-- TALLPOINT EDIT
--========================================================

TallPointEditButton.Activated:Connect(
	function()

		State.TallPointEditMode =
			not State.TallPointEditMode

		if State.TallPointEditMode then

			State.PositionMode = false
			State.EditMode = false
			State.ArrowEditMode = false
			State.DrivingEditMode = false

			State.TallPoint = true
			TallPoint.Visible = true

			SetButtonState(
				TallPointButton,
				true,
				"TallPoint"
			)

		end

		TallPointHandle.Visible =
			State.TallPointEditMode

		SetButtonState(
			TallPointEditButton,
			State.TallPointEditMode,
			"Edição TallPoint"
		)

	end
)

--========================================================
-- DRIVING GUI
--========================================================

local DrivingGui =
	Instance.new("Frame")

DrivingGui.Name =
	"DrivingControls"

DrivingGui.Size =
	UDim2.fromScale(
		1,
		1
	)

DrivingGui.BackgroundTransparency = 1

DrivingGui.Visible =
	false

DrivingGui.ZIndex = 40

DrivingGui.Parent =
	Gui

--========================================================
-- DRIVING WHEEL
--========================================================

local Wheel =
	Instance.new("TextButton")

Wheel.Name =
	"DrivingWheel"

Wheel.Size =
	UDim2.fromOffset(
		CONFIG.DrivingWheelWidth,
		CONFIG.DrivingWheelHeight
	)

Wheel.AnchorPoint =
	Vector2.new(
		0,
		1
	)

Wheel.Position =
	UDim2.new(
		0,
		25,
		1,
		-25
	)

Wheel.BackgroundTransparency = 1

Wheel.Text = ""

Wheel.AutoButtonColor = false

Wheel.ZIndex = 41

Wheel.Parent =
	DrivingGui

Corner(
	Wheel,
	100
)

local WheelStroke =
	Stroke(
		Wheel,
		Color3.fromRGB(
			220,
			220,
			225
		),
		8
)

--========================================================
-- WHEEL CENTER
--========================================================

local WheelCenter =
	Instance.new("Frame")

WheelCenter.Size =
	UDim2.fromOffset(
		54,
		54
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
		30,
		30,
		35
	)

WheelCenter.BorderSizePixel = 0

WheelCenter.ZIndex = 42

WheelCenter.Parent =
	Wheel

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

WheelMark.Text =
	"▲"

WheelMark.TextColor3 =
	Color3.fromRGB(
		235,
		235,
		240
	)

WheelMark.TextSize = 15

WheelMark.Font =
	Enum.Font.GothamBold

WheelMark.ZIndex = 43

WheelMark.Parent =
	WheelCenter

--========================================================
-- DRIVING WHEEL CONTROL
--========================================================

local wheelDragging = false

local function UpdateWheel(
	position
)

	local center =
		Wheel.AbsolutePosition +
		Wheel.AbsoluteSize / 2

	local offset =
		position - center

	if offset.Magnitude < 8 then
		return
	end

	local angle =
		math.deg(
			math.atan2(
				offset.Y,
				offset.X
			)
		) + 90

	while angle > 180 do
		angle -= 360
	end

	while angle < -180 do
		angle += 360
	end

	angle =
		math.clamp(
			angle,
			-75,
			75
		)

	State.Driving.Steer =
		math.clamp(
			angle / 75,
			-1,
			1
		)

	Wheel.Rotation =
		angle

end

Wheel.InputBegan:Connect(
	function(input)

		if State.PositionMode
			or State.DrivingEditMode then
			return
		end

		if input.UserInputType ~=
			Enum.UserInputType.Touch then
			return
		end

		wheelDragging = true

		UpdateWheel(
			input.Position
		)

	end
)

UIS.InputChanged:Connect(
	function(input)

		if not wheelDragging then
			return
		end

		if input.UserInputType ~=
			Enum.UserInputType.Touch then
			return
		end

		UpdateWheel(
			input.Position
		)

	end
)

UIS.InputEnded:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.Touch then

			wheelDragging = false

			State.Driving.Steer = 0

			Tween(
				Wheel,
				{
					Rotation = 0
				},
				0.15
			)

		end

	end
)

--========================================================
-- SWIFT / THROTTLE
--========================================================

local Swift =
	Instance.new("Frame")

Swift.Name =
	"Swift"

Swift.Size =
	UDim2.fromOffset(
		CONFIG.DrivingStickWidth,
		CONFIG.DrivingStickHeight
	)

Swift.AnchorPoint =
	Vector2.new(
		1,
		1
	)

Swift.Position =
	UDim2.new(
		1,
		-25,
		1,
		-25
	)

Swift.BackgroundColor3 =
	Color3.fromRGB(
		18,
		18,
		23
	)

Swift.BorderSizePixel = 0

Swift.ZIndex = 41

Swift.Parent =
	DrivingGui

Corner(
	Swift,
	20
)

Stroke(
	Swift,
	Color3.fromRGB(
		90,
		90,
		100
	),
	2
)

--========================================================
-- SWIFT TRACK
--========================================================

local SwiftTrack =
	Instance.new("Frame")

SwiftTrack.Size =
	UDim2.new(
		0,
		10,
		1,
		-30
	)

SwiftTrack.AnchorPoint =
	Vector2.new(
		0.5,
		0.5
	)

SwiftTrack.Position =
	UDim2.fromScale(
		0.5,
		0.5
	)

SwiftTrack.BackgroundColor3 =
	Color3.fromRGB(
		55,
		55,
		65
	)

SwiftTrack.BorderSizePixel = 0

SwiftTrack.ZIndex = 42

SwiftTrack.Parent =
	Swift

Corner(
	SwiftTrack,
	8
)

--========================================================
-- SWIFT HANDLE
--========================================================

local SwiftKnob =
	Instance.new("TextButton")

SwiftKnob.Name =
	"SwiftKnob"

SwiftKnob.Size =
	UDim2.fromOffset(
		54,
		54
	)

SwiftKnob.AnchorPoint =
	Vector2.new(
		0.5,
		0.5
	)

SwiftKnob.Position =
	UDim2.fromScale(
		0.5,
		0.5
	)

SwiftKnob.BackgroundColor3 =
	Color3.fromRGB(
		45,
		45,
		52
	)

SwiftKnob.BorderSizePixel = 0

SwiftKnob.Text =
	""

SwiftKnob.AutoButtonColor = false

SwiftKnob.ZIndex = 44

SwiftKnob.Parent =
	Swift

Corner(
	SwiftKnob,
	100
)

Stroke(
	SwiftKnob,
	Color3.fromRGB(
		125,
		125,
		135
	),
	2
)

--========================================================
-- SWIFT ARROWS
--========================================================

local SwiftUp =
	Instance.new("TextLabel")

SwiftUp.Size =
	UDim2.fromOffset(
		30,
		25
	)

SwiftUp.AnchorPoint =
	Vector2.new(
		0.5,
		0
	)

SwiftUp.Position =
	UDim2.new(
		0.5,
		0,
		0,
		5
	)

SwiftUp.BackgroundTransparency = 1

SwiftUp.Text =
	"▲"

SwiftUp.TextColor3 =
	Color3.fromRGB(
		230,
		230,
		235
	)

SwiftUp.TextSize = 14

SwiftUp.Font =
	Enum.Font.GothamBold

SwiftUp.ZIndex = 43

SwiftUp.Parent =
	Swift

local SwiftDown =
	SwiftUp:Clone()

SwiftDown.Text =
	"▼"

SwiftDown.Position =
	UDim2.new(
		0.5,
		0,
		1,
		-30
	)

SwiftDown.Parent =
	Swift

--========================================================
-- SWIFT TOUCH
--========================================================

local swiftDragging = false

local function UpdateSwift(
	position
)

	local top =
		Swift.AbsolutePosition.Y

	local height =
		Swift.AbsoluteSize.Y

	local localY =
		position.Y - top

	local normalized =
		math.clamp(
			localY / height,
			0,
			1
		)

	-- Norte = acelera
	-- Sul = ré/freia
	--
	-- Centro = neutro

	local throttle =
		1 - normalized

	State.Driving.Throttle =
		math.clamp(
			(throttle - 0.5) * 2,
			-1,
			1
		)

	local usableHeight =
		math.max(
			20,
			height - 70
		)

	local knobY =
		35 +
		(
			usableHeight *
			normalized
		)

	SwiftKnob.Position =
		UDim2.new(
			0.5,
			0,
			0,
			knobY
		)

end

Swift.InputBegan:Connect(
	function(input)

		if State.PositionMode
			or State.DrivingEditMode then
			return
		end

		if input.UserInputType ~=
			Enum.UserInputType.Touch then
			return
		end

		swiftDragging = true

		UpdateSwift(
			input.Position
		)

	end
)

UIS.InputChanged:Connect(
	function(input)

		if not swiftDragging then
			return
		end

		if input.UserInputType ~=
			Enum.UserInputType.Touch then
			return
		end

		UpdateSwift(
			input.Position
		)

	end
)

UIS.InputEnded:Connect(
	function(input)

		if input.UserInputType ==
			Enum.UserInputType.Touch then

			swiftDragging = false

			State.Driving.Throttle = 0

			Tween(
				SwiftKnob,
				{
					Position =
						UDim2.new(
							0.5,
							0,
							0.5,
							0
						)
				},
				0.15
			)

		end

	end
)

--========================================================
-- DRIVING POSITION / EDIT
--========================================================

EnablePositionDrag(
	Wheel,

	function()
		return State.PositionMode
	end
)

EnablePositionDrag(
	Swift,

	function()
		return State.PositionMode
	end
)

local WheelResize =
	CreateResizeHandle(
		Wheel,

		CONFIG.DrivingMinWidth,
		CONFIG.DrivingMaxWidth,

		CONFIG.DrivingMinHeight,
		CONFIG.DrivingMaxHeight,

		function()
			return State.DrivingEditMode
		end
	)

local SwiftResize =
	CreateResizeHandle(
		Swift,

		CONFIG.DrivingMinWidth,
		CONFIG.DrivingMaxWidth,

		CONFIG.DrivingMinHeight,
		CONFIG.DrivingMaxHeight,

		function()
			return State.DrivingEditMode
		end
	)

--========================================================
-- DRIVING TOGGLE
--========================================================

DrivingButton.Activated:Connect(
	function()

		State.Driving =
			not State.Driving

		DrivingGui.Visible =
			State.Driving

		SetButtonState(
			DrivingButton,
			State.Driving,
			"Driving"
		)

		if not State.Driving then

			State.Driving.Steer = 0
			State.Driving.Throttle = 0

			Wheel.Rotation = 0

		end

	end
)

--========================================================
-- DRIVING EDIT
--========================================================

DrivingEditButton.Activated:Connect(
	function()

		State.DrivingEditMode =
			not State.DrivingEditMode

		if State.DrivingEditMode then

			State.PositionMode = false
			State.EditMode = false
			State.ArrowEditMode = false
			State.TallPointEditMode = false

			State.Driving = true
			DrivingGui.Visible = true

			SetButtonState(
				DrivingButton,
				true,
				"Driving"
			)

		end

		WheelResize.Visible =
			State.DrivingEditMode

		SwiftResize.Visible =
			State.DrivingEditMode

		SetButtonState(
			DrivingEditButton,
			State.DrivingEditMode,
			"Edição Driving"
		)

	end
)

--========================================================
-- CHARACTER MOVEMENT
--========================================================

RunService.RenderStepped:Connect(
	function()

		if not Humanoid then
			return
		end

		local camera =
			workspace.CurrentCamera

		if not camera then
			return
		end

		--============================================
		-- NORMAL ARROWS
		--============================================

		if State.Arrows
			and not State.Driving then

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
				forward =
					forward.Unit
			end

			if right.Magnitude > 0 then
				right =
					right.Unit
			end

			local direction =
				Vector3.zero

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

		end

		--============================================
		-- DRIVING
		--============================================

		if State.Driving then

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
				forward =
					forward.Unit
			end

			if right.Magnitude > 0 then
				right =
					right.Unit
			end

			local throttle =
				State.Driving.Throttle

			local steer =
				State.Driving.Steer

			if math.abs(throttle) > 0.02 then

				local driveDirection =
					forward *
					throttle

				Humanoid:Move(
					driveDirection,
					false
				)

			end

			-- Rotação visual do personagem
			-- acompanha o volante.

			if RootPart
				and math.abs(steer) > 0.02 then

				local current =
					RootPart.CFrame

				local rotation =
					CFrame.Angles(
						0,
						math.rad(
							steer * 2.5
						),
						0
					)

				RootPart.CFrame =
					current:Lerp(
						current * rotation,
						math.clamp(
							0.15,
							0,
							1
						)
					)

			end

		end

	end
)

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

	SafeDestroy(
		data.Highlight
	)

	SafeDestroy(
		data.Tag
	)

	ESPObjects[player] = nil

end

local function CreateESP(player)

	if player == Player then
		return
	end

	RemoveESP(
		player
	)

	local character =
		player.Character

	if not character then
		return
	end

	local head =
		character:FindFirstChild(
			"Head"
		)

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
		0.60

	highlight.OutlineTransparency =
		0

	highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Parent =
		character

	local tag =
		Instance.new("BillboardGui")

	tag.Name =
		"LoL_ESP_Name"

	tag.Adornee =
		head

	tag.Size =
		UDim2.fromOffset(
			135,
			22
		)

	tag.StudsOffset =
		Vector3.new(
			0,
			2.6,
			0
		)

	tag.AlwaysOnTop = true

	tag.Parent =
		head

	local label =
		Instance.new("TextLabel")

	label.Size =
		UDim2.fromScale(
			1,
			1
		)

	label.BackgroundTransparency = 1

	label.Text =
		player.DisplayName

	label.TextColor3 =
		CONFIG.ESPColor

	label.TextStrokeTransparency =
		0.25

	label.TextScaled = true

	label.Font =
		Enum.Font.GothamBold

	label.Parent =
		tag

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

				CreateESP(
					player
				)

			else

				RemoveESP(
					player
				)

			end

		end

	end

end

ESPButton.Activated:Connect(
	function()

		State.ESP =
			not State.ESP

		SetButtonState(
			ESPButton,
			State.ESP,
			"ESP"
		)

		UpdateESP()

	end
)

Players.PlayerAdded:Connect(
	function(player)

		player.CharacterAdded:Connect(
			function()

				if State.ESP then

					task.wait(
						0.25
					)

					CreateESP(
						player
					)

				end

			end
		)

	end
)

Players.PlayerRemoving:Connect(
	function(player)

		RemoveESP(
			player
		)

	end
)

--========================================================
-- SHIFTLOCK
--========================================================

local Crosshair =
	Instance.new("Frame")

Crosshair.Name =
	"ShiftLockCrosshair"

Crosshair.Size =
	UDim2.fromOffset(
		26,
		26
	)

Crosshair.AnchorPoint =
	Vector2.new(
		0.5,
		0.5
	)

Crosshair.Position =
	UDim2.fromScale(
		0.5,
		0.5
	)

Crosshair.BackgroundTransparency = 1

Crosshair.Visible = false

Crosshair.ZIndex = 90

Crosshair.Parent =
	Gui

local CrossHorizontal =
	Instance.new("Frame")

CrossHorizontal.Size =
	UDim2.fromOffset(
		18,
		2
	)

CrossHorizontal.AnchorPoint =
	Vector2.new(
		0.5,
		0.5
	)

CrossHorizontal.Position =
	UDim2.fromScale(
		0.5,
		0.5
	)

CrossHorizontal.BackgroundColor3 =
	Color3.new(
		1,
		1,
		1
	)

CrossHorizontal.BorderSizePixel = 0

CrossHorizontal.Parent =
	Crosshair

local CrossVertical =
	Instance.new("Frame")

CrossVertical.Size =
	UDim2.fromOffset(
		2,
		18
	)

CrossVertical.AnchorPoint =
	Vector2.new(
		0.5,
		0.5
	)

CrossVertical.Position =
	UDim2.fromScale(
		0.5,
		0.5
	)

CrossVertical.BackgroundColor3 =
	Color3.new(
		1,
		1,
		1
	)

CrossVertical.BorderSizePixel = 0

CrossVertical.Parent =
	Crosshair

--========================================================
-- SHIFTLOCK ENABLE
--========================================================

local function SetShiftLock(
	enabled
)

	State.ShiftLock =
		enabled

	if Humanoid then

		if enabled then

			OriginalAutoRotate =
				Humanoid.AutoRotate

			OriginalCameraOffset =
				Humanoid.CameraOffset

			Humanoid.AutoRotate =
				false

			Humanoid.CameraOffset =
				Vector3.new(
					1.65,
					0,
					0
				)

		else

			Humanoid.AutoRotate =
				OriginalAutoRotate

			Humanoid.CameraOffset =
				OriginalCameraOffset

		end

	end

	Crosshair.Visible =
		enabled

	SetButtonState(
		ShiftButton,
		enabled,
		"ShiftLock Forçado"
	)

end

ShiftButton.Activated:Connect(
	function()

		SetShiftLock(
			not State.ShiftLock
		)

	end
)

--========================================================
-- SHIFTLOCK CAMERA / ROTATION
--========================================================

RunService:BindToRenderStep(
	"LoLPainnelShiftLock",
	Enum.RenderPriority.Character.Value + 1,

	function(deltaTime)

		if not State.ShiftLock then
			return
		end

		if not Character
			or not Humanoid
			or not RootPart then
			return
		end

		local camera =
			workspace.CurrentCamera

		if not camera then
			return
		end

		local look =
			camera.CFrame.LookVector

		local flat =
			Vector3.new(
				look.X,
				0,
				look.Z
			)

		if flat.Magnitude <= 0.001 then
			return
		end

		flat =
			flat.Unit

		local target =
			CFrame.lookAt(
				RootPart.Position,
				RootPart.Position + flat
			)

		local alpha =
			math.clamp(
				deltaTime * 16,
				0,
				1
			)

		RootPart.CFrame =
			RootPart.CFrame:Lerp(
				target,
				alpha
			)

	end
)

--========================================================
-- OPTIMIZATION
--========================================================

local OptimizationBackup = {}
local OptimizationConnection = nil

local function SaveAndDisable(
	object,
	property
)

	local success, value =
		pcall(function()
			return object[property]
		end)

	if not success then
		return
	end

	if OptimizationBackup[object] == nil then

		OptimizationBackup[object] = {}

	end

	if OptimizationBackup[object][property]
		== nil then

		OptimizationBackup[object][property] =
			value

	end

	pcall(function()

		object[property] =
			false

	end)

end

local function ApplyOptimizationTo(
	object
)

	if object:IsA(
		"ParticleEmitter"
	) then

		SaveAndDisable(
			object,
			"Enabled"
		)

	elseif object:IsA(
		"Trail"
	) then

		SaveAndDisable(
			object,
			"Enabled"
		)

	elseif object:IsA(
		"Beam"
	) then

		SaveAndDisable(
			object,
			"Enabled"
		)

	elseif object:IsA(
		"Smoke"
	) then

		SaveAndDisable(
			object,
			"Enabled"
		)

	elseif object:IsA(
		"Fire"
	) then

		SaveAndDisable(
			object,
			"Enabled"
		)

	elseif object:IsA(
		"Sparkles"
	) then

		SaveAndDisable(
			object,
			"Enabled"
		)

	end

end

local LightingBackup = {}

local function EnableOptimization()

	if State.Optimization then
		return
	end

	State.Optimization = true

	--============================================
	-- LIGHTING
	--============================================

	pcall(function()

		LightingBackup.GlobalShadows =
			Lighting.GlobalShadows

		Lighting.GlobalShadows =
			false

	end)

	pcall(function()

		LightingBackup.FogEnd =
			Lighting.FogEnd

		Lighting.FogEnd =
			100000

	end)

	--============================================
	-- VISUAL EFFECTS
	--============================================

	for _, object in ipairs(
		game:GetDescendants()
	) do

		ApplyOptimizationTo(
			object
		)

	end

	if OptimizationConnection then
		OptimizationConnection:Disconnect()
	end

	OptimizationConnection =
		game.DescendantAdded:Connect(
			function(object)

				if State.Optimization then

					task.defer(
						ApplyOptimizationTo,
						object
					)

				end

			end
		)

	SetButtonState(
		OptimizationButton,
		true,
		"Otimização"
	)

end

local function DisableOptimization()

	if not State.Optimization then
		return
	end

	State.Optimization = false

	if OptimizationConnection then

		OptimizationConnection:Disconnect()

		OptimizationConnection =
			nil

	end

	--============================================
	-- RESTORE LIGHTING
	--============================================

	if LightingBackup.GlobalShadows ~= nil then

		pcall(function()

			Lighting.GlobalShadows =
				LightingBackup.GlobalShadows

		end)

	end

	if LightingBackup.FogEnd ~= nil then

		pcall(function()

			Lighting.FogEnd =
				LightingBackup.FogEnd

		end)

	end

	--============================================
	-- RESTORE EFFECTS
	--============================================

	for object, properties in pairs(
		OptimizationBackup
	) do

		if object
			and object.Parent then

			for property, value in pairs(
				properties
			) do

				pcall(function()

					object[property] =
						value

				end)

			end

		end

	end

	table.clear(
		OptimizationBackup
	)

	table.clear(
		LightingBackup
	)

	SetButtonState(
		OptimizationButton,
		false,
		"Otimização"
	)

end

OptimizationButton.Activated:Connect(
	function()

		if State.Optimization then

			DisableOptimization()

		else

			EnableOptimization()

		end

	end
)

--========================================================
-- CATEGORY NAVIGATION
--========================================================

local function GoToSection(
	name
)

	local section =
		Sections[name]

	if not section then
		return
	end

	task.defer(
		function()

			local y =
				section.AbsolutePosition.Y -
				Content.AbsolutePosition.Y

			Content.CanvasPosition =
				Vector2.new(
					0,
					math.max(
						0,
						y - 5
					)
				)

		end
	)

end

CategoryButtons.Botoes.Activated:Connect(
	function()
		GoToSection("Botões")
	end
)

CategoryButtons.Locomocao.Activated:Connect(
	function()
		GoToSection("Locomoção")
	end
)

CategoryButtons.Visualizacao.Activated:Connect(
	function()
		GoToSection("Visualização")
	end
)

CategoryButtons.Configuracoes.Activated:Connect(
	function()
		GoToSection("Configurações")
	end
)

--========================================================
-- MINIMIZE
--========================================================

local OriginalPanelHeight =
	CONFIG.PanelHeight

local MinimizedHeight =
	48

local function SetMinimized(
	minimized
)

	State.PanelMinimized =
		minimized

	if minimized then

		Tween(
			Panel,
			{
				Size =
					UDim2.fromOffset(
						CONFIG.PanelWidth,
						MinimizedHeight
					)
			},
			0.18
		)

		Body.Visible = false

		MinimizeButton.Text =
			"+"

	else

		Body.Visible = true

		Tween(
			Panel,
			{
				Size =
					UDim2.fromOffset(
						CONFIG.PanelWidth,
						OriginalPanelHeight
					)
			},
			0.18
		)

		MinimizeButton.Text =
			"−"

	end

end

MinimizeButton.Activated:Connect(
	function()

		SetMinimized(
			not State.PanelMinimized
		)

	end
)

--========================================================
-- CLOSE / DISABLE SCRIPT
--========================================================

local ScriptDisabled = false

local function DisableScript()

	if ScriptDisabled then
		return
	end

	ScriptDisabled = true

	--==============================
	-- SHIFTLOCK
	--==============================

	if State.ShiftLock then

		SetShiftLock(
			false
		)

	end

	--==============================
	-- OPTIMIZATION
	--==============================

	if State.Optimization then

		DisableOptimization()

	end

	--==============================
	-- ESP
	--==============================

	for player in pairs(
		ESPObjects
	) do

		RemoveESP(
			player
		)

	end

	--==============================
	-- MOVEMENT
	--==============================

	for direction in pairs(
		State.Moving
	) do

		State.Moving[direction] =
			false

	end

	State.Driving.Steer =
		0

	State.Driving.Throttle =
		0

	--==============================
	-- DESTROY GUI
	--==============================

	SafeDestroy(
		Gui
	)

end

CloseButton.Activated:Connect(
	DisableScript
)

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
			viewport.X / 950,
			viewport.Y / 720
		)

	PanelScale.Scale =
		math.clamp(
			scale,
			CONFIG.PanelMinScale,
			CONFIG.PanelMaxScale
		)

end

local function ConnectCamera()

	local camera =
		workspace.CurrentCamera

	if not camera then
		return
	end

	camera:GetPropertyChangedSignal(
		"ViewportSize"
	):Connect(
		UpdatePanelScale
	)

	UpdatePanelScale()

end

ConnectCamera()

workspace:GetPropertyChangedSignal(
	"CurrentCamera"
):Connect(
	function()

		task.defer(
			ConnectCamera
		)

	end
)

--========================================================
-- INITIAL STATES
--========================================================

SetButtonState(
	ArrowButton,
	true,
	"Setas"
)

SetButtonState(
	EditButton,
	false,
	"Edição"
)

SetButtonState(
	PositionButton,
	false,
	"Modo Posição"
)

SetButtonState(
	TallPointButton,
	false,
	"TallPoint"
)

SetButtonState(
	TallPointEditButton,
	false,
	"Edição TallPoint"
)

SetButtonState(
	ArrowEditButton,
	false,
	"Edição Setas"
)

SetButtonState(
	DrivingButton,
	false,
	"Driving"
)

SetButtonState(
	DrivingEditButton,
	false,
	"Edição Driving"
)

SetButtonState(
	ESPButton,
	false,
	"ESP"
)

SetButtonState(
	ShiftButton,
	false,
	"ShiftLock Forçado"
)

SetButtonState(
	OptimizationButton,
	false,
	"Otimização"
)

--========================================================
-- STARTUP
--========================================================

Panel.Visible = true
Body.Visible = true

ArrowFrame.Visible =
	State.Arrows

DrivingGui.Visible =
	State.Driving

TallPoint.Visible =
	State.TallPoint

print(
	"[LoL Painnel 1.1] Inicializado com sucesso."
)
