local gott = {}

gott.opt = {
    timeout = 5000,
    keep = function()
        return true
    end,
}

local function pre_check()
    -- check if 'gott' shell command exists
    local cmd = vim.fn.executable('gott')
    if cmd == 0 then
        vim.api.nvim_err_writeln("gott: command not found, please install it first")
        return false
    end
    return true
end

local function get_pos_under_cursor()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line, col = cursor[1], cursor[2]

    -- get all lines
    local allLines = vim.api.nvim_buf_get_lines(0, 0, line, false)

    -- find the byte position of the cursor
    local pos = 0
    for i = 1, line - 1 do
        pos = pos + #allLines[i] + 1
    end
    pos = pos + col

    return pos
end

local function split(str, sep)
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

local function exec(cmd)
    local parsedCmd = vim.api.nvim_parse_cmd(cmd, {})

    local output = vim.api.nvim_cmd(parsedCmd, { output = true })
    local splited = split(output, "\n")
    table.remove(splited, 1)

    local displayed = vim.notify(
        splited,
        vim.log.levels.INFO,
        {
            title = "gott",
            icon = "",
            timeout = gott.opt.timeout,
            keep = gott.opt.keep,
        }
    )
    if not displayed then
        vim.api.nvim_err_writeln(output)
    end
end


gott.run_test_under_cursor = function(args)
    if not pre_check() then
        return
    end

    local pos = get_pos_under_cursor()
    local dir = vim.fn.expand('%:p:h')
    local filename = vim.fn.expand('%:p')

    local cmd = string.format("!cd %s && gott --pos %s:%s %s", dir, filename, pos, args or "")

    exec(cmd)
end

gott.run_test_by_file = function(args)
    if not pre_check() then
        return
    end

    local dir = vim.fn.expand('%:p:h')
    local filename = vim.fn.expand('%:p')

    local cmd = string.format("!cd %s && gott --runFile %s %s", dir, filename, args or "")

    exec(cmd)
end

local function create_cmd()
    vim.api.nvim_create_user_command(
        'Gott',
        function(opts)
            local args = unpack(opts.fargs)
            gott.run_test_under_cursor(args)
        end,
        {}
    )
    vim.api.nvim_create_user_command(
        'GottFile',
        function(opts)
            local args = unpack(opts.fargs)
            gott.run_test_by_file(args)
        end,
        {}
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


gott.setup = function(opt)
    gott.opt = vim.tbl_deep_extend("force", gott.opt, opt or {})
    create_cmd()
end

return gott
