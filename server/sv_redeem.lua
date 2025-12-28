function GetPlayerFromId(source)
    return exports.qbx_core:GetPlayer(source)
end

---@param playerId integer
---@param title string
---@param data table
function DiscordLog(playerId, title, data)
    local fields = {}
    if (playerId ~= nil) then
        local player = GetPlayerFromId(playerId)
        if player and player.PlayerData then
            fields[#fields + 1] = {
                name = 'Player',
                value = ('%s %s (id: %s)'):format(
                    player.PlayerData.charinfo.firstname,
                    player.PlayerData.charinfo.lastname,
                    tostring(playerId)
                ),
                inline = false
            }
        end
    end

    for _, row in pairs(data) do
        fields[#fields + 1] = {
            name = row.key,
            value = tostring(row.value),
            inline = true
        }
    end

    local body = {
        username = "Tebex Logs",
        avatar_url = "https://cdn.discordapp.com/attachments/1213682269219192892/1274689499527385160/haxalotts_development.png",
        content = '<@&1338486170958434346>',
        embeds = {
            {
                type = "rich",
                title = title,
                description = '',
                color = 0x2ecc71,
                fields = fields
            }
        }
    }

    PerformHttpRequest(
        Config.webhook,
        function(err, text, header) end,
        "POST",
        json.encode(body),
        {["Content-Type"] = "application/json"}
    )
end

MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `hx_tebex_active_orders` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(50) NOT NULL,
            `code` VARCHAR(30) NOT NULL,
            `redeemed` TINYINT(1) NOT NULL DEFAULT 0,
            PRIMARY KEY (`id`)
        )
    ]])
end)

Database = {}
Database.Functions = {
    ---@param orderId string
    ---@param packageName string
    ---@return integer
    ---@description Insert a package ordered from tebex into the database table
    AddOrder = function(orderId, packageName)
        return MySQL.insert.await('INSERT INTO `hx_tebex_active_orders` (identifier, code) VALUES (?, ?)', {
            packageName,
            orderId
        })
    end,

    ---@param orderId string
    ---@return boolean
    ---@description Mark an order as redeemed
    OrderRedeemed = function(orderId)
        return MySQL.update.await('UPDATE hx_tebex_active_orders SET redeemed = ? WHERE code = ?', {
            1, orderId
        })
    end,

    ---@param orderId string
    ---@return boolean | {identifier: string, redeemed: integer}
    OrderExists = function(orderId)
        local row <const> = MySQL.single.await('SELECT `identifier`, `redeemed` FROM `hx_tebex_active_orders` WHERE `code` = ? LIMIT 1', {
            orderId
        })

        if not row then return false end

        return {
            identifier = row.identifier,
            redeemed = row.redeemed
        }
    end,
}

exports('AddOrder', Database.Functions.AddOrder)
exports('OrderRedeemed', Database.Functions.OrderRedeemed)

lib.addCommand('redeem', {
    help = 'Redeem a tebex order'
}, function(source, args, raw)
    ---@type string | boolean
    local code <const> = lib.callback.await('hx_tebexclaim:client:getCode', source)
    print(code)
    ---@type boolean | {identifier: string, redeemed: integer}
    local orderExists <const> = Database.Functions.OrderExists(code)
    print(json.encode(orderExists, {indent = true}))

    if not orderExists then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Tebex',
            description = 'Order does not exist!',
            type = 'error'
        })
        return
    end

    if orderExists.redeemed == true then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Tebex',
            description = 'Order has already been claimed!',
            type = 'error'
        })
        return
    end

    if not orderExists.redeemed and code ~= nil then
        Config.packages[orderExists.identifier](source, {
            packageName = orderExists.identifier,
            redeemed = orderExists.redeemed,
            tebexCode = code
        })

        Database.Functions.OrderRedeemed(code)

        DiscordLog(source, 'Order Redeemed', {
            { key = 'Package Name:', value = orderExists.identifier },
            { key = 'Redeemed:', value = orderExists.redeemed },
            { key = 'Tebex Code:', value = code }
        })
    end
end)

lib.addCommand('tebex-addorder', {
    help = 'Add a order to the database',
    params = {
        {
            name = 'package_name',
            type = 'string',
            help = 'The name of the package on the tebex store',
        },
        {
            name = 'tebexCode',
            type = 'string',
            help = 'The tebex code'
        }
    },
    restricted = 'group.admin',
}, function(source, args, raw)
    print(json.encode(args, {indent = true}))
    if not args.package_name or not args.tebexCode then return error('Tebex code or package name not provided') end
    if Config.packages[args.package_name] == nil then return error(('Package name is not in the config: %s'):format(args.package_name)) end

    Database.Functions.AddOrder(args.tebexCode, args.package_name)

    DiscordLog(source, 'Tebex order Added', {
        { key = 'Package Name:', value = args.package_name },
        { key = 'Tebex Code:', value = args.tebexCode }
    })
end)
