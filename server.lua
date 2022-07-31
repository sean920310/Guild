local MySQLReady = false
local Guild = {}
Guild.list={}

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

    MySQL.Async.fetchAll('SELECT * FROM `guilds`',{}, function(collect)
        if collect[1] then
            self.list = collect
        end

        if Config.debug then
            for i=1, #self.list do
                print(self.list[i].name .. " | Lv." .. self.list[i].level .. " | point:" .. self.list[i].point .." | players:" .. self.list[i].players.. " | comment:"..self.list[i].comment)
            end
        end
    end)
end

function Guild:load(source)
    local data = {}
    local loaded = false
    local xPlayer = ESX.GetPlayerFromId(source)

    while not xPlayer do
        Wait(5)
        xPlayer = ESX.GetPlayerFromId(source)
    end

    local identifier = xPlayer.getIdentifier()
	local name = nil
    MySQL.Async.fetchAll('SELECT * FROM `users` WHERE `identifier`=@identifier;', {['@identifier'] = identifier}, function(collect)
        name = collect[1].guild
        xPlayer.set("guild",name)
        loaded = true
    end)

    while not loaded do
        Wait(5)
    end

    data.player = {
        name = xPlayer.getName(),
        level = xPlayer.get("rank")
    }

    for i, value in ipairs(Guild.list) do
        if value.name == name then
            data.guild = value
            return data
        end
    end

    return data
end

function Guild:new(_name, _comment)
    if _name == nil then
        return "Guild name is nil"
    end

    if _comment == nil then
        _comment = ""
    end

    for i=1, #self.list do
        if self.list[i].name == _name then
            return "The name is already exist"
        end
    end

    table.insert(self.list, {
        name = _name,
        level = 1,
        players = 0,
        comment = _comment
    })

    MySQL.Async.execute('INSERT INTO `guilds` (`name`,`level`,`point`,`players`, `comment`) VALUES (@name,1,0,0,@comment)', {['name'] = _name,['comment'] = _comment}, nil)

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
            
            xPlayer.set('guild',name)
            MySQL.Async.execute('UPDATE `guilds` SET `players`= @players WHERE `name` = @name', {["@name"] = name, ["@players"] = self.list[i].players}, nil)
            MySQL.Async.execute('UPDATE `users` SET `guild` = @guild WHERE identifier = @identifier', {["@identifier"] = xPlayer.getIdentifier(),["@guild"] = name}, nil)
            
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
            
            xPlayer.set('guild', nil)
            MySQL.Async.execute('UPDATE `guilds` SET `players`= @players WHERE `name` = @name', {["@name"] = name, ["@players"] = self.list[i].players}, nil)
            MySQL.Async.execute('UPDATE `users` SET `guild` = NULL WHERE identifier = @identifier', {["@identifier"] = xPlayer.getIdentifier()}, nil)
            
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
                self.list[i].name = data.name
            end
            if data.level then
                self.list[i].level = data.level
            end
            if data.comment then
                self.list[i].comment = data.comment
            end

            MySQL.Async.execute('UPDATE `guilds` SET `players`= @players,`name` = @newname, `level` = @level, `comment` = @comment WHERE `name` = @name', {["@name"] = name, ["@players"] = self.list[i].players, ["@newname"] = self.list[i].name, ["@level"] = self.list[i].level, ["@comment"] = self.list[i].comment}, nil)
            
            if Config.debug then
                print(name.."modify to: "..self.list[i].name .. " | Lv." .. self.list[i].level .. " | players:" .. self.list[i].players.. " | comment:"..self.list[i].comment)
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

RegisterCommand("reloadGuild", function() Guild:init() end, true)

--------------------------------------------------------------------------------------

CreateThread(function()
    Guild:init()
end)

