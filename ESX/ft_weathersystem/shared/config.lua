Config = {}

-- Time Configuration
Config.DynamicTime     = true
Config.TimeCycleSpeed = 48
Config.StartingTime       = {hour = 12, minute = 0}

-- Weather Configuration
Config.DynamicWeather   = true
Config.WeatherChangeTime = 60
Config.StartingWeather     = 'EXTRASUNNY'
Config.WeatherTypes = {
    { type = 'EXTRASUNNY', rarity = 'common' },
    { type = 'NEUTRAL', rarity = 'common' },
    { type = 'CLOUDS', rarity = 'common' },
    { type = 'CLEAR', rarity = 'common' },
    { type = 'OVERCAST', rarity = 'uncommon' },
    { type = 'FOGGY', rarity = 'uncommon' },
    { type = 'SMOG', rarity = 'uncommon' },
    { type = 'CLEARING', rarity = 'uncommon' },
    { type = 'RAIN', rarity = 'rare' },
    { type = 'SNOW', rarity = 'rare' },
    { type = 'HALLOWEEN', rarity = 'rare' },
    { type = 'XMAS', rarity = 'rare' },
    { type = 'SNOWLIGHT', rarity = 'rare' },
    { type = 'BLIZZARD', rarity = 'rare' },
    { type = 'THUNDER', rarity = 'rare' },
}
