local Guild = {}
Guild.guild = nil

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
    ESX.TriggerServerCallback("Guild:load", function(data) self.guild = data end)
end

function Guild:new(name,comment)
    --todo 判斷是否要執行或收費
    ESX.TriggerServerCallback("Guild:new",function(error)
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
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
        end
    end, name,data)
end

function Guild:setupNUI()
    
end

--------------------------------------------------------------------------------------

RegisterCommand("newGuild", function(source,args) Guild:new(args[1],table.concat(args," ",2)) end)

RegisterCommand("joinGuild", function(source,args) Guild:join(args[1]) end)

RegisterCommand("leaveGuild", function() Guild:leave() end)

RegisterCommand("modifyGuild", function(source,args,data) Guild:modify(args[1],data) end)

exports("getGuild",function() 
    if Guild.guild then
        return Guild.guild.name
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