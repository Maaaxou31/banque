Config = {}

-- Configuration générale
Config.MaxAmount = 999999999 -- Montant maximum par transaction
Config.MinAmount = 1 -- Montant minimum par transaction

-- Positions des ATM (distributeurs automatiques)
Config.ATMLocations = {
    {x = 147.44, y = -1035.69, z = 29.34},
    {x = -350.8, y = -49.57, z = 49.04},
    {x = -1205.02, y = -324.29, z = 37.87},
    {x = -2072.41, y = -316.95, z = 13.31},
    {x = -1091.5, y = 2708.66, z = 18.95},
    {x = 1171.98, y = 2702.55, z = 38.17},
    {x = 1653.4, y = 4850.3, z = 41.99},
    {x = -302.3, y = -829.31, z = 32.41},
    {x = 5.23, y = -919.83, z = 29.55}
}

-- Positions des banques
Config.BankLocations = {
    {x = 149.46, y = -1040.54, z = 29.37, name = "Fleeca Bank"},
    {x = -1212.98, y = -330.84, z = 37.78, name = "Fleeca Bank"},
    {x = -2962.71, y = 482.93, z = 15.70, name = "Fleeca Bank"},
    {x = -112.22, y = 6469.91, z = 31.63, name = "Blaine County Savings Bank"},
    {x = 314.16, y = -278.83, z = 54.17, name = "Pacific Standard Bank"},
    {x = -351.26, y = -49.99, z = 49.04, name = "Fleeca Bank"}
}

-- Distance d'interaction
Config.DrawDistance = 10.0
Config.InteractDistance = 2.0

-- Markers
Config.ShowMarkers = true
Config.MarkerType = 1
Config.MarkerSize = {x = 1.5, y = 1.5, z = 0.5}
Config.MarkerColor = {r = 0, g = 255, b = 0}

-- Blips sur la carte
Config.EnableBankBlips = true
Config.BankBlip = {
    Sprite = 108,
    Display = 4,
    Scale = 0.8,
    Color = 2
}

Config.EnableATMBlips = false
Config.ATMBlip = {
    Sprite = 277,
    Display = 4,
    Scale = 0.6,
    Color = 2
}
