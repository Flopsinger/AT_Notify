--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------

Global( "LocalizedTexts", nil )

local widgetArrowDescription = mainForm:GetChildChecked( 'Arrow', false ):GetWidgetDesc()
local widgetControl3D = stateMainForm:GetChildChecked( "MainAddonMainForm", false ):GetChildChecked( "MainScreenControl3D", false )

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------

-- Log to the ingame chat
--@return nil
function LogToChatColor(text, color)
	local widgetChat = nil
	local valuedText = common.CreateValuedText()
	if not widgetChat then 
		widgetChat = stateMainForm:GetChildUnchecked("ChatLog", false)
		widgetChat = widgetChat:GetChildUnchecked("Container", true)
		local formatVT = "<html fontsize='18' fontname='AllodsSystem' outline='1'><rs class='color'><r name='addon'/><r name='text'/></rs></html>"
		valuedText:SetFormat(userMods.ToWString(formatVT))
	end
	if widgetChat and widgetChat.PushFrontValuedText then
		if not common.IsWString(text) then text = userMods.ToWString(text) end
		valuedText:ClearValues()
		valuedText:SetClassVal( "color", color)
		valuedText:SetVal( "text", text )
		widgetChat:PushFrontValuedText( valuedText )
	end
end

-- Resize a widget
local function resizeWidget( widget, x, y )
	local placementPlain = widget:GetPlacementPlain()
	placementPlain.sizeX = x
	placementPlain.sizeY = y
	widget:SetPlacementPlain( placementPlain )
end


function AttachArrowToObject( object_id )
    local ArrowMarker = mainForm:CreateWidgetByDesc( widgetArrowDescription )
    resizeWidget(ArrowMarker, 90, 900)
    ArrowMarker:SetBackgroundColor( { r = 1, g = 0, b = 1, a = 1.0 } )

    widgetControl3D:AddWidget3D(
		ArrowMarker,
		{ sizeX = 1.2, sizeY = 1.2 },   -- sizeX: number - size of the 3D control by X in meters
		avatar.GetPos(),                -- Rotate in 3D space depending on this position
		false,                           -- autoResizeX: boolean - whether to use automatic calculation of the object width (cannot be enabled simultaneously with autoResizeY)
		true,                          -- autoResizeY
		95,                             -- 75.0 cutDistance: number (float) - distance (in meters) at which the control stops showing
		WIDGET_3D_BIND_POINT_HIGH,      -- Maximum height of the widget 
		1,
		1                               --maxSizeLimit: number (float) - coefficient of the maximum control size, similar to the minimum
	)

	object.AttachWidget3D(
		object_id,          -- Target object
		widgetControl3D,    -- 3D widget to attach
		ArrowMarker,        -- 2D widget to attach in 3D space
		0.18                --0.0    Height offset over the object
	)
end

--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------


function OnObjectChanged( params )
    -- Only check new units
    if not params.spawned then
        return
    end

    for _, object_id in pairs( params.spawned ) do
        -- Try to get the objects name
        local object_Name = tostring( userMods.FromWString( object.GetName( object_id ) ) )
        if not object_Name then
            goto continue
        end

        -- Check if object_Name is in the objects of interest list
        local matchFound = false
        for interest_name, localized_name in pairs( LocalizedTexts ) do
            -- Check if object_Name matches localized_name
            if object_Name == localized_name then
                matchFound = true
                LogToChatColor( "Notify2: Found " .. localized_name, "log_yellow" )

                -- Attach arrow
                AttachArrowToObject( object_id )
            end
        end
        -- Skip to next object_id
        if not matchFound then 
            goto continue
        end

        -- -- Get position if it is not a player
        -- local object_Position = object.GetPos( object_id )
        -- if not object_Position then
        --     LogToChatColor( "Could not get object position", "log_yellow" )
        --     goto continue
        -- end
        -- -- Get players position
        -- local avatar_Position = avatar.GetPos()
        -- if not avatar_Position then
        --     LogToChatColor( "Could not get avatar position", "log_yellow" )
        --     goto continue
        -- end
        -- Calculate distance and angle
        -- local xDiff = avatar_Position.posX - object_Position.posX
        -- local yDiff = avatar_Position.posY - object_Position.posY
        -- local distance = math.sqrt( ( yDiff * yDiff) + ( xDiff * xDiff ) )
        -- LogToChatColor( "Distance is " .. tostring( distance ), "log_yellow" )

        ::continue::
        -- goto the next object in the list
    end
end

function OnEventUnitsChanged( params )
    --LogToChatColor( "OnEventUnitsChanged", "log_yellow" )
    OnObjectChanged( params )
end

function OnEventDevicesChanged( params )
    --LogToChatColor( "OnEventDevicesChanged", "log_yellow" )
    OnObjectChanged( params )
end

-- function OnEventSecondTimer( params )
--     LogToChatColor( "OnEventSecondTimer", "log_yellow" )
-- end

--------------------------------------------------------------------------------
-- INITIALIZATION
--------------------------------------------------------------------------------

function Init()
    common.RegisterEventHandler( OnEventUnitsChanged, "EVENT_UNITS_CHANGED" )
    common.RegisterEventHandler( OnEventDevicesChanged, "EVENT_DEVICES_CHANGED" )
    -- common.RegisterEventHandler( OnEventSecondTimer, "EVENT_SECOND_TIMER" )
    LocalizedTexts = Locales[common.GetLocalization()] or Locales["eng_eu"]
end

if avatar.IsExist() then
	Init()
else
	common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")
end