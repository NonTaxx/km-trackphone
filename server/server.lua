local QBCore = exports['qb-core']:GetCoreObject()

-- Configs

local function Notify(src, message, notifytype, time)
    if Config.NotificationType == "qb" then
        TriggerClientEvent('QBCore:Notify', src, message, notifytype)
    elseif Config.NotificationType == "okok" then
        TriggerClientEvent('okokNotify:Alert', src, Config.NotifyTitle, message, time, notifytype)
    elseif Config.NotificationType == "ox" then
        TriggerClientEvent('ox_lib:notify', src, { title = Config.NotifyTitle, description = message, type = notifytype })
    else
        print("There is an error with Config.NotificationType!")
    end
end


-- Functions

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end


-- Events

RegisterServerEvent("km-tracknumber:searchnumber")
AddEventHandler("km-tracknumber:searchnumber", function(number)
    local src = source

    local response = MySQL.query.await('SELECT `owner` FROM `phone_phones` WHERE `phone_number` = ?', { number })

    if #response > 0 then
        local ownerValue = response[1].owner
        local Player = QBCore.Functions.GetPlayerByCitizenId(ownerValue)

        if Player then
            if Player.PlayerData.source == src then
                Notify(src, _L("cant_track_your_own"), 'error', 5000)
            else
                local hasItem = exports.ox_inventory:GetItemCount(Player.PlayerData.source, 'phone')

                if hasItem > 0 then
                    if table.contains(Config.BlacklistedJobs, Player.PlayerData.job.name) or table.contains(Config.BlacklistedGangs, Player.PlayerData.gang.name) then
                        Notify(src, _L("encrypted_signal"), 'error', 5000)
                    else
                        if Config.UseAirplane then
                            local airplaneModeResult = MySQL.query.await('SELECT `settings` FROM `phone_phones` WHERE `owner` = ?', { ownerValue })

                            if airplaneModeResult and #airplaneModeResult > 0 then
                                local settingsJson = json.decode(airplaneModeResult[1].settings)

                                if settingsJson and settingsJson.airplaneMode ~= nil then
                                    local airplaneModeValue = settingsJson.airplaneMode

                                    if airplaneModeValue then
                                        Notify(src, _L("in_airplane"), 'error', 5000)
                                    else
                                        local playerId = Player.PlayerData.source
                                        Notify(src, _L("tracking_started"), 'success', 5000)
                                        TriggerClientEvent('km-tracknumber:setbliponperson', src, playerId, number)
                                    end
                                else
                                    print(_L("database_error"))
                                end
                            else
                                print(_L("database_error"))
                            end
                        else
                            local playerId = Player.PlayerData.source
                            Notify(src, _L("tracking_started"), 'success', 5000)
                            TriggerClientEvent('km-tracknumber:setbliponperson', src, playerId, number)
                        end
                    end
                else
                    Notify(src, _L("dont_have_phone"), 'error', 5000)
                end
            end
        else
            Notify(src, _L("not_in_server"), 'error', 5000)
        end
    else
        Notify(src, _L("incorrect_phone_number"), 'error', 5000)
    end
end)


-- Callbacks

lib.callback.register("km-tracknumber:getcoords", function(_, playerId)
    local pedid = GetPlayerPed(playerId)
    local blipcoords = GetEntityCoords(pedid)

    return blipcoords
end)

lib.callback.register("km-tracknumber:checkairplane", function(_, playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    local airplaneModeResult = MySQL.query.await('SELECT `settings` FROM `phone_phones` WHERE `owner` = ?', { Player.PlayerData.citizenid })

    if airplaneModeResult and #airplaneModeResult > 0 then
        local settingsJson = json.decode(airplaneModeResult[1].settings)

        if settingsJson and settingsJson.airplaneMode ~= nil then
            local airplaneModeValue = settingsJson.airplaneMode
            return airplaneModeValue
        else
            print(_L("database_error"))
        end
    else
        print(_L("database_error"))
    end
end)

lib.callback.register("km-tracknumber:checkphoneitem", function(_, playerId)
    local hasItem = exports.ox_inventory:GetItemCount(playerId, 'phone')
    if hasItem > 0 then
        return true
    else
        return false
    end
end)

lib.callback.register("km-tracknumber:getheading", function(_, playerId)
    local pedid = GetPlayerPed(playerId)
    local entityheading = GetEntityHeading(pedid)

    return entityheading
end)

-- Threads

Citizen.CreateThread(function()
    if Config.ItemUse then
        QBCore.Functions.CreateUseableItem(Config.ItemName, function(source)
            lib.callback.await('km-tracknumber:useitem', source)
        end)
    end
end)