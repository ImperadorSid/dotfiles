function tasks -d "Manage tasks"
  set -g tasks_file ~/Documents/Books/Others/tasks.json
  set tasks_count (jq 'length' $tasks_file)

  for i in (seq 0 (math "$tasks_count - 1"))
    set task (jq -r ".[$i].task" $tasks_file)
    set priority (jq -r ".[$i].priority" $tasks_file)
    set date (jq -r ".[$i].date" $tasks_file)

    switch $priority
      case 'low'
        set task_color $fish_color_comment
      case 'normal'
        set task_color $fish_color_quote
      case 'high'
        set task_color $fish_color_error

    end

    printf '%s%3d | %s | %s\n%s' (set_color $task_color) $i $date $task (set_color normal)
  end


  return
  set -e tasks_file
end

