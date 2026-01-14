local Crutch = CrutchAlerts


---------------------------------------------------------------------
-- Add overlay of warning icon onto action bar slots
---------------------------------------------------------------------
local abilitiesToOverlay = {}

local function GetSlotTrueBoundId(index, bar)
    local id = GetSlotBoundId(index, bar)
    local actionType = GetSlotType(index, bar)
    if (actionType ~= ACTION_TYPE_CRAFTED_ABILITY) then
        return id
    end
    return GetAbilityIdForCraftedAbilityId(id)
end
Crutch.GetSlotTrueBoundId = GetSlotTrueBoundId

-- The button CONTROL, not the action button
local function GetButton(actionSlotIndex)
    local button
    if (FancyActionBar and FancyActionBar.GetActionButton) then
        button = FancyActionBar.GetActionButton(actionSlotIndex)
    elseif (actionSlotIndex <= 8) then
        button = ZO_ActionBar_GetButton(actionSlotIndex)
    end
    if (button) then
        return button.slot
    end
end

local function GetOrCreateOverlay(actionSlotIndex)
    local button = GetButton(actionSlotIndex)
    if (not button) then return end

    local overlay = button:GetNamedChild("CrutchOverlay")
    if (overlay) then return overlay end

    Crutch.dbgOther("Creating slot " .. actionSlotIndex)
    overlay = WINDOW_MANAGER:CreateControl("$(parent)CrutchOverlay", button, CT_TEXTURE)
    overlay:SetTexture("/esoui/art/miscellaneous/eso_icon_warning.dds")
    overlay:SetAnchorFill()
    overlay:SetDrawLayer(DL_CONTROLS)
    overlay:SetColor(1, 0.5, 0, 0.6)

    return overlay
end

local function UpdateOverlay(actionSlotIndex, show)
    local button = GetButton(actionSlotIndex)
    if (not button) then return end

    if (not show and not button:GetNamedChild("CrutchOverlay")) then return end

    -- Only access overlay if turning it on, or if it already exists and needs to be turned off
    local overlay = GetOrCreateOverlay(actionSlotIndex)
    overlay:SetHidden(not show)
end

local function UpdateAllOverlays()
    for i = 3, 8 do
        local abilityId = GetSlotTrueBoundId(i, GetActiveHotbarCategory())
        UpdateOverlay(i, abilitiesToOverlay[abilityId] == true)
    end

    -- FAB: Update the inactive bar too
    if (FancyActionBar) then
        local otherBar = (GetActiveHotbarCategory() == HOTBAR_CATEGORY_PRIMARY) and HOTBAR_CATEGORY_BACKUP or HOTBAR_CATEGORY_PRIMARY
        for i = 3, 8 do
            local otherBarAbilityId = GetSlotTrueBoundId(i, otherBar)
            -- 20 offset gets the inactive bar's slot
            UpdateOverlay(i + 20, abilitiesToOverlay[otherBarAbilityId] == true)
        end
    end
end


---------------------------------------------------------------------
-- Registration for overlays
---------------------------------------------------------------------
function Crutch.SetAbilityOverlay(abilityId)
    abilitiesToOverlay[abilityId] = true
    UpdateAllOverlays()
end

function Crutch.RemoveAbilityOverlay(abilityId)
    abilitiesToOverlay[abilityId] = nil
    UpdateAllOverlays()
end


---------------------------------------------------------------------
---------------------------------------------------------------------
function Crutch.InitializeAbilityOverlay()
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AbilityOverlayHotbarsUpdated", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, UpdateAllOverlays)
    EVENT_MANAGER:RegisterForEvent(Crutch.name .. "AbilityOverlaySlotUpdated", EVENT_ACTION_SLOT_UPDATED, UpdateAllOverlays) -- TODO: only change 1?
end
