
RegisterServerEvent('removeStopSign')
AddEventHandler('removeStopSign', function(stopSign)
    TriggerClientEvent('removeStopSign', -1, stopSign)
end)
