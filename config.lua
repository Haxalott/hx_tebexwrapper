-- This is server sided dont worry about your webhook getting leaked
Config = {
    webhook = 'CHANGE_ME',

    packages = {
        ---@param source integer
        ---@param orderData {packageName: string, redeemed: integer | boolean, tebexCode: string}
        ['Test'] = function(source, orderData)
            -- Server side only code
            exports.ox_inventory:AddItem(source, 'money', 1000)
        end,
        ['customplate'] = function(source, orderData)
            exports.ox_inventory:AddItem(source, 'customizableplate', 1)
        end
    },
}
