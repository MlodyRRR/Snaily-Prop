Config = {}

Config.MovementSpeed = 0.05
Config.RotationSpeed = 2.0

Config.Props = {
    ['barrier'] = {
        item = 'barrier',
        label = 'Barierka',
        model = 'prop_barrier_work05',
        animation = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        },
        progressBar = {
            duration = 2000,
            label = 'Stawianie barierki...'
        }
    },
    ['cone'] = {
        item = 'cone',
        label = 'Pachołek',
        model = 'prop_roadcone02a',
        animation = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        },
        progressBar = {
            duration = 2000,
            label = 'Stawianie pachołka...'
        }
    }
}

Config.LoadModel = function(model)
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    return hash
end

Config.LoadAnimDict = function(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
end

Config.GetVector = function(entity)
    local forward = GetEntityForwardVector(entity)
    return vector3(-forward.y, forward.x, 0.0)
end

Config.Notification = function(msg)
    lib.notify({
        title = 'System',
        description = msg,
        type = 'info'
    })
end

Config.ProgressBar = function(data)
    return lib.progressBar({
        duration = data.duration,
        label = data.label,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = data.dict,
            clip = data.clip
        }
    })
end
