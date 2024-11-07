local SavedProps = {}

local function tableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

CreateThread(function()
    local file = LoadResourceFile(GetCurrentResourceName(), 'snaily-propData.json')
    if file then
        SavedProps = json.decode(file) or {}
    else
        SavedProps = {}
        SaveResourceFile(GetCurrentResourceName(), 'snaily-propData.json', json.encode(SavedProps), -1)
    end
end)

local function SaveToFile()
    SaveResourceFile(GetCurrentResourceName(), 'snaily-propData.json', json.encode(SavedProps), -1)
end

lib.callback.register('snaily-prop:server:getProps', function(source)
    return SavedProps
end)

lib.callback.register('snaily-prop:server:saveProp', function(source, propData)
    local xPlayer = ESX.GetPlayerFromId(source)

    if propData.jobs and not tableContains(propData.jobs, xPlayer.job.name) then
        return false
    end

    table.insert(SavedProps, propData)
    SaveToFile()
    TriggerClientEvent('snaily-prop:client:updateProps', -1, SavedProps)
    return true
end)

lib.callback.register('snaily-prop:server:removeProp', function(source, index)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not SavedProps[index] then return false end

    if SavedProps[index].jobs and not tableContains(SavedProps[index].jobs, xPlayer.job.name) then
        return false
    end

    table.remove(SavedProps, index)
    SaveToFile()
    TriggerClientEvent('snaily-prop:client:updateProps', -1, SavedProps)
    return true
end)

lib.callback.register('snaily-prop:server:addItem', function(source, item)
    return exports.ox_inventory:AddItem(source, item, 1)
end)

lib.callback.register('snaily-prop:server:removeItem', function(source, item)
    return exports.ox_inventory:RemoveItem(source, item, 1)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SaveToFile()
    end
end)
