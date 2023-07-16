# gott.nvim

Exec go test under cursor easily.



## Screenshot

![](./img/demo.jpg)



## Requirements

- gott (required)

> Install: `go install github.com/sshelll/gott@latest `

- nvim-notify (required)

> Install: check https://github.com/rcarriga/nvim-notify for more details.



## Install

Use your nvim plug manager.

Such as: `Plug 'sshelll/gott.nvim'`



## Commands

1. `Gott`

​	Run go test under cursor. For example:

```sh
:Gott
:Gott -v
:Gott -v -race
:Gott -gcflags=all=-l -race
```

2. `GottFile`

​	Run all go tests of the current buffer. For example:

```sh
:GottFile
:GottFile -v
:GottFile -v -race
:GottFile -gcflags=all=-l -race
```

3. `GottClear`

​	Clear all the notifications.



## Configuration

```lua
require('gott').setup{
  	timeout = 3000,    -- try to close go test result notification after 3s.
    keep = function () -- decide whether to keep the notification after timeout(3s).
        return false
    end,
  	render = 'default' -- default / minimal / simple / compact, controls the notification style.
}
```

The default conf is:

```lua
require('gott').setup{
    keep = function () -- keep the notification after timeout, which means the notification window will not be closed.
        return true    -- if you want to close them, just call ':GottClear'.
    end,
  	render = 'default'
}
```

