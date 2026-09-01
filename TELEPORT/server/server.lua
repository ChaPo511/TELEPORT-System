local DynamicElevators = {}

local function SanitizeVectors(elevators)
    local safe = {}
    for k, v in pairs(elevators) do
        local safeElevator = { id = v.id, label = v.label, floors = {} }
        if v.floors then
            for i, floor in ipairs(v.floors) do
                local coords = floor.coords
                local safeCoords = { x = 0, y = 0, z = 0, w = 0 }
                if type(coords) == "vector4" or type(coords) == "vector3" then
                    safeCoords.x = coords.x
                    safeCoords.y = coords.y
                    safeCoords.z = coords.z
                    if type(coords) == "vector4" then safeCoords.w = coords.w end
                elseif type(coords) == "table" then
                    safeCoords.x = coords.x or 0
                    safeCoords.y = coords.y or 0
                    safeCoords.z = coords.z or 0
                    safeCoords.w = coords.w or coords.heading or 0
                end
                
                safeElevator.floors[i] = {
                    id = floor.id,
                    number = floor.number,
                    label = floor.label,
                    icon = floor.icon,
                    passcode = floor.passcode,
                    coords = safeCoords
                }
            end
        end
        safe[k] = safeElevator
    end
    return safe
end

local function LoadElevators()
    if not MySQL then
        print("[^1TELEPORT-ELEVATOR^7] oxmysql not found! Using config.lua fallback.")
        if TELEPORT and TELEPORT.ELEVATORS then
            DynamicElevators = SanitizeVectors(TELEPORT.ELEVATORS)
        end
        return
    end

    MySQL.ready(function()
        -- Auto-create the table if it doesn't exist
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS `TELEPORT_elevators` (
              `elevator_id` varchar(50) NOT NULL,
              `data` longtext NOT NULL,
              PRIMARY KEY (`elevator_id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]], {}, function()
            -- Now fetch the elevators
            MySQL.query('SELECT * FROM TELEPORT_elevators', {}, function(results)
                if results and #results > 0 then
                    for i = 1, #results do
                        local row = results[i]
                        local decoded = json.decode(row.data)
                        if decoded then
                            DynamicElevators[row.elevator_id] = decoded
                        end
                    end
                    print("[^2TELEPORT-ELEVATOR^7] Loaded " .. #results .. " elevator configurations from SQL")
                else
                    -- Fallback to config.lua migration if DB is empty
                    if TELEPORT and TELEPORT.ELEVATORS then
                        DynamicElevators = SanitizeVectors(TELEPORT.ELEVATORS)
                        print("[^3TELEPORT-ELEVATOR^7] Database is empty. Migrating config.lua elevators to SQL...")
                        
                        for id, data in pairs(DynamicElevators) do
                            MySQL.insert('INSERT INTO TELEPORT_elevators (elevator_id, data) VALUES (?, ?) ON DUPLICATE KEY UPDATE data = ?', {
                                id, json.encode(data), json.encode(data)
                            })
                        end
                    else
                        DynamicElevators = {}
                    end
                end
                
                -- Broadcast to all connected clients
                TriggerClientEvent("TELEPORT:KortzEstate:SyncConfig", -1, DynamicElevators)
            end)
        end)
    end)
end

-- Initialize on start
LoadElevators()

local function HasAdminPerms(src)
    -- Try QBOX (qbx_core)
    if GetResourceState('qbx_core') == 'started' then
        return exports.qbx_core:HasPermission(src, 'admin') or exports.qbx_core:HasPermission(src, 'god')
    end

    -- Try QB-Core
    if GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        if QBCore then
            return QBCore.Functions.HasPermission(src, 'admin') or QBCore.Functions.HasPermission(src, 'god')
        end
    end

    -- Try ESX
    if GetResourceState('es_extended') == 'started' then
        local ESX = exports['es_extended']:getSharedObject()
        if ESX then
            local xPlayer = ESX.GetPlayerFromId(src)
            if xPlayer then
                local group = xPlayer.getGroup()
                return group == 'admin' or group == 'superadmin'
            end
        end
    end

    -- Fallback for standalone / ace permissions
    return IsPlayerAceAllowed(src, "command") or IsPlayerAceAllowed(src, "command.tpmadmin")
end

RegisterCommand("tpmadmin", function(source, args, rawCommand)
    if source == 0 then return end
    
    if HasAdminPerms(source) then
        TriggerClientEvent("TELEPORT:KortzEstate:OpenAdminUI", source)
    else
        TriggerClientEvent("chat:addMessage", source, { args = { "^1SYSTEM", "You do not have permission to use this command." } })
    end
end, false)

-- Client requests config
RegisterNetEvent("TELEPORT:KortzEstate:GetConfig", function()
    local src = source
    TriggerClientEvent("TELEPORT:KortzEstate:SyncConfig", src, DynamicElevators)
end)

local function TableToString(o, indent)
    indent = indent or 1
    local spacing = string.rep("    ", indent)
    local spacing_prev = string.rep("    ", indent - 1)

    if type(o) == 'table' then
        local isArray = true
        local count = 0
        for k, v in pairs(o) do
            if type(k) ~= 'number' then isArray = false break end
            count = count + 1
        end
        if count ~= #o then isArray = false end
        
        local s = '{\n'
        -- Sort keys so config.lua doesn't get shuffled randomly every time
        local keys = {}
        for k in pairs(o) do table.insert(keys, k) end
        table.sort(keys, function(a, b) 
            if type(a) == type(b) then return a < b end
            return tostring(a) < tostring(b)
        end)
        
        for _, k in ipairs(keys) do
            local v = o[k]
            local k_str = ""
            if not isArray then
                if type(k) == 'string' and k:match("^[%a_][%w_]*$") then
                    k_str = k .. ' = '
                else
                    k_str = '[' .. (type(k) == 'string' and '"' .. k .. '"' or k) .. '] = '
                end
            end
            
            if k == "coords" and type(v) == "table" and v.x and v.y and v.z then
                local x = tonumber(string.format("%.4f", v.x or 0))
                local y = tonumber(string.format("%.4f", v.y or 0))
                local z = tonumber(string.format("%.4f", v.z or 0))
                local w = tonumber(string.format("%.4f", v.w or 0))
                s = s .. spacing .. k_str .. 'vector4(' .. x .. ', ' .. y .. ', ' .. z .. ', ' .. w .. '),\n'
            else
                s = s .. spacing .. k_str .. TableToString(v, indent + 1) .. ',\n'
            end
        end
        return s .. spacing_prev .. '}'
    elseif type(o) == 'string' then
        return '"' .. o:gsub('"', '\\"') .. '"'
    else
        return tostring(o)
    end
end

-- Admin saves config
RegisterNetEvent("TELEPORT:KortzEstate:SaveConfig", function(newElevators)
    local src = source
    if not HasAdminPerms(src) then return end
    
    DynamicElevators = SanitizeVectors(newElevators)
    
    if MySQL then
        -- Clear existing to handle deleted elevators, then insert
        MySQL.query('TRUNCATE TABLE TELEPORT_elevators', {}, function()
            for id, data in pairs(DynamicElevators) do
                MySQL.insert('INSERT INTO TELEPORT_elevators (elevator_id, data) VALUES (?, ?)', {
                    id, json.encode(data)
                })
            end
        end)
    end
    
    -- Save to config.lua
    local resourceName = GetCurrentResourceName()
    local configContent = LoadResourceFile(resourceName, "config.lua")
    if configContent then
        local newElevatorsStr = "TELEPORT.ELEVATORS = " .. TableToString(DynamicElevators, 1)
        
        local startIdx = string.find(configContent, "TELEPORT%.ELEVATORS%s*=%s*{")
        local endIdx = string.find(configContent, "TELEPORT%.MarkerConfig%s*=%s*{")
        
        if startIdx and endIdx then
            local newContent = string.sub(configContent, 1, startIdx - 1) .. newElevatorsStr .. "\n\n" .. string.sub(configContent, endIdx)
            SaveResourceFile(resourceName, "config.lua", newContent, -1)
            print("[^2TELEPORT-ELEVATOR^7] Config updated in config.lua!")
        else
            print("[^1TELEPORT-ELEVATOR^7] Failed to find ELEVATORS block in config.lua to update.")
        end
    end
    
    -- Broadcast to all clients
    TriggerClientEvent("TELEPORT:KortzEstate:SyncConfig", -1, DynamicElevators)
    print("[^2TELEPORT-ELEVATOR^7] Config updated in SQL by admin ("..GetPlayerName(src)..")")
end)
