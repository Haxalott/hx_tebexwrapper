-- This is server sided dont worry about your webhook getting leaked
Config = {
    webhook = 'https://discord.com/api/webhooks/1416397913457823796/bn9hlXZeKsk5g2nhcm_SfuuocZrhb_KDLC3LxhYKNHkTG0L0r4gvmOR7-fdQYGe7U0q3',

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
