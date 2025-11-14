-- Récupérer le solde bancaire d'un joueur
RegisterServerEvent('es_banque:getBalance')
AddEventHandler('es_banque:getBalance', function()
    local _source = source
    local xPlayer = Framework.GetPlayer(_source)

    if xPlayer then
        local balance = Framework.GetBankMoney(xPlayer)
        TriggerClientEvent('es_banque:updateBalance', _source, balance)
    end
end)

-- Déposer de l'argent
RegisterServerEvent('es_banque:deposit')
AddEventHandler('es_banque:deposit', function(amount)
    local _source = source
    local xPlayer = Framework.GetPlayer(_source)

    if not xPlayer then return end

    amount = tonumber(amount)

    if not amount or amount <= 0 then
        TriggerClientEvent('es_banque:notify', _source, 'Montant invalide', 'error')
        return
    end

    if amount > Config.MaxAmount then
        TriggerClientEvent('es_banque:notify', _source, 'Montant trop élevé', 'error')
        return
    end

    -- Vérifier si le joueur a assez d'argent liquide
    local playerMoney = Framework.GetPlayerMoney(xPlayer)

    if playerMoney >= amount then
        -- Retirer l'argent liquide et ajouter à la banque
        Framework.RemovePlayerMoney(xPlayer, amount)
        Framework.AddBankMoney(xPlayer, amount)

        -- Récupérer le nouveau solde
        local newBalance = Framework.GetBankMoney(xPlayer)

        TriggerClientEvent('es_banque:updateBalance', _source, newBalance)
        TriggerClientEvent('es_banque:notify', _source, 'Dépôt de $' .. amount .. ' effectué avec succès', 'success')

        -- Log
        print(('[es_banque] %s a déposé $%s'):format(Framework.GetPlayerIdentifier(xPlayer), amount))
    else
        TriggerClientEvent('es_banque:notify', _source, 'Vous n\'avez pas assez d\'argent liquide', 'error')
    end
end)

-- Retirer de l'argent
RegisterServerEvent('es_banque:withdraw')
AddEventHandler('es_banque:withdraw', function(amount)
    local _source = source
    local xPlayer = Framework.GetPlayer(_source)

    if not xPlayer then return end

    amount = tonumber(amount)

    if not amount or amount <= 0 then
        TriggerClientEvent('es_banque:notify', _source, 'Montant invalide', 'error')
        return
    end

    if amount > Config.MaxAmount then
        TriggerClientEvent('es_banque:notify', _source, 'Montant trop élevé', 'error')
        return
    end

    -- Vérifier le solde bancaire
    local bankBalance = Framework.GetBankMoney(xPlayer)

    if bankBalance >= amount then
        -- Retirer de la banque et ajouter en liquide
        Framework.RemoveBankMoney(xPlayer, amount)
        Framework.AddPlayerMoney(xPlayer, amount)

        -- Récupérer le nouveau solde
        local newBalance = Framework.GetBankMoney(xPlayer)

        TriggerClientEvent('es_banque:updateBalance', _source, newBalance)
        TriggerClientEvent('es_banque:notify', _source, 'Retrait de $' .. amount .. ' effectué avec succès', 'success')

        -- Log
        print(('[es_banque] %s a retiré $%s'):format(Framework.GetPlayerIdentifier(xPlayer), amount))
    else
        TriggerClientEvent('es_banque:notify', _source, 'Solde bancaire insuffisant', 'error')
    end
end)

-- Transférer de l'argent à un autre joueur
RegisterServerEvent('es_banque:transfer')
AddEventHandler('es_banque:transfer', function(target, amount)
    local _source = source
    local xPlayer = Framework.GetPlayer(_source)
    local xTarget = Framework.GetPlayer(target)

    if not xPlayer then return end

    amount = tonumber(amount)

    if not amount or amount <= 0 then
        TriggerClientEvent('es_banque:notify', _source, 'Montant invalide', 'error')
        return
    end

    if not xTarget then
        TriggerClientEvent('es_banque:notify', _source, 'Joueur introuvable', 'error')
        return
    end

    if Framework.GetPlayerIdentifier(xPlayer) == Framework.GetPlayerIdentifier(xTarget) then
        TriggerClientEvent('es_banque:notify', _source, 'Vous ne pouvez pas vous transférer de l\'argent à vous-même', 'error')
        return
    end

    if amount > Config.MaxAmount then
        TriggerClientEvent('es_banque:notify', _source, 'Montant trop élevé', 'error')
        return
    end

    -- Vérifier le solde bancaire
    local bankBalance = Framework.GetBankMoney(xPlayer)

    if bankBalance >= amount then
        -- Retirer de la banque de l'expéditeur et ajouter à celle du destinataire
        Framework.RemoveBankMoney(xPlayer, amount)
        Framework.AddBankMoney(xTarget, amount)

        -- Récupérer les nouveaux soldes
        local newBalance = Framework.GetBankMoney(xPlayer)
        local targetBalance = Framework.GetBankMoney(xTarget)

        TriggerClientEvent('es_banque:updateBalance', _source, newBalance)
        TriggerClientEvent('es_banque:notify', _source, 'Transfert de $' .. amount .. ' effectué avec succès', 'success')

        TriggerClientEvent('es_banque:notify', target, 'Vous avez reçu $' .. amount, 'success')
        TriggerClientEvent('es_banque:updateBalance', target, targetBalance)

        -- Log
        print(('[es_banque] %s a transféré $%s à %s'):format(Framework.GetPlayerIdentifier(xPlayer), amount, Framework.GetPlayerIdentifier(xTarget)))
    else
        TriggerClientEvent('es_banque:notify', _source, 'Solde bancaire insuffisant', 'error')
    end
end)

-- Obtenir la liste des transactions
RegisterServerEvent('es_banque:getTransactions')
AddEventHandler('es_banque:getTransactions', function()
    local _source = source
    local xPlayer = Framework.GetPlayer(_source)

    if xPlayer then
        MySQL.Async.fetchAll('SELECT * FROM bank_transactions WHERE identifier = @identifier ORDER BY date DESC LIMIT 10', {
            ['@identifier'] = Framework.GetPlayerIdentifier(xPlayer)
        }, function(transactions)
            TriggerClientEvent('es_banque:sendTransactions', _source, transactions)
        end)
    end
end)

-- Commande pour donner de l'argent (admin)
RegisterCommand('givebank', function(source, args, rawCommand)
    local xPlayer = Framework.GetPlayer(source)

    if not xPlayer then return end

    -- Vérifier les permissions (à adapter selon votre système de permissions)
    local group = Framework.GetPlayerGroup(xPlayer)
    if group == 'admin' or group == 'superadmin' then
        local target = tonumber(args[1])
        local amount = tonumber(args[2])

        if target and amount then
            local xTarget = Framework.GetPlayer(target)

            if xTarget then
                Framework.AddBankMoney(xTarget, amount)

                local newBalance = Framework.GetBankMoney(xTarget)

                TriggerClientEvent('es_banque:notify', source, 'Vous avez donné $' .. amount .. ' à ' .. GetPlayerName(target), 'success')
                TriggerClientEvent('es_banque:notify', target, 'Un administrateur vous a donné $' .. amount, 'success')
                TriggerClientEvent('es_banque:updateBalance', target, newBalance)
            else
                TriggerClientEvent('es_banque:notify', source, 'Joueur introuvable', 'error')
            end
        else
            TriggerClientEvent('es_banque:notify', source, 'Usage: /givebank [id] [montant]', 'error')
        end
    else
        TriggerClientEvent('es_banque:notify', source, 'Vous n\'avez pas la permission', 'error')
    end
end, false)

-- Exporter les fonctions pour d'autres ressources
exports('GetBankBalance', function(identifier)
    local result = MySQL.Sync.fetchScalar('SELECT bank FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })
    return result or 0
end)

exports('AddBankMoney', function(identifier, amount)
    MySQL.Async.execute('UPDATE users SET bank = bank + @amount WHERE identifier = @identifier', {
        ['@amount'] = amount,
        ['@identifier'] = identifier
    })
end)

exports('RemoveBankMoney', function(identifier, amount)
    MySQL.Async.execute('UPDATE users SET bank = bank - @amount WHERE identifier = @identifier', {
        ['@amount'] = amount,
        ['@identifier'] = identifier
    })
end)

print('^2[es_banque] Système bancaire chargé avec succès^0')
