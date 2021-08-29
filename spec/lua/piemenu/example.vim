augroup piemenu_setting
  autocmd!
  autocmd FileType piemenu call s:setting()
augroup END
function! s:setting() abort
  nnoremap <buffer> <LeftDrag> <Cmd>lua require("piemenu").highlight()<CR>
  nnoremap <buffer> <LeftRelease> <Cmd>lua require("piemenu").finish()<CR>
  nnoremap <buffer> <RightMouse> <Cmd>lua require("piemenu").cancel()<CR>
endfunction

lua << EOF
require("piemenu").register("TODO", {
  -- start_angle = 0,
  -- increment_angle = 45,
  -- tile_width = 15,
  menus = {
    {
      text = "open",
      action = function()
        -- TODO
      end,
    },
  },
})
EOF
