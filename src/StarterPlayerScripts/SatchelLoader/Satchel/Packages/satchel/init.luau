local BACKPACK_TITLE_TEXT: string = "Back Pack"
local BACKPACK_TITLE_OFFSET: UDim2 = UDim2.new(0, 14, 0, 10) -- distanza dal bordo top-left
local BACKPACK_TITLE_SIZE: number = 50 -- <— qui decidi la grandezza
local BACKPACK_TITLE_COLOR: Color3 = Color3.new(1, 1, 1)

local PADDING_TOPANDLEFT = 40

local ATTRIBUTE_DISPLAY_LIST: { [string]: number } = {
	["Rarity"] = 2,
	["Level"] = 1,
	["Tier"] = 3,
}

local ATTRIBUTE_LABEL_OFFSET_X: { [number]: number } = {
	[1] = 0,
	[2] = 0,
	[3] = 0,
}

local SLOT_NUMBER_POSITION: UDim2 = UDim2.new(0, -40, 0, -30)
local SLOT_NUMBER_ANCHOR: Vector2 = Vector2.new(0, 0)
local SLOT_NUMBER_SIZE: UDim2 = UDim2.fromScale(0.8, 0.8)

local ATTRIBUTE_LABEL_WIDTH: { [number]: number } = {
	[1] = 50,
	[2] = 50,
	[3] = 50,
}

local ATTRIBUTE_LEVEL_POSITION: { [number]: UDim2 } = {
	[1] = UDim2.new(0.5, 0, 1, -3),
	[2] = UDim2.new(0.5, 0, 0.4, 0),
	[3] = UDim2.new(0.5, 0, 0.1, 0),
}

local ATTRIBUTE_TEXTURE_POSITION: UDim2 = UDim2.new(0.5, 0, 1, -3)

local ATTRIBUTE_TEXT_SIZE: { [number]: number } = {
	[1] = 13,
	[2] = 20,
	[3] = 10,
}

local ATTRIBUTE_TEXT_COLOR: { [number]: Color3 } = {
	[1] = Color3.new(1, 1, 1),
	[2] = Color3.new(1, 0.968627, 0),
	[3] = Color3.new(0.101961, 1, 0),
}

local ATTRIBUTE_BG_COLOR: { [number]: Color3 } = {
	[1] = Color3.new(0, 0, 0),
	[2] = Color3.new(0, 0, 0),
	[3] = Color3.new(0, 0, 0),
}

local ATTRIBUTE_BG_TRANSPARENCY: { [number]: number } = {
	[1] = 1,
	[2] = 1,
	[3] = 1,
}

local ATTRIBUTE_FONT_WEIGHT: { [number]: Enum.FontWeight } = {
	[1] = Enum.FontWeight.Medium,
	[2] = Enum.FontWeight.Medium,
	[3] = Enum.FontWeight.Bold,
}

local ATTRIBUTE_LABEL_CORNER_RADIUS: UDim = UDim.new(0, 3)
local ATTRIBUTE_LABEL_PADDING_X: number = 5
local ATTRIBUTE_LABEL_HEIGHT_EXTRA: number = 6

local ContextActionService = game:GetService("ContextActionService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PlayerGui: Instance = Players.LocalPlayer:WaitForChild("PlayerGui")
local BackpackScript = {}

BackpackScript.OpenClose = nil :: any
BackpackScript.IsOpen = false :: boolean
BackpackScript.StateChanged = Instance.new("BindableEvent") :: BindableEvent

BackpackScript.ModuleName = "Backpack" :: string
BackpackScript.KeepVRTopbarOpen = true :: boolean
BackpackScript.VRIsExclusive = true :: boolean
BackpackScript.VRClosesNonExclusive = true :: boolean

BackpackScript.BackpackEmpty = Instance.new("BindableEvent") :: BindableEvent
BackpackScript.BackpackEmpty.Name = "BackpackEmpty"

BackpackScript.BackpackItemAdded = Instance.new("BindableEvent") :: BindableEvent
BackpackScript.BackpackItemAdded.Name = "BackpackAdded"

BackpackScript.BackpackItemRemoved = Instance.new("BindableEvent") :: BindableEvent
BackpackScript.BackpackItemRemoved.Name = "BackpackRemoved"

local targetScript: ModuleScript = script

require(script.Attribution)

local PREFERRED_TRANSPARENCY: number = GuiService.PreferredTransparency or 1

local LEGACY_EDGE_ENABLED: boolean = not targetScript:GetAttribute("OutlineEquipBorder") or false
local LEGACY_PADDING_ENABLED: boolean = targetScript:GetAttribute("InsetIconPadding")

local BACKGROUND_TRANSPARENCY_DEFAULT: number = targetScript:GetAttribute("BackgroundTransparency") or 0.3
local BACKGROUND_TRANSPARENCY: number = BACKGROUND_TRANSPARENCY_DEFAULT * PREFERRED_TRANSPARENCY
local BACKGROUND_CORNER_RADIUS: UDim = UDim.new(0, 8)
local BACKGROUND_COLOR: Color3 = targetScript:GetAttribute("BackgroundColor3")
	or Color3.new(25 / 255, 27 / 255, 29 / 255)

local SLOT_EQUIP_COLOR: Color3 = targetScript:GetAttribute("EquipBorderColor3") or Color3.new(0 / 255, 162 / 255, 1)
local SLOT_EQUIP_BACKGROUND_COLOR3: Color3 = targetScript:GetAttribute("EquipBackgroundColor3") or Color3.new(1, 1, 1)
local SLOT_LOCKED_TRANSPARENCY_DEFAULT: number = 1
local SLOT_LOCKED_TRANSPARENCY: number = SLOT_LOCKED_TRANSPARENCY_DEFAULT * PREFERRED_TRANSPARENCY
local SLOT_EQUIP_THICKNESS: number = targetScript:GetAttribute("EquipBorderSizePixel") or 5
local SLOT_CORNER_RADIUS: UDim = targetScript:GetAttribute("CornerRadius") or UDim.new(0, 8)
local SLOT_BORDER_COLOR: Color3 = Color3.new(1, 1, 1)

local TOOLTIP_CORNER_RADIUS: UDim = SLOT_CORNER_RADIUS - UDim.new(0, 5) or UDim.new(0, 3)
local TOOLTIP_BACKGROUND_COLOR: Color3 = targetScript:GetAttribute("BackgroundColor3")
	or Color3.new(25 / 255, 27 / 255, 29 / 255)
local TOOLTIP_PADDING: number = 4
local TOOLTIP_HEIGHT: number = 16
local TOOLTIP_OFFSET: number = -5

local ARROW_IMAGE_OPEN: string = "rbxasset://textures/ui/TopBar/inventoryOn.png"
local ARROW_IMAGE_CLOSE: string = "rbxasset://textures/ui/TopBar/inventoryOff.png"

local HOTBAR_SLOTS_FULL: number = 10
local HOTBAR_SLOTS_VR: number = 6
local HOTBAR_SLOTS_MINI: number = 6
local HOTBAR_SLOTS_WIDTH_CUTOFF: number = 1024

local INVENTORY_ROWS_FULL: number = 4
local INVENTORY_ROWS_VR: number = 3
local INVENTORY_ROWS_MINI: number = 2
local INVENTORY_HEADER_SIZE: number = 40
local INVENTORY_ARROWS_BUFFER_VR: number = 40

local TEXT_COLOR: Color3 = targetScript:GetAttribute("TextColor3") or Color3.new(1, 1, 1)
local TEXT_STROKE_TRANSPARENCY: number = targetScript:GetAttribute("TextStrokeTransparency") or 0.5
local TEXT_STROKE_COLOR: Color3 = targetScript:GetAttribute("TextStrokeColor3") or Color3.new(0, 0, 0)

local SEARCH_IMAGE_X: string = "rbxassetid://115774947923834"

local HeaderTotalHeight: number = INVENTORY_HEADER_SIZE -- valore calcolato dinamicamente
local SEARCH_BACKGROUND_COLOR: Color3 = Color3.new(25 / 255, 27 / 255, 29 / 255)
local SEARCH_BACKGROUND_TRANSPARENCY_DEFAULT: number = 0.2
local SEARCH_BACKGROUND_TRANSPARENCY: number = SEARCH_BACKGROUND_TRANSPARENCY_DEFAULT * PREFERRED_TRANSPARENCY
local SEARCH_BORDER_COLOR: Color3 = Color3.new(0, 0, 0)
local SEARCH_BORDER_TRANSPARENCY: number = 0.5
local SEARCH_BORDER_THICKNESS: number = 3
local SEARCH_TEXT_PLACEHOLDER: string = "Search..."
local SEARCH_TEXT_OFFSET: number = 8
local SEARCH_TEXT: string = ""
local SEARCH_CORNER_RADIUS: UDim = UDim.new(0, 10)

local SEARCH_TOP_OFFSET: number = 10
local SEARCH_RIGHT_OFFSET: number = 10
local SEARCH_WIDTH_PIXELS: number = 400
local SEARCH_HEIGHT_PIXELS: number = 60
local SEARCH_INNER_PADDING: number = 6

local TEXTSIZE = 40

local FONT_FAMILY: Font = targetScript:GetAttribute("FontFace")
	or Font.new("rbxasset://fonts/families/BuilderSans.json")
local FONT_SIZE: number = targetScript:GetAttribute("TextSize") or 16
local DROP_HOTKEY_VALUE: number = Enum.KeyCode.Backspace.Value
local ZERO_KEY_VALUE: number = Enum.KeyCode.Zero.Value
local DOUBLE_CLICK_TIME: number = 0.5
local ICON_BUFFER_PIXELS: number = 12
local ICON_SIZE_PIXELS: number = 65
local TEXTTHICKNESS = 3
local BACKGROUNDTICHNESS = 4

local USEHOVER: boolean = true
local HoverMult: number = 1.12
local ClickMult: number = 1.18
local HoverTweenTime: number = 0.1
local MOUSE_INPUT_TYPES: { [Enum.UserInputType]: boolean } = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseButton2] = true,
	[Enum.UserInputType.MouseButton3] = true,
	[Enum.UserInputType.MouseMovement] = true,
	[Enum.UserInputType.MouseWheel] = true,
}

local GAMEPAD_INPUT_TYPES: { [Enum.UserInputType]: boolean } = {
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true,
	[Enum.UserInputType.Gamepad4] = true,
	[Enum.UserInputType.Gamepad5] = true,
	[Enum.UserInputType.Gamepad6] = true,
	[Enum.UserInputType.Gamepad7] = true,
	[Enum.UserInputType.Gamepad8] = true,
}

local BackpackEnabled: boolean = true

local Icon: any = require(script.Parent.topbarplus)

local inventoryIcon: any = Icon.new()
	:setName("Inventory")
	:setImage(ARROW_IMAGE_OPEN, "Selected")
	:setImage(ARROW_IMAGE_CLOSE, "Deselected")
	:setImageScale(1)
	:setCaption("Inventory")
	:bindToggleKey(Enum.KeyCode.Backquote)
	:autoDeselect(false)
	:setOrder(-1)

inventoryIcon.toggled:Connect(function(): ()
	if not GuiService.MenuIsOpen then
		BackpackScript.OpenClose()
	end
end)
local BackpackGui: ScreenGui = Instance.new("ScreenGui")
BackpackGui.DisplayOrder = 120
BackpackGui.IgnoreGuiInset = true
BackpackGui.ResetOnSpawn = false
BackpackGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
BackpackGui.Name = "BackpackGui"
BackpackGui.Parent = PlayerGui

local IsTenFootInterface: boolean = GuiService:IsTenFootInterface()
local Uis = game:GetService("UserInputService")
local IsOnMobile = Uis.TouchEnabled

if IsOnMobile then
	ICON_BUFFER_PIXELS = 12
	ICON_SIZE_PIXELS = 70
	BACKPACK_TITLE_SIZE = 30
	PADDING_TOP = 13
	TEXTSIZE = 16
	SEARCH_WIDTH_PIXELS = 200
	SEARCH_HEIGHT_PIXELS = 30
	TEXTTHICKNESS = 2.4
	BACKGROUNDTICHNESS = 3
else
	ICON_BUFFER_PIXELS = 20
	ICON_SIZE_PIXELS = 90
	BACKPACK_TITLE_SIZE = 65
	TEXTTHICKNESS = 3
	BACKGROUNDTICHNESS = 4
end

if IsTenFootInterface then
	ICON_SIZE_PIXELS = 100
	FONT_SIZE = 24
end

local GamepadActionsBound: boolean = false

local IS_PHONE: boolean = UserInputService.TouchEnabled
	and workspace.CurrentCamera.ViewportSize.X < HOTBAR_SLOTS_WIDTH_CUTOFF

local Player: Player = Players.LocalPlayer

local MainFrame: Frame = nil
local HotbarFrame: Frame = nil
local InventoryFrame: Frame = nil
local VRInventorySelector: any = nil
local ScrollClipGroup: CanvasGroup = nil
local ScrollingFrame: ScrollingFrame = nil
local UIGridFrame: Frame = nil
local UIGridLayout: UIGridLayout = nil
local ScrollUpInventoryButton: any = nil
local BackpackTitle: TextLabel = nil

local ScrollDownInventoryButton: any = nil
local changeToolFunc: any = nil

local Character: Model = Player.Character or Player.CharacterAdded:Wait()
local Humanoid: any = Character:WaitForChild("Humanoid")
local Backpack: Instance = Player:WaitForChild("Backpack")

local Slots = {}
local LowestEmptySlot: any = nil
local SlotsByTool = {}
local HotkeyFns = {}
local Dragging: { boolean } = {}
local FullHotbarSlots: number = 0
local ActiveHopper = nil
local StarterToolFound: boolean = false
local WholeThingEnabled: boolean = false
local TextBoxFocused: boolean = false
local ViewingSearchResults: boolean = false

local CharConns: { RBXScriptConnection } = {}
local GamepadEnabled: boolean = false

local IsVR: boolean = VRService.VREnabled
local NumberOfHotbarSlots: number = IsVR and HOTBAR_SLOTS_VR or (IS_PHONE and HOTBAR_SLOTS_MINI or HOTBAR_SLOTS_FULL)
local NumberOfInventoryRows: number = IsVR and INVENTORY_ROWS_VR
	or (IS_PHONE and INVENTORY_ROWS_MINI or INVENTORY_ROWS_FULL)
local BackpackPanel = nil
local lastEquippedSlot: any = nil

local function EvaluateBackpackPanelVisibility(enabled: boolean): boolean
	return enabled and inventoryIcon.enabled and BackpackEnabled and VRService.VREnabled
end

local function ShowVRBackpackPopup(): ()
	if BackpackPanel and EvaluateBackpackPanelVisibility(true) then
		BackpackPanel:ForceShowForSeconds(2)
	end
end

local CollectionService = game:GetService("CollectionService")

local function StyleTextLabel(label: TextLabel, weight: Enum.FontWeight?, strokeThickness: number?): TextLabel
	label.FontFace =
		Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
	label.TextStrokeTransparency = TEXT_STROKE_TRANSPARENCY
	label.TextStrokeColor3 = TEXT_STROKE_COLOR

	local stroke: UIStroke? = label:FindFirstChildOfClass("UIStroke")
	if not stroke then
		stroke = Instance.new("UIStroke")
		stroke.Parent = label
	end
	stroke.Thickness = TEXTTHICKNESS
	stroke:SetAttribute("FROMINVTextLabel", true)
	CollectionService:AddTag(stroke, "ScaleUIStroke")

	return label
end

local function FindLowestEmpty(): number?
	for i: number = 1, NumberOfHotbarSlots do
		local slot: any = Slots[i]
		if not slot.Tool then
			return slot
		end
	end
	return nil
end

local function isInventoryEmpty(): boolean
	for i: number = NumberOfHotbarSlots + 1, #Slots do
		local slot: any = Slots[i]
		if slot and slot.Tool then
			return false
		end
	end
	return true
end

BackpackScript.IsInventoryEmpty = isInventoryEmpty

local function UseGazeSelection(): boolean
	return false
end

local function AdjustHotbarFrames(): ()
	local inventoryOpen: boolean = InventoryFrame.Visible
	local visualTotal: number = inventoryOpen and NumberOfHotbarSlots or FullHotbarSlots
	local visualIndex: number = 0

	for i: number = 1, NumberOfHotbarSlots do
		local slot: any = Slots[i]
		if slot.Tool or inventoryOpen then
			visualIndex = visualIndex + 1
			slot:Readjust(visualIndex, visualTotal)
			slot.Frame.Visible = true
		else
			slot.Frame.Visible = false
		end
	end
end

local function UpdateScrollingFrameCanvasSize(): ()
	if UIGridLayout then
		ScrollingFrame.CanvasSize = UDim2.fromOffset(0, UIGridLayout.AbsoluteContentSize.Y + PADDING_TOPANDLEFT + 20)
	end
end
local function AdjustInventoryFrames(): ()
	for i: number = NumberOfHotbarSlots + 1, #Slots do
		local slot: any = Slots[i]
		slot.Frame.LayoutOrder = slot.Index
		slot.Frame.Visible = (slot.Tool ~= nil)
	end
	UpdateScrollingFrameCanvasSize()
end

local function UpdateBackpackLayout(): ()
	HotbarFrame.Size = UDim2.new(
		0,
		ICON_BUFFER_PIXELS + (NumberOfHotbarSlots * (ICON_SIZE_PIXELS + ICON_BUFFER_PIXELS)),
		0,
		ICON_BUFFER_PIXELS + ICON_SIZE_PIXELS + ICON_BUFFER_PIXELS
	)
	HotbarFrame.Position = UDim2.new(0.5, -HotbarFrame.Size.X.Offset / 2, 1, -HotbarFrame.Size.Y.Offset)
	InventoryFrame.Size = UDim2.new(
		0,
		HotbarFrame.Size.X.Offset,
		0,
		(HotbarFrame.Size.Y.Offset * NumberOfInventoryRows)
			+ INVENTORY_HEADER_SIZE
			+ (IsVR and 2 * INVENTORY_ARROWS_BUFFER_VR or 0)
	)
	InventoryFrame.Position = UDim2.new(
		0.5,
		-InventoryFrame.Size.X.Offset / 2,
		1,
		HotbarFrame.Position.Y.Offset - InventoryFrame.Size.Y.Offset
	)

	-- Calcola l'altezza reale occupata da titolo e barra di ricerca
	local titleBottom: number = BACKPACK_TITLE_OFFSET.Y.Offset
		+ (BackpackTitle and BackpackTitle.AbsoluteSize.Y or BACKPACK_TITLE_SIZE * 1.3)

	local searchBottom: number = SEARCH_TOP_OFFSET + SEARCH_HEIGHT_PIXELS

	HeaderTotalHeight = math.max(titleBottom, searchBottom, INVENTORY_HEADER_SIZE) + 10 -- +10 di margine di sicurezza

	ScrollClipGroup.Size = UDim2.new(1, 0, 1, -HeaderTotalHeight - (IsVR and 2 * INVENTORY_ARROWS_BUFFER_VR or 0))
	ScrollClipGroup.Position = UDim2.fromOffset(0, HeaderTotalHeight + (IsVR and INVENTORY_ARROWS_BUFFER_VR or 0))
	AdjustHotbarFrames()
	AdjustInventoryFrames()
end

local function Clamp(low: number, high: number, num: number): number
	return math.min(high, math.max(low, num))
end

local function CheckBounds(guiObject: GuiObject, x: number, y: number): boolean
	local pos: Vector2 = guiObject.AbsolutePosition
	local size: Vector2 = guiObject.AbsoluteSize
	return (x > pos.X and x <= pos.X + size.X and y > pos.Y and y <= pos.Y + size.Y)
end

local function GetOffset(guiObject: GuiObject, point: Vector2): number
	local centerPoint: Vector2 = guiObject.AbsolutePosition + (guiObject.AbsoluteSize / 2)
	return (centerPoint - point).Magnitude
end

local function DisableActiveHopper(): ()
	ActiveHopper:ToggleSelect()
	SlotsByTool[ActiveHopper]:UpdateEquipView()
	ActiveHopper = nil :: any
end

local function UnequipAllTools(): ()
	if Humanoid then
		Humanoid:UnequipTools()
		if ActiveHopper then
			DisableActiveHopper()
		end
	end
end

local function EquipNewTool(tool: Tool): ()
	UnequipAllTools()
	Humanoid:EquipTool(tool)
end

local function IsEquipped(tool: Tool): boolean
	return tool and tool.Parent == Character
end

local function CreateSlotFrame(slotObject: any, index: number): (TextButton, ImageLabel, TextLabel, Frame, UIStroke)
	local SlotFrame = Instance.new("TextButton")
	SlotFrame.Name = tostring(index)
	game:GetService("CollectionService"):AddTag(SlotFrame, "PopUp")
	SlotFrame:SetAttribute("FromInv", index)
	SlotFrame.BackgroundColor3 = BACKGROUND_COLOR
	SlotFrame.BorderColor3 = SLOT_BORDER_COLOR
	SlotFrame.BackgroundTransparency = 1
	SlotFrame.Text = ""
	SlotFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	SlotFrame.BorderSizePixel = 0
	SlotFrame.Size = UDim2.fromOffset(ICON_SIZE_PIXELS, ICON_SIZE_PIXELS)
	SlotFrame.Active = true
	SlotFrame.Draggable = false

	local BackGround = Instance.new("Frame")
	BackGround.BackgroundColor3 = BACKGROUND_COLOR
	BackGround.BackgroundTransparency = 0.6
	BackGround.Rotation = 25
	BackGround.Position = UDim2.fromScale(0.5, 0.5)
	BackGround.Size = UDim2.fromScale(0.9, 0.9)
	BackGround.AnchorPoint = Vector2.new(0.5, 0.5)
	BackGround.Name = "BackGround"
	BackGround.Parent = SlotFrame

	local Stroke = Instance.new("UIStroke")
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.StrokeSizingMode = Enum.StrokeSizingMode.FixedSize
	Stroke.Thickness = BACKGROUNDTICHNESS
	Stroke.Color = Color3.new(0, 0, 0)
	Stroke.Transparency = 0.5
	Stroke.Parent = BackGround

	SlotFrame.MouseButton1Click:Connect(function(): ()
		changeSlot(slotObject)
	end)

	if USEHOVER then
		local HoverScale = Instance.new("UIScale")
		HoverScale.Name = "HoverScale"
		HoverScale.Scale = 1
		HoverScale.Parent = BackGround

		local isHovering = false

		local function TweenSlotScale(targetScale: number): ()
			TweenService:Create(
				HoverScale,
				TweenInfo.new(HoverTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Scale = targetScale }
			):Play()
		end

		SlotFrame.MouseEnter:Connect(function(): ()
			isHovering = true
			TweenSlotScale(HoverMult)
		end)

		SlotFrame.MouseLeave:Connect(function(): ()
			isHovering = false
			TweenSlotScale(1)
		end)

		SlotFrame.MouseButton1Down:Connect(function(): ()
			TweenSlotScale(ClickMult)
		end)

		SlotFrame.MouseButton1Up:Connect(function(): ()
			TweenSlotScale(isHovering and HoverMult or 1)
		end)
	end

	local slotCorner = Instance.new("UICorner")
	slotCorner.Name = "Corner"
	slotCorner.CornerRadius = SLOT_CORNER_RADIUS
	slotCorner.Parent = BackGround

	do
		local selectionObjectClipper = Instance.new("Frame")
		selectionObjectClipper.Name = "SelectionObjectClipper"
		selectionObjectClipper.BackgroundTransparency = 1
		selectionObjectClipper.Visible = false
		selectionObjectClipper.Parent = SlotFrame

		local SelectionObj = Instance.new("ImageLabel")
		SelectionObj.Name = "Selector"
		SelectionObj.BackgroundTransparency = 1
		SelectionObj.Size = UDim2.fromScale(1, 1)
		SelectionObj.Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png"
		SelectionObj.ScaleType = Enum.ScaleType.Slice
		SelectionObj.SliceCenter = Rect.new(12, 12, 52, 52)
		SelectionObj.Parent = selectionObjectClipper
	end

	local ToolIcon = Instance.new("ImageLabel")
	ToolIcon.BackgroundTransparency = 1
	ToolIcon.Name = "Icon"
	ToolIcon.Position = UDim2.fromScale(0.5, 0.5)
	ToolIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	if LEGACY_PADDING_ENABLED == true then
		ToolIcon.Size = UDim2.new(1, 0, 1, 0)
	else
		ToolIcon.Size = UDim2.fromScale(1, 1)
	end
	ToolIcon.Parent = SlotFrame

	local ToolIconCorner = Instance.new("UICorner")
	ToolIconCorner.Name = "Corner"
	if LEGACY_PADDING_ENABLED == true then
		ToolIconCorner.CornerRadius = SLOT_CORNER_RADIUS - UDim.new(0, SLOT_EQUIP_THICKNESS)
	else
		ToolIconCorner.CornerRadius = SLOT_CORNER_RADIUS
	end
	ToolIconCorner.Parent = ToolIcon

	local ToolName = Instance.new("TextLabel")
	ToolName.BackgroundTransparency = 1
	ToolName.Name = "ToolName"
	ToolName.Text = ""
	ToolName.TextColor3 = TEXT_COLOR
	ToolName.TextStrokeTransparency = TEXT_STROKE_TRANSPARENCY
	ToolName.TextStrokeColor3 = TEXT_STROKE_COLOR
	ToolName.FontFace = Font.new(FONT_FAMILY.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	ToolName.TextSize = FONT_SIZE
	ToolName.Size = UDim2.new(1, -SLOT_EQUIP_THICKNESS * 2, 1, -SLOT_EQUIP_THICKNESS * 2)
	ToolName.Position = UDim2.fromScale(0.5, 0.5)
	ToolName.AnchorPoint = Vector2.new(0.5, 0.5)
	ToolName.TextWrapped = true
	ToolName.TextTruncate = Enum.TextTruncate.AtEnd
	ToolName.Parent = SlotFrame
	StyleTextLabel(ToolName)

	SlotFrame.LayoutOrder = index

	return SlotFrame, ToolIcon, ToolName, BackGround, Stroke
end

local function MakeSlot(parent: Instance, initIndex: number?): GuiObject
	local index: number = initIndex or (#Slots + 1)

	local slot: any = {}
	slot.Tool = nil :: any
	slot.Index = index :: number
	slot.Frame = nil :: any

	local SlotFrame: any = nil
	local FakeSlotFrame: Frame = nil
	local ToolIcon: ImageLabel = nil
	local ToolName: TextLabel = nil
	local ToolChangeConn: any = nil
	local HighlightFrame: any = nil
	local SelectionObj: ImageLabel = nil
	local BackGround: Frame = nil
	local EquipStroke: UIStroke = nil

	local ToolTip: TextLabel = nil
	local SlotNumber: TextLabel = nil
	local ViewportFrame: any = nil
	local ViewportCamera: any = nil

	local function buildViewport(tool: any): ()
		if ViewportFrame then
			ViewportFrame:Destroy()
			ViewportFrame = nil
			ViewportCamera = nil
			ToolIcon.Visible = true
			ToolName.Visible = true
		end
		if not tool then
			return
		end

		local offsetCF = tool:GetAttribute("Offset")
		if not (offsetCF and typeof(offsetCF) == "CFrame") then
			return
		end

		local vmName = tool:GetAttribute("ViewModelName")
		local vmFolder = ReplicatedStorage:FindFirstChild("Assets")
			and ReplicatedStorage.Assets:FindFirstChild("ViewModels")
		local vmTemplate = vmFolder and vmName and vmFolder:FindFirstChild(tostring(vmName))

		if not vmTemplate then
			warn("[Backpack] ViewModel non trovato: " .. tostring(vmName))
			return
		end

		ToolIcon.Visible = false
		ToolName.Visible = false

		ViewportFrame = Instance.new("ViewportFrame")
		ViewportFrame.Name = "VMViewport"
		ViewportFrame.BackgroundTransparency = 1
		ViewportFrame.Size = UDim2.fromScale(1, 1)
		ViewportFrame.Position = UDim2.fromScale(0, 0)
		ViewportFrame.ZIndex = 1
		ViewportFrame.LightColor = Color3.new(1, 1, 1)
		ViewportFrame.Ambient = Color3.new(1, 1, 1)
		ViewportFrame.Parent = SlotFrame
		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 8)
		Corner.Parent = ViewportFrame
		ViewportCamera = Instance.new("Camera")
		ViewportCamera.CFrame = offsetCF
		ViewportCamera.Parent = ViewportFrame
		ViewportFrame.CurrentCamera = ViewportCamera

		local vmClone = vmTemplate:Clone()
		if vmClone:IsA("Model") and vmClone.PrimaryPart then
			vmClone:PivotTo(CFrame.new(0, 0, 0))
		end
		vmClone.Parent = ViewportFrame
	end

	local AttributeLabels: { [string]: TextLabel } = {}
	local AttrChangedConns: { RBXScriptConnection } = {}

	local function clearAttributeLabels(): ()
		for _, label in pairs(AttributeLabels) do
			label:Destroy()
		end
		AttributeLabels = {}
		for _, conn in ipairs(AttrChangedConns) do
			conn:Disconnect()
		end
		AttrChangedConns = {}
	end

	local function buildAttributeLabels(tool: any): ()
		clearAttributeLabels()
		if not tool then
			return
		end

		local hasTexture: boolean = (tool.TextureId ~= "")

		for attrName: string, level: number in pairs(ATTRIBUTE_DISPLAY_LIST) do
			local value: any = tool:GetAttribute(attrName)
			if value ~= nil then
				local tSize: number = ATTRIBUTE_TEXT_SIZE[level] or 9
				local lHeight: number = tSize + ATTRIBUTE_LABEL_HEIGHT_EXTRA

				local label: TextLabel = Instance.new("TextLabel")
				label.Name = "AttrLabel_" .. attrName
				label.BackgroundColor3 = ATTRIBUTE_BG_COLOR[level] or Color3.new(0, 0, 0)
				label.BackgroundTransparency = ATTRIBUTE_BG_TRANSPARENCY[level] or 0.4
				label.TextColor3 = ATTRIBUTE_TEXT_COLOR[level] or Color3.new(1, 1, 1)
				label.TextStrokeTransparency = TEXT_STROKE_TRANSPARENCY
				label.TextStrokeColor3 = TEXT_STROKE_COLOR
				label.TextScaled = true
				label.TextWrapped = true
				label.ZIndex = 2

				label.FontFace = Font.new(
					FONT_FAMILY.Family,
					ATTRIBUTE_FONT_WEIGHT[level] or Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				)
				label.TextSize = tSize
				label.Text = tostring(value)
				label.ZIndex = 3
				label.BorderSizePixel = 0
				StyleTextLabel(label)
				local fixedW: number = ATTRIBUTE_LABEL_WIDTH[level] or 0
				local offsetX: number = ATTRIBUTE_LABEL_OFFSET_X[level] or 0

				if fixedW > 0 then
					label.AutomaticSize = Enum.AutomaticSize.None
					label.Size = UDim2.fromOffset(fixedW, lHeight)
				else
					label.AutomaticSize = Enum.AutomaticSize.X
					label.Size = UDim2.fromOffset(0, lHeight)
				end

				label.AnchorPoint = Vector2.new(0.5, 1)

				local basePos: UDim2 = ATTRIBUTE_LEVEL_POSITION[level] or UDim2.new(0.5, 0, 1, -3)

				label.Position =
					UDim2.new(basePos.X.Scale, basePos.X.Offset + offsetX, basePos.Y.Scale, basePos.Y.Offset)
				local attrCorner: UICorner = Instance.new("UICorner")
				attrCorner.CornerRadius = ATTRIBUTE_LABEL_CORNER_RADIUS
				attrCorner.Parent = label

				local attrPadding: UIPadding = Instance.new("UIPadding")
				attrPadding.PaddingLeft = UDim.new(0, ATTRIBUTE_LABEL_PADDING_X)
				attrPadding.PaddingRight = UDim.new(0, ATTRIBUTE_LABEL_PADDING_X)
				attrPadding.Parent = label

				label.Parent = SlotFrame
				AttributeLabels[attrName] = label
				StyleTextLabel(label) -- <— AGGIUNGI QUESTO (spessore più sottile, 2, dato che sono etichette piccole)hintText.Text = hintTextString

				local conn: RBXScriptConnection = tool:GetAttributeChangedSignal(attrName):Connect(function(): ()
					local newVal: any = tool:GetAttribute(attrName)
					if newVal ~= nil then
						label.Text = tostring(newVal)
					else
						label:Destroy()
						AttributeLabels[attrName] = nil
					end
				end)
				table.insert(AttrChangedConns, conn)
			end
		end
	end

	local function UpdateSlotFading(): ()
		SlotFrame.SelectionImageObject = nil

		SlotFrame.BackgroundTransparency = SLOT_LOCKED_TRANSPARENCY
	end

	function slot:Readjust(visualIndex: number, visualTotal: number): ...any
		local centered: number = HotbarFrame.Size.X.Offset / 2
		local sizePlus: number = ICON_BUFFER_PIXELS + ICON_SIZE_PIXELS
		local midpointish: number = (visualTotal / 2) + 0.5
		local factor: number = visualIndex - midpointish
		SlotFrame.Position = UDim2.fromOffset(
			centered - (ICON_SIZE_PIXELS / 2) + (sizePlus * factor) + (ICON_SIZE_PIXELS / 2), -- +metà size X
			ICON_BUFFER_PIXELS + (ICON_SIZE_PIXELS / 2) -- +metà size Y
		)
	end

	function slot:Fill(tool: Tool): ...any
		if not tool then
			return self:Clear()
		end

		if self.Tool and self.Tool ~= tool then
			if ToolChangeConn then
				ToolChangeConn:Disconnect()
				ToolChangeConn = nil
			end
			clearAttributeLabels()
			buildViewport(nil)
		end

		self.Tool = tool :: Tool

		if self.Index > NumberOfHotbarSlots then
			local cs = game:GetService("CollectionService")
			if cs:HasTag(SlotFrame, "PopUp") then
				cs:RemoveTag(SlotFrame, "PopUp")
			end
			cs:AddTag(SlotFrame, "PopUp")
		end

		local function assignToolData(): ()
			local icon: string = tool.TextureId
			ToolIcon.Image = icon

			if icon ~= "" then
				ToolName.Visible = false
			else
				ToolName.Visible = true
			end

			ToolName.Text = tool.Name

			if ToolTip and tool:IsA("Tool") then
				ToolTip.Text = tool.ToolTip
				ToolTip.Size = UDim2.fromOffset(0, TOOLTIP_HEIGHT)
				ToolTip.Position = UDim2.new(0.5, 0, 0, TOOLTIP_OFFSET)
			end
		end

		assignToolData()
		buildViewport(tool)
		buildAttributeLabels(tool)

		if ToolChangeConn then
			ToolChangeConn:Disconnect()
			ToolChangeConn = nil
		end

		ToolChangeConn = tool.Changed:Connect(function(property: string): ()
			if property == "TextureId" or property == "Name" or property == "ToolTip" then
				assignToolData()
				if property == "TextureId" then
					buildAttributeLabels(tool)
				end
			end

			if property == "Offset" or property == "ViewModelName" then
				buildViewport(tool)
			end
		end)

		local hotbarSlot: boolean = (self.Index <= NumberOfHotbarSlots)
		local inventoryOpen: boolean = InventoryFrame.Visible

		if (not hotbarSlot or inventoryOpen) and not UserInputService.VREnabled then
			SlotFrame.Draggable = true
		end

		self:UpdateEquipView()

		if hotbarSlot then
			FullHotbarSlots = FullHotbarSlots + 1

			if WholeThingEnabled and FullHotbarSlots >= 1 and not GamepadActionsBound then
				GamepadActionsBound = true
				ContextActionService:BindAction(
					"BackpackHotbarEquip",
					changeToolFunc,
					false,
					Enum.KeyCode.ButtonL1,
					Enum.KeyCode.ButtonR1
				)
			end
		end

		SlotsByTool[tool] = self
		LowestEmptySlot = FindLowestEmpty()
	end

	function slot:Clear(): ...any
		if not self.Tool then
			return
		end

		if ToolChangeConn then
			ToolChangeConn:Disconnect()
			ToolChangeConn = nil
		end

		clearAttributeLabels()
		buildViewport(nil)
		ToolIcon.Visible = true
		ToolName.Visible = false

		ToolIcon.Image = ""
		ToolName.Text = ""
		if ToolTip then
			ToolTip.Text = ""
			ToolTip.Visible = false
		end
		SlotFrame.Draggable = false

		self:UpdateEquipView(true)

		if self.Index <= NumberOfHotbarSlots then
			FullHotbarSlots = FullHotbarSlots - 1
			if FullHotbarSlots < 1 then
				GamepadActionsBound = false
				ContextActionService:UnbindAction("BackpackHotbarEquip")
			end
		end

		SlotsByTool[self.Tool] = nil
		self.Tool = nil
		LowestEmptySlot = FindLowestEmpty()
	end

	function slot:UpdateEquipView(unequippedOverride: boolean?): ...any
		local override = unequippedOverride or false

		-- Cerchiamo il bordo ORIGINALE dello slot (usiamo FindFirstChildOfClass per sicurezza)
		local NativeStroke = SlotFrame:FindFirstChildOfClass("UIStroke")

		if not override and IsEquipped(self.Tool) then
			lastEquippedSlot = slot

			if LEGACY_EDGE_ENABLED == false then
				if NativeStroke and NativeStroke ~= HighlightFrame then
					NativeStroke.Enabled = false
				end
			end

			if BackGround then
				BackGround.BackgroundColor3 = SLOT_EQUIP_BACKGROUND_COLOR3
			end
			if EquipStroke then
				EquipStroke.Color = Color3.new(1, 1, 1)
			end
		else
			-- Riaccendiamo semplicemente il bordo originale, che è rimasto al suo posto sicuro
			if NativeStroke then
				NativeStroke.Enabled = true
			end

			if BackGround then
				BackGround.BackgroundColor3 = BACKGROUND_COLOR
			end
			if EquipStroke then
				EquipStroke.Color = Color3.new(0, 0, 0)
			end
		end

		UpdateSlotFading()
	end
	function slot:IsEquipped(): boolean
		return IsEquipped(self.Tool)
	end

	function slot:Delete(): ...any
		SlotFrame:Destroy()
		table.remove(Slots, self.Index)
		local newSize: number = #Slots

		for slotIndex: number = self.Index :: number, newSize :: number do
			Slots[slotIndex]:SlideBack()
		end

		UpdateScrollingFrameCanvasSize()
	end

	function slot:Swap(targetSlot: any): ...any
		local myTool: any = self.Tool
		local otherTool: any = targetSlot.Tool

		if ToolChangeConn then
			ToolChangeConn:Disconnect()
			ToolChangeConn = nil
		end

		self:Clear()
		targetSlot:Clear()

		if otherTool then
			self:Fill(otherTool)
		end
		if myTool then
			targetSlot:Fill(myTool)
		end
	end

	function slot:SlideBack(): ...any
		self.Index = self.Index - 1
		SlotFrame.Name = self.Index
		SlotFrame.LayoutOrder = self.Index
	end

	function slot:TurnNumber(on: boolean): ...any
		if SlotNumber then
			SlotNumber.Visible = on
		end
	end

	function slot:SetClickability(on: boolean): ...any
		if self.Tool then
			if UserInputService.VREnabled then
				SlotFrame.Draggable = false
			else
				SlotFrame.Draggable = not on
			end
			UpdateSlotFading()
		end
	end

	function slot:CheckTerms(terms: any): number
		local hits: number = 0
		local function checkEm(str: string, term: any): ()
			local _, n: number = str:lower():gsub(term, "")
			hits = hits + n
		end
		local tool: Tool = self.Tool
		if tool then
			for term: any in pairs(terms) do
				checkEm(ToolName.Text, term)
				if tool:IsA("Tool") then
					local toolTipText: string = ToolTip and ToolTip.Text or ""
					checkEm(toolTipText, term)
				end
			end
		end
		return hits
	end

	function slot:Select(): ...any
		local tool: Tool = slot.Tool
		if tool then
			if IsEquipped(tool) then
				UnequipAllTools()
			elseif tool.Parent == Backpack then
				EquipNewTool(tool)
			end
		end
	end

	SlotFrame, ToolIcon, ToolName, BackGround, EquipStroke = CreateSlotFrame(slot, index)
	slot.Frame = SlotFrame
	slot.Frame.LayoutOrder = slot.Index

	if index <= NumberOfHotbarSlots then
		ToolTip = Instance.new("TextLabel")
		ToolTip.Name = "ToolTip"
		ToolTip.Text = ""
		ToolTip.Size = UDim2.fromScale(1, 1)
		ToolTip.TextColor3 = TEXT_COLOR
		ToolTip.TextStrokeTransparency = TEXT_STROKE_TRANSPARENCY
		ToolTip.TextStrokeColor3 = TEXT_STROKE_COLOR
		ToolTip.FontFace = Font.new(FONT_FAMILY.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		ToolTip.TextSize = FONT_SIZE
		ToolTip.ZIndex = 2
		ToolTip.TextWrapped = false
		ToolTip.TextYAlignment = Enum.TextYAlignment.Center
		ToolTip.BackgroundColor3 = TOOLTIP_BACKGROUND_COLOR
		ToolTip.BackgroundTransparency = SLOT_LOCKED_TRANSPARENCY
		ToolTip.AnchorPoint = Vector2.new(0.5, 1)
		ToolTip.BorderSizePixel = 0
		ToolTip.Visible = false
		ToolTip.AutomaticSize = Enum.AutomaticSize.X
		ToolTip.Parent = SlotFrame
		StyleTextLabel(ToolTip, Enum.FontWeight.Medium) -- <— AGGIUNGI QUESTO
		SlotFrame.AnchorPoint = Vector2.new(0.5, 0.5)

		local ToolTipCorner: UICorner = Instance.new("UICorner")
		ToolTipCorner.Name = "Corner"
		ToolTipCorner.CornerRadius = TOOLTIP_CORNER_RADIUS
		ToolTipCorner.Parent = ToolTip

		local ToolTipPadding: UIPadding = Instance.new("UIPadding")
		ToolTipPadding.PaddingLeft = UDim.new(0, TOOLTIP_PADDING)
		ToolTipPadding.PaddingRight = UDim.new(0, TOOLTIP_PADDING)
		ToolTipPadding.PaddingTop = UDim.new(0, TOOLTIP_PADDING)
		ToolTipPadding.PaddingBottom = UDim.new(0, TOOLTIP_PADDING)
		ToolTipPadding.Parent = ToolTip
		SlotFrame.MouseEnter:Connect(function(): ()
			if ToolTip.Text ~= "" then
				ToolTip.Visible = true
			end
		end)
		SlotFrame.MouseLeave:Connect(function(): ()
			ToolTip.Visible = false
		end)

		function slot:MoveToInventory(): ...any
			if slot.Index <= NumberOfHotbarSlots then
				local tool: any = slot.Tool
				self:Clear()
				clearAttributeLabels()
				local newSlot: any = MakeSlot(UIGridFrame)
				newSlot:Fill(tool)

				if IsEquipped(tool) then
					UnequipAllTools()
				end
				if ViewingSearchResults then
					newSlot.Frame.Visible = false
					newSlot.Frame.Parent = InventoryFrame
				end
			end
		end

		if index < 10 or index == NumberOfHotbarSlots then
			local slotNum: number = (index < 10) and index or 0
			SlotNumber = Instance.new("TextLabel")
			SlotNumber.BackgroundTransparency = 1
			SlotNumber.Name = "Number"
			SlotNumber.TextColor3 = TEXT_COLOR
			SlotNumber.TextStrokeTransparency = TEXT_STROKE_TRANSPARENCY
			SlotNumber.TextStrokeColor3 = TEXT_STROKE_COLOR
			SlotNumber.TextSize = FONT_SIZE
			SlotNumber.Text = tostring(slotNum)
			SlotNumber.FontFace = Font.new(FONT_FAMILY.Family, Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
			SlotNumber.Size = SLOT_NUMBER_SIZE
			SlotNumber.Position = SLOT_NUMBER_POSITION
			SlotNumber.ZIndex = 4
			SlotNumber.AnchorPoint = SLOT_NUMBER_ANCHOR
			SlotNumber.Visible = false
			SlotNumber.Parent = SlotFrame
			StyleTextLabel(SlotNumber, Enum.FontWeight.Heavy) -- <— AGGIUNGI QUESTO (era Heavy nell'originale)
			HotkeyFns[ZERO_KEY_VALUE + slotNum] = slot.Select
		end
	end

	do
		local startPoint: UDim2 = SlotFrame.Position
		local lastUpTime: number = 0
		local startParent: any = nil

		SlotFrame.DragBegin:Connect(function(dragPoint: UDim2): ()
			Dragging[SlotFrame] = true
			startPoint = dragPoint
			SlotFrame.BorderSizePixel = 2
			inventoryIcon:lock()

			startParent = SlotFrame.Parent

			if startParent == UIGridFrame then
				local newPosition: UDim2 = UDim2.new(
					0,
					SlotFrame.AbsolutePosition.X - MainFrame.AbsolutePosition.X + (SlotFrame.AbsoluteSize.X / 2), -- +metà size
					0,
					SlotFrame.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y + (SlotFrame.AbsoluteSize.Y / 2) -- +metà size
				)
				SlotFrame.Parent = MainFrame
				SlotFrame.Position = newPosition

				FakeSlotFrame = Instance.new("Frame")
				FakeSlotFrame.Name = "FakeSlot"

				FakeSlotFrame.LayoutOrder = SlotFrame.LayoutOrder
				FakeSlotFrame.Size = SlotFrame.Size
				FakeSlotFrame.BackgroundTransparency = 1
				FakeSlotFrame.Parent = UIGridFrame
			end

			SlotFrame.ZIndex = 10
			ToolIcon.ZIndex = 10
			ToolName.ZIndex = 10
			if ViewportFrame then
				ViewportFrame.ZIndex = 10
			end
			for _, child in ipairs(SlotFrame:GetChildren()) do
				if child:IsA("TextLabel") and child.Name:find("AttrLabel_") then
					child.ZIndex = 11
				end
			end
			if SlotNumber then
				SlotNumber.ZIndex = 11
			end
		end)

		SlotFrame.DragStopped:Connect(function(x: number, y: number): ()
			if FakeSlotFrame then
				FakeSlotFrame:Destroy()
			end

			local now: number = os.clock()

			SlotFrame.Position = startPoint
			SlotFrame.Parent = startParent

			SlotFrame.BorderSizePixel = 0
			inventoryIcon:unlock()

			SlotFrame.ZIndex = 1
			ToolIcon.ZIndex = 1
			ToolName.ZIndex = 1
			if ViewportFrame then
				ViewportFrame.ZIndex = 1
			end
			for _, child in ipairs(SlotFrame:GetChildren()) do
				if child:IsA("TextLabel") and child.Name:find("AttrLabel_") then
					child.ZIndex = 3
				end
			end
			if SlotNumber then
				SlotNumber.ZIndex = 2
			end

			Dragging[SlotFrame] = nil

			if not slot.Tool then
				return
			end

			if CheckBounds(InventoryFrame, x, y) then
				if slot.Index <= NumberOfHotbarSlots then
					slot:MoveToInventory()
				end
				if slot.Index > NumberOfHotbarSlots and now - lastUpTime < DOUBLE_CLICK_TIME then
					if LowestEmptySlot then
						local myTool: any = slot.Tool
						slot:Clear()
						LowestEmptySlot:Fill(myTool)
						slot:Delete()
					end
					now = 0
				end
			elseif CheckBounds(HotbarFrame, x, y) then
				local closest: { number } = { math.huge, nil :: any }
				for i: number = 1, NumberOfHotbarSlots do
					local otherSlot: any = Slots[i]
					local offset: number = GetOffset(otherSlot.Frame, Vector2.new(x, y))
					if offset < closest[1] then
						closest = { offset, otherSlot }
					end
				end
				local closestSlot: any = closest[2]
				if closestSlot ~= slot then
					slot:Swap(closestSlot)
					if slot.Index > NumberOfHotbarSlots then
						local tool: Tool = slot.Tool
						if not tool then
							slot:Delete()
						else
							if IsEquipped(tool) then
								UnequipAllTools()
							end
							if ViewingSearchResults then
								slot.Frame.Visible = false
								slot.Frame.Parent = InventoryFrame
							end
						end
					end
				end
			else
				if slot.Index <= NumberOfHotbarSlots then
					slot:MoveToInventory()
				end
			end

			lastUpTime = now
		end)
	end

	SlotFrame.Parent = parent
	Slots[index] = slot

	if index > NumberOfHotbarSlots then
		UpdateScrollingFrameCanvasSize()

		if InventoryFrame.Visible and not ViewingSearchResults then
			local offset: number = ScrollingFrame.CanvasSize.Y.Offset - ScrollingFrame.AbsoluteSize.Y
			ScrollingFrame.CanvasPosition = Vector2.new(0, math.max(0, offset))
		end
	end

	return slot
end

local function OnChildAdded(child: Instance): ()
	if not child:IsA("Tool") and not child:IsA("HopperBin") then
		if child:IsA("Humanoid") and child.Parent == Character then
			Humanoid = child
		end
		return
	end
	local tool: any = child

	if tool.Parent == Character then
		ShowVRBackpackPopup()
	end

	if ActiveHopper and tool.Parent == Character then
		DisableActiveHopper()
	end

	if not StarterToolFound and tool.Parent == Character and not SlotsByTool[tool] then
		local starterGear: Instance? = Player:FindFirstChild("StarterGear")
		if starterGear then
			if starterGear:FindFirstChild(tool.Name) then
				StarterToolFound = true
				local slot: any = LowestEmptySlot or MakeSlot(UIGridFrame)
				for i: number = slot.Index, 1, -1 do
					local curr = Slots[i]
					local pIndex: number = i - 1
					if pIndex > 0 then
						local prev = Slots[pIndex]
						prev:Swap(curr)
					else
						curr:Fill(tool)
					end
				end

				for _, children: Instance in pairs(Character:GetChildren()) do
					if children:IsA("Tool") and children ~= tool then
						children.Parent = Backpack
					end
				end
				AdjustHotbarFrames()
				return
			end
		end
	end

	local slot: any = SlotsByTool[tool]
	if slot then
		slot:UpdateEquipView()
	else
		slot = LowestEmptySlot or MakeSlot(UIGridFrame)
		slot:Fill(tool)
		if slot.Index <= NumberOfHotbarSlots and not InventoryFrame.Visible then
			AdjustHotbarFrames()
		end
		if tool:IsA("HopperBin") then
			if tool.Active then
				UnequipAllTools()
				ActiveHopper = tool
			end
		end
	end

	BackpackScript.BackpackItemAdded:Fire()
end

local function OnChildRemoved(child: Instance): ()
	if not child:IsA("Tool") and not child:IsA("HopperBin") then
		return
	end
	local tool: Tool | any = child

	ShowVRBackpackPopup()

	local newParent: any = tool.Parent
	if newParent == Character or newParent == Backpack then
		return
	end

	local slot: any = SlotsByTool[tool]
	if slot then
		slot:Clear()
		if slot.Index > NumberOfHotbarSlots then
			slot:Delete()
		elseif not InventoryFrame.Visible then
			AdjustHotbarFrames()
		end
	end

	if tool :: any == ActiveHopper then
		ActiveHopper = nil :: any
	end

	BackpackScript.BackpackItemRemoved:Fire()
	if isInventoryEmpty() then
		BackpackScript.BackpackEmpty:Fire()
	end
end

local function OnCharacterAdded(character: Model): ()
	for i: number = #Slots, 1, -1 do
		local slot = Slots[i]
		if slot.Tool then
			slot:Clear()
		end
		if i > NumberOfHotbarSlots then
			slot:Delete()
		end
	end
	ActiveHopper = nil :: any

	for _, conn: RBXScriptConnection in pairs(CharConns) do
		conn:Disconnect()
	end
	CharConns = {}

	Character = character
	table.insert(CharConns, character.ChildRemoved:Connect(OnChildRemoved))
	table.insert(CharConns, character.ChildAdded:Connect(OnChildAdded))
	for _, child: Instance in pairs(character:GetChildren()) do
		OnChildAdded(child)
	end

	Backpack = Player:WaitForChild("Backpack")
	table.insert(CharConns, Backpack.ChildRemoved:Connect(OnChildRemoved))
	table.insert(CharConns, Backpack.ChildAdded:Connect(OnChildAdded))
	for _, child: Instance in pairs(Backpack:GetChildren()) do
		OnChildAdded(child)
	end

	AdjustHotbarFrames()
end

local function OnInputBegan(input: InputObject, isProcessed: boolean): ()
	local ChatInputBarConfiguration =
		TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration") :: ChatInputBarConfiguration

	if
		input.UserInputType == Enum.UserInputType.Keyboard
		and not TextBoxFocused
		and not ChatInputBarConfiguration.IsFocused
		and (WholeThingEnabled or input.KeyCode.Value == DROP_HOTKEY_VALUE)
	then
		local hotkeyBehavior: any = HotkeyFns[input.KeyCode.Value]
		if hotkeyBehavior then
			hotkeyBehavior(isProcessed)
		end
	end

	local inputType: Enum.UserInputType = input.UserInputType
	if not isProcessed then
		if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
			if InventoryFrame.Visible then
				inventoryIcon:deselect()
			end
		end
	end
end

local function OnUISChanged(): ()
	if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
		for i: number = 1, NumberOfHotbarSlots do
			Slots[i]:TurnNumber(false)
		end
		return
	end

	if UserInputService:GetLastInputType() == Enum.UserInputType.Keyboard then
		for i: number = 1, NumberOfHotbarSlots do
			Slots[i]:TurnNumber(true)
		end
		return
	end

	for _, mouse: any in pairs(MOUSE_INPUT_TYPES) do
		if UserInputService:GetLastInputType() == mouse then
			for i: number = 1, NumberOfHotbarSlots do
				Slots[i]:TurnNumber(true)
			end
			return
		end
	end

	for _, gamepad: any in pairs(GAMEPAD_INPUT_TYPES) do
		if UserInputService:GetLastInputType() == gamepad then
			for i: number = 1, NumberOfHotbarSlots do
				Slots[i]:TurnNumber(false)
			end
			return
		end
	end
end

local lastChangeToolInputObject: InputObject = nil
local lastChangeToolInputTime: number = nil
local maxEquipDeltaTime: number = 0.06
local noOpFunc = function() end

function unbindAllGamepadEquipActions(): ()
	ContextActionService:UnbindAction("BackpackHasGamepadFocus")
	ContextActionService:UnbindAction("BackpackCloseInventory")
end

changeToolFunc = function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject): ()
	if inputState ~= Enum.UserInputState.Begin then
		return
	end

	if lastChangeToolInputObject then
		if
			(
				lastChangeToolInputObject.KeyCode == Enum.KeyCode.ButtonR1
				and inputObject.KeyCode == Enum.KeyCode.ButtonL1
			)
			or (
				lastChangeToolInputObject.KeyCode == Enum.KeyCode.ButtonL1
				and inputObject.KeyCode == Enum.KeyCode.ButtonR1
			)
		then
			if (os.clock() - lastChangeToolInputTime) <= maxEquipDeltaTime then
				UnequipAllTools()
				lastChangeToolInputObject = inputObject
				lastChangeToolInputTime = os.clock()
				return
			end
		end
	end

	lastChangeToolInputObject = inputObject
	lastChangeToolInputTime = os.clock()

	task.delay(maxEquipDeltaTime, function(): ()
		if lastChangeToolInputObject ~= inputObject then
			return
		end

		local moveDirection: number = 0
		if inputObject.KeyCode == Enum.KeyCode.ButtonL1 then
			moveDirection = -1
		else
			moveDirection = 1
		end

		for i: number = 1, NumberOfHotbarSlots do
			local hotbarSlot: any = Slots[i]
			if hotbarSlot:IsEquipped() then
				local newSlotPosition: number = moveDirection + i
				local hitEdge: boolean = false
				if newSlotPosition > NumberOfHotbarSlots then
					newSlotPosition = 1
					hitEdge = true
				elseif newSlotPosition < 1 then
					newSlotPosition = NumberOfHotbarSlots
					hitEdge = true
				end

				local origNewSlotPos: number = newSlotPosition
				while not Slots[newSlotPosition].Tool do
					newSlotPosition = newSlotPosition + moveDirection
					if newSlotPosition == origNewSlotPos then
						return
					end

					if newSlotPosition > NumberOfHotbarSlots then
						newSlotPosition = 1
						hitEdge = true
					elseif newSlotPosition < 1 then
						newSlotPosition = NumberOfHotbarSlots
						hitEdge = true
					end
				end

				if hitEdge then
					UnequipAllTools()
					lastEquippedSlot = nil
				else
					Slots[newSlotPosition]:Select()
				end
				return
			end
		end

		if lastEquippedSlot and lastEquippedSlot.Tool then
			lastEquippedSlot:Select()
			return
		end

		local startIndex: number = moveDirection == -1 and NumberOfHotbarSlots or 1
		local endIndex: number = moveDirection == -1 and 1 or NumberOfHotbarSlots
		for i: number = startIndex, endIndex, moveDirection do
			if Slots[i].Tool then
				Slots[i]:Select()
				return
			end
		end
	end)
end

function getGamepadSwapSlot(): any
	for i: number = 1, #Slots do
		if Slots[i].Frame.BorderSizePixel > 0 then
			return Slots[i]
		end
	end
	return
end

function changeSlot(slot: any): ()
	local swapInVr: boolean = not VRService.VREnabled or InventoryFrame.Visible

	if slot.Frame == GuiService.SelectedObject and swapInVr then
		local currentlySelectedSlot: any = getGamepadSwapSlot()

		if currentlySelectedSlot then
			currentlySelectedSlot.Frame.BorderSizePixel = 0
			if currentlySelectedSlot ~= slot then
				slot:Swap(currentlySelectedSlot)
				VRInventorySelector.SelectionImageObject.Visible = false

				if slot.Index > NumberOfHotbarSlots and not slot.Tool then
					if GuiService.SelectedObject == slot.Frame then
						GuiService.SelectedObject = currentlySelectedSlot.Frame
					end
					slot:Delete()
				end

				if currentlySelectedSlot.Index > NumberOfHotbarSlots and not currentlySelectedSlot.Tool then
					if GuiService.SelectedObject == currentlySelectedSlot.Frame then
						GuiService.SelectedObject = slot.Frame
					end
					currentlySelectedSlot:Delete()
				end
			end
		else
			local startSize: UDim2 = slot.Frame.Size
			local startPosition: UDim2 = slot.Frame.Position
			slot.Frame:TweenSizeAndPosition(
				startSize + UDim2.fromOffset(10, 10),
				startPosition, -- prima era: startPosition - UDim2.fromOffset(5, 5)
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true,
				function(): ()
					slot.Frame:TweenSizeAndPosition(
						startSize,
						startPosition,
						Enum.EasingDirection.In,
						Enum.EasingStyle.Quad,
						0.1,
						true
					)
				end
			)
			slot.Frame.BorderSizePixel = 3
			VRInventorySelector.SelectionImageObject.Visible = true
		end
	else
		slot:Select()
		VRInventorySelector.SelectionImageObject.Visible = false
	end
end

function vrMoveSlotToInventory(): ()
	if not VRService.VREnabled then
		return
	end

	local currentlySelectedSlot: any = getGamepadSwapSlot()
	if currentlySelectedSlot and currentlySelectedSlot.Tool then
		currentlySelectedSlot.Frame.BorderSizePixel = 0
		currentlySelectedSlot:MoveToInventory()
		VRInventorySelector.SelectionImageObject.Visible = false
	end
end

function enableGamepadInventoryControl(): ()
	local goBackOneLevel = function(): ()
		local selectedSlot: any = getGamepadSwapSlot()
		if selectedSlot then
			local selectedSlot: any = getGamepadSwapSlot()
			if selectedSlot then
				selectedSlot.Frame.BorderSizePixel = 0
				return
			end
		elseif InventoryFrame.Visible then
			inventoryIcon:deselect()
		end
	end

	ContextActionService:BindAction("BackpackHasGamepadFocus", noOpFunc, false, Enum.UserInputType.Gamepad1)
	ContextActionService:BindAction(
		"BackpackCloseInventory",
		goBackOneLevel,
		false,
		Enum.KeyCode.ButtonB,
		Enum.KeyCode.ButtonStart
	)

	if not UseGazeSelection() then
		GuiService.SelectedObject = HotbarFrame:FindFirstChild("1")
	end
end

function disableGamepadInventoryControl(): ()
	unbindAllGamepadEquipActions()

	for i: number = 1, NumberOfHotbarSlots do
		local hotbarSlot: any = Slots[i]
		if hotbarSlot and hotbarSlot.Frame then
			hotbarSlot.Frame.BorderSizePixel = 0
		end
	end

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(MainFrame) then
		GuiService.SelectedObject = nil
	end
end

local function bindBackpackHotbarAction(): ()
	if WholeThingEnabled and not GamepadActionsBound then
		GamepadActionsBound = true
		ContextActionService:BindAction(
			"BackpackHotbarEquip",
			changeToolFunc,
			false,
			Enum.KeyCode.ButtonL1,
			Enum.KeyCode.ButtonR1
		)
	end
end

local function unbindBackpackHotbarAction(): ()
	disableGamepadInventoryControl()
	GamepadActionsBound = false
	ContextActionService:UnbindAction("BackpackHotbarEquip")
end

function gamepadDisconnected(): ()
	GamepadEnabled = false
	disableGamepadInventoryControl()
end

function gamepadConnected(): ()
	GamepadEnabled = true
	GuiService:AddSelectionParent("BackpackSelection", MainFrame)

	if FullHotbarSlots >= 1 then
		bindBackpackHotbarAction()
	end

	if InventoryFrame.Visible then
		enableGamepadInventoryControl()
	end
end

local function OnIconChanged(enabled: boolean): ()
	local success, _topbarEnabled = pcall(function()
		return enabled and StarterGui:GetCore("TopbarEnabled")
	end)

	if not success then
		return
	end

	WholeThingEnabled = enabled
	MainFrame.Visible = enabled

	if enabled then
		if FullHotbarSlots >= 1 then
			bindBackpackHotbarAction()
		end
	else
		unbindBackpackHotbarAction()
	end
end

local function MakeVRRoundButton(name: string, image: string): (ImageButton, ImageLabel, ImageLabel)
	local newButton: ImageButton = Instance.new("ImageButton")
	newButton.BackgroundTransparency = 1
	newButton.Name = name
	newButton.Size = UDim2.fromOffset(40, 40)
	newButton.Image = "rbxasset://textures/ui/Keyboard/close_button_background.png"

	local buttonIcon: ImageLabel = Instance.new("ImageLabel")
	buttonIcon.Name = "Icon"
	buttonIcon.BackgroundTransparency = 1
	buttonIcon.Size = UDim2.fromScale(0.5, 0.5)
	buttonIcon.Position = UDim2.fromScale(0.25, 0.25)
	buttonIcon.Image = image
	buttonIcon.Parent = newButton

	local buttonSelectionObject: ImageLabel = Instance.new("ImageLabel")
	buttonSelectionObject.BackgroundTransparency = 1
	buttonSelectionObject.Name = "Selection"
	buttonSelectionObject.Size = UDim2.fromScale(0.9, 0.9)
	buttonSelectionObject.Position = UDim2.fromScale(0.05, 0.05)
	buttonSelectionObject.Image = "rbxasset://textures/ui/Keyboard/close_button_selection.png"
	newButton.SelectionImageObject = buttonSelectionObject

	return newButton, buttonIcon, buttonSelectionObject
end

MainFrame = Instance.new("Frame")
MainFrame.BackgroundTransparency = 1
MainFrame.Name = "Backpack"
MainFrame.Size = UDim2.fromScale(1, 1)
MainFrame.Visible = false
MainFrame.Parent = BackpackGui

HotbarFrame = Instance.new("Frame")
HotbarFrame.BackgroundTransparency = 1
HotbarFrame.Name = "Hotbar"
HotbarFrame.Size = UDim2.fromScale(1, 1)
HotbarFrame.Parent = MainFrame

for index: number = 1, NumberOfHotbarSlots do
	local slot: any = MakeSlot(HotbarFrame, index)
	slot.Frame.Visible = false

	if not LowestEmptySlot then
		LowestEmptySlot = slot
	end
end

local LeftBumperButton: ImageLabel = Instance.new("ImageLabel")
LeftBumperButton.BackgroundTransparency = 1
LeftBumperButton.Name = "LeftBumper"
LeftBumperButton.Size = UDim2.fromOffset(40, 40)
LeftBumperButton.Position = UDim2.new(0, -LeftBumperButton.Size.X.Offset, 0.5, -LeftBumperButton.Size.Y.Offset / 2)

local RightBumperButton: ImageLabel = Instance.new("ImageLabel")
RightBumperButton.BackgroundTransparency = 1
RightBumperButton.Name = "RightBumper"
RightBumperButton.Size = UDim2.fromOffset(40, 40)
RightBumperButton.Position = UDim2.new(1, 0, 0.5, -RightBumperButton.Size.Y.Offset / 2)

InventoryFrame = Instance.new("Frame")
InventoryFrame.Name = "Inventory"
InventoryFrame.Size = UDim2.fromScale(1, 1)
InventoryFrame.BackgroundTransparency = BACKGROUND_TRANSPARENCY
InventoryFrame.BackgroundColor3 = BACKGROUND_COLOR
InventoryFrame.Active = true
InventoryFrame.Visible = false
InventoryFrame.ClipsDescendants = true
InventoryFrame.Parent = MainFrame
local corner: UICorner = Instance.new("UICorner")
corner.Name = "Corner"
corner.CornerRadius = BACKGROUND_CORNER_RADIUS
corner.Parent = InventoryFrame

BackpackTitle = Instance.new("TextLabel")
BackpackTitle.Name = "Title"
BackpackTitle.BackgroundTransparency = 1
BackpackTitle.FontFace.Weight = Enum.FontWeight.ExtraBold
BackpackTitle.Text = BACKPACK_TITLE_TEXT
BackpackTitle.TextColor3 = BACKPACK_TITLE_COLOR
BackpackTitle.TextStrokeTransparency = TEXT_STROKE_TRANSPARENCY
BackpackTitle.TextStrokeColor3 = TEXT_STROKE_COLOR
BackpackTitle.FontFace = Font.new(FONT_FAMILY.Family, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
BackpackTitle.TextSize = BACKPACK_TITLE_SIZE
BackpackTitle.TextXAlignment = Enum.TextXAlignment.Left
BackpackTitle.TextYAlignment = Enum.TextYAlignment.Top
BackpackTitle.AutomaticSize = Enum.AutomaticSize.XY
BackpackTitle.AnchorPoint = Vector2.new(0, 0)
BackpackTitle.Position = BACKPACK_TITLE_OFFSET
BackpackTitle.ZIndex = 2
BackpackTitle.Parent = InventoryFrame
StyleTextLabel(BackpackTitle) -- <— sostituisce sia FontFace che il vecchio blocco "local Stroke = ..."

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 4
game:GetService("CollectionService"):AddTag(Stroke, "ScaleUIStroke")
Stroke.Parent = BackpackTitle

VRInventorySelector = Instance.new("TextButton")
VRInventorySelector.Name = "VRInventorySelector"
VRInventorySelector.Position = UDim2.new(0, 0, 0, 0)
VRInventorySelector.Size = UDim2.fromScale(1, 1)
VRInventorySelector.BackgroundTransparency = 1
VRInventorySelector.Text = ""
VRInventorySelector.Parent = InventoryFrame

local selectorImage: ImageLabel = Instance.new("ImageLabel")
selectorImage.BackgroundTransparency = 1
selectorImage.Name = "Selector"
selectorImage.Size = UDim2.fromScale(1, 1)
selectorImage.Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png"
selectorImage.ScaleType = Enum.ScaleType.Slice
selectorImage.SliceCenter = Rect.new(12, 12, 52, 52)
selectorImage.Visible = false
VRInventorySelector.SelectionImageObject = selectorImage

VRInventorySelector.MouseButton1Click:Connect(function(): ()
	vrMoveSlotToInventory()
end)

ScrollClipGroup = Instance.new("CanvasGroup")
ScrollClipGroup.Name = "ScrollClipGroup"
ScrollClipGroup.BackgroundTransparency = 1
ScrollClipGroup.BorderSizePixel = 0
ScrollClipGroup.Size = UDim2.fromScale(1, 1)
ScrollClipGroup.Position = UDim2.fromScale(0, 0)
ScrollClipGroup.Parent = InventoryFrame

ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Size = UDim2.fromScale(1, 1)
ScrollingFrame.Position = UDim2.fromScale(0, 0)
ScrollingFrame.Selectable = false
ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 10
ScrollingFrame.ScrollBarImageTransparency = 0.5
ScrollingFrame.ScrollBarImageColor3 = Color3.new(1, 1, 1)
ScrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.None
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ScrollClipGroup

UIGridFrame = Instance.new("Frame")
UIGridFrame.BackgroundTransparency = 1
UIGridFrame.Name = "UIGridFrame"
UIGridFrame.Selectable = false
UIGridFrame.Size = UDim2.new(1, -(ICON_BUFFER_PIXELS * 2) - (ScrollingFrame.ScrollBarThickness + 2) + 20, 1, 0)
UIGridFrame.Position = UDim2.fromOffset(ICON_BUFFER_PIXELS, 0)
UIGridFrame.Parent = ScrollingFrame
UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.CellSize = UDim2.fromOffset(ICON_SIZE_PIXELS + 10, ICON_SIZE_PIXELS + 10)
UIGridLayout.CellPadding = UDim2.fromOffset(ICON_BUFFER_PIXELS, ICON_BUFFER_PIXELS)
UIGridLayout.Parent = UIGridFrame

local Padding = Instance.new("UIPadding")
Padding.Parent = UIGridFrame
Padding.PaddingTop = UDim.new(0, PADDING_TOPANDLEFT - 20)
Padding.PaddingLeft = UDim.new(0, PADDING_TOPANDLEFT - 30)

ScrollUpInventoryButton = MakeVRRoundButton("ScrollUpButton", "rbxasset://textures/ui/Backpack/ScrollUpArrow.png")
ScrollUpInventoryButton.Size = UDim2.fromOffset(34, 34)
ScrollUpInventoryButton.Position =
	UDim2.new(0.5, -ScrollUpInventoryButton.Size.X.Offset / 2, 0, INVENTORY_HEADER_SIZE + 3)
ScrollUpInventoryButton.Icon.Position = ScrollUpInventoryButton.Icon.Position - UDim2.fromOffset(0, 2)
ScrollUpInventoryButton.MouseButton1Click:Connect(function(): ()
	ScrollingFrame.CanvasPosition = Vector2.new(
		ScrollingFrame.CanvasPosition.X,
		Clamp(
			0,
			ScrollingFrame.CanvasSize.Y.Offset - ScrollingFrame.AbsoluteWindowSize.Y,
			ScrollingFrame.CanvasPosition.Y - (ICON_BUFFER_PIXELS + ICON_SIZE_PIXELS)
		)
	)
end)

ScrollDownInventoryButton = MakeVRRoundButton("ScrollDownButton", "rbxasset://textures/ui/Backpack/ScrollUpArrow.png")
ScrollDownInventoryButton.Rotation = 180
ScrollDownInventoryButton.Icon.Position = ScrollDownInventoryButton.Icon.Position - UDim2.fromOffset(0, 2)
ScrollDownInventoryButton.Size = UDim2.fromOffset(34, 34)
ScrollDownInventoryButton.Position =
	UDim2.new(0.5, -ScrollDownInventoryButton.Size.X.Offset / 2, 1, -ScrollDownInventoryButton.Size.Y.Offset - 3)
ScrollDownInventoryButton.MouseButton1Click:Connect(function(): ()
	ScrollingFrame.CanvasPosition = Vector2.new(
		ScrollingFrame.CanvasPosition.X,
		Clamp(
			0,
			ScrollingFrame.CanvasSize.Y.Offset - ScrollingFrame.AbsoluteWindowSize.Y,
			ScrollingFrame.CanvasPosition.Y + (ICON_BUFFER_PIXELS + ICON_SIZE_PIXELS)
		)
	)
end)

ScrollingFrame.Changed:Connect(function(prop: string): ()
	if prop == "AbsoluteWindowSize" or prop == "CanvasPosition" or prop == "CanvasSize" then
		local canScrollUp: boolean = ScrollingFrame.CanvasPosition.Y ~= 0
		local canScrollDown: boolean = ScrollingFrame.CanvasPosition.Y
			< ScrollingFrame.CanvasSize.Y.Offset - ScrollingFrame.AbsoluteWindowSize.Y

		ScrollUpInventoryButton.Visible = canScrollUp
		ScrollDownInventoryButton.Visible = canScrollDown
	end
end)

UpdateBackpackLayout()

local gamepadHintsFrame: Frame = Instance.new("Frame")
gamepadHintsFrame.Name = "GamepadHintsFrame"
gamepadHintsFrame.Size = UDim2.fromOffset(HotbarFrame.Size.X.Offset, (IsTenFootInterface and 95 or 60))
gamepadHintsFrame.BackgroundTransparency = BACKGROUND_TRANSPARENCY
gamepadHintsFrame.BackgroundColor3 = BACKGROUND_COLOR
gamepadHintsFrame.Visible = false
gamepadHintsFrame.Parent = MainFrame

local gamepadHintsFrameLayout: UIListLayout = Instance.new("UIListLayout")
gamepadHintsFrameLayout.Name = "Layout"
gamepadHintsFrameLayout.Padding = UDim.new(0, 25)
gamepadHintsFrameLayout.FillDirection = Enum.FillDirection.Horizontal
gamepadHintsFrameLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gamepadHintsFrameLayout.SortOrder = Enum.SortOrder.LayoutOrder
gamepadHintsFrameLayout.Parent = gamepadHintsFrame

local gamepadHintsFrameCorner: UICorner = Instance.new("UICorner")
gamepadHintsFrameCorner.Name = "Corner"
gamepadHintsFrameCorner.CornerRadius = BACKGROUND_CORNER_RADIUS
gamepadHintsFrameCorner.Parent = gamepadHintsFrame

local function addGamepadHint(hintImageString: string, hintTextString: string): ()
	local hintFrame: Frame = Instance.new("Frame")
	hintFrame.Name = "HintFrame"
	hintFrame.AutomaticSize = Enum.AutomaticSize.XY
	hintFrame.BackgroundTransparency = 1
	hintFrame.Parent = gamepadHintsFrame

	local hintLayout: UIListLayout = Instance.new("UIListLayout")
	hintLayout.Name = "Layout"
	hintLayout.Padding = (IsTenFootInterface and UDim.new(0, 20) or UDim.new(0, 12))
	hintLayout.FillDirection = Enum.FillDirection.Horizontal
	hintLayout.SortOrder = Enum.SortOrder.LayoutOrder
	hintLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	hintLayout.Parent = hintFrame

	local hintImage: ImageLabel = Instance.new("ImageLabel")
	hintImage.Name = "HintImage"
	hintImage.Size = (IsTenFootInterface and UDim2.fromOffset(60, 60) or UDim2.fromOffset(30, 30))
	hintImage.BackgroundTransparency = 1
	hintImage.Image = hintImageString
	hintImage.Parent = hintFrame

	local hintText: TextLabel = Instance.new("TextLabel")
	hintText.Name = "HintText"
	hintText.AutomaticSize = Enum.AutomaticSize.XY
	hintText.FontFace = Font.new(FONT_FAMILY.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	hintText.TextSize = (IsTenFootInterface and 32 or 19)
	hintText.BackgroundTransparency = 1
	hintText.Text = hintTextString
	hintText.TextColor3 = Color3.new(1, 1, 1)
	hintText.TextXAlignment = Enum.TextXAlignment.Left
	hintText.TextYAlignment = Enum.TextYAlignment.Center
	hintText.TextWrapped = true
	hintText.Parent = hintFrame
	StyleTextLabel(hintText, Enum.FontWeight.Medium) -- <— AGGIUNGI QUESTO (era Medium nell'originale)

	local textSizeConstraint: UITextSizeConstraint = Instance.new("UITextSizeConstraint")
	textSizeConstraint.MaxTextSize = hintText.TextSize
	textSizeConstraint.Parent = hintText
end

addGamepadHint(UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonX), "Remove From Hotbar")
addGamepadHint(UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonA), "Select/Swap")
addGamepadHint(UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonB), "Close Backpack")

local function resizeGamepadHintsFrame(): ()
	gamepadHintsFrame.Size =
		UDim2.new(HotbarFrame.Size.X.Scale, HotbarFrame.Size.X.Offset, 0, (IsTenFootInterface and 95 or 60))
	gamepadHintsFrame.Position = UDim2.new(
		HotbarFrame.Position.X.Scale,
		HotbarFrame.Position.X.Offset,
		InventoryFrame.Position.Y.Scale,
		InventoryFrame.Position.Y.Offset - gamepadHintsFrame.Size.Y.Offset - ICON_BUFFER_PIXELS
	)

	local spaceTaken: number = 0

	local gamepadHints: { Instance } = gamepadHintsFrame:GetChildren()
	local filteredGamepadHints: any = {}

	for _, child: Instance in pairs(gamepadHints) do
		if child:IsA("GuiObject") then
			table.insert(filteredGamepadHints, child)
		end
	end

	for guiObjects = 1, #filteredGamepadHints do
		if filteredGamepadHints[guiObjects]:IsA("GuiObject") then
			filteredGamepadHints[guiObjects].Size = UDim2.new(1, 0, 1, -5)
			filteredGamepadHints[guiObjects].Position = UDim2.new(0, 0, 0, 0)
			spaceTaken = spaceTaken
				+ (
					filteredGamepadHints[guiObjects].HintText.Position.X.Offset
					+ filteredGamepadHints[guiObjects].HintText.TextBounds.X
				)
		end
	end

	local spaceBetweenElements: number = (gamepadHintsFrame.AbsoluteSize.X - spaceTaken) / (#filteredGamepadHints - 1)
	for i: number = 1, #filteredGamepadHints do
		filteredGamepadHints[i].Position = (
			i == 1 and UDim2.new(0, 0, 0, 0)
			or UDim2.new(
				0,
				filteredGamepadHints[i - 1].Position.X.Offset
					+ filteredGamepadHints[i - 1].Size.X.Offset
					+ spaceBetweenElements,
				0,
				0
			)
		)
		filteredGamepadHints[i].Size = UDim2.new(
			0,
			(filteredGamepadHints[i].HintText.Position.X.Offset + filteredGamepadHints[i].HintText.TextBounds.X),
			1,
			-5
		)
	end
end

local searchFrame: Frame = Instance.new("Frame")
do
	searchFrame.Name = "Search"
	searchFrame.BackgroundColor3 = SEARCH_BACKGROUND_COLOR
	searchFrame.Size = UDim2.new(0, SEARCH_WIDTH_PIXELS, 0, SEARCH_HEIGHT_PIXELS)
	searchFrame.Position = UDim2.new(1, -SEARCH_WIDTH_PIXELS - SEARCH_RIGHT_OFFSET, 0, SEARCH_TOP_OFFSET)
	searchFrame.Parent = InventoryFrame
	searchFrame.BackgroundTransparency = 0.5
	local searchFrameCorner: UICorner = Instance.new("UICorner")
	searchFrameCorner.Name = "Corner"
	searchFrameCorner.CornerRadius = SEARCH_CORNER_RADIUS
	searchFrameCorner.Parent = searchFrame

	local searchFrameBorder: UIStroke = Instance.new("UIStroke")
	searchFrameBorder.Name = "Border"
	searchFrameBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	searchFrameBorder.Color = SEARCH_BORDER_COLOR
	searchFrameBorder.Thickness = SEARCH_BORDER_THICKNESS
	searchFrameBorder.Transparency = SEARCH_BORDER_TRANSPARENCY
	game.CollectionService:AddTag(searchFrameBorder, "ScaleUIStroke")
	searchFrameBorder:SetAttribute("FROMINV", true)
	searchFrameBorder.Parent = searchFrame
	local searchBox: TextBox = Instance.new("TextBox")
	searchBox.BackgroundTransparency = 1
	searchBox.Name = "TextBox"
	searchBox.Text = ""
	searchBox.TextColor3 = TEXT_COLOR
	searchBox.PlaceholderText = SEARCH_TEXT_PLACEHOLDER
	searchBox.TextTransparency = 0
	searchBox.ClearTextOnFocus = false
	searchBox.TextTruncate = Enum.TextTruncate.AtEnd
	searchBox.TextSize = TEXTSIZE
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.TextYAlignment = Enum.TextYAlignment.Center
	searchBox.Size = UDim2.new(
		0,
		SEARCH_WIDTH_PIXELS - (SEARCH_TEXT_OFFSET * 2) - 20,
		0,
		SEARCH_HEIGHT_PIXELS - (SEARCH_INNER_PADDING * 2)
	)
	searchBox.AnchorPoint = Vector2.new(0, 0.5)
	searchBox.Position = UDim2.new(0, SEARCH_TEXT_OFFSET, 0.5, 0)
	searchBox.ZIndex = 2
	searchBox.Parent = searchFrame
	searchBox.PlaceholderColor3 = Color3.new(1, 1, 1)
	searchBox.TextTransparency = 0
	StyleTextLabel(searchBox, Enum.FontWeight.Medium, 2) -- <— AGGIUNGI QUESTO: stile uniforme, stroke più sottile (2) per non appesantire il campo di ricerca

	local xButtonSize: number = SEARCH_HEIGHT_PIXELS - (SEARCH_INNER_PADDING * 2)

	local xButton: TextButton = Instance.new("TextButton")
	xButton.Name = "X"
	xButton.Text = ""
	xButton.Size = UDim2.fromOffset(xButtonSize, xButtonSize)
	xButton.Position = UDim2.new(1, -xButtonSize - SEARCH_INNER_PADDING, 0.5, -xButtonSize / 2)
	xButton.ZIndex = 4
	xButton.Visible = false
	xButton.BackgroundTransparency = 1
	xButton.Parent = searchFrame

	local xImage: ImageButton = Instance.new("ImageButton")
	xImage.Name = "X"
	xImage.Image = SEARCH_IMAGE_X
	xImage.BackgroundTransparency = 1
	xImage.Size = UDim2.fromScale(1, 1)
	xImage.AnchorPoint = Vector2.new(0.5, 0.5)
	xImage.Position = UDim2.fromScale(0.5, 0.5)
	xImage.ZIndex = 1
	xImage.BorderSizePixel = 0
	xImage.Parent = xButton

	local function search(): ()
		local terms: { [string]: boolean } = {}
		for word: string in searchBox.Text:gmatch("%S+") do
			terms[word:lower()] = true
		end

		local hitTable = {}
		for i: number = NumberOfHotbarSlots + 1, #Slots do
			local slot = Slots[i]
			local hits: any = slot:CheckTerms(terms)
			table.insert(hitTable, { slot, hits })
			slot.Frame.Visible = false
			slot.Frame.Parent = InventoryFrame
		end

		table.sort(hitTable, function(left: any, right: any): boolean
			return left[2] > right[2]
		end)
		ViewingSearchResults = true

		local hitCount: number = 0
		for _, data in ipairs(hitTable) do
			local slot, hits: any = data[1], data[2]
			if hits > 0 then
				slot.Frame.Visible = true
				slot.Frame.Parent = UIGridFrame
				slot.Frame.LayoutOrder = NumberOfHotbarSlots + hitCount
				hitCount = hitCount + 1
			end
		end

		ScrollingFrame.CanvasPosition = Vector2.new(0, 0)
		UpdateScrollingFrameCanvasSize()

		xButton.ZIndex = 3
	end

	local function clearResults(): ()
		if xButton.ZIndex > 0 then
			ViewingSearchResults = false
			for i: number = NumberOfHotbarSlots + 1, #Slots do
				local slot = Slots[i]
				slot.Frame.LayoutOrder = slot.Index
				slot.Frame.Parent = UIGridFrame
				slot.Frame.Visible = true
			end
			xButton.ZIndex = 0
		end
		UpdateScrollingFrameCanvasSize()
	end

	local function reset(): ()
		clearResults()
		searchBox.Text = ""
	end

	local function onChanged(property: string): ()
		if property == "Text" then
			local text: string = searchBox.Text
			if text == "" then
				searchBox.TextTransparency = 0
				clearResults()
			elseif text ~= SEARCH_TEXT then
				searchBox.TextTransparency = 0
				search()
			end
			xButton.Visible = text ~= "" and text ~= SEARCH_TEXT
		end
	end

	local function focusLost(enterPressed: boolean): ()
		if enterPressed then
			if searchBox.Text ~= "" then
				search()
			else
				clearResults()
			end
		end
	end

	xButton.MouseButton1Click:Connect(reset)
	searchBox.Changed:Connect(onChanged)
	searchBox.FocusLost:Connect(focusLost)

	BackpackScript.StateChanged.Event:Connect(function(isNowOpen: boolean): ()
		if not isNowOpen then
			reset()
		end
	end)

	HotkeyFns[Enum.KeyCode.Escape.Value] = function(isProcessed: any): ()
		if isProcessed then
			reset()
		end
	end
	local function detectGamepad(lastInputType: Enum.UserInputType): ()
		if lastInputType == Enum.UserInputType.Gamepad1 and not UserInputService.VREnabled then
			searchFrame.Visible = false
		else
			searchFrame.Visible = true
		end
	end
	UserInputService.LastInputTypeChanged:Connect(detectGamepad)
end

GuiService.MenuOpened:Connect(function(): ()
	BackpackGui.Enabled = false
	inventoryIcon:setEnabled(false)
end)

GuiService.MenuClosed:Connect(function(): ()
	BackpackGui.Enabled = true
	inventoryIcon:setEnabled(true)
end)

do
	local removeHotBarSlot = function(name: string, state: Enum.UserInputState, input: InputObject): ()
		if state ~= Enum.UserInputState.Begin then
			return
		end
		if not GuiService.SelectedObject then
			return
		end

		for i: number = 1, NumberOfHotbarSlots do
			if Slots[i].Frame == GuiService.SelectedObject and Slots[i].Tool then
				Slots[i]:MoveToInventory()
				return
			end
		end
	end

	local function openClose(): ()
		if not next(Dragging) then
			InventoryFrame.Visible = not InventoryFrame.Visible
			local nowOpen: boolean = InventoryFrame.Visible
			AdjustHotbarFrames()
			HotbarFrame.Active = not HotbarFrame.Active
			for i: number = 1, NumberOfHotbarSlots do
				Slots[i]:SetClickability(not nowOpen)
			end
		end

		if InventoryFrame.Visible then
			if GamepadEnabled then
				if GAMEPAD_INPUT_TYPES[UserInputService:GetLastInputType()] then
					resizeGamepadHintsFrame()
					gamepadHintsFrame.Visible = not UserInputService.VREnabled
				end
				enableGamepadInventoryControl()
			end
			if BackpackPanel and VRService.VREnabled then
				BackpackPanel:SetVisible(true)
				BackpackPanel:RequestPositionUpdate()
			end
		else
			if GamepadEnabled then
				gamepadHintsFrame.Visible = false
			end
			disableGamepadInventoryControl()
		end

		if InventoryFrame.Visible then
			ContextActionService:BindAction("BackpackRemoveSlot", removeHotBarSlot, false, Enum.KeyCode.ButtonX)
		else
			ContextActionService:UnbindAction("BackpackRemoveSlot")
		end

		BackpackScript.IsOpen = InventoryFrame.Visible
		BackpackScript.StateChanged:Fire(InventoryFrame.Visible)
	end

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	BackpackScript.OpenClose = openClose
end

while not Player do
	task.wait()
	Player = Players.LocalPlayer
end

Player.CharacterAdded:Connect(OnCharacterAdded)
if Player.Character then
	OnCharacterAdded(Player.Character)
end

do
	UserInputService.InputBegan:Connect(OnInputBegan)

	UserInputService.TextBoxFocused:Connect(function(): ()
		TextBoxFocused = true
	end)
	UserInputService.TextBoxFocusReleased:Connect(function(): ()
		TextBoxFocused = false
	end)

	HotkeyFns[DROP_HOTKEY_VALUE] = function(): ()
		if ActiveHopper then
			UnequipAllTools()
		end
	end

	UserInputService.LastInputTypeChanged:Connect(OnUISChanged)
	OnUISChanged()

	if UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1) then
		gamepadConnected()
	end
	UserInputService.GamepadConnected:Connect(function(gamepadEnum: Enum.UserInputType): ()
		if gamepadEnum == Enum.UserInputType.Gamepad1 then
			gamepadConnected()
		end
	end)
	UserInputService.GamepadDisconnected:Connect(function(gamepadEnum: Enum.UserInputType): ()
		if gamepadEnum == Enum.UserInputType.Gamepad1 then
			gamepadDisconnected()
		end
	end)
end

function BackpackScript:SetBackpackEnabled(Enabled: boolean): ()
	BackpackEnabled = Enabled
end

function BackpackScript:IsOpened(): boolean
	return BackpackScript.IsOpen
end

function BackpackScript:GetBackpackEnabled(): boolean
	return BackpackEnabled
end

function BackpackScript:GetStateChangedEvent(): BindableEvent
	return BackpackScript.StateChanged
end

RunService.Heartbeat:Connect(function(): ()
	OnIconChanged(BackpackEnabled)
end)

local function OnPreferredTransparencyChanged(): ()
	local preferredTransparency: number = GuiService.PreferredTransparency

	BACKGROUND_TRANSPARENCY = BACKGROUND_TRANSPARENCY_DEFAULT * preferredTransparency
	InventoryFrame.BackgroundTransparency = BACKGROUND_TRANSPARENCY

	SLOT_LOCKED_TRANSPARENCY = SLOT_LOCKED_TRANSPARENCY_DEFAULT * preferredTransparency
	for _, slot in ipairs(Slots) do
		slot.Frame.BackgroundTransparency = SLOT_LOCKED_TRANSPARENCY
	end

	SEARCH_BACKGROUND_TRANSPARENCY = SEARCH_BACKGROUND_TRANSPARENCY_DEFAULT * preferredTransparency
	searchFrame.BackgroundTransparency = SEARCH_BACKGROUND_TRANSPARENCY
end
GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(OnPreferredTransparencyChanged)

return BackpackScript
