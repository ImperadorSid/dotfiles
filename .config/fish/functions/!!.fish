function !!
  set last_command 1

  while test $history[$last_command] = '!!'
    set last_command (math $last_command + 1)
  end
  
  eval $history[$last_command]
end

