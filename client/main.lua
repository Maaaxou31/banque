-- Variables
ESX = exports['es_extended']:getSharedObject()
local bankBalance = 0
local isInMenu = false
local currentAccount = nil

-- Fonction pour afficher les notifications
function ShowNotification(message, type)
    if type == 'success' then
        ESX.ShowNotification('~g~' .. message)
    elseif type == 'error' then
        ESX.ShowNotification('~r~' .. message)
    else
        ESX.ShowNotification(message)
    end
end

-- Recevoir les notifications du serveur
RegisterNetEvent('es_banque:notify')
AddEventHandler('es_banque:notify', function(message, type)
    ShowNotification(message, type)
end)

-- Mettre à jour le solde
RegisterNetEvent('es_banque:updateBalance')
AddEventHandler('es_banque:updateBalance', function(balance)
    bankBalance = balance
    if isInMenu then
        SendNUIMessage({
            action = 'updateBalance',
            balance = balance
        })
    end
end)

-- Ouvrir le menu bancaire
function OpenBankMenu()
    if not isInMenu then
        isInMenu = true
        SetNuiFocus(true, true)
        TriggerServerEvent('es_banque:getBalance')

        SendNUIMessage({
            action = 'openBank',
            balance = bankBalance
        })
    end
end

-- Fermer le menu bancaire
function CloseBankMenu()
    if isInMenu then
        isInMenu = false
        SetNuiFocus(false, false)

        SendNUIMessage({
            action = 'closeBank'
        })
    end
end

-- Callback NUI pour fermer le menu
RegisterNUICallback('close', function(data, cb)
    CloseBankMenu()
    cb('ok')
end)

-- Callback NUI pour déposer
RegisterNUICallback('deposit', function(data, cb)
    local amount = tonumber(data.amount)
    if amount and amount > 0 then
        TriggerServerEvent('es_banque:deposit', amount)
    else
        ShowNotification('Montant invalide', 'error')
    end
    cb('ok')
end)

-- Callback NUI pour retirer
RegisterNUICallback('withdraw', function(data, cb)
    local amount = tonumber(data.amount)
    if amount and amount > 0 then
        TriggerServerEvent('es_banque:withdraw', amount)
    else
        ShowNotification('Montant invalide', 'error')
    end
    cb('ok')
end)

-- Callback NUI pour transférer
RegisterNUICallback('transfer', function(data, cb)
    local target = tonumber(data.target)
    local amount = tonumber(data.amount)

    if target and amount and amount > 0 then
        TriggerServerEvent('es_banque:transfer', target, amount)
    else
        ShowNotification('Données invalides', 'error')
    end
    cb('ok')
end)

-- Créer les blips pour les banques
Citizen.CreateThread(function()
    if Config.EnableBankBlips then
        for k, v in pairs(Config.BankLocations) do
            local blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(blip, Config.BankBlip.Sprite)
            SetBlipDisplay(blip, Config.BankBlip.Display)
            SetBlipScale(blip, Config.BankBlip.Scale)
            SetBlipColour(blip, Config.BankBlip.Color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.name)
            EndTextCommandSetBlipName(blip)
        end
    end

    if Config.EnableATMBlips then
        for k, v in pairs(Config.ATMLocations) do
            local blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(blip, Config.ATMBlip.Sprite)
            SetBlipDisplay(blip, Config.ATMBlip.Display)
            SetBlipScale(blip, Config.ATMBlip.Scale)
            SetBlipColour(blip, Config.ATMBlip.Color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Distributeur")
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- Thread pour afficher les markers et gérer l'interaction
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isNearBank = false

        -- Vérifier les banques
        for k, v in pairs(Config.BankLocations) do
            local distance = #(playerCoords - vector3(v.x, v.y, v.z))

            if distance < Config.DrawDistance then
                isNearBank = true

                if Config.ShowMarkers then
                    DrawMarker(
                        Config.MarkerType,
                        v.x, v.y, v.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                        Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100,
                        false, true, 2, false, nil, nil, false
                    )
                end

                if distance < Config.InteractDistance then
                    DrawText3D(v.x, v.y, v.z, '[~g~E~w~] Accéder à la banque')

                    if IsControlJustReleased(0, 38) then -- E
                        OpenBankMenu()
                    end
                end
            end
        end

        -- Vérifier les ATMs
        for k, v in pairs(Config.ATMLocations) do
            local distance = #(playerCoords - vector3(v.x, v.y, v.z))

            if distance < Config.DrawDistance then
                isNearBank = true

                if Config.ShowMarkers then
                    DrawMarker(
                        Config.MarkerType,
                        v.x, v.y, v.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                        Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100,
                        false, true, 2, false, nil, nil, false
                    )
                end

                if distance < Config.InteractDistance then
                    DrawText3D(v.x, v.y, v.z, '[~g~E~w~] Accéder au distributeur')

                    if IsControlJustReleased(0, 38) then -- E
                        OpenBankMenu()
                    end
                end
            end
        end

        if not isNearBank then
            Citizen.Wait(500)
        end
    end
end)

-- Fonction pour afficher du texte 3D
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Commande pour ouvrir le menu (alternative)
RegisterCommand('bank', function()
    OpenBankMenu()
end, false)

-- Fermer le menu avec ESC
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isInMenu then
            if IsControlJustReleased(0, 322) then -- ESC
                CloseBankMenu()
            end
        else
            Citizen.Wait(500)
        end
    end
end)

print('^2[es_banque] Client chargé avec succès^0')
