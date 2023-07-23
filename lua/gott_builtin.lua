-- Copyright (c) 2023 sshelll, the gott.nvim authors. All rights reserved.
-- Use of this source code is governed by a BSD-style license that can
-- be found in the LICENSE file.

local builtin = {}

function builtin.pre_check()
    -- check if the current file is a go test file
    local filename = vim.fn.expand('%:p')
    if not string.match(filename, "_test.go$") then
        vim.api.nvim_err_writeln("gott: not a go test file.")
        return false
    end

    -- check if gott is installed
    local cmd = vim.fn.executable('gott')
    if cmd == 0 then
        vim.api.nvim_err_writeln(
            "gott: command not found, please install it first. Try 'go install github.com/sshelll/gott@latest'.")
        return false
    end
    return true
end

function builtin.get_pos_under_cursor()
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

function builtin.split(str, sep)
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

function builtin.exec(cmd, opts)
    local parsedCmd = vim.api.nvim_parse_cmd(cmd, {})

    local output = vim.api.nvim_cmd(parsedCmd, { output = true })
    local splited = builtin.split(output, "\n")
    table.remove(splited, 1)

    local displayed = vim.notify(
        splited,
        vim.log.levels.INFO,
        {
            title = string.format("gott: %s", opts.title),
            render = opts.render,
            icon = "",
            timeout = opts.timeout,
            keep = opts.keep,
        }
    )
    if not displayed then
        vim.api.nvim_err_writeln(output)
    end
end

function builtin.exec_async(cmd, opts)
    local parsedCmd = vim.api.nvim_parse_cmd(cmd, {})

    local async_exec = function()
        local output = vim.api.nvim_cmd(parsedCmd, { output = true })
        local splited = builtin.split(output, "\n")
        table.remove(splited, 1)

        local displayed = vim.notify(
            splited,
            vim.log.levels.INFO,
            {
                title = string.format("gott: %s", opts.title),
                render = opts.render,
                icon = "",
                timeout = opts.timeout,
                keep = opts.keep,
            }
        )
        if not displayed then
            vim.api.nvim_err_writeln(output)
        end
    end

    local co = coroutine.create(async_exec)
    coroutine.resume(co)
end

return builtin
