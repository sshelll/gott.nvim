local gott = {}
local builtin = require('gott_builtin')

gott.opts = {
    keep = function()
        return true
    end,
    render = 'default',
}

gott.run_test_under_cursor = function(args)
    if not builtin.pre_check() then
        return
    end

    local pos = builtin.get_pos_under_cursor()
    local dir = vim.fn.expand('%:p:h')
    local filename = vim.fn.expand('%:p')

    local cmd = string.format("!cd %s && gott --pos %s:%s %s", dir, filename, pos, args or "")

    local opts = vim.tbl_deep_extend("force", {}, gott.opts)
    opts.title = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':p:~:.')

    builtin.exec(cmd, opts)
end

gott.run_test_by_file = function(args)
    if not builtin.pre_check() then
        return
    end

    local dir = vim.fn.expand('%:p:h')
    local filename = vim.fn.expand('%:p')

    local cmd = string.format("!cd %s && gott --runFile %s %s", dir, filename, args or "")

    local opts = vim.tbl_deep_extend("force", {}, gott.opts)
    opts.title = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':p:~:.')

    builtin.exec(cmd, opts)
end

local function create_cmd()
    vim.api.nvim_create_user_command(
        'Gott',
        function(opts)
            local args = unpack(opts.fargs)
            gott.run_test_under_cursor(args)
        end,
        {
            nargs = "*",
        }
    )
    vim.api.nvim_create_user_command(
        'GottFile',
        function(opts)
            local args = unpack(opts.fargs)
            gott.run_test_by_file(args)
        end,
        {
            nargs = "*",
        }
    )
    vim.api.nvim_create_user_command(
        'GottClear',
        function()
            if not pcall(require, 'notify') then
                return
            end
            require('notify').dismiss()
        end,
        {}
    )
end


gott.setup = function(opts)
    gott.opts = vim.tbl_deep_extend("force", gott.opts, opts or {})
    create_cmd()
end

return gott
