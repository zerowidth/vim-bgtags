let g:bgtags_job = 0
let g:bgtags_command = ""
let g:bgtags_queue = []

function! bgtags#Reset()
  if type(g:bgtags_job) == v:t_job
    call job_stop(g:bgtags_job, "KILL")
  endif
  let g:bgtags_job = 0
  let g:bgtags_command = ""
  let g:bgtags_queue = []
endfunction

function! bgtags#EchoHandler(channel, msg)
  echomsg a:msg
endfunction

func! bgtags#ExitHandler(job, status)
  let g:bgtags_job = 0
  let g:bgtags_command = ""
  if a:status != 0
    echomsg 'error while generating tags! ' . a:status
    let g:bgtags_queue = []
  else
    call bgtags#ProcessQueue()
  endif
endfunc

function! bgtags#Fetch(dict, key, default)
  if has_key(a:dict, a:key)
    return a:dict[a:key]
  else
    return a:default
  endif
endfunction

function! bgtags#ProcessQueue()
  " echomsg "processing queue: " . string(g:bgtags_queue)
  if type(g:bgtags_job) == v:t_job
    " echomsg "job still running"
    return
  endif
  if len(g:bgtags_queue) > 0
    let cmd = remove(g:bgtags_queue, 0)
    if cmd == 'DONE'
      echo "done generating tags"
      return
    endif
    " echomsg "kicking off " . cmd
    let g:bgtags_command = cmd
    let g:bgtags_job = job_start(['sh', '-c', cmd], {'callback': 'bgtags#EchoHandler', 'exit_cb': 'bgtags#ExitHandler'})
  else
    " echomsg "queue clear, done"
  endif
endfunction

function! bgtags#UpdateTags()
  " TODO handle plain string value if not dict
  let directories_commands = bgtags#Fetch(g:bgtags_user_commands, 'directories', {})
  let update_command = ""
  for [key, cmd] in items(directories_commands)
    if key == 'default'
      cont
    endif
    if isdirectory(key)
      let update_command = cmd
      break
    endif
  endfor
  if empty(update_command)
    let update_command = bgtags#Fetch(directories_commands, 'default', 'ctags -R')
  endif
  if type(update_command) == v:t_list
    " echomsg "queueing update command as list: " . update_command
    let g:bgtags_queue = update_command
  else
    " echomsg "queueing update command as single: " . update_command
    let g:bgtags_queue = [update_command]
  end
  call add(g:bgtags_queue, 'DONE')
  call bgtags#ProcessQueue()
endfunction

function! bgtags#UpdateTagsForFile(file)
  if !filereadable("tags")
    return
  endif
  let filename = shellescape(a:file)
  let cmd = 'grep -v '.filename.' tags > tags.new && mv -f tags.new tags >/dev/null'
  call add(g:bgtags_queue, cmd)
  call add(g:bgtags_queue, 'ctags -f- '.filename.' >> tags')
  call bgtags#ProcessQueue()
endfunction
