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
    print("ronan end vim")
    lua require("myluamodule").printWindowSize()
endfunction

augroup triggerOnResize
    autocmd!
    autocmd VimResized * :lua require("myluamodule").onResize()
augroup

