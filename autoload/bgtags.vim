let s:job = 0
let s:command = ""
let s:queue = []

function! bgtags#UpdateTags()
  echo 'updating tags...' | redraw
  let update_command = s:DirectoryCommand()
  call s:debug('queueing update command: ' . string(update_command))
  if type(update_command) == v:t_list
    let s:queue = [] + update_command
  else
    let s:queue = [update_command]
  end
  call add(s:queue, 'DONE')
  call s:process()
endfunction

function! bgtags#UpdateTagsForFile(file)
  if !filereadable('tags')
    return
  endif
  if !filereadable(a:file)
    return
  endif
  let filename = shellescape(a:file)
  let remove = 'grep -v ''\t' . filename[1:-1] . ' tags > tags.new && ' .
        \ 'mv -f tags.new tags >/dev/null'
  call add(s:queue, remove)
  let restore = s:FiletypeCommand()
  call add(s:queue, restore . ' ' . filename . ' >> tags')
  call s:process()
endfunction

function! bgtags#Reset()
  if type(s:job) == v:t_job
    call job_stop(s:job, "kill")
  endif
  let s:job = 0
  let s:command = ""
  let s:queue = []
endfunction

function! s:DirectoryCommand()
  if exists('g:bgtags_user_commands')
    let directories = s:fetch(g:bgtags_user_commands, 'directories', {})
  else
    let directories = {}
  endif
  for [key, cmd] in items(directories)
    if key == 'default'
      cont
    endif
    if isdirectory(key)
      return cmd
      break
    endif
  endfor
  return s:fetch(directories, 'default', 'ctags -R')
endfunction

function! s:FiletypeCommand()
  if exists('g:bgtags_user_commands')
    let filetypes = s:fetch(g:bgtags_user_commands, 'filetypes', {})
  else
    let filetypes = {}
  endif
  return s:fetch(filetypes, &ft, s:fetch(filetypes, 'default', 'ctags -f-'))
endfunction

function! s:process()
  call s:debug('processing queue: ' . string(s:queue))
  if type(s:job) == v:t_job
    call s:debug('job still running')
    return
  endif
  if len(s:queue) > 0
    let cmd = remove(s:queue, 0)
    if cmd == 'DONE'
      echo 'tags updated.' | redraw
      return
    endif
    call s:debug('running ' . cmd)
    let s:command = cmd
    let s:job = job_start(['sh', '-c', cmd],
          \ {'callback': 'bgtags#EchoHandler', 'exit_cb': 'bgtags#ExitHandler'})
  else
    call s:debug('queue clear, done')
  endif
endfunction

" can't scope these to the script, job_start callbacks complains
function! bgtags#EchoHandler(channel, msg)
  echomsg a:msg
endfunction

function! bgtags#ExitHandler(job, status)
  let s:job = 0
  let s:command = ''
  if a:status != 0
    echomsg 'error while generating tags! exit status ' . a:status
    let s:queue = []
  else
    call s:process()
  endif
endfunc

function! s:fetch(dict, key, default)
  if has_key(a:dict, a:key)
    return a:dict[a:key]
  else
    return a:default
  endif
endfunction

function! s:debug(msg)
  if g:bgtags_debug
    echomsg a:msg
  endif
endfunction
