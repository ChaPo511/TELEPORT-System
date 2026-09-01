Citizen.CreateThread(function()
    while not TELEPORT do
        Wait(100)
    end

    print("[^1TELEPORT-ELEVATOR^7] Client script started - Fixed By Fivevault")

    StartElevatorSystem()
end)

function StartElevatorSystem()
    local DynamicElevators = {}
    local ConfigLoaded = false
    local uiOpen = false
    local currentElevator = nil
    local currentElevatorId = nil
    local currentFloorId = nil
    local elevatorMarkers = {}
    local closestMarker = nil
    local hasNearbyMarker = false

    local function DebugPrint(message, level)
        if not TELEPORT then
            return
        end

        if not TELEPORT.Debug then
            return
        end

        if not TELEPORT.Debug.enabled then
            return
        end

        if level == 2 and not TELEPORT.Debug.verbose then
            return
        end

        local prefix = "[^1TELEPORT-ELEVATOR^7]"

        if level == 2 then
            prefix = "[^1TELEPORT-ELEVATOR-DEBUG^7]"
        end

        print(prefix .. " " .. message)
    end

    local function PlayElevatorSound()
        if not TELEPORT.SoundConfig then
            return
        end

        if not TELEPORT.SoundConfig.enabled then
            return
        end

        DebugPrint(
            "Playing elevator sound: " ..
            TELEPORT.SoundConfig.soundName,
            2
        )

        PlaySoundFrontend(
            -1,
            TELEPORT.SoundConfig.soundName,
            TELEPORT.SoundConfig.soundSet,
            false
        )
    end

    local function CacheElevatorMarkers()
        elevatorMarkers = {}

        if not DynamicElevators then
            DebugPrint(
                "No elevators configured",
                1
            )

            return
        end

        for _, elevator in pairs(DynamicElevators) do
            if elevator.floors then

                for _, floor in ipairs(elevator.floors) do

                    elevatorMarkers[#elevatorMarkers + 1] = {
                        pos = vector3(
                            floor.coords.x,
                            floor.coords.y,
                            floor.coords.z
                        ),

                        coords = floor.coords,

                        elevatorId = elevator.id,

                        floorId = floor.id
                    }
                end
            end
        end

        DebugPrint(
            "Cached " ..
            #elevatorMarkers ..
            " elevator markers",
            1
        )
    end

    local function OpenElevatorUI(elevatorId, currentFloor)
        if uiOpen then
            return
        end

        DebugPrint(
            "Opening UI for elevator: " ..
            tostring(elevatorId),
            2
        )

        if TELEPORT.SoundConfig then
            if TELEPORT.SoundConfig.enabled then
                if TELEPORT.SoundConfig.playOnOpenUI then
                    PlayElevatorSound()
                end
            end
        end

        currentElevator = nil

        if DynamicElevators then

            for _, elevator in pairs(DynamicElevators) do

                if elevator.id == elevatorId then
                    currentElevator = elevator
                    break
                end
            end
        end

        if not currentElevator then
            DebugPrint(
                "Elevator not found: " ..
                tostring(elevatorId),
                2
            )

            return
        end

        currentElevatorId = elevatorId
        currentFloorId = currentFloor
        uiOpen = true

        SendNUIMessage({
            action = "show"
        })

        Wait(50)

        local sanitizedElevator = {
            id = currentElevator.id,
            label = currentElevator.label,
            floors = {}
        }
        
        if currentElevator.floors then
            for _, floor in ipairs(currentElevator.floors) do
                table.insert(sanitizedElevator.floors, {
                    id = floor.id,
                    number = floor.number,
                    label = floor.label,
                    icon = floor.icon
                })
            end
        end

        local sanitizedConfig = {
            LANGUAGE = TELEPORT.LANGUAGE,
            TEXTS = TELEPORT.TEXTS
        }

        SendNUIMessage({
            action = "show",
            elevator = sanitizedElevator,
            currentFloor = currentFloor,
            config = sanitizedConfig
        })

        SetNuiFocus(true, true)
    end

    local function CloseElevatorUI()
        if not uiOpen then
            return
        end

        DebugPrint(
            "Closing elevator UI",
            2
        )

        if TELEPORT.SoundConfig then
            if TELEPORT.SoundConfig.enabled then
                if TELEPORT.SoundConfig.playOnCloseUI then
                    PlayElevatorSound()
                end
            end
        end

        SendNUIMessage({
            action = "hide"
        })

        SetNuiFocus(false, false)

        uiOpen = false
        currentElevator = nil
        currentElevatorId = nil
        currentFloorId = nil
    end

    local function GetCurrentFloor(elevatorId)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local elevator = nil

        if DynamicElevators then

            for _, configuredElevator in pairs(
                DynamicElevators
            ) do

                if configuredElevator.id == elevatorId then
                    elevator = configuredElevator
                    break
                end
            end
        end

        if not elevator then
            DebugPrint(
                "Elevator not found for floor detection: " ..
                tostring(elevatorId),
                2
            )

            return nil
        end

        local closestFloorId = nil
        local closestDistance = 9999.0

        if elevator.floors then

            for _, floor in ipairs(elevator.floors) do

                local floorCoords = vector3(
                    floor.coords.x,
                    floor.coords.y,
                    floor.coords.z
                )

                local distance = #(playerCoords - floorCoords)

                if closestDistance > distance then
                    closestDistance = distance
                    closestFloorId = floor.id
                end
            end
        end

        DebugPrint(
            "Found current floor: " ..
            tostring(closestFloorId) ..
            " (distance: " ..
            string.format("%.2f", closestDistance) ..
            ")",
            2
        )

        return closestFloorId
    end

    local function TeleportToFloor(coords)
        local playerPed = PlayerPedId()

        DebugPrint(
            "Teleporting player to floor",
            2
        )

        if TELEPORT.SoundConfig then
            if TELEPORT.SoundConfig.enabled then
                if TELEPORT.SoundConfig.playOnTeleport then
                    PlayElevatorSound()
                end
            end
        end

        DoScreenFadeOut(500)

        while not IsScreenFadedOut() do
            Wait(10)
        end

        SetEntityCoords(
            playerPed,
            coords.x,
            coords.y,
            coords.z,
            false,
            false,
            false,
            false
        )

        SetEntityHeading(
            playerPed,
            coords.w or 0.0
        )

        Wait(1200)

        DoScreenFadeIn(500)
    end

    local function Draw3DText(x, y, z, text)
        if not text or text == "" then
            return
        end

        local onScreen, screenX, screenY = World3dToScreen2d(
            x,
            y,
            z
        )

        if not onScreen then
            return
        end

        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextCentre(true)
        SetTextColour(
            255,
            255,
            255,
            215
        )

        SetTextEntry("STRING")
        AddTextComponentString(tostring(text))

        DrawText(
            screenX,
            screenY
        )

        local textLength = string.len(
            tostring(text)
        )

        local backgroundWidth =
            textLength / 370

        DrawRect(
            screenX,
            screenY + 0.0125,
            0.015 + backgroundWidth,
            0.03,
            0,
            0,
            0,
            80
        )
    end

    CreateThread(function()
        CacheElevatorMarkers()

        while true do

            if uiOpen then
                Wait(1000)

            else
                local playerCoords =
                    GetEntityCoords(PlayerPedId())

                local nearestMarker = nil
                local nearestDistance = 9999.0

                local drawDistance = 20.0

                if TELEPORT.MarkerConfig then
                    if TELEPORT.MarkerConfig.drawDistance then
                        drawDistance =
                            TELEPORT.MarkerConfig.drawDistance
                    end
                end

                nearestDistance =
                    drawDistance + 0.01

                local foundMarker = false

                for _, marker in ipairs(elevatorMarkers) do

                    local distance =
                        #(playerCoords - marker.pos)

                    if nearestDistance > distance then
                        nearestDistance = distance
                        nearestMarker = marker
                        foundMarker = true
                    end
                end

                if foundMarker then

                    if closestMarker then
                        if closestMarker.elevatorId ==
                            nearestMarker.elevatorId then

                            if closestMarker.floorId ==
                                nearestMarker.floorId then

                            end
                        end
                    end

                    DebugPrint(
                        "Found new closest marker: " ..
                        nearestMarker.elevatorId ..
                        "/" ..
                        nearestMarker.floorId ..
                        " (distance: " ..
                        string.format(
                            "%.2f",
                            nearestDistance
                        ) ..
                        ")",
                        2
                    )

                    closestMarker = nearestMarker
                    hasNearbyMarker = true

                    Wait(250)

                else

                    if hasNearbyMarker then
                        DebugPrint(
                            "No markers nearby",
                            2
                        )
                    end

                    closestMarker = nil
                    hasNearbyMarker = false

                    Wait(1000)
                end
            end
        end
    end)

    CreateThread(function()

        while true do

            if uiOpen
                or not hasNearbyMarker
                or not closestMarker then

                Wait(500)

            else
                local playerCoords =
                    GetEntityCoords(PlayerPedId())

                local distance =
                    #(playerCoords - closestMarker.pos)

                local markerConfig =
                    TELEPORT.MarkerConfig or {}

                local drawDistance =
                    markerConfig.drawDistance or 20.0

                local markerType =
                    markerConfig.type or 25

                local markerSize =
                    markerConfig.size or vector3(
                        1.2,
                        1.2,
                        0.4
                    )

                local markerColor =
                    markerConfig.color or {
                        r = 180,
                        g = 30,
                        b = 30,
                        a = 150
                    }

                local interactDistance =
                    markerConfig.interactDistance or 1.5

                if distance < drawDistance then

                    DrawMarker(
                        markerType,

                        closestMarker.pos.x,
                        closestMarker.pos.y,
                        closestMarker.pos.z - 1.0,

                        0.0,
                        0.0,
                        0.0,

                        0.0,
                        0.0,
                        0.0,

                        markerSize.x,
                        markerSize.y,
                        markerSize.z,

                        markerColor.r,
                        markerColor.g,
                        markerColor.b,
                        markerColor.a,

                        false,
                        false,
                        2,
                        false
                    )

                    if distance < interactDistance then

                        local interactionText =
                            "~r~E~s~ - Elevator"

                        if TELEPORT.TEXTS then

                            local language =
                                TELEPORT.LANGUAGE
                                or "EN"

                            local languageTexts =
                                TELEPORT.TEXTS[language]

                            if languageTexts then

                                if languageTexts.INTERACT_TEXT then
                                    interactionText =
                                        languageTexts.INTERACT_TEXT
                                end

                            else

                                if TELEPORT.TEXTS.EN then

                                    if TELEPORT.TEXTS.EN.INTERACT_TEXT then
                                        interactionText =
                                            TELEPORT.TEXTS.EN.INTERACT_TEXT
                                    end
                                end
                            end
                        end

                        Draw3DText(
                            closestMarker.pos.x,
                            closestMarker.pos.y,
                            closestMarker.pos.z + 0.25,
                            interactionText
                        )

                        if IsControlJustReleased(0, 38) then

                            local currentFloor =
                                GetCurrentFloor(
                                    closestMarker.elevatorId
                                )

                            OpenElevatorUI(
                                closestMarker.elevatorId,
                                currentFloor
                            )
                        end
                    end
                end

                if distance < 10.0 then
                    Wait(5)
                else
                    Wait(10)
                end
            end
        end
    end)

    RegisterNUICallback(
        "selectFloor",
        function(data, cb)
            if not currentElevator then
                cb({ success = false })
                DebugPrint("No elevator data for floor selection", 2)
                return
            end

            DebugPrint("Selected floor: " .. tostring(data.floor), 2)

            local targetFloor = nil
            if currentElevator.floors then
                for _, floor in ipairs(currentElevator.floors) do
                    if floor.id == data.floor then
                        targetFloor = floor
                        break
                    end
                end
            end

            if not targetFloor then
                CloseElevatorUI()
                cb({ success = false })
                return
            end

            if targetFloor.passcode and targetFloor.passcode ~= "" then
                if data.passcode == tostring(targetFloor.passcode) then
                    TeleportToFloor(targetFloor.coords)
                    CloseElevatorUI()
                    cb({ success = true })
                else
                    SetNotificationTextEntry("STRING")
                    AddTextComponentString("~r~Incorrect Passcode!")
                    DrawNotification(false, false)
                    
                    -- We can let NUI know it failed if we want, but for now we just return false
                    -- The UI will clear itself after 2 seconds anyway based on JS logic.
                    cb({ success = false })
                end
                return
            end

            TeleportToFloor(targetFloor.coords)
            CloseElevatorUI()

            cb({ success = true })
        end
    )

    RegisterNUICallback(
        "close",
        function(data, cb)

            CloseElevatorUI()

            cb({
                success = true
            })
        end
    )


        RegisterNetEvent("TELEPORT:KortzEstate:SyncConfig", function(elevators)
        DynamicElevators = elevators
        ConfigLoaded = true
        CacheElevatorMarkers()
    end)

    RegisterNetEvent("TELEPORT:KortzEstate:OpenAdminUI", function()
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openAdmin",
            elevators = DynamicElevators
        })
    end)

    RegisterCommand("tpmadmin", function()
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openAdmin",
            elevators = DynamicElevators
        })
    end, false)

    RegisterNUICallback("adminClose", function(data, cb)
        SetNuiFocus(false, false)
        cb({})
    end)

    RegisterNUICallback("adminSaveConfig", function(data, cb)
        TriggerServerEvent("TELEPORT:KortzEstate:SaveConfig", data.elevators)
        cb({})
    end)

    CreateThread(function()
        TriggerServerEvent("TELEPORT:KortzEstate:GetConfig")
        
        local timeout = 0
        while not ConfigLoaded and timeout < 30 do 
            Wait(100)
            timeout = timeout + 1
        end
        
        if not ConfigLoaded then
            DynamicElevators = TELEPORT.ELEVATORS
            ConfigLoaded = true
            CacheElevatorMarkers()
            print("[^1TELEPORT-ELEVATOR^7] WARNING: Server failed to send dynamic config. Using config.lua fallback!")
        end
    end)

    RegisterNUICallback("adminCaptureCoords", function(data, cb)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        cb({
            x = coords.x,
            y = coords.y,
            z = coords.z,
            w = heading
        })
    end)
end
