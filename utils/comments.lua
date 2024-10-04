-- strip space from around text and drop everything after ":"
function trim(arg)
    arg = arg:match("^%s*(.*)%s*$")
    arg = arg:match("^([^:]+).*")
    return arg
end

-- grab all the args except "self" and add them to the output table
function parse_args(args, output)
    for _, arg in ipairs(args) do
        arg = trim(arg)
        if arg ~= "self" then
            table.insert(output, indent_padding .. arg .. ': <++>')
        end
    end
    return output
end

vim.api.nvim_create_user_command("Blarg",
    function(opts)

        local start = opts.line1 - 1
        local stop = opts.line2
        local lines = vim.api.nvim_buf_get_lines(0, start, stop, false)
        local buff = table.concat(lines, ' ')

        _, _, init_padding = string.find(buff, "^(%s*)")
        init_padding = init_padding .. "    "
        indent_padding = init_padding .. "    "

        _, _, arg_block = string.find(buff, ".*%((.*)%).*")
        args = {}

        for arg in string.gmatch(arg_block, "([^,]+)") do
            table.insert(args, arg)
        end

        output = {}
        table.insert(output, init_padding .. '"""')
        table.insert(output, init_padding .. 'Arguments')
        table.insert(output, init_padding .. '---------')

        output = parse_args(args, output)

        table.insert(output, '')
        table.insert(output, init_padding .. 'Returns')
        table.insert(output, init_padding .. '-------')
        table.insert(output, indent_padding .. '<++>')
        table.insert(output, init_padding .. '"""')

        vim.api.nvim_buf_set_lines(0, stop, stop, false, output)

    end,
{nargs=0, range=1})
