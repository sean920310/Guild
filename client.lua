local Guild = {}

function Guild:init()
    
end

function Guild:new(name,comment)
    ESX.TriggerServerCallback("Guild:new",function(error)
        if error then
            chat(error,{255,0,0})

            if Config.debug then
                print(error)
            end
        end
    end,name,comment)
end





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