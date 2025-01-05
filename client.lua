local stopSignModel = GetHashKey("prop_sign_road_01a") 
local hasStopSignInHand = false 
local stopSignObject


function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = GetGameplayCamCoords()
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
end

CreateThread(function()
    while true do
        Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local closestStopSign
        local closestDistance = 2.0

        
        for obj in EnumerateObjects() do
            if GetEntityModel(obj) == stopSignModel then
                local objCoords = GetEntityCoords(obj)
                local distance = #(playerCoords - objCoords)

                if distance < closestDistance then
                    closestDistance = distance
                    closestStopSign = obj
                end
            end
        end

        
        if closestStopSign and not hasStopSignInHand then
            local objCoords = GetEntityCoords(closestStopSign)
            DrawText3D(objCoords.x, objCoords.y, objCoords.z + 1.0, "[E] Stoppschild entfernen")

            if IsControlJustPressed(1, 51) then -- E-Taste
                TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
                Wait(5000) 
                ClearPedTasks(PlayerPedId())
                SetEntityAsMissionEntity(closestStopSign, true, true)
                DeleteObject(closestStopSign)

                
                RequestAnimDict("anim@heists@box_carry@")
                RequestModel(stopSignModel)
                while not HasAnimDictLoaded("anim@heists@box_carry@") or not HasModelLoaded(stopSignModel) do
                    Wait(100)
                end

                
                TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 8.0, -8.0, -1, 50, 0, false, false, false)

                
                stopSignObject = CreateObject(stopSignModel, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
                AttachEntityToEntity(stopSignObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.1, 0.0, 0.0, 0.0, 180.0, 0.0, true, true, false, true, 1, true)

                
                hasStopSignInHand = true
            end
        end

        
        if hasStopSignInHand and IsControlJustPressed(1, 73) then -- X-Taste
            ClearPedTasks(PlayerPedId())
            DetachEntity(stopSignObject, true, true)
            DeleteObject(stopSignObject)
            hasStopSignInHand = false
            stopSignObject = nil
        end
    end
end)

function EnumerateObjects()
    return coroutine.wrap(function()
        local handle, object = FindFirstObject()
        if not IsEntityAnObject(object) then
            EndFindObject(handle)
            return
        end

        local success
        repeat
            coroutine.yield(object)
            success, object = FindNextObject(handle)
        until not success

        EndFindObject(handle)
    end)
end



