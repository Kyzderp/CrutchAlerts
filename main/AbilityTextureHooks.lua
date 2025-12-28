local Crutch = CrutchAlerts


---------------------------------------------------------------------
-- Registration for texture replacements
---------------------------------------------------------------------
local abilitiesToSpoof = {}

function Crutch.SpoofAbilityTexture(abilityId, texture)
    abilitiesToSpoof[abilityId] = texture
    -- TODO: immediately update bar
end
-- /script CrutchAlerts.SpoofAbilityTexture(193398, "CrutchAlerts/assets/poop.dds")

function Crutch.UnspoofAbilityTexture(abilityId)
    abilitiesToSpoof[abilityId] = nil
    -- TODO: immediately update bar
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

    -- TODO: do we need this?
    -- -- If the poops expire while on the other bar, FAB doesn't update
    -- if (FancyActionBar and FancyActionBar.GetActionButton) then
    --     EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "PoopfistHotbar", EVENT_HOTBAR_SLOT_UPDATED, function(_, actionSlotIndex, hotbarCategory)
    --         if (hotbarCategory == GetActiveHotbarCategory()) then
    --             return
    --         end

    --         local abilityId = GetSlotBoundId(actionSlotIndex, hotbarCategory)
    --         if (GetSlotBoundId(actionSlotIndex, hotbarCategory) ~= POOPSTOMP_ID) then
    --             return
    --         end

    --         -- This is a bit hacky, but FAB doesn't expose any functions for refreshing the icon
    --         -- 20 offset gets the inactive bar's slot
    --         local button = FancyActionBar.GetActionButton(actionSlotIndex + 20)
    --         if (button) then
    --             button.icon:SetTexture(POOPSTOMP_PATH)
    --         end
    --     end)
    -- end
end
