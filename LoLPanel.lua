--========================================================
-- LoL Pannel | Functional Edition
-- Luau / Roblox
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--========================================================
-- CONFIG
--========================================================

local CONFIG = {
	PanelSize = Vector2.new(500, 360),
	MessageButtonSize = 72,
	ArrowSize = 58,
	ESPColor = Color3.fromRGB(255, 0, 0)
}

--========================================================
-- ESTADOS
--========================================================

local State = {
	PanelOpen = true,
	EditMode = false,
	ESP = false,
	ShiftLock = false,

	DraggingPanel = false,
	SelectedButton = nil
}

local Character
local Humanoid
local RootPart

local MessageButtons = {}
local ESPObjects = {}

--========================================================
-- CHARACTER
--========================================================

local function updateCharacter(character)

	Character = character
	Humanoid = character:WaitForChild("Humanoid")
	RootPart = character:WaitForChild("HumanoidRootPart")

	if State.ShiftLock then
		Humanoid.AutoRotate = false
	end
end

if LocalPlayer.Character then
	updateCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(updateCharacter)

--========================================================
-- GUI BASE
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "LoLPannel"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = false
Gui.Parent = PlayerGui

--========================================================
-- FUNÇÕES GUI
--========================================================

local function Corner(object, radius)

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = object

end

local function Stroke(object, color, thickness)

	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.Parent = object

end

local function Button(parent, text, size, position)

	local b = Instance.new("TextButton")

	b.Size = size
	b.Position = position

	b.BackgroundColor3 =
		Color3.fromRGB(35, 35, 35)

	b.TextColor3 =
		Color3.new(1, 1, 1)

	b.Text = text

	b.Font =
		Enum.Font.GothamBold

	b.TextSize = 14

	b.AutoButtonColor = true

	b.Parent = parent

	Corner(b, 10)

	return b

end

--========================================================
-- CAMADA DOS BOTÕES DE MENSAGEM
--========================================================

local MessageLayer = Instance.new("Frame")

MessageLayer.Name = "MessageLayer"
MessageLayer.Size = UDim2.fromScale(1, 1)
MessageLayer.BackgroundTransparency = 1
MessageLayer.Parent = Gui

--========================================================
-- CHAT
--========================================================

local function SendMessage(message)

	if message == nil or message == "" then
		return
	end

	local channels =
		TextChatService:FindFirstChild("TextChannels")

	if not channels then
		return
	end

	local general =
		channels:FindFirstChild("RBXGeneral")

	if general then
		general:SendAsync(message)
	end

end

--========================================================
-- BOTÕES DE MENSAGEM
--========================================================

local function selectMessageButton(button)

	if State.SelectedButton then

		local oldStroke =
			State.SelectedButton:FindFirstChild("Selection")

		if oldStroke then
			oldStroke:Destroy()
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
		Color3.fromRGB(255, 220, 0)

	selection.Thickness = 3
	selection.Parent = button

end

local function makeDraggable(button)

	local dragging = false
	local startInput
	local startPosition

	button.InputBegan:Connect(function(input)

		if not State.EditMode then
			return
		end

		if
			input.UserInputType ==
			Enum.UserInputType.MouseButton1

			or

			input.UserInputType ==
			Enum.UserInputType.Touch
		then

			dragging = true

			startInput =
				input.Position

			startPosition =
				button.Position

			selectMessageButton(button)

		end

	end)

	UIS.InputChanged:Connect(function(input)

		if not dragging then
			return
		end

		if
			input.UserInputType ~=
			Enum.UserInputType.MouseMovement

			and

			input.UserInputType ~=
			Enum.UserInputType.Touch
		then
			return
		end

		local delta =
			input.Position - startInput

		button.Position =
			UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,

				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)

	end)

	UIS.InputEnded:Connect(function(input)

		if
			input.UserInputType ==
			Enum.UserInputType.MouseButton1

			or

			input.UserInputType ==
			Enum.UserInputType.Touch
		then

			dragging = false

		end

	end)

end

local function CreateMessageButton(message)

	local viewport =
		workspace.CurrentCamera.ViewportSize

	local index =
		#MessageButtons

	local size =
		CONFIG.MessageButtonSize

	local margin = 10

	local columns =
		math.max(
			1,
			math.floor(
				(viewport.X - 20) /
				(size + margin)
			)
		)

	local column =
		index % columns

	local row =
		math.floor(index / columns)

	local button =
		Instance.new("TextButton")

	button.Name = "MessageButton"

	button.Size =
		UDim2.fromOffset(
			size,
			size
		)

	button.Position =
		UDim2.fromOffset(
			10 + column * (size + margin),
			100 + row * (size + margin)
		)

	button.BackgroundColor3 =
		Color3.fromRGB(150, 0, 0)

	button.TextColor3 =
		Color3.new(1, 1, 1)

	button.Text =
		message

	button.TextWrapped = true

	button.TextSize = 13

	button.Font =
		Enum.Font.GothamBold

	button.Parent =
		MessageLayer

	Corner(button, 12)

	Stroke(
		button,
		Color3.fromRGB(255, 50, 50),
		1
	)

	button.Activated:Connect(function()

		if State.EditMode then

			selectMessageButton(button)

		else

			SendMessage(message)

		end

	end)

	makeDraggable(button)

	table.insert(
		MessageButtons,
		{
			Object = button,
			Message = message
		}
	)

end

--========================================================
-- PAINEL
--========================================================

local Panel =
	Instance.new("Frame")

Panel.Name = "Panel"

Panel.AnchorPoint =
	Vector2.new(0.5, 0.5)

Panel.Position =
	UDim2.fromScale(0.5, 0.5)

Panel.Size =
	UDim2.fromOffset(
		CONFIG.PanelSize.X,
		CONFIG.PanelSize.Y
	)

Panel.BackgroundColor3 =
	Color3.fromRGB(18, 18, 18)

Panel.BorderSizePixel = 0

Panel.Parent = Gui

Corner(Panel, 18)

Stroke(
	Panel,
	Color3.fromRGB(130, 0, 0),
	2
)

--========================================================
-- TÍTULO
--========================================================

local Title =
	Instance.new("TextLabel")

Title.Size =
	UDim2.new(1, -20, 0, 40)

Title.Position =
	UDim2.fromOffset(10, 5)

Title.BackgroundTransparency = 1

Title.Text = "LoL Pannel"

Title.TextColor3 =
	Color3.fromRGB(255, 50, 50)

Title.TextSize = 22

Title.Font =
	Enum.Font.GothamBold

Title.Parent = Panel

--========================================================
-- CAMPO DE FRASE
--========================================================

local MessageInput =
	Instance.new("TextBox")

MessageInput.Size =
	UDim2.new(1, -30, 0, 45)

MessageInput.Position =
	UDim2.fromOffset(15, 55)

MessageInput.BackgroundColor3 =
	Color3.fromRGB(40, 40, 40)

MessageInput.TextColor3 =
	Color3.new(1, 1, 1)

MessageInput.PlaceholderText =
	"Digite uma frase e pressione ENTER"

MessageInput.Text = ""

MessageInput.ClearTextOnFocus = false

MessageInput.TextSize = 14

MessageInput.Parent = Panel

Corner(MessageInput, 10)

--========================================================
-- BOTÕES DO PAINEL
--========================================================

local EditButton =
	Button(
		Panel,
		"Edição: OFF",
		UDim2.fromOffset(140, 42),
		UDim2.fromOffset(15, 115)
	)

local DeleteButton =
	Button(
		Panel,
		"Apagar botão",
		UDim2.fromOffset(140, 42),
		UDim2.fromOffset(165, 115)
	)

local ESPButton =
	Button(
		Panel,
		"ESP: OFF",
		UDim2.fromOffset(140, 42),
		UDim2.fromOffset(15, 170)
	)

local ShiftButton =
	Button(
		Panel,
		"ShiftLock: OFF",
		UDim2.fromOffset(140, 42),
		UDim2.fromOffset(165, 170)
	)

local CloseButton =
	Button(
		Panel,
		"Fechar",
		UDim2.fromOffset(140, 42),
		UDim2.fromOffset(15, 225)
	)

--========================================================
-- CRIAR BOTÃO AO PRESSIONAR ENTER
--========================================================

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
-- MODO EDIÇÃO
--========================================================

EditButton.Activated:Connect(function()

	State.EditMode =
		not State.EditMode

	if State.EditMode then

		EditButton.Text =
			"Edição: ON"

		EditButton.BackgroundColor3 =
			Color3.fromRGB(0, 110, 55)

	else

		EditButton.Text =
			"Edição: OFF"

		EditButton.BackgroundColor3 =
			Color3.fromRGB(35, 35, 35)

		selectMessageButton(nil)

	end

end)

--========================================================
-- APAGAR BOTÃO
--========================================================

DeleteButton.Activated:Connect(function()

	if not State.EditMode then
		return
	end

	local selected =
		State.SelectedButton

	if not selected then
		return
	end

	for i, data in ipairs(MessageButtons) do

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
-- FECHAR / ABRIR PAINEL
--========================================================

local Toggle =
	Button(
		Gui,
		"⚙",
		UDim2.fromOffset(48, 48),
		UDim2.new(1, -60, 0, 15)
	)

Toggle.TextSize = 22

Toggle.BackgroundColor3 =
	Color3.fromRGB(150, 0, 0)

local function SetPanelVisible(value)

	State.PanelOpen = value

	Panel.Visible = value

end

CloseButton.Activated:Connect(function()

	SetPanelVisible(false)

end)

Toggle.Activated:Connect(function()

	SetPanelVisible(
		not State.PanelOpen
	)

end)

--========================================================
-- PAINEL MOVIMENTÁVEL
--========================================================

local DragArea =
	Instance.new("TextButton")

DragArea.Size =
	UDim2.new(1, -200, 0, 45)

DragArea.Position =
	UDim2.fromOffset(10, 5)

DragArea.BackgroundTransparency = 1

DragArea.Text = ""

DragArea.Parent = Panel

local dragging = false
local dragStart
local panelStart

DragArea.InputBegan:Connect(function(input)

	if
		input.UserInputType ==
		Enum.UserInputType.MouseButton1

		or

		input.UserInputType ==
		Enum.UserInputType.Touch
	then

		dragging = true

		dragStart =
			input.Position

		panelStart =
			Panel.Position

	end

end)

UIS.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if
		input.UserInputType ~=
		Enum.UserInputType.MouseMovement

		and

		input.UserInputType ~=
		Enum.UserInputType.Touch
	then
		return
	end

	local delta =
		input.Position - dragStart

	Panel.Position =
		UDim2.new(
			panelStart.X.Scale,
			panelStart.X.Offset + delta.X,

			panelStart.Y.Scale,
			panelStart.Y.Offset + delta.Y
		)

end)

UIS.InputEnded:Connect(function(input)

	if
		input.UserInputType ==
		Enum.UserInputType.MouseButton1

		or

		input.UserInputType ==
		Enum.UserInputType.Touch
	then

		dragging = false

	end

end)

--========================================================
-- ESP
--========================================================

local function RemoveESP(player)

	local data =
		ESPObjects[player]

	if not data then
		return
	end

	if data.Highlight then
		data.Highlight:Destroy()
	end

	if data.NameTag then
		data.NameTag:Destroy()
	end

	ESPObjects[player] = nil

end

local function CreateESP(player)

	if player == LocalPlayer then
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

	-- Aura
	local highlight =
		Instance.new("Highlight")

	highlight.Name =
		"ESP_Aura"

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

	-- Nome
	local tag =
		Instance.new("BillboardGui")

	tag.Name =
		"ESP_Name"

	tag.Adornee =
		head

	tag.Size =
		UDim2.fromOffset(160, 35)

	tag.StudsOffset =
		Vector3.new(0, 3, 0)

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

	label.TextStrokeTransparency = 0

	label.TextSize = 14

	label.Font =
		Enum.Font.GothamBold

	label.Parent = tag

	ESPObjects[player] = {
		Highlight = highlight,
		NameTag = tag
	}

end

local function UpdateESP()

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if player ~= LocalPlayer then

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

	if State.ESP then

		ESPButton.Text =
			"ESP: ON"

		ESPButton.BackgroundColor3 =
			Color3.fromRGB(120, 0, 0)

	else

		ESPButton.Text =
			"ESP: OFF"

		ESPButton.BackgroundColor3 =
			Color3.fromRGB(35, 35, 35)

	end

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

Players.PlayerRemoving:Connect(RemoveESP)

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

Crosshair.TextSize = 28

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

	if enabled then

		UIS.MouseBehavior =
			Enum.MouseBehavior.LockCenter

		Crosshair.Visible = true

		ShiftButton.Text =
			"ShiftLock: ON"

		ShiftButton.BackgroundColor3 =
			Color3.fromRGB(0, 110, 55)

	else

		UIS.MouseBehavior =
			Enum.MouseBehavior.Default

		Crosshair.Visible = false

		ShiftButton.Text =
			"ShiftLock: OFF"

		ShiftButton.BackgroundColor3 =
			Color3.fromRGB(35, 35, 35)

	end

end

local function ToggleShiftLock()

	SetShiftLock(
		not State.ShiftLock
	)

end

ShiftButton.Activated:Connect(
	ToggleShiftLock
)

UIS.InputBegan:Connect(function(input, processed)

	if processed then
		return
	end

	if
		input.KeyCode == Enum.KeyCode.LeftShift

		or

		input.KeyCode == Enum.KeyCode.RightShift
	then

		ToggleShiftLock()

	end

end)

--========================================================
-- SETAS
--========================================================

local ArrowFrame =
	Instance.new("Frame")

ArrowFrame.Name =
	"ArrowControls"

ArrowFrame.Size =
	UDim2.fromOffset(190, 130)

ArrowFrame.Position =
	UDim2.new(
		0,
		20,
		1,
		-145
	)

ArrowFrame.BackgroundTransparency = 1

ArrowFrame.Parent = Gui

local function CreateArrow(
	name,
	text,
	position
)

	local b =
		Instance.new("TextButton")

	b.Name = name

	b.Size =
		UDim2.fromOffset(
			CONFIG.ArrowSize,
			CONFIG.ArrowSize
		)

	b.Position = position

	b.BackgroundColor3 =
		Color3.fromRGB(30, 30, 30)

	b.BackgroundTransparency = 0.15

	b.Text = text

	b.TextColor3 =
		Color3.new(1, 1, 1)

	b.TextSize = 26

	b.Font =
		Enum.Font.GothamBold

	b.Parent =
		ArrowFrame

	Corner(b, 30)

	return b

end

local Up =
	CreateArrow(
		"Up",
		"↑",
		UDim2.fromOffset(66, 0)
	)

local Down =
	CreateArrow(
		"Down",
		"↓",
		UDim2.fromOffset(66, 66)
	)

local Left =
	CreateArrow(
		"Left",
		"←",
		UDim2.fromOffset(0, 66)
	)

local Right =
	CreateArrow(
		"Right",
		"→",
		UDim2.fromOffset(132, 66)
	)

--========================================================
-- MOVIMENTO
--========================================================

local Movement = {
	Up = false,
	Down = false,
	Left = false,
	Right = false
}

local function GetDirection()

	local camera =
		workspace.CurrentCamera

	if not camera then
		return Vector3.zero
	end

	local look =
		camera.CFrame.LookVector

	local right =
		camera.CFrame.RightVector

	local forward =
		Vector3.new(
			look.X,
			0,
			look.Z
		)

	local side =
		Vector3.new(
			right.X,
			0,
			right.Z
		)

	if forward.Magnitude > 0 then
		forward = forward.Unit
	end

	if side.Magnitude > 0 then
		side = side.Unit
	end

	local direction =
		Vector3.zero

	if Movement.Up then
		direction += forward
	end

	if Movement.Down then
		direction -= forward
	end

	if Movement.Right then
		direction += side
	end

	if Movement.Left then
		direction -= side
	end

	if direction.Magnitude > 0 then
		return direction.Unit
	end

	return Vector3.zero

end

local function Move()

	if not Humanoid then
		return
	end

	Humanoid:Move(
		GetDirection(),
		false
	)

end

local function ConnectArrow(
	button,
	direction
)

	button.InputBegan:Connect(function(input)

		if
			input.UserInputType ==
			Enum.UserInputType.Touch

			or

			input.UserInputType ==
			Enum.UserInputType.MouseButton1
		then

			Movement[direction] = true

		end

	end)

	button.InputEnded:Connect(function(input)

		if
			input.UserInputType ==
			Enum.UserInputType.Touch

			or

			input.UserInputType ==
			Enum.UserInputType.MouseButton1
		then

			Movement[direction] = false

		end

	end)

end

ConnectArrow(Up, "Up")
ConnectArrow(Down, "Down")
ConnectArrow(Left, "Left")
ConnectArrow(Right, "Right")

--========================================================
-- LOOP PRINCIPAL
--========================================================

RunService.RenderStepped:Connect(function()

	if
		Movement.Up
		or Movement.Down
		or Movement.Left
		or Movement.Right
	then

		Move()

	end

	if State.ShiftLock and Humanoid then

		Humanoid.AutoRotate = false

		if not UIS:IsMouseButtonPressed(
			Enum.UserInputType.MouseButton1
		) then

			UIS.MouseBehavior =
				Enum.MouseBehavior.LockCenter

		end

	end

end)

--========================================================
-- RESPONSIVIDADE
--========================================================

local function UpdateScale()

	local camera =
		workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport =
		camera.ViewportSize

	local scale =
		math.clamp(
			math.min(
				viewport.X / 1536,
				viewport.Y / 688
			),
			0.65,
			1.2
		)

	local uiScale =
		Panel:FindFirstChild("UIScale")

	if not uiScale then

		uiScale =
			Instance.new("UIScale")

		uiScale.Parent = Panel

	end

	uiScale.Scale = scale

end

workspace.CurrentCamera:GetPropertyChangedSignal(
	"ViewportSize"
):Connect(UpdateScale)

UpdateScale()

--========================================================
-- FIM
--========================================================
