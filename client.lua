local isPlacing = false
local previewEntity = nil
local placedProps = {}

local function hasRequiredJob(jobs)
    if not jobs then return true end
    local playerJob = ESX.PlayerData.job.name
    for _, job in pairs(jobs) do
        if playerJob == job then
            return true
        end
    end
    return false
end

local function loadSavedProps()
    if placedProps and #placedProps > 0 then
        for _, entity in pairs(placedProps) do
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
    end

    placedProps = {}

    local props = lib.callback.await('snaily-prop:server:getProps', false) or {}
    for _, propData in ipairs(props) do
        if propData and propData.model and propData.coords then
            local hash = Config.LoadModel(propData.model)
            local object = CreateObject(hash, propData.coords.x, propData.coords.y, propData.coords.z, true, false, false)
            if DoesEntityExist(object) then
                if propData.rotation then
                    local rotation = type(propData.rotation) == 'vector3' and propData.rotation or
                        vector3(propData.rotation.x or 0.0, propData.rotation.y or 0.0, propData.rotation.z or 0.0)
                    SetEntityRotation(object, rotation.x, rotation.y, rotation.z, 2, true)
                end
                PlaceObjectOnGroundProperly(object)
                table.insert(placedProps, object)
            end
        end
    end
end

local function createPreviewProp(model)
    if previewEntity and DoesEntityExist(previewEntity) then
        DeleteEntity(previewEntity)
    end

    local hash = Config.LoadModel(model)
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)

    previewEntity = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityCollision(previewEntity, false, false)
    SetEntityAlpha(previewEntity, 150, false)
    PlaceObjectOnGroundProperly(previewEntity)

    return previewEntity
end

local function handlePropPlacement(propData)
    if isPlacing then return end

    if not hasRequiredJob(propData.jobs) then
        Config.Notification('Nie masz uprawnień do używania tego przedmiotu')
        return
    end

    local count = exports.ox_inventory:Search('count', propData.item)
    if count < 1 then
        Config.Notification('Nie posiadasz tego przedmiotu')
        return
    end

    isPlacing = true
    local preview = createPreviewProp(propData.model)

    if not preview then
        Config.Notification('Wystąpił błąd podczas tworzenia podglądu')
        isPlacing = false
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
                SetEntityCoords(preview, coords + GetEntityForwardVector(ped) * Config.MovementSpeed)
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

                local success = lib.callback.await('snaily-prop:server:removeItem', false, propData.item)
                if success then
                    if Config.ProgressBar({
                            duration = propData.progressBar.duration,
                            label = propData.progressBar.label,
                            dict = propData.animation.dict,
                            clip = propData.animation.clip
                        }) then
                        local saved = lib.callback.await('snaily-prop:server:saveProp', false, {
                            model = propData.model,
                            coords = finalCoords,
                            rotation = finalRotation,
                            jobs = propData.jobs
                        })

                        if saved then
                            Config.Notification('Przedmiot postawiony pomyślnie')
                        else
                            lib.callback.await('snaily-prop:server:addItem', false, propData.item)
                            Config.Notification('Nie udało się postawić przedmiotu')
                        end
                    else
                        lib.callback.await('snaily-prop:server:addItem', false, propData.item)
                        Config.Notification('Anulowano stawianie')
                    end
                else
                    Config.Notification('Nie posiadasz już tego przedmiotu')
                end

                DeleteEntity(preview)
                isPlacing = false
                break
            elseif IsControlJustPressed(0, 177) then
                DeleteEntity(preview)
                isPlacing = false
                Config.Notification('Anulowano stawianie')
                break
            end
        end
    end)
end

local function setupTargetSystem()
    local models = {}
    for _, prop in pairs(Config.Props) do
        table.insert(models, GetHashKey(prop.model))
    end

    exports.ox_target:addModel(models, {
        {
            name = 'pickup_prop',
            icon = 'fa-solid fa-hand',
            label = 'Podnieś przedmiot',
            onSelect = function(data)
                local entity = data.entity
                if not DoesEntityExist(entity) then return end

                local model = GetEntityModel(entity)
                local entityCoords = GetEntityCoords(entity)
                local propIndex = nil
                local props = lib.callback.await('snaily-prop:server:getProps', false) or {}

                for index, prop in ipairs(props) do
                    if #(vector3(prop.coords.x, prop.coords.y, prop.coords.z) - entityCoords) < 0.1 then
                        propIndex = index
                        break
                    end
                end

                if not propIndex then
                    Config.Notification('Nie można znaleźć przedmiotu')
                    return
                end

                for _, prop in pairs(Config.Props) do
                    if GetHashKey(prop.model) == model then
                        if not hasRequiredJob(prop.jobs) then
                            Config.Notification('Nie masz uprawnień do podniesienia tego przedmiotu')
                            return
                        end

                        if Config.ProgressBar({
                                duration = prop.progressBar.duration,
                                label = 'Podnoszenie przedmiotu...',
                                dict = prop.animation.dict,
                                clip = prop.animation.clip
                            }) then
                            local success = lib.callback.await('snaily-prop:server:addItem', false, prop.item)
                            if success then
                                local removed = lib.callback.await('snaily-prop:server:removeProp', false, propIndex)
                                if removed then
                                    DeleteEntity(entity)
                                    Config.Notification('Przedmiot podniesiony')
                                else
                                    lib.callback.await('snaily-prop:server:removeItem', false, prop.item)
                                    Config.Notification('Nie udało się podnieść przedmiotu')
                                end
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
end

RegisterNetEvent('snaily-prop:client:updateProps', function(props)
    loadSavedProps()
end)

AddEventHandler('ox_inventory:usedItem', function(name, slot)
    for _, propData in pairs(Config.Props) do
        if name == propData.item then
            handlePropPlacement(propData)
            break
        end
    end
end)

RegisterNetEvent('esx:playerLoaded', function()
    loadSavedProps()
    setupTargetSystem()
end)

RegisterNetEvent('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        loadSavedProps()
        setupTargetSystem()
    end
end)
