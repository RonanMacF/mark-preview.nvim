-- Since this function doesn't have a `local` qualifier, it will end up in the
-- global namespace, and can be invoked from anywhere using:
--
-- :lua global_lua_function()
--
-- Personally, I feel that kind of global namespace pollution should probably
-- be avoided in order to prevent other modules from accidentally clashing with
-- my function names. While `global_lua_function` seems kind of rare, if I had
-- a function called `connect` in my module, I would be more concerned. So I
-- normally try to follow the pattern demonstrated by `local_lua_function`. The
-- right choice might depend on your circumstances.
function global_lua_function()
    print "mynewplugin.myluamodule.init global_lua_function: hello"
end

-- This function is qualified with `local`, so it's visibility is restricted to
-- this file. It is exported below in the return value from this module using a
-- Lua pattern that allows symbols to be selectively exported from a module.
local function local_lua_function()
    print "mynewplugin.myluamodule.init local_lua_function: hello"
end

local function printWindowSize( )
    tmp = vim.fn.eval("g:localMarks")
    tmp2 = vim.fn.eval("g:globalMarks")
    print(tmp)
    print(tmp2)
    local fname = '/Users/ronan/.local/share/nvim/shada/main.shada'
    local io = require "io"
    local open = io.open
    local file = open(fname, "rb") -- r read mode and b binary mode
    local content = file:read "*a"    
    -- local f = assert(loadfile("/Users/ronan/.vim/mynewplugin/lua/myluamodule/msgpack.lua"))

    -- local decoded = msgpack.decode(content)
    -- msgpack = require('msgpack')
    -- local value = msgpack.decode(content) -- decode to Lua value
    -- local binary_data = msgpack.encode(lua_value)

    local stats = vim.api.nvim_list_uis()[1]
    -- local height = vim.fn.nvim_win_get_height(0)
    local height = stats.height
    local width = stats.width
    print(height , " " , width)

    -- local buf = vim.api.nvim_create_buf(false, true)
    -- local winId = vim.api.nvim_open_win( buf, true, {
    --     relative="editor",
    --     width = width - 4,
    --     height = height - 4,
    --     col = 2,
    --     row = 2,
    -- })

    print "chicken dinner3"
end

local function onResize()

end
-- Returning a Lua table at the end allows fine control of the symbols that
-- will be available outside this file. By returning the table, it allows the
-- importer to decide what name to use in their own code.
--
-- Examples of how this module is imported:
                                --    local mine = require('myluamodule')
--    mine.local_lua_function()
--    local myluamodule = require('myluamodule')
--    myluamodule.local_lua_function()
return {
    local_lua_function = local_lua_function,
    printWindowSize = printWindowSize,
}
