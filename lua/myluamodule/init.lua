-- local winID

local function center(str)
    local width = vim.api.nvim_win_get_width(0)
    local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
    return string.rep(' ', shift) .. str
end

local function close_window()
  vim.api.nvim_win_close(win, true)
end

-- Our file list start at line 4, so we can prevent reaching above it
-- from bottm the end of the buffer will limit movment
local function move_cursor(winID, delta, numGlobalMarks, maxLine)
  -- moving up the screen
  new_pos = 0
  local curr_pos = vim.api.nvim_win_get_cursor(winID)[1]
  if delta == -1 then
    new_pos = math.max(4, (curr_pos-1))
    if new_pos < 3 + numGlobalMarks + 3 and new_pos > 3 + numGlobalMarks then
      new_pos = 3 + numGlobalMarks
    end
  else
    new_pos = math.min(maxLine, (curr_pos + 1))
    if new_pos < 3 + numGlobalMarks + 3 and new_pos > 3 + numGlobalMarks then
      new_pos = 3 + numGlobalMarks + 3
    end 
  end

  vim.api.nvim_win_set_cursor(winID, {new_pos, 0})
  print(vim.api.nvim_get_current_line())
end

-- Open file under cursor
function open_file( marks )
  local currLine = vim.api.nvim_get_current_line()
  local mark = string.sub(currLine, 0, 1)
  markData = marks[mark]
  close_window()
  if mark >= 'a' and mark <= 'z' then
    winID = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_cursor(winID, {markData, 0}) -- set cursor on first list entry
    return
  else    
  -- it is a global mark
  file = markData["f"]
  lineNum = markData["l"]
  vim.api.nvim_command('edit +'..lineNum.." "..file)
  end
end

local function calculateMaxLine( numGlobalMarks, numLocalMarks)
  minimumLine = 3
  if numLocalMarks == 0 then
    return minimumLine + numGlobalMarks
  end

  return minimumLine + numGlobalMarks + 2 + numLocalMarks
end

local function set_mappings(winID, files, numGlobalMarks, maxLine)
    local mappings = {
        e = 'open_file( files )',
        ['<cr>'] = 'open_file( files )',
        q = 'close_window(winID)',
        k = 'move_cursor(winID, -1, numGlobalMarks, maxLine)',
        ['<up>'] = 'move_cursor(winID, -1, numGlobalMarks, maxLine)',
        j = 'move_cursor(winID, 1, numGlobalMarks, maxLine)',
        ['<down>'] = 'move_cursor(winID, 1, numGlobalMarks, maxLine)',
    }

    for k,v in pairs(mappings) do
        vim.api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"myluamodule".'..v..'<cr>', {
            nowait = true, noremap = true, silent = true
        })
    end
end

local function printWindowSize( )
    -- get mark data
    localMarks = vim.fn.eval("g:localMarks")
    globalMarks = vim.fn.eval("g:globalMarks")

    local stats = vim.api.nvim_list_uis()[1] -- get details of the UI

    -- extract height and width data from the UI as opposed to window
    local height = stats.height
    local width = stats.width

    -- (not-listed buffer, scratch buffer)
    local buf = vim.api.nvim_create_buf( false, true )
    -- vim.api.nvim_buf_set_lines(buf, 3, -1, false, marks)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')


    files = {}
    globalOutput = {}
    localOutput = {}
    -- generate the output to be displated on the floating window
    numGlobalMarks = 0
    for mark,line in pairs(globalMarks) do
      out = mark.."  "..line["f"]..":"..tostring(line["l"])
      table.insert(globalOutput ,out )
      numGlobalMarks = numGlobalMarks + 1

      -- add to files
      files[string.char(line["n"])] = line
    end
    table.sort(globalOutput )

    fname =vim.fn.eval("expand('%:t')") 
    numLocalMarks = 0
    for mark,line in pairs(localMarks) do
      localLine = mark.." "..fname..":"..line
      table.insert(localOutput , localLine)
      numLocalMarks = numLocalMarks + 1

      files[mark] = line
    end
    if next(localOutput) == nil then
      table.insert(localOutput , "no local marks for "..fname )
    end
    table.sort(localOutput )
      
    -- buffer, start, end, strict_indexing(outOfBounds == error), array data
    -- fill content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        center('mark-preview.nvim'),
        ''
    })
    vim.api.nvim_buf_set_lines(buf, 2, -1, false, {
        'Global Marks',
        ''
    })
    vim.api.nvim_buf_set_lines(buf, 3, -1, false, globalOutput )
    localMarkBegin = 3 + numGlobalMarks + 6
    vim.api.nvim_buf_set_lines(buf, localMarkBegin, -1, false, {
        '',
        'Local Marks'
    })
    vim.api.nvim_buf_set_lines(buf, localMarkBegin + 1, -1, false, localOutput)

    -- true == bring into focus
    winID = vim.api.nvim_open_win( buf, true, {
        style = "minimal", -- disable line number or error highlighting
        relative="editor",
        width = width - 8,
        height = height - 4,
        col = 2,
        row = 2,
    })

    maxLine = calculateMaxLine(numGlobalMarks, numLocalMarks)
    set_mappings( winID, files, numGlobalMarks, maxLine)
    vim.api.nvim_win_set_cursor(winID, {4, 0}) -- set cursor on first list entry
end

return {
    local_lua_function = local_lua_function,
    printWindowSize = printWindowSize,
    update_view = update_view,
    move_cursor = move_cursor,
    close_window = close_window,
    open_file = open_file
}
