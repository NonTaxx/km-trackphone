local QBCore = exports['qb-core']:GetCoreObject()
local shownblips = true
local blipsremoved = true
local blip

-- Config

local function Notify(message, notifytype, time)
    if Config.NotificationType == "qb" then
        QBCore.Functions.Notify(message, notifytype)
    elseif Config.NotificationType == "okok" then
        exports['okokNotify']:Alert(Config.NotifyTitle, message, time, notifytype)
    elseif Config.NotificationType == "ox" then
        lib.notify({ title = Config.NotifyTitle, description = message, type = notifytype })
    else
        print("There is an error with Config.NotificationType!")
    end
end

if Config.UseCommand then
    RegisterCommand(Config.CommandName, function()
        if Config.OnlyWhitelistedJobs then
            local job = QBCore.Functions.GetPlayerData()
            if table.contains(Config.WhitelistedJobs, job.job.name) then
                lib.showContext('tracknumber')
            else
                Notify(_L("not_police"), 'error', 5000)
            end
        else
            lib.showContext('tracknumber')
        end
    end)
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


-- Main events

Citizen.CreateThread(function()
    lib.registerContext({
        id = 'tracknumber',
        title = _L("lib_menu_title"),
        options = {
            {
                title = _L("menu_seach"),
                icon = 'fa-solid fa-magnifying-glass',
                onSelect = function()
                    TriggerEvent('km-tracknumber:openinput')
                end
            },
            {
                title = _L("menu_stop_search"),
                icon = 'fa-solid fa-stop',
                onSelect = function()
                    if blipsremoved then
                        Notify(_L("not_tracking"), 'error', 5000)
                    else
                        TriggerEvent('km-tracknumber:removeblip')
                    end
                end
            },
        }
    })
end)

AddEventHandler("km-tracknumber:openinput", function()
    local input = lib.inputDialog(_L("input_menu_title"), {
        {type = 'input', label = _L("input_menu_description"), required = true, min = 4, max = 16},
    })

    if input then
        local number = tonumber(input[1])

        if number then
            TriggerServerEvent('km-tracknumber:searchnumber', number)
        else
            Notify(_L("only_numbers"), 'error', 5000)
        end
    end
end)

RegisterNetEvent("km-tracknumber:setbliponperson")
AddEventHandler("km-tracknumber:setbliponperson", function(playerId, number)
    while shownblips do
        Wait(Config.UpdateBlip)
        local phoneitem = lib.callback.await("km-tracknumber:checkphoneitem", false, playerId)
        if phoneitem then
            if Config.UseAirplane then
                local airplanemode = lib.callback.await("km-tracknumber:checkairplane", false, playerId)
                if airplanemode then
                    Notify(_L("tracking_stopped"), 'error', 5000)
                    TriggerEvent("km-tracknumber:removeblip")
                else
                    local blipcoords = lib.callback.await("km-tracknumber:getcoords", false, playerId)

                    if Config.BlipType == 'radius' then
                        RemoveBlip(blip)

                        blip = AddBlipForRadius(blipcoords, Config.BlipRadius)
                        SetBlipColour(blip, 1)
                        SetBlipAlpha(blip, 128)
                        blipsremoved = false
                    else
                        RemoveBlip(blip)

                        blip = AddBlipForCoord(blipcoords)
                        SetBlipSprite(blip, 480)
                        SetBlipScale(blip, 0.8)
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentSubstringPlayerName(number)
                        EndTextCommandSetBlipName(blip)
                        blipsremoved = false
                    end
                end
            else
                local blipcoords = lib.callback.await("km-tracknumber:getcoords", false, playerId)

                if Config.BlipType == 'radius' then
                    RemoveBlip(blip)

                    blip = AddBlipForRadius(blipcoords, Config.BlipRadius)
                    SetBlipColour(blip, 1)
                    SetBlipAlpha(blip, 128)
                    blipsremoved = false
                else
                    RemoveBlip(blip)

                    blip = AddBlipForCoord(blipcoords)
                    SetBlipSprite(blip, 480)
                    SetBlipScale(blip, 0.8)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentSubstringPlayerName(number)
                    EndTextCommandSetBlipName(blip)
                    blipsremoved = false
                end
            end
        else
            Notify(_L("tracking_stopped_nophone"), 'error', 5000)
            TriggerEvent("km-tracknumber:removeblip")
        end
    end
end)

AddEventHandler("km-tracknumber:removeblip", function()
    shownblips = false
    Wait(Config.UpdateBlip*2)
    RemoveBlip(blip)
    shownblips = true
    blipsremoved = true
end)

lib.callback.register('km-tracknumber:useitem', function()
    lib.showContext('tracknumber')  
end)