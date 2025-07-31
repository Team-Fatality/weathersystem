local ESX = exports['es_extended']:getSharedObject()

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
    TriggerClientEvent('ft_weather:setWeather', -1, weatherType)
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
    
    TriggerClientEvent('ft_weather:setTime', -1, hour, minute)
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
                    TriggerClientEvent('ft_weather:setTime', -1, newHour, newMinute)
                end
            end
        end
    end
end)

RegisterNetEvent('ft_weather:setweather', function(weatherType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        local success = SetWeather(weatherType)
        if success then
            xPlayer.showNotification('Weather changed to: ' .. weatherType)
        else
            xPlayer.showNotification('Invalid weather type.')
        end
    end
end)

RegisterNetEvent('ft_weather:settime', function(hour, minute)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        SetTime(hour, minute, true)
        xPlayer.showNotification(('Time changed to: %02d:%02d'):format(hour, minute))
    end
end)

RegisterNetEvent('ft_weather:toggledynamictime', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        DynamicTime = not DynamicTime
        local stateText = DynamicTime and 'unfrozen' or 'frozen'
        xPlayer.showNotification('Time is now ' .. stateText)
    end
end)

RegisterNetEvent('ft_weather:toggledynamicweather', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        DynamicWeather = not DynamicWeather
        xPlayer.showNotification('Dynamic weather: '..(DynamicWeather and 'ENABLED' or 'DISABLED'))
    end
end)

RegisterNetEvent('ft_weather:setweatherinterval', function(minutes)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        if minutes and minutes > 0 then
            WeatherChangeTime = minutes
            xPlayer.showNotification(('Weather change interval set to: %d minutes'):format(minutes))
        end
    end
end)

RegisterNetEvent('ft_weather:settimeinterval', function(speed)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    time = 1440 / (tonumber(speed) * 60)

    if xPlayer then
        if speed and speed > 0 then
            timeStep = time
            xPlayer.showNotification(('Time speed set to: %.2f'):format(speed))
        end
    end
end)

AddEventHandler('playerJoining', function()
    local playerId = source
    TriggerClientEvent('ft_weather:setWeather', playerId, CurrentWeather)
    TriggerClientEvent('ft_weather:setTime', playerId, CurrentTime.hour, CurrentTime.minute)
end)

RegisterServerEvent('ft_weather:requestSync')
AddEventHandler('ft_weather:requestSync', function()
    local playerId = source
    TriggerClientEvent('ft_weather:setWeather', playerId, CurrentWeather)
    TriggerClientEvent('ft_weather:setTime', playerId, CurrentTime.hour, CurrentTime.minute)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    totalMinutes = Config.StartingTime.hour * 60 + Config.StartingTime.minute
    
    SetWeather(Config.StartingWeather)
    SetTime(Config.StartingTime.hour, Config.StartingTime.minute)

end)

ESX.RegisterCommand('setweather', 'admin', function(xPlayer, args, showError)
    local weather = args.weather and string.upper(args.weather) or nil
    if weather then
        if SetWeather(weather) then
            xPlayer.showNotification('Weather changed to: '..weather)
        else
            xPlayer.showNotification('Invalid weather type!')
        end
    else
        xPlayer.showNotification('Usage: /setweather [weathertype]')
    end
end, true, {help = 'Change server weather', validate = true, arguments = {
    {name = 'weather', help = 'Weather type to set', type = 'string'}
}})

ESX.RegisterCommand('settime', 'admin', function(xPlayer, args, showError)
    local hour = tonumber(args.hour)
    local minute = tonumber(args.minute) or 0
    
    if hour then
        if SetTime(hour, minute, true) then 
            xPlayer.showNotification(('Time changed to: %02d:%02d'):format(hour, minute))
        end
    else
        xPlayer.showNotification('Usage: /settime [hour] [minute]')
    end
end, true, {help = 'Change server time', validate = true, arguments = {
    {name = 'hour', help = 'Hour (0-23)', type = 'number'},
    {name = 'minute', help = 'Minute (0-59)', type = 'number', optional = true}
}})

ESX.RegisterCommand('toggledynamicweather', 'admin', function(xPlayer, args, showError)
    DynamicWeather = not DynamicWeather
    xPlayer.showNotification('Dynamic weather: '..(DynamicWeather and 'ENABLED' or 'DISABLED'))
end, true, {help = 'Toggle automatic weather changes'})

ESX.RegisterCommand('toggledynamictime', 'admin', function(xPlayer, args, showError)
    DynamicTime = not DynamicTime
    xPlayer.showNotification('Dynamic time: '..(DynamicTime and 'ENABLED' or 'DISABLED'))
end, true, {help = 'Toggle automatic time progression'})

ESX.RegisterCommand('setweatherinterval', 'admin', function(xPlayer, args, showError)
    local minutes = tonumber(args.minutes)
    if minutes and minutes > 0 then
        WeatherChangeTime = minutes
        xPlayer.showNotification(('Weather change interval set to: %d minutes'):format(minutes))
    else
        xPlayer.showNotification('Usage: /setweatherinterval [minutes]')
    end
end, true, {help = 'Set minutes between weather changes', validate = true, arguments = {
    {name = 'minutes', help = 'Minutes between weather changes', type = 'number'}
}})

ESX.RegisterCommand('settimespeed', 'admin', function(xPlayer, args, showError)
    local speed = tonumber(args.speed)
    if speed and speed > 0 then
        TimeSpeed = speed
        xPlayer.showNotification(('Time speed set to: %.2f'):format(speed))
    else
        xPlayer.showNotification('Usage: /settimespeed [speed] (e.g., 0.5 for half realtime)')
    end
end, true, {help = 'Set time progression speed', validate = true, arguments = {
    {name = 'speed', help = 'Time speed multiplier', type = 'number'}
}})

ESX.RegisterCommand('freezetime', 'admin', function(xPlayer, args, showError)
    DynamicTime = not DynamicTime
    local stateText = DynamicTime and 'unfrozen' or 'frozen'
    xPlayer.showNotification('Time is now ' .. stateText)
end, true, {
    help = 'Toggle time freeze/unfreeze',
    validate = true
})
