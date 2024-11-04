local isPlacing = false
local previewEntity = nil

local models = {}
for _, prop in pairs(Config.Props) do
    table.insert(models, prop.model)
end

local function SpawnEntity(model)
    if previewEntity then DeleteEntity(previewEntity) end

    local hash = Config.LoadModel(model)
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)

    previewEntity = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityCollision(previewEntity, false, false)
    SetEntityAlpha(previewEntity, 150, false)
    PlaceObjectOnGroundProperly(previewEntity)

    return previewEntity
end

local function HandleEntity(propData)
    if isPlacing then return end
    isPlacing = true

    local preview = SpawnEntity(propData.model)
    if not preview then
        Config.Notification('Błąd podczas tworzenia podglądu')
        return
    end

    Config.Notification('Użyj strzałek do przesuwania, scroll do obracania. ENTER aby postawić, BACKSPACE aby anulować.')

    CreateThread(function()
        while isPlacing do
            Wait(0)
            local coords = GetEntityCoords(preview)
            local rotation = GetEntityRotation(preview)
            local ped = PlayerPedId()

            if IsControlPressed(0, 172) then
                SetEntityCoords(preview, coords +  GetEntityForwardVector(ped) * Config.MovementSpeed)
                PlaceObjectOnGroundProperly(preview)
            elseif IsControlPressed(0, 173) then
                SetEntityCoords(preview, coords - GetEntityForwardVector(ped) * Config.MovementSpeed)
                PlaceObjectOnGroundProperly(preview)
            elseif IsControlPressed(0, 175) then
                SetEntityCoords(preview, coords - Config.GetVector(ped) * Config.MovementSpeed)
                PlaceObjectOnGroundProperly(preview)
            elseif IsControlPressed(0, 174) then
                SetEntityCoords(preview, coords + Config.GetVector(ped) * Config.MovementSpeed)
                PlaceObjectOnGroundProperly(preview)
            end

            if IsControlPressed(0, 15) then
                SetEntityRotation(preview, rotation.x, rotation.y, rotation.z - Config.RotationSpeed)
            elseif IsControlPressed(0, 14) then
                SetEntityRotation(preview, rotation.x, rotation.y, rotation.z + Config.RotationSpeed)
            end

            if IsControlJustPressed(0, 18) then
                local finalCoords = GetEntityCoords(preview)
                local finalRotation = GetEntityRotation(preview)
                local canRemove = lib.callback.await('snaily-prop:server:removeItem', false, propData.item)

                if canRemove then
                    if Config.ProgressBar({
                        duration = propData.progressBar.duration,
                        label = propData.progressBar.label,
                        dict = propData.animation.dict,
                        clip = propData.animation.clip
                    }) then
                        local hash = Config.LoadModel(propData.model)
                        local object = CreateObject(hash, finalCoords.x, finalCoords.y, finalCoords.z, true, false, false)
                        SetEntityRotation(object, finalRotation)
                        PlaceObjectOnGroundProperly(object)

                        Config.Notification('Przedmiot postawiony pomyślnie')
                    else
                        lib.callback.await('snaily-prop:server:addItem', false, propData.item)
                        Config.Notification('Anulowano stawianie')
                    end
                else
                    Config.Notification('Nie masz już tego przedmiotu')
                end

                DeleteEntity(preview)
                isPlacing = false
                break
            end

            if IsControlJustPressed(0, 177) then
                DeleteEntity(preview)
                isPlacing = false
                Config.Notification('Anulowano stawianie')
                break
            end
        end
    end)
end

AddEventHandler('ox_inventory:usedItem', function(name, slot, metadata)
    for _, propData in pairs(Config.Props) do
        if name == propData.item then
            local hasItem = lib.callback.await('snaily-prop:server:checkItem', false, name)
            if hasItem then
                HandleEntity(propData)
            else
                Config.Notification('Nie masz już tego przedmiotu')
            end
            break
        end
    end
end)

exports.ox_target:addModel(models, {
    {
        name = 'pickup_prop',
        icon = 'fa-solid fa-hand',
        label = 'Podnieś przedmiot',
        onSelect = function(data)
            local entity = data.entity
            local model = GetEntityModel(entity)

            for _, prop in pairs(Config.Props) do
                if GetHashKey(prop.model) == model then
                    if Config.ProgressBar({
                        duration = prop.progressBar.duration,
                        label = 'Podnoszenie przedmiotu...',
                        dict = prop.animation.dict,
                        clip = prop.animation.clip
                    }) then
                        local success = lib.callback.await('snaily-prop:server:addItem', false, prop.item)
                        if success then
                            DeleteEntity(entity)
                            Config.Notification('Przedmiot podniesiony')
                        else
                            Config.Notification('Nie możesz podnieść więcej przedmiotów')
                        end
                    end
                    break
                end
            end
        end
    }
})
