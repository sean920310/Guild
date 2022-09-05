Config = {}

Config.debug = true

Config.key = 311

Config.upgradeCost = {
    money = 15000,
    point = 5000
}

Config.shopItem = {
    green_material = {
        name = "green_material",
        money = 100,
        limit = 5,
        level = 2
    },
    blue_material = {
        name = "blue_material",
        money = 500,
        limit = 5,
        level = 4
    },
    purple_material = {
        name = "purple_material",
        money = 1000,
        limit = 5,
        level = 6
    },
    gold_material = {
        name = "gold_material",
        money = 2000,
        limit = 5,
        level = 8
    },
    red_material = {
        name = "red_material",
        money = 5000,
        limit = 5,
        level = 10
    }
}

Config.misson = {
    easy = {
        {
            type = "hand_in",
            item = "money",
            amount = 10000,
            describe = "繳交10000金幣"
        },
        {
            type = "hand_in",
            item = "water",
            amount = 10,
            describe = "繳交10瓶水"
        }
    },
    medium = {
        {
            type = "kill",
            name = "player",
            amount = 10,
            describe = "擊殺10名玩家"
        },
        {
            type = "attend",
            name = "pvp",
            amount = 5,
            describe = "參加5次PVP模式"
        }
    },
    hard = {
        {
            type = "harm",
            name = "boss",
            amount = 15000,
            describe = "對boss造成15000傷害"
        },
        {
            type = "win",
            name = "pvp",
            amount = 5,
            describe = "贏得5次PVP模式勝利"
        }
    }
}