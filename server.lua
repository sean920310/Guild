local MySQLReady = false
local Guild = {}
Guild.list={}
local match = {}

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

MySQL.ready(function()
    MySQLReady = true
end)

function Guild:init()
    while not MySQLReady do
        Wait(5)
    end

    local listReady = false
    MySQL.Async.fetchAll('SELECT * FROM `guild_list`',{}, function(collect)
        if collect[1] then
            self.list = collect
        end

        for i=1, #self.list do
            --初始化每個公會申請加入的table
            self.list[i].apply = {}

            --初始化每個公會成員的table
            self.list[i].member = {}

            --創建可以用公會名稱取得index的table
            match[self.list[i].name] = i
        end

        if Config.debug then
            print("GUILD:")
            for i=1, #self.list do
                print("^3"..self.list[i].name .. " | Lv." .. self.list[i].level .. " | point:" .. self.list[i].point .. " | chairman:" .. self.list[i].chairman .." | players:" .. self.list[i].players.. " | comment:"..self.list[i].comment.."^7")
            end
        end
        listReady = true
    end)

    while not listReady do
        Wait(5)
    end

    MySQL.Async.fetchAll('SELECT * FROM `guild_player`',{}, function(collect)
        if collect[1] then
            for i=1, #collect do
                local sync = false
                MySQL.Async.fetchAll('SELECT `job`,`rank` FROM `users` WHERE `identifier`=@identifier;', {['@identifier'] = collect[i].identifier}, function(user)
                    if user[1] then
                        collect[i].rank = user[1].rank
                        collect[i].job = user[1].job
                    end
                    sync = true
                end)
                while not sync do
                    Wait(5)
                end
                if collect[i].guild then
                    --取得目標公會的成員table
                    if collect[i].grade~=0 then
                        --成員
                        local targetTable = self.list[match[collect[i].guild]].member
                        table.insert(targetTable,#targetTable+1,collect[i])
                    else
                        --申請中
                        local targetTable = self.list[match[collect[i].guild]].apply
                        table.insert(targetTable,#targetTable+1,collect[i])
                    end
                end
            end
            
            if Config.debug then
                print("MEMBER:")
                for i=1, #self.list do
                    print("\t"..self.list[i].name..":")
                    for j=1,#self.list[i].member do
                        print("\t\t".. self.list[i].member[j].name.." | Grade:"..self.list[i].member[j].grade)
                    end
                end
                print("APPLY:")
                for i=1, #self.list do
                    print("\t"..self.list[i].name..":")
                    for j=1,#self.list[i].apply do
                        print("\t\t".. self.list[i].apply[j].name.." | Rank:"..self.list[i].apply[j].rank)
                    end
                end
            end
        end
    end)
end

function Guild:load(source)
    local loaded = false
    local data = {}
    local xPlayer = ESX.GetPlayerFromId(source)

    local count=0
    while not xPlayer do
        Wait(5)
        xPlayer = ESX.GetPlayerFromId(source)

        count=count+1
        if count>1000 then
            print("Guild: xPlayer load error")
            return;
        end
    end

    local identifier = xPlayer.getIdentifier()
	local name = nil
    MySQL.Async.fetchAll('SELECT * FROM `guild_player` WHERE `identifier`=@identifier;', {['@identifier'] = identifier}, function(collect)
        --讀取舊資料
        if collect[1] then
            data.player = collect[1]
            data.player.apply = nil
            name = collect[1].guild
            if collect[1].grade~=0 then
                xPlayer.set("guild",name)
            else
                data.player.apply = name
                name = nil
            end

            data.list = self.list

            if name then
                data.guild = self.list[match[name]]
            else
                data.guild = nil
            end

        else
            --新增資料
            MySQL.Async.execute('INSERT INTO `guild_player` (`identifier`,`name`,`guild`, `point`, `grade`) VALUES (@identifier,@name,NULL,0,0);', {['@identifier'] = identifier,['@name']=xPlayer.getName()}, nil)
            xPlayer.set("guild",nil)

            data.player = {
                identifier = identifier,
                name = xPlayer.getName(),
                guild = nil,
                apply= nil,
                point = 0,
                grade = 0,
                job = xPlayer.get("job"),
                rank = xPlayer.get("rank")
            }
            data.guild = nil

        end
        loaded = true
    end)

    while not loaded do
        Wait(5)
    end

    return data
end

function Guild:new(name, comment)
    if name == nil then
        return "Guild name is nil"
    end

    if comment == nil then
        comment = ""
    end

    for i=1, #self.list do
        if self.list[i].name == name then
            return "The name is already exist"
        end
    end

    table.insert(self.list, #self.list+1,{
        name = name,
        level = 1,
        players = 0,
        comment = comment,
        member = {},
        apply = {}
    })
    match[name] = #self.list


    MySQL.Async.execute('INSERT INTO `guild_list` (`name`,`level`,`point`,`players`, `comment`, `apply`) VALUES (@name,1,0,0,@comment,"[]")', {['name'] = name,['comment'] = comment}, nil)

    if Config.debug then
        print("New guild: "..self.list[#self.list].name)
    end
end

function Guild:join(source, name)
    if name == nil then
        return "Guild name is nil"
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.get("guild") then
        return "You already has a guild"
    end

    for i=1, #self.list do
        if self.list[i].name == name then
            self.list[i].players = self.list[i].players + 1
            table.insert(self.list[i].member,#self.list[i].member+1,{
                identifier = xPlayer.getIdentifier(),
                name = xPlayer.getName(),
                guild = name,
                point = 0,
                grade = 1
            })

            xPlayer.set('guild',name)
            MySQL.Async.execute('UPDATE `guild_list` SET `players`= @players WHERE `name` = @name', {["@name"] = name, ["@players"] = self.list[i].players}, nil)
            MySQL.Async.execute('UPDATE `guild_player` SET `guild` = @guild, `grade` = 1 WHERE identifier = @identifier', {["@identifier"] = xPlayer.getIdentifier(),["@guild"] = name}, nil)
            
            if Config.debug then
                print(xPlayer.getName().." join "..name)
            end

            return false
        end
    end

    return "Couldn't find the guild "..name
end

function Guild:leave(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.get("guild")

    if not name then
       return "Is not in any guild" 
    end

    for i=1, #self.list do
        if self.list[i].name == name then
            self.list[i].players = self.list[i].players - 1
            for j=1, #self.list[i].member do
                if self.list[i].member[j].identifier == xPlayer.getIdentifier() then
                    table.remove(self.list[i].member,j)
                    break
                end
            end
            
            xPlayer.set('guild', nil)
            MySQL.Async.execute('UPDATE `guild_list` SET `players`= @players WHERE `name` = @name', {["@name"] = name, ["@players"] = self.list[i].players}, nil)
            MySQL.Async.execute('UPDATE `guild_player` SET `guild` = NULL, `grade` = 0, `point` = 0 WHERE identifier = @identifier', {["@identifier"] = xPlayer.getIdentifier()}, nil)
            
            if Config.debug then
                print(xPlayer.getName().." leave "..self.list[i].name)
            end

            return false
        end
    end

    return "Couldn't find the guild "..name
end

function Guild:modify(name, data)
    if name == nil then
        return "Guild name is nil"
    end

    for i=1, #self.list do
        if self.list[i].name == name then
            if data.players then
                self.list[i].players = data.players
            end
            if data.name then
                if match[data.name] then
                    return "The guild name already exist"
                end
                self.list[i].name = data.name
                match[data.name] = match[name]
                match[name] = nil
            end
            if data.level then
                self.list[i].level = data.level
            end
            if data.comment then
                self.list[i].comment = data.comment
            end

            MySQL.Async.execute('UPDATE `guild_list` SET `players`= @players,`name` = @newname, `level` = @level, `comment` = @comment WHERE `name` = @name', {["@name"] = name, ["@players"] = self.list[i].players, ["@newname"] = self.list[i].name, ["@level"] = self.list[i].level, ["@comment"] = self.list[i].comment}, nil)
            MySQL.Async.execute('UPDATE `guild_player` SET `guild` = @newname WHERE `guild` = @name', {["@name"] = name, ["@newname"] = self.list[i].name}, nil)
            
            if Config.debug then
                print(name.." modify to: "..self.list[i].name .. " | Lv." .. self.list[i].level .. " | players:" .. self.list[i].players.. " | comment:"..self.list[i].comment)
            end
            return false
        end
    end

    return "Couldn't find the guild "..name
end

--------------------------------------------------------------------------------------

ESX.RegisterServerCallback("Guild:new",function(source,cb,name,comment)
    cb(Guild:new(name,comment))
end)

ESX.RegisterServerCallback("Guild:join",function(source,cb,name)
    cb(Guild:join(source,name))
end)

ESX.RegisterServerCallback("Guild:leave",function(source,cb)
    cb(Guild:leave(source))
end)

ESX.RegisterServerCallback("Guild:modify",function(source,cb,name,data)
    cb(Guild:modify(name,data))
end)

ESX.RegisterServerCallback("Guild:load",function(source,cb)
    cb(Guild:load(source))
end)

--------------------------------------------------------------------------------------

RegisterCommand("reloadGuild", function() 
    Guild:init() 
    TriggerClientEvent("Guild:client:onChange", -1)
end, true)

RegisterNetEvent("Guild:server:onChange")
AddEventHandler("Guild:server:onChange",function ()
    TriggerClientEvent("Guild:client:onChange", -1)
end)

--------------------------------------------------------------------------------------

CreateThread(function()
    Guild:init()
end)

