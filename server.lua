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

function Guild:init(debug)
    while not MySQLReady do
        Wait(5)
    end

    local listReady = false
    MySQL.Async.fetchAll('SELECT * FROM `guild_list`',{}, function(collect)
        if collect[1] then
            self.list = collect
        end

        for i=1, #self.list do
            --初始化每個公會技能的table
            local skillTemp = self.list[i].skill
            self.list[i].skill = json.decode(skillTemp)

            --初始化每個公會申請加入的table
            self.list[i].apply = {}

            --初始化每個公會成員的table
            self.list[i].member = {}

            --創建可以用公會名稱取得index的table
            match[self.list[i].name] = i
        end

        if Config.debug and debug then
            print("GUILD:")
            for i=1, #self.list do
                print("^3"..self.list[i].name .. " | Lv." .. self.list[i].level .. " | point:" .. self.list[i].point .. " | money:" .. self.list[i].money .. " | chairman:" .. self.list[i].chairman .." | players:" .. self.list[i].players.. " | comment:"..self.list[i].comment.."^7")
            end
        end
        listReady = true
    end)

    while not listReady do
        Wait(5)
    end

    local playerReady = false
    MySQL.Async.fetchAll('SELECT * FROM `guild_player`',{}, function(collect)
        if collect[1] then
            for i=1, #collect do
                collect[i].shop = json.decode(collect[i].shop)
                local tempMission = json.decode(collect[i].mission)
                if #tempMission.hard == 0 then

                    for i = 1, #Config.mission.hard do
                        table.insert(tempMission.hard,#tempMission.hard+1,0)
                    end
                end
                if #tempMission.medium == 0 then
                    for i = 1, #Config.mission.medium do
                        table.insert(tempMission.medium,#tempMission.medium+1,0)
                    end 
                end
                if #tempMission.easy == 0 then
                    for i = 1, #Config.mission.easy do
                        table.insert(tempMission.easy,#tempMission.easy+1,0)
                    end 
                end
                collect[i].mission = tempMission
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
            
            if Config.debug and debug then
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
        playerReady = true
    end)
    while not playerReady do
        Wait(5)
    end
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
                xPlayer.set("guild",nil)
            end
            data.player.shop = json.decode(data.player.shop)
            data.player.mission = json.decode(data.player.mission)
            if #data.player.mission.hard == 0 then
                for i = 1, #Config.mission.hard do
                    table.insert(data.player.mission.hard,#data.player.mission.hard+1,0)
                end
            end
            if #data.player.mission.medium == 0 then
                for i = 1, #Config.mission.medium do
                    table.insert(data.player.mission.medium,#data.player.mission.medium+1,0)
                end 
            end
            if #data.player.mission.easy == 0 then
                for i = 1, #Config.mission.easy do
                    table.insert(data.player.mission.easy,#data.player.mission.easy+1,0)
                end 
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
                shop = {
                    green_material = 0,
                    blue_material = 0,
                    purple_material = 0,
                    gold_material = 0,
                    red_material = 0
                },
                mission = {
                    hard = {},
                    medium = {},
                    easy = {}
                },
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

function Guild:new(source, name, comment)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.get("guild") then
       return "Already in guild" 
    end

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
        chairman = xPlayer.getName(),
        level = 1,
        players = 1,
        comment = comment,
        member = {
            {
                identifier = xPlayer.getIdentifier(),
                name = xPlayer.getName(),
                guild = name,
                apply = nil,
                point = 0,
                grade = 4,
                shop = {
                    green_material = 0,
                    blue_material = 0,
                    purple_material = 0,
                    gold_material = 0,
                    red_material = 0
                },
                mission = {
                    hard = {},
                    medium = {},
                    easy = {}
                },
                job = xPlayer.get("job"),
                rank = xPlayer.get("rank")
            }
        },
        apply = {}
    })

    match[name] = #self.list

    MySQL.Async.execute('INSERT INTO `guild_list` (`name`,`chairman`,`level`,`point`,`players`, `comment`) VALUES (@name,@chairman,1,0,1,@comment)', {['name'] = name,['chairman'] = xPlayer.getName(),['comment'] = comment}, nil)
    MySQL.Async.execute('UPDATE `guild_player` SET `guild` = @guild, `grade` = 4,`point`=0, `shop`=DEFAULT, `mission`=DEFAULT WHERE identifier = @identifier', {["@identifier"] = xPlayer.getIdentifier(),["@guild"] = name}, nil)

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

    local guild = self.list[match[name]]
    if guild then
        if guild.players>=(math.floor((guild.level-1)/3)*5 + 20) then
            return "Guild is already full"
        end

        table.insert(guild.apply,#guild.apply+1,{
            identifier = xPlayer.getIdentifier(),
            name = xPlayer.getName(),
            guild = nil,
            apply = name,
            point = 0,
            grade = 0,
            shop = {
                green_material = 0,
                blue_material = 0,
                purple_material = 0,
                gold_material = 0,
                red_material = 0
            },
            mission = {
                hard = {},
                medium = {},
                easy = {}
            },
            job = xPlayer.get("job"),
            rank = xPlayer.get("rank")
        })

        xPlayer.set('guild',nil)
        MySQL.Async.execute('UPDATE `guild_player` SET `guild` = @guild, `grade` = 0, `shop`= DEFAULT WHERE identifier = @identifier', {["@identifier"] = xPlayer.getIdentifier(),["@guild"] = name}, nil)
        
        if Config.debug then
            print(xPlayer.getName().." wants to join "..name)
        end

        return false
    end

    return "Couldn't find the guild "..name
end

function Guild:leave(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.get("guild")

    if not name then
       return "Is not in any guild" 
    end

    local guild = self.list[match[name]]
    if guild then
        guild.players = guild.players - 1
        for j=1, #guild.member do
            if guild.member[j].identifier == xPlayer.getIdentifier() then
                table.remove(guild.member,j)
                break
            end
        end
        
        xPlayer.set('guild', nil)
        MySQL.Async.execute('UPDATE `guild_list` SET `players`= @players WHERE `name` = @name', {["@name"] = name, ["@players"] = guild.players}, nil)
        MySQL.Async.execute('UPDATE `guild_player` SET `guild` = NULL, `grade` = 0, `point` = 0, `shop`= DEFAULT, `mission`=DEFAULT WHERE identifier = @identifier', {["@identifier"] = xPlayer.getIdentifier()}, nil)
        
        if Config.debug then
            print(xPlayer.getName().." leave "..guild.name)
        end

        return false
    end

    return "Couldn't find the guild "..name
end

function Guild:apply(source, identifier, accept)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.get("guild")

    if not name then
        return "Is not in any guild" 
    end

    local guild = self.list[match[name]]
    if guild then
       for i = 1, #guild.apply do
            if guild.apply[i].identifier == identifier then
                local tempName = guild.apply[i].name
                if accept then
                    if guild.players>=(math.floor((guild.level-1)/3)*5 + 20) then
                        return "Guild is already full"
                    end

                    local targetPlayer = guild.apply[i]
                    targetPlayer.grade = 1
                    targetPlayer.point = 0
                    
                    guild.players = guild.players+1
                    table.insert(guild.member,#guild.member,targetPlayer)
                    table.remove(guild.apply,i)
                    MySQL.Async.execute('UPDATE `guild_player` SET `grade` = 1, `point` = 0 WHERE identifier = @identifier', {["@identifier"] = identifier}, nil)
                    
                    if Config.debug then
                        print(name.." | "..xPlayer.getName().." accept "..tempName.." apply")
                    end
                else
                    table.remove(guild.apply,i)
                    MySQL.Async.execute('UPDATE `guild_player` SET `guild` = NULL, `grade` = 0, `point` = 0 WHERE identifier = @identifier', {["@identifier"] = identifier}, nil)
                    
                    if Config.debug then
                        print(name.." | "..xPlayer.getName().." reject "..tempName.." apply")
                    end
                end

                MySQL.Async.execute('UPDATE `guild_list` SET `players`= @players WHERE `name` = @name', {["@name"] = name, ["@players"] = guild.players}, nil)
                
                return false
            end
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

function Guild:kick(source,identifier)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.get("guild")

    if not name then
        return "Is not in any guild" 
    end

    local guild = self.list[match[name]]
    if guild then
        for i = 1, #guild.member do
            if guild.member[i].identifier == identifier then
                local tempName = guild.member[i].name
                table.remove(guild.member,i)
                guild.players = guild.players-1

                MySQL.Async.execute('UPDATE `guild_player` SET `guild` = NULL, `grade` = 0, `point` = 0, `shop`= DEFAULT, `mission`=DEFAULT WHERE identifier = @identifier', {["@identifier"] = identifier}, nil)
                MySQL.Async.execute('UPDATE `guild_list` SET `players`= @players WHERE `name` = @name', {["@name"] = name, ["@players"] = guild.players}, nil)
                
                if Config.debug then
                    print(name.." | "..xPlayer.getName().." kick "..tempName)
                end

                return false
            end
       end
    end

    return "Couldn't find the guild "..name
end

function Guild:changeGrade(source,identifier,grade)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.get("guild")

    if not name then
        return "Is not in any guild" 
    end

    local guild = self.list[match[name]]
    if guild then
       for i = 1, #guild.member do
            if guild.member[i].identifier == identifier then
                if grade == 4 then
                    for j = 1, #guild.member do
                        if guild.member[j].grade == 4 then
                            guild.member[j].grade = 3
                            guild.chairman = guild.member[i].name
                            MySQL.Async.execute('UPDATE `guild_player` SET `grade` = 3 WHERE identifier = @identifier', {["@identifier"] = guild.member[j].identifier}, nil)
                            MySQL.Async.execute('UPDATE `guild_list` SET `chairman`= @chairman WHERE `name` = @name', {["@name"] = name, ["@chairman"] = guild.member[i].name}, nil)
                        end
                    end
                end
                guild.member[i].grade = grade
                MySQL.Async.execute('UPDATE `guild_player` SET `grade` = @grade WHERE identifier = @identifier', {["@identifier"] = identifier,["@grade"] = grade}, nil)
                
                if Config.debug then
                    print(name.." | "..xPlayer.getName().." change "..guild.member[i].name.." grade to "..grade)
                end

                return false
            end
       end
    end

    return "Couldn't find the guild "..name
end

function Guild:upgrade(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.get("guild")

    if not name then
        return "Is not in any guild" 
    end

    local guild = self.list[match[name]]
    if guild then
        local moneyCost = Config.upgradeCost.money * guild.level
        local pointCost = Config.upgradeCost.point * guild.level
        if guild.money < moneyCost then
            return "Not enough money"
        end
        if guild.point < pointCost then
            return "Not enough point"
        end
        if guild.level >= 10 then
            return "Guild level is already the highest level"
        end

        guild.money = guild.money - moneyCost
        guild.point = guild.point - pointCost
        guild.level = guild.level + 1
        guild.skillPoint = guild.skillPoint + 2

        MySQL.Async.execute('UPDATE `guild_list` SET `level`= @level,`point`= @point,`money`= @money,`skillPoint`= @skillPoint WHERE `name` = @name', {["@name"] = name, ["@level"] = guild.level, ["@point"] = guild.point, ["@money"] = guild.money, ["@skillPoint"] = guild.skillPoint}, nil)
    
        if Config.debug then
            print(name.." upgrade to "..guild.level)
        end
        return false
    end

    return "Couldn't find the guild "..name
end

function Guild:skillUpgrade(source,skill)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.get("guild")

    if not name then
        return "Is not in any guild" 
    end

    local guild = self.list[match[name]]
    if guild then
        if guild.skillPoint <= 0 then
            guild.skillPoint = 0
            return "Not enough skill point"
        end

        if guild.skill[skill] >= 5 then
            guild.skill[skill] = 5
            return "Skill is already fully upgrade"
        else
            guild.skill[skill] = guild.skill[skill] + 1
            guild.skillPoint = guild.skillPoint - 1
        end

        MySQL.Async.execute('UPDATE `guild_list` SET `skillPoint`= @skillPoint, `skill`= @skill WHERE `name` = @name', {["@name"] = name, ["@skillPoint"] = guild.skillPoint, ["@skill"] = json.encode(guild.skill)}, nil)
    
        if Config.debug then
            print(name.." skill-"..skill.." upgrade")
        end
        return false
    end

    return "Couldn't find the guild "..name
end

function Guild:shop(source,item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.get("guild")
    local identifier = xPlayer.getIdentifier()

    if not name then
        return "Is not in any guild" 
    end

    local guild = self.list[match[name]]
    if guild then
        local playerMoney = xPlayer.getMoney()
        local cost = Config.shopItem[item].money

        if playerMoney >= cost then
            for i = 1, #guild.member do
                if guild.member[i].identifier == identifier then
                    if guild.member[i].shop[item] >= Config.shopItem[item].limit then
                        return "You already buy to the limited amount"
                    end
                    guild.member[i].shop[item] = guild.member[i].shop[item] + 1
                    MySQL.Async.execute('UPDATE `guild_player` SET `shop`= @shop WHERE identifier = @identifier', {["@identifier"] = identifier, ["@shop"] = json.encode(guild.member[i].shop)}, nil)
                end
            end
            xPlayer.removeMoney(cost)
            --xPlayer.addInventoryItem(item,1)
        else
            return "You don't have enough money"
        end

        return false
    end

    return "Couldn't find the guild "..name
end

function Guild:missionHandin(source,level,index)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.get("guild")
    local identifier = xPlayer.getIdentifier()

    if not name then
        return "Is not in any guild" 
    end

    local guild = self.list[match[name]]
    if guild then
        local itemName = Config.mission[level][index].item
        local itemCount = Config.mission[level][index].amount
        if itemName == "money" then
            local playerMoney = xPlayer.getMoney()
            if playerMoney >= itemCount then
                xPlayer.removeMoney(itemCount)
                for i = 1, #guild.member do
                    if guild.member[i].identifier == identifier then
                        guild.member[i].mission[level][index] = itemCount
                        MySQL.Async.execute('UPDATE `guild_player` SET `mission`= @mission WHERE identifier = @identifier', {["@identifier"] = identifier, ["@mission"] = json.encode(guild.member[i].mission)}, nil)
                    end
                end
                return self:missionGetReward(source,level,index)
            else
                return "You don't have enough "..itemName
            end
        else
            local item = xPlayer.getInventoryItem(itemName)
            if item.count >= itemCount then
                xPlayer.removeInventoryItem(itemName,itemCount)
                for i = 1, #guild.member do
                    if guild.member[i].identifier == identifier then
                        guild.member[i].mission[level][index] = itemCount
                        MySQL.Async.execute('UPDATE `guild_player` SET `mission`= @mission WHERE identifier = @identifier', {["@identifier"] = identifier, ["@mission"] = json.encode(guild.member[i].mission)}, nil)
                    end
                end
                return self:missionGetReward(source,level,index)
            else
                return "You don't have enough "..itemName
            end
        end

    end

    return "Couldn't find the guild "..name
end

function Guild:missionGetReward(source,level,index)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = xPlayer.get("guild")
    local identifier = xPlayer.getIdentifier()

    if not name then
        return "Is not in any guild" 
    end

    local guild = self.list[match[name]]
    if guild then
        for i, v in ipairs(Config.mission[level][index].rewards) do
            if v.name == "xp" then
                exports.xperience.addXP(source,source, v.amount)
            elseif v.name == "money" then
                xPlayer.addMoney(v.amount)
            elseif v.name == "point" then
                for i = 1, #guild.member do
                    if guild.member[i].identifier == identifier then
                        guild.member[i].point = guild.member[i].point + v.amount
                        guild.point = guild.point + v.amount
                        MySQL.Async.execute('UPDATE `guild_player` SET `point`= @point WHERE identifier = @identifier', {["@identifier"] = identifier, ["@point"] = guild.member[i].point}, nil)
                        MySQL.Async.execute('UPDATE `guild_list` SET `point`= @point WHERE `name` = @name', {["@name"] = name, ["@point"] = guild.point}, nil)
                    end
                end
            else
                xPlayer.addInventoryItem(v.name, v.amount)  
            end
        end
    end

    return false
end

--------------------------------------------------------------------------------------

ESX.RegisterServerCallback("Guild:new",function(source,cb,name,comment)
    cb(Guild:new(source,name,comment))
end)

ESX.RegisterServerCallback("Guild:join",function(source,cb,name)
    cb(Guild:join(source,name))
end)

ESX.RegisterServerCallback("Guild:leave",function(source,cb)
    cb(Guild:leave(source))
end)

ESX.RegisterServerCallback("Guild:apply",function(source,cb,identifier,accept)
    cb(Guild:apply(source,identifier,accept))
end)

ESX.RegisterServerCallback("Guild:modify",function(source,cb,name,data)
    cb(Guild:modify(name,data))
end)

ESX.RegisterServerCallback("Guild:kick",function(source,cb,identifier)
    cb(Guild:kick(source,identifier))
end)

ESX.RegisterServerCallback("Guild:changeGrade",function(source,cb,identifier,grade)
    cb(Guild:changeGrade(source,identifier,grade))
end)

ESX.RegisterServerCallback("Guild:upgrade",function(source,cb)
    cb(Guild:upgrade(source))
end)

ESX.RegisterServerCallback("Guild:skillUpgrade",function(source,cb,skill)
    cb(Guild:skillUpgrade(source,skill))
end)

ESX.RegisterServerCallback("Guild:shop",function(source,cb,item)
    cb(Guild:shop(source,item))
end)

ESX.RegisterServerCallback("Guild:missionHandin",function(source,cb,level,index)
    cb(Guild:missionHandin(source,level,index))
end)

ESX.RegisterServerCallback("Guild:load",function(source,cb)
    cb(Guild:load(source))
end)

--------------------------------------------------------------------------------------

RegisterCommand("reloadGuild", function() 
    Guild:init(false) 
    TriggerClientEvent("Guild:client:onChange", -1)
end, true)

RegisterNetEvent("Guild:server:onChange")
AddEventHandler("Guild:server:onChange",function ()
    Guild:init(false) 
    TriggerClientEvent("Guild:client:onChange", -1)
end)

--------------------------------------------------------------------------------------

CreateThread(function()
    Guild:init(true)
end)

CreateThread(function()
    while true do
        Wait(500)
        if tonumber(os.date("%H",os.time())) == 0 and tonumber(os.date("%M",os.time())) == 0 and tonumber(os.date("%S",os.time())) == 0 then
            --midnight
            ----shop reset
            MySQL.Sync.execute('UPDATE `guild_player` SET `shop`= DEFAULT', {}, nil)
            ----mission reset
            local Sync = false
            MySQL.Async.fetchAll('SELECT `identifier`,`mission` FROM `guild_player`', {}, function(collect)
                if collect[1] then
                    for i=1, #collect do
                        local tempMission = collect[i].mission
                        tempMission = json.decode(tempMission)
                        for j, v in ipairs(tempMission.easy) do
                            tempMission.easy[j] = 0
                        end
                        for j, v in ipairs(tempMission.medium) do
                            tempMission.medium[j] = 0
                        end
                        MySQL.Sync.execute('UPDATE `guild_player` SET `mission`= @mission WHERE identifier = @identifier', {["@identifier"] = collect[i].identifier, ['@mission']=json.encode(tempMission)}, nil)
                    end
                end
                Sync = true
            end)

            while not Sync do
                print("wait")
                Wait(1)
            end
            
            if tonumber(os.date("%d",os.time())) == 0 then
                --a month
                MySQL.Sync.execute('UPDATE `guild_player` SET `mission`= DEFAULT', {}, nil)
            end

            TriggerEvent("Guild:server:onChange")
        end
    end
end)