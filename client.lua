local Guild = {}
Guild.data = nil

local display = false

ESX = nil
Citizen.CreateThread(
    function()
        while ESX == nil do
            TriggerEvent(
                "esx:getSharedObject",
                function(obj)
                    ESX = obj
                end
            )
            Citizen.Wait(0)
        end
    end
)

--------------------------------------------------------------------------------------

function Guild:load()
    local loaded = false
    ESX.TriggerServerCallback("Guild:load", function(data)
        self.data = data
        loaded = true
    end)

    while not loaded do
        Wait(5)
    end
end

function Guild:new(name,comment)
    --todo 判斷是否要執行或收費
    ESX.TriggerServerCallback("Guild:new",function(error)
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
        else
            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        end
    end,name,comment)
end

function Guild:join(name)
    --todo 判斷是否能加入
    ESX.TriggerServerCallback("Guild:join",function(error)
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
        else
            self.guild = {name = name}
            self:load()
            chat("你加入了"..name,{0,255,0})

            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        end
    end,name)
end

function Guild:leave()
    ESX.TriggerServerCallback("Guild:leave", function(error) 
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
        else
            local name = self.guild.name
            self.guild.name = nil
            self:load()
            chat("你已退出"..name,{0,255,0})

            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        end
    end)
end

function Guild:modify(name,data)
    ESX.TriggerServerCallback("Guild:modify", function(error) 
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
        else
            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        end
    end, name,data)
end

function Guild:setupNUI()
    if self.data.guild then
        SendNUIMessage({
            type = 'setup',
            selfName = self.data.player.name,
            selfLv = exports.xperience.GetRank(),
            information = {
                name = self.data.guild.name,
                level = self.data.guild.level,
                point = self.data.guild.point,
                players = self.data.guild.players,
                comment = self.data.guild.comment,
                ranking = self.data.ranking
            }
        })
    else
        SendNUIMessage({
            type = 'setup',
            selfName = self.data.player.name,
            selfLv = exports.xperience.GetRank(),
            information = nil
        })
    end
end

function Guild:openNUI()
    self:setupNUI()
    display = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'open'
    })
end

RegisterNUICallback("close", function(data)
    SetNuiFocus(false, false)
    display = false
end)

--------------------------------------------------------------------------------------

RegisterNetEvent("Guild:client:onChange")
AddEventHandler("Guild:client:onChange", function()
    Citizen.Wait(1000)
    Guild:load()
    Guild:setupNUI()
end)

RegisterNetEvent("xperience:client:rankUp")
AddEventHandler("xperience:client:rankUp",function()
    Citizen.Wait(1000)
    Guild:setupNUI()
end)

RegisterNetEvent("xperience:client:rankDown")
AddEventHandler("xperience:client:rankDown",function()
    Citizen.Wait(1000)
    Guild:setupNUI()
end)

--------------------------------------------------------------------------------------

RegisterCommand("newGuild", function(source,args) Guild:new(args[1],table.concat(args," ",2)) end)

RegisterCommand("joinGuild", function(source,args) Guild:join(args[1]) end)

RegisterCommand("leaveGuild", function() Guild:leave() end)

RegisterCommand("modifyGuild", function(source,args,data) Guild:modify(args[1],data) end)

exports("getGuild",function() 
    if Guild.data.guild then
        return Guild.data.guild.name
    else
        return nil
    end
end)

--------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    Guild:load()
    
    while true do
        Citizen.Wait(0)
        
        if IsControlJustReleased(1, Config.key) then
            Guild:openNUI()
        end
    end
end)

--------------------------------------------------------------------------------------

function chat(str, color)
    TriggerEvent(
        'chat:addMessage',
        {
            color = color,
            multiline = true,
            args = {str}
        }
    )
end