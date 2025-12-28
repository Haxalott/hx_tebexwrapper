lib.callback.register('hx_tebexclaim:client:getCode', function()
    local code <const> = lib.inputDialog('Redeem Tebex Order', {
        { type = 'input', label = 'Enter your code', icon = 'code', required = true, placeholder = 'tbx-xxxxxxxxxxxxxx-xxxxxx', min = 20, max = 30 }
    })

    if (not code or not code[1]) then
        return false
    else
        return code[1]:match('^%s*(.-)%s*$')
    end
end)
