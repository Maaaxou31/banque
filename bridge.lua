-- Bridge pour la compatibilité multi-framework
-- Supporte : ESX (es_extended) et jaksam_core

Framework = {}
Framework.Name = nil
Framework.Object = nil

-- Détection automatique du framework
Citizen.CreateThread(function()
    -- Essayer de charger ESX
    local success, esx = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if success and esx then
        Framework.Name = 'esx'
        Framework.Object = esx
        print('^2[es_banque] Framework détecté: ESX (es_extended)^0')
        return
    end

    -- Essayer de charger jaksam_core
    local jaksamLoaded = false
    TriggerEvent('jaksam_core:getSharedObject', function(obj)
        if obj then
            Framework.Name = 'jaksam'
            Framework.Object = obj
            jaksamLoaded = true
            print('^2[es_banque] Framework détecté: jaksam_core^0')
        end
    end)

    -- Attendre que jaksam_core se charge
    while not jaksamLoaded and Framework.Name == nil do
        Citizen.Wait(100)
    end

    if Framework.Name == nil then
        print('^1[es_banque] ERREUR: Aucun framework détecté (ESX ou jaksam_core)^0')
    end
end)

-- Fonctions wrapper universelles
if IsDuplicityVersion() then
    -- Code serveur
    function Framework.GetPlayer(source)
        while Framework.Object == nil do
            Citizen.Wait(100)
        end

        if Framework.Name == 'esx' then
            return Framework.Object.GetPlayerFromId(source)
        elseif Framework.Name == 'jaksam' then
            return Framework.Object.GetPlayerFromId(source)
        end
        return nil
    end

    function Framework.GetPlayerMoney(xPlayer)
        if Framework.Name == 'esx' then
            return xPlayer.getMoney()
        elseif Framework.Name == 'jaksam' then
            return xPlayer.getMoney()
        end
        return 0
    end

    function Framework.AddPlayerMoney(xPlayer, amount)
        if Framework.Name == 'esx' then
            xPlayer.addMoney(amount)
        elseif Framework.Name == 'jaksam' then
            xPlayer.addMoney(amount)
        end
    end

    function Framework.RemovePlayerMoney(xPlayer, amount)
        if Framework.Name == 'esx' then
            xPlayer.removeMoney(amount)
        elseif Framework.Name == 'jaksam' then
            xPlayer.removeMoney(amount)
        end
    end

    function Framework.GetBankMoney(xPlayer)
        if Framework.Name == 'esx' then
            local account = xPlayer.getAccount('bank')
            return account and account.money or 0
        elseif Framework.Name == 'jaksam' then
            local account = xPlayer.getAccount('bank')
            return account and account.money or 0
        end
        return 0
    end

    function Framework.AddBankMoney(xPlayer, amount)
        if Framework.Name == 'esx' then
            xPlayer.addAccountMoney('bank', amount)
        elseif Framework.Name == 'jaksam' then
            xPlayer.addAccountMoney('bank', amount)
        end
    end

    function Framework.RemoveBankMoney(xPlayer, amount)
        if Framework.Name == 'esx' then
            xPlayer.removeAccountMoney('bank', amount)
        elseif Framework.Name == 'jaksam' then
            xPlayer.removeAccountMoney('bank', amount)
        end
    end

    function Framework.GetPlayerGroup(xPlayer)
        if Framework.Name == 'esx' then
            return xPlayer.getGroup()
        elseif Framework.Name == 'jaksam' then
            return xPlayer.getGroup()
        end
        return 'user'
    end

    function Framework.GetPlayerIdentifier(xPlayer)
        return xPlayer.identifier
    end
else
    -- Code client
    function Framework.ShowNotification(message)
        while Framework.Object == nil do
            Citizen.Wait(100)
        end

        if Framework.Name == 'esx' then
            Framework.Object.ShowNotification(message)
        elseif Framework.Name == 'jaksam' then
            Framework.Object.ShowNotification(message)
        end
    end
end
