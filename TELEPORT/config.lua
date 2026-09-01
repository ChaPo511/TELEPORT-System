TELEPORT = {}

TELEPORT.Debug = {
    enabled = false, 
    verbose = false 
}

TELEPORT.ELEVATORS = {
    CHApO = {
        floors = {
            {
                coords = vector4(-775.09, 312.35, 85.7, 357.71),
                icon = "house",
                id = "01",
                label = "Ground Floor",
                number = "01",
            },
            {
                coords = vector4(-781.92, 324.21, 176.8, 181.5),
                icon = "02",
                id = "02",
                label = "CHAPO",
                number = "02",
                passcode = "2003",
            },
        },
        id = "CHAPO",
        label = "CHAPO",
    },
}

TELEPORT.MarkerConfig = {
    type = 25,
    size = vector3(1.2, 1.2, 0.4),
    color = { r = 180, g = 30, b = 30, a = 150 },
    drawDistance = 20.0,
    interactDistance = 1.5
}

TELEPORT.LANGUAGE = "EN"
TELEPORT.TEXTS = {
    DE = {
        ELEVATOR = "Aufzug",
        CURRENT_FLOOR = "Aktuelles Stockwerk",
        MOVING_TO = "Fährt zu",
        SELECT_FLOOR = "Stockwerk auswählen",
        INTERACT_TEXT = "~r~E~s~ - Aufzug",
        FLOOR = "Stockwerk"
    },
    EN = {
        ELEVATOR = "Elevator",
        CURRENT_FLOOR = "Current Floor",
        MOVING_TO = "Moving to",
        SELECT_FLOOR = "Select Floor",
        INTERACT_TEXT = "~r~E~s~ - Elevator",
        FLOOR = "Floor"
    },
    ES = {
        ELEVATOR = "Ascensor",
        CURRENT_FLOOR = "Piso Actual",
        MOVING_TO = "Moviendo a",
        SELECT_FLOOR = "Seleccionar Piso",
        INTERACT_TEXT = "~r~E~s~ - Ascensor",
        FLOOR = "Piso"
    },
    FR = {
        ELEVATOR = "Ascenseur",
        CURRENT_FLOOR = "Étage Actuel",
        MOVING_TO = "En route vers",
        SELECT_FLOOR = "Sélectionner l'étage",
        INTERACT_TEXT = "~r~E~s~ - Ascenseur",
        FLOOR = "Étage"
    },
    AR = {
        ELEVATOR = "مصعد",
        CURRENT_FLOOR = "الطابق الحالي",
        MOVING_TO = "الانتقال إلى",
        SELECT_FLOOR = "اختر الطابق",
        INTERACT_TEXT = "~r~E~s~ - مصعد",
        FLOOR = "طابق"
    }
}

TELEPORT.SoundConfig = {
    enabled = true,
    soundName = "Fake_Arrival",
    soundSet = "Union_Depository_Elevator_Sounds", 
    volume = 0.5, 
    
    playOnTeleport = true,
    playOnOpenUI = false,
    playOnCloseUI = false, 
}

function DebugPrint(message, level)
    if not TELEPORT.Debug.enabled then return end
    
    if level == 2 and not TELEPORT.Debug.verbose then
        return
    end
    
    local prefix = "[^1TELEPORT-ELEVATOR^7]"
    if level == 2 then
        prefix = "[^1TELEPORT-ELEVATOR-DEBUG^7]"
    end
    
    print(prefix .. " " .. message)
end

function PlayElevatorSound()
    if not TELEPORT.SoundConfig.enabled then return end
    
    local soundConfig = TELEPORT.SoundConfig
    
    DebugPrint("Playing elevator sound: " .. soundConfig.soundName, 2)
    PlaySoundFrontend(-1, soundConfig.soundName, soundConfig.soundSet, false)
end

function PlayCustomElevatorSound(soundName, soundSet, volume)
    if not TELEPORT.SoundConfig.enabled then return end
    
    soundSet = soundSet or TELEPORT.SoundConfig.soundSet
    
    DebugPrint("Playing custom sound: " .. soundName, 2)
    PlaySoundFrontend(-1, soundName, soundSet, false)
end

function GetText(key)
    local lang = TELEPORT.LANGUAGE
    if TELEPORT.TEXTS[lang] and TELEPORT.TEXTS[lang][key] then
        return TELEPORT.TEXTS[lang][key]
    end
    return TELEPORT.TEXTS["EN"][key] or key
end

function SetFloorLabels()
    for _, elevator in pairs(TELEPORT.ELEVATORS) do
        for _, floor in ipairs(elevator.floors) do
            floor.label = GetText(floor.label)
        end
    end
end

