local QBCore = exports['qb-core']:GetCoreObject()

local DynamicTime = Config.DynamicTime
local TimeSpeed = Config.TimeCycleSpeed
local timeStep = 1440 / (TimeSpeed * 60)
local CurrentTime = Config.StartingTime

local DynamicWeather = Config.DynamicWeather
local WeatherChangeTime = Config.WeatherChangeTime
local CurrentWeather = Config.StartingWeather

local totalMinutes = CurrentTime.hour * 60 + CurrentTime.minute
local lastManualTimeChange = 0  

local rarityWeights = {
    common = 30,
    uncommon = 10,
    rare = 3
}

function SetWeather(weatherType)
    local valid = false
    for _, wtype in ipairs(Config.WeatherTypes) do
        if wtype.type == weatherType then
            valid = true
            break
        end
    end

    if not valid then
        return false
    end

    CurrentWeather = weatherType
    TriggerClientEvent('ft_qb_weather:setWeather', -1, weatherType)
    return true
end

function GetRandomWeather()
    local weightedList = {}
    local totalWeight = 0

    for _, weather in ipairs(Config.WeatherTypes) do
        local weight = rarityWeights[weather.rarity] or 1
        totalWeight = totalWeight + weight
        table.insert(weightedList, { type = weather.type, weight = weight })
    end

    local pick = math.random(1, totalWeight)
    local current = 0

    for _, weather in ipairs(weightedList) do
        current = current + weather.weight
        if pick <= current then
            return weather.type
        end
    end

    return 'CLEAR'
end

function SetTime(hour, minute, isManualChange)
    hour = math.floor(tonumber(hour))
    minute = tonumber(minute) and math.floor(tonumber(minute)) or 0
    
    if hour < 0 then hour = 0 end
    if hour > 23 then hour = 23 end
    if minute < 0 then minute = 0 end
    if minute > 59 then minute = 59 end
    
    CurrentTime = {hour = hour, minute = minute}
    
    totalMinutes = hour * 60 + minute
    
    if isManualChange then
        lastManualTimeChange = GetGameTimer()
    end
    
    TriggerClientEvent('ft_qb_weather:setTime', -1, hour, minute)
    return true
end

CreateThread(function()
    while true do
        Wait(WeatherChangeTime * 60000) 
        
        if DynamicWeather then
            local newWeather = GetRandomWeather()
            while newWeather == CurrentWeather do
                newWeather = GetRandomWeather() 
                Wait(0)
            end
            SetWeather(newWeather)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1000) 

        if DynamicTime then
            if GetGameTimer() - lastManualTimeChange > 5000 then
                totalMinutes = totalMinutes + timeStep

                if totalMinutes >= 1440 then
                    totalMinutes = totalMinutes - 1440
                end

                local newHour = math.floor(totalMinutes / 60)
                local newMinute = math.floor(totalMinutes % 60)

                if newHour ~= CurrentTime.hour or newMinute ~= CurrentTime.minute then
                    CurrentTime = { hour = newHour, minute = newMinute }
                    TriggerClientEvent('ft_qb_weather:setTime', -1, newHour, newMinute)
                end
            end
        end
    end
end)

RegisterNetEvent('ft_qb_weather:setweather', function(weatherType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        local success = SetWeather(weatherType)
        if success then
            TriggerClientEvent('QBCore:Notify', src, 'Weather changed to: ' .. weatherType, 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Invalid weather type.', 'error')
        end
    end
end)

RegisterNetEvent('ft_qb_weather:settime', function(hour, minute)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        SetTime(hour, minute, true)
        TriggerClientEvent('QBCore:Notify', src, ('Time changed to: %02d:%02d'):format(hour, minute), 'success')
    end
end)

RegisterNetEvent('ft_qb_weather:toggledynamictime', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        DynamicTime = not DynamicTime
        local stateText = DynamicTime and 'unfrozen' or 'frozen'
        TriggerClientEvent('QBCore:Notify', src, 'Time is now ' .. stateText, 'success')
    end
end)

RegisterNetEvent('ft_qb_weather:toggledynamicweather', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        DynamicWeather = not DynamicWeather
        TriggerClientEvent('QBCore:Notify', src, 'Dynamic weather: ' .. (DynamicWeather and 'ENABLED' or 'DISABLED'), 'success')
    end
end)

RegisterNetEvent('ft_qb_weather:setweatherinterval', function(minutes)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        if minutes and minutes > 0 then
            WeatherChangeTime = minutes
            TriggerClientEvent('QBCore:Notify', src, ('Weather change interval set to: %d minutes'):format(minutes), 'success')
        end
    end
end)

RegisterNetEvent('ft_qb_weather:settimeinterval', function(speed)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    time = 1440 / (tonumber(speed) * 60)

    if Player then
        if speed and speed > 0 then
            timeStep = time
            TriggerClientEvent('QBCore:Notify', src, ('Time speed set to: %.2f'):format(speed), 'success')
        end
    end
end)

AddEventHandler('playerJoining', function()
    local playerId = source
    TriggerClientEvent('ft_qb_weather:setWeather', playerId, CurrentWeather)
    TriggerClientEvent('ft_qb_weather:setTime', playerId, CurrentTime.hour, CurrentTime.minute)
end)

RegisterServerEvent('ft_qb_weather:requestSync')
AddEventHandler('ft_qb_weather:requestSync', function()
    local playerId = source
    TriggerClientEvent('ft_qb_weather:setWeather', playerId, CurrentWeather)
    TriggerClientEvent('ft_qb_weather:setTime', playerId, CurrentTime.hour, CurrentTime.minute)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    totalMinutes = Config.StartingTime.hour * 60 + Config.StartingTime.minute
    
    SetWeather(Config.StartingWeather)
    SetTime(Config.StartingTime.hour, Config.StartingTime.minute)

end)

QBCore.Commands.Add('setweather', 'Change server weather', {{name='weather', help='Weather type'}}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData.job.name == 'admin' then
        local weather = args[1] and string.upper(args[1])
        if SetWeather(weather) then
            TriggerClientEvent('QBCore:Notify', source, 'Weather changed to: ' .. weather, 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, 'Invalid weather type.', 'error')
        end
    end
end, 'admin')

QBCore.Commands.Add('settime', 'Change server time', {
    {name='hour', help='Hour (0-23)'},
    {name='minute', help='Minute (0-59)'}
}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData.job.name == 'admin' then
        local hour = tonumber(args[1])
        local minute = tonumber(args[2]) or 0
        if hour then
            SetTime(hour, minute, true)
            TriggerClientEvent('QBCore:Notify', source, ('Time changed to: %02d:%02d'):format(hour, minute), 'success')
        end
    end
end, 'admin')

QBCore.Commands.Add('toggledynamicweather', 'Toggle dynamic weather', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData.job.name == 'admin' then
        DynamicWeather = not DynamicWeather
        TriggerClientEvent('QBCore:Notify', source, 'Dynamic weather: ' .. (DynamicWeather and 'ENABLED' or 'DISABLED'), 'success')
    end
end, 'admin')

QBCore.Commands.Add('toggledynamictime', 'Toggle dynamic time', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData.job.name == 'admin' then
        DynamicTime = not DynamicTime
        TriggerClientEvent('QBCore:Notify', source, 'Dynamic time: ' .. (DynamicTime and 'ENABLED' or 'DISABLED'), 'success')
    end
end, 'admin')

QBCore.Commands.Add('setweatherinterval', 'Set weather change interval', {{name='minutes', help='Minutes'}}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local minutes = tonumber(args[1])
    if Player and Player.PlayerData.job.name == 'admin' and minutes then
        WeatherChangeTime = minutes
        TriggerClientEvent('QBCore:Notify', source, ('Weather change interval set to: %d minutes'):format(minutes), 'success')
    end
end, 'admin')

QBCore.Commands.Add('settimespeed', 'Set time speed multiplier', {{name='speed', help='Speed value'}}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    local speed = tonumber(args[1])
    if Player and Player.PlayerData.job.name == 'admin' and speed then
        timeStep = 1440 / (speed * 60)
        TriggerClientEvent('QBCore:Notify', source, ('Time speed set to: %.2f'):format(speed), 'success')
    end
end, 'admin')

QBCore.Commands.Add('freezetime', 'Toggle time freeze/unfreeze', {}, false, function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData.job.name == 'admin' then
        DynamicTime = not DynamicTime
        local stateText = DynamicTime and 'unfrozen' or 'frozen'
        TriggerClientEvent('QBCore:Notify', source, 'Time is now ' .. stateText, 'success')
    end
end, 'admin')
