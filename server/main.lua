-- Variables globales
local JaksamCore = nil

-- Initialisation de JaksamCore
Citizen.CreateThread(function()
    while JaksamCore == nil do
        TriggerEvent('jaksam_core:getSharedObject', function(obj) JaksamCore = obj end)
        Citizen.Wait(0)
    end
end)

-- Fonction pour obtenir le joueur
local function GetPlayer(source)
    return JaksamCore.GetPlayerFromId(source)
end

-- Récupérer le solde bancaire d'un joueur
RegisterServerEvent('es_banque:getBalance')
AddEventHandler('es_banque:getBalance', function()
    local _source = source
    local xPlayer = GetPlayer(_source)

    if xPlayer then
        MySQL.Async.fetchScalar('SELECT bank FROM users WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        }, function(bank)
            local balance = bank or 0
            TriggerClientEvent('es_banque:updateBalance', _source, balance)
        end)
    end
end)

-- Déposer de l'argent
RegisterServerEvent('es_banque:deposit')
AddEventHandler('es_banque:deposit', function(amount)
    local _source = source
    local xPlayer = GetPlayer(_source)

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
    local playerMoney = xPlayer.getMoney()

    if playerMoney >= amount then
        -- Retirer l'argent liquide
        xPlayer.removeMoney(amount)

        -- Ajouter à la banque
        MySQL.Async.execute('UPDATE users SET bank = bank + @amount WHERE identifier = @identifier', {
            ['@amount'] = amount,
            ['@identifier'] = xPlayer.identifier
        }, function(rowsChanged)
            if rowsChanged > 0 then
                -- Récupérer le nouveau solde
                MySQL.Async.fetchScalar('SELECT bank FROM users WHERE identifier = @identifier', {
                    ['@identifier'] = xPlayer.identifier
                }, function(newBalance)
                    TriggerClientEvent('es_banque:updateBalance', _source, newBalance)
                    TriggerClientEvent('es_banque:notify', _source, 'Dépôt de $' .. amount .. ' effectué avec succès', 'success')

                    -- Log
                    print(('[es_banque] %s a déposé $%s'):format(xPlayer.identifier, amount))
                end)
            else
                -- Rembourser en cas d'erreur
                xPlayer.addMoney(amount)
                TriggerClientEvent('es_banque:notify', _source, 'Erreur lors du dépôt', 'error')
            end
        end)
    else
        TriggerClientEvent('es_banque:notify', _source, 'Vous n\'avez pas assez d\'argent liquide', 'error')
    end
end)

-- Retirer de l'argent
RegisterServerEvent('es_banque:withdraw')
AddEventHandler('es_banque:withdraw', function(amount)
    local _source = source
    local xPlayer = GetPlayer(_source)

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
    MySQL.Async.fetchScalar('SELECT bank FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(bank)
        local bankBalance = bank or 0

        if bankBalance >= amount then
            -- Retirer de la banque
            MySQL.Async.execute('UPDATE users SET bank = bank - @amount WHERE identifier = @identifier', {
                ['@amount'] = amount,
                ['@identifier'] = xPlayer.identifier
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    -- Ajouter l'argent liquide
                    xPlayer.addMoney(amount)

                    -- Récupérer le nouveau solde
                    MySQL.Async.fetchScalar('SELECT bank FROM users WHERE identifier = @identifier', {
                        ['@identifier'] = xPlayer.identifier
                    }, function(newBalance)
                        TriggerClientEvent('es_banque:updateBalance', _source, newBalance)
                        TriggerClientEvent('es_banque:notify', _source, 'Retrait de $' .. amount .. ' effectué avec succès', 'success')

                        -- Log
                        print(('[es_banque] %s a retiré $%s'):format(xPlayer.identifier, amount))
                    end)
                else
                    TriggerClientEvent('es_banque:notify', _source, 'Erreur lors du retrait', 'error')
                end
            end)
        else
            TriggerClientEvent('es_banque:notify', _source, 'Solde bancaire insuffisant', 'error')
        end
    end)
end)

-- Transférer de l'argent à un autre joueur
RegisterServerEvent('es_banque:transfer')
AddEventHandler('es_banque:transfer', function(target, amount)
    local _source = source
    local xPlayer = GetPlayer(_source)
    local xTarget = GetPlayer(target)

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

    if xPlayer.identifier == xTarget.identifier then
        TriggerClientEvent('es_banque:notify', _source, 'Vous ne pouvez pas vous transférer de l\'argent à vous-même', 'error')
        return
    end

    if amount > Config.MaxAmount then
        TriggerClientEvent('es_banque:notify', _source, 'Montant trop élevé', 'error')
        return
    end

    -- Vérifier le solde bancaire
    MySQL.Async.fetchScalar('SELECT bank FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(bank)
        local bankBalance = bank or 0

        if bankBalance >= amount then
            -- Retirer de la banque de l'expéditeur
            MySQL.Async.execute('UPDATE users SET bank = bank - @amount WHERE identifier = @identifier', {
                ['@amount'] = amount,
                ['@identifier'] = xPlayer.identifier
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    -- Ajouter à la banque du destinataire
                    MySQL.Async.execute('UPDATE users SET bank = bank + @amount WHERE identifier = @identifier', {
                        ['@amount'] = amount,
                        ['@identifier'] = xTarget.identifier
                    }, function(rowsChanged2)
                        if rowsChanged2 > 0 then
                            -- Récupérer les nouveaux soldes
                            MySQL.Async.fetchScalar('SELECT bank FROM users WHERE identifier = @identifier', {
                                ['@identifier'] = xPlayer.identifier
                            }, function(newBalance)
                                TriggerClientEvent('es_banque:updateBalance', _source, newBalance)
                                TriggerClientEvent('es_banque:notify', _source, 'Transfert de $' .. amount .. ' effectué avec succès', 'success')
                                TriggerClientEvent('es_banque:notify', target, 'Vous avez reçu $' .. amount, 'success')

                                -- Mettre à jour le solde du destinataire
                                MySQL.Async.fetchScalar('SELECT bank FROM users WHERE identifier = @identifier', {
                                    ['@identifier'] = xTarget.identifier
                                }, function(targetBalance)
                                    TriggerClientEvent('es_banque:updateBalance', target, targetBalance)
                                end)

                                -- Log
                                print(('[es_banque] %s a transféré $%s à %s'):format(xPlayer.identifier, amount, xTarget.identifier))
                            end)
                        else
                            -- Rembourser en cas d'erreur
                            MySQL.Async.execute('UPDATE users SET bank = bank + @amount WHERE identifier = @identifier', {
                                ['@amount'] = amount,
                                ['@identifier'] = xPlayer.identifier
                            })
                            TriggerClientEvent('es_banque:notify', _source, 'Erreur lors du transfert', 'error')
                        end
                    end)
                else
                    TriggerClientEvent('es_banque:notify', _source, 'Erreur lors du transfert', 'error')
                end
            end)
        else
            TriggerClientEvent('es_banque:notify', _source, 'Solde bancaire insuffisant', 'error')
        end
    end)
end)

-- Obtenir la liste des transactions
RegisterServerEvent('es_banque:getTransactions')
AddEventHandler('es_banque:getTransactions', function()
    local _source = source
    local xPlayer = GetPlayer(_source)

    if xPlayer then
        MySQL.Async.fetchAll('SELECT * FROM bank_transactions WHERE identifier = @identifier ORDER BY date DESC LIMIT 10', {
            ['@identifier'] = xPlayer.identifier
        }, function(transactions)
            TriggerClientEvent('es_banque:sendTransactions', _source, transactions)
        end)
    end
end)

-- Commande pour donner de l'argent (admin)
RegisterCommand('givebank', function(source, args, rawCommand)
    local xPlayer = GetPlayer(source)

    if not xPlayer then return end

    -- Vérifier les permissions (à adapter selon votre système de permissions)
    if xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin' then
        local target = tonumber(args[1])
        local amount = tonumber(args[2])

        if target and amount then
            local xTarget = GetPlayer(target)

            if xTarget then
                MySQL.Async.execute('UPDATE users SET bank = bank + @amount WHERE identifier = @identifier', {
                    ['@amount'] = amount,
                    ['@identifier'] = xTarget.identifier
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        TriggerClientEvent('es_banque:notify', source, 'Vous avez donné $' .. amount .. ' à ' .. GetPlayerName(target), 'success')
                        TriggerClientEvent('es_banque:notify', target, 'Un administrateur vous a donné $' .. amount, 'success')

                        -- Mettre à jour le solde
                        MySQL.Async.fetchScalar('SELECT bank FROM users WHERE identifier = @identifier', {
                            ['@identifier'] = xTarget.identifier
                        }, function(newBalance)
                            TriggerClientEvent('es_banque:updateBalance', target, newBalance)
                        end)
                    end
                end)
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
