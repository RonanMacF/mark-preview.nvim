function! ReloadOnChange()
    lua for k in pairs(package.loaded) do if k:match("^myluamodule") then package.loaded[k] = nil end end
    let lowercaseAlphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    let g:localMarks = {}

    for letter in lowercaseAlphabet
        let markPos = nvim_buf_get_mark( 0, letter )
        if markPos != [ 0, 0 ]
            let g:localMarks[letter] = markPos[0]
        endif
    endfor

    let uppercaseAlphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    let g:globalMarks = {}
    let fname = expand('~/.local/share/nvim/shada/main.shada')
    let mpack = readfile(fname, 'b')
    let shada_objects = msgpackparse(mpack)
    for line in shada_objects 
        if type(line) == 4
            let mark = get(line, 'n', "NONE")
            if mark !=# "NONE"
                if mark > 64 && mark < 91
                    echom(line)
                    let g:globalMarks[nr2char(mark)] = line
                endif
            endif
        endif
    endfor
    
    echom(g:localMarks)
    echom(g:globalMarks)
    lua require("myluamodule").printWindowSize()
endfunction

augroup triggerOnResize
    autocmd!
    autocmd VimResized * :lua require("myluamodule").onResize()
augroup

" The VimL/VimScript code is included in this file to demonstrate that the
" file is being loaded. It is not required for the Lua code to execute and can
" be deleted.

echo "mynewplugin.vim: VimL code executing."

function LuaDoItVimL()
    echo "mynewplugin.vim LuaDoItVimL(): hello"
endfunction

" Neovim knows about finding VimL files in the `plugin` directory, but it
" won't find Lua files in the same location. So, you need to bootstrap your
" Lua code using a VimL file. There are two possibilities:

" 1. Lua code can be embedded in a VimL file by using a lua block.
lua <<EOF
    function lua_do_it_lua()
        print("mynewplugin.vim lua_do_it_lua(): hello")
    end

    print "mynewplugin.vim: Lua code executing."
EOF

" 2. Lua code can be built in a pure Lua file and imported as a module from
" the VimL file. `myluamodule` is a directory in the `lua` folder. Because
" only the `myluamodule` directory is specified, Neovim will look for a
" `lua.lua` file, then an `init.lua` file in that directory. In this case, it
" will find the `lua\myluamodule\init.lua` file.
lua myluamodule = require("myluamodule")

" Once the `require` statement completes, the `global_lua_function` Lua
" function defined in `lua\myluamodule\init.lua` will be available without
" qualification.
lua global_lua_function()

" Once the `require` statement completes, the `local_lua_function` Lua
" function defined in `lua\myluamodule\init.lua` will be available when
" qualified with the module name.
lua myluamodule.local_lua_function()

" A Lua function can be mapped to a key. Here, Alt-Ctrl-G will echo a message.
" This is a mapping to the function that wasn't carefully scoped in the Lua
" file. Since this function was exported globally, that symbol is available
" everywhere, once the module has been loaded. (See the `require` statement
" above.)
nmap <M-C-G> :lua global_lua_function()<CR>

" A local Lua function can be mapped to a key, if it was exported from the
" module. Here, Alt-Ctrl-L will echo a message.  This is a mapping to the
" function that was qualified with `local`, so it is only available outside
" the module when qualified with the module name.  (See the `require`
" statement above.)
nmap <M-C-L> :lua myluamodule.local_lua_function()<CR>

" Lua code can be defined in other files, rather than just `lua.lua` or
" `init.lua`. Here, Lua code is defined in `lua\myluamodule\definestuff.lua`.
lua require("myluamodule.definestuff").show_stuff()
