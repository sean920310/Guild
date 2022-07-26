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
    TriggerEvent("Guild:mission:init",self.data.player)
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
            self:load()
            chat("你申請加入了"..name,{0,255,0})

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
            local name = self.data.guild.name
            self:load()
            chat("你已退出"..name,{0,255,0})

            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        end
    end)
end

function Guild:apply(identifier,accept)
    ESX.TriggerServerCallback("Guild:apply", function(error) 
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
        else
            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        end
    end, identifier, accept)
end

function Guild:modify(data)
    local name = self.data.guild.name
    ESX.TriggerServerCallback("Guild:modify", function(error) 
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        else
            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        end
    end, name ,data)
end

function Guild:changeGrade(identifier,grade)
    ESX.TriggerServerCallback("Guild:changeGrade", function(error) 
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
        else
            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        end
    end, identifier,grade)
end

function Guild:chat(identifier)
    
end

function Guild:kick(identifier)
    ESX.TriggerServerCallback("Guild:kick", function(error) 
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
        else
            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        end
    end, identifier)
end

function Guild:upgrade()
    ESX.TriggerServerCallback("Guild:upgrade", function(error) 
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
        else
            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        end
    end)
end

function Guild:skillUpgrade(skill)
    ESX.TriggerServerCallback("Guild:skillUpgrade", function(error) 
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
        else
            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        end
    end,skill)
end

function Guild:shop(item)
    ESX.TriggerServerCallback("Guild:shop", function(error) 
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
        else
            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        end
    end,item)
end

function Guild:missionHandin(level,index)
    ESX.TriggerServerCallback("Guild:missionHandin", function(error) 
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
        else
            TriggerServerEvent("Guild:server:onChange")
            TriggerEvent("Guild:client:onChange")
        end
    end,level,index)
end

function Guild:initNUI()
    SendNUIMessage({
        type = 'init',
        config = Config
    })
end

function Guild:setupNUI()
    if not self.data then
        self:load()
    end
    local player = self.data.player
    player.level = exports.xperience.GetRank()

    if self.data.guild then
        SendNUIMessage({
            type = 'setup',
            player = player,
            guild = self.data.guild,
            list = self.data.list
        })
    else
        SendNUIMessage({
            type = 'setup',
            player = player,
            guild = nil,
            list = self.data.list
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

--------------------------------------------------------------------------------------

RegisterNUICallback("close", function(data)
    SetNuiFocus(false, false)
    display = false
end)

RegisterNUICallback("join", function(data)
    Guild:join(data.name)
end)

RegisterNUICallback("leave", function(data)
    Guild:leave()
end)

RegisterNUICallback("edit", function(data)
    if Guild.data.guild.name == data.name then
        data.name = nil;
    end
    Guild:modify({
        name = data.name,
        comment = data.comment
    })
end)

RegisterNUICallback("apply", function(data)
    Guild:apply(data.identifier,data.accept)
end)

RegisterNUICallback("changeGrade", function(data)
    Guild:changeGrade(data.identifier,data.grade)
end)

RegisterNUICallback("chat", function(data)
    Guild:chat(data.identifier)
end)

RegisterNUICallback("kick", function(data)
    Guild:kick(data.identifier)
end)

RegisterNUICallback("upgrade", function(data)
    Guild:upgrade()
end)

RegisterNUICallback("skillUpgrade", function(data)
    Guild:skillUpgrade(data.skill)
end)

RegisterNUICallback("shop", function(data)
    Guild:shop(data.item)
end)

RegisterNUICallback("missionHandin", function(data)
    Guild:missionHandin(data.level,data.index)
end)

--------------------------------------------------------------------------------------

RegisterNetEvent("Guild:client:missionGetReward")
AddEventHandler("Guild:client:missionGetReward", function()
    Notify("~g~你已完成任務~w~")
    PlaySoundFrontend(-1, "OTHER_TEXT", "HUD_AWARDS")
end)

RegisterNetEvent("Guild:client:onChange")
AddEventHandler("Guild:client:onChange", function()
    Guild:load()
    Guild:setupNUI()
end)

RegisterNetEvent("xperience:client:rankUp")
AddEventHandler("xperience:client:rankUp",function()
    Citizen.Wait(1000)
    TriggerServerEvent("Guild:server:onChange")
end)

RegisterNetEvent("xperience:client:rankDown")
AddEventHandler("xperience:client:rankDown",function()
    Citizen.Wait(1000)
    TriggerServerEvent("Guild:server:onChange")
end)

RegisterNetEvent("esx:playerLoaded",function()
    Citizen.Wait(1000)
    Guild:load()
end)

--------------------------------------------------------------------------------------

RegisterCommand("newGuild", function(source,args) Guild:new(args[1],table.concat(args," ",2)) end)

RegisterCommand("joinGuild", function(source,args) Guild:join(args[1]) end)

RegisterCommand("leaveGuild", function() Guild:leave() end)

RegisterCommand("modifyGuild", function(source,args,data) Guild:modify(args[1],data) end)

exports("getGuild",function() 
    if Guild.data then
        if Guild.data.guild then
            return Guild.data.guild.name
        else
            return nil
        end
    else
        print("Guild load error")        
    end
end)

--------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    Citizen.Wait(500)
    Guild:initNUI()    
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

function Notify(text) -- 左下角通知
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(false, false)
end