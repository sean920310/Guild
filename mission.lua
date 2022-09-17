local mission = Config.mission
local TrackedEntities = {}
local playerData = {}
local loaded = false

function missionSetup()
    for k, level in pairs(mission) do
        for i, value in ipairs(level) do
            if value.type == 'kill' then
                Citizen.CreateThread(function()

                end)
            elseif value.type == 'attend' then
                Citizen.CreateThread(function()

                end)
            elseif value.type == 'harm' then
                Citizen.CreateThread(function()
                    local _level = k
                    local _index = i
                    local dmgTarget = value.amount
                    local dmgCount = playerData.mission[_level][_index]

                    AddEventHandler('gameEventTriggered', function(eventName, data)
                        if eventName == 'CEventNetworkEntityDamage' then
                            local victim = data[1]
                            local attacker = data[2]
                            -- victim ~= GetVehiclePedIsIn(PlayerPedId(), false)
                            if attacker ~= PlayerPedId() and victim ~= PlayerPedId() then
                                return
                            end

                            local tempDmg = CalculateHealthLost(victim)
                            
                            if playerData.mission[_level][_index] < dmgTarget then
                                dmgCount = dmgCount + tempDmg.h + tempDmg.a
                                TriggerServerEvent("Guild:server:missionUpdate", _level, _index, math.floor(dmgCount))
                            end
                        end
                    end)
                end)
            elseif value.type == 'win' then
                Citizen.CreateThread(function()

                end)
            end
        end
    end
end

function TrackEntityHealth()
    entities = GetActivePlayers()
    for k, v in ipairs(GetGamePool('CPed')) do
        table.insert(entities, v)
    end
    for k, v in ipairs(GetGamePool('CVehicle')) do
        table.insert(entities, v)
    end
    for i, ent in ipairs(entities) do
        if IsEntityAPed(ent) then
            TrackedEntities[ent] = {
                h = GetEntityHealth(ent),
                a = GetPedArmour(ent)
            }
        elseif IsEntityAVehicle(ent) then
            TrackedEntities[ent] = {
                h = MergeVehicleHealths(ent),
                a = 0
            }
        end
    end
    for i, ent in ipairs(TrackedEntities) do
        if entities[ent] == nil and TrackedEntities[ent] then
            table.remove(TrackedEntities, IndexOf(TrackedEntities, ent))
            print('Removed ' .. ent .. ' from tracking list')
        end
    end
end

function MergeVehicleHealths(veh)
    local wheel_healths = 0
    -- print(GetVehicleNumberOfWheels(veh))
    for i = 1, GetVehicleNumberOfWheels(veh) do
        -- print(i)
        wheel_healths = wheel_healths + GetVehicleWheelHealth(veh, i)
    end
    local heli_healths = 0
    if GetVehicleClass(veh) == 15 then -- if vehicle is helicopter, get it's health stats
        heli_healths = GetHeliMainRotorHealth(veh) + GetHeliTailBoomHealth(veh) + GetHeliTailRotorHealth(veh)
    end
    return GetVehicleBodyHealth(veh) + GetVehicleEngineHealth(veh) + GetVehiclePetrolTankHealth(veh) + wheel_healths +
               heli_healths
end

function CalculateHealthLost(ent)
    local health = 0
    local armor = 0
    if IsEntityAPed(ent) then
        health = TrackedEntities[ent].h - GetEntityHealth(ent)
        TrackedEntities[ent].h = GetEntityHealth(ent)
        -- print(health)
        armor = TrackedEntities[ent].a - GetPedArmour(ent)
        TrackedEntities[ent].a = GetPedArmour(ent)
    elseif IsEntityAVehicle(ent) then
        health = TrackedEntities[ent].h - MergeVehicleHealths(ent)
        TrackedEntities[ent].h = MergeVehicleHealths(ent)
    else
        health = 0
    end
    return {
        h = health,
        a = armor
    }
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- update every second.
        TrackEntityHealth()
    end
end)

Citizen.CreateThread(function()
    while not loaded do
        Citizen.Wait(0)
    end
    missionSetup()
end)

RegisterNetEvent("Guild:mission:init")
AddEventHandler("Guild:mission:init", function(data)
    playerData = data
    loaded = true
end)
