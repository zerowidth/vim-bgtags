if exists('g:loaded_bgtags_plugin')
  finish
endif
let g:loaded_bgtags_plugin = 1

if !exists('g:bgtags_enabled')
  let g:bgtags_enabled = 1
endif

" timeout in milliseconds
if !exists('g:bgtags_timeout')
  let g:bgtags_timeout = 30000
endif

if !exists('g:bgtags_debug')
  let g:bgtags_debug = 0
endif

command! BgtagsUpdateTags call bgtags#UpdateTags()
command! BgtagsReset call bgtags#Reset()

augroup bgtags
  au!
  autocmd BufWritePost * if g:bgtags_enabled | call bgtags#UpdateTagsForFile(expand('%')) | endif
augroup END
