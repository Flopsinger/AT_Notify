--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------

local timerMax = 300
local timer = timerMax

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------

--- Feed mounts that are running low on satiation (<30min)
--- @return nil
function FeedMounts()
    -- Check if the player even has mounts
    local mounts = mount.GetMounts()
    if not mounts then
        return
    end
    
    -- Iterate over all mounts
    for key, value in pairs( mounts ) do
        -- Try to get the mount info
        local mountInfo = mount.GetInfo( value )
        if not mountInfo then
            goto continue
        end

        -- Ignore all temporary mounts
        if not mountInfo.canBeFeeded then
            goto continue
        end

        -- Try to get remaining satiation time
        local remainingTime = mountInfo.satiationMs
        if not remainingTime then
            goto continue
        end

        -- Feed mount if remaining time is less than 30 mins (1800000 ms)
        if remainingTime < 1800000 then
            mount.Feed( value, 1 )
        end

        -- Continue with next mount if any of the previous checks failed
        ::continue::
    end
end


--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------

--- Execute FeedMounts every time timer is 0
--- @return nil
function OnEventSecondTimer()
    timer = timer - 1
    if timer > 0 then
        return
    end
    if timer <= 0 then
        timer = timerMax
        FeedMounts()
        return
    end
end


--------------------------------------------------------------------------------
-- INITIALIZATION
--------------------------------------------------------------------------------

function Init()
    common.RegisterEventHandler( OnEventSecondTimer, "EVENT_SECOND_TIMER" )
end

if avatar.IsExist() then
	Init()
else
	common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")
end