local MySQLReady = false
local Guild = {}

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

    MySQL.Async.fetchAll('SELECT * FROM `guilds`', function(collect)
        if collect then
            self.list = collect
        else
            self.list = {}
        end
    end)

    if Config.debug then
        for i, v in ipairs(self.list) do
            print(v.name .. " | Lv." .. v.level .. " | players:" .. v.players.. " | comment:"..v.comment)
        end
    end
end

function Guild:new(_name, _comment)
    if _name == nil then
        return "name is nil"
    end

    for i=1, #self.list do
        if self.list[i].name == _name then
            return "the name is already exist"
        end
    end

    table.insert(self.list, {
        name = _name,
        level = 1,
        players = 0,
        comment = _comment
    })

    MySQL.Async.execute('INSERT INTO `guilds` (`name`,`level`,`players`, `comment`) VALUES (@name,1,0,@comment)', {['@name'] = _name,['@comment'] = _comment}, nil)

    if Config.debug then
        print("New guild: "..self.list[#self.list].name)
    end
end

function Guild:join(source, name)
    local xPlayer = ESX.GetPlayerFromId(source)

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

    return "couldn't find the guild "..name
end

function Guild:leave(source, name)
    local xPlayer = ESX.GetPlayerFromId(source)

    for i=1, #self.list do
        if self.list[i].name == name then
            self.list[i].players = self.list[i].players - 1
            
            xPlayer.set('guild', '')
            MySQL.Async.execute('UPDATE `guilds` SET `players`= @players WHERE `name` = @name', {["@name"] = name, ["@players"] = self.list[i].players}, nil)
            MySQL.Async.execute('UPDATE `users` SET `guild` = "" WHERE identifier = @identifier', {["@identifier"] = xPlayer.getIdentifier()}, nil)
            
            if Config.debug then
                print(xPlayer.getName().." leave "..self.list[i].name)
            end

            return false
        end
    end

    return "couldn't find the guild "..name
end

function Guild:modify(name, data)
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

    return "couldn't find the guild "..name
end

--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------

CreateThread(function()
    Guild:init()
end)

