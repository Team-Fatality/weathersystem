local currentWeather = nil
local currentTime = nil
local lastWeatherSync = 0
local lastTimeSync = 0

RegisterNetEvent('ft_weather:setWeather')
AddEventHandler('ft_weather:setWeather', function(weatherType)
    if currentWeather == weatherType then return end
    
    ClearWeatherTypePersist()
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    
    SetWeatherTypeOverTime(weatherType, 15.0)
    currentWeather = weatherType
    lastWeatherSync = GetGameTimer()
    
    Citizen.CreateThread(function()
        Citizen.Wait(15000) 
        
        if currentWeather == weatherType then
            SetWeatherTypePersist(weatherType)
            SetWeatherTypeNowPersist(weatherType)
            SetOverrideWeather(weatherType)
        end
    end)
end)

RegisterNetEvent('ft_weather:setTime')
AddEventHandler('ft_weather:setTime', function(hour, minute)
    NetworkOverrideClockTime(hour, minute, 0)
    currentTime = {hour = hour, minute = minute}
    lastTimeSync = GetGameTimer()
end)

Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() do
        Citizen.Wait(100)
    end
    
    TriggerServerEvent('ft_weather:requestSync')
    
    while true do
        Citizen.Wait(30000) 
        
        if currentWeather and GetGameTimer() - lastWeatherSync > 60000 then
            SetWeatherTypePersist(currentWeather)
            SetWeatherTypeNowPersist(currentWeather)
            SetOverrideWeather(currentWeather)
            lastWeatherSync = GetGameTimer()
        end
        
        if currentTime and GetGameTimer() - lastTimeSync > 60000 then
            NetworkOverrideClockTime(currentTime.hour, currentTime.minute, 0)
            lastTimeSync = GetGameTimer()
        end
    end
end)

function ChangeWeather(weatherType)
    TriggerServerEvent('ft_weather:setweather', weatherType)
end

function ChangeTime(hour, minute)
    TriggerServerEvent('ft_weather:settime', hour, minute)
end

function ToggleFreezeTime()
    TriggerServerEvent('ft_weather:toggledynamictime')
end

exports('ChangeWeather', ChangeWeather)
exports('ChangeTime', ChangeTime)
exports('ToggleFreezeTime', ToggleFreezeTime)

local timeUpdateRunning = false

RegisterCommand("weathermenu", function()
    local hour = GetClockHours()
    local minute = GetClockMinutes()
    if minute ~= lastMinute then
        lastMinute = minute
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openWeather",
            hour = hour,
            minute = minute
        })
    end
    timeUpdateRunning = true
end, false)

CreateThread(function()
    local lastMinute = -1
    while true do
        Wait(5000)

        if timeUpdateRunning then
            local hour = GetClockHours()
            local minute = GetClockMinutes()

            if minute ~= lastMinute then
                lastMinute = minute
                SendNUIMessage({
                    action = "updateTime",
                    hour = hour,
                    minute = minute
                })
            end
        end
    end
end)

RegisterNUICallback("setWeather", function(data, cb)
    local weatherType = data.mode
    TriggerServerEvent('ft_weather:setweather', weatherType)
    cb({ status = "ok" })
end)

RegisterNUICallback("setTime", function(data, cb)
    local hour = data.hour
    local minute = data.minute
    TriggerServerEvent('ft_weather:settime', hour, minute)
    cb({ status = "ok" })
end)

RegisterNUICallback("freezeTime", function(data, cb)
    TriggerServerEvent('ft_weather:toggledynamictime')
    cb({ status = "ok" })
end)

RegisterNUICallback("dynamicweather", function(data, cb)
    TriggerServerEvent('ft_weather:toggledynamicweather')
    cb({ status = "ok" })
end)

RegisterNUICallback("dynamictime", function(data, cb)
    TriggerServerEvent('ft_weather:toggledynamictime')
    cb({ status = "ok" })
end)

RegisterNUICallback("setWeatherInterval", function(data, cb)
    local interval = data.interval
    TriggerServerEvent('ft_weather:setweatherinterval', interval)
    cb({ status = "ok" })
end)

RegisterNUICallback("setTimeSpeed", function(data, cb)
    local speed = data.speed
    TriggerServerEvent('ft_weather:settimeinterval', speed)
    cb({ status = "ok" })
end)

RegisterNUICallback("close", function(data, cb)
    timeUpdateRunning = false
    SetNuiFocus(false, false)
    cb({ status = "ok" })
end)
