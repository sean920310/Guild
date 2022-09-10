local mission = Config.mission

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
                
            end)
        elseif value.type == 'win' then
            Citizen.CreateThread(function()
                
            end)
        end
    end
end