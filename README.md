# 🌦️ FiveM Weather System

NUI based fully configurable and performance-friendly dynamic weather and time synchronization system for FiveM. Built to work with **ESX** and **QBCore**, and designed for immersive RP environments.

---
## 📸 ShowCase

---

## 🔧 Features

- ☀️ Dynamic weather cycling  
- ⏱️ Real-time or fast-forwarded time progression  
- 🧊 Freeze/unfreeze time  
- 🔁 Automatic weather sync  
- ✅ Admin menu and commands to control everything

---

## 🛠️ Admin Commands

| Command                      | Description                        |
|------------------------------|------------------------------------|
| `/setweather [type]`         | Force change the weather           |
| `/settime [h] [m]`           | Set time manually                  |
| `/freezetime`                | Toggle freeze/unfreeze time        |
| `/settimespeed [n]`          | Change time cycle duration         |
| `/setweatherinterval [min]`  | Change weather interval            |
| `/toggledynamicweather`      | Enable/disable weather cycling     |

---

## 📦 Exports (Client-side)

```lua
exports['ft_weathersync']:ChangeWeather("RAIN")
exports['ft_weathersync']:ChangeTime(18, 30)
exports['ft_weathersync']:ToggleFreezeTime()

