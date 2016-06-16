" need augroup?
augroup plugin-quickrun-job
augroup END

let s:runner = {}
let s:job_options = {
      \ 'out_mode': 'nl',
      \ 'err_mode': 'nl',
      \ }

function! s:callback(session, ch, msg) abort
  call a:session.output(a:msg . "\n")
endfunction

function! s:close_cb(session, ch) abort
  if ch_status(a:ch) ==# 'buffered'
    call a:session.output(ch_read(a:ch))
  endif
  " how to get *actual* exit code of the job?
  let exit_code = job_status(a:session._job) ==# 'dead' ? 0 : 1
  call a:session.finish(exit_code)
  return exit_code
endfunction

function! s:runner.shellescape(str) abort
  return shellescape(a:str)
endfunction

function! s:runner.run(commands, input, session) abort
  let l:options = deepcopy(s:job_options)
  let l:options['callback'] = function('s:callback', [a:session])
  " let l:options['out_cb'] = function('s:callback', [a:session])
  " let l:options['err_cb'] = function('s:callback', [a:session])
  let l:options['close_cb'] = function('s:close_cb', [a:session])
  let cmd = split(substitute(a:commands[0], "'", '', 'g'))
  " echomsg string(cmd)
  let a:session._job =  job_start(cmd, l:options)
  call a:session.continue()
endfunction

function! quickrun#runner#job#new() abort
  return deepcopy(s:runner)
endfunction
