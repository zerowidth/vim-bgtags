if exists('g:loaded_bgtags_plugin')
  finish
endif
let g:loaded_bgtags_plugin = 1

let g:bgtags_user_commands = {
  \ 'directories': {
    \ '.git': 'git ls-files -c -o --exclude-standard | ctags -L - -f - > tags',
    \ 'default': 'ctags -R'
    \ },
  \ 'filetypes': {
    \ 'ruby': 'ctags -f-',
    \ 'default': 'ctags -f-'
    \}
\ }

command! BgtagsUpdateTags call bgtags#UpdateTags()
command! BgtagsReset call bgtags#Reset()

augroup bgtags
  au!
  autocmd BufWritePost * call bgtags#UpdateTagsForFile(expand('%'))
augroup END
