
Locales = {}
local lang = 'en'

Locales["en"] = {
    intraction = {
        Starter = "[E] Open Starter Pack",
    },
    target = {
        Starter = "Open Starter Pack",
    },
    notify = {
        Starter = "Starter Pack",
        already = "You have already claimed the starter pack.",
        claimed = "You have claimed the starter pack. Enjoy playing!",
    },
}
















function L(key)
    local value = Locales[lang]
    for k in key:gmatch("[^.]+") do
        value = value[k]

        if not value then
            print("Missing locale for: " .. key)
            return ""
        end
    end
    return value
end