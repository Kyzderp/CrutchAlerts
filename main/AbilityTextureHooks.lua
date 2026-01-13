local Crutch = CrutchAlerts


---------------------------------------------------------------------
-- Hacks to immediately update texture
---------------------------------------------------------------------
local function GetSlotTrueBoundId(index, bar)
    local id = GetSlotBoundId(index, bar)
    local actionType = GetSlotType(index, bar)
    if (actionType ~= ACTION_TYPE_CRAFTED_ABILITY) then
        return id
    end
    return GetAbilityIdForCraftedAbilityId(id)
end

local function UpdateAllTextures()
    -- Basegame bar: only update it if it's the active bar, because switching
    -- to backbar will update it already. It does mean the basegame otherbar
    -- won't be updated, but that's ok for now
    for i = 3, 8 do
        local abilityId = GetSlotTrueBoundId(i, GetActiveHotbarCategory())
        local button = ZO_ActionBar_GetButton(i)
        if (button and abilityId ~= 0) then
            button.icon:SetTexture(GetAbilityIcon(abilityId))
        end

    end

    -- FAB: Update the inactive bar hackily too
    if (FancyActionBar and FancyActionBar.GetActionButton) then
        local otherBar = (GetActiveHotbarCategory() == HOTBAR_CATEGORY_PRIMARY) and HOTBAR_CATEGORY_BACKUP or HOTBAR_CATEGORY_PRIMARY
        for i = 3, 8 do
            local otherBarAbilityId = GetSlotTrueBoundId(i, otherBar)
            -- 20 offset gets the inactive bar's slot
            local button = FancyActionBar.GetActionButton(i + 20)
            if (button) then
                button.icon:SetTexture(GetAbilityIcon(otherBarAbilityId))
            end
        end
    end
end


---------------------------------------------------------------------
-- Registration for texture replacements
---------------------------------------------------------------------
local abilitiesToSpoof = {}

function Crutch.SpoofAbilityTexture(abilityId, texture)
    abilitiesToSpoof[abilityId] = texture
    UpdateAllTextures()
end
-- /script CrutchAlerts.SpoofAbilityTexture(193398, "CrutchAlerts/assets/poop.dds")

function Crutch.UnspoofAbilityTexture(abilityId)
    abilitiesToSpoof[abilityId] = nil
    UpdateAllTextures()
end


---------------------------------------------------------------------
-- Hooks
---------------------------------------------------------------------
-- Hook for base game action bar
local origGetSlotTexture
local function MyGetSlotTexture(actionSlotIndex, hotbarCategory)
    local abilityId = GetSlotBoundId(actionSlotIndex, hotbarCategory)

    local texture = abilitiesToSpoof[abilityId]
    if (texture) then
        return texture
    end

    return origGetSlotTexture(actionSlotIndex, hotbarCategory)
end

-- Hook for addons or whatever
local origGetAbilityIcon = GetAbilityIcon
local function MyGetAbilityIcon(abilityId)
    local texture = abilitiesToSpoof[abilityId]
    if (texture) then
        return texture
    end

    return origGetAbilityIcon(abilityId)
end

function Crutch.InitializeAbilityTextureHooks()
    origGetSlotTexture = GetSlotTexture
    GetSlotTexture = MyGetSlotTexture

    origGetAbilityIcon = GetAbilityIcon
    GetAbilityIcon = MyGetAbilityIcon
end
